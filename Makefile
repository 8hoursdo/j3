J3_JS = ./lib/js/j3.js
J3_JS_MIN = ./lib/js/j3.min.js

J3_CSS = ./lib/css/j3.css
J3_CSS_MIN = ./lib/css/j3.min.css
J3_LESS = ./less/j3.less


#
# BUILD J3 DIRECTORY
# lessc & uglifyjs are required
#
build: css js images

css:
	mkdir -p lib/img
	mkdir -p lib/css
	lessc ${J3_LESS} > ${J3_CSS}
	lessc --compress ${J3_LESS} > ${J3_CSS_MIN}

js:
	mkdir -p lib/js
	cake build
	uglifyjs -nc ${J3_JS} > ${J3_JS_MIN}

images:
	cp img/* lib/img/
  

