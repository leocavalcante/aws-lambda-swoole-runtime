FROM public.ecr.aws/lambda/provided as builder
WORKDIR /var

RUN yum group install -y "Development Tools" && \
    yum install -y re2c libxml2-devel openssl-devel

ARG php_version="8.0.3"
ARG swoole_version="4.6.4"

RUN git clone --branch php-${php_version} --depth 1 https://github.com/php/php-src.git
RUN cd php-src && ./buildconf --force
RUN cd php-src && ./configure --prefix=/var/lang --without-sqlite3 --without-pdo-sqlite --with-openssl
RUN cd php-src && make -j6 && make install

RUN git clone --branch v${swoole_version} --depth 1 https://github.com/swoole/swoole-src.git
RUN cd swoole-src && phpize
RUN cd swoole-src && ./configure
RUN cd swoole-src && make -j6 && make install

COPY ./php.ini /var/lang/lib/
COPY ./runtime/ /var/runtime/

RUN curl -sS https://getcomposer.org/installer | /var/lang/bin/php -- --install-dir=/var/lang/bin/ --filename=composer
RUN cd /var/runtime/ && composer install --prefer-dist --no-dev -o

RUN chmod 0755 /var/runtime/bootstrap

# Runtime
FROM public.ecr.aws/lambda/provided as runtime
COPY --from=builder /var/lang/ /var/lang/
COPY --from=builder /var/runtime/ /var/runtime/
COPY ./task/ /var/task/
CMD [ "index" ]
