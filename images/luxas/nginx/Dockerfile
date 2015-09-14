FROM luxas/alpine

RUN apk-install nginx && \
	ln -sf /dev/stdout /var/log/nginx/access.log && \
	ln -sf /dev/stderr /var/log/nginx/error.log && \
	mkdir -p /usr/share/nginx/html && \
	cat > /usr/share/nginx/html/index.html <<EOF
<p>welcome to nginx</p>
EOF



CMD ["nginx", "-g", "daemon off;"]