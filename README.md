# CTF TLS Test

## GCP Notes
```
gcloud init
gcloud auth application-default login
gcloud config set project ctf-tls-test
gcloud config set compute/zone europe-north1-a
```

## Result

```
$ host chall2.ctftest1.zetatwo.dev
chall2.ctftest1.zetatwo.dev has address 34.88.159.215
$ host chall1.ctftest1.zetatwo.dev
chall1.ctftest1.zetatwo.dev has address 34.88.159.215
$ ncat --ssl-verify chall2.ctftest1.zetatwo.dev 443
Hello pwn!
$ curl https://chall1.ctftest1.zetatwo.dev
...
<p><em>Thank you for using nginx.</em></p>
...
```
