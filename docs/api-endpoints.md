# API endpoints

## Routes

Information about the route data structure can be found in the [router repository](https://github.com/alphagov/router#routes).

Router watches its database for changes and will pick up new/changed/deleted routes automatically within a few seconds.

### Getting details of a route:

``` sh
curl "http://router-api.example.com/routes?incoming_path=/foo"
```

This will return the corresponding route in JSON format.

### Creating/updating a route:

The following will create/update a route entry:

``` sh
curl http://router-api.example.com/routes -X PUT \
    -H 'Content-type: application/json' \
    -d '{"route": {"incoming_path": "/foo", "route_type": "exact", "handler": "backend", "backend_id": "foo"}}'
```

This will return details of the updated route in JSON format.  If the route doesn't already exist, it will be created and a 201 status code returned.  The `backend_id` must reference a backend that exists (see below).

On error a 400 status code will be returned, and the JSON response will include an "errors" key with more details.

### Deleting a route:

``` sh
curl "http://router-api.example.com/routes?incoming_path=/foo" -X DELETE
```

This will delete the corresponding route.  If no route matches the JSON request, a 404 status code will be returned.

## Backends

Backends represent an application that the router can route requests to.  They are referenced by entries in the routes collection. Information about the backend data structure can be found in the [router repository](https://github.com/alphagov/router#backends).

### Getting details for a backend:

``` sh
curl http://router-api.example.com/backends/foo
```

Will return the backend details in JSON format.

### Creating/updating a backend:

``` sh
curl http://router-api.example.com/backends/foo -X PUT \
    -H 'Content-type: application/json' \
    -d '{"backend": {"backend_url": "http://foo.example.com/"}}'
```

This will update the `backend_url` for the backend with id 'foo'.  The backend entry will be created if it doesn't already exist (and a 201 status code returned).  The response will be a JSON representation of the updated backend.

On validation error a 400 status code will be returned, and the resulting JSON document will have an "errors" key with more details.

### Deleting a backend:

``` sh
curl http://router-api.example.com/backends/foo -X DELETE
```

This will delete the backend with id 'foo'.  This will only be allowed if the backend has no associated routes.  A 400 status code will be returned if this is the case.
