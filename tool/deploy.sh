#!/usr/bin/env bash

# Example 
# ~/tilebasedwordsearch$ ./tool/deploy https://github.com/financeCoding/tilebasedwordsearch.git

if [ "$1" == "" ]; then
	echo "./tool/deploy <git repo>";
	exit -1;
fi

rm -rf web/out
if [ $? != 0 ]; then
	echo "FAILED: rm -rf web/out";
	exit -1;
fi

dart build.dart
if [ $? != 0 ]; then
	echo "FAILED: dart build.dart";
	exit -1;
fi

dart2js -v --output-type=js --minify -oweb/out/index.html_bootstrap.dart.js web/out/index.html_bootstrap.dart 
if [ $? != 0 ]; then
	echo "FAILED: dart2js -v --output-type=js";
	exit -1;
fi

dart2js -v --output-type=dart --minify -oweb/out/index.html_bootstrap.dart web/out/index.html_bootstrap.dart 
if [ $? != 0 ]; then
	echo "FAILED: dart2js -v --output-type=dart";
	exit -1;
fi

rm -rf web/out/packages
if [ $? != 0 ]; then
	echo "FAILED: rm -rf web/out/packages";
	exit -1;
fi

mkdir -p web/out/packages/browser
if [ $? != 0 ]; then
	echo "FAILED: mkdir -p web/out/packages/browser";
	exit -1;
fi

cp packages/browser/dart.js web/out/packages/browser/
if [ $? != 0 ]; then
	echo "FAILED: cp packages/browser/dart.js ";
	exit -1;
fi

cd web/out
sed -i -e "s/\.\.\/packages\/browser\/dart.js/packages\/browser\/dart.js/g" index.html
if [ $? != 0 ]; then
	echo "FAILED: sed -i -e ";
	exit -1;
fi

touch .nojekyll
if [ $? != 0 ]; then
	echo "FAILED: touch .nojekyll";
	exit -1;
fi

git init
if [ $? != 0 ]; then
	echo "FAILED: git init";
	exit -1;
fi

git add .
if [ $? != 0 ]; then
	echo "FAILED: git add";
	exit -1;
fi

git commit -m "adding files"
if [ $? != 0 ]; then
	echo "FAILED: git commit";
	exit -1;
fi

git remote add origin $1
if [ $? != 0 ]; then
	echo "FAILED: git remote";
	exit -1;
fi

git push -f origin master:gh-pages
if [ $? != 0 ]; then
	echo "FAILED: git push";
	exit -1;
fi
