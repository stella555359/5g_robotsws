from taf.transport.ssh import ssh
import sys
import time
import UUF_common

csn = ssh()


def enable_ru_flag(controlPC, PCusername, PCpassword, ru, ru_type, build_release, cmd):
    pc_conn = None
    ru_conn = None
    ru_shell = None
    try:
        ru_conn, pc_conn = UUF_common.connet_to_ru(controlPC, PCusername, PCpassword, ru, ru_type, build_release)
        ru_shell = ru_conn.invoke_shell()
        ru_shell.send('ccsShell.sh rad -pw 0x10043 0xC739\n')
        time.sleep(2)
        print(ru_shell.recv(65535).decode())
        ru_shell.send(cmd)
        ru_shell.send('\n')
        time.sleep(2)
        print(ru_shell.recv(65535).decode())
    finally:
        UUF_common.disconnect_ru(pc_conn, ru_conn)
        return ru_shell


if __name__ == "__main__":
    controlPC = sys.argv[1]
    PCusername = sys.argv[2]
    PCpassword = sys.argv[3]
    ru = sys.argv[4]
    ru_type = sys.argv[5]
    build_release = sys.argv[6]
    cmd = sys.argv[7]
    print("Enable RU Flag %s" % controlPC)
    enable_ru_flag(controlPC, PCusername, PCpassword, ru, ru_type, build_release, cmd)
