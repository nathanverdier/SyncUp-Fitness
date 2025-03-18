---
<div align = center>

[Présentation](#présentation) | [L'objectif](#objectif) | [Hardware](#hardware)

</div>

---


## Présentation

**Nom du projet** : SyncUp Fitness

(Évoque l'idée de se synchroniser pour atteindre des objectifs en salle)

### Problématique

Tout le monde n'a pas les moyens de se permettre un coach personnel dans une salle de sport ou une salle de crossfit. Ce projet naît de cette constatation. Nous souhaitons éviter que les adhérents d'une salle se blessent en effectuant de mauvais mouvements et leur donner accès à des informations détaillées sur la façon dont leur corps réagit aux exercices, ainsi que sur les moyens de s'améliorer.

### L'objectif

Ce projet a pour but de recueillir diverses informations corporelles telles que le rythme cardiaque, l'oxygène dans le sang, la température, etc.

Ensuite, toutes ces informations seront accessibles à l'utilisateur via une application, lui permettant de faire le point sur ses mouvements lors de sa dernière série, ses gestes, son rythme cardiaque, sa dépense calorique, etc.

Par la suite, une IA utilisant un modèle VFTD (modifiable) traitera ces données et proposera des axes d'amélioration à l'utilisateur.

## Répartition du Gitlab

La racine du github est composé de deux dossier :

[**Syncup_fitness_app**](Application) : **Code de l'application**

[**Documentation**](Documentation) : **Regroupe l'entièreté  de la documentation**

[**Hardware code**](Hardware) : **Le code de la partie hardware**

⚠️ Code de l'application en cours!

## Hardware
### Solution carte mère :
   - **Raspberry Pi 4** : Je pense que c'est la meilleure solution pour ce projet avec une large gamme de capteurs, un bon support logiciel, le Bluetooth intégré comme le wifi. 

### Camera
   - **Camera imx477** : Permet l'utilisation du grand angle, pratique lors de scéance de sport

## Application
L'application sera développée en Flutter (Dart) afin que tout ceci soit accessible sur toutes les plateformes mobiles (Android et iOS) et permette une utilisation simple du Bluetooth. 


## Base de données
Nous utiliserons Firebase pour gérer les différents comptes et utilisateurs, les droits, etc. 

## Branche de rendu 
Master

## Techniciens
<div align = center>

<a href = "https://github.com/nathanverdier">
<img src ="https://www.proservices-informatique.fr/wp-content/uploads/2023/11/abonnement-assistance-maintenance-informatique.png" height="50px">
</a>

<strong>VERDIER Nathan</strong>



---


&nbsp; ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
&nbsp; ![Dart](https://img.shields.io/badge/Dart-00599C?style=for-the-badge&logo=dart&logoColor=white) 
&nbsp; ![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-C51A4A?style=for-the-badge&logo=raspberry-pi&logoColor=white)
&nbsp; ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white)


---


</div>



<div align = center>
</div>
