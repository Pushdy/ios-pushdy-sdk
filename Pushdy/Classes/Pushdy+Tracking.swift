//
//  Pushdy+Tracking.swift
//  PushdySDK
//
//  Created by Luat on 20/8/20.
//

import Foundation

public extension Pushdy {
  public static var pendingTrackingOpenedItems:[String] = []
  
  
  /**
   Track opening push notification
   
   - Parameter data: A notification dictionary.
   
   */
  static func trackOpeningPushNotification(_ data:[String:Any]) {
      // Track open push notification
    // self.trackOpenedNow(data)
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
   *    For more detail, please read the comment in Android-pushdy-sdk
   */
  static func trackOpenedLazy(_ data:[String:Any]) {
    print("[Pushdy] trackOpenedLazy save notiId={$notificationID} to tracking queue pendingTrackingOpenedItems(before): ", self.pendingTrackingOpenedItems)
    
    if let notificationID = data["_notification_id"] as? String {
      // Save to queue + localStorage
      pendingTrackingOpenedItems.append(notificationID)
      setPendingTrackOpenNotiIds(pendingTrackingOpenedItems)
      // Delay flushing queue
      // Empty queue on success
      // NOTE: You must do this in non-blocking mode to ensure program will continue to run without any dependant on this code
      let delayInMs:Int = Int.random(in: 1...125) * 1000
      self.trackOpenedWithRetry(delayInMs: delayInMs)
    } else {
      print("[Pushdy] trackOpenedLazy was skip because of empty notificationID")
    }
  }
  
  static func trackOpenedWithRetry(delayInMs: Int) {
    let verbose = true
    if (verbose) { print("[Pushdy] trackOpenedWithRetry: delayInMs: \(delayInMs) ") }

    // Delay flushing queue
    // Empty queue on success
    // NOTE: You must do this in non-blocking mode to ensure program will continue to run without any dependant on this code
    // Tested in background: This Timer still run when app is in background, not sure for Xiaomi 3
    // Tested in closed state then open by push:

//    PDYThread.perform(onBackGroundThread: {
//      doTaskDelay()
//    }, after: Double(delayInMs / 1000))

    NSObject.cancelPreviousPerformRequests(withTarget: self)
    self.perform(#selector(__doTaskDelay), with: nil, afterDelay: Double(delayInMs / 1000))
  }
  
  @objc static func __doTaskDelay() {
    let verbose = true
    if (verbose) { print("[Pushdy] trackOpenedWithRetry: Process tracking queue after delay ${delayInMs}s | Ids= \(pendingTrackingOpenedItems.joined(separator: ", "))") }

    if let playerID = getPlayerID() {
        // NOTE: If api request was failed, we don't intend to fire again, ignore it
      try? trackOpenedList(playerID: playerID, notificationIds: pendingTrackingOpenedItems, completion: { (response:AnyObject?) in
        if (verbose) { print("[Pushdy] trackOpenedWithRetry: successfully: ", pendingTrackingOpenedItems) }
        // Empty queue on success
        pendingTrackingOpenedItems = []
        setPendingTrackOpenNotiIds(pendingTrackingOpenedItems)
      }, failure: { (errorCode:Int, message:String?) in
        if (verbose) { print("[Pushdy] trackOpenedWithRetry: error: \(errorCode) , message: \(String(describing: message))") }
      })
    } else {
      // retry after 10 seconds
      self.trackOpenedWithRetry(delayInMs: 10000)
      if (verbose) { print("[Pushdy] trackOpenedWithRetry: playerID empty, trying to retry after ${10}s") }
    }
  }
}

