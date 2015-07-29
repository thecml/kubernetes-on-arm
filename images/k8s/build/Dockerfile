FROM luxas/go

COPY inbuild.sh /inbuild.sh

RUN ./inbuild.sh && rm /inbuild.sh

CMD ["/bin/echo", "Built!"]