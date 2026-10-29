#!/usr/bin/env python3
import os
import stat
import subprocess
import time
import pexpect
import sys
from robot.api.deco import keyword

# ----- CONFIGURARE HARD-CODATA -----
INTRAREEGATE_PATH = os.path.join(
    os.getcwd(),
    'testsuite/Timisoara/OAM/OPERABILITY_PM/PM_SIMULATOR/resources/intrareegate.sh'
)

# Comenzi shell (sudo ip addr add ...)
COMMANDS_BEFORE = [
    "sudo ip addr add 10.0.2.1/24 dev eth4",
    "sudo ip addr add 10.0.1.121/24 dev eth3",
    "sudo ip addr add 10.0.1.122/24 dev eth3",
    "sudo ip addr add 10.0.1.123/24 dev eth3",
    "sudo ip addr add 10.0.1.124/24 dev eth3",
    "sudo ip addr add 10.0.1.125/24 dev eth3",
    "sudo ip addr add 10.0.1.126/24 dev eth3",
    "sudo ip addr add 10.0.1.127/24 dev eth3",
    "sudo ip addr add 10.0.1.128/24 dev eth3",
    "sudo ip addr add 10.0.1.129/24 dev eth3",
    "sudo ip addr add 10.0.1.130/24 dev eth3",
    "sudo ip addr add 10.0.1.131/24 dev eth3",
    "sudo ip addr add 10.0.1.132/24 dev eth3",
    "sudo ip addr add 10.0.1.133/24 dev eth3",
    "sudo ip addr add 10.0.1.134/24 dev eth3",
    "sudo ip addr add 10.0.1.135/24 dev eth3",
    "sudo ip addr add 10.0.1.136/24 dev eth3",
    "sudo ip addr add 10.0.1.137/24 dev eth3",
    "sudo ip addr add 10.0.1.138/24 dev eth3",
    "sudo ip addr add 10.0.1.139/24 dev eth3",
    "sudo ip addr add 10.0.1.140/24 dev eth3",
    "sudo ip addr add 10.0.1.141/24 dev eth3",
    "sudo ip addr add 10.0.1.142/24 dev eth3",
    "sudo ip addr add 10.0.1.143/24 dev eth3",
    "sudo ip addr add 10.0.1.144/24 dev eth3",
    "sudo ip addr add 10.0.1.145/24 dev eth3",
    "sudo ip addr add 10.0.1.146/24 dev eth3",
    "sudo ip addr add 10.0.1.147/24 dev eth3",
    "sudo ip addr add 10.0.1.148/24 dev eth3",
    "sudo ip addr add 10.0.1.149/24 dev eth3",
    "sudo ip addr add 10.0.1.150/24 dev eth3",
    "sudo ip addr add 10.0.1.151/24 dev eth3",
    "sudo ip addr add 10.0.1.152/24 dev eth3",
    "sudo ip addr add 10.0.1.153/24 dev eth3",
    "sudo ip addr add 10.0.1.154/24 dev eth3",
    "sudo ip addr add 10.0.1.155/24 dev eth3",
    "sudo ip addr add 10.0.1.161/24 dev eth3",
    "sudo ip addr add 10.0.1.162/24 dev eth3",
    "sudo ip addr add 10.0.1.163/24 dev eth3",
    "sudo ip addr add 10.0.2.90/24 dev eth4",
    "sudo ip addr add 10.0.2.91/24 dev eth4",
    "sudo ip addr add 10.0.2.92/24 dev eth4",
    "sudo ip addr add 10.0.2.93/24 dev eth4",
    "sudo ip addr add 10.0.2.94/24 dev eth4",
    "sudo ip addr add 10.0.2.95/24 dev eth4",
    "sudo ip addr add 10.0.2.96/24 dev eth4",
    "sudo ip addr add 10.0.2.97/24 dev eth4",
    "sudo ip addr add 10.0.2.98/24 dev eth4",
    "sudo ip addr add 10.0.2.99/24 dev eth4",
    "sudo ip addr add 10.0.2.100/24 dev eth4",
    "sudo ip addr add 10.0.1.9/24 dev eth3",
    "sudo ip addr add 10.0.1.10/24 dev eth3",
    "sudo ip addr add 10.0.1.11/24 dev eth3",
    "sudo ip addr add 10.0.1.12/24 dev eth3",
    "sudo ip addr add 10.0.1.13/24 dev eth3",
    "sudo ip addr add 10.0.1.14/24 dev eth3",
    "sudo ip addr add 10.0.1.15/24 dev eth3",
    "sudo ip addr add 10.0.1.100/24 dev eth3",
    "sudo ip addr add 10.0.1.101/24 dev eth3",
    "sudo ip addr add 10.0.1.102/24 dev eth3",
    "sudo ip addr add 10.0.1.103/24 dev eth3",
    "sudo ip addr add 10.0.1.104/24 dev eth3",
    "sudo ip addr add 10.0.1.105/24 dev eth3",
    "sudo ip addr add 10.0.1.106/24 dev eth3",
    "sudo ip addr add 10.0.1.107/24 dev eth3",
    "sudo ip addr add 10.0.1.108/24 dev eth3",
    "sudo ip addr add 10.0.1.109/24 dev eth3",
    "sudo ip addr add 10.0.1.4/24 dev eth3",
    "sudo ip addr add 10.0.1.112/24 dev eth3",
    "sudo ip addr add 10.0.1.113/24 dev eth3",
]

# Comenzi trimise în EGATE>
EGATE_COMMANDS = [
    "cfg file=/home/ute/wts.cfg",
    "enb_x2_link_up enb=1 target=2",
]

EGATE_PROMPT = "EGATE>"
DELAY_BETWEEN_EGATE_CMDS = 1


@keyword("Make Simulator Executable")
def make_simulator_executable():
    path = INTRAREEGATE_PATH
    if not os.path.exists(path):
        raise FileNotFoundError(f"Fisierul nu a fost gasit: {path}")
    st = os.stat(path)
    os.chmod(path, st.st_mode | stat.S_IEXEC)
    print(f"{path} este acum executabil.")


@keyword("Run Hardcoded IP Commands Then Start EGATE")
def run_hardcoded_ips_then_start_egate():
    print("=== Rulez comenzile shell hardcodate (IP-uri) ===")
    for i, cmd in enumerate(COMMANDS_BEFORE, start=1):
        print(f"[{i}/{len(COMMANDS_BEFORE)}] Execut: {cmd}")
        try:
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=False)
            if result.stdout:
                print(result.stdout.strip())
            if result.stderr:
                print("ERR:", result.stderr.strip())
            if result.returncode != 0:
                print(f"Atentie: comanda a returnat cod {result.returncode} (continuam).")
        except Exception as e:
            print(f"Eroare la rulare comanda [{cmd}]: {e}")

    print("=== Astept 60 secunde inainte de a porni EGATE ===")
    time.sleep(60)

    print("=== Pornesc EGATE si trimit comenzile ===")
    try:
        child = pexpect.spawn(INTRAREEGATE_PATH, encoding='utf-8', timeout=30)
        child.logfile = sys.stdout

        child.expect(EGATE_PROMPT)
        print("==> Prompt EGATE> detectat.")

        for cmd in EGATE_COMMANDS:
            print(f"Trimit comanda: {cmd}")
            child.sendline(cmd)
            child.expect(EGATE_PROMPT)
            time.sleep(DELAY_BETWEEN_EGATE_CMDS)

        print("=== Toate comenzile EGATE au fost trimise ===")
        child.sendline("exit")

    except pexpect.exceptions.TIMEOUT:
        print("Eroare: Timeout la așteptarea promptului EGATE>")
    except pexpect.exceptions.EOF:
        print("Eroare: Procesul EGATE s-a încheiat neașteptat.")
    except Exception as e:
        print(f"Eroare neașteptată în sesiunea EGATE: {e}")


@keyword("Start PMStat Detached Over SSH NonBlocking")
def start_pmstat_ssh_nonblocking(host, username, key_file=None):
    """
    Ruleaza PMStat detached pe hostul remote prin SSH.
    Keyword-ul se termina imediat; PMStat continua sa ruleze.

    :param host: IP sau hostname host remote
    :param username: user SSH
    :param key_file: optional path catre cheia privata SSH
    """
    working_dir = "/ffs/run"
    pmstat_cmd = "/opt/PMStat/PMStat -C -M measurements.json -E environment.json"
    output_file = f"{working_dir}/simulator_output.txt"

    remote_cmd = f"cd {working_dir} && setsid nohup {pmstat_cmd} > {output_file} 2>&1 < /dev/null &"

    ssh_command = ["ssh", "-o", "StrictHostKeyChecking=no"]

    if key_file:
        key_file = os.path.expanduser(key_file)
        ssh_command += ["-i", key_file]

    ssh_command += [f"{username}@{host}", remote_cmd]

    try:
        print(f"=== Pornesc PMStat detached pe {host} (non-blocking) ===")
        # Folosim Popen ca sa nu mai blocam Robot
        subprocess.Popen(
            ssh_command,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        print(f"Keyword-ul s-a terminat, PMStat ruleaza pe {host} în continuare.")
    except Exception as e:
        raise RuntimeError(f"Eroare la execu?ia SSH: {e}")
