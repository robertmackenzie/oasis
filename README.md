Oasis
=====

Oasis is a service to create services via REST.

Use cases:

1. mocking HTTP services in automated tests
1. security testing (e.g. by creating a header splitting service)
1. API gateway (e.g. adding auth or rate limiting on an existing service)

So far the focus is on #1.

API
---

### Services

#### `POST /services`

Create a service.

Body JSON parameters:

* name (string) - A name for your service.
* route (object) - A route for your service. Members are constraints against which requests to the service are matched.
  * method (string) - The HTTP request method. One of "GET", "POST", "PUT", "PATCH", "OPTIONS".
  * path (string) - The request path. For example "/my-test-route".
  * headers (object) - HTTP request headers. For example `{ "Content-Type": "application.json" }`.
  * params (object) - Query parameters or form encoded body parameters. For example `{ "q": "sport" }`.
* handler (object) - A handler for your service. Members specify how to respond to a request matching the route. Some members can be templated based on the
  request params, headers, and body.
  * status (int) - The HTTP response code. For example 200.
  * body (string) - A response body. Can be templated. For example `{{ req.params.name }}`
  * headers (object) - A set of HTTP headers. Can be templated. For example:
    ```json
      {
        "Content-Type": "{{req.headers.accept}}; charset={{req.headers.accept_charset}}"
      }
    ```

Example request:

```http
POST /services HTTP/1.1
Host: localhost
Accept: application/json

{ "name": "my-test-service", "route": { "method": "GET", "path": "/my-test-route" }, "handler": { "status": 200, "body": "this is a response body" } }
```

Example response:

```http
HTTP/1.1 201 CREATED
Content-Type: application/json

{ "name": "my-test-service", "route": { "method": "GET", "path": "/my-test-route" }, "handler": { "status": 200, headers: { "Content-Type": "text/plain" }, "body": "this is a response body" } }
```

#### `GET /services/:name`

Retrieve a service.

Parameters:

* name (string) - The name of the service to retrieve.

Example request:

```http
GET /services/my-test-service HTTP/1.1
Host: localhost
Accept: application/json
```

Example response:

```http
HTTP/1.1 200 OK
Content-Type: application/json

{ "name": "my-test-service", "route": { "method": "GET", "path": "/my-test-route" }, "handler": { "status": 200, "body": "this is a response body" } }
```

#### `GET/POST/PUT/PATCH/OPTIONS /services/:name/api/:path`

Parameters:

* name (string) - The name of the service to interact with.
* path (string) - The route path to trigger from the named service.

Interact with your service. Requests matching the service route will trigger the associated response. Non-matching requests return a 404 response.

Example request:

```http
GET /services/my-test-service/api/my-test-route HTTP/1.1
Host: localhost
Accept: text/plain
```

Example response:

```http
HTTP/1.1 200 OK

this is a response body
```

Contributions
=============

Are welcome. This was written mainly to enjoy some Ruby. A colleague also asked me how I might refactor the domain model in [lashd/mirage](https://github.com/lashd/mirage) and this project is me thinking out loud.
