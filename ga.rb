#!/usr/bin/env ruby

#
# Gestion de cours et de programme d'etudes.
#

require 'fileutils'
require_relative 'cours'
require_relative 'cours-texte'
require_relative 'motifs'
require_relative 'dbc'

###################################################
# CONSTANTES GLOBALES.
###################################################

# Nom de fichier pour depot par defaut.
DEPOT_DEFAUT = '.cours.txt'


###################################################
# Fonctions pour debogage et traitement des erreurs.
###################################################

# Pour generer ou non des traces de debogage avec la function debug,
# il suffit d'ajouter/retirer '#' devant '|| true'.
DEBUG=false #|| true

def debug( *args )
  return unless DEBUG

  puts "[debug] #{args.join(' ')}"
end

def erreur( msg )
  STDERR.puts "*** Erreur: #{msg}"
  STDERR.puts

  puts aide if /Commande inconnue/ =~ msg

  exit 1
end

def erreur_nb_arguments( *args )
  erreur "Nombre incorrect d'arguments: <<#{args.join(' ')}>>"
end

###################################################
# Fonction d'aide: fournie, pour uniformite.
###################################################

def aide
    <<EOF
NOM
  #{$0} -- Script pour gestion academique (banque de cours)

SYNOPSIS
  #{$0} [--depot=fich] commande [options-commande] [argument...]

COMMANDES
  aide          - Emet la liste des commandes
  ajouter       - Ajoute un cours dans la banque de cours
                  (les prealables doivent exister)
  desactiver    - Rend inactif un cours actif
                  (ne peut plus etre utilise comme nouveau prealable)
  init          - Cree une nouvelle base de donnees pour gerer des cours
                  (dans './#{$DEPOT_DEFAUT}' si --depot n'est pas specifie)
  lister        - Liste l'ensemble des cours de la banque de cours
                  (ordre croissant de sigle)
  nb_credits    - Nombre total de credits pour les cours indiques
  prealables    - Liste l'ensemble des prealables d'un cours
                  (par defaut: les prealables directs seulement)
  reactiver     - Rend actif un cours inactif
  supprimer     - Supprime un cours de la banque de cours
  trouver       - Trouve les cours qui matchent un motif
EOF
end

###################################################
# Fonctions pour manipulation du depot.
#
# Fournies pour simplifier le devoir et assurer au depart un
# fonctionnement minimal du logiciel.
###################################################

def definir_depot
  
  #si ARGV[0] contient --depot= alors on assigne depot a apres le = 
  
  if ARGV[0].include?("--depot=") 
    dep = ARGV[0].split("=")
    depot = dep[1]
    ARGV.shift
  end
  depot ||= DEPOT_DEFAUT
  depot
end

def init( depot )

 if ARGV.length > 0
  if ARGV[0].include?("--detruire")
    detruire = true
    ARGV.shift
  end
end
  if File.exists? depot
    if detruire
      FileUtils.rm_f depot # On detruit le depot existant si --detruire est specifie.
    else
      erreur "Le fichier '#{depot}' existe.
              Si vous voulez le detruire, utilisez 'init --detruire'."
    end
  end

  FileUtils.touch depot
end


def charger_les_cours( depot )
  erreur "Le fichier '#{depot}' n'existe pas!" unless File.exists? depot
 
  # On lit les cours du fichier.
  IO.readlines( depot ).map do |ligne|
   
    # On ignore le saut de ligne avec chomp.
    CoursTexte.creer_cours( ligne )
  end
end


def sauver_les_cours( depot, les_cours )
  # On cree une copie de sauvegarde.
  FileUtils.cp depot, "#{depot}.bak"
  
  # On sauve les cours dans le fichier.
  #
  # Ici, on aurait aussi pu utiliser map plutot que each. Toutefois,
  # comme la collection resultante n'aurait pas ete utilisee,
  # puisqu'on execute la boucle uniquement pour son effet de bord
  # (ecriture dans le fichier), ce n'etait pas approprie.
  #
  File.open( depot, "w" ) do |fich|
    les_cours.each do |c|
      CoursTexte.sauver_cours( fich, c )
    end
  end
end


#################################################################
# Les fonctions pour les diverses commandes de l'application.
#################################################################

def lister( les_cours )
  [les_cours, nil] # A MODIFIER/COMPLETER!
end

def ajouter( les_cours )

     
   if ARGV.size > 0
      sigle,titre,nb_credits, *prealables = ARGV.to_a
       cour = []
    cour << sigle
    cour << titre
    cour << nb_credits
     
     ARGV.clear  
     
   end
    
   
  
  # elsif not STDIN.tty? and not STDIN.closed?
  #    cour = ARGF.read
  #    sigle = cour.match(Motifs::SIGLE).to_s 
  #    cour.slice! "#{sigle}"
  #    titre = cour.match(/["'][^"]+["']/).to_s
  #    titre.slice! "\""
  #    titre.slice! "\""
  #    cour.slice! "\"#{titre}\""
  #    nb_credits = cour.match(/\d/).to_s
  #    cour.slice! "#{nb_credits}"
  #    cour.strip!
  #    prealables = cour.split("  ")
  # end


    sigle_valide(sigle) 
    cours_existe(sigle, les_cours)

    if !prealables.nil? and prealables.size > 0
      for prea in prealables do
        sigle_valide( prea )
        prea_valide(prea, les_cours)
      end
      cour << prealables.join(':')
    else 
      cour << nil
    end
   cour << CoursTexte::ACTIF

    cour_valide = CoursTexte.creer_cours(cour.join(','))
    
   
  #    c = Cours.new(sigle.to_sym,titre,nb_credits,prealables,CoursTexte::ACTIF)
     
     les_cours << cour_valide
    return [les_cours, nil] # A Ameliorer
end

def nb_credits( les_cours )
   nb_cr = 0 
   sig = ARGV.to_a
   if ARGV.size == 0
     puts "0"
   elsif
     nb_cr = sig.map{|sigle| get_cours(sigle,les_cours).nb_credits.to_i}.reduce(:+)
      puts nb_cr
   end

   ARGV.clear
  return [les_cours, nil] # A MODIFIER/COMPLETER!
end

def supprimer( les_cours )
  [les_cours, nil] # A MODIFIER/COMPLETER!
end

def trouver( les_cours )
  [les_cours, nil] # A MODIFIER/COMPLETER!
end

def desactiver( les_cours )
   
    sigle = ARGV.to_a
    sigle_invalid(sigle[0])
    cours_inexiste(sigle[0], les_cours)
    for cour in les_cours do
     if cour.sigle.to_s =~ /#{sigle.to_s}/
  if cour.actif? == "ACTIF"
           cour.desactiver
          
  else
     erreur "deja inactif. #{sigle}"
  end
     end
    end

   ARGV.clear
return  [les_cours, nil] # A MODIFIER/COMPLETER!
end

def reactiver( les_cours )

   sigle = ARGV.to_a
   sigle_invalid(sigle[0])
   cours_inexiste(sigle[0], les_cours)

  for cour in les_cours do
     if cour.sigle.to_s =~ /#{sigle.to_s}/
        if cour.actif? == "INACTIF"
           cour.activer

        else
           erreur "deja actif. #{sigle}"
        end
     end
    end
  ARGV.clear
return  [les_cours, nil]
end

def prealables( les_cours )
  [les_cours, nil] # A MODIFIER/COMPLETER!
end

#######################################################
# Fonctions utilitaires
#######################################################
def sigle_valide( sigle )
  DBC.require( /^#{Motifs::SIGLE}$/ =~ sigle,"Sigle incorrect: #{sigle}!?" )
end

def sigle_invalid( sigle )
  DBC.require( /^#{Motifs::SIGLE}$/ =~ sigle,"Aucun cours. *#{sigle}" )
end


def prea_valide( prea , les_cours )
  if les_cours.size == 0
    fail "Prealables invalide: #{prea}"
  else
    prea_existe = les_cours.each{|c| c.sigle.to_s =~ /#{prea.to_s}/}
    end
  if prea_existe.empty?
    fail "Prealables invalide: #{prea}"
  end

end

def cours_existe ( sigle, les_cours)
  for cours in les_cours do
    if cours.sigle.to_s =~ /#{sigle.to_s}/
      cours_existe = true
    end
  end
  if cours_existe

    fail "Cours avec meme sigle existe deja: #{sigle}"
  end
end

def get_cours(sigle, les_cours)

  sigle_invalid(sigle)
  cour = les_cours.find{|c| c.sigle.to_s =~/#{sigle.to_s}/ }
  erreur "Aucun cours. *#{sigle}" unless !cour.nil?
  cour
end

def cours_inexiste ( sigle, les_cours)

  cours_existe = false
  for cours in les_cours do
    if cours.sigle.to_s =~ /#{sigle.to_s}/
      cours_existe = true
    end
  end
  if !cours_existe
    erreur "Aucun cours. *#{sigle}"
  end
end

#######################################################
# Les differentes commandes possibles.
#######################################################
COMMANDES = [:ajouter,
             :desactiver,
             :init,
             :lister,
             :nb_credits,
             :prealables,
             :reactiver,
             :supprimer,
             :trouver,
            ]

#######################################################
# Le programme principal
#######################################################

#
# La strategie utilisee pour uniformiser le traitement des commandes
# est la suivante (strategie differente de celle utilisee par ga.sh
# dans le devoir 1).
#
# Une commande est mise en oeuvre par une fonction auxiliaire.
# Contrairement au devoir 1, c'est cette fonction *qui modifie
# directement ARGV* (ceci est possible en Ruby, alors que ce ne
# l'etait pas en bash), et ce selon les arguments consommes.
#
# La fonction appelee pour realiser une commande ne retourne donc pas
# le nombre d'arguments utilises. Comme on desire utiliser une
# approche fonctionnelle, la fonction retourne plutot deux resultats
# (tableau de taille 2):
#
# 1. La liste des cours resultant de l'execution de la commande
#    (donc liste possiblement modifiee)
#
# 2. L'information a afficher sur stdout (nil lorsqu'il n'y a aucun
#    resultat a afficher).
#

begin
  # On definit le depot a utiliser, possiblement via l'option.
  depot = definir_depot

  debug "On utilise le depot suivant: #{depot}"

  # On analyse la commande indiquee en argument.
  commande = (ARGV.shift || :aide).to_sym
  (puts aide; exit 0) if commande == :aide

  erreur "Commande inconnue: '#{commande}'" unless COMMANDES.include? commande

  # La commande est valide: on l'execute et on affiche son resultat.
  if commande == :init
    init( depot )
  else
    les_cours = charger_les_cours( depot )
    les_cours, resultat = send commande, les_cours
    resultat if resultat   # Note: print n'ajoute pas de saut de ligne!
    sauver_les_cours( depot, les_cours )
  end

  erreur "Argument(s) en trop: '#{ARGV.join(' ')}'" unless ARGV.empty?
end
