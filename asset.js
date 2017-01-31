"use strict";

let request = require('request');
let mkdirp = require('mkdirp');
let fs = require('fs');

class Asset {
    constructor(url, path) {
        this.url = url;
        this.filename = path.split("/").pop();
        this.path = 'assets/' + path.substring(0, path.indexOf(this.filename) - 1);
        this.contents = '';
        this.beautified = false;
    }

    getUrl() {
        return this.url;
    }

    download() {
        return new Promise((resolve, reject) => {
            this.onBeforeDownload().then(() => {
                request(this.getUrl(), (error, response, body) => {
                    if (!error && response.statusCode == 200) {
                        this.contents = body;
                        this.onDownload(error, response, body);
                        resolve(this);
                    } else {
                        this.onError(error, response, body);
                        reject(this, error, response, body);
                    }
                });
            });
        });
    }

    /* STUB */
    onBeforeDownload() {
        return new Promise((resolve, reject) => {
           resolve();
        });
    }

    /* STUB */
    onDownload(error, response, body) {
        console.log("DOWNLOADED:", this.path + '/' + this.filename);
    }

    /* STUB */
    onError(error, response, body) {
        console.error("ERROR:", this.path + '/' + this.filename, error);
    }

    save() {
        return new Promise((resolve, reject) => {
            console.log("SAVING", this.filename, "TO", this.path, "MINIFIED:", this.beautified);
            mkdirp.sync(__dirname + '/' + this.path);
            fs.writeFile(__dirname + '/' + this.path + '/' + this.filename, this.contents, () => {
                resolve();
            });
        });
    }
}

module.exports = Asset;