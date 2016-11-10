"use strict";
var beautify_js = require('js-beautify').js_beautify,
    beautify_css = require('js-beautify').css,
    beautify_html = require('js-beautify').html,
    fs = require('fs'),
    process = require('process');

var files = process.argv.slice(2), i;

for (i in files) {
    let file = files[i];

    fs.readFile(file, 'utf8', function (err, data) {
        if (err) {
            throw err;
        }

        let beautify;

        if (file.endsWith('.css')) {
            beautify = beautify_css;
        } else if (file.endsWith('.js')) {
            beautify = beautify_js;
        } else if (file.endsWith('.html')) {
            beautify = beautify_html;
        }

        if (beautify) {
            fs.writeFile(file, beautify(data, {indent_size: 4}), function (err) {
                if (err) {
                    throw err;
                }
            })
        }
    });
}