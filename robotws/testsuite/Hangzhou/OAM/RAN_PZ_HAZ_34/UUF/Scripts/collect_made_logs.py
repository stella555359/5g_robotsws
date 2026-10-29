from taf.transport.ssh import ssh
import sys
import time
import UUF_common

csn = ssh()


def visit_ru_to_collect_logs(controlPC, PCusername, PCpassword, ru, ru_type, build_release):
    ru_conn, pc_conn = UUF_common.connet_to_ru(controlPC, PCusername, PCpassword, ru, ru_type, build_release)
    ru_shell = ru_conn.invoke_shell()
    ru_shell.send('ping 192.168.101.2 -c 3')
    ru_shell.send('\n')
    time.sleep(3)
    ru_shell.send('rad -mpw 0x10042 0xC0A865C8')
    ru_shell.send('\n')
    ru_shell.send('rad -mpw 0x10043 0xC738')
    ru_shell.send('\n')
    return ru_shell


if __name__ == "__main__":
    controlPC = sys.argv[1]
    PCusername = sys.argv[2]
    PCpassword = sys.argv[3]
    ru = sys.argv[4]
    ru_type = sys.argv[5]
    build_release = sys.argv[6]
    log_output_file = sys.argv[7]
    print("Start RU log in server %s" % controlPC)
    ru_shell = visit_ru_to_collect_logs(controlPC, PCusername, PCpassword, ru, ru_type, build_release)
    print("Will write to log file %s" % log_output_file)
    while True:
        fp = open(log_output_file, "a")
        output = ru_shell.recv(65535)
        fp.write(output)
        fp.close()
