from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

# Dictionnaire des scripts que l'on peut exécuter
SCRIPTS = {
    "Deadlift.py": "Deadlift.py",
    "PullUp.py": "PullUp.py",
    "Squat.py": "Squat.py",
    "benchPress.py": "benchPress.py",
    "biceps.py": "biceps.py",
}

@app.route('/run', methods=['POST'])
def run_script():
    data = request.get_json()
    script_name = data.get("script")

    if script_name in SCRIPTS:
        try:
            output = subprocess.check_output(
                ["python3", SCRIPTS[script_name]], 
                stderr=subprocess.STDOUT
            )
            return jsonify({"status": "success", "output": output.decode()}), 200
        except subprocess.CalledProcessError as e:
            return jsonify({"status": "error", "output": e.output.decode()}), 500
    else:
        return jsonify({"status": "error", "message": "Script inconnu"}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)


