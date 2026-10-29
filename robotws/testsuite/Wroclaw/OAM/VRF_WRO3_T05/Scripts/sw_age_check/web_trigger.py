from flask import Flask, render_template, redirect
import subprocess
import os
from datetime import datetime
import threading
import time

app = Flask(__name__)

HTMLFILE = "OCP_FHGW_check_latest.html"
LAST_RUN_FILE = "last_run.txt"


def get_last_run_time():
    if os.path.exists(LAST_RUN_FILE):
        with open(LAST_RUN_FILE, "r") as f:
            return f.read().strip()
    return "Never"


def set_last_run_time():
    with open(LAST_RUN_FILE, "w") as f:
        f.write(datetime.now().strftime("%Y-%m-%d %H:%M:%S"))


@app.route('/')
def index():
    last_run = get_last_run_time()
    # Read the HTML file content to embed in the template
    with open(HTMLFILE, encoding='utf-8') as f:
        html_content = f.read()
    return render_template(
        "index.html",
        last_run=last_run,
        html_content=html_content
    )


@app.route('/run', methods=['POST'])
def run_script():
    subprocess.run(['python3', 'sw_age_check.py'], cwd=os.path.dirname(os.path.abspath(__file__)))
    set_last_run_time()
    return redirect('/')


def periodic_refresh():
    while True:
        subprocess.run(['python3', 'sw_age_check.py'], cwd=os.path.dirname(os.path.abspath(__file__)))
        set_last_run_time()
        time.sleep(12 * 60 * 60)  # 12 hours


if __name__ == '__main__':
    # Start periodic refresh in background
    t = threading.Thread(target=periodic_refresh, daemon=True)
    t.start()
    app.run(host='0.0.0.0', port=80)
