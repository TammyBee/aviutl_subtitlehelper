# 字幕ヘルパー

字幕ヘルパーは、AviUtl拡張編集Pluginのタイムライン上にVOICEROIDで出力した音声ファイルを  
ドラッグ&ドロップした時に、自動で音声ファイルと一緒に出力された字幕が書かれている  
テキストファイルのテキストオブジェクトを配置するごちゃまぜドロップス用のスクリプトです。  
テキストオブジェクトは音声（テキスト）ファイル名に応じたエイリアスをもとに生成をします。 
  
エイリアスとは、オブジェクトの設定（例：座標、色、フォントなど）をエイリアスファイル（exa形式）として保存し、  
そのエイリアスファイルを読み込むことで同じ設定のオブジェクトを生成することができる機能です。 
  
# 使い方

## 前準備

本機能を利用する際、以下の前準備が必要となります。
- VOICEROIDで音声ファイルを出力する時、一緒にテキストファイルも出力するようにする。
- 自動生成する字幕のテキストオブジェクトのもととなるエイリアスを用意する。

### VOICEROIDで音声ファイルと一緒にテキストファイルも出力する方法

#### VOICEROID+の場合

1. メニューから「設定(S)」 → 「音声出力設定(S)...」の順に選択します。
2. 「テキストファイルを一緒に保存する」にチェックを入れます。
3. 「OK」ボタンを押します。

#### VOICEROID2の場合 

1. メニューから「ツール(T)」 → 「オプション(O)...」の順に選択します。
2. オプションウィンドウ上の「音声保存」タブを選択します。
3. 「テキストファイルを音声ファイルと一緒に保存する」にチェックを入れます。
4. 「OK」ボタンを押します。

### エイリアスファイルを作成する方法

1. 拡張編集プラグインのタイムライン上に、テキストオブジェクトを配置します。
2. そのテキストオブジェクトに対し、パラメータの変更やフィルタ効果の追加などの設定をします。
3. タイムライン上のテキストオブジェクトを右クリックします。
4. 表示されたメニューのうち、「エイリアスの作成」を選択します。
5. エイリアス名は適当な名前（ここでは「sample」）、格納フォルダは「Subtitles」を入力します。
6. 「OK」ボタンを押します。

## 基本的な流れ

1. VOICEROIDで音声ファイルと字幕用のテキストファイルを保存（出力）します。  
  このとき、保存するファイル名は「<利用したいエイリアス名>_」から始まるようにしてください。  
  （例）エイリアスファイル「sample.exa」の設定を利用した字幕オブジェクトを生成したい時、  
  　　　「sample_001.wav」「sample_test.wav」「sample_0_0_1.wav」のようなファイル名で保存してください。  
2. Ctrlキーを押しながら、保存した音声ファイルを拡張編集プラグインのタイムライン上にドラッグ&ドロップします。
3. 音声オブジェクトと音声ファイル名に対応するエイリアスから作成したテキストオブジェクトがタイムライン上に配置されます。
  対応するエイリアスファイルが見つからない場合、「Plugins/Subtitles/default.exa」を用います。
  

# インストール

## 使用上の注意

このソフトウェアには何の保証もついていません。  
例え、このスクリプトを利用したことで問題が起こった場合でも、製作者は一切の責任を負いません。

## 必要条件

字幕ヘルパーの動作には以下のツール、プラグインが必要です。
- [AviUtl](http://spring-fragrance.mints.ne.jp/aviutl/) version1.00
- [拡張編集Plugin](http://spring-fragrance.mints.ne.jp/aviutl/) version0.92
- [ごちゃまぜドロップス](https://github.com/oov/aviutl_gcmzdrops) v0.3.8

## インストール方法

1. ダウンロードした「SubtitleHelper_X_Y_Z.zip」を解凍します。
2. 「Subtitles」フォルダと「GCMZDrops」フォルダを「exedit.auf」ファイルと同じ場所に配置してください。  
  このとき、「GCMZDrops」フォルダは上書きされます。
  

# FAQ

## 自動生成する字幕のテキストオブジェクトの長さを音声ファイルより長くしたい

ファイル「GCMZDrops/subtitle.lua」の16行目の「P.textmargin」の値を変更してください。

## 音声ファイル名に対応するエイリアスファイルを探すフォルダを変更したい

ファイル「GCMZDrops/subtitle.lua」の23行目の「P.aliasdir」の値を変更してください。

## 自動で字幕を生成するツールって他にもあるような

AviUtlに音声ファイルをドラッグ&ドロップすると、ファイル名に応じたエイリアスを用いた  
字幕のテキストオブジェクトも一緒に配置するツールが見つからなかったので作りました。

## 字幕のテキストオブジェクトが追加されない

以下の可能性があるのでお確かめください。
- 音声ファイルをドラッグ&ドロップする時、Ctrlキーを押していない。
- 音声ファイルをドラッグ&ドロップした場所に余白が足りていない。
- 音声ファイル名に対応するエイリアスファイルとデフォルトのエイリアスファイルの両方が無い。

## ごちゃまぜドロップスの代わりにPsdToolKitを利用しても大丈夫？

調査中です。おそらく利用できるはずです。  
  
  

# クレジット

## ごちゃまぜドロップス 

https://github.com/oov/aviutl_gcmzdrops

The MIT License (MIT)

Copyright (c) 2016 oov

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.