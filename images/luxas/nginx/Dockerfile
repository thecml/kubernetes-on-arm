FROM luxas/alpine

RUN apk-install nginx && \
	mkdir -p /usr/share/nginx/html && \
	echo "<p>WELCOME TO NGINX</p>" > /usr/share/nginx/html/index.html


#ln -sf /dev/stdout /var/log/nginx/access.log && \
#ln -sf /dev/stderr /var/log/nginx/error.log && \


CMD ["nginx", "-g", "daemon off;"]