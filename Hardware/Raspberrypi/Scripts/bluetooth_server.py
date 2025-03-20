#!/usr/bin/env python3
import bluetooth
import subprocess
import time

# Dictionnaire des commandes disponibles et des scripts correspondants
COMMANDS = {
    "Squat": "Squat.py",
    "Pull-ups": "PullUp.py",
    "Deadlift": "Deadlift.py",
    "Bench press": "benchPress.py",
    "Biceps Curls": "biceps.py",
    "Treadmill": "treadmill.py"
}

def run_bluetooth_server():
    """Lance un serveur Bluetooth RFCOMM pour recevoir des commandes et exécuter des scripts."""
    server_sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
    port = 1  # Canal RFCOMM standard
    
    try:
        server_sock.bind(("", port))
        server_sock.listen(1)
        print(f"📡 En attente d'une connexion Bluetooth sur le canal RFCOMM {port}...")

        client_sock, client_info = server_sock.accept()
        print(f"✅ Connexion acceptée de {client_info}")

        print("\n📜 **Commandes disponibles**:")
        for cmd in COMMANDS.keys():
            print(f"  ➜ {cmd}")

        print("  ➜ STOP (pour arrêter la connexion)")

        while True:
            try:
                data = client_sock.recv(1024)
                if not data:
                    break  # Si aucune donnée reçue, quitter la boucle

                command = data.decode('utf-8').strip()
                print(f"🎤 Commande reçue : {command}")

                if command.upper() == "STOP":
                    print("🛑 Arrêt de la connexion Bluetooth...")
                    break

                if command in COMMANDS:
                    script_name = COMMANDS[command]
                    print(f"🚀 Exécution de {script_name}...")
                    subprocess.Popen(["python3", script_name])
                else:
                    print(f"⚠️ Commande inconnue : {command}")
            except bluetooth.BluetoothError as e:
                print(f"❌ Erreur de communication Bluetooth : {e}")
                break  # Quitter si une erreur Bluetooth se produit
            except Exception as e:
                print(f"❌ Erreur générale : {e}")
                break  # Quitter en cas d'erreur générale

            time.sleep(0.1)  # Ajouter un petit délai pour éviter la surcharge CPU

    except Exception as e:
        print(f"❌ Erreur : {e}")

    finally:
        print("🔌 Fermeture de la connexion Bluetooth...")
        client_sock.close()
        server_sock.close()
        print("✅ Serveur arrêté.")

if __name__ == "__main__":
    run_bluetooth_server()
