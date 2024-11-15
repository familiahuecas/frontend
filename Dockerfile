FROM nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY build/web /usr/share/nginx/html
COPY replacer.sh /usr/share/nginx/html/
RUN chmod +x /usr/share/nginx/html/replacer.sh
ENTRYPOINT ["/usr/share/nginx/html/replacer.sh"]