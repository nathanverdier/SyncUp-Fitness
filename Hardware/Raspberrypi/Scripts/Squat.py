from picamera2 import Picamera2
import cv2
import mediapipe as mp
import numpy as np
import json

# Initialisation de MediaPipe et Picamera2
mp_drawing = mp.solutions.drawing_utils
mp_pose = mp.solutions.pose

picam2 = Picamera2()
config = picam2.create_preview_configuration(main={"size": (640, 480), "format": "RGB888"})
picam2.configure(config)
picam2.start()

def calculate_angle(a, b, c):
    """Calcule l'angle entre trois points (ex: hanche, genou, cheville)"""
    a = np.array(a)
    b = np.array(b)
    c = np.array(c)
    
    radians = np.arctan2(c[1] - b[1], c[0] - b[0]) - np.arctan2(a[1] - b[1], a[0] - b[0])
    angle = np.abs(radians * 180.0 / np.pi)
    if angle > 180.0:
        angle = 360.0 - angle
        
    return angle

squat_counter = 0
squat_stage = None

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
                
                # Points clés pour le squat (côté gauche)
                hip = [landmarks[mp_pose.PoseLandmark.LEFT_HIP.value].x * w,
                       landmarks[mp_pose.PoseLandmark.LEFT_HIP.value].y * h]
                knee = [landmarks[mp_pose.PoseLandmark.LEFT_KNEE.value].x * w,
                        landmarks[mp_pose.PoseLandmark.LEFT_KNEE.value].y * h]
                ankle = [landmarks[mp_pose.PoseLandmark.LEFT_ANKLE.value].x * w,
                         landmarks[mp_pose.PoseLandmark.LEFT_ANKLE.value].y * h]
                shoulder = [landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].x * w,
                            landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].y * h]
                
                # Calcul des angles
                knee_angle = calculate_angle(hip, knee, ankle)  # Angle du genou
                hip_angle = calculate_angle(shoulder, hip, knee)  # Angle de la hanche
                ankle_angle = calculate_angle(knee, ankle, [ankle[0] + 10, ankle[1]])  # Angle de la cheville
                
                # Détection du squat
                if knee_angle > 160 and hip_angle > 160:
                    squat_stage = "up"
                if knee_angle < 90 and hip_angle < 100 and squat_stage == "up":
                    squat_stage = "down"
                    squat_counter += 1
                    print(f"Squats: {squat_counter}")
                
                # Affichage des angles
                cv2.putText(frame_bgr, f"Knee: {int(knee_angle)}°", 
                            tuple(np.multiply(knee, [1, 1]).astype(int)),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2, cv2.LINE_AA)
                cv2.putText(frame_bgr, f"Hip: {int(hip_angle)}°", 
                            tuple(np.multiply(hip, [1, 1]).astype(int)),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2, cv2.LINE_AA)
                cv2.putText(frame_bgr, f"Ankle: {int(ankle_angle)}°", 
                            tuple(np.multiply(ankle, [1, 1]).astype(int)),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2, cv2.LINE_AA)
                
                # Affichage du compteur et de l'état du squat
                cv2.rectangle(frame_bgr, (0, 0), (300, 60), (245, 117, 16), -1)
                cv2.putText(frame_bgr, f"SQUATS: {squat_counter} | {squat_stage}",
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
            
            cv2.imshow("Squat Tracker", frame_bgr)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
    except KeyboardInterrupt:
        print("Arrêt par l'utilisateur.")
    finally:
        cv2.destroyAllWindows()
        picam2.stop()
