import os
import platform
import subprocess
import sys

# === CONFIGURATION ===
PROXY = "http://10.144.1.10:8080"  # proxy IP
VENV_DIR = ".tti_env"
REQUIREMENTS_FILE = "requirements.txt"
MAIN_SCRIPT = "main.py"


def run_command(command, shell=False):
    print(f"▶ Running: {' '.join(command) if isinstance(command, list) else command}")
    result = subprocess.run(command, shell=shell)
    if result.returncode != 0:
        print("❌ Command failed.")
        sys.exit(1)


def create_virtualenv():
    if not os.path.exists(VENV_DIR):
        print("🔧 Creating virtual environment...")
        run_command([sys.executable, "-m", "venv", VENV_DIR])
    else:
        print("✅ Virtual environment already exists.")


def activate_virtualenv():
    if platform.system() == "Windows":
        activate_script = os.path.join(VENV_DIR, "Scripts", "activate")
    else:
        activate_script = os.path.join(VENV_DIR, "bin", "activate")
    return activate_script


def install_dependencies():
    if os.path.exists(REQUIREMENTS_FILE):
        pip_path = os.path.join(
            VENV_DIR, "Scripts" if platform.system() == "Windows" else "bin", "pip"
        )
        print("📦 Installing dependencies via proxy...")
        run_command([pip_path, "install", "--proxy", PROXY, "-r", REQUIREMENTS_FILE])
    else:
        print("⚠️ No requirements.txt found. Skipping dependency installation.")


def run_main_script():
    python_path = os.path.join(
        VENV_DIR, "Scripts" if platform.system() == "Windows" else "bin", "python"
    )
    print("🚀 Running main script...")
    run_command([python_path, MAIN_SCRIPT])


if __name__ == "__main__":
    create_virtualenv()
    install_dependencies()
