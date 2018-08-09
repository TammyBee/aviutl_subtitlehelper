local P = {}

P.name = "TMB_�����w���p�["

P.priority = 10

-- ===========================================================
-- �ݒ�@��������
-- ===========================================================

-- ���������̃g���K�[�ƂȂ�L�[�i���̃L�[����������Ԃŉ����t�@�C�����h���b�v���Ȃ��Ǝ����I�u�W�F�N�g���ꏏ�ɒǉ����Ȃ��j
-- �w��ł���L�[�F"control", "shift", "alt", "lbutton", "mbutton", "rbutton"
P.triggerkey = "control"

-- �ǉ������e�L�X�g�I�u�W�F�N�g���w�肵���t���[������������������������
P.textmargin = 0

-- �����t�@�C�������玚���G�C���A�X�t�@�C�����𒊏o���鐳�K�\���p�^�[��
-- "([^_]+)_.+"  => (��)�uXX_YY.wav�v���uXX.exa�v
P.aliasfilepattern = "([^_]+)_.+"

-- �����G�C���A�X�������Ă�t�H���_�̃p�X�i��1�j
P.aliasdir = "Subtitles"

-- �����G�C���A�X�t�@�C����������Ȃ������ꍇ�̃f�t�H���g�G�C���A�X�t�@�C���̃p�X�i��1�j
P.defaultaliaspath = "Subtitles\\default.exa"

-- �����I�u�W�F�N�g�ƃe�L�X�g�I�u�W�F�N�g���O���[�v�����邩�i�utrue�v�܂��́ufalse�v�j
-- �O���[�v������ہA�����t�@�C����createsoundexo�֐��ō쐬���������I�u�W�F�N�g�ɒu�������܂��B
P.grouping = true

-- ��1 �uaviutl.exe�v���܂ރf�B���N�g������̑��΃p�X

-- ===========================================================
-- �ݒ�@�����܂�
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
    
    -- �g���K�[�L�[���ݒ肳��Ă��鎞�A�g���K�[�L�[��������Ă��Ȃ��Ȃ玩���������Ȃ�
    if not TMB.isactive(state,P.triggerkey) then
        return false
    end
    
    local groupid = 1
    for i, v in ipairs(files) do
        if TMB.iswavfile(v) then
            -- �����̃t�@�C���p�X
            filepathwav = v.orgfilepath or v.filepath
            -- �����e�L�X�g�t�@�C���p�X
            local filepathtxt = filepathwav:sub(1, #filepathwav - 3) .. "txt"
            
            local filetxt = io.open(filepathtxt, "rb")
            if filetxt ~= nil then
                -- �����p�e�L�X�g�t�@�C�������݂���ꍇ
                local subtitle = filetxt:read("*all")
                filetxt:close()
                
                -- Shift_JIS�ɃG���R�[�h
                subtitle = TMB.encodetosjis(subtitle)
                
                -- exo�t�@�C���ɗp����e�L�X�g�`���ɕϊ�
                subtitle = GCMZDrops.encodeexotext(subtitle)
                
                -- �v���W�F�N�g�ƃt�@�C���̏����擾
                local projectinfo = GCMZDrops.getexeditfileinfo()
                local fileinfowav = GCMZDrops.getfileinfo(filepathwav)
                
                -- ���������݂̃v���W�F�N�g�ŉ��t���[��������̂����v�Z
                local lengthwav = math.ceil((fileinfowav.audio_samples / projectinfo.audio_rate) * projectinfo.rate / projectinfo.scale)
                local lengthtxt = lengthwav + P.textmargin
                
                -- �Ή�����G�C���A�X�t�@�C���̃p�X���擾
                local filepathalias = TMB.getfilepathalias(filepathwav,P.aliasdir,P.aliasfilepattern,P.defaultaliaspath)
                
                -- �G�C���A�X�t�@�C�����玚��exa�t�@�C�����쐬
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
                
                -- �����I�u�W�F�N�g�Ɖ����I�u�W�F�N�g���O���[�v������ꍇ�A
                -- �����G�C���A�X�t�@�C������쐬��������exa�t�@�C������������exo�t�@�C���ɒu��������
                if P.grouping then
                    local exosound = TMB.createsoundexo(filepathwav,lengthwav,groupid)
                    
                    local contents = TMB.convertintoexo(tostring(exasubtitle)) .. tostring(exosound)
                    v.filepath = TMB.writetempfile("subtitle" ,".exo" ,contents)
                    
                    groupid = groupid + 1
                else
                    -- ����exa�t�@�C���̓��e���ꎞ�t�@�C���usubtitle.exa�v�ɏ�������
                    local filepathsubtitle = TMB.writetempfile("subtitle" ,".exa" ,tostring(exasubtitle))
                    
                    -- �ꎞ�t�@�C���usubtitle.exa�v��ǉ��\��t�@�C���ɂ���
                    table.insert(filepathstobeadded, filepathsubtitle)
                end
            end
        end
    end
    
    -- �ǉ��\��t�@�C����ǉ�����
    for i, v in ipairs(filepathstobeadded) do
        table.insert(files, {filepath=v})
    end
    
    return files, state
end

return P