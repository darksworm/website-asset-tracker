"use strict";
var beautify_js = require('js-beautify').js_beautify,
    beautify_css = require('js-beautify').css,
    beautify_html = require('js-beautify').html,
    fs = require('fs'),
    process = require('process');

var files = process.argv.slice(2), i, errors = [];

for (i in files) {
    let data,
        beautify,
        file = files[i];

    try {
        data = fs.readFileSync(file, 'utf-8');
    } catch (err) {
        errors.push(file + "::" + err.stack);
        continue;
    }

    if (file.endsWith('.css')) {
        beautify = beautify_css;
    } else if (file.endsWith('.js')) {
        beautify = beautify_js;
    } else if (file.endsWith('.html')) {
        beautify = beautify_html;
    }

    if (beautify) {
        try {
            fs.writeFileSync(file, beautify(data, {indent_size: 4}));
        } catch (err) {
            errors.push(file + "::" + err.stack);
        }
    }
}

if(errors.length){
    var date = new Date().toISOString()
        .replace(/T/, ' ')
        .replace(/\..+/, '');
    var text = '';

    for(i in errors) {
        text += date + ' :: ' + errors[i] + '\n';
    }

    fs.appendFile('error.log', text.slice(0, -1), function(){
        process.exit(1);
    });
} else {
    process.exit(0);
}