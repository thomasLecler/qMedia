Champs={}
function string.insertChaine(chaineDepart,chaineInseree,position)
    if position==1 then
        return chaineInseree..chaineDepart
    elseif (string.len(chaineDepart)+1)==position then
        return chaineDepart..chaineInseree
    else
        local debut=string.sub(chaineDepart,1,position-1)
        local fin=string.sub(chaineDepart,position,-1)
        return debut..chaineInseree..fin
    end
end

function string.retire(chaineDepart,positionChar,nbChar)
    if nbChar==nil then
        nbChar=1
    end
    if positionChar==1 then
        return string.sub(chaineDepart,1+nbChar,-1)
    elseif (string.len(chaineDepart)+1)==positionChar then
        return string.sub(chaineDepart,1,-(1+nbChar))
    else
        local debut=string.sub(chaineDepart,1,positionChar-1)
        local fin=string.sub(chaineDepart,positionChar+nbChar,-1)
        return debut..fin
    end
end

function Champs.ChampCoche(nom,posX,posY,uecran)
    local Champ={}
    local Interne={}
    local ecran
    
    Interne.nom=nom
    Interne.posX=posX
    Interne.posY=posY
    if type(uecran)=="table" then
        ecran=uecran
    else
        ecran=term.current()
    end
    
    Champ.etat=false
    Interne.description=""
    Interne.visible=false
    Interne.actif=true
    Interne.focus=false
    Interne.quandModifie=false
    Interne.fonctionFini=false
    Interne.couleurFond=colors.white
    
    function Champ.couleurFond(choix)
        if choix==nil then
            return Interne.couleurFond
        else
            if not type(choix)=="numeric" then
                error("Le choix doit être un nombre")
            end
            Interne.couleurFond=choix
            Champ.redessine()
            return Champ
        end
    end
    function Champ.perteFocus(event)
        if not Interne.focus then
            return Champ
        end
        if not event then
            event="manuel"
        end
        Interne.focus=false
        os.queueEvent("finFocusChamp",Interne.nom,event)
        Champ.redessine()
        if type(Interne.fonctionFini)=="function" then
            Interne.fonctionFini(event,Champ)
        end
        return Champ
    end    
    function Champ.quandFini(fonction)
        Interne.fonctionFini=fonction
        return Champ
    end
    function Champ.quandModifie(fonction)
        Interne.quandModifie=fonction
        return Champ
    end
    function Champ.focus()
        if Interne.actif==false then
            return Champ
        end
        Interne.visible=true
        Interne.focus=true
        Champ.redessine()
        while true do
            event,para1,para2=os.pullEvent()
            if event=="key" and (para1==200 or para1==208) then
                Champ.change()
            elseif event=="key" and para1==15 then
                Champ.perteFocus("tab")
                break
            elseif event=="key" and para1==28 then
                Champ.perteFocus("entre")
                break
            elseif event=="char" and (para1=="o" or para1=="y") then
                Champ.etat(true)
            elseif event=="char" and (para1=="n") then
                Champ.etat(false)
            end
        end
        return Champ
    end
    function Champ.description(texte)
        if texte==nil then
            return Interne.description
        else
            if not type(texte)=="string" then
                error("Le texte doit être une string")
            end
            Interne.description=texte
            Champ.redessine()
            return Champ
        end
    end
    function Champ.visible(choix)
        if choix==nil then
            return Interne.visible
        else
            if not type(choix)=="boolean" then
                error("La visibilite doit être un boolean")
            end
            Interne.visible=choix
            if choix then
                Champ.redessine()
            end
            return Champ
        end
    end
    function Champ.statut(choix)
        if choix==nil then
            return Interne.actif
        else
            if not type(choix)=="boolean" then
                error("Le paramètre doit être un boolean")
            end
            Interne.actif=choix
            Champ.redessine()
            return Champ
        end
    end    
    function Champ.position(posX,posY)
        if posX==nil or posY==nil then
            return Interne.posX,Interne.posY
        end
        if type(posX)=="numeric" and type(posY)=="numeric" then
            Interne.posX=posX
            Interne.posY=posY
            Champ.redessine()
        else
            error("posx et posy doivent être des nombres")
        end
        return Champ
    end
    function Champ.redessine()
        if Interne.visible==false then
            return Champ
        end
        if Interne.description~="" then
            ecran.setCursorPos(Interne.posX+1,Interne.posY)
            ecran.setTextColor(colors.gray)
            ecran.setBackgroundColor(Interne.couleurFond)
            ecran.write(Interne.description)
        end
        ecran.setCursorPos(Interne.posX,Interne.posY)
        if Interne.actif then
            ecran.setBackgroundColor(colors.lightGray)
            if Interne.etat then
                ecran.setTextColor(colors.lime)
                ecran.write("V")
            else
                ecran.setTextColor(colors.red)
                ecran.write("X")
            end
            if Interne.focus then
                ecran.setTextColor(colors.gray)
                ecran.setCursorPos(Interne.posX,Interne.posY)
                ecran.setCursorBlink(true)
            else
                ecran.setCursorBlink(false)
            end
        else
            ecran.setCursorBlink(false)
            ecran.setBackgroundColor(colors.gray)
            if Interne.etat then
                ecran.setTextColor(colors.lime)
                ecran.write("V")
            else
                ecran.setTextColor(colors.red)
                ecran.write("X")
            end
        end
    end
    function Champ.change()
        if Interne.etat then
            Interne.etat=false
        else
            Interne.etat=true
        end
        if type(Interne.quandModifie)=="function" then
            Interne.quandModifie(Champ)
        end
        Champ.redessine()
        return Champ
    end
    function Champ.etat(choix)
        if choix==nil then
            return Interne.etat
        else
            if not type(choix)=="boolean" then
                error("Le texte doit être un boolean")
            end
            Interne.etat=choix
            Champ.redessine()
            return Champ
        end
    end
    return Champ
end
function Champs.ChampBouton(nom,posX,posY,largeur,uecran)
    local Champ={}
    local Interne={}
    local ecran
    
    Interne.nom=nom
    Interne.posX=posX
    Interne.posY=posY
    Interne.largeur=largeur
    if type(uecran)=="table" then
        ecran=uecran
    else
        ecran=term.current()
    end
    
    Interne.texte=""
    Interne.visible=false
    Interne.actif=true
    Interne.quandClique=false
    Interne.focus=false
    Interne.fonctionFini=false
    
    function Champ.texte(texte)
        if texte==nil then
            return Interne.texte
        else
            if not type(texte)=="string" then
                error("Le texte doit être une string")
            end
            if string.len(texte)>Interne.largeur then
                return false,"le texte est plus large que la largeur"
            end
            Interne.texte=texte
            return Champ
        end
    end
    function Champ.perteFocus(event)
        if not event then
            event="manuel"
        end
        os.queueEvent("finFocusChamp",Interne.nom,event)
        Interne.focus=false
        Champ.redessine()
        if type(Interne.fonctionFini)=="function" then
            Interne.fonctionFini(event,Champ)
        end
        return Champ
    end    
    function Champ.quandFini(fonction)
        if fonction==nil then
            return Interne.fonctionFini
        else
            if not type(fonction)=="function" then
                error("Le paramètre doit être une fonction")
            end
            Interne.fonctionFini=fonction
            return Champ
        end
    end
    function Champ.focus()
        if Interne.actif==false then
            return Champ
        end
        Interne.visible=true
        Interne.focus=true
        Champ.redessine()
        while true do
            event,para1,para2=os.pullEvent()
            if event=="key" and para1==15 then
                Champ.perteFocus("tab")
                break
            elseif event=="key" and para1==28 then
                if type(Interne.quandClique)=="function" then
                    Interne.quandClique()
                end
                os.queueEvent("activationBoutonChamp",Interne.nom)
                Champ.perteFocus("entre")
                break
            end
        end
        return Champ
    end
    function Champ.visible(choix)
        if choix==nil then
            return Interne.visible
        else
            if not type(choix)=="boolean" then
                error("La visibilite doit être un boolean")
            end
            Interne.visible=choix
            if choix then
                Champ.redessine()
            end
            return Champ
        end
    end
    function Champ.statut(choix)
        if choix==nil then
            return Interne.actif
        else
            if not type(choix)=="boolean" then
                error("Le paramètre doit être un boolean")
            end
            Interne.actif=choix
            Champ.redessine()
            return Champ
        end
    end    
    function Champ.position(posX,posY)
        if posX==nil or posY==nil then
            return Interne.posX,Interne.posY
        end
        if type(posX)=="numeric" and type(posY)=="numeric" then
            Interne.posX=posX
            Interne.posY=posY
            Champ.redessine()
        else
            error("posx et posy doivent être des nombres")
        end
        return Champ
    end
    function Champ.quandValide(fonction)
        if fonction==nil then
            return Interne.quandClique
        else
            if not type(fonction)=="function" then
                error("Le paramètre doit être une fonction")
            end
            Interne.quandClique=fonction
            return Champ
        end
    end
    function Champ.redessine()
        if not Interne.visible then
            return Champ
        end
        ecran.setCursorPos(Interne.posX,Interne.posY)
        if Interne.actif then
            ecran.setBackgroundColor(colors.lightGray)
            ecran.write(string.rep(" ",Interne.largeur))
            ecran.setCursorPos(Interne.posX+(Interne.largeur-string.len(Interne.texte))/2,Interne.posY)
            ecran.setTextColor(colors.gray)
            ecran.write(Interne.texte)
            if Interne.focus then
                ecran.setCursorPos(Interne.posX+(Interne.largeur/2),Interne.posY)
                ecran.setCursorBlink(true)
            else
                ecran.setCursorBlink(false)
                ecran.setCursorPos(Interne.posX+Interne.largeur,Interne.posY)
            end
        else
            ecran.setBackgroundColor(colors.gray)
            ecran.setTextColor(colors.lightGray)
            ecran.write(string.rep(" ",Interne.largeur))
            ecran.setCursorPos(Interne.posX+(Interne.largeur-string.len(Interne.texte))/2,Interne.posY)
            ecran.write(Interne.texte)
            ecran.setCursorPos(Interne.posX+Interne.largeur,Interne.posY)
        end
        return Champ
    end
    return Champ
end
function Champs.ChampTexte(nom,posX,posY,largeur,uecran)
    local Champ={}
    local Interne={}
    local ecran
    
    Interne.nom=nom
    Interne.posX=posX
    Interne.posY=posY
    Interne.largeur=largeur    
    if type(uecran)=="table" then
        ecran=uecran
    else
        ecran=term.current()
    end
    
    Interne.positionCurseur=1
    Interne.actif=true
    Interne.visible=false
    Interne.focus=false
    Interne.vexreg=""
    Interne.valeur=""
    Interne.charCache=false
    Interne.autoComplection={}
    Interne.quandModifie=false
    Interne.fonctionFini=false
    Interne.valeurInfo=""
    Interne.valide=true
    Interne.doitEtreValide=false
    
    function Champ.charCache(choix)
        if choix==nil then
            return Interne.charCache
        else
            Interne.charCache=choix
            return Champ
        end
    end
    function Champ.valide(choix)
        if choix==nil then
            if Interne.vexreg=="" then
                return true
            else
                return Interne.valide
            end
        else
            if not type(choix)=="boolean" then
                error("le paramètre doit être de type boolean")
            end
            Interne.doitEtreValide=choix
            return Champ
        end
    end
    function Champ.autoComplection(choix)
        if choix then
            Interne.autoComplection=choix
            return Champ
        else
            return Interne.autoComplection
        end
    end
    function Champ.valueInfo(valeur)
        if valeur~=nil then
            if not type(valeur)=="string" then
                error("le paramètre doit être de type string")
            end
            Interne.valeurInfo=valeur
            Champ.redessine()
            return Champ
        else
            return Interne.valeurInfo
        end
    end
    function Champ.position(posX,posY)
        if posX==nil or posY==nil then
            return Interne.posX,Interne.posY
        end
        if type(posX)=="numeric" and type(posY)=="numeric" then
            Interne.posX=posX
            Interne.posY=posY
            Champ.redessine()
        else
            error("posx et posy doivent être des nombres")
        end
        return Champ
    end
    function Champ.exreg(exreg)
        if exreg==nil then
            return Interne.vexreg
        end
        Interne.vexreg=exreg
        Champ.redessine()
        return Champ
    end
    function Champ.statut(leStatu)
        if leStatu~=nil then
            if not type(statu)=="boolean" then
                error("une valeur booleenne est attendue")
            end
            Interne.actif=statu
            Champ.redessine()
            return Champ
        else
            return Interne.actif
        end
    end
    function Champ.visible(visibilite)
        if visibilite~=nil then
            if not type(visibilite)=="boolean" then
                error("une valeur booleenne est attendue")
            end
            Interne.visible=visibilite
            Champ.redessine()
            return Champ
        else
            return Interne.visible
        end
    end
    function Champ.valeur(valeur)
        if valeur==nil then
            return Interne.valeur
        else
            if string.len(valeur)>Interne.largeur then
                error("la valeur communiquée est trop longue pour ce champ")
                return false
            end
            Interne.valeur=valeur
            Interne.positionCurseur=string.len(valeur)+1
            Champ.redessine()
            return Champ
        end
    end
    function Champ.redessine()
        if not Interne.visible then
            return Champ
        end
        ecran.setCursorPos(Interne.posX,Interne.posY)
        if not Interne.actif then
            if Interne.vexreg~="" and Interne.valide==false then
                ecran.setTextColor(colors.red)
            else
                ecran.setTextColor(colors.black)
            end
            ecran.setCursorBlink(false)
            ecran.setBackgroundColor(colors.gray)
            ecran.write(string.rep(" ",Interne.largeur))
            ecran.setCursorPos(Interne.posX,Interne.posY)
            if not Interne.charCache then
                ecran.write(Interne.valeur)
            else
                ecran.write(string.rep(Interne.charCache,string.len(Interne.valeur)))
            end
            ecran.setCursorPos(Interne.posX+Interne.largeur,Interne.posY)
        else
            ecran.setBackgroundColor(colors.lightGray)
            if Interne.valeur=="" then
                ecran.setTextColor(colors.gray)
                ecran.write(string.rep(" ",Interne.largeur))
                ecran.setCursorPos(Interne.posX,Interne.posY)
                ecran.write(Interne.valeurInfo)
                if Interne.focus then
                    ecran.setCursorPos(Interne.posX+string.len(Interne.valeurInfo),Interne.posY)
                    ecran.setCursorBlink(true)
                else
                    ecran.setCursorPos(Interne.posX+Interne.largeur,Interne.posY)
                    ecran.setCursorBlink(false)
                end
            else
                if Interne.vexreg~="" then
                    if Interne.valide==false then
                        ecran.setTextColor(colors.red)
                    else
                        ecran.setTextColor(colors.gray)
                    end
                else
                    ecran.setTextColor(colors.black)
                end
                ecran.write(string.rep(" ",Interne.largeur))
                ecran.setCursorPos(Interne.posX,Interne.posY)
                if not Interne.charCache then
                    ecran.write(Interne.valeur)
                else
                    ecran.write(string.rep(Interne.charCache,string.len(Interne.valeur)))
                end
                if Interne.focus then
                    ecran.setCursorPos(Interne.posX+Interne.positionCurseur-1,Interne.posY)
                    ecran.setCursorBlink(true)
                else
                    ecran.setCursorPos(Interne.posX+Interne.largeur,Interne.posY)
                    ecran.setCursorBlink(false)
                end
                
            end
        end
        return Champ
    end
    function Champ.perteFocus(event)
        if not event then
            event="manuel"
        end
        os.queueEvent("finFocusChamp",Interne.nom,event)
        Interne.focus=false
        Champ.redessine()
        if type(Interne.fonctionFini)=="function" then
            Interne.fonctionFini(event,Champ)
        end
        return Champ
    end
    
    function Champ.quandFini(fonction)
        if fonction==nil then
            return Interne.fonctionFini
        end
        Interne.fonctionFini=fonction
        return Champ
    end
    function Champ.quandModifie(fonction)
        if fonction==nil then
            return Interne.quandModifie
        end
        Interne.quandModifie=fonction
        return Champ
    end
    
    local function modifie()
        if Interne.vexreg~="" then
            if string.find(Interne.valeur,Interne.vexreg) then
                Interne.valide=true
            else
                Interne.valide=false
            end
        end
        if type(Interne.quandModifie)=="function" then
            Interne.quandModifie(Champ)
        end
    end
    function Champ.focus()
        if Interne.statut==false then
            return Objet
        end
        Interne.visible=true
        parallel.waitForAny(function()
            Interne.focus=true
            Champ.redessine()
            
            local listeChars={}
            local enControle
            while true do
                event,para1,para2=os.pullEvent()
                if Interne.positionCurseur<=Interne.largeur then
                    if event=="char" then
                        table.insert(listeChars,Interne.positionCurseur,string.len(para1))
                        Interne.valeur=string.insertChaine(Interne.valeur,para1,Interne.positionCurseur)
                        Interne.positionCurseur=Interne.positionCurseur+1
                        modifie()
                        Champ.redessine()
                    end
                end
                if event=="key" and para1==14 then
                    if Interne.positionCurseur>1 then
                        if enControle then
                            Interne.valeur=string.sub(Interne.valeur,Interne.positionCurseur,-1)
                            Interne.positionCurseur=1
                            enControle=false
                        else
                            Interne.positionCurseur=Interne.positionCurseur-1
                            Interne.valeur=string.retire(Interne.valeur,Interne.positionCurseur,listeChars[Interne.positionCurseur])
                            table.remove(listeChars,Interne.positionCurseur)
                        end
                        modifie()
                        Champ.redessine()
                    end
                elseif event=="key" and para1==211 then
                    if enControle then
                        Interne.valeur=string.sub(Interne.valeur,1,Interne.positionCurseur-1)
                    else
                        Interne.valeur=string.retire(Interne.valeur,Interne.positionCurseur,listeChars[Interne.positionCurseur])
                    end
                    modifie()
                    Champ.redessine()
                elseif event=="key" and para1==203 then
                    if Interne.positionCurseur>1 then
                        Interne.positionCurseur=Interne.positionCurseur-1
                        Champ.redessine()
                    end
                elseif event=="key" and para1==205 then
                    if Interne.positionCurseur<=string.len(Interne.valeur) then
                        Interne.positionCurseur=Interne.positionCurseur+1
                        Champ.redessine()
                    end
                elseif event=="key" and para1==207 then
                    Interne.positionCurseur=string.len(Interne.valeur)+1
                    Champ.redessine()
                elseif event=="key" and para1==199 then
                    Interne.positionCurseur=1
                    Champ.redessine()
                elseif event=="key" and para1==28 then
                    Champ.perteFocus("entre")
                    Champ.redessine()
                    if Interne.valide==true then
                        break
                    end
                elseif event=="key" and para1==15 then
                    Champ.perteFocus("tab")
                    Champ.redessine()
                    if Interne.valide==true then
                        break
                    end
                end
                
                if event=="key" and para1==29 then
                    enControle=true
                else
                    enControle=false
                end
            end
        end,function()
            while true do
                local _,para1=os.pullEvent("finFocusChamp")
                if para1==Interne.nom then
                    break
                end
            end
        end)
        return Champ
    end
    return Champ
end

function Champs.alerte(texte,background,ecran,posX,posY,largeur,hauteur)
    term.setCursorBlink(false)
    if texte==nil then texte="alerte" end
    if ecran==nil then ecran=term.current() end
    if background==nil then background=colors.white end
    if finY==nil then
        local x,y=ecran.getSize()
        posX=math.floor((x-15)/2)
        posY=5
        if string.len(texte)<15 then
            largeur=15
        else
            largeur=string.len(texte)
        end
        hauteur=5
    end
    fenettre=window.create(ecran, posX, posY, largeur, hauteur, true)
    fenettre.setBackgroundColor(background)
    fenettre.clear()
    fenettre.setCursorPos(1,1)
    fenettre.setBackgroundColor(colors.gray)
    fenettre.clearLine()
    fenettre.setCursorPos(largeur,1)
    fenettre.setTextColor(colors.red)
    fenettre.write("x")
    fenettre.setBackgroundColor(background)
    fenettre.setCursorPos((largeur-string.len(texte))/2,2)
    fenettre.write(texte)
    Champ=Champs.ChampBouton("bouton1",2,hauteur,largeur-2,fenettre).texte("ok").visible(true)
    while true do
        event,par1,par2,par3=os.pullEvent()
        if event=="key" and par1==28 then
            break
        elseif event=="mouse_click" and par2>posX and par2<posX+largeur and par3==hauteur+posY-1 then
            break
        elseif event=="mouse_click" and par2==posX+largeur-1 and par3==posY then
            break
        end
    end
end
function Champs.confirm(texte,background,ecran,posX,posY,largeur,hauteur)
    term.setCursorBlink(false)
    if texte==nil then texte="alerte" end
    if ecran==nil then ecran=term.current() end
    if background==nil then background=colors.white end
    if finY==nil then
        local x,y=ecran.getSize()
        posX=math.floor((x-15)/2)
        posY=5
        if string.len(texte)<15 then
            largeur=15
        else
            largeur=string.len(texte)
        end
        hauteur=5
    end
    fenettre=window.create(ecran, posX, posY, largeur, hauteur, true)
    fenettre.setBackgroundColor(background)
    fenettre.clear()
    fenettre.setCursorPos(1,1)
    fenettre.setBackgroundColor(colors.gray)
    fenettre.clearLine()
    fenettre.setCursorPos(largeur,1)
    fenettre.setTextColor(colors.red)
    fenettre.write("x")
    fenettre.setBackgroundColor(background)
    fenettre.setCursorPos((largeur-string.len(texte))/2,2)
    fenettre.write(texte)
    Champs.ChampBouton("bouton1",2,hauteur,(largeur-2)/2,fenettre).texte("oui").visible(true)
    Champs.ChampBouton("bouton1",3+(largeur-2)/2,hauteur,(largeur-2)/2,fenettre).texte("non").visible(true)
    while true do
        event,par1,par2,par3=os.pullEvent()
        if event=="key" and par1==24 then
            return true
        elseif event=="key" and par1==49 then
            return false
        elseif event=="mouse_click" and par2>posX and par2<posX+(largeur-2)/2 and par3==hauteur+posY-1 then
            return true
        elseif event=="mouse_click" and par2>posX+(largeur-2)/2 and par2<posX+largeur-2 and par3==hauteur+posY-1 then
            return false
        elseif event=="mouse_click" and par2==posX+largeur-1 and par3==posY then
            return false
        end
    end
end
function Champs.prompt(texte,defaut,largeur,ecran)
    term.setCursorBlink(false)
    if texte==nil then texte="demande" end
    if ecran==nil then ecran=term.current() end
    if defaut==nil then defaut="" end
    if largeur==nil then
        if string.len(texte)<15 then
            largeur=15
        else
            largeur=string.len(texte)
        end
    end
    local x,y=ecran.getSize()
    fenettre=window.create(ecran, math.floor((x-largeur)/2), 5, largeur, 5, true)
    fenettre.setBackgroundColor(colors.white)
    fenettre.clear()
    fenettre.setCursorPos(1,1)
    fenettre.setBackgroundColor(colors.gray)
    fenettre.clearLine()
    fenettre.setCursorPos(largeur,1)
    fenettre.setTextColor(colors.red)
    fenettre.write("x")
    Champs.ChampBouton("bouton1",2,5,largeur-2,fenettre).texte("ok").visible(true)
    local ctexte=Champs.ChampTexte("texte1",2,3,largeur-2,fenettre)
    ctexte.valeur(defaut).valueInfo(texte).visible(true)
    local retour=""
    parallel.waitForAny(function()
        while true do
            event,par1,par2,par3=os.pullEvent()
            if event=="key" and par1==28 then
                break
            elseif event=="mouse_click" and par2>math.floor((x-15)/2) and par2<math.floor((x-15)/2)+largeur and par3==5+5-1 then
                break
            elseif event=="mouse_click" and par2==math.floor((x-15)/2)+largeur-1 and par3==5 then
                break
            end
        end
    end,function()
        ctexte.focus()
    end)
    term.setCursorBlink(false)
    return ctexte.valeur()
end
function Champs.choixOrdonne(liste,nom,listeObjetsSelect,ecran)
    term.setCursorBlink(false)
    if liste==nil then liste={} end
    if nom==nil then nom="" end
    if ecran==nil then ecran=term.current() end
    local objetSelect=1
    local listeObjetsOrdonnees={}
    if listeObjetsSelect~=nil then
	for i,v in pairs(listeObjetsSelect) do
	    for ii,vv in pairs(liste) do
		    if vv==v then
			    table.insert(listeObjetsOrdonnees,v)
			    break
		    end
	    end
	end
    end
    local coteSelect="gauche"
    local x,y=ecran.getSize()
    local fenettre=window.create(term.current(),(x-41)/2,5,41,10,true)
    local premier=1
    local premierDroite=1
    local function aff()
        local x,y=20,5
        fenettre.setBackgroundColor(colors.white)
        fenettre.clear()
        fenettre.setCursorPos(1,1)
        fenettre.setBackgroundColor(colors.gray)
        fenettre.clearLine()
        fenettre.setCursorPos(2,1)
        fenettre.setTextColor(colors.lightGray)
        fenettre.write(nom)
        fenettre.setCursorPos(41,1)
        fenettre.setTextColor(colors.red)
        fenettre.write("x")
        for i,v in pairs(liste) do
            if i>=premier and i<premier+6 then
                fenettre.setTextColor(colors.black)
                fenettre.setCursorPos(2,i-premier+3)
                if i==objetSelect and coteSelect=="gauche" then
                    fenettre.setBackgroundColor(colors.gray)
		else
                    fenettre.setBackgroundColor(colors.lightGray)
                end
                fenettre.write(string.rep(" ",18))
                fenettre.setCursorPos(2,i-premier+3)
                fenettre.write(v)
            end
        end
	for i,v in pairs(listeObjetsOrdonnees) do
            if i>=premierDroite and i<premierDroite+6 then
                fenettre.setTextColor(colors.black)
                fenettre.setCursorPos(23,i-premierDroite+3)
                if i==objetSelect and coteSelect=="droite" then
                    fenettre.setBackgroundColor(colors.gray)
		else
                    fenettre.setBackgroundColor(colors.lightGray)
                end
                fenettre.write(string.rep(" ",18))
                fenettre.setCursorPos(23,i-premierDroite+3)
                fenettre.write(v)
            end
        end
	if coteSelect=="droite" or objetSelect<=0 then
		fenettre.setBackgroundColor(colors.gray)
		fenettre.setTextColor(colors.black)
	else
		fenettre.setBackgroundColor(colors.lightGray)
		fenettre.setTextColor(colors.gray)
	end
        fenettre.setCursorPos(21,4)
	fenettre.write(">")
	if coteSelect=="gauche" or objetSelect<=0 then
		fenettre.setBackgroundColor(colors.gray)
		fenettre.setTextColor(colors.black)
	else
		fenettre.setBackgroundColor(colors.lightGray)
		fenettre.setTextColor(colors.gray)
	end
        fenettre.setCursorPos(21,5)
	fenettre.write("<")		
        fenettre.setBackgroundColor(colors.white)
        fenettre.setTextColor(colors.lightGray)
	if coteSelect=="droite" and objetSelect>0 and #listeObjetsOrdonnees>1 then
	    if objetSelect>1 then
		fenettre.setCursorPos(41,3)
		fenettre.write("|")
	    end
	    if objetSelect<#listeObjetsOrdonnees then
		fenettre.setCursorPos(41,8)
		fenettre.write("|")
	    end
	end
        if premier+5<#liste then
            fenettre.setCursorPos(9,9)
            fenettre.write("...")
        end
        if premier>1 then
            fenettre.setCursorPos(9,2)
            fenettre.write("...")
        end
	if premierDroite+5<#listeObjetsOrdonnees then
            fenettre.setCursorPos(31,9)
            fenettre.write("...")
        end
        if premierDroite>1 then
            fenettre.setCursorPos(31,2)
            fenettre.write("...")
        end
        Champs.ChampBouton("",12,10,18,fenettre).texte("ok").visible(true)
    end
    aff()
    while true do
        event,para1,para2,para3=os.pullEvent()
        if event=="mouse_click" then
            if para2==math.floor((x-41)/2)+40 and para3==5 then
                return false
            elseif para2>=math.floor((x-41)/2)+12 and para2<=math.floor((x-41)/2)+28 and para3==14 then
		break
            elseif premier>1 and para2>=math.floor((x-35)/2)+2 and para2<=math.floor((x-35)/2)+15 and para3==6 and coteSelect=="gauche" then
                premier=premier-1
                aff()
            elseif premier+5<#liste and para2>=math.floor((x-35)/2)+2 and para2<=math.floor((x-35)/2)+15 and para3==13 and coteSelect=="gauche" then
                premier=premier+1
                aff()
            elseif premierDroite>1 and para2>=math.floor((x-35)/2)+19 and para2<=math.floor((x-35)/2)+32 and para3==6 and coteSelect=="droite" then
                premierDroite=premierDroite-1
                aff()
            elseif premierDroite+5<#listeObjetsOrdonnees and para2>=math.floor((x-35)/2)+32 and para2<=math.floor((x-35)/2)+32 and para3==13 and coteSelect=="droite" then
                premierDroite=premierDroite+1
                aff()
            elseif para2>=math.floor((x-41)/2)+1 and para2<=math.floor((x-41)/2)+18 and para3>6 and para3<=12 and para3-6<=#liste then
		objetSelect=para3-7+premier
		coteSelect="gauche"
                aff()
            elseif para2>=math.floor((x-41)/2)+22 and para2<=math.floor((x-41)/2)+39 and para3>6 and para3<=12 and para3-6<=#listeObjetsOrdonnees then
		objetSelect=para3-7+premierDroite
		coteSelect="droite"
                aff()
            elseif para2==math.floor((x-41)/2)+20 and para3==8 and coteSelect=="gauche" and objetSelect>0 then
		table.insert(listeObjetsOrdonnees,liste[objetSelect+premier-1])
		table.remove(liste,objetSelect+premier-1)
		if objetSelect>#liste then
			objetSelect=#liste
		end
                aff()
            elseif para2==math.floor((x-41)/2)+20 and para3==9 and coteSelect=="droite" and objetSelect>0 then
		table.insert(liste,listeObjetsOrdonnees[objetSelect+premierDroite-1])
		table.remove(listeObjetsOrdonnees,objetSelect+premierDroite-1)
		if objetSelect>#listeObjetsOrdonnees then
			objetSelect=#listeObjetsOrdonnees
		end
                aff()
            elseif para2==math.floor((x-41)/2)+40 and para3==7 and coteSelect=="droite" and objetSelect>0 and #listeObjetsOrdonnees>1 and objetSelect>1 then
		local nomActuel=listeObjetsOrdonnees[objetSelect]
		listeObjetsOrdonnees[objetSelect]=listeObjetsOrdonnees[objetSelect-1]
		listeObjetsOrdonnees[objetSelect-1]=nomActuel
		objetSelect=objetSelect-1
                aff()
            elseif para2==math.floor((x-41)/2)+40 and para3==12 and coteSelect=="droite" and objetSelect>0 and objetSelect<#listeObjetsOrdonnees then
		local nomActuel=listeObjetsOrdonnees[objetSelect]
		listeObjetsOrdonnees[objetSelect]=listeObjetsOrdonnees[objetSelect+1]
		listeObjetsOrdonnees[objetSelect+1]=nomActuel
		objetSelect=objetSelect+1
                aff()
            end
        elseif event=="mouse_scroll" and para1==1 and premier+5<#liste and coteSelect=="gauche" then
            premier=premier+1
            aff()
        elseif event=="mouse_scroll" and para1==-1 and premier>1 and coteSelect=="gauche" then
            premier=premier-1
            aff()
	elseif event=="mouse_scroll" and para1==1 and premierDroite+5<#listeObjetsOrdonnees and coteSelect=="droite" then
            premierDroite=premierDroite+1
            aff()
        elseif event=="mouse_scroll" and para1==-1 and premierDroite>1 and coteSelect=="droite" then
            premierDroite=premierDroite-1
            aff()
        elseif event=="key" and para1==28 then
            return false
        end
    end
    return listeObjetsOrdonnees
end
function Champs.choix(liste,nom,objetSelect,multiple,ecran)
    term.setCursorBlink(false)
    if liste==nil then liste={} end
    if nom==nil then nom="" end
    if multiple==nil then multiple=false end
    if objetSelect==nil then
	if multiple then
	    objetSelect={}
	else
	    objetSelect=1
	end
    end
    if ecran==nil then ecran=term.current() end
    local x,y=ecran.getSize()
    local fenettre=window.create(term.current(),(x-20)/2,5,20,10,true)
    local premier=1
    local function aff()
        local x,y=20,5
        fenettre.setBackgroundColor(colors.white)
        fenettre.clear()
        fenettre.setCursorPos(1,1)
        fenettre.setBackgroundColor(colors.gray)
        fenettre.clearLine()
        fenettre.setCursorPos(2,1)
        fenettre.setTextColor(colors.lightGray)
        fenettre.write(nom)
        fenettre.setCursorPos(20,1)
        fenettre.setTextColor(colors.red)
        fenettre.write("x")
        for i,v in pairs(liste) do
            if i>=premier and i<premier+6 then
                fenettre.setTextColor(colors.black)
                fenettre.setCursorPos(2,i-premier+3)
                if multiple==false and i==objetSelect then
                    fenettre.setBackgroundColor(colors.gray)
                elseif multiple and objetSelect["r"..i]==true then
                    fenettre.setBackgroundColor(colors.gray)
		else
                    fenettre.setBackgroundColor(colors.lightGray)
                end
                fenettre.write(string.rep(" ",18))
                fenettre.setCursorPos(2,i-premier+3)
                fenettre.write(v)
            end
        end
        fenettre.setTextColor(colors.lightGray)
        fenettre.setBackgroundColor(colors.white)
        if premier+5<#liste then
            fenettre.setCursorPos(9,9)
            fenettre.write("...")
        end
        if premier>1 then
            fenettre.setCursorPos(9,2)
            fenettre.write("...")
        end
        if (multiple==false and objetSelect>0) or (multiple==true and #objetSelect>0) then
            Champs.ChampBouton("",2,10,18,fenettre).texte("ok").visible(true)
        else
            Champs.ChampBouton("",2,10,18,fenettre).texte("ok").statut(false).visible(true)
        end
    end
    aff()
    while true do
        event,para1,para2,para3=os.pullEvent()
        if event=="mouse_click" then
            if para2==math.floor((x-20)/2)+19 and para3==5 then
                return false
            elseif ((multiple==false and objetSelect>0) or multiple) and para2>=math.floor((x-20)/2)+2 and para2<=math.floor((x-20)/2)+18 and para3==14 then
		break
            elseif premier>1 and para2>=math.floor((x-20)/2)+2 and para2<=math.floor((x-20)/2)+18 and para3==6 then
                premier=premier-1
                aff()
            elseif premier+5<#liste and para2>=math.floor((x-20)/2)+2 and para2<=math.floor((x-20)/2)+18 and para3==13 then
                premier=premier+1
                aff()
            elseif para2>=math.floor((x-20)/2)+2 and para2<=math.floor((x-20)/2)+18 and para3>6 and para3<=12 and para3-6<=#liste then
		if multiple then
			if objetSelect["r"..para3-7+premier]==true then
				objetSelect["r"..para3-7+premier]=nil
			else
				objetSelect["r"..para3-7+premier]=true
			end
		else
			objetSelect=para3-7+premier
		end
                aff()
            end
        elseif event=="mouse_scroll" and para1==1 and premier+5<#liste then
            premier=premier+1
            aff()
        elseif event=="mouse_scroll" and para1==-1 and premier>1 then
            premier=premier-1
            aff()
        elseif event=="key" and par1==28 then
            return false
        end
    end
    if multiple then
        return objetSelect
    end
    return objetSelect,liste[objetSelect]
end
function Champs.couleur(nom,couleurSelect,multiple,ecran)
    term.setCursorBlink(false)
    local nomCouleurs={"blanc","orange","magenta","bleu clair","jaune","citron vert","rose","gris","gris clair","cyan","violet","bleu","marron","vert","rouge","noir"}
    local idCouleurs={1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768}
    if nom==nil then nom="choix Couleur" end
    if multiple==nil then multiple=false end
    if couleurSelect==nil then
	if multiple then
	    couleurSelect={}
	else
	    couleurSelect=0
	end
    elseif not multiple then
	lacouleur=0
	for i,v in pairs(idCouleurs) do
            if v==couleurSelect then
                lacouleur=i
                break
            end
	end
	couleurSelect=lacouleur
    end
    if ecran==nil then ecran=term.current() end
    local x,y=ecran.getSize()
    local fenettre=window.create(term.current(),(x-20)/2,5,20,10,true)
    local premier=1
    local function aff()
        local x,y=20,5
        fenettre.setBackgroundColor(colors.white)
        fenettre.clear()
        fenettre.setCursorPos(1,1)
        fenettre.setBackgroundColor(colors.gray)
        fenettre.clearLine()
        fenettre.setCursorPos(2,1)
        fenettre.setTextColor(colors.lightGray)
        fenettre.write(nom)
        fenettre.setCursorPos(20,1)
        fenettre.setTextColor(colors.red)
        fenettre.write("x")
        for i,v in pairs(nomCouleurs) do
            if i>=premier and i<premier+6 then
                fenettre.setTextColor(colors.black)
                fenettre.setCursorPos(2,i-premier+3)
                if multiple==false and i==couleurSelect then
                    fenettre.setBackgroundColor(colors.gray)
                elseif multiple and couleurSelect["r"..i]==true then
                    fenettre.setBackgroundColor(colors.gray)
		else
                    fenettre.setBackgroundColor(colors.lightGray)
                end
                fenettre.write(string.rep(" ",18))
                fenettre.setCursorPos(4,i-premier+3)
                fenettre.write(v)
                fenettre.setCursorPos(2,i-premier+3)
		fenettre.setBackgroundColor(idCouleurs[i])
		fenettre.write(" ")
            end
        end
        fenettre.setTextColor(colors.lightGray)
        fenettre.setBackgroundColor(colors.white)
        if premier+5<#nomCouleurs then
            fenettre.setCursorPos(9,9)
            fenettre.write("...")
        end
        if premier>1 then
            fenettre.setCursorPos(9,2)
            fenettre.write("...")
        end
	nbCouleursSelect=false
	if multiple then
            for i,v in pairs(couleurSelect) do
                nbCouleursSelect=true
                break
            end
	end
        if (multiple==false and couleurSelect>0) or (multiple==true and nbCouleursSelect) then
            Champs.ChampBouton("",2,10,18,fenettre).texte("ok").visible(true)
        else
            Champs.ChampBouton("",2,10,18,fenettre).texte("ok").statut(false).visible(true)
        end
    end
    aff()
    while true do
        event,para1,para2,para3=os.pullEvent()
        if event=="mouse_click" then
            if para2==math.floor((x-20)/2)+19 and para3==5 then
                return false
            elseif ((multiple==false and couleurSelect>0) or (multiple and nbCouleursSelect)) and para2>=math.floor((x-20)/2)+2 and para2<=math.floor((x-20)/2)+18 and para3==14 then
		break
            elseif premier>1 and para2>=math.floor((x-20)/2)+2 and para2<=math.floor((x-20)/2)+18 and para3==6 then
                premier=premier-1
                aff()
            elseif premier+5<#nomCouleurs and para2>=math.floor((x-20)/2)+2 and para2<=math.floor((x-20)/2)+18 and para3==13 then
                premier=premier+1
                aff()
            elseif para2>=math.floor((x-20)/2)+2 and para2<=math.floor((x-20)/2)+18 and para3>6 and para3<=12 and para3-6<=#nomCouleurs then
		if multiple then
                    if couleurSelect["r"..para3-7+premier]==true then
                        couleurSelect["r"..para3-7+premier]=nil
                    else
                        couleurSelect["r"..para3-7+premier]=true
                    end
		else
		    couleurSelect=para3-7+premier
		end
                aff()
            end
        elseif event=="mouse_scroll" and para1==1 and premier+5<#nomCouleurs then
            premier=premier+1
            aff()
        elseif event=="mouse_scroll" and para1==-1 and premier>1 then
            premier=premier-1
            aff()
        elseif event=="key" and par1==28 then
            return false
        end
    end
    if multiple then
	local retour={}
	for i,v in pairs(couleurSelect) do
	    table.insert(retour,idCouleurs[v])
	end
        return retour
    end
    return idCouleurs[couleurSelect]
end
