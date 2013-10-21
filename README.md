Router API
==========

This provides an API for updating the routes used by the [router](https://github.com/alphagov/router/).


API endpoints
-------------

### Routes

**Getting details of a route:**

    curl http://router-api.example.com/routes?incoming_path=/foo&route_type=exact

This will return the corresponding route in JSON format.

**Creating/updating a route:**

The following will create/update a route entry:

    curl http://router-api.example.com/routes -v -X PUT \
    -H 'Content-type: application/json' \
    -d '{"route": {"incoming_path": "/foo", "route_type": "exact", "handler": "backend", "backend_id": "foo"}}'

This will return details of the updated route in JSON format.  If the route doesn't already exist, it will be created and a 201 status code returned.  The `backend_id` must reference a backend that exists (see below).

On error a 400 status code will be returned, and the JSON response will include an "errors" key with more details.

**Deleting a route:**

    curl http://router-api.example.com/routes -v -X DELETE \
    -H 'Content-type: application/json' \
    -d '{"route": {"incoming_path": "/foo", "route_type": "exact"}}`

This will delete the corresponding route.  If no route matches the JSON request, a 400 status codce will be returned.

### Backends

Backends represent an application that the router can route requests to.  They are referenced by entries in the routes collection.

**Getting details for a backend:**

    curl http://router-api.example.com/backends/foo

Will return the backend details in JSON format.

**Creating/updating a backend:**

    curl http://router-api.example.com/backends/foo -v -X PUT \
    -H 'Content-type: application/json' \
    -d '{"backend": {"backend_url": "http://foo.example.com/"}}'

This will update the `backend_url` for the backend with id 'foo'.  The backend entry will be created if it doesn't already exist (and a 201 status code returned).  The response will be a JSON representation of the updated backend.

On validation error a 400 status code will be returned, and the resulting JSON document will have an "errors" key with more details.

**Deleting a backend:**

    curl http://router-api.example.com/backends/foo -v -X DELETE

This will delete the backend with id 'foo'.  This will only be allowed if the backend has no associated routes.  A 400 status code will be returned if this is the case.
