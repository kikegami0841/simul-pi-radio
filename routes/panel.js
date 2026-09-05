const ejs = require('ejs');
const fs = require('fs');
const express = require('express');
const app = express.Router();
const path = require('path');

const { exec } = require('child_process')

let def_station='nhk-tokyo-fm';
let def_volume='60';
let def_prev_station=def_station;
exec('/opt/simulradio/bin/vol.sh '+def_volume, (err, stdout, stderr) => { } );
exec('/opt/simulradio/bin/ch_station_conf.sh dmy 0; /opt/simulradio/bin/ch_station_conf.sh '+def_station+' 1', (err, stdout, stderr) => { } );

app.get('/', function(req, res, next){
    res.render('./panel.ejs',{
	def_station:def_station,
	def_volume:def_volume
	});
}); 

app.get('/sshairline.png', function(req, res, next) {
    console.log(__dirname);
  let filepath = path.join(__dirname, '../public/images', 'sshairline.png');
    console.log(filepath);
  res.sendFile(filepath);
});
app.get('/pwricong48.png', function(req, res, next) {
     console.log(__dirname);
   let filepath = path.join(__dirname, '../public/images', 'pwricong48.png');
     console.log(filepath);
});

app.post('/post', function(req, res, next){
	switch(req.body.id) {
	case 'Station':
	      	switch(req.body.value) {
		case 'nhk-tokyo-fm': //NHK FM(tokyo)
		case 'rn1': //RADIO NIKKEI 1
		case 'chokuradi': //チョクラジ
		case 'iidafm': //IIDA-FM
		case 'radioniseko': //Radio NISEKO
			res.end();
			exec('/opt/simulradio/bin/ch_station_conf.sh ' +def_prev_station+' 0; /opt/simulradio/bin/ch_station_conf.sh '+req.body.value+' 1', (err, stdout, stderr) => { } );
			def_prev_station=req.body.value;
			break;
		default:
			break;
		}
		def_station = req.body.value;
		break;
	case 'Volume':
                res.end();
                exec('/opt/simulradio/bin/vol.sh '+req.body.value, (err, stdout, stderr) => { } );
		def_volume = req.body.value;
		break;
	default:
		break;
	}
	console.log(req.body);

}); 

app.get('/', function(req, res, next){
    res.render('./panel.ejs',{
	def_station:def_station,
	def_volume:def_volume
	});
}); 

module.exports=app;

