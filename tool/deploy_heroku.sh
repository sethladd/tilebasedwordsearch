# If you dont have heroku remote run the following command
# git remote add heroku git@heroku.com:tbwfg.git
git branch -D heroku_push
git checkout -b heroku_push
rm -rf web/out/
sed -i '' -e 's/out//g' .gitignore 
pub install
dart build.dart 
cd web/out/
#dart2js --verbose --minify -oindex.html_bootstrap.dart.js index.html_bootstrap.dart
dart2js --verbose -oindex.html_bootstrap.dart.js index.html_bootstrap.dart
cd ../../
git add .gitignore
git add .
git commit -m "adding deployable files"
git push --verbose --force heroku heroku_push:master
git checkout master