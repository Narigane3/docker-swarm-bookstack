#!/bin/bash

# Demander le nom d'utilisateur
read -p "Nom d'utilisateur: " username

# Demander et confirmer le mot de passe avec une boucle en cas d'échec
while true; do
    echo -n "Mot de passe: "
    stty -echo
    read password
    stty echo
    echo ""
    
    echo -n "Confirmez le mot de passe: "
    stty -echo
    read password_confirm
    stty echo
    echo ""
    
    if [ "$password" = "$password_confirm" ]; then
        # Vérifier la force du mot de passe
        if [ ${#password} -lt 8 ]; then
            echo "Le mot de passe doit contenir au moins 8 caractères. Veuillez réessayer."
        else
            break
        fi
    else
        echo "Les mots de passe ne correspondent pas. Veuillez réessayer."
    fi
done

# Générer le hash du mot de passe
password_hash=$(openssl passwd -apr1 "$password")

# Remplacer tous les $ par $$ pour éviter les erreurs d'interprétation dans .env
password_hash=$(echo "$password_hash" | sed 's/\$/\$\$/g')

# Afficher le résultat à copier-coller dans .env
echo "Ajoutez cette ligne à votre fichier .env :"
echo ""
echo "BASIC_AUTH=\"$username:$password_hash\""