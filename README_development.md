#Pushdy
##Release
- Nâng version trong PushdySDK.podspec
```
s.version          = '0.0.9'
```
- Chạy lệnh kiểm tra 
```
$ pod lib lint --allow-warnings
```
- Commit và tag 
```
$ git add -A && git commit -m "Release 0.0.9."
$ git tag '0.0.9'
$ git push --tags
```
- Nếu chưa đăng ký Cocapods -> đăng ký 1 session
```
$ pod trunk register orta@cocoapods.org 'Orta Therox'
```
sau đó liên hệ Owner của PushdySDK (https://cocoapods.org/pods/PushdySDK) để thêm quyền
- Xuất bản Cocapods lib
```
$ pod trunk push --allow-warnings
```