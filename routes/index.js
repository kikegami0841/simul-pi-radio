const ejs = require('ejs');
var express = require('express');
var router = express.Router();

const { exec } = require('child_process')

router.get('/', function(req, res, next){
    res.render('./index.ejs',{
        });
});

/* GET home page. */
/*
router.get('/', function(req, res, next) {
  res.render('index', { title: 'サイマルラジオ' });
});
*/

module.exports = router;
