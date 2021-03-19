FROM leocavalcante/aws-lambda-swoole-runtime
# The WORKDIR is already /var/task
COPY composer.* .
RUN composer install -o --prefer-dist --no-dev
# This split avoids a call to composer install on every change to a source-code file
COPY . .
