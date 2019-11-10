const Discord = require('discord.js');
const fs = require("fs");
const glob = require ("glob")
const PathFoldersObject = "./Objet";
const Prefix='!';
const PathDeckListe= "Deck-Liste";
const bot = new Discord.Client();

bot.login(process.env.PremierPointTcgNon);

bot.on('ready',function(){
    bot.user.setGame("Aide : "+Prefix+"gh");
})



//--------------- Help ---------------------------
bot.on('message', message => {
    var splitMessage = message.content.split(" ");
    if( (splitMessage[0] === Prefix+"gh") ){
        if(splitMessage.length === 1){
            message.author.sendMessage(
                '\n'+
                "----------------------------------------------------------------------"+'\n'+'\n'
                
                +"!gbot -i          		=> info bot"+'\n'
                +"-----------------------------------------------------"+'\n'+'\n'
                
                +"!idtcg @user / !Idtcg @user	=> indique le pseudo in game d'un membre"+'\n'
                +"-----------------------------------------------------"+'\n'+'\n'
                
                +"!liste Format NomDeck/NomPoke	=> Permet de trouver une deck liste dans le Github PkmTCGO-fr"+'\n'+'\n'
                
                +"Exemple : !liste 2019 Ciza  ou  !liste Etendu ZoroarkMiasmax"+'\n'
                +"-----------------------------------------------------"+'\n'+'\n'+'\n'
                
                
                +"!tournoi -s       		=> lancer un Tournoi"+'\n'
                +"!tournoi -r       		=> s'inscrire à un tournoi (lancé par la commande !tournoi -s)"+'\n'
                +"!tournoi -e       		=> Met fin au tournoi"+'\n'
                
                +"----------------------------------------------------------------------"
            )
        }
    }
    if(splitMessage[0] === Prefix+"gbot"){
        if(splitMessage[1] === "-i"){
            if(splitMessage.length === 2){
                var HeureCreationDiscord = message.guild.createdAt.toLocaleTimeString(),
                    DateCreationDiscord = message.guild.createdAt.toLocaleDateString();
				message.channel.sendMessage(
					'\n'
					+"Nom du bot : Tcgo Bot"+'\n'
					+"Version : 1.3"+'\n'
					+"Date des Updates : 05/08/2018 ; 31/08/2018; 07/01/2019"+'\n'
					+"Discord origine : "+message.guild.name+'\n'
                    +"Date et Heure de créaton du discord : "+DateCreationDiscord+' | '+HeureCreationDiscord
				)
			}
        }
    }
    if(splitMessage[0] === Prefix+"tournoi"){
        if(splitMessage.length === 2){
            message.channel.sendMessage("Indisponible pour le moment, attendre la version 2.0 de Tcgo Bot") 
        }
    }
})

//---------------- Supprime les PUB, mauvais postes, etc.. ----------------
bot.on('message', message => {
    
    var key_word = new RegExp('discord.gg/');
    var PubDiscord = key_word.test(message.content);
    if(  PubDiscord  ){  message.delete()   }
    
    
    if(message.author.id !== '475734236951740436'){
        key_word = new RegExp('https://');
        var Lien = key_word.test(message.content);
        if(  Lien  ){  message.delete()   }

        key_word = new RegExp('http://');
        var Lien = key_word.test(message.content);
        if(  Lien  ){  message.delete()   }
    }
    
    
})
//-------------------------------------------------------------------------


//-------------- obtient le pseudo tcgo ----------------
bot.on('message', message => {
	
    var splitMessage = message.content.split(" ");
    
    if( (splitMessage[0] === Prefix+"Idtcg") || (splitMessage[0] === Prefix+"idtcg") ){
        
        if(splitMessage.length === 2){
            var idUser,
                IdDiscord=splitMessage[1].replace('<@','').replace('>','').replace('!',''),
				FilesUsers = require(PathFoldersObject+"/ClassMembreDiscord.js");
            
            for(var i=1;i <= process.env.Longueur ;i++){
                 if(FilesUsers['user'+i].id === IdDiscord){ idUser = FilesUsers['user'+i].idTcgo; break}
            }
            if(idUser){
                message.channel.sendMessage(idUser)
            }else{
                message.channel.sendMessage("Membre introuvable")
            }
        }
    }
})



// Recherche une deck liste

bot.on('message', message => {
    
    var splitMessage = message.content.split(" ");
    
    if(splitMessage[0] === Prefix+"liste"){
        
        //Partie Conteneur de deck liste (Format)
        if(splitMessage.length === 2){
            var Annees=fs.readdirSync(PathDeckListe+"/Standard/", (err, files) => {files.length}),
                Format=fs.readdirSync(PathDeckListe+'/', (err, files) => {files.length}),
                chemin;
            
            if(Annees.includes(splitMessage[1])){
                message.channel.sendMessage("https://github.com/PkmTCGO-FR/Ressource/tree/master/Deck-Liste/Standard/"+splitMessage[1])
            }else if(Format.includes(splitMessage[1])){
                message.channel.sendMessage("https://github.com/PkmTCGO-FR/Ressource/tree/master/Deck-Liste/"+splitMessage[1])
            }else{
                message.channel.sendMessage(
                    "Format introuvable !"+'\n'+'\n'
                    +"Liste des formats existants dans le Github :"+'\n'
                    +Format+'\n'+'\n'
                );
            }
        }
        
        //Partie deck liste
        if(splitMessage.length === 3){
            
            var Annees=fs.readdirSync(PathDeckListe+"/Standard/", (err, files) => {files.length}),
                Format=fs.readdirSync(PathDeckListe+'/', (err, files) => {files.length}),
                chemin;
            
            splitMessage[2]='*'+splitMessage[2]+'*';
            
            if(Annees.includes(splitMessage[1])){
                
                chemin=glob.sync(PathDeckListe+"/Standard/"+splitMessage[1]+"/" + splitMessage[2] + ".md")
                
                if((typeof chemin != "undefined" && chemin != null && chemin.length != null && chemin.length > 0)){
                   chemin.forEach(function(elem) {
                        message.channel.sendMessage("https://github.com/PkmTCGO-FR/Ressource/blob/master/"+elem.replace('../',''))
                    });
                }else{
                    message.channel.sendMessage(
                        "deck liste introuvable !"+'\n'+'\n'
                        +"Exemple : "+'\n'
                        +Prefix+"liste 2019 Sarmurai"+'\n'
                        +Prefix+"liste 2019 Zoro"+'\n'
                        +Prefix+"liste 2019 Mo"+'\n'
                    );
                }
                
                console.log((typeof chemin != "undefined" && chemin != null && chemin.length != null && chemin.length > 0))
                
            }else if(Format.includes(splitMessage[1])){
                chemin=glob.sync(PathDeckListe+'/'+splitMessage[1]+"/" + splitMessage[2] + ".md")
                
                if((typeof chemin != "undefined" && chemin != null && chemin.length != null && chemin.length > 0)){
                    chemin.forEach(function(elem) {
                        message.channel.sendMessage("https://github.com/PkmTCGO-FR/Ressource/blob/master/"+elem.replace('../',''))
                    });
                }else{
                    message.channel.sendMessage(
                        "deck liste introuvable !"+'\n'+'\n'
                        +"Exemple : "+'\n'
                        +Prefix+"liste Debutant Novi"+'\n'
                        +Prefix+"liste Heritage Gene"+'\n'
                        +Prefix+"liste Etendu Pyroli"+'\n'
                    );
                }
            }else{
                message.channel.sendMessage(
                    "Format introuvable !"+'\n'+'\n'
                    +"Voici la liste des années existantes pour le standard:"+'\n'
                    +Annees+'\n'+'\n'
                    +"Liste des formats existants dans le Github :"+'\n'
                    +Format+'\n'+'\n'
                    +"Exemple : "+'\n'
                    +Prefix+"liste 2019 Sarmurai"+'\n'
                    +Prefix+"liste Debutant Apprenti"+'\n'
                    +Prefix+"liste Etendu Pyro"+'\n'
                );
            }
        }
    } 
})
