#!/usr/bin/env python3
import bluetooth
import subprocess

def run_bluetooth_server():
    # Création de la socket Bluetooth en mode RFCOMM
    server_sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
    port = 1  # Canal RFCOMM standard
    server_sock.bind(("", port))
    server_sock.listen(1)
    print("En attente d'une connexion sur le canal RFCOMM", port)
    
    client_sock, client_info = server_sock.accept()
    print("Connexion acceptée de", client_info)
    
    try:
        while True:
            data = client_sock.recv(1024)
            if not data:
                break
            command = data.decode('utf-8').strip()
            print("Commande reçue :", command)
            if command.upper() == "STOP":
                print("Arrêt de la connexion...")
                break
            # Lancer le script correspondant en fonction de la commande
            if command == "Squat":
                subprocess.Popen(["python3", "Squat.py"])
            elif command == "Pull-ups":
                subprocess.Popen(["python3", "PullUp.py"])
            elif command == "Deadlift":
                subprocess.Popen(["python3", "Deadlift.py"])
            elif command == "Bench press":
                subprocess.Popen(["python3", "benchPress.py"])
            elif command == "Biceps Curls":
                subprocess.Popen(["python3", "biceps.py"])
            elif command == "Treadmill":
                subprocess.Popen(["python3", "biceps.py"])
            else:
                print("Commande non reconnue :", command)
    except Exception as e:
        print("Erreur :", e)
    finally:
        client_sock.close()
        server_sock.close()
        print("Connexion fermée.")

if __name__ == "__main__":
    run_bluetooth_server()
