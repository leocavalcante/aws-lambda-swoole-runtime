<?php declare(strict_types=1);

use Runtime\Context;

function main(Context $context): string
{
    $greet = $context->payload['greet'] ?? 'World';
    return "Hello, $greet!";
}
