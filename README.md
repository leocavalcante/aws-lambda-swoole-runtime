# Swoole Runtime for AWS Lambda

## Getting started

### Make you lambda function

#### Dockerfile
```Dockerfile
FROM leocavalcante/aws-lambda-swoole-runtime
# The WORKDIR is already /var/task
COPY composer.* .
RUN composer install -o --prefer-dist --no-dev
# This split avoids a call to composer install on every change to a source-code file
COPY . .
```

#### index.php
```php
<?php declare(strict_types=1);

use Swoole\Coroutine;

function main(array $context): string
{
    $channel = new Coroutine\Channel(2);
    $context['greet'] ??= 'World';

    Coroutine::create(static function() use ($context, $channel): void {
        Coroutine::sleep(1);
        $channel->push("{$context['greet']}!");
    });

    Coroutine::create(static function() use ($channel): void {
        Coroutine::sleep(0.5);
        $channel->push('Hello');
    });

    return implode(', ', [$channel->pop(), $channel->pop()]);
}
```
The `main(array $context)` function here isn't optional, the runtime will make a call to a `main` function passing a `array` representing the context.

The return should be something scalar or a `JsonSerializable` object.

### Deploying your container-based function

#### Login to your ECR
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 884320951759.dkr.ecr.us-east-1.amazonaws.com
```
Don't forget to change region `us-east-1` and the AWS Account ID (`884320951759`).

> It assumes that you already have the [AWS Command Line Interface (`aws`)](https://aws.amazon.com/cli/) and it is [already configured (`aws configure`)](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).

⚠️ Also make sure that you will be using a Private ECR on the same Account that your Lambda function.

#### Build and push the Lambda image
```bash
docker build -t 884320951759.dkr.ecr.us-east-1.amazonaws.com/lambda-swoole-runtime-example .
docker push 884320951759.dkr.ecr.us-east-1.amazonaws.com/lambda-swoole-runtime-example
```

#### Your Lambda image is ready
You can use the Web UI to create a function based on a **Container image**.
![Create function screenshot](create-function-screenshot.gif)

