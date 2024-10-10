# SyncMotion

## Problématique

Tout le monde n'a pas les moyens de se permettre un coach personnel dans une salle de sport ou une salle de crossfit. Ce projet naît de cette constatation. Nous souhaitons éviter que les adhérents d'une salle se blessent en effectuant de mauvais mouvements et leur donner accès à des informations détaillées sur la façon dont leur corps réagit aux exercices, ainsi que sur les moyens de s'améliorer.

## L'objectif

Ce projet a pour but de recueillir diverses informations corporelles telles que le rythme cardiaque, l'oxygène dans le sang, la température, etc.

Ensuite, toutes ces informations seront accessibles à l'utilisateur via une application, lui permettant de faire le point sur ses mouvements lors de sa dernière série, ses gestes, son rythme cardiaque, sa dépense calorique, etc.

Par la suite, une IA utilisant un modèle VFTD (modifiable) traitera ces données et proposera des axes d'amélioration à l'utilisateur.

### 1. **Capteur de fréquence cardiaque (ECG ou PPG)**
   - **PPG (Photopléthysmographie)** : Utilisé dans les montres, mais moins précis.
   - **ECG (Électrocardiographie)** : Plus précis, mais peut être moins confortable ou plus contraignant. [lien ECG](https://www.sparkfun.com/products/12969)

### 2. **Capteur de température corporelle**
   - **Thermistors** ou **capteurs infrarouges** : Ces capteurs mesurent la température cutanée, apparemment. [lien TMP36](https://www.sparkfun.com/products/10988)
   
### 3. **Accéléromètre et gyroscope**
   - Utilisés pour suivre les mouvements, la vitesse et la position du corps pendant l'activité. Les capteurs triaxiaux peuvent détecter les accélérations dans toutes les directions et analyser les mouvements complexes, très utiles pour suivre la course, la marche ou le cyclisme. [lien MPU-6050](https://www.sparkfun.com/products/10937) 

### 4. **Capteurs d'oxygène dans le sang (SpO2)**
   - Mesurent la saturation en oxygène dans le sang. (pas trouvé de site)

### 5. **Capteurs de respiration (Taux de respiration)**
   - Certains dispositifs comme les ceintures cardio-fréquencemètres peuvent aussi intégrer la mesure de la respiration, soit par des capteurs de pression, soit par des technologies basées sur la photopléthysmographie.

### Solution carte mère :
   - **Raspberry Pi 3/4** : Je pense que c'est la meilleure solution pour ce projet avec une large gamme de capteurs, un bon support logiciel, le Bluetooth intégré comme le wifi.

## Batterie
J'ai du mal à estimer la consommation nécessaire pour tout ce projet. Je pense qu'une batterie au lithium sera nécessaire afin d'avoir une solution portable pouvant durer quelques séances de sport sans avoir à la recharger.

## Application
L'application sera développée en Flutter (Dart) afin que tout ceci soit accessible sur toutes les plateformes mobiles (Android et iOS) et permette une utilisation simple du Bluetooth.

## Base de données
Nous utiliserons Firebase pour gérer les différents comptes et utilisateurs, les droits, etc.