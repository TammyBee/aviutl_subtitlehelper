local TMB = {}

-- �t�@�C���p�X����t�@�C�������擾
function TMB.getfilename(filepath)
    filename = filepath:match("[^\\]*$")
    local ext = TMB.getextension(filename)
    return filename:sub(1, #filename - #ext - 1)
end

-- �t�@�C���p�X����g���q���擾
function TMB.getextension(filepath)
    if filepath == nil then
        return nil
    end
    return filepath:match("[^.]+$"):lower()
end

-- �t�@�C����wav�`���t�@�C�����ǂ����𔻒�
function TMB.iswavfile(file)
    return (TMB.getextension(file.filepath) == "wav") and (file.mediatype ~= "audio/wav")
end

-- �t�@�C���p�X�ɑ΂���A�G�C���A�X�t�@�C���p�X���擾
-- aliasdir�̃t�H���_���̃G�C���A�X�t�@�C����
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

-- �������Shift_JIS�ɕϊ�
-- �utextsjis.lua�v���Q�l
function TMB.encodetosjis(str)
    local encoding = GCMZDrops.detectencoding(str)
    if (encoding == "utf8") or (encoding == "eucjp") or (encoding == "iso2022jp") then
        -- BOM�̏���
        if encoding == "utf8" and str:sub(1, 3) == "\239\187\191" then
            str = str:sub(4)
        end
        str = GCMZDrops.convertencoding(str, encoding, "sjis")
    end
    return str
end

-- �e�L�X�g�t�@�C���̓��e���擾
function TMB.getcontent(filepath)
    local f = io.open(filepath, "r")
    local text = ""
    if f ~= nil then
        text = f:read("*all")
        f:close()
    end
    return text
end

-- ����������s�����ŕ���
function TMB.splitbyline(str)
    return str:gmatch("([^\n]*)\n?")
end

-- �ꎞ�t�@�C���𐶐����A���e����������
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

-- �����G�C���A�X�t�@�C���̓��e��exo�t�@�C���p�̌`���ɕϊ�
function TMB.convertintoexo(content)
    local exo = ""
    for line in TMB.splitbyline(content) do
        if line:match("%[vo%.(%d+)%]") ~= nil then
            -- �s���u[vo.<����>]�v�̂悤�Ȍ`���̏ꍇ
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

-- �O���[�v������ۂɗp���鉹���I�u�W�F�N�g�̐���
function TMB.createsoundexo(filepath,length,groupid)
    local exosound = GCMZDrops.inistring("")
    exosound:set("1", "layer", 2)
    exosound:set("1", "start", 1)
    exosound:set("1", "end", length)
    exosound:set("1", "overlay",1)
    exosound:set("1", "group", groupid)
    exosound:set("1", "audio", 1)
    exosound:set("1.0", "_name", "�����t�@�C��")
    exosound:set("1.0", "�Đ��ʒu", 0.00)
    exosound:set("1.0", "�Đ����x", 100.0)
    exosound:set("1.0", "���[�v�Đ�", 0)
    exosound:set("1.0", "����t�@�C���ƘA�g", 0)
    exosound:set("1.0", "file", filepath)
    exosound:set("1.1", "_name", "�W���Đ�")
    exosound:set("1.1", "����", 100.0)
    exosound:set("1.1", "���E", 0.0)
    return exosound
end

-- �L�[�̔���
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
