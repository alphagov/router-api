# Router API

This provides an API for updating the routes used by the [router](https://github.com/alphagov/router/).

## Technical documentation

A Ruby on Rails application that manages the router database.  Routes are
stored in a mongo database using [Mongoid](http://mongoid.org/) as an ORM.

### Dependencies

- [mongoDB](http://www.mongodb.org/)
- [alphagov/router](https://github.com/alphagov/router/) - to reload routes
  (optional in dev mode)

When running in development mode, this will ignore connection errors when
triggering a reload of the router

### Running the application

`bundle exec rails s`

The app will then be available at http://localhost:3000/ (the port can be
changed by passing a `-p` option to the command)

### Running the test suite

`bundle exec rake`

## API endpoints

### Routes

Information about the route data structure can be found in the [router repository](https://github.com/alphagov/router#routes).

##### Getting details of a route:

``` sh
curl "http://router-api.example.com/routes?incoming_path=/foo"
```

This will return the corresponding route in JSON format.

##### Creating/updating a route:

The following will create/update a route entry:

``` sh
curl http://router-api.example.com/routes -X PUT \
    -H 'Content-type: application/json' \
    -d '{"route": {"incoming_path": "/foo", "route_type": "exact", "handler": "backend", "backend_id": "foo"}}'
```

This will return details of the updated route in JSON format.  If the route doesn't already exist, it will be created and a 201 status code returned.  The `backend_id` must reference a backend that exists (see below).

On error a 400 status code will be returned, and the JSON response will include an "errors" key with more details.

##### Deleting a route:

``` sh
curl "http://router-api.example.com/routes?incoming_path=/foo" -X DELETE
```

This will delete the corresponding route.  If no route matches the JSON request, a 404 status code will be returned.

##### Committing changes:

``` sh
curl http://router-api.example.com/routes/commit -X POST
```

This will trigger a router reload and cause any changes to the route to take effect.

### Backends

Backends represent an application that the router can route requests to.  They are referenced by entries in the routes collection. Information about the backend data structure can be found in the [router repository](https://github.com/alphagov/router#backends).

##### Getting details for a backend:

``` sh
curl http://router-api.example.com/backends/foo
```

Will return the backend details in JSON format.

##### Creating/updating a backend:

``` sh
curl http://router-api.example.com/backends/foo -X PUT \
    -H 'Content-type: application/json' \
    -d '{"backend": {"backend_url": "http://foo.example.com/"}}'
```

This will update the `backend_url` for the backend with id 'foo'.  The backend entry will be created if it doesn't already exist (and a 201 status code returned).  The response will be a JSON representation of the updated backend.

On validation error a 400 status code will be returned, and the resulting JSON document will have an "errors" key with more details.

##### Deleting a backend:

``` sh
curl http://router-api.example.com/backends/foo -X DELETE
```

This will delete the backend with id 'foo'.  This will only be allowed if the backend has no associated routes.  A 400 status code will be returned if this is the case.

## Licence

[MIT License](LICENSE)
