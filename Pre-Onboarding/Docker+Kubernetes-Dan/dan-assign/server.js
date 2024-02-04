const express = require('express');
const fs = require('fs');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;

app.use(bodyParser.text());

app.post('/message', (req, res) => {
    fs.writeFile('message.txt', req.body, (err) => {
        if (err) {
            res.status(500).ensd('error occured');
            console.log(`error start`);
        } else {
            res.send('saved message');
            console.log(`saved message compeleted.`);
        }
    });
});

app.listen(port, () => {
    console.log(`now sever start http://localhost:${port}`);
});
