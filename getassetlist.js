var fs = require('fs'),
    dict = JSON.parse(fs.readFileSync('urls.json', 'utf8')),
    keys = [],
    values = [];

for (var i in dict) {
    keys.push(i);
    values.push(dict[i])
}

console.log(JSON.stringify(keys));
console.log(JSON.stringify(values));