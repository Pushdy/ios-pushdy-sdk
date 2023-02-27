//
//  Pushdy+Tracking.swift
//  PushdySDK
//
//  Created by Luat on 20/8/20.
//

import Foundation

public extension Pushdy {
  public static var pendingTrackingOpenedItems:[String] = []
  public static var pendingTask:DispatchWorkItem? = nil
  
  /**
   Track opening push notification
   
   - Parameter data: A notification dictionary.
   
   */
  static func trackOpeningPushNotification(_ data:[String:Any]) {
      // Track open push notification
    // self.trackOpenedNow(data)
    
    // If you use trackOpenedLazy, you must delay trackOpeningPushNotification a little bit while click push to open app
    self.trackOpenedLazy(data)
  }
  
  @objc static func trackOpened(playerID:String?, notificationID:String, completion:PDYRequest.CompletionBlock?, failure:PDYRequest.FailureBlock?) throws {
      if let key = _clientKey {
          let notification = PDYNotification(clientKey:key, deviceID: _deviceID)
          try notification.trackOpened(playerID: playerID, notificationID: notificationID, completion: completion, failure: failure)
      }
      else {
          throw clientKeyNotSetError()
      }
  }
  
  @objc static func trackOpenedList(playerID:String?, notificationIds:[String], completion:PDYRequest.CompletionBlock?, failure:PDYRequest.FailureBlock?) throws {
      if let key = _clientKey {
          let player = PDYPlayer(clientKey:key, deviceID: _deviceID)
          try player.trackOpened(playerID: playerID, notificationIds: notificationIds, completion: completion, failure: failure)
      }
      else {
          throw clientKeyNotSetError()
      }
  }
  
  
  static func trackOpenedNow(_ data:[String:Any]) {
    // Track open push notification
    if let notificationID = data["_notification_id"] as? String {
        let playerID = getPlayerID()
        try? trackOpened(playerID: playerID, notificationID: notificationID, completion: { (response:AnyObject?) in
            print("[Pushdy] Tracked opening for push \(notificationID) successfully")
        }, failure: { (errorCode:Int, message:String?) in
          print("[Pushdy] Failed to track opening for push \(notificationID) with error \(errorCode) : \(String(describing: message))")
        })
    }
  }

  /**
   * http://redmine.mobiletech.vn/issues/6077
   * - [x] Save to trackOpenQueue
   * - [x] Flushing queue and send all pending trackOpenItems after random (1-125) seconds
   * - [x] Persist this queue to localStorage in case of user kill app before queue was flushed
   * - [x] Can send by batch if queue has multiple items
   *
   * - [x] Restore this queue when app open / app open by notification => Avoid overriten
   * - [x] In case of schedule is running => Cancel the prev schedule if you fire new schedule
   *
   *  iOS has a special running policy:
     *     - A pending task is scheduled will be pause when you put your app to BG > Resuming app will resume scheduled task, it lead to the issue bellow
     *     - If a schedule task is paused in BG > Click open new Push > You need to ensure you can track all pendingTrackingOpenedItems and the newly clicked ID (that's why we delay lazy tracking 0.5s to ensure previous scheduled task will be complete first)
     *     - delay 0.5s would not be a solution in case of slow network
     *     - iOS might still fire requests in background, then it log to console after resume? => Check on Charles proxy ?
     *     - The solution is to add notifcation right before the task started to run, not started to schedule
   *
   *    For more detail, please read the comment in Android-pushdy-sdk
   */
  static func trackOpenedLazy(_ data:[String:Any]) {
    if let notificationID = data["_notification_id"] as? String {
      NSLog("[Pushdy] trackOpenedLazy save notiId=\(notificationID) to tracking queue pendingTrackingOpenedItems(before): \(pendingTrackingOpenedItems.joined(separator: ", "))")
        
      // Save to queue + localStorage
      // Delay flushing queue
      // Empty queue on success
      // NOTE: You must do this in non-blocking mode to ensure program will continue to run without any dependant on this code
      let delayInMs:Int = Int.random(in: 4...15) * 1000
//        PDYThread.perform(
//            onBackGroundThread: {
                self.pendingTrackingOpenedItems.append(notificationID)
                setPendingTrackOpenNotiIds(pendingTrackingOpenedItems)
                self.trackOpenedWithRetry(delayInMs: delayInMs, clickedNotificationId: notificationID)
//            },
//            after: pendingTask != nil
//                ? Double(5000)    // Delay if there was a pending task
//                : Double(0)      // Execute imme if no pending task
//        )
    } else {
      NSLog("[Pushdy] trackOpenedLazy was skip because of empty notificationID")
    }
  }
  
  static func trackOpenedWithRetry(delayInMs: Int, clickedNotificationId: String? = nil) {
    let verbose = true
    if (verbose) { NSLog("[Pushdy] trackOpenedWithRetry: delayInMs: \(delayInMs) ") }

    // Delay flushing queue
    // Empty queue on success
    // NOTE: You must do this in non-blocking mode to ensure program will continue to run without any dependant on this code
    // Tested in background: This Timer still run when app is in background, not sure for Xiaomi 3
    // Tested in closed state then open by push:

    if (self.pendingTask != nil){
      self.pendingTask?.cancel()
    }
    self.pendingTask = PDYThread.performCancelable(onBackGroundThread: {
      // Only add id right before the task start to avoid data interference
//        if clickedNotificationId != nil {
//            self.pendingTrackingOpenedItems.append(clickedNotificationId ?? "")
//            setPendingTrackOpenNotiIds(pendingTrackingOpenedItems)
//            if (verbose) { NSLog("[Pushdy] performCancelable: Add notiId(\(String(describing: clickedNotificationId))) | Queue(after)= \(pendingTrackingOpenedItems.joined(separator: ", "))") }
//        }
        self.__doTaskDelay()
    }, after: Double(delayInMs / 1000))

//    NSObject.cancelPreviousPerformRequests(withTarget: self)
//    self.perform(#selector(__doTaskDelay), with: nil, afterDelay: Double(delayInMs / 1000))
  }
  
  @objc static func __doTaskDelay() {
    let verbose = true
    if (verbose) { NSLog("[Pushdy] trackOpenedWithRetry: Process tracking queue after delay | Ids= \(pendingTrackingOpenedItems.joined(separator: ", "))") }

    if let playerID = getPlayerID() {
        // NOTE: If api request was failed, we don't intend to fire again, ignore it
      try? trackOpenedList(playerID: playerID, notificationIds: pendingTrackingOpenedItems, completion: { (response:AnyObject?) in
        if (verbose) { NSLog("[Pushdy] trackOpenedWithRetry: successfully: ", pendingTrackingOpenedItems) }
        // Empty queue on success
        pendingTrackingOpenedItems = []
        setPendingTrackOpenNotiIds(pendingTrackingOpenedItems)
        self.pendingTask = nil
      }, failure: { (errorCode:Int, message:String?) in
        if (verbose) { NSLog("[Pushdy] trackOpenedWithRetry: error: \(errorCode) , message: \(String(describing: message))") }
        self.pendingTask = nil
      })
    } else {
      // retry after 10 seconds
      self.trackOpenedWithRetry(delayInMs: 10000)
      if (verbose) { NSLog("[Pushdy] trackOpenedWithRetry: playerID empty, trying to retry after ${10}s") }
    }
  }

  @objc static func trackEvent(eventName: String, params: NSObject, immediate: Bool = false, completion:PDYRequest.CompletionBlock?, failure:PDYRequest.FailureBlock?) throws {
    if let playerID = getPlayerID() {
			let event: NSObject = [
				"event": eventName,
				"properties": params,
				"created_at": Int(Date().timeIntervalSince1970),
				"player_id": playerID
			] as NSObject
			NSLog("[Pushdy] trackEvent: \(event)");

      var pendingEvents: [NSObject] = getPendingTrackEvents(count: 999);
      pendingEvents.append(event)
			if (immediate) {
				pushPendingEvents()
			} else {
				pendingEvents.append(event)
				setPendingTrackEvents(pendingEvents)
			}
    } else {
      NSLog("[Pushdy] trackEvent: playerID empty");
    }
  }

	@objc static func pushPendingEvents() {
    if let playerID = getPlayerID() {
      let Event = PDYEvent(clientKey:_clientKey ?? "", deviceID: _deviceID);
      let pendingEvents: [NSObject] = getPendingTrackEvents(count: 50);
      if (pendingEvents.count > 0) {
        NSLog("[Pushdy] pushPendingEvents: \(pendingEvents)");
          try? Event.pushPendingEvents(events: pendingEvents, application_id: _applicationId, playerID: playerID, completion: { (response:AnyObject?) in
          NSLog("[Pushdy] pushPendingEvents: successfully: \(response)")
          // remove 50 events from pendingEvents
          var pendingEvents: [NSObject] = getPendingTrackEvents(count: 999);
          if pendingEvents.count > 50 {
            pendingEvents.removeFirst(50)
          } else {
              pendingEvents = [];
          }
          setPendingTrackEvents(pendingEvents)
        }, failure: { (errorCode:Int, message:String?) in
          NSLog("[Pushdy] pushPendingEvents: error: \(errorCode) , message: \(String(describing: message))")
        })
      } else {
        NSLog("[Pushdy] pushPendingEvents: pendingEvents empty");
      }
    } else {
      NSLog("[Pushdy] pushPendingEvents: playerID empty");
    }
  }
}

