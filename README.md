tilebasedwordsearch
===================

## Development

* Dart SDK from dartlang.org
* PostgreSQL server. On a Mac? Use http://postgresapp.com/
* Load db/schema.sql into your dev postgres server

## Setup deployment

* Install the heroku development tools: https://toolbelt.heroku.com/
* heroku create [NAME]
* heroku config:add BUILDPACK_URL=https://github.com/igrigorik/heroku-buildpack-dart.git
* heroku labs:enable user-env-compile
* heroku config:set DART_SDK_URL=<.tar.gz archive URL>
* heroku addons:add heroku-postgresql
  * Look for "Attached as HEROKU_POSTGRESQL_OLIVE_URL" or similar
* heroku pg:promote HEROKU_POSTGRESQL_OLIVE_URL
* heroku pg:psql < db/schema.sql

## Deploying


