<?php declare(strict_types=1);

use Laminas\Diactoros\Response\TextResponse;
use Psr\Http\Message\{RequestInterface, ResponseInterface};

function main(RequestInterface $request): ResponseInterface
{
    $payload = json_decode($request, true, 512, JSON_THROW_ON_ERROR);
    return new TextResponse(sprintf("Hello, %s!", $payload['name'] ?? 'World'));
}
