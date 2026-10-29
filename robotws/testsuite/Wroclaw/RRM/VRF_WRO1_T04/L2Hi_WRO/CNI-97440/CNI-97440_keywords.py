import subprocess


def push_ping(ip="4.7.254.208"):
    subprocess.run(["ping", "-c 100", ip])
    return None
