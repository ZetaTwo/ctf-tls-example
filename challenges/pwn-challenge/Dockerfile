FROM ghcr.io/google/nsjail/nsjail:latest

ADD src/run.sh /

ENTRYPOINT nsjail --port 1337 --chroot / --user 1337 --group 1337 /run.sh
