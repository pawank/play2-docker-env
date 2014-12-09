# Playframework 2 Dockerfile

[Playframework](http://www.playframework.com/) for [Docker](https://www.docker.com/).


### How to build docker image?

Image uses ssh public key file inside the current directory so make sure ```id_rsa.pub``` is present.

Run ```./build.sh``` to create docker image for Playframework 2 + activator.

### How to run?

```
docker run -i -t -v /Users/pawan/git/AWS/:/opt/workspace -p 9000:9000 pawank/play_activator
```
