<?php declare(strict_types=1);

namespace Runtime;

use JsonSerializable;
use Swoole\Coroutine\Http\Client;
use Throwable;

final class API
{
    private const REQUEST_ID_HEADER = 'lambda-runtime-aws-request-id';

    private Client $client;
    private string $requestId;

    public function __construct(string $url)
    {
        $host = parse_url($url, PHP_URL_HOST);
        $port = parse_url($url, PHP_URL_PORT);

        $this->client = new Client($host, $port);
        $this->client->setHeaders(['Content-type' => 'application/json']);
    }

    public function next(): array
    {
        $this->client->get('/2018-06-01/runtime/invocation/next');
        $this->requestId = $this->client->headers[self::REQUEST_ID_HEADER];

        $context = json_decode($this->client->body, true, 512, JSON_THROW_ON_ERROR);

        if (!is_array($context)) {
            $context = ['payload' => $context];
        }

        $context['request_id'] = $this->requestId;
        return $context;
    }

    public function response(JsonSerializable|string|array|int|float $data): void
    {
        $this->client->post("/2018-06-01/runtime/invocation/{$this->requestId}/response", json_encode($data, JSON_THROW_ON_ERROR));
    }

    public function error(Throwable $err): void
    {
        $this->client->post("/2018-06-01/runtime/invocation/{$this->requestId}/error", json_encode([
            'errorMessage' => $err->getMessage(),
            'errorType' => $err::class,
        ], JSON_THROW_ON_ERROR));
    }
}
