local TMB = {}

-- ファイルパスからファイル名を取得
function TMB.getfilename(filepath)
    filename = filepath:match("[^\\]*$")
    local ext = TMB.getextension(filename)
    return filename:sub(1, #filename - #ext - 1)
end

-- ファイルパスから拡張子を取得
function TMB.getextension(filepath)
    if filepath == nil then
        return nil
    end
    return filepath:match("[^.]+$"):lower()
end

-- ファイルがwav形式ファイルかどうかを判定
function TMB.iswavfile(file)
    return (TMB.getextension(file.filepath) == "wav") and (file.mediatype ~= "audio/wav")
end

-- ファイルパスに対する、エイリアスファイルパスを取得
-- aliasdirのフォルダ内のエイリアスファイル名
function TMB.getfilepathalias(filepath,aliasdir,aliasfilepattern,defaultaliaspath)
    local filename = TMB.getfilename(filepath)
    local filepathalias = aliasdir
    local filenamealias = string.match(filename,aliasfilepattern)
    
    if filenamealias ~= nil then
        filepathalias = aliasdir .. "\\" .. filenamealias .. ".exa"
        local f = io.open(filepathalias, "r")
        if f ~= nil then
            f:close()
        else
            filepathalias = defaultaliaspath
        end
    else
        filepathalias = defaultaliaspath
    end
    
    return filepathalias
end

-- 文字列をShift_JISに変換
-- 「textsjis.lua」を参考
function TMB.encodetosjis(str)
    local encoding = GCMZDrops.detectencoding(str)
    if (encoding == "utf8") or (encoding == "eucjp") or (encoding == "iso2022jp") then
        -- BOMの除去
        if encoding == "utf8" and str:sub(1, 3) == "\239\187\191" then
            str = str:sub(4)
        end
        str = GCMZDrops.convertencoding(str, encoding, "sjis")
    end
    return str
end

-- テキストファイルの内容を取得
function TMB.getcontent(filepath)
    local f = io.open(filepath, "r")
    local text = ""
    if f ~= nil then
        text = f:read("*all")
        f:close()
    end
    return text
end

-- 文字列を改行文字で分割
function TMB.splitbyline(str)
    return str:gmatch("([^\n]*)\n?")
end

-- 一時ファイルを生成し、内容を書き込む
function TMB.writetempfile(filename,ext,contents)
    local filepathtemp = GCMZDrops.createtempfile(filename,ext)
    filetemp, err = io.open(filepathtemp, "wb")
    if filetemp == nil then
        error(err)
    end
    filetemp:write(contents)
    filetemp:close()
    
    return filepathtemp
end

-- 字幕エイリアスファイルの内容をexoファイル用の形式に変換
function TMB.convertintoexo(content)
    local exo = ""
    for line in TMB.splitbyline(content) do
        if line:match("%[vo%.(%d+)%]") ~= nil then
            -- 行が「[vo.<数字>]」のような形式の場合
            local section = tonumber(line:match("%[vo%.(%d+)%]"))
            exo = exo .. "[0." .. section .. "]\n"
        elseif line:match("%[vo%]") ~= nil then
            exo = exo .. "[0]\n"
        else
            exo = exo .. line .. "\n"
        end
    end
    return exo
end

-- グループ化する際に用いる音声オブジェクトの生成
function TMB.createsoundexo(filepath,length,groupid)
    local exosound = GCMZDrops.inistring("")
    exosound:set("1", "layer", 2)
    exosound:set("1", "start", 1)
    exosound:set("1", "end", length)
    exosound:set("1", "overlay",1)
    exosound:set("1", "group", groupid)
    exosound:set("1", "audio", 1)
    exosound:set("1.0", "_name", "音声ファイル")
    exosound:set("1.0", "再生位置", 0.00)
    exosound:set("1.0", "再生速度", 100.0)
    exosound:set("1.0", "ループ再生", 0)
    exosound:set("1.0", "動画ファイルと連携", 0)
    exosound:set("1.0", "file", filepath)
    exosound:set("1.1", "_name", "標準再生")
    exosound:set("1.1", "音量", 100.0)
    exosound:set("1.1", "左右", 0.0)
    return exosound
end

-- キーの判定
function TMB.isactive(state,triggerkey)
    if triggerkey == "control" and not state.control then
        return false
    end
    if triggerkey == "shift" and not state.shift then
        return false
    end
    if triggerkey == "alt" and not state.alt then
        return false
    end
    if triggerkey == "lbutton" and not state.lbutton then
        return false
    end
    if triggerkey == "mbutton" and not state.mbutton then
        return false
    end
    if triggerkey == "rbutton" and not state.rbutton then
        return false
    end
    return true
end

return TMB
