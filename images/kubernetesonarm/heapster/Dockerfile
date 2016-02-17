FROM luxas/alpine

COPY heapster /

RUN apk-install tar \
    && for cert in `ls -1 /etc/ssl/certs/*.crt | grep -v /etc/ssl/certs/ca-certificates.crt`; do cat "$cert" >> /etc/ssl/certs/ca-certificates.crt; done

ENTRYPOINT ["/heapster"]