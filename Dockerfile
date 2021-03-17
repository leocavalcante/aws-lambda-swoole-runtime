FROM public.ecr.aws/lambda/provided as builder

ARG php_version="8.0.3"

RUN yum install -y tar gzip gcc pkgconfig libxml2-devel sqlite-devel make

RUN curl https://www.php.net/distributions/php-${php_version}.tar.gz -o php-src.tar.gz \
    && tar -xzvf php-src.tar.gz

RUN cd php-${php_version} \
    && ./buildconf \
    && ./configure

RUN cd php-${php_version} \
    && make -j2 \
    && make install

FROM public.ecr.aws/lambda/provided as runtime
COPY --from=builder /usr/local/bin/php /var/lang/bin/php
COPY /runtime/ /var/runtime

#ARG swoole_version="4.6.4"
#
#RUN yum clean all
#
## Build essential
#RUN yum install -y gcc
#RUN yum install -y gcc-c++
#RUN yum install -y make
#
#
#RUN yum install -y autoconf
#RUN yum install -y automake
#RUN yum install -y bison
#RUN yum install -y bzip2-devel
#RUN yum install -y git
#RUN yum install -y gzip
#RUN yum install -y libcurl-devel
#RUN yum install -y libxml2-devel
#RUN yum install -y oniguruma-devel
#RUN yum install -y openssl-devel
#RUN yum install -y re2c
#RUN yum install -y tar
#RUN yum install -y unzip
#RUN yum install -y zip
#
## Download the PHP source, compile, and install both PHP and Composer
#RUN curl -sL https://www.php.net/distributions/php-${php_version}.tar.gz | tar -xvz \
# && cd php-src-php-${php_version}
#
#RUN curl -sL https://github.com/swoole/swoole-src/archive/v${swoole_version}.tar.gz | tar -xvz \
# && mv swoole-src-${swoole_version} ext/swoole
#
#RUN ./buildconf --force
#RUN ./configure --prefix=/opt/php/ --with-openssl --with-curl --with-zlib --without-pear --enable-bcmath --without-sqlite3 --without-pdo-sqlite --with-bz2 --enable-mbstring --with-mysqli --with-swoole
#RUN make -j 5
#RUN make install
#RUN /opt/php/bin/php -v
#
#RUN curl -sS https://getcomposer.org/installer | /opt/php/bin/php -- --install-dir=/opt/php/bin/ --filename=composer
#
## Prepare runtime files
## RUN mkdir -p /lambda-php-runtime/bin && \
#    # cp /opt/php/bin/php /lambda-php-runtime/bin/php
#COPY runtime/bootstrap /lambda-php-runtime/
#RUN chmod 0755 /lambda-php-runtime/bootstrap
#
## Install Guzzle, prepare vendor files
#RUN mkdir /lambda-php-vendor && \
#    cd /lambda-php-vendor && \
#    /opt/php/bin/php /opt/php/bin/composer require guzzlehttp/guzzle
#
####### Create runtime image ######

## Layer 3: Vendor
#COPY --from=builder /lambda-php-vendor/vendor /opt/vendor
#
#COPY . /var/task/
#
#CMD [ "index" ]
