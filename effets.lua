effets={}
effets.image={}
effets.image.parametres={{type="image",info="image:",nom="image",defaut=""},{type="numeric",info="Xpos:",nom="x",defaut=1},{nom="y",info="Ypos:",type="numeric",defaut=1}}
effets.image.infos="Fixed image"
function effets.image.dessine(donnees,contenu,moniteur,_)
    if contenu.image=="" then
        return
    end
    if donnees.ressources[contenu.image]==nil then
        return
    end
    local image=tostring(donnees.ressources[contenu.image].contenu)
    local couleurs={c0=1,c1=2,c2=4,c3=8,c4=16,c5=32,c6=64,c7=128,c8=256,c9=512,ca=1024,cb=2048,cc=4096,cd=8192,ce=16384,cf=32768}
    local ecran=peripheral.wrap(moniteur)
    local ligne=0
    local numChar=0
    ecran.setCursorPos(contenu.x,contenu.y)
    for i=1,string.len(image) do
        char=string.sub(image,i,i)
        if couleurs["c"..char]~=nil then
            ecran.setCursorPos(contenu.x+numChar,contenu.y+ligne)
            ecran.setBackgroundColor(couleurs["c"..char])
            ecran.write(" ")
            numChar=numChar+1
        elseif char=="\n" then
            ligne=ligne+1
            numChar=0
        elseif char==" " then
            numChar=numChar+1
        end
    end
end

effets.imageAnnim={}
effets.imageAnnim.parametres={{type="liste",liste="images",info="images:",nom="images",defaut={}},{type="numeric",info="Xpos:",nom="x",defaut=1},{nom="y",info="Ypos:",type="numeric",defaut=1}}
effets.imageAnnim.infos="Moving pictures"
function effets.imageAnnim.dessine(donnees,contenu,moniteur,tour)
    if #contenu.images<1 then
        return
    end
    local ecran=peripheral.wrap(moniteur)
    if contenu.vitesse==nil or contenu.vitesse=="" then contenu.vitesse=1 end
    
    tour=tour*contenu.vitesse
    local numImage
    if tour<=#contenu.images then
        numImage=tour
    else
        local total=math.floor(tour/#contenu.images)
        numImage=tour-total*#contenu.images+1
    end
    if donnees.ressources[contenu.images[numImage]]==nil then
        return
    end
    local image=tostring(donnees.ressources[contenu.images[numImage]].contenu)
    local couleurs={c0=1,c1=2,c2=4,c3=8,c4=16,c5=32,c6=64,c7=128,c8=256,c9=512,ca=1024,cb=2048,cc=4096,cd=8192,ce=16384,cf=32768}
    local ligne=0
    local numChar=0
    ecran.setCursorPos(contenu.x,contenu.y)
    for i=1,string.len(image) do
        char=string.sub(image,i,i)
        if couleurs["c"..char]~=nil then
            ecran.setCursorPos(contenu.x+numChar,contenu.y+ligne)
            ecran.setBackgroundColor(couleurs["c"..char])
            ecran.write(" ")
            numChar=numChar+1
        elseif char=="\n" then
            ligne=ligne+1
            numChar=0
        elseif char==" " then
            numChar=numChar+1
        end
    end
end

effets.texte={}
effets.texte.parametres={{type="couleur",info="Tcolor:",nom="couleur",defaut=1},{type="couleur",info="Bcolor:",nom="fond",defaut=1},{type="texte",info="text:",nom="texte",defaut=""},{type="numeric",info="Xpos:",nom="x",defaut=1},{nom="y",info="Ypos:",type="numeric",defaut=1}}
function effets.texte.dessine(_,contenu,moniteur,_)
    local couleurs={c0=1,c1=2,c2=4,c3=8,c4=16,c5=32,c6=64,c7=128,c8=256,c9=512,ca=1024,cb=2048,cc=4096,cd=8192,ce=16384,cf=32768}
    local ecran=peripheral.wrap(moniteur)
    local ligne=0
    local numChar=0
    ecran.setTextColor(tonumber(contenu.couleur))
    ecran.setBackgroundColor(tonumber(contenu.fond))
    ecran.setCursorPos(contenu.x,contenu.y)
    ecran.write(contenu.texte)
end
effets.texte.infos="texte fixe"

effets.texteMouv={}
effets.texteMouv.parametres={{type="couleur",info="Tcolor:",nom="couleur",defaut=1},{type="couleur",info="Bcolor:",nom="fond",defaut=1},{type="texte",info="text:",nom="texte",defaut=""},{type="numeric",info="Xpos:",nom="x",defaut=1},{nom="y",info="Ypos:",type="numeric",defaut=1},{type="numeric",info="width:",nom="largeur",defaut=5},{nom="vitesse",info="speed:",type="texte",defaut=1},{type="boolean",info="oppDirec:",nom="sensInv",defaut=1}}
function effets.texteMouv.dessine(_,contenu,moniteur,tour)
    local ecran=peripheral.wrap(moniteur)
    if contenu.vitesse==nil or contenu.vitesse=="" then contenu.vitesse=1 end
    tour=tour*contenu.vitesse
    
    ecran.setCursorPos(contenu.x-8,contenu.y)
    if tour<=string.len(contenu.texte)*2-1 then
        position=tour+1
    else
        local total=math.floor(tour/(string.len(contenu.texte)*2-1))
        position=tour-total*(string.len(contenu.texte)*2-1)+1
    end
    
    ecran.setTextColor(tonumber(contenu.couleur))
    ecran.setBackgroundColor(tonumber(contenu.fond))
    if position<=string.len(contenu.texte) then
        if contenu.sensInv then
            ecran.setCursorPos(contenu.x+position,contenu.y)
            ecran.write(string.sub(contenu.texte,1,string.len(contenu.texte)-position+1))
        else
            ecran.setCursorPos(contenu.x,contenu.y)
            ecran.write(string.sub(contenu.texte,position,-1))
        end
    else
        if contenu.sensInv then
            ecran.setCursorPos(contenu.x,contenu.y)
            ecran.write(string.sub(contenu.texte,-(position-string.len(contenu.texte)),-1))
        else
            ecran.setCursorPos(contenu.x+string.len(contenu.texte)*2-position,contenu.y)
            ecran.write(string.sub(contenu.texte,1,position-string.len(contenu.texte)))
        end
    end
end
effets.texteMouv.infos="scrolling text"

--[[effets.texteClini={}
effets.texteClini.parametres={{type="couleur",info="tColor:",nom="color",defaut=1},{type="couleur",info="bColor:",nom="background",defaut=1},{type="texte",info="text:",nom="text",defaut=""},{type="numeric",info="xpos:",nom="x",defaut=1},{nom="y",info="ypos:",type="numeric",defaut=1},{type="numeric",info="speed:",nom="speed",defaut=1}}
function effets.texteClini.dessine(_,contenu,moniteur,tour)
    local couleurs={c0=1,c1=2,c2=4,c3=8,c4=16,c5=32,c6=64,c7=128,c8=256,c9=512,ca=1024,cb=2048,cc=4096,cd=8192,ce=16384,cf=32768}
    local ecran=peripheral.wrap(moniteur)
    local ligne=0
    local numChar=0
    ecran.setTextColor(tonumber(contenu.couleur))
    ecran.setBackgroundColor(tonumber(contenu.fond))
    ecran.setCursorPos(contenu.x,contenu.y)
    ecran.write(contenu.texte)
end
effets.texteClini.infos="texte cliniottant"]]

effets.date={}
effets.date.parametres={{type="couleur",info="Tcolor:",nom="couleur",defaut=16384},{type="couleur",info="Bcolor:",nom="fond",defaut=1},{type="texte",info="pattern:",nom="forme",defaut="#J-#H:#m"},{type="numeric",info="Xpos:",nom="x",defaut=1},{nom="y",info="Ypos:",type="numeric",defaut=1}}
function effets.date.dessine(_,contenu,moniteur,_)
    local temps=os.time()
    local jour=os.day()
    local heure24=math.floor(temps)
    local matinApresMidi="Am"
    local heure12=heure24
    local minutes=math.floor((temps - heure24)*60)
    local semaine=math.ceil(jour/7)
    local jourSemaine=jour-semaine*7
    if jour >= 12 then
        matinApresMidi = "PM"
    end
    if heure12 >= 13 then
        heure12 = heure12 - 12
    end
    local texte=contenu.forme
    texte=string.gsub(texte,"#t",temps)
    texte=string.gsub(texte,"#J",jour)
    texte=string.gsub(texte,"#j",jourSemaine)
    texte=string.gsub(texte,"#H",heure24)
    texte=string.gsub(texte,"#h",heure12)
    texte=string.gsub(texte,"#m",minutes)
    texte=string.gsub(texte,"#f",matinApresMidi)
    texte=string.gsub(texte,"#s",semaine)
    
    local couleurs={c0=1,c1=2,c2=4,c3=8,c4=16,c5=32,c6=64,c7=128,c8=256,c9=512,ca=1024,cb=2048,cc=4096,cd=8192,ce=16384,cf=32768}
    local ecran=peripheral.wrap(moniteur)
    local ligne=0
    local numChar=0
    ecran.setTextColor(tonumber(contenu.couleur))
    ecran.setBackgroundColor(tonumber(contenu.fond))
    ecran.setCursorPos(contenu.x,contenu.y)
    ecran.write(texte)
end
effets.date.infos="date/hour"

effets.conteur={}
effets.conteur.parametres={{type="numeric",info="Xpos:",nom="x",defaut=1},{nom="y",info="Ypos:",type="numeric",defaut=1},{type="couleur",info="Tcolor:",nom="couleur",defaut=32768},{type="couleur",info="Bcolor:",nom="fond",defaut=1},{type="numeric",info="start:",nom="depart",defaut=1},{type="numeric",info="end:",nom="arrivee",defaut=100},{type="numeric",info="speed:",nom="vitesse",defaut=1}}
function effets.conteur.dessine(_,contenu,moniteur,tour)
    donnees=tour*contenu.vitesse-contenu.depart+1
    if tour*contenu.vitesse<contenu.depart then
        return
    end
    if tour*contenu.vitesse>contenu.arrivee then
        return
    end
    local ecran=peripheral.wrap(moniteur)
    ecran.setTextColor(tonumber(contenu.couleur))
    ecran.setBackgroundColor(tonumber(contenu.fond))
    ecran.setCursorPos(contenu.x,contenu.y)
    ecran.write(donnees)
end
effets.conteur.infos="Counter/Chrono"