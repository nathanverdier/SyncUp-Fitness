# Importation des bibliothèques nécessaires
from picamera2 import Picamera2  # Pour contrôler la caméra Raspberry Pi
import cv2  # OpenCV pour le traitement d'images
import mediapipe as mp  # MediaPipe pour la détection de pose
import numpy as np  # NumPy pour les calculs mathématiques
import json
import sys

# Initialisation des outils de dessin et du modèle Pose de MediaPipe
mp_drawing = mp.solutions.drawing_utils  # Utilisé pour dessiner les landmarks et les connexions
mp_pose = mp.solutions.pose  # Modèle de détection de pose

# Configuration et démarrage de la caméra Raspberry Pi avec Picamera2
picam2 = Picamera2()  # Initialisation de l'objet caméra
config = picam2.create_preview_configuration(main={"size": (640, 480), "format": "RGB888"})  # Configuration de la résolution et du format
picam2.configure(config)  # Application de la configuration
picam2.start()  # Démarrage de la caméra

# Fonction pour calculer l'angle entre trois points
def calculate_angle(a, b, c):
    """
    Calcule l'angle entre trois points (A, B, C).
    Arguments :
    - a, b, c : coordonnées des points (listes ou tableaux NumPy)
    Retourne :
    - angle : l'angle en degrés entre les trois points
    """
    a = np.array(a)  # Conversion du point A en tableau NumPy
    b = np.array(b)  # Conversion du point B en tableau NumPy
    c = np.array(c)  # Conversion du point C en tableau NumPy
    
    # Calcul de l'angle en radians en utilisant l'arctangente
    radians = np.arctan2(c[1] - b[1], c[0] - b[0]) - np.arctan2(a[1] - b[1], a[0] - b[0])
    angle = np.abs(radians * 180.0 / np.pi)  # Conversion en degrés

    # Ajustement si l'angle dépasse 180 degrés
    if angle > 180.0:
        angle = 360.0 - angle
        
    return angle

# Variables pour suivre les répétitions et le stage (état) des bras gauche et droit
left_counter = 0  # Compteur pour le bras gauche
left_stage = None  # État actuel du bras gauche ("up" ou "down")

right_counter = 0  # Compteur pour le bras droit
right_stage = None  # État actuel du bras droit ("up" ou "down")

# Initialisation du modèle MediaPipe Pose
with mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5) as pose:
    try:
        while True:
            # Capture une image depuis la caméra
            frame = picam2.capture_array()  # Capture l'image en format NumPy
            
            # Conversion de l'image de RGB (format de la caméra) à BGR (format attendu par OpenCV)
            frame_bgr = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)

            # Détection de la pose dans l'image
            results = pose.process(frame)  # Analyse l'image pour détecter les landmarks

            # Vérification si des landmarks sont détectés
            if results.pose_landmarks:
                landmarks = results.pose_landmarks.landmark  # Liste des landmarks détectés
                
                # Récupération des dimensions de l'image pour convertir les coordonnées normalisées
                h, w, _ = frame_bgr.shape

                # === Détection pour le bras gauche ===
                left_shoulder = [
                    landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].x * w,
                    landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].y * h
                ]
                left_elbow = [
                    landmarks[mp_pose.PoseLandmark.LEFT_ELBOW.value].x * w,
                    landmarks[mp_pose.PoseLandmark.LEFT_ELBOW.value].y * h
                ]
                left_wrist = [
                    landmarks[mp_pose.PoseLandmark.LEFT_WRIST.value].x * w,
                    landmarks[mp_pose.PoseLandmark.LEFT_WRIST.value].y * h
                ]

                # Calcul de l'angle du bras gauche
                left_angle = calculate_angle(left_shoulder, left_elbow, left_wrist)

                # Logique pour compter les répétitions du bras gauche
                if left_angle > 160:
                    left_stage = "down"  # Position initiale (bras étendu)
                if left_angle < 30 and left_stage == "down":
                    left_stage = "up"  # Mouvement terminé (bras plié)
                    left_counter += 1  # Incrémentation du compteur
                    print(f"Reps bras gauche : {left_counter}")

                # Affichage de l'angle du bras gauche sur l'image
                cv2.putText(
                    frame_bgr,
                    f"Gauche: {int(left_angle)}",
                    tuple(np.multiply(left_elbow, [1, 1]).astype(int)),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.5,
                    (255, 255, 255),
                    2,
                    cv2.LINE_AA
                )

                # === Détection pour le bras droit ===
                right_shoulder = [
                    landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER.value].x * w,
                    landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER.value].y * h
                ]
                right_elbow = [
                    landmarks[mp_pose.PoseLandmark.RIGHT_ELBOW.value].x * w,
                    landmarks[mp_pose.PoseLandmark.RIGHT_ELBOW.value].y * h
                ]
                right_wrist = [
                    landmarks[mp_pose.PoseLandmark.RIGHT_WRIST.value].x * w,
                    landmarks[mp_pose.PoseLandmark.RIGHT_WRIST.value].y * h
                ]

                # Calcul de l'angle du bras droit
                right_angle = calculate_angle(right_shoulder, right_elbow, right_wrist)

                # Logique pour compter les répétitions du bras droit
                if right_angle > 160:
                    right_stage = "down"  # Position initiale (bras étendu)
                if right_angle < 30 and right_stage == "down":
                    right_stage = "up"  # Mouvement terminé (bras plié)
                    right_counter += 1  # Incrémentation du compteur
                    print(f"Reps bras droit : {right_counter}")

                # Affichage de l'angle du bras droit sur l'image
                cv2.putText(
                    frame_bgr,
                    f"Droit: {int(right_angle)}",
                    tuple(np.multiply(right_elbow, [1, 1]).astype(int)),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.5,
                    (255, 255, 255),
                    2,
                    cv2.LINE_AA
                )

                # === Affichage des répétitions et des états pour les deux bras ===
                cv2.rectangle(frame_bgr, (0, 0), (350, 80), (245, 117, 16), -1)  # Rectangle de fond pour les données
                cv2.putText(frame_bgr, 'GAUCHE', (60, 12), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 0), 1, cv2.LINE_AA)
                cv2.putText(frame_bgr, f"{left_counter} | {left_stage}", (15, 60), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2, cv2.LINE_AA)
                cv2.putText(frame_bgr, 'DROIT', (230, 12), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 0), 1, cv2.LINE_AA)
                cv2.putText(frame_bgr, f"  {right_counter} | {right_stage}", (150, 60), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2, cv2.LINE_AA)

                # Dessin des landmarks et des connexions sur l'image
                mp_drawing.draw_landmarks(
                    frame_bgr,
                    results.pose_landmarks,
                    mp_pose.POSE_CONNECTIONS,
                    mp_drawing.DrawingSpec(color=(0, 255, 0), thickness=2, circle_radius=2),  # Style des points
                    mp_drawing.DrawingSpec(color=(0, 0, 255), thickness=2, circle_radius=2)   # Style des connexions
                )

            # Affichage de l'image avec annotations
            cv2.imshow("MediaPipe Pose Detection", frame_bgr)

            # Quitter la boucle si l'utilisateur appuie sur 'q'
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
    except KeyboardInterrupt:
        print("Arrêt par l'utilisateur.")  # Message lors d'une interruption avec Ctrl+C
    finally:
        result = {"left_arm": left_counter, "right_arm": right_counter}
        # Pour les autres exercices, tu pourrais simplement afficher left_counter (ou total)
        print(json.dumps(result))
        sys.stdout.flush()
        cv2.destroyAllWindows()  # Fermer toutes les fenêtres d'affichage
        picam2.stop()  # Arrêter la caméra

