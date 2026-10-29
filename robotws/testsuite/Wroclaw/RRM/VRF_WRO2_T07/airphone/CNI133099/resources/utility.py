import os
import subprocess
from robot.api import logger


def start_netcat(port="49150"):
    subprocess.run("ncat -vklnp %s > /dev/null 2>&1 &" % port, shell=True)


def stop_netcat():
    os.system("sudo killall ncat")


def get_bip_pcap_file(directory):
    return os.listdir(directory)[0]


def verify_csi_im_slot_in_bip(pcap_file, read_filter):
    try:
        output = subprocess.run(
            "tshark -V -r %s -Y '%s'" % (pcap_file, read_filter), shell=True, check=True, capture_output=True,
            text=True).stdout
        if "DlData_CsiRsSendReq" in output:  # main checking is done by pcap filter earlier
            logger.info("Found desired slot in BIP.")
            return True
        else:
            logger.error("Proper slot not found in BIP.")
            return False
    except subprocess.CalledProcessError:
        logger.error("Tshark execution failure. Probably proper slot not found in BIP.")
        return False
