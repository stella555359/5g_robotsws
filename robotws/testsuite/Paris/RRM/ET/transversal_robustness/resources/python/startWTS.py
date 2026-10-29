import time
import subprocess


# start WTS
def startWTS():
    setupIP = (
        "sudo ip addr add 10.0.1.121 dev eth3 && sudo ip addr add 10.0.1.131 dev eth3 && "
        "sudo ip addr add 10.0.1.132 dev eth3 && sudo ip addr add 10.0.1.133 dev eth3 && "
        "sudo ip addr add 10.0.1.134 dev eth3 && sudo ip addr add 10.0.1.135 dev eth3 && "
        "sudo ip addr add 10.0.1.136 dev eth3 && sudo ip addr add 10.0.1.137 dev eth3 && "
        "sudo ip addr add 10.0.1.138 dev eth3"
    )
    try:
        subprocess.run(setupIP, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Une erreur s'est produite : {e}")
    time.sleep(5)  # wait 5s
    restartWTS = (
        "sudo pkill -9 sim_cnt_ap; sudo pkill -9 l3_sim; sudo pkill -9 sim_pg; "
        "sudo pkill -9 egate;sudo pkill -9 edaemon; "
        "sudo ./edaemon --port 22222; sudo -u ute ./egate --port 9880; sleep 5"
    )
    subprocess.run(restartWTS, shell=True, check=True, cwd="/opt/wts/latest")
    time.sleep(5)  # wait 5s


if __name__ == '__main__':
    startWTS()
