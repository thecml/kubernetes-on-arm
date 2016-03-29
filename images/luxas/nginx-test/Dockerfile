FROM luxas/alpine

RUN apk-install nginx && \
	mkdir -p /usr/share/nginx/html && \
	echo "<p>WELCOME TO NGINX</p>" > /usr/share/nginx/html/index.html

CMD ["nginx", "-g", "daemon off;"]
