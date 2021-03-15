FROM public.ecr.aws/lambda/provided as builder

ARG php_version="8.0.3"
ARG swoole_version="4.6.4"

RUN yum clean all && \
    yum install -y autoconf \
                bison \
                bzip2-devel \
                gcc \
                gcc-c++ \
                git \
                gzip \
                libcurl-devel \
                libxml2-devel \
                make \
                oniguruma-devel \
                openssl-devel \
                re2c \
                tar \
                unzip \
                zip

# Download the PHP source, compile, and install both PHP and Composer
RUN curl -sL https://github.com/php/php-src/archive/php-${php_version}.tar.gz | tar -xvz

RUN cd php-src-php-${php_version} && \
    curl -sL https://github.com/swoole/swoole-src/archive/v${swoole_version}.tar.gz | tar -xvz && \
    mv swoole-src-${swoole_version} ext/swoole && \
    ./buildconf --force && \
    ./configure --prefix=/opt/php/ --with-openssl --with-curl --with-zlib --without-pear --enable-bcmath --without-sqlite3 --without-pdo-sqlite --with-bz2 --enable-mbstring --with-mysqli --with-swoole && \
    make -j 5 && \
    make install && \
    /opt/php/bin/php -v && \
    curl -sS https://getcomposer.org/installer | /opt/php/bin/php -- --install-dir=/opt/php/bin/ --filename=composer

# Prepare runtime files
# RUN mkdir -p /lambda-php-runtime/bin && \
    # cp /opt/php/bin/php /lambda-php-runtime/bin/php
COPY runtime/bootstrap /lambda-php-runtime/
RUN chmod 0755 /lambda-php-runtime/bootstrap

# Install Guzzle, prepare vendor files
RUN mkdir /lambda-php-vendor && \
    cd /lambda-php-vendor && \
    /opt/php/bin/php /opt/php/bin/composer require guzzlehttp/guzzle

###### Create runtime image ######
FROM public.ecr.aws/lambda/provided as runtime
# Layer 1: PHP Binaries
COPY --from=builder /opt/php /var/lang
# Layer 2: Runtime Interface Client
COPY --from=builder /lambda-php-runtime /var/runtime
# Layer 3: Vendor
COPY --from=builder /lambda-php-vendor/vendor /opt/vendor

COPY . /var/task/

CMD [ "index" ]
