FROM phpswoole/swoole:4.6-php8.0-alpine
COPY /var /var
RUN cd /var/runtime && composer install --prefer-dist --no-dev -o
WORKDIR /var/task
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "index" ]
