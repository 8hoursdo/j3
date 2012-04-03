J3_JS = ./j3/js/j3.js
J3_JS_MIN = ./j3/js/j3.min.js

J3_CSS = ./j3/css/j3.css
J3_CSS_MIN = ./j3/css/j3.min.css
J3_LESS = ./less/j3.less


#
# BUILD J3 DIRECTORY
# lessc & uglifyjs are required
#
build: css js images

css:
	mkdir -p j3/img
	mkdir -p j3/css
	lessc ${J3_LESS} > ${J3_CSS}
	lessc --compress ${J3_LESS} > ${J3_CSS_MIN}

js:
	mkdir -p j3/js
	cake build
	uglifyjs -nc ${J3_JS} > ${J3_JS_MIN}

images:
	cp img/* j3/img/
  

