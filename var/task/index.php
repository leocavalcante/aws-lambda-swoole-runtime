<?php declare(strict_types=1);

function main(array $context): string
{
    $context['greet'] ??= 'World';
    return "Hello, {$context['greet']}!";
}
