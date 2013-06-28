tilebasedwordsearch
===================

Game is hosted on heroku:
http://tbwfg.herokuapp.com/


## How to create a Heroku server

Here are my notes from creating a staging server of my own.
The order of the actions might be off,
since I ran commands in multiple windows.

*FIRST:* Create a branch with the changes you want to stage.
In that branch, do everything that the `tool/deploy_heroku.sh` script does.

*THEN:* Perform these commands to create a staging server.
For `SOME-NAME-####` substitute in the app name the first step gives you.
For example, my app name is morning-taiga-2034,
and my staging server's at http://morning-taiga-2034.herokuapp.com/.

    (layout) > heroku create --remote staging
    Creating SOME-NAME-####... done, stack is cedar
    http://SOME-NAME-####.herokuapp.com/ | git@heroku.com:SOME-NAME-####.git
    Git remote staging added
    
    (layout) > heroku config:add BUILDPACK_URL=https://github.com/igrigorik/heroku-buildpack-dart.git --app SOME-NAME-####
    
    (layout) > git remote add heroku git@heroku.com:SOME-NAME-####.git
    
    (layout) > heroku addons:add heroku-postgresql --app SOME-NAME-####
    
    (layout) > heroku config --app SOME-NAME-#### | grep HEROKU_POSTGRESQL
    HEROKU_POSTGRESQL_WHITE_URL: postgres://shkqbmwfhosolt:oARVTGc_utR86jB512v3UQAEQ3@ec2-107-21-112-215.compute-1.amazonaws.com:5432/dd8tveiv732o62
    
    (layout) > heroku pg:promote HEROKU_POSTGRESQL_WHITE_URL --app SOME-NAME-####
    Promoting HEROKU_POSTGRESQL_WHITE_URL to DATABASE_URL... done
    
    (layout) > git push staging heroku_push:master
