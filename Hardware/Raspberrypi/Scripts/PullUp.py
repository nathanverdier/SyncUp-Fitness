from picamera2 import Picamera2
import cv2
import mediapipe as mp
import numpy as np

# Initialisation de MediaPipe et Picamera2
mp_drawing = mp.solutions.drawing_utils
mp_pose = mp.solutions.pose

picam2 = Picamera2()
config = picam2.create_preview_configuration(main={"size": (640, 480), "format": "RGB888"})
picam2.configure(config)
picam2.start()

def calculate_angle(a, b, c):
    """Calcule l'angle entre trois points (ex: épaule, coude, poignet)"""
    a = np.array(a)
    b = np.array(b)
    c = np.array(c)
    
    radians = np.arctan2(c[1] - b[1], c[0] - b[0]) - np.arctan2(a[1] - b[1], a[0] - b[0])
    angle = np.abs(radians * 180.0 / np.pi)
    if angle > 180.0:
        angle = 360.0 - angle
        
    return angle

pullup_counter = 0
pullup_stage = None

# Détection des poses avec MediaPipe
with mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5) as pose:
    try:
        while True:
            frame = picam2.capture_array()
            frame_bgr = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
            results = pose.process(frame)
            
            if results.pose_landmarks:
                landmarks = results.pose_landmarks.landmark
                h, w, _ = frame_bgr.shape
                
                # Points clés pour les tractions (côté gauche)
                shoulder = [landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].x * w,
                            landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].y * h]
                elbow = [landmarks[mp_pose.PoseLandmark.LEFT_ELBOW.value].x * w,
                         landmarks[mp_pose.PoseLandmark.LEFT_ELBOW.value].y * h]
                wrist = [landmarks[mp_pose.PoseLandmark.LEFT_WRIST.value].x * w,
                         landmarks[mp_pose.PoseLandmark.LEFT_WRIST.value].y * h]
                
                # Calcul des angles
                elbow_angle = calculate_angle(shoulder, elbow, wrist)  # Angle du coude
                shoulder_angle = calculate_angle([shoulder[0], shoulder[1] - 20], shoulder, elbow)  # Angle de l'épaule
                
                # Détection du mouvement des tractions
                if elbow_angle > 150 and shoulder_angle > 50:
                    pullup_stage = "down"  # Bras tendus en bas
                if elbow_angle < 70 and shoulder_angle < 30 and pullup_stage == "down":
                    pullup_stage = "up"  # En position haute
                    pullup_counter += 1
                    print(f"Pull-ups: {pullup_counter}")
                
                # Affichage des angles
                cv2.putText(frame_bgr, f"Elbow: {int(elbow_angle)}°", 
                            tuple(np.multiply(elbow, [1, 1]).astype(int)),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2, cv2.LINE_AA)
                cv2.putText(frame_bgr, f"Shoulder: {int(shoulder_angle)}°", 
                            tuple(np.multiply(shoulder, [1, 1]).astype(int)),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2, cv2.LINE_AA)
                
                # Affichage du compteur et de l'état de la traction
                cv2.rectangle(frame_bgr, (0, 0), (300, 60), (245, 117, 16), -1)
                cv2.putText(frame_bgr, f"PULL-UPS: {pullup_counter} | {pullup_stage}",
                            (10, 40),
                            cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2, cv2.LINE_AA)
                
                # Dessiner les landmarks du corps
                mp_drawing.draw_landmarks(
                    frame_bgr,
                    results.pose_landmarks,
                    mp_pose.POSE_CONNECTIONS,
                    mp_drawing.DrawingSpec(color=(0, 255, 0), thickness=2, circle_radius=2),
                    mp_drawing.DrawingSpec(color=(0, 0, 255), thickness=2, circle_radius=2)
                )
            
            cv2.imshow("Pull-up Tracker", frame_bgr)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
    except KeyboardInterrupt:
        print("Arrêt par l'utilisateur.")
    finally:
        cv2.destroyAllWindows()
        picam2.stop()
