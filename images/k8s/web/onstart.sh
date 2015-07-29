cd /www/app
mkdir /www/logs

http-server -a 0.0.0.0 -p 8000 1>/www/logs/http.log &

cd /www/master
npm start 1>/www/logs/gulp.log &