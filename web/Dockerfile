FROM nginx:1.21.6

EXPOSE 8080

ENV CATALOGUE_HOST=catalogue \
    USER_HOST=user \
    CART_HOST=cart \
    SHIPPING_HOST=shipping \
    PAYMENT_HOST=payment \
    RATINGS_HOST=ratings

RUN rm -f /usr/share/nginx/html/*.html

COPY default.conf.template /etc/nginx/conf.d/default.conf.template
COPY web/*.html /usr/share/nginx/html/
COPY web/static/ /usr/share/nginx/html/static/

RUN chmod -R 755 /usr/share/nginx/html

    
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]