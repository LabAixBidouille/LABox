LABox
=====

Vagrant Box permettant d'avoir un environement de développement uniforme et facile à déployer pour la team embarqué.

# Installation
Pour construire l'image de votre machine virtuelle vous aurez besoin d'installer [Vagrant](http://vagrantup.com). Pour la lancer, nous utiliserons [VirtualBox](http://virtualbox.org). Pour la gestion des périphériques USB2, vous devez aussi installer [VirtualBox Extension Pack](https://www.virtualbox.org/wiki/Downloads). 

## Preparing the LAB Ubuntu box
Pour lancer LABox, il vous suffit de récupérer les fichiers de ce dépot et lancer Vagrant comme suit :
```sh
git clone https://github.com/LabAixBidouille/LABox.git
cd LABox
vagrant up
```
Attention cette étape va télécharger la moitié d'internet, donc prevoyez d'aller prendre l'air avant de la lancer.

Si jamais vous rencontrez des problèmes lors du provisionning (timeout ou autre), vous pouvez reprendre avec la commande suivante :
```sh
vagrant reload --provision
```