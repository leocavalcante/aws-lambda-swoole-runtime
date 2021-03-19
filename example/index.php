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
