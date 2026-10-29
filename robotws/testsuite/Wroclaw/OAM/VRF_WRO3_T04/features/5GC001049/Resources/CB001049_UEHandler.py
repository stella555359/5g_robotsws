import paramiko
import time
import robot.api.logger as logger
from taf.ue import ue as taf_ue

ue = taf_ue()


def connect_to_UE_PC_and_perform_traffic_via_ssh(
        ue_pc_ip: str, ue_serial: str, port: int, ip_addr: str,
        ue_pc_username: str = 'labadmin', ue_pc_password: str = 'ZAQ!2wsx'
) -> None:
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.load_system_host_keys()
    client.connect(ue_pc_ip, username=ue_pc_username, password=ue_pc_password)
    _, stdout, _ = client.exec_command(f'adb -s {ue_serial} shell')
    logger.info("Waiting for output")
    time.sleep(10)
    _, stdout, _ = client.exec_command(f'iperf -c {ip_addr} -u -i 1 -p {port} -t 1000 -b 300M -l 1400')
    client.close()
