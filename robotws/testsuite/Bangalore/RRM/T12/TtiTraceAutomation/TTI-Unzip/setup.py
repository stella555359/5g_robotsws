import os
import subprocess
import sys
import venv

proxy = "http://10.144.1.10:8080"
# Step 1: Create virtual environment
env_dir = ".tti-env"
if not os.path.exists(env_dir):
    print(f"Creating virtual environment at {env_dir}...")
    venv.create(env_dir, with_pip=True)
else:
    print(f"Virtual environment {env_dir} already exists.")

# Step 2: Ensure requirements file exists
# requirements_file = os.path.join("requirements", "requirements.txt")
requirements_file = "requirements.txt"
if not os.path.isfile(requirements_file):
    print(f"❌ Could not find {requirements_file}")
    sys.exit(1)

# Step 3: Install missing packages
env_python = (
    os.path.join(env_dir, "Scripts", "python.exe")
    if os.name == "nt"
    else os.path.join(env_dir, "bin", "python")
)
print("Installing required packages...")
subprocess.check_call(
    [env_python, "-m", "pip", "install", "--proxy", proxy, "-r", requirements_file]
)

# Step 4: Ensure pyperclip is available
try:
    import pyperclip
except ImportError:
    subprocess.check_call(
        [
            sys.executable,
            "-m",
            "pip",
            "install",
            "pyperclip",
            "--proxy",
            proxy,
        ]
    )
    import pyperclip

# Step 5: Copy activation and run command to clipboard
if os.name == "nt":
    activation_cmd = f".\\{env_dir}\\Scripts\\activate"
else:
    activation_cmd = f"source ./{env_dir}/bin/activate"

pyperclip.copy(activation_cmd)
print(f"\n✅ Setup complete. Paste this in your terminal to run:\n{activation_cmd}")
