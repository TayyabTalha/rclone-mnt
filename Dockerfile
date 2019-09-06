FROM alpine

ARG RCLONE_VERSION=current
ARG ARCH=amd64
ENV GOPATH="/go" \
    AccessFolder="/mnt" \
    RemotePath="mediaefs:" \
    MountPoint="/mnt/mediaefs" \
    ConfigDir="/config" \
    ConfigName="rclone.conf" \
    MountCommands="--allow-other --allow-non-empty" \
    UnmountCommands="-u -z" \
    S3_TYPE="s3" \
    S3_PROVIDER="AWS"

COPY config config 

## Alpine with Go Git
#RUN apk add --no-cache --update alpine-sdk ca-certificates go git fuse fuse-dev \
#    && go get -u -v github.com/rclone/rclone \
#    && cp /go/bin/rclone /usr/sbin/ \
#    && rm -rf /go \
#    && apk del alpine-sdk go git \
#    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

RUN apk -U add ca-certificates fuse fuse-dev wget dcron tzdata \
  && rm -rf /var/cache/apk/*

RUN URL=http://downloads.rclone.org/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip ; \
  URL=${URL/\/current/} ; \
  cd /tmp \
  && wget -q $URL \
  && unzip /tmp/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip \
  && mv /tmp/rclone-*-linux-${ARCH}/rclone /usr/bin \
  && rm -r /tmp/rclone*

ADD start.sh /start.sh
RUN chmod +x /start.sh 

VOLUME ["/mnt"]

CMD ["/start.sh"]

# Use this docker Options in run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined
# -v /path/to/config/.rclone.conf:/config/.rclone.conf
# -v /mnt/mediaefs:/mnt/mediaefs:shared
