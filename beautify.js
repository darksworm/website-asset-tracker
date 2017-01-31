let beautify_js = require('js-beautify').js_beautify,
    beautify_css = require('js-beautify').css,
    beautify_html = require('js-beautify').html;

module.exports = (asset) => {
    let beautify;
    if (asset.filename.endsWith('.css')) {
        beautify = beautify_css;
    } else if (asset.filename.endsWith('.js')) {
        beautify = beautify_js;
    } else if (asset.filename.endsWith('.html')) {
        beautify = beautify_html;
    }

    asset.contents = beautify(asset.contents, {indent_size: 4});
    asset.beautified = true;
    return asset;
};