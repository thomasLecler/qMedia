ltpg={}
do
    function ltpg.fsEnregistrementData(chemin,donnees)
        local fichier=fs.open(chemin,"w")
        local retour=fichier.write(ltpg.enregistrementData(donnees))
        fichier.close()
        return retour
    end
    local function enregistrementDatatraitement(donnees)
        traite="{"
        for i,v in pairs(donnees) do
            traite=traite..i.."="
            if type(v)=="number" then
                traite=traite..v.."\n"
            elseif type(v)=="boolean" then
                if v then
                    traite=traite.."o".."\n"
                else
                    traite=traite.."n".."\n"
                end
            elseif type(v)=="string" then
                if string.exreg(v, "^[0-9]+") then
                    traite=traite.."\""..v.."\"\n"
                elseif string.exreg(v, "^[0-9]+\.[0-9]+") then
                    traite=traite.."\""..v.."\"\n"
                else
                    v=string.gsub(v, "\"", "@guilmets@")
                    traite=traite.."\""..v.."\"\n"
                end
            elseif type(v)=="table" then
                traite=traite..enregistrementDatatraitement(v)
            else
                error("type variable non reconnu")
            end
        end
        traite=traite.."}"
        return traite
    end
    function ltpg.enregistrementData(laTable)
        if not type(laTable)=="table" then
            error("type attendu: table")
        end
        local traite=""
        if laTable.enTete~=nil then
            traite=laTable.enTete.."\n"
            laTable.enTete=nil
        end
        traite=traite..enregistrementDatatraitement(laTable)
        return traite
    end
end

--analyse
do
    function ltpg.fsTraitementData(chemin)
        local fichier=fs.open(chemin,"r")
        local retour=ltpg.traitementData(fichier.readAll())
        fichier.close()
        return retour
    end
    local function traitementDD(chaine)
        local traite={}
        while true do
            if string.sub(chaine, 1,1) == "}" then
                chaine=string.sub(chaine, 2,-1)
                break
            
            --com Chaine
            elseif string.exreg(chaine, "^[0-9a-zA-Z_]+=") then
                local nomVar
                if string.exreg(chaine, "^[0-9]+=") then
                    nomVar=string.sub(chaine,1,1)
                    chaine=string.sub(chaine,3)
                else
                    local _,fin=string.find(chaine, "^[a-zA-Z0-9_]+=")
                    nomVar=string.sub(chaine,1,fin-1)
                    chaine=string.sub(chaine,fin+1)
                end
                
                --numeric
                if string.exreg(chaine, "^[0-9]+\n") then
                    _,fin=string.find(chaine, "^[0-9]+")
                    if string.exreg(nomVar, "^[0-9]+$") then
                        table.insert(traite,tonumber(string.sub(chaine,1,fin)))
                    else
                        traite[nomVar]=tonumber(string.sub(chaine,1,fin))
                    end
                    chaine=string.sub(chaine,fin+2)
                elseif string.exreg(chaine, "^[0-9]+\.[0-9]+\n") then
                    _,fin=string.find(chaine, "^[0-9]+\.[0-9]+")
                    if string.exreg(nomVar, "^[0-9]+$") then
                        table.insert(traite,tonumber(string.sub(chaine,1,fin)))
                    else
                        traite[nomVar]=tonumber(string.sub(chaine,1,fin))
                    end
                    chaine=string.sub(chaine,fin+2)
                
                --booléens
                elseif string.exreg(chaine, "^o\n") then
                    if string.exreg(nomVar, "^[0-9]+$") then
                        table.insert(traite,true)
                    else
                        traite[nomVar]=true
                    end
                    chaine=string.sub(chaine,3)
                elseif string.exreg(chaine, "^n\n") then
                    if string.exreg(nomVar, "^[0-9]+$") then
                        table.insert(traite,false)
                    else
                        traite[nomVar]=false
                    end
                    chaine=string.sub(chaine,3)
                
                --constantes
                elseif string.exreg(chaine, "^[0-9a-zA-Z_]+\n") then
                    _,fin=string.find(chaine, "^[0-9a-zA-Z_]+")
                    if string.exreg(nomVar, "^[0-9]+$") then
                        table.insert(traite,string.sub(chaine,1,fin))
                    else
                        traite[nomVar]=string.sub(chaine,1,fin)
                    end
                    chaine=string.sub(chaine,fin+2)
                
                --chaine caractère
                elseif string.exreg(chaine, "^\"\"\n") then --vide
                    _,fin=string.find(chaine, "^\"\"")
                    if string.exreg(nomVar, "^[0-9]+$") then
                        table.insert(traite,"")
                    else
                        traite[nomVar]=""
                    end
                    chaine=string.sub(chaine,4)
                elseif string.exreg(chaine, "^\"[^\"]*\"\n") then --remplie
                    _,fin=string.find(chaine, "^\"[^\"]*\"")
                    local contenu=string.sub(chaine,2,fin-1)
                    contenu=string.gsub(contenu, "@guilmets@", "\"")
                    if string.exreg(nomVar, "^[0-9]+$") then
                        table.insert(traite,contenu)
                    else
                        traite[nomVar]=contenu
                    end
                    chaine=string.sub(chaine,fin+2)
                
                --table
                elseif string.sub(chaine, 1,1) == "{" then
                    chaine=string.sub(chaine, 2)
                    contenu,chaine=traitementDD(chaine)
                    if string.exreg(nomVar, "^[0-9]+$") then
                        table.insert(traite,contenu)
                    else
                        traite[nomVar]=contenu
                    end
                
                --pas de contenu
                else
                    error("format non valide")
                end
            else
                error('nom de variable non reconnu '..string.sub(chaine,1,10))
                break
            end
        end
        return traite,chaine
    end
    function ltpg.traitementData(laChaine)
        if laChaine=="" then
            error('chaine vide')
            return
        end
        local entete
        if string.exreg(laChaine,"^[^{]*\n{") then
            _,fin=string.find(laChaine, "^[^{]*\n{")
            entete=string.sub(laChaine,1,fin-2)
            laChaine=string.sub(laChaine,fin+1)
        elseif string.sub(laChaine,1,1)=="{" then
            laChaine=string.sub(laChaine,2,-1)
        else
            local fichier=fs.open("debegage.ltpgTraitementData","w")
            fichier.write(laChaine)
            fichier.close()
            error('erreur de syntaxe')
        end
        retout=traitementDD(laChaine)
        if entete then
            retout.enTete=entete
        end
        return retout
    end
end
function string.exreg(texte,expression,depart)
    if string.find(texte,expression,depart) then
        return true
    else
        return false
    end
end
