FROM luxas/go

# Copy the script and the version variables
COPY inbuild.sh ../../version.sh /

# Run the build script and then remove them
RUN ./inbuild.sh && \
	rm /inbuild.sh /version.sh

CMD ["/bin/echo", "Built!"]