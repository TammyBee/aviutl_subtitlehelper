local P = {}

P.name = "TMB_字幕ヘルパー"

P.priority = 10

-- ===========================================================
-- 設定　ここから
-- ===========================================================

-- 字幕生成のトリガーとなるキー（このキーを押した状態で音声ファイルをドロップしないと字幕オブジェクトを一緒に追加しない）
-- 指定できるキー："control", "shift", "alt", "lbutton", "mbutton", "rbutton"
P.triggerkey = "control"

-- 追加されるテキストオブジェクトを指定したフレーム数だけ音声よりも長くする
P.textmargin = 0

-- 音声ファイル名から字幕エイリアスファイル名を抽出する正規表現パターン
-- "([^_]+)_.+"  => (例)「XX_YY.wav」→「XX.exa」
P.aliasfilepattern = "([^_]+)_.+"

-- 字幕エイリアスが入ってるフォルダのパス（※1）
P.aliasdir = "Subtitles"

-- 字幕エイリアスファイルが見つからなかった場合のデフォルトエイリアスファイルのパス（※1）
P.defaultaliaspath = "Subtitles\\default.exa"

-- 音声オブジェクトとテキストオブジェクトをグループ化するか（「true」または「false」）
-- グループ化する際、音声ファイルはcreatesoundexo関数で作成した音声オブジェクトに置き換わります。
P.grouping = true

-- ※1 「aviutl.exe」を含むディレクトリからの相対パス

-- ===========================================================
-- 設定　ここまで
-- ===========================================================

function P.ondragenter(files, state)
    local TMB = require('tmblib')
    for i, v in ipairs(files) do
        if TMB.iswavfile(v) then
            return true
        end
    end
    return false
end

function P.ondragover(files, state)
    return true
end

function P.ondragleave()
end

function P.ondrop(files, state)
    local filepathstobeadded = {}
    
    local TMB = require('tmblib')
    
    -- トリガーキーが設定されている時、トリガーキーが押されていないなら自動生成しない
    if not TMB.isactive(state,P.triggerkey) then
        return false
    end
    
    local groupid = 1
    for i, v in ipairs(files) do
        if TMB.iswavfile(v) then
            -- 音声のファイルパス
            filepathwav = v.orgfilepath or v.filepath
            -- 字幕テキストファイルパス
            local filepathtxt = filepathwav:sub(1, #filepathwav - 3) .. "txt"
            
            local filetxt = io.open(filepathtxt, "rb")
            if filetxt ~= nil then
                -- 字幕用テキストファイルが存在する場合
                local subtitle = filetxt:read("*all")
                filetxt:close()
                
                -- Shift_JISにエンコード
                subtitle = TMB.encodetosjis(subtitle)
                
                -- exoファイルに用いるテキスト形式に変換
                subtitle = GCMZDrops.encodeexotext(subtitle)
                
                -- プロジェクトとファイルの情報を取得
                local projectinfo = GCMZDrops.getexeditfileinfo()
                local fileinfowav = GCMZDrops.getfileinfo(filepathwav)
                
                -- 音声が現在のプロジェクトで何フレーム分あるのかを計算
                local lengthwav = math.ceil((fileinfowav.audio_samples / projectinfo.audio_rate) * projectinfo.rate / projectinfo.scale)
                local lengthtxt = lengthwav + P.textmargin
                
                -- 対応するエイリアスファイルのパスを取得
                local filepathalias = TMB.getfilepathalias(filepathwav,P.aliasdir,P.aliasfilepattern,P.defaultaliaspath)
                
                -- エイリアスファイルから字幕exaファイルを作成
                local exasubtitle = GCMZDrops.inifile(filepathalias)
                exasubtitle:set("vo", "layer", 1)
                exasubtitle:set("vo.0", "text", subtitle)
                if P.grouping then
                    exasubtitle:set("vo", "start", 1)
                    exasubtitle:set("vo", "end", lengthtxt)
                    exasubtitle:set("vo", "overlay",1)
                    exasubtitle:set("vo", "group", groupid)
                else
                    exasubtitle:set("vo", "length", lengthtxt)
                end
                
                -- 字幕オブジェクトと音声オブジェクトをグループ化する場合、
                -- 音声エイリアスファイルから作成した音声exaファイルを結合したexoファイルに置き換える
                if P.grouping then
                    local exosound = TMB.createsoundexo(filepathwav,lengthwav,groupid)
                    
                    local contents = TMB.convertintoexo(tostring(exasubtitle)) .. tostring(exosound)
                    v.filepath = TMB.writetempfile("subtitle" ,".exo" ,contents)
                    
                    groupid = groupid + 1
                else
                    -- 字幕exaファイルの内容を一時ファイル「subtitle.exa」に書き込む
                    local filepathsubtitle = TMB.writetempfile("subtitle" ,".exa" ,tostring(exasubtitle))
                    
                    -- 一時ファイル「subtitle.exa」を追加予定ファイルにする
                    table.insert(filepathstobeadded, filepathsubtitle)
                end
            end
        end
    end
    
    -- 追加予定ファイルを追加する
    for i, v in ipairs(filepathstobeadded) do
        table.insert(files, {filepath=v})
    end
    
    return files, state
end

return P