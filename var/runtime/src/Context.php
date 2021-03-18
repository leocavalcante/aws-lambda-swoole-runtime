<?php declare(strict_types=1);

namespace Runtime;

final class Context
{
    public function __construct (
        public string $requestId,
        public array $payload,
    ) {}
}
