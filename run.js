let fs = require('fs'),
    Asset = require('./asset.js'),
    beautify = require('./beautify.js');

/* add custom assets to this */
let assets = [];
let errors = [];

/* load static assets from urls.json */
let staticAssets = JSON.parse(fs.readFileSync('urls.json', 'utf8'));
for(let path in staticAssets) {
    if(!staticAssets.hasOwnProperty(path)){
        continue;
    }
    let url = staticAssets[path];
    assets.push(new Asset(url, path));
}

let downloadedAssetCnt = 0;
/* download, beautify and save assets */
for(let asset of assets) {
    asset.download().then($asset => {
        try {
            $asset = beautify($asset);
            $asset.save().then(onDownloadAsset);
        } catch (e) {
            errors.push({
                error: e,
                asset: asset
            });
        }
    }, ($asset, error) => {
        errors.push({
            error: error,
            asset: $asset
        });
        console.log('err');
        onDownloadAsset();
    });
}

function onDownloadAsset() {
    // all assets have been downloaded
    if(++downloadedAssetCnt >= assets.length) {
        if(errors.length) {
            fs.appendFileSync('error.log', JSON.stringify(errors));
            process.exit(1);
        } else {
            process.exit(0);
        }
    }
}