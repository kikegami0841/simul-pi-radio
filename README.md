# Simulradio (サイマルラジオ受信機)

２つの受信エンジンを使ったラジオ受信機の実装例です  
| ツール | 対応サービス |
| ---- | ---- |
| radish-play.sh | [NHKラジオ らじる★らじる](https://www.nhk.or.jp/radio/) / [radiko](http://radiko.jp/) / [ListenRadio](http://listenradio.jp/) |
| rec_wss.py | [JCBA](https://www.jcbasimul.com/), [FM++](https://fmplapla.com/) |

- この2つで、日本中のラジオ局のサイマル放送を網羅している(と思います)  
これらの好きなものを node.js を使ってWebServerを構築して、スマホやPCを使って選曲、音量調整できる物
を作ってみました。raspberry pi zero 2 W を使って、DAC+パワーアンプでスピーカーから鳴らします
システムはユーザー領域で動いています

## raspberry pi zero 2W 使うことにしたのか
- ラジオのサイマル放送は古いスマホ＋アンプでもいいが、
自分の使い方は、外出しない休日は 1日の大半をラジオを鳴らしっぱなしています
- こんな使い方だったら raspberry pi zero系で十分かと判断しました
Raspberry Pi OSの起動が遅いのでのちにZero 2 Wに変更
- それと、raspberry piをそれ専用に贅沢に使いたいというのがありました
- キーボードもモニタも繋がずに、スマホから操作できればと始めました(家族でも使えるように)

## ハードウェア
- raspberry pi zero 2 W (raspberry pi zero Wでも動く) x 1
- I2S接続対応DAC (なんでも良い) x 1
- アンプ(Digital Ampなど) x 1 (最近はDACボードにパワーアンプが入っているものもある)
- ステレオスピーカー x 1

## 準備
- [Raspi Imager](https://www.raspberrypi.com/software/) を使ってRapiOSのイメージ[Version 13 trixie, GUIツールの無いLite(32bit)]
を作ってください  
使い方は [[こちら]](https://www.google.com/search?q=raspi+imager+%E4%BD%BF%E3%81%84%E6%96%B9+2.0.0&client=firefox-b-d&hs=rBAB&sca_esv=1995570cdb9dd810&sxsrf=APpeQnvEhQj8esr4lrDz2SI8eYy_O3T10g%3A1787465420200&ei=zI6KaqDyC9Hg2roPoN_koAI&ved=0ahUKEwigiK3Li7aWAxVRsFYBHaAvGSQQ4dUDCBA&uact=5&oq=raspi+imager+%E4%BD%BF%E3%81%84%E6%96%B9+2.0.0&gs_lp=Egxnd3Mtd2l6LXNlcnAiHHJhc3BpIGltYWdlciDkvb_jgYTmlrkgMi4wLjAyCBAAGIAEGKIEMgUQABjvBTIFEAAY7wUyBRAAGO8FMgUQABjvBUi2IlC0BljSHHABeACQAQCYAe4BoAH9CaoBBTAuNi4yuAEDyAEA-AEBmAIIoALNCcICChAAGEcY1gQYsAPCAgQQABgewgIFECEYoAHCAgQQIRgVmAMAiAYBkAYKkgcFMS41LjKgB8kSsgcFMC41LjK4B8EJwgcHMC4xLjYuMcgHI4AIAQ&sclient=gws-wiz-serp)
などを見ながらすすめてください
- 起動時にWi-Fiに接続できるようRaspi Imagerで設定してください
- 起動時にSSHでログインできるようRaspi Imagerで設定してください
- Raspi Imageで設定したHostnameは、Network設定に依っては http://[hostname].local/panel でアクセス可能(ダイナミックDNS)  
 そうでなければ、Wi-Fi環境のDHCPで ip address を固定化してアクセスする http://固定アドレス/panel でアクセス
- ターミナル コマンドプロンプト や wsl Terminal などを用意
- ファイル転送 WinSCP などファイル転送ツールを用意
- PCからSSH（Secure Shell）を使ってRaspberry Pi Zero 2 Wにログインし、CUI（コマンドライン）に操作ができる事

## インストールするもの
- SSHで Raspberry Oi Zero 2 W にログインした後、最初にする仕事は、git wgetのインストールです
以下のコマンドを実行してください
```
sudo apt update 
sudo apt upgrade -y 
sudo apt install git -y  

wget https://raw.githubusercontent.com/kikegami0841/simul-pi-radio/refs/heads/main/installer.sh -P .
```

- スクリプト言語で動いている為、インストールするパッケージ、修正する設定ファイルが多い為、
install.sh にまとめているので、確認してほしい
- 大きいものとしては、  
 Audio ffmpeg, pipewire, pluseaudio, wget, curl, python3  
 Webサーバー node.js

## ディレクトリ構成
```
└─simulradio
    ├─bin/                                        # nodejsの設定ファイル  ＊
    ├─CmdScript/                                  #シェルクリプト類
    │  ├─dotconfig_pipewire/                     #~/.config/pipewire/以下の設定  
    │  ├─dotconfig_systemd_user/                 #~/.config/systemd/user/以下の設定 
    │  ├─dotconfig_wireplumber/                  #~/.config/wireplumber/以下の設定
    │  └─etc_NetworkManager_system-connections/  #/etc/NetworkManager/system-connections/以下の設定
    ├─node_modules/                               # nodejsの設定ファイル ＊
    ├─public/                                     # html ico ファイル
    │  ├─images/                                 # html image
    │  └─stylesheets/                            # html css ファイル ＊
    ├─routes/                                     # nodejs jsファイル
    └─views/                                      # nodejs ejsファイル
```

## インストール
- 「インストールするもの」で取得した install.sh を実行します
```
sh ./install.sh > log.txt 2>&1
```

## 選曲
- スマホやPCから http://[RaspiImagerでつけたhostname].local/panel/ または http://固定アドレス/panel でアクセスする
- ラジオボタンで選曲、スライダーで音量調節できます
- 起動してすぐに決めたラジオ局が鳴ります。後述

## 音量
- 音量は ALSA を使ってるため 0..100 で設定します
- 起動してすぐに決めた音量で鳴ります。後述

## できない事
- Radiko Premiumの会員登録をしていない(アカウントが無い)場合はエリアフリーにならないですが  
自分には必要が無い為、アカウント/パスワードを入力できるようなインターフェースを用意していません  
(改造すれば対応できます) 詳しくは radish-play.sh の情報を参照してください  
- 古いOSバージョン(Legacy)はAudioの構成が違い過ぎるので動かないと思います

## 終了手順
- rootfs ROM化 設定をしているので、電源を落とすだけ

## カスタマイズ
- カスタマイズ前後で、rootfs ROM化のdisable/enable を行ってください詳しくは、installler.shファイルの最後の10行程度を参考に
- 当初 5局だけWebインターフェースに入れてます  
~/src/simulradio/CmdScript/に、対応するリスト全てのバッチを用意しています  
自分の地域に合った放送局に入れ替えてみてください
- 入れ替える所は2か所  
	~/SimulRadio/views/panel.ejs
		Tableの要素(Station id)の追加/編集
	~/SimulRadio/routes/panel.js
		Case文の条件(Station id)の追加/編集
- 起動時の選曲、音量の編集
 ~/SimulRadio/routes/panel.js : def_station, def_volume
- 全部のラジオ局を選曲するインターフェースは複雑なので非対応です


