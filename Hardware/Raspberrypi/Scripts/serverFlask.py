from flask import Flask, request, jsonify
import subprocess
import json

app = Flask(__name__)

# Dictionnaire des scripts que l'on peut exécuter
SCRIPTS = {
    "Deadlift": "Deadlift.py",
    "PullUp": "PullUp.py",
    "Squat": "Squat.py",
    "benchPress": "benchPress.py",
    "biceps": "biceps.py"
}

# Variable pour garder la trace du processus en cours
current_process = None
# Variable pour mémoriser le dernier script lancé
last_script = None

# Dictionnaire des répétitions
reps_counter = {
    "Deadlift": 0,
    "PullUp": 0,
    "Squat": 0,
    "benchPress": 0,
    "biceps": {"left_arm": 0, "right_arm": 0}  # biceps a 2 valeurs
}

@app.route('/run', methods=['POST'])
def run_script():
    global current_process, last_script, reps_counter

    data = request.get_json()
    script_name = data.get("script")

    if script_name in SCRIPTS:
        try:
            # Arrêter un script en cours avant de lancer le nouveau
            if current_process is not None:
                current_process.terminate()
                print("\uD83D\uDED1 Processus précédent arrêté.")
            
            # Réinitialiser le compteur pour cet exercice
            if script_name == "biceps":
                reps_counter["biceps"] = {"left_arm": 0, "right_arm": 0}
            else:
                reps_counter[script_name] = 0

            # Mémoriser le script lancé
            last_script = script_name

            # Lancer le script en mode non-bufferé (-u) pour être sûr que la sortie soit immédiate
            current_process = subprocess.Popen(
                ['python3', '-u', SCRIPTS[script_name]],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            return jsonify({"status": "success", "message": f"Script {script_name} en cours d'exécution"}), 200
        except Exception as e:
            return jsonify({"status": "error", "message": str(e)}), 500
    else:
        return jsonify({"status": "error", "message": "Script inconnu"}), 400

@app.route('/stop', methods=['POST'])
def stop_script():
    global current_process, reps_counter, last_script

    if current_process is not None:
        # Terminer le processus
        current_process.terminate()
        # Récupérer la sortie du script arrêté
        stdout, stderr = current_process.communicate()
        output = stdout.decode().strip() if stdout else ""
        print("Sortie du script :", output)

        # Tenter de parser la sortie pour mettre à jour le compteur
        try:
            parsed = json.loads(output)
            if last_script in reps_counter:
                reps_counter[last_script] = parsed
            else:
                print("Le script lancé n'est pas reconnu dans le compteur.")
        except Exception as e:
            print("Erreur lors du parsing de la sortie :", e)

        current_process = None
        return jsonify({"status": "success", "message": "Script arrêté", "reps": reps_counter}), 200
    else:
        return jsonify({"status": "error", "message": "Aucun script en cours d'exécution"}), 400

@app.route('/get_reps', methods=['GET'])
def get_reps():
    """
    Retourne le nombre de répétitions pour chaque exercice.
    """
    return jsonify(reps_counter), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

