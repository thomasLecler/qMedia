local args={...}
local shell=args[1]
x,y=term.getSize()
local Interne={}
local continue=true
local direenrevoir=true
Interne.nomMoniteur=""
Interne.champs={}
Interne.page="accueil"
Interne.prjDefaut=false
if fs.exists("recent") and fs.isDir("recent")==false then
    local parametres=ltpg.fsTraitementData("recent")
    if parametres.autoProjet and fs.exists(parametres.autoProjet) then
        Interne.page="renduProjet"
        Interne.urlProjet=parametres.autoProjet
    end
end

if not fs.exists("recent") then
    local theTable={}
    theTable.enTete="Parametres qMedia"
    theTable.recent={}
    ltpg.fsEnregistrementData("recent",theTable)
end
local function info(texte)
    if texte==nil then
        return
    end
    term.setCursorPos((x-string.len(texte))/2,y)
    term.setBackgroundColor(colors.lightBlue)
    term.setTextColor(colors.blue)
    term.write(">"..texte.."<")
    sleep(1.5)
    term.clearLine()
end
local function erreur(texte)
    term.setCursorPos((x-string.len(texte))/2,y)
    term.setBackgroundColor(colors.lightBlue)
    term.setTextColor(colors.red)
    term.write(">"..texte.."<")
    sleep(1.5)
    term.clearLine()
end
function Interne.redessine()
    term.setBackgroundColor(colors.lightBlue)
    term.setCursorPos(1,1)
    term.clear()
    term.setBackgroundColor(colors.cyan)
    term.clearLine()
    term.setCursorPos(1,1)
    term.setTextColor(colors.red)
    term.write("x")
    term.setCursorPos(3,1)
    term.setTextColor(colors.lime)
    term.write("qMedia V1.0.1")
    if Interne.page=="editProjet" then
        write(" - edition "..fs.getName(Interne.urlProjet))
    elseif Interne.page=="lancerProjet" then
        write(" - lancement "..fs.getName(Interne.urlProjet))
    end
    if Interne.page~="accueil" then
        term.setCursorPos(x,1)
        term.write("a")
    end
    term.setCursorPos(1,3)
    term.setBackgroundColor(colors.lightBlue)
    if Interne.nomMoniteur~="" then
        if peripheral.getType(Interne.nomMoniteur)~="monitor" then
            Interne.nomMoniteur=""
        elseif Interne.page~="editScene" and Interne.page~="renduProjet" then
            local moniteur=peripheral.wrap(Interne.nomMoniteur)
            local larg,haut=moniteur.getSize()
            moniteur.setTextScale(1)
            larg,haut=moniteur.getSize()
            if larg<Interne.largeur or haut<Interne.hauteur then
                Interne.nomMoniteur=""
            else
                moniteur.setBackgroundColor(colors.lightBlue)
                moniteur.clear()
                if Interne.largeur>8 then
                    if Interne.largeur>40 then
                        moniteur.setTextScale(2)
                    end
                    larg,haut=moniteur.getSize()
                    moniteur.setTextColor(colors.green)
                    moniteur.setCursorPos((larg-8)/2,1)
                    moniteur.write("qMedia")
                end
            end
        end
    end
end

function Interne.boutonsBarre()
    while true do
        event, para1, para2, para3=os.pullEvent()
        if event=="mouse_click" and para2==1 and para3==1 then
            if para1==2 then
                info("pour quitter le programme")
            else
                continue=false
                break
            end
        elseif event=="mouse_click" and para2==x and para3==1 and Interne.page~="accueil" then
            if para1==2 then
                info("pour retourner à l'accueil")
            else
                Interne.urlProjet=nil
                Interne.page="accueil"
                break
            end
        <?php if ($debug)
        {
            ?>elseif event=="key" and para1==74 then
            continue=false
            direenrevoir=false
            sleep(0.01)
            break<?php
                }?>
        end
    end
end

local projetSelect
do
    local projetsRecents
    local parametres
    
    function Interne.accueil()
        projetsRecents={}
        if fs.exists("recent") and fs.isDir("recent")==false then
            parametres=ltpg.fsTraitementData("recent")
            for i,v in pairs(parametres.recent) do
                table.insert(projetsRecents,v)
            end
        end
        if parametres.fichierDefaut~=nil then
            Interne.prjDefaut=parametres.fichierDefaut
        end
        local function enregistrePara()
            parametres.recent=projetsRecents
            ltpg.fsEnregistrementData("recent",parametres)
        end
        local function aff()
            Interne.redessine()
            term.setBackgroundColor(colors.lightBlue)
            term.setCursorPos((x-6)/2,3)
            term.setTextColor(colors.blue)
            term.write("Projet")
            term.setCursorPos(3,4)
            term.setTextColor(colors.gray)
            term.write("Fichiers recent:")
            sleep(0.1)
            for i,v in ipairs(projetsRecents) do
                if i==projetSelect then
                    Champs.ChampBouton("fichierrecent"..i,3,4+i,20).statut(false).texte(fs.getName(v)).visible(true)
                else
                    Champs.ChampBouton("fichierrecent"..i,3,4+i,20).texte(fs.getName(v)).visible(true)
                end
                if i>=10 then
                    break
                end
            end
            Interne.champs.recent={}
            if #projetsRecents==0 then
                term.setTextColor(colors.red)
                term.setCursorPos(3,5)
                term.write("Aucun fichier")
            end
            term.setCursorPos(3,16)
            term.setTextColor(colors.gray)
            term.setBackgroundColor(colors.lightBlue)
            term.write("Autre:")
            Champs.ChampBouton("nouveauFichier",3,17,20).texte("nouveau projet").visible(true)
            Champs.ChampBouton("ouvrirFichier",3,18,20).texte("ouvrir un projet").visible(true)
            term.setBackgroundColor(colors.cyan)
            for i=4,18 do
                term.setCursorPos(29,i)
                term.write(string.rep(" ",21))
            end
            
            term.setCursorPos(30,5)
            term.setTextColor(colors.blue)
            if not projetSelect then
                term.write(" Selectionnez")
                term.setCursorPos(30,6)
                term.write(" un projet")
            else
                local infosfs=ltpg.fsTraitementData(projetsRecents[projetSelect])
                local function lectureFichier()
                    if infosfs.scenes==nil or infosfs.largeur==nil or infosfs.hauteur==nil or infosfs.id==nil then
                        return false
                    end
                    conteur=0
                    for i,v in pairs(infosfs.scenes) do
                        if conteur>5 then
                            term.setCursorPos(30,17)
                            term.setTextColor(colors.gray)
                            term.write(" (...)             ")
                        elseif conteur<5 then
                            term.setCursorPos(30,12+conteur)
                            term.setTextColor(colors.gray)
                            if v.nom==nil then
                                return false
                            end
                            term.write(">"..v.nom)
                        end
                        conteur=conteur+1
                    end
                    term.setTextColor(colors.yellow)
                    term.setCursorPos(29+(21-string.len(fs.getName(projetsRecents[projetSelect])))/2,4)
                    term.write(fs.getName(projetsRecents[projetSelect]))
                    term.setCursorPos(30,6)
                    term.setTextColor(colors.lightBlue)
                    term.write(projetsRecents[projetSelect])
                    term.setCursorPos(30,7)
                    term.write(fs.getSize(projetsRecents[projetSelect]).." bytes")
                    term.setCursorPos(30,8)
                    if infosfs.largeur==nil or infosfs.hauteur==nil then
                        return false
                    end
                    term.write("ecran: "..infosfs.largeur.."*"..infosfs.hauteur)
                    term.setCursorPos(30,9)
                    if conteur>1 then
                        term.write(conteur.." scenes ")
                    else
                        term.write(conteur.." scene ")
                    end
                    local nbRes=0
                    if infosfs.ressources==nil then
                        return false
                    end
                    for i,v in pairs(infosfs.ressources) do
                        nbRes=nbRes+1
                    end
                    term.setCursorPos(30,10)
                    if nbRes>1 then
                        term.write(nbRes.." ressources")
                    else
                        term.write(nbRes.." ressource")
                    end
                    return true
                end
                if lectureFichier()==false then
                    for i=5,18 do
                        term.setCursorPos(29,i)
                        term.write(string.rep(" ",21))
                    end
                    term.setCursorPos(30,5)
                    term.setTextColor(colors.red)
                    term.write(" Fichier corrompu")
                    term.setCursorPos(29,7)
                    term.write("il est impossible")
                    term.setCursorPos(29,8)
                    term.write("de decoder le fichier")
                    term.setCursorPos(29,9)
                    term.write("vous pouvez contacter")
                    term.setCursorPos(29,10)
                    term.write("le support ou Ded@le")
                    term.setCursorPos(29,11)
                    term.write("sur sa chaine")
                    term.setCursorPos(30,13)
                    term.write("merci de votre")
                    term.setCursorPos(30,14)
                    term.write("comprehention")
                    projetSelect=nil
                else                    
                    Champs.ChampBouton("nouveauFichier",31,18,8).texte("Editer").visible(true)
                    if conteur==0 then
                        Champs.ChampBouton("nouveauFichier",40,18,8).texte("Rendu").statut(false).visible(true)
                    else
                        Champs.ChampBouton("nouveauFichier",40,18,8).texte("Rendu").visible(true)
                    end
                end
            end
        end
        aff()
        
        parallel.waitForAny(Interne.boutonsBarre, function()
            while true do
                event, para1, para2, para3=os.pullEvent()
                if event=="mouse_click" then
                    if para2>=3 and para2<=23 and para3==17 then
                        if para1==2 then
                            info("pour cree une nouvelle scene")
                        else
                            Interne.page="nouveau"
                            break
                        end
                    elseif projetSelect~=nil and para2>=31 and para2<=39 and para3==18 then
                        if para1==2 then
                            info("pour modifier la scene selectionnée")
                        else
                            Interne.urlProjet=projetsRecents[projetSelect]
                            table.remove(projetsRecents,projetSelect)
                            table.insert(projetsRecents,1,Interne.urlProjet)
                            enregistrePara()
                            resetDonneesScene()
                            projetSelect=1
                            Interne.page="editProjet"
                            break
                        end
                    elseif projetSelect~=nil and para2>=40 and para2<=48 and para3==18 and conteur>0 then
                        if para1==2 then
                            info("pour lancer le rendu d'un projet")
                        else
                            Interne.urlProjet=projetsRecents[projetSelect]
                            table.remove(projetsRecents,projetSelect)
                            table.insert(projetsRecents,1,Interne.urlProjet)
                            enregistrePara()
                            resetDonneesScene()
                            projetSelect=1
                            resetDonneesScene()
                            Interne.page="renduProjet"
                            break
                        end
                    elseif para2>=3 and para2<=22 and para3>=5 and para3<=14 and (para3-4)<=#projetsRecents then
                        if para3-4==projetSelect then
                            if para1==1 then
                                Interne.page="editProjet"
                            elseif conteur>0 then
                                Interne.page="renduProjet"
                            end
                            Interne.urlProjet=projetsRecents[projetSelect]
                            table.remove(projetsRecents,projetSelect)
                            table.insert(projetsRecents,1,Interne.urlProjet)
                            enregistrePara()
                            resetDonneesScene()
                            projetSelect=1
                            break
                        else
                            term.setCursorPos(30,y)
                            projetSelect=para3-4
                            aff()
                        end
                    elseif para2>=3 and para2<=23 and para3==18 then
                        if para1==2 then
                            info("pour ouvrir un projet existant")
                        else
                            local fichier=Champs.ChampTexte("ouverture",3,y-1,20).valueInfo("fichier:").visible(true).focus().valeur()
                            if fichier and fs.exists(fichier) then
                                table.insert(projetsRecents,1,fichier)
                                projetSelect=1
                                enregistrePara()
                                resetDonneesScene()
                                break
                            else
                                Champs.alerte("Fichier inexistant")
                                Interne.redessine()
                                aff()
                            end
                            aff()
                        end
                    else
                        projetSelect=nil
                        aff()
                    end
                end
            end
        end)
    end
end

do
    local donnees
    local selectScene
    local scenes
    function resetDonneesScene()
        donnees=nil
    end
    local function choixMoniteur(multiple)
        if multiple==nil then
            multiple=false
        else
            multiple=true
        end
        local listeNomIndiceMon
        local fenettre=window.create(term.current(),(x-20)/2,5,20,10,true)
        local moniteurs
        local premier=1
        local ok
        if multiple then
            listeNomIndiceMon={}
            if donnees.nomListeMoniteur==nil then
                donnees.nomListeMoniteur={}
            end
            for i,v in pairs(donnees.nomListeMoniteur) do
                listeNomIndiceMon[tostring(v)]=true
            end
        else
            local nomMoniteurProv=Interne.nomMoniteur
        end
        local function aff()
            moniteurs={}
            local x,y=20,5
            fenettre.setBackgroundColor(colors.white)
            fenettre.clear()
            fenettre.setCursorPos(1,1)
            fenettre.setBackgroundColor(colors.gray)
            fenettre.clearLine()
            fenettre.setCursorPos(x,1)
            fenettre.setTextColor(colors.red)
            fenettre.write("x")
            for i,v in pairs(peripheral.getNames()) do
                if peripheral.getType(v)=="monitor" then
                    table.insert(moniteurs,v)
                end
            end
            for i,v in pairs(moniteurs) do
                if i>=premier and i<premier+6 then
                    fenettre.setTextColor(colors.black)
                    fenettre.setCursorPos(2,i-premier+3)
                    local larg,haut=peripheral.wrap(v).getSize()
                    if (multiple==false and v==nomMoniteurProv) or (multiple==true and listeNomIndiceMon[v]==true) then
                        fenettre.setBackgroundColor(colors.gray)
                    else
                        if larg>=donnees.largeur and haut>=donnees.hauteur then
                            fenettre.setBackgroundColor(colors.lime)
                        else
                            fenettre.setBackgroundColor(colors.lightGray)
                        end
                    end
                    fenettre.write(string.rep(" ",18))
                    fenettre.setCursorPos(2,i-premier+3)
                    fenettre.write(v)
                    fenettre.setCursorPos(13,i-premier+3)
                    if larg<donnees.largeur then
                        fenettre.setTextColor(colors.red)
                    else
                        fenettre.setTextColor(colors.black)
                    end
                    fenettre.write(tostring(larg))
                    fenettre.setCursorPos(16,i-premier+3)
                    if haut<donnees.hauteur then
                        fenettre.setTextColor(colors.red)
                    else
                        fenettre.setTextColor(colors.black)
                    end
                    fenettre.write(tostring(haut))
                    fenettre.setCursorPos(19,i-premier+3)
                    fenettre.setTextColor(colors.blue)
                    fenettre.write("r")
                end
            end
            fenettre.setTextColor(colors.lightGray)
            fenettre.setBackgroundColor(colors.white)
            if premier+5<#moniteurs then
                fenettre.setCursorPos(9,9)
                fenettre.write("...")
            end
            if premier>1 then
                fenettre.setCursorPos(9,2)
                fenettre.write("...")
            end
            ok=false
            if multiple then
                for i,v in pairs(listeNomIndiceMon) do
                    ok=true
                    break
                end
            end
            if (multiple==false and nomMoniteurProv~="") or (multiple==true and ok) then
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
                    break
                elseif ((multiple==false and nomMoniteurProv~="") or (multiple==true and ok)) and para2>=math.floor((x-20)/2)+2 and para2<=math.floor((x-20)/2)+18 and para3==14 then
                    if multiple then
                        local rtable={}
                        for i,v in pairs(listeNomIndiceMon) do
                            table.insert(rtable,i)
                        end
                        donnees.nomListeMoniteur=rtable
                    else
                        Interne.nomMoniteur=nomMoniteurProv
                        donnees.moniteur=nomMoniteurProv
                    end
                    Interne.change=true
                    break
                elseif premier>1 and para2>=math.floor((x-20)/2)+2 and para2<=math.floor((x-20)/2)+18 and para3==6 then
                    premier=premier-1
                    aff()
                elseif premier+5<#moniteurs and para2>=math.floor((x-20)/2)+2 and para2<=math.floor((x-20)/2)+18 and para3==13 then
                    premier=premier+1
                    aff()
                elseif para2>=math.floor((x-20)/2)+2 and para2<=math.floor((x-20)/2)+18 and para3>6 and para3-6<=#moniteurs then
                    if para2==math.floor((x-20)/2)+18 then
                        peripheral.wrap(moniteurs[para3-6]).setTextScale(1)
                    else
                        if multiple then
                            if listeNomIndiceMon[moniteurs[para3-6]]==nil then
                                listeNomIndiceMon[moniteurs[para3-6]]=true
                            else
                                listeNomIndiceMon[moniteurs[para3-6]]=nil
                            end
                        else
                            local larg,haut=peripheral.wrap(moniteurs[para3-6]).getSize()
                            if larg>=donnees.largeur and haut>=donnees.hauteur then
                                if multiple then
                                    listeNomIndiceMon[moniteurs[para3-6]]=true
                                else
                                    nomMoniteurProv=moniteurs[para3-6]
                                end
                            else
                                nomMoniteurProv=""
                            end
                        end
                    end
                    aff()
                end
            elseif event=="mouse_scroll" and para1==1 and premier+5<#moniteurs then
                premier=premier+1
                aff()
            elseif event=="mouse_scroll" and para1==-1 and premier>1 then
                premier=premier-1
                aff()
            end
        end
    end
    function Interne.editProjet()
        if donnees==nil then
            donnees=ltpg.fsTraitementData(Interne.urlProjet)
            Interne.largeur=donnees.largeur
            Interne.hauteur=donnees.hauteur
            if donnees.moniteur~=nil then
                Interne.nomMoniteur=donnees.moniteur
            end
        end
        selectScene=0
        scenes={}       
        for i,v in pairs(donnees.scenes) do
            table.insert(scenes,i,v)
        end
        
        local function fermetureProjet()
            if Interne.change then
                if Champs.confirm("Enregistrer?") then
                    ltpg.fsEnregistrementData(Interne.urlProjet,donnees)
                    Interne.change=false
                end
            end
            donnees=nil
            Interne.urlProjet=nil
        end
        local function aff()
            Interne.redessine()
            term.setCursorPos(4,2)
            term.setTextColor(colors.gray)
            term.setBackgroundColor(colors.lightBlue)
            write("scenes")
            local conteur=0
            for i,v in pairs(scenes) do
                if conteur<=20 then
                    term.setCursorPos(3,conteur+3)
                    if selectScene==i then
                        term.setTextColor(colors.black)
                        term.setBackgroundColor(colors.gray)
                    else
                        term.setBackgroundColor(colors.lightGray)
                    end
                    term.write(string.rep(" ",20))
                    term.setCursorPos(4,conteur+3)
                    write(v.nom)
                    term.setTextColor(colors.gray)
                end
                conteur=conteur+1
            end
            term.setCursorPos(11,2)
            term.setTextColor(colors.gray)
            term.setBackgroundColor(colors.lightBlue)
            if selectScene>0 then
                write("("..selectScene.."/"..conteur..")")
            else
                write("("..conteur..") ")
            end
            if selectScene==0 or selectScene<=1 then
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.gray)
            end
            term.setCursorPos(24,3)
            term.write("<")
            if selectScene==0 or selectScene==#scenes then
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.gray)
            end
            term.setCursorPos(24,4)
            term.write(">")
            if selectScene==0 or #scenes>=15 then
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.gray)
            end
            term.setCursorPos(24,5)
            term.write("d")
            if selectScene==0 then
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.gray)
            end
            term.setCursorPos(24,6)
            term.write("r")
            term.setCursorPos(24,7)
            term.write("-")
            if #scenes>=15 then
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.gray)
            end
            term.setCursorPos(24,8)
            term.write("+")
            if Interne.change then
                term.setCursorPos(x-1,1)
                term.setTextColor(colors.lime)
                term.setBackgroundColor(colors.cyan)
                term.write("s")
            end
            if selectScene==0 then
                Champs.ChampBouton("",28,3,21).statut(false).texte("modifier").visible(true)
            else
                Champs.ChampBouton("",28,3,21).texte("modifier").visible(true)
            end
            Champs.ChampBouton("",28,4,21).texte("resourses projet").visible(true)
            if #scenes>0 then
                Champs.ChampBouton("",28,5,21).texte("Rendu").visible(true)
            else
                Champs.ChampBouton("",28,5,21).texte("Rendu  ").statut(false).visible(true)
            end
            Champs.ChampBouton("",28,6,21).texte("moniteur").visible(true)
            term.setBackgroundColor(colors.cyan)
            for i=8,12 do
                term.setCursorPos(28,i)
                term.write(string.rep(" ",21))
            end
            if selectScene>0 then
                for i=14,18 do
                    term.setCursorPos(28,i)
                    term.write(string.rep(" ",21))
                end
                term.setTextColor(colors.orange)
                term.setCursorPos(29+(19-string.len("scene "..scenes[selectScene].nom))/2,14)
                term.write("scene "..scenes[selectScene].nom)
                term.setTextColor(colors.lightBlue)
                term.setCursorPos(30,15)
                write("zoom: "..scenes[selectScene].zoom)
                term.setCursorPos(39,15)
                write("fond: ")
                term.setTextColor(tonumber(scenes[selectScene].fond))
                write(scenes[selectScene].fond)
                local conteur=0
                for _,_ in pairs(scenes[selectScene].objets) do
                    conteur=conteur+1
                end
                term.setTextColor(colors.lightBlue)
                term.setCursorPos(30,16)
                if scenes[selectScene].frequence==nil then
                    scenes[selectScene].frequence=2
                end
                write("frequence: "..scenes[selectScene].frequence.."img/sec")
                term.setCursorPos(30,17)
                if scenes[selectScene].duree==nil then
                    scenes[selectScene].duree=10
                end
                write("duree: "..scenes[selectScene].duree.."sec")
                term.setCursorPos(30,18)
                write(conteur.." objet")
                if conteur>1 then
                    write("s")
                end
            end
            term.setTextColor(colors.yellow)
            term.setCursorPos(29+(19-string.len(fs.getName(Interne.urlProjet)))/2,8)
            term.write(fs.getName(Interne.urlProjet))
            term.setCursorPos(30,9)
            term.setTextColor(colors.lightBlue)
            term.write(Interne.urlProjet)
            term.setCursorPos(30,10)
            term.write(fs.getSize(Interne.urlProjet).." bytes")
            term.setCursorPos(30,11)
            term.write("ecran: "..donnees.largeur.."*"..donnees.hauteur)
            local nbRes=0
            for i,v in pairs(donnees.ressources) do
                nbRes=nbRes+1
            end
            term.setCursorPos(30,12)
            if nbRes>1 then
                term.write(nbRes.." ressources")
            else
                term.write(nbRes.." ressource")
            end
        end
        local function renomme()
            term.setBackgroundColor(colors.lightGray)
            term.setCursorPos(3,2+selectScene)
            term.setTextColor(colors.gray)
            write(">")
            term.setCursorPos(22,2+selectScene)
            write("<")
            local nouveauNom=Champs.ChampTexte("",4,2+selectScene,18).exreg("^[a-zA-Z0-9 ]+$").valide(true).valeur(scenes[selectScene].nom).focus().valeur()
            if string.len(nouveauNom)>=3 and string.len(nouveauNom)<=18 and string.find(nouveauNom,"^[a-zA-Z0-9 ]+$") then
                scenes[selectScene].nom=nouveauNom
                donnees.scenes=scenes
                Interne.change=true
            elseif nouveauNom=="" then
                
            else
                Champs.alerte("nom incorrecte")
            end
        end
        aff()
        while true do
            event,para1,para2,para3=os.pullEvent()
            if event=="mouse_click" and para2>=3 and para2<=23 and para3-2<=#scenes and para3>2 then
                if para3-2==selectScene then
                    if para1==2 then
                        info("modifier la scene")
                    else
                        Interne.page="editScene"
                        Interne.scene=selectScene
                        break
                    end
                else
                    selectScene=para3-2
                end
                aff()
            elseif event=="mouse_click" and para2==24 and para3==3 and selectScene~=0 and selectScene>1 then
                if para1==2 then
                    info("deplacer vers le haut la scene")
                else
                    local emplacement=scenes[selectScene-1]
                    scenes[selectScene-1]=scenes[selectScene]
                    scenes[selectScene]=emplacement
                    selectScene=selectScene-1
                    donnees.scenes=scenes
                    Interne.change=true
                end
                aff()
            elseif event=="mouse_click" and para2==24 and para3==4 and selectScene~=0 and selectScene<#scenes then
                if para1==2 then
                    info("pour deplacer vers le bas la scene")
                else
                    local emplacement=scenes[selectScene+1]
                    scenes[selectScene+1]=scenes[selectScene]
                    scenes[selectScene]=emplacement
                    selectScene=selectScene+1
                    donnees.scenes=scenes
                    Interne.change=true
                end
                aff()
            elseif event=="mouse_click" and para2==24 and para3==5 and selectScene~=0 and #scenes<15 then
                if para1==2 then
                    info("pour dupliquer la scene")
                else
                    local nomCopie="copie de "..string.sub(scenes[selectScene].nom,1,9)
                    local fond=scenes[selectScene].fond
                    local objets=scenes[selectScene].objets
                    local zoom=scenes[selectScene].zoom
                    table.insert(scenes,{nom=nomCopie,zoom=zoom,fond=fond,objets=objets})
                    selectScene=#scenes
                    aff()
                    renomme()
                    donnees.scenes=scenes
                    Interne.change=true
                end
                aff()
            elseif event=="mouse_click" and para2==24 and para3==6 and selectScene~=0 then
                if para1==2 then
                    info("pour renommer la scene")
                else
                    renomme()
                end
                aff()
            elseif event=="mouse_click" and para2==24 and para3==7 and #scenes<15 and selectScene~=0 then
                if para1==2 then
                    info("pour supprimer la scene")
                else
                    table.remove(scenes,selectScene)
                    if selectScene>=#scenes then
                        selectScene=#scenes
                    end
                    donnees.scenes=scenes
                    Interne.change=true
                end
                aff()
            elseif event=="mouse_click" and para2==24 and para3==8 and #scenes<15 then
                if para1==2 then
                    info("pour cree une nouvelle scene")
                else
                    table.insert(scenes,{nom="nouvelle scene",zoom=1,fond=32768,duree=10,frequence=2,objets={}})
                    selectScene=#scenes
                    aff()
                    renomme()
                    donnees.scenes=scenes
                    Interne.change=true
                end
                aff()
            elseif event=="mouse_click" and para2>=28 and para2<=49 and para3==3 and selectScene~=0 then
                if para1==2 then
                    info("Modifier la scene selectionnee")
                else
                    Interne.page="editScene"
                    Interne.scene=selectScene
                    break
                end
                aff()
            elseif event=="mouse_click" and para2>=28 and para2<=49 and para3==4 then
                if para1==2 then
                    info("Editer les ressources du projet")
                else
                    Interne.page="resourcesProjet"
                    break
                end
                aff()
            elseif event=="mouse_click" and para2>=28 and para2<=49 and para3==5 then
                if para1==2 then
                    info("Voir un rendu du projet")
                else
                    if Interne.change then
                        if Champs.confirm("Enregistrer?") then
                            ltpg.fsEnregistrementData(Interne.urlProjet,donnees)
                            Interne.change=false
                        end
                    end
                    Interne.page="renduProjet"
                    break
                end
                aff()
            elseif event=="mouse_click" and para2>=28 and para2<=49 and para3==6 then
                if para1==2 then
                    info("Choisir le moniteur de test")
                else
                    choixMoniteur()
                end
                aff()
            elseif event=="mouse_click" and para2==1 and para3==1 then
                if para1==2 then
                    info("pour quitter le programme")
                else
                    fermetureProjet()
                    continue=false
                    break
                end
                aff()
            elseif event=="mouse_click" and para2==x and para3==1 and Interne.page~="accueil" then
                if para1==2 then
                    info("pour retourner à l'accueil")
                else
                    fermetureProjet()
                    Interne.page="accueil"
                    break
                end
                aff()
            <?php if ($debug)
            {
                ?>elseif event=="key" and para1==74 then
                continue=false
                direenrevoir=false
                sleep(0.01)
                break<?php
            }?>
            elseif event=="mouse_click" and Interne.change and para2==x-1 and para3==1 then
                if para1==2 then
                    info("pour enregistrer les modifications")
                    aff()
                else
                    ltpg.fsEnregistrementData(Interne.urlProjet,donnees)
                    Interne.change=false
                end
                aff()
            end
        end
    end
    do
        local resSelectionnee
        local premier
        local ressources
        function Interne.resourcesProjet()
            ressources={}
            for i,v in pairs(donnees.ressources) do
                table.insert(ressources,i,v)
            end
            resSelectionnee=0
            premier=1
            local function fermetureProjet()
                if Interne.change then
                    if Champs.confirm("Enregistrer?") then
                        ltpg.fsEnregistrementData(Interne.urlProjet,donnees)
                        Interne.change=false
                    end
                end
                donnees=nil
                Interne.change=false
                Interne.urlProjet=nil
            end
            function aff()
                Interne.redessine()
                term.setCursorPos(2,2)
                term.setTextColor(colors.gray)
                term.setBackgroundColor(colors.lightBlue)
                write("<- retout")
                term.setCursorPos((x-10)/2,2)
                term.setTextColor(colors.blue)
                write("Ressources ("..#ressources..")")
                term.setCursorPos(x-2-5,2)
                if resSelectionnee>0 then
                    term.setBackgroundColor(colors.lightGray)
                    term.setTextColor(colors.gray)
                else
                    term.setBackgroundColor(colors.gray)
                    term.setTextColor(colors.black)
                end
                write("e")
                write("r")
                write("d")
                write("-")
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.gray)
                write("+")
                write("i")
                if #ressources>15 then
                    term.setBackgroundColor(colors.cyan)
                    for i=0,15 do
                        term.setCursorPos(x,i+4)
                        write(" ")
                    end
                    term.setBackgroundColor(colors.blue)
                    if premier>1 then
                        term.setCursorPos(x,4)
                        write(" ")
                    end
                    if premier+14<#ressources+1 then
                        term.setCursorPos(x,19)
                        write(" ")
                    end
                end
                term.setCursorPos(3,4)
                term.setBackgroundColor(colors.cyan)
                term.setTextColor(colors.black)
                term.write(string.rep(" ",x-4))
                term.setCursorPos(2,4)
                term.setTextColor(colors.black)
                term.write("nm nom        type infos")
                term.setCursorPos(1,5)
                term.setTextColor(colors.gray)
                for i=0,14 do
                    if #ressources==0 then
                        break
                    end
                    term.setCursorPos(2,i+5)
                    term.setBackgroundColor(colors.lightGray)
                    if resSelectionnee==i+premier then
                        term.setBackgroundColor(colors.gray)
                        term.setTextColor(colors.black)
                    end
                    term.write(string.rep(" ",x-3))
                    term.setCursorPos(2,i+5)
                    write(i+premier)
                    term.setCursorPos(5,i+5)
                    write(ressources[i+premier].nom)
                    term.setCursorPos(16,i+5)
                    if ressources[i+premier].type=="img" and ressources[i+premier].fond~=nil then
                        write("img")
                        term.setCursorPos(21,i+5)
                        write("fond:")
                        if ressources[i+premier].fond~=0 then
                            term.setTextColor(ressources[i+premier].fond)
                            write(ressources[i+premier].fond.." ")
                            if resSelectionnee==i+premier then
                                term.setTextColor(colors.black)
                            else
                                term.setTextColor(colors.gray)
                            end
                        else
                            write("_")
                        end
                        write("taille:"..ressources[i+premier].x.."x"..ressources[i+premier].y)
                    elseif ressources[i+premier].type=="prg" then
                        write("prg")
                        term.setCursorPos(21,i+5)
                    end
                    term.setTextColor(colors.gray)
                    term.setBackgroundColor(colors.lightBlue)
                    if resSelectionnee==i+premier then
                        term.setCursorPos(1,i+5)
                        write(">")
                        term.setCursorPos(x-1,i+5)
                        write("<")
                    end
                    if i+premier==#ressources then
                        break
                    end
                end
                if Interne.change then
                    term.setCursorPos(x-1,1)
                    term.setTextColor(colors.lime)
                    term.setBackgroundColor(colors.cyan)
                    term.write("s")
                end
            end
            local clicky=0
            local function renomme()
                term.setBackgroundColor(colors.lightGray)
                term.setCursorPos(3,4+resSelectionnee)
                term.setTextColor(colors.gray)
                write(">")
                term.setCursorPos(13,4+resSelectionnee)
                write("<")
                local nouveauNom=Champs.ChampTexte("",4,4+resSelectionnee,10).exreg("^[a-zA-Z0-9 ]+$").valide(true).valeur(ressources[resSelectionnee].nom).focus().valeur()
                if string.len(nouveauNom)>=3 and string.len(nouveauNom)<=18 and string.find(nouveauNom,"^[a-zA-Z0-9 ]+$") then
                    ressources[resSelectionnee].nom=nouveauNom
                    donnees.ressources=ressources
                    Interne.change=true
                elseif nouveauNom=="" then
                    
                else
                    Champs.alerte("nom incorrecte")
                end
            end
            while true do
                aff()
                event,para1,para2,para3=os.pullEvent()
                if event=="mouse_click" then
                    if para2==x and para3>=5 and para3<=18 then
                        clicky=para3
                    else
                        clicky=0
                    end
                end
                if event=="mouse_scroll" and para1==1 and premier+14<#ressources+1 then
                    premier=premier+1
                elseif event=="mouse_scroll" and para1==-1 and premier>1 then
                    premier=premier-1
                elseif event=="mouse_drag" and clicky>0 then
                    if clicky-para3>0 and premier>1 then
                        premier=premier-1
                    elseif para3-clicky>0 and premier+14<#ressources+1 then
                        premier=premier+1
                    end
                elseif event=="mouse_click" and para2>=2 and para2<=10 and para3==2 then
                    if para1==2 then
                        info("retourner a la gestion de projet")
                    else
                        Interne.page="editProjet"
                        break
                    end
                elseif event=="mouse_click" and para2==x and para3==4 and premier>1 then
                    premier=premier-1
                elseif event=="mouse_click" and para2==x and para3==19 and premier+14<#ressources+1 then
                    premier=premier+1
                elseif event=="mouse_click" and para2>=2 and para2<=x-3 and para3>=5 and para3<=25 and para3-4+premier<=#ressources+1 then
                    if resSelectionnee==para3-5+premier and para2>=5 and para2<=15 then
                        if para1==2 then
                            info("renommer une ressource")
                        else
                            renomme()
                        end
                    else
                        if para1==2 then
                            info("selectionner une ressource")
                        else
                            resSelectionnee=para3-5+premier
                        end
                    end
                elseif event=="mouse_click" and para2==x-2 and para3==2 then
                    if para1==2 then
                        info("Importer une ressource")
                    else
                        erreur("pas encore implemente")
                    end
                elseif event=="mouse_click" and para2==x-7 and para3==2 and resSelectionnee>0 then
                    if para1==2 then
                        info("Editer la ressource")
                    else
                        if ressources[resSelectionnee].type=="prg" then
                            local fichier=fs.open("edition.programme","w")
                            fichier.write(ressources[resSelectionnee].contenu)
                            fichier.close()
                            shell.run("edit","edition.programme")
                            fichier=fs.open("edition.programme","r")
                            ressources[resSelectionnee].contenu=fichier.readAll()
                            fichier.close()
                            Interne.change=true
                            donnees.ressources=ressources
                        elseif ressources[resSelectionnee].type=="img" then
                            local fichier=fs.open("edition.image","w")
                            fichier.write(ressources[resSelectionnee].contenu)
                            fichier.close()
                            shell.run("paint","edition.image")
                            fichier=fs.open("edition.image","r")
                            ressources[resSelectionnee].contenu=fichier.readAll()
                            fichier.close()
                            Interne.change=true
                            donnees.ressources=ressources
                        end
                    end
                elseif event=="mouse_click" and para2==x-6 and para3==2 and resSelectionnee>0 then
                    if para1==2 then
                        info("renommer la ressource")
                    else
                        renomme()
                    end
                elseif event=="mouse_click" and para2==x-5 and para3==2 and resSelectionnee>0 then
                    if para1==2 then
                        info("Dupliquer la ressource")
                    else
                        local nouveau={}
                        nouveau.nom="2"..ressources[resSelectionnee].nom
                        if ressources[resSelectionnee].type=="img" then
                            nouveau.type="img"
                            nouveau.fond=ressources[resSelectionnee].fond
                            nouveau.x=ressources[resSelectionnee].x
                            nouveau.y=ressources[resSelectionnee].y
                        end
                        nouveau.contenu=ressources[resSelectionnee].contenu
                        table.insert(ressources,nouveau)
                        Interne.change=true
                        donnees.ressources=ressources
                    end
                elseif event=="mouse_click" and para2==x-4 and para3==2 and resSelectionnee>0 then
                    if para1==2 then
                        info("supprimer la ressource")
                    else
                        table.remove(ressources,resSelectionnee)
                        Interne.change=true
                        donnees.ressources=ressources
                    end
                elseif event=="mouse_click" and para2==x-3 and para3==2 then
                    if para1==2 then
                        info("ajouter une ressource")
                    else
                        do
                            local nom
                            local type="img"
                            local fenettre
                            local fond
                            local largeur
                            local hauteur
                            local function aff()
                                fenettre=window.create(term.current(),(x-22)/2,4,22,14)
                                fenettre.setBackgroundColor(colors.white)
                                fenettre.clear()
                                fenettre.setCursorPos(1,1)
                                fenettre.setBackgroundColor(colors.gray)
                                fenettre.clearLine()
                                fenettre.setCursorPos(22,1)
                                fenettre.setTextColor(colors.lightGray)
                                fenettre.write("Nouvelle Ressource")
                                fenettre.setCursorPos(22,1)
                                fenettre.setTextColor(colors.red)
                                fenettre.write("x")
                                Champs.ChampBouton("",3,13,18,fenettre).texte("valider").visible(true)
                                if type=="img" then
                                    if fond==nil then
                                        fond=Champs.ChampTexte("",3,7,18,fenettre).valueInfo("fond:").visible(true)
                                        largeur=Champs.ChampTexte("",3,9,18,fenettre).valueInfo("largeur:").visible(true)
                                        hauteur=Champs.ChampTexte("",3,11,18,fenettre).valueInfo("hauteur:").visible(true)
                                    else
                                        fond.redessine()
                                        largeur.redessine()
                                        hauteur.redessine()
                                    end
                                end
                                if nom==nil then
                                    nom=Champs.ChampTexte("",3,3,18,fenettre).valueInfo("nom:").visible(true)
                                else
                                    nom.redessine()
                                end
                                fenettre.setCursorPos(3,5)
                                if type=="img" then
                                    fenettre.setBackgroundColor(colors.gray)
                                    fenettre.setTextColor(colors.black)
                                else
                                    fenettre.setBackgroundColor(colors.lightGray)
                                    fenettre.setTextColor(colors.gray)
                                end
                                fenettre.write(" image ")
                                fenettre.setCursorPos(10,5)
                                if type=="prg" then
                                    fenettre.setBackgroundColor(colors.gray)
                                    fenettre.setTextColor(colors.black)
                                else
                                    fenettre.setBackgroundColor(colors.lightGray)
                                    fenettre.setTextColor(colors.gray)
                                end
                                fenettre.write(" Programme ")
                            end
                            while true do
                                aff()
                                event,para1,para2,para3=os.pullEvent()
                                if event=="mouse_click" and para2==math.floor(21+(x-22)/2) and para3==4 then
                                    break
                                elseif event=="mouse_click" and para2>=math.floor((x-22)/2)+2 and para2<=math.floor((x-22)/2)+7 and para3==8 then
                                    type="img"
                                elseif event=="mouse_click" and para2>=math.floor((x-22)/2)+8 and para2<=math.floor((x-22)/2)+19 and para3==8 then
                                    type="prg"
                                elseif event=="mouse_click" and para2>=math.floor((x-22)/2)+3 and para2<=math.floor((x-22)/2)+18 then
                                    if para3==13+3 then
                                        if string.len(nom.valeur())<3 then
                                            erreur("le nom doit fair min 3chars")
                                        else
                                            if type=="prg" then
                                                table.insert(ressources,{nom=nom.valeur(),contenu="--contenu",type="prg"})
                                                Interne.change=true
                                                donnees.ressources=ressources
                                            elseif type=="img" then
                                                local cfond=" "
                                                if fond.valeur()~=nil then
                                                    if string.len(fond.valeur())>1 then
                                                        local couleurs={blanc="0",orange="1",rose="v",bleuClair="3",jaune="4",citron="5",rose="6",gris="7",grisClair="8",cyan="9",violet="a",bleu="b",marron="c",vert="d",rouge="e",noir="f"}
                                                        cfond=couleurs[fond.valeur()]
                                                    else
                                                        cfond=fond.valeur()
                                                    end
                                                end
                                                local lcontenu=""
                                                for i=1,hauteur.valeur() do
                                                    lcontenu=lcontenu..string.rep(cfond,largeur.valeur()).."\n"
                                                end
                                                table.insert(ressources,{nom=nom.valeur(),contenu=lcontenu,type="img",fond=0,x=largeur.valeur(),y=hauteur.valeur()})
                                                Interne.change=true
                                                donnees.ressources=ressources
                                            end
                                        end
                                        break
                                    elseif para3==3+3 then
                                        nom.focus()
                                    end
                                    if type=="img" then
                                        if para3==7+3 then
                                            fond.focus()
                                        elseif para3==9+3 then
                                            largeur.focus()
                                        elseif para3==11+3 then
                                            hauteur.focus()
                                        end
                                    end
                                end
                            end
                        end
                    end
                elseif Interne.change and para2==x-1 and para3==1 then
                    if para1==2 then
                        info("pour enregistrer les modifications")
                    else
                        ltpg.fsEnregistrementData(Interne.urlProjet,donnees)
                        Interne.change=false
                    end
                elseif para2==x and para3==1 then
                    if para1==2 then
                        info("pour retourner à l'accueil")
                    else
                        fermetureProjet()
                        Interne.page="accueil"
                        break
                    end
                <?php if ($debug)
                {
                    ?>elseif event=="key" and para1==74 then
                    continue=false
                    direenrevoir=false
                    sleep(0.01)
                    break<?php
                }?>
                elseif event=="mouse_click" and para2==1 and para3==1 then
                    if para1==2 then
                        info("pour quitter le programme")
                    else
                        fermetureProjet()
                        Interne.page="accueil"
                        continue=false
                        break
                    end
                end
            end
        end
    end
    function Interne.editScene()
        local objets={}
        local selectObjet=0
        local moniteur
        local listePara={}
        local modeAffichage=1
        local play=true
        local tour=0
        for i,v in pairs(donnees.scenes[Interne.scene].objets) do
            table.insert(objets,i,v)
        end
        local function nouveauObjet()
            play=false
            local fenettre=window.create(term.current(),(x-20)/2,5,20,10,true)
            local objetSelect=0
            local premier=1
            local listeType={}
            local listeNom={}
            for i,_ in pairs(effets) do
                table.insert(listeType,effets[i].infos)
                table.insert(listeNom,i)
            end
            local nouveauObjet={}
            nouveauObjet.type=listeNom[Champs.choix(listeType,"nouvel Objet")]
            if type(nouveauObjet.type)~="string" then
                return false
            end
            nouveauObjet.nom="nouvel objet"
            for i,v in pairs(effets[nouveauObjet.type].parametres) do
                nouveauObjet[v.nom]=v.defaut
            end
            table.insert(objets,nouveauObjet)
        end
        local function ActualiseMoniteur()
            term.setCursorPos(x-17,4)
            term.setBackgroundColor(colors.white)
            write("     ")
            term.setCursorPos(x-17,4)
            term.setTextColor(colors.magenta)
            local valeurTour=math.floor(tour*1/tonumber(donnees.scenes[Interne.scene].frequence)*100)/100
            write(valeurTour)
            if Interne.nomMoniteur~="" then
                moniteur=peripheral.wrap(Interne.nomMoniteur)
                moniteur.setTextScale(tonumber(donnees.scenes[Interne.scene].zoom))
                moniteur.setBackgroundColor(tonumber(donnees.scenes[Interne.scene].fond))
                moniteur.clear()
                moniteur.setCursorPos(1,1)
                if modeAffichage==2 and selectObjet>0 then
                    effets[objets[selectObjet].type].dessine(donnees,objets[selectObjet],Interne.nomMoniteur,tour)
                elseif modeAffichage==1 then
                    for i,v in pairs(objets) do
                        if effets[v.type]~=nil and effets[v.type].dessine~=nil then
                            effets[v.type].dessine(donnees,v,Interne.nomMoniteur,tour)
                        end
                    end
                end
            end
        end
        local function editeParaScene()
            local isPlay=play
            play=false
            local fenettre=window.create(term.current(),(x-30)/2,5,30,10,true)
            fenettre.setBackgroundColor(colors.white)
            fenettre.clear()
            fenettre.setTextColor(colors.gray)
            fenettre.setCursorPos(2,3)
            fenettre.write("Couleur Fond:")
            fenettre.setCursorPos(2,4)
            fenettre.write("Zoom [0.5-5]:")
            fenettre.setCursorPos(3,5)
            fenettre.write("duree (sec):")
            fenettre.setCursorPos(5,6)
            fenettre.write("Frequence:")
            fenettre.setCursorPos(5,7)
            fenettre.write("(img/sec)")
            
            fenettre.setCursorPos(1,1)
            fenettre.setBackgroundColor(colors.gray)
            fenettre.clearLine()
            fenettre.setCursorPos(2,1)
            fenettre.setTextColor(colors.lightGray)
            fenettre.write("parametres scene")
            fenettre.setCursorPos(30,1)
            fenettre.setTextColor(colors.red)
            fenettre.write("x")
            local couleurFond=Champs.ChampTexte("",15,3,10,fenettre).valeur(donnees.scenes[Interne.scene].fond).visible(true)
            local zoom=Champs.ChampTexte("",15,4,10,fenettre).valeur(donnees.scenes[Interne.scene].zoom).visible(true)
            local duree=Champs.ChampTexte("",15,5,10,fenettre).valeur(donnees.scenes[Interne.scene].duree).visible(true)
            local frequence=Champs.ChampTexte("",15,6,10,fenettre).valeur(donnees.scenes[Interne.scene].frequence).visible(true)
            Champs.ChampBouton("",6,10,20,fenettre).texte("ok").visible(true)
            while true do
                event,para1,para2,para3=os.pullEvent()
                if event=="key" and para1==28 then
                    break
                elseif event=="mouse_click" then
                    if para2==math.floor((x-30)/2)+29 and para3==5 then
                        return false
                    elseif para2>=math.floor((x-30)/2)+15 and para2<=math.floor((x-30)/2)+23 and para3>=7 and para3<=10 then
                        if para3==7 then
                            local valeur=Champs.couleur("",couleurFond.valeur())
                            if valeur then
                                couleurFond.valeur(valeur)
                            end
                            fenettre.redraw()
                        elseif para3==8 then
                            zoom.focus()
                        elseif para3==9 then
                            duree.focus()
                        elseif para3==10 then
                            frequence.focus()
                        end
                    elseif para2>=math.floor((x-30)/2)+5 and para2<=math.floor((x-20)/2)+19 and para3==14 then
                        break
                    end
                end
            end
            donnees.scenes[Interne.scene].fond=couleurFond.valeur()
            donnees.scenes[Interne.scene].zoom=zoom.valeur()
            donnees.scenes[Interne.scene].duree=duree.valeur()
            donnees.scenes[Interne.scene].frequence=frequence.valeur()
            play=isPlay
            return true
        end
        local function aff()
            Interne.redessine()
            term.setCursorPos((x-12)/2,2)
            term.setTextColor(colors.blue)
            term.write("edition Scene (")
            write(#objets)
            write(")")
            term.setCursorPos(2,2)
            term.setTextColor(colors.gray)
            term.setBackgroundColor(colors.lightBlue)
            write("<- retout")
            term.setCursorPos(x-10,2)   
            write("parametres")
            term.setCursorPos(2,3)
            term.setBackgroundColor(colors.gray)
            term.write(string.rep(" ",20))
            term.setTextColor(colors.black)
            term.setCursorPos(3,3)
            write("Objets")
            local conteur=0
            for i,v in pairs(objets) do
                if conteur<=20 then
                    term.setCursorPos(2,conteur+4)
                    if selectObjet==i then
                        term.setTextColor(colors.gray)
                        term.setBackgroundColor(colors.lightGray)
                    else
                        term.setBackgroundColor(colors.white)
                        term.setTextColor(colors.gray)
                    end
                    term.write(string.rep(" ",20))
                    term.setCursorPos(3,conteur+4)
                    write(v.nom)
                end
                conteur=conteur+1
            end
            if selectObjet==0 or #objets>=15 then
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.gray)
            end
            term.setCursorPos(23,5)
            term.write("d")
            if selectObjet==0 then
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.gray)
            end
            term.setCursorPos(23,6)
            term.write("r")
            term.setCursorPos(23,7)
            term.write("-")
            if #objets>=15 then
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.gray)
            end
            term.setCursorPos(23,8)
            term.write("+")
            if selectObjet<2 then
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.gray)
            end
            term.setCursorPos(23,3)
            term.write("<")
            if selectObjet>=#objets then
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.gray)
            end
            term.setCursorPos(23,4)
            term.write(">")
            if modeAffichage==1 then
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.gray)
            end
            term.setCursorPos(23,10)
            write("t")
            if modeAffichage==2 then
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.gray)
            end
            term.setCursorPos(23,11)
            write("a")
            
            term.setBackgroundColor(colors.gray)
            term.setTextColor(colors.black)
            term.setCursorPos(x-25,3)
            term.write(string.rep(" ",25))
            term.setCursorPos(x-24,3)   
            write("Temps")
            term.setBackgroundColor(colors.white)
            term.setCursorPos(x-25,4)
            term.write(string.rep(" ",25))
            term.setCursorPos(x-22,4)
            term.setBackgroundColor(colors.lightGray)
            term.setCursorPos(x-22,4)
            if play then
                term.setTextColor(colors.white)
                write("j")
                term.setTextColor(colors.black)
                write("p")
            else
                term.setTextColor(colors.black)
                write("j")
                term.setTextColor(colors.white)
                write("p")
                term.setTextColor(colors.black)
            end
            write("r")
            write("<")
            term.setCursorPos(x-3,4)
            write(">")
            term.setBackgroundColor(colors.white)
            term.setCursorPos(x-17,4)
            term.setTextColor(colors.magenta)
            write(tour)
            if tonumber(donnees.scenes[Interne.scene].duree)>0 then
                term.setCursorPos(x-11,4)
                write("/ "..donnees.scenes[Interne.scene].duree)
            end
            
            term.setCursorPos(x-25,6)
            term.setBackgroundColor(colors.gray)
            term.write(string.rep(" ",25))
            term.setTextColor(colors.black)
            term.setCursorPos(x-24,6)   
            write("parametres")
            if selectObjet>0 and effets[objets[selectObjet].type]~=nil then
                term.setBackgroundColor(colors.white)
                listePara=effets[objets[selectObjet].type].parametres
                term.setCursorPos(x-25,7)
                term.write(string.rep(" ",25))
                term.setCursorPos(x-20,7)
                term.setTextColor(colors.gray)
                write("type:")
                write(effets[objets[selectObjet].type].infos)
                for i,v in pairs(listePara) do
                    term.setBackgroundColor(colors.white)
                    term.setCursorPos(x-25,7+i)
                    term.write(string.rep(" ",25))
                    term.setTextColor(colors.gray)
                    term.setCursorPos(x-15-string.len(v.info),7+i)
                    write(v.info)
                    if objets[selectObjet][v.nom]~=nil then
                        if v.type=="image" then
                            term.setTextColor(colors.green)
                            if objets[selectObjet][v.nom]~="" then
                                if donnees.ressources[objets[selectObjet][v.nom]]~=nil then
                                    write(donnees.ressources[objets[selectObjet][v.nom]].nom)
                                end
                            else
                                write("[selectionne]")
                            end
                            term.setTextColor(colors.blue)
                            term.setBackgroundColor(colors.lightGray)
                            term.setCursorPos(x-1,8)
                            write("e")
                        elseif v.type=="couleur" then
                            term.setBackgroundColor(tonumber(objets[selectObjet][v.nom]))
                            write(" ")
                            term.setTextColor(colors.gray)
                            term.setBackgroundColor(colors.lightGray)
                            term.setCursorPos(x-14,7+i)
                            term.write(string.rep(" ",12))
                            term.setCursorPos(x-14,7+i)
                            write(objets[selectObjet][v.nom])
                        elseif v.type=="programme" then
                            term.setTextColor(colors.blue)
                            write(donnees.ressources[tostring(objets[selectObjet][v.nom])].nom)
                         elseif v.type=="liste" then
                            if objets[selectObjet][v.nom]~="" then
                                term.setTextColor(colors.orange)
                                local liste={}
                                for i,v in pairs(objets[selectObjet][v.nom]) do
                                    table.insert(liste,v)
                                end
                                objets[selectObjet][v.nom]=liste
                                if string.sub(v.liste,-1,-1)=="s" and #objets[selectObjet][v.nom]<=1 then
                                    write(#objets[selectObjet][v.nom]..string.sub(v.liste,1,-2))
                                else
                                    write(#objets[selectObjet][v.nom]..v.liste)
                                end
                            end
                            term.setTextColor(colors.blue)
                            term.setBackgroundColor(colors.lightGray)
                            term.setCursorPos(x-1,8)
                            write("e")
                        elseif v.type=="numeric" or v.type=="texte" then
                            term.setTextColor(colors.gray)
                            term.setBackgroundColor(colors.lightGray)
                            term.setCursorPos(x-15,7+i)
                            term.write(string.rep(" ",13))
                            term.setCursorPos(x-15,7+i)
                            write(string.sub(objets[selectObjet][v.nom],1,12))
                        elseif v.type=="boolean" then
                            Champs.ChampCoche("",x-15,7+i).etat(objets[selectObjet][v.nom]).visible(true)
                        else
                            write(objets[selectObjet][v.nom])
                        end
                    else
                        term.setTextColor(colors.red)
                        write("erreur")
                        erreur("fichier corrompu!")
                    end
                end
            end
            if Interne.change then
                term.setCursorPos(x-1,1)
                term.setTextColor(colors.lime)
                term.setBackgroundColor(colors.cyan)
                term.write("s")
            end
            return true
        end
        
        local function change()
            donnees.scenes[Interne.scene].objets=objets
            Interne.change=true
            aff()
        end
        local function fermetureProjet()
            if Interne.change then
                if Champs.confirm("Enregistrer?") then
                    ltpg.fsEnregistrementData(Interne.urlProjet,donnees)
                    Interne.change=false
                end
            end
            donnees=nil
            Interne.change=false
            Interne.urlProjet=nil
        end
        aff()
        parallel.waitForAny(function()
            while true do
                local event,para1,para2,para3=os.pullEvent()
                if event=="monitor_touch" and selectObjet>0 and para1==Interne.nomMoniteur and objets[selectObjet].x~=nil and objets[selectObjet].y~=nil then
                    objets[selectObjet].x=para2
                    objets[selectObjet].y=para3
                    ActualiseMoniteur()
                    change()
                end
                if event=="mouse_click" and para2>=x-15 and para2<=x-1 and para3>7 and para3<=#listePara+7 then
                    if listePara[para3-7].type=="image" or listePara[para3-7].type=="programme" then
                        if para2==x-1 then
                            local res={}
                            local images={}
                            local numActuel=0
                            for i,v in pairs(donnees.ressources) do
                                if (v.type=="img" and listePara[para3-7].type=="image") or (listePara[para3-7].type=="programme" and v.type=="prg") then
                                    table.insert(res,v.nom)
                                    table.insert(images,i)
                                end
                                if i==objets[selectObjet][listePara[para3-7].nom] then
                                    numActuel=#res
                                end
                            end
                            local num=Champs.choix(res,"Choisir une ressource",numActuel)
                            if num then
                                objets[selectObjet][listePara[para3-7].nom]=images[num]
                                change()
                            end
                        end
                    elseif listePara[para3-7].type=="liste" then
                        if para2==x-1 then
                            if listePara[para3-7].liste=="images" then
                                local res={}
                                for i,v in pairs(donnees.ressources) do
                                    if v.type=="img" then
                                        table.insert(res,v.nom)
                                    end
                                end
                                local retour=Champs.choixOrdonne(res,"Choisir une ressource",objets[selectObjet][listePara[para3-7].nom])
                                if retour then
                                    local numImages={}
                                    for i,v in pairs(retour) do
                                        for ii,vv in pairs(donnees.ressources) do
                                            if vv.nom==v then
                                                table.insert(numImages,ii)
                                                break
                                            end
                                        end
                                    end
                                    objets[selectObjet][listePara[para3-7].nom]=numImages
                                    change()
                                end
                            end
                        end
                    elseif listePara[para3-7].type=="texte" then
                        play=false
                        local retour=Champs.prompt("texte:",objets[selectObjet][listePara[para3-7].nom],40)
                        if string.len(retour)>0 then
                            objets[selectObjet][listePara[para3-7].nom]=retour
                            change()
                        end
                    elseif listePara[para3-7].type=="couleur" then
                        play=false
                        local retour=Champs.couleur("couleur",tonumber(objets[selectObjet][listePara[para3-7].nom]))
                        if retour then
                            objets[selectObjet][listePara[para3-7].nom]=retour
                            change()
                        end
                    elseif listePara[para3-7].type=="numeric" then
                        play=false
                        local retour=Champs.ChampTexte("",x-15,para3,13).valeur(objets[selectObjet][listePara[para3-7].nom]).focus().valeur()
                        if string.len(retour)>0 then
                            objets[selectObjet][listePara[para3-7].nom]=tonumber(retour)
                            change()
                        end
                    elseif listePara[para3-7].type=="boolean" then
                        if objets[selectObjet][listePara[para3-7].nom]==true then
                            objets[selectObjet][listePara[para3-7].nom]=false
                        else
                            objets[selectObjet][listePara[para3-7].nom]=true
                        end
                        change()
                    end
                    ActualiseMoniteur()
                    aff()
                end    
                if event=="mouse_click" and para2>=2 and para2<=10 and para3==2 then
                    if para1==2 then
                        info("retourner a la gestion de projet")
                        aff()
                    else
                        Interne.page="editProjet"
                        break
                    end
                elseif event=="mouse_click" and para2>=x-10 and para2<=x-2 and para3==2 then
                    if para1==2 then
                        info("Editer les parametres de la scene")
                        aff()
                    else
                        if editeParaScene() then
                            change()
                            ActualiseMoniteur()
                        end
                        aff()
                    end
                elseif event=="mouse_click" and para2>=2 and para2<=21 and para3-3<=#objets and para3>3 then
                    if para1==2 then
                        info("selectionner un objet")
                        aff()
                    else
                        selectObjet=para3-3
                        ActualiseMoniteur()
                        change()
                    end
                elseif event=="mouse_click" and Interne.change and para2==x-1 and para3==1 then
                    if para1==2 then
                        info("pour enregistrer les modifications")
                        aff()
                    else
                        ltpg.fsEnregistrementData(Interne.urlProjet,donnees)
                        Interne.change=false
                        aff()
                    end
                elseif event=="mouse_click" and para2==x and para3==1 then
                    if para1==2 then
                        info("pour retourner à l'accueil")
                        aff()
                    else
                        fermetureProjet()
                        Interne.page="accueil"
                        break
                    end
                elseif event=="mouse_click" and selectObjet>0 and para2==23 and para3==3 and selectObjet>1 then
                    if para1==2 then
                        info("monter l'objet")
                        aff()
                    else
                        local donnees={}
                        for i,v in pairs(objets[selectObjet-1]) do
                            donnees[i]=v
                        end
                        objets[selectObjet-1]=objets[selectObjet]
                        objets[selectObjet]=donnees
                        selectObjet=selectObjet-1
                        change()
                    end
                elseif event=="mouse_click" and selectObjet>0 and para2==23 and para3==4 and selectObjet<#objets then
                    if para1==2 then
                        info("descendre l'objet")
                        aff()
                    else
                        local donnees={}
                        for i,v in pairs(objets[selectObjet+1]) do
                            donnees[i]=v
                        end
                        objets[selectObjet+1]=objets[selectObjet]
                        objets[selectObjet]=donnees
                        selectObjet=selectObjet+1
                        change()
                    end
                elseif event=="mouse_click" and selectObjet>0 and para2==23 and para3==5 then
                    if para1==2 then
                        info("dupliquer l'Objet")
                        aff()
                    else
                        local nouvelObjet={}
                        nouvelObjet.type=objets[selectObjet].type
                        nouvelObjet.nom="copie"
                        for i,v in pairs(listePara) do
                            nouvelObjet[v.nom]=objets[selectObjet][v.nom]
                        end
                        table.insert(objets,selectObjet+1,nouvelObjet)
                        selectObjet=#objets
                        change()
                    end
                elseif event=="mouse_click" and selectObjet>0 and para2==23 and para3==6 then
                    if para1==2 then
                        info("Renommer l'objet")
                        aff()
                    else
                        objets[selectObjet].nom=Champs.prompt("Nom:",objets[selectObjet].nom)
                        change()
                    end
                elseif event=="mouse_click" and para2==23 and para3==7 and selectObjet>0 then
                    if para1==2 then
                        info("supprimer L'objet selectionne")
                        aff()
                    else
                        table.remove(objets,selectObjet)
                        if selectObjet>#objets then
                            selectObjet=selectObjet-1
                        end
                        ActualiseMoniteur()
                        change()
                    end
                elseif event=="mouse_click" and para2==23 and para3==8 then
                    if para1==2 then
                        info("Nouvel objet")
                        aff()
                    else
                        nouveauObjet()
                        selectObjet=#objets
                        ActualiseMoniteur()
                        change()
                    end
                elseif event=="mouse_click" and para2==23 and para3==10 then
                    if para1==2 then
                        info("Apercu de tout les objets")
                    elseif modeAffichage~=1 then
                        modeAffichage=1
                        ActualiseMoniteur()
                    end
                    aff()
                elseif event=="mouse_click" and para2==23 and para3==11 then
                    if para1==2 then
                        info("Apercu de l'objet select")
                    elseif modeAffichage~=2 then
                        modeAffichage=2
                        ActualiseMoniteur()
                    end
                    aff()
                elseif event=="mouse_click" and para2==x-22 and para3==4 then
                    if play==true or para1==2 or modeAffichage==2 then
                        info("Jouer la scene")
                    else
                        play=true
                    end
                    aff()
                elseif event=="mouse_click" and para2==x-21 and para3==4 then
                    if play==false or para1==2 or modeAffichage==2 then
                        info("mettre en pause la scene")
                    else
                        play=false
                    end
                    aff()
                elseif event=="mouse_click" and para2==x-20 and para3==4 then
                    if para1==2 then
                        info("jouer la scene au debut")
                    elseif modeAffichage~=2 then
                        tour=1
                        ActualiseMoniteur()
                    end
                    aff()
                elseif event=="mouse_click" and para2==x-19 and para3==4 then
                    if para1==2 then
                        info("reculer le temps")
                    elseif modeAffichage~=2 then
                        tour=tour-1/tonumber(donnees.scenes[Interne.scene].frequence)
                        if tour<=0 then
                            tour=1
                        end
                        ActualiseMoniteur()
                    end
                    aff()
                elseif event=="mouse_click" and para2==x-3 and para3==4 then
                    if para1==2 then
                        info("Avancer le temps")
                    elseif modeAffichage~=2 then
                        tour=tour+1/tonumber(donnees.scenes[Interne.scene].frequence)
                        if tonumber(donnees.scenes[Interne.scene].duree)<=tour then
                            tour=tonumber(donnees.scenes[Interne.scene].duree)
                        end
                        ActualiseMoniteur()
                    end
                    aff()
                <?php if ($debug)
                {
                    ?>elseif event=="key" and para1==74 then
                    continue=false
                    direenrevoir=false
                    sleep(0.01)
                    break<?php
                }?>
                elseif event=="mouse_click" and para2==1 and para3==1 then
                    if para1==2 then
                        info("pour quitter le programme")
                        aff()
                    else
                        fermetureProjet()
                        Interne.page="accueil"
                        continue=false
                        break
                    end
                end
            end
        end,function()
            ActualiseMoniteur()
            while true do
                sleep(1/tonumber(donnees.scenes[Interne.scene].frequence))
                if play then
                    if tonumber(donnees.scenes[Interne.scene].duree)==0 then
                        tour=tour+1
                    elseif tonumber(donnees.scenes[Interne.scene].duree)*tonumber(donnees.scenes[Interne.scene].frequence)<=tour then
                        tour=1
                    else
                        tour=tour+1
                    end
                    ActualiseMoniteur()
                end
            end
        end)
    end
    function Interne.renduProjet()
        if Interne.nomMoniteur and peripheral.isPresent(Interne.nomMoniteur)==false then
            Interne.nomMoniteur=""
        end
        if donnees==nil then
            donnees=ltpg.fsTraitementData(Interne.urlProjet)
            Interne.largeur=donnees.largeur
            Interne.hauteur=donnees.hauteur
            if donnees.moniteur~=nil then
                Interne.nomMoniteur=donnees.moniteur
            end
        end
        local selectScene=1
        local tour=0
        local totalTemps=5
        local temps=0
        local play=true
        local pjdef=false
        do
            local parametres=ltpg.fsTraitementData("recent")
            if parametres.autoProjet==Interne.urlProjet then
                pjdef=true
            end
        end
        local infos={"chargement..."}
        local function affInfos()
            term.setBackgroundColor(colors.white)
            term.setTextColor(colors.black)
            for i=1,6 do
                term.setCursorPos(28,i+6)
                term.write(string.rep(" ",21))
                term.setCursorPos(28,i+6)
                if #infos>6 then
                    write(string.sub(infos[#infos-6+i],1,21))
                elseif i<=#infos then
                    write(string.sub(infos[i],1,21))
                end
            end
        end            
        local function affBarre()
            affInfos()
            term.setCursorPos(5,y-1)
            term.setBackgroundColor(colors.lightGray)
            write(string.rep(" ",43))
            term.setCursorPos(6,y-1)
            if selectScene>1 then
                term.setTextColor(colors.white)
            else
                term.setTextColor(colors.gray)
            end
            write("<")
            term.setBackgroundColor(colors.green)
            write(string.rep(" ",20))
            term.setTextColor(colors.gray)
            if selectScene>0 then
                term.setCursorPos((18-string.len(donnees.scenes[selectScene].nom))/2+7,y-1)
                write("["..donnees.scenes[selectScene].nom.."]")
            end
            term.setCursorPos(33,y-1)
            term.setBackgroundColor(colors.magenta)
            write(string.rep(" ",13))
            term.setCursorPos((13-string.len(temps.."/"..totalTemps))/2+33,y-1)
            write(temps.."/"..totalTemps)
            term.setBackgroundColor(colors.lightGray)
            term.setCursorPos(46,y-1)
            if temps<totalTemps then
                term.setTextColor(colors.white)
            else
                term.setTextColor(colors.gray)
            end
            write(">")
            term.setCursorPos(27,y-1)
            if selectScene<#donnees.scenes then
                term.setTextColor(colors.white)
            else
                term.setTextColor(colors.gray)
            end
            write(">")
            if play==false then
                term.setTextColor(colors.white)
                write("j")
                term.setTextColor(colors.gray)
                write("p")
            else
                term.setTextColor(colors.gray)
                write("j")
                term.setTextColor(colors.white)
                write("p")
            end
            if temps>0 then
                term.setTextColor(colors.white)
            else
                term.setTextColor(colors.gray)
            end
            write("r <")
        end
        local function aff()
            totalTemps=tonumber(donnees.scenes[selectScene].duree)
            if totalTemps==nil then totalTemps=0 end
            Interne.redessine()
            --[[term.setCursorPos((x-6)/2,3)
            term.setTextColor(colors.blue)
            term.write("Projet")]]
            term.setTextColor(colors.gray)
            term.setBackgroundColor(colors.lightBlue)
            term.setCursorPos(4,2)
            write("scenes")
            term.setCursorPos(29,6)
            write("infos")
            term.setCursorPos(11,2)
            term.setTextColor(colors.gray)
            term.setBackgroundColor(colors.lightBlue)
            if selectScene>0 then
                write("("..selectScene.."/"..#donnees.scenes..")")
            else
                write("("..#donnees.scenes..") ")
            end
            Champs.ChampBouton("",28,3,21).texte("edition projet").visible(true)
            Champs.ChampBouton("",28,4,21).texte("moniteurs").visible(true)
            Champs.ChampCoche("",28,14).description("projet par defaut").couleurFond(colors.lightBlue).etat(pjdef).visible(true)
            for i,v in pairs(donnees.scenes) do
                if selectScene==i then
                    term.setCursorPos(2,i+2)
                    term.setTextColor(colors.white)
                    term.setBackgroundColor(colors.green)
                    write(">")
                else
                    term.setTextColor(colors.black)
                end
                term.setCursorPos(3,i+2)
                if selectScene==i then
                    term.setBackgroundColor(colors.gray)
                else
                    term.setBackgroundColor(colors.lightGray)
                end
                term.write(string.rep(" ",20))
                term.setCursorPos(4,i+2)
                write(v.nom)
            end
            affBarre()
        end
        local function ActualiseMoniteur()
            if peripheral.isPresent(Interne.nomMoniteur)==false then
                Interne.nomMoniteur=""
                return
            end
            temps=math.floor(tour*1/tonumber(donnees.scenes[selectScene].frequence)*100)/100
            affBarre()
            if Interne.nomMoniteur~="" or donnees.nomListeMoniteur~=nil then
                if donnees.nomListeMoniteur==nil or #donnees.nomListeMoniteur==0 then
                    donnees.nomListeMoniteur={Interne.nomMoniteur}
                end
                for _,vv in pairs(donnees.nomListeMoniteur) do
                    moniteur=peripheral.wrap(vv)
                    if moniteur then
                        moniteur.setTextScale(tonumber(donnees.scenes[selectScene].zoom))
                        moniteur.setBackgroundColor(tonumber(donnees.scenes[selectScene].fond))
                        moniteur.clear()
                        moniteur.setCursorPos(1,1)
                    end
                    for i,v in pairs(donnees.scenes[selectScene].objets) do
                        if effets[v.type]~=nil and effets[v.type].dessine~=nil then
                            if peripheral.isPresent(vv) then
                                effets[v.type].dessine(donnees,v,vv,tour)
                            end
                        end
                    end
                end
                
                --[[for _,v in pairs(donnees.nomListeMoniteur) do
                    moniteur=peripheral.wrap(v)
                    if moniteur then
                        moniteur.setTextScale(tonumber(donnees.scenes[selectScene].zoom))
                        moniteur.setBackgroundColor(tonumber(donnees.scenes[selectScene].fond))
                        moniteur.clear()
                        moniteur.setCursorPos(1,1)
                    end
                end
                for i,v in pairs(donnees.scenes[selectScene].objets) do
                    if effets[v.type]~=nil and effets[v.type].dessine~=nil then
                        for _,vv in pairs(donnees.nomListeMoniteur) do
                            if peripheral.isPresent(vv) then
                                effets[v.type].dessine(donnees,v,vv,tour)
                            end
                        end
                    end
                end]]
            end
        end
        temps=math.floor(tour*1/tonumber(donnees.scenes[selectScene].frequence)*100)/100
        totalTemps=tonumber(donnees.scenes[selectScene].duree)
        aff()
        ActualiseMoniteur()
        parallel.waitForAny(function()
            ActualiseMoniteur()
            while true do
                sleep(1/tonumber(donnees.scenes[selectScene].frequence))
                if play then
                    if tonumber(donnees.scenes[selectScene].duree)==0 then
                        tour=tour+1
                    elseif tonumber(donnees.scenes[selectScene].duree)*tonumber(donnees.scenes[selectScene].frequence)<=tour then
                        tour=0
                        selectScene=selectScene+1
                        if #donnees.scenes<selectScene then
                            selectScene=1
                        end
                        table.insert(infos,"scene ["..donnees.scenes[selectScene].nom.."]")
                        aff()
                    else
                        tour=tour+1
                    end 
                    ActualiseMoniteur()
                end
            end
        end,function()
            while true do
                event,para1,para2,para3=os.pullEvent()
                if event=="mouse_click" and para2>=3 and para2<=23 and para3>=3 and para3<=#donnees.scenes+2 then
                    table.insert(infos,"scene ["..donnees.scenes[selectScene].nom.."]")
                    selectScene=para3-2
                    tour=0
                    aff()
                elseif event=="mouse_click" and para2==28 and para3==14 then
                    if pjdef==true then
                        local parametres=ltpg.fsTraitementData("recent")
                        parametres.autoProjet=false
                        ltpg.fsEnregistrementData("recent",parametres)
                        pjdef=false
                    else
                        local parametres=ltpg.fsTraitementData("recent")
                        parametres.autoProjet=Interne.urlProjet
                        ltpg.fsEnregistrementData("recent",parametres)
                        pjdef=true
                    end
                    aff()
                elseif event=="mouse_click" and para2>=28 and para2<=48 and para3==3 then
                    Interne.page="editProjet"
                    for _,v in pairs(donnees.nomListeMoniteur) do
                        if peripheral.isPresent(v) then
                            moniteur=peripheral.wrap(v)
                            moniteur.setTextScale(1)
                            moniteur.setBackgroundColor(32768)
                            moniteur.clear()
                            moniteur.setCursorPos(1,1)
                        end
                    end
                    break
                elseif event=="mouse_click" and para2>=28 and para2<=48 and para3==4 then
                    play=false
                    choixMoniteur(true)
                    ltpg.fsEnregistrementData(Interne.urlProjet,donnees)
                    aff()
                elseif event=="mouse_click" and para2==6 and para3==y-1 and selectScene>1 then
                    table.insert(infos,"scene ["..donnees.scenes[selectScene].nom.."]")
                    selectScene=selectScene-1
                    tour=0
                    aff()
                elseif event=="mouse_click" and para2==27 and para3==y-1 and selectScene<#donnees.scenes then
                    table.insert(infos,"scene ["..donnees.scenes[selectScene].nom.."]")
                    selectScene=selectScene+1
                    tour=0
                    aff()
                elseif event=="mouse_click" and para2==28 and para3==y-1 and play==false then
                    table.insert(infos,"play")
                    play=true
                    aff()
                elseif event=="mouse_click" and para2==29 and para3==y-1 and play then
                    table.insert(infos,"pause")
                    play=false
                    aff()
                elseif event=="mouse_click" and para2==30 and para3==y-1 and temps>0 then
                    tour=0
                    aff()
                elseif event=="mouse_click" and para2==32 and para3==y-1 and temps>0 then
                    tour=tour-1
                    aff() 
                elseif event=="mouse_click" and para2==46 and para3==y-1 and temps<totalTemps then
                    tour=tour+1
                    aff()                
                <?php if ($debug)
                {
                    ?>elseif event=="key" and para1==74 then
                    continue=false
                    direenrevoir=false
                    sleep(0.01)
                    break<?php
                }?>
                elseif event=="mouse_click" and para2==x and para3==1 then
                    if para1==2 then
                        info("pour retourner à l'accueil")
                        aff()
                    else
                        Interne.page="accueil"
                        break
                    end
                elseif event=="mouse_click" and para2==1 and para3==1 then
                    if para1==2 then
                        info("pour quitter le programme")
                        aff()
                    else
                        Interne.page="accueil"
                        continue=false
                        break
                    end
                end
            end
        end)
    end
end
do
    local ChampUrl
    local ChampLargeur
    local ChampHauteur
    local ChampAnnuler
    local ChampValider
    local focus
    local infos={}
    function Interne.nouveau()
        Interne.redessine()
        term.setCursorPos((x-6)/2,3)
        term.setTextColor(colors.blue)
        term.write("Nouveau")
        
        local continuer=true
        local function quandModifie()
            if string.len(ChampUrl.valeur())>=3 then
                ChampValider.statut(true)
            else
                ChampValider.statut(false)
            end            
        end
        local function quandFini(bouton)
            if bouton=="entre" and ChampValider.statut()==true then
                ChampValider.quandValide()()
            end
        end
        ChampUrl=Champs.ChampTexte("url",3,5,21).valueInfo("Url:").visible(true).quandModifie(quandModifie).quandFini(quandFini)
        ChampLargeur=Champs.ChampTexte("largeur",3,7,10).valueInfo("Largeur:").visible(true).quandModifie(quandModifie).quandFini(quandFini)
        ChampHauteur=Champs.ChampTexte("hauteur",14,7,10).valueInfo("Hauteur:").visible(true).quandModifie(quandModifie).quandFini(quandFini)
        ChampAnnuler=Champs.ChampBouton("annuler",3,9,10).texte("annuler").visible(true).quandValide(function() continuer=false end)
        ChampValider=Champs.ChampBouton("valider",14,9,10).texte("valider").statut(false).visible(true).quandValide(function()
            local donnees={}
            donnees.enTete="Fichier Projet fluomort"
            donnees.id=os.getComputerID()
            donnees.largeur=tonumber(ChampLargeur.valeur())
            donnees.hauteur=tonumber(ChampHauteur.valeur())
            donnees.scenes={}
            donnees.ressources={}
            ltpg.fsEnregistrementData(ChampUrl.valeur(),donnees)
            local fichiersRecent=ltpg.fsTraitementData("recent")
            table.insert(fichiersRecent.recent,1,ChampUrl.valeur())
            ltpg.fsEnregistrementData("recent",fichiersRecent)
            continuer=false
            end)
        focus=1
        
        parallel.waitForAny(Interne.boutonsBarre, function()
            while continuer do
                if focus==2 then
                    ChampLargeur.focus()
                    focus=focus+1
                elseif focus==3 then
                    ChampHauteur.focus()
                    focus=focus+1
                elseif focus==4 then
                    ChampAnnuler.focus()
                    focus=focus+1
                elseif focus==5 then
                    ChampValider.focus()
                    focus=1
                else
                    ChampUrl.focus()
                    focus=2
                end
            end
            Interne.page="accueil"
        end)
    end
end
while true do
    if Interne.page=="accueil" then
        if Interne.nomMoniteur~="" then
            if peripheral.getType(Interne.nomMoniteur)~="monitor" then
                Interne.nomMoniteur=""
            else
                local moniteur=peripheral.wrap(Interne.nomMoniteur)
                local larg,haut=moniteur.getSize()
                moniteur.setTextScale(1)
                moniteur.setBackgroundColor(colors.black)
                moniteur.clear()
            end
        end
        Interne.accueil()
    elseif Interne.page=="editProjet" then
        Interne.editProjet()
    elseif Interne.page=="renduProjet" then
        Interne.renduProjet()
    elseif Interne.page=="nouveau" then
        Interne.nouveau()
    elseif Interne.page=="resourcesProjet" then
        Interne.resourcesProjet()
    elseif Interne.page=="editScene" then
        Interne.editScene()
    end
    if not continue then
        break
    end
end
if direenrevoir then
    Champs.alerte("Ded@le")
end
if Interne.nomMoniteur~="" then
    if peripheral.getType(Interne.nomMoniteur)~="monitor" then
        Interne.nomMoniteur=""
    else
        local moniteur=peripheral.wrap(Interne.nomMoniteur)
        local larg,haut=moniteur.getSize()
        moniteur.setTextScale(1)
        moniteur.setBackgroundColor(colors.black)
        moniteur.clear()
    end
end
term.setBackgroundColor(32768)
term.clear()
term.setCursorPos(1,1)
