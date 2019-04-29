# ssh 重新链接时 报错
错误信息：
```
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ECDSA key sent by the remote host is
SHA256:6scLEJ3HEFbXg+58n6Wy0sF7kLWOx8mhykoEG8/nOkc.
Please contact your system administrator.
Add correct host key in /Users/renhaoran/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in /Users/renhaoran/.ssh/known_hosts:12
ECDSA host key for 47.92.26.78 has changed and you have requested strict checking.
Host key verification failed.
```
解决方法：
```
vim /Users/renhaoran/.ssh/known_hosts
```
删掉对应IP的key