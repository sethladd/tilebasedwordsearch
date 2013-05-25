
rm -rf web/out
dart build.dart
dart2js -v --output-type=js --minify -oweb/out/index.html_bootstrap.dart.js web/out/index.html_bootstrap.dart 
dart2js -v --output-type=dart --minify -oweb/out/index.html_bootstrap.dart web/out/index.html_bootstrap.dart 
rm -rf web/out/packages
mkdir -p web/out/packages/browser
cp packages/browser/dart.js web/out/packages/browser/
cd web/out
sed -i -e "s/\.\.\/packages\/browser\/dart.js/packages\/browser\/dart.js/g" index.html
touch .nojekyll
git init
git add .
ls -al
git commit -m "adding files"
git remote add origin https://github.com/financeCoding/tilebasedwordsearch.git
git push -f origin master:gh-pages