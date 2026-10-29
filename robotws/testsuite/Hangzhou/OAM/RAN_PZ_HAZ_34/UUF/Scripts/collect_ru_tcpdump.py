from taf.transport.ssh import ssh
import sys
import UUF_common

csn = ssh()


def visit_ru_to_collect_logs(controlPC, PCusername, PCpassword, ru, command, ru_type, build_release):
    ru_conn, pc_conn = UUF_common.connet_to_ru(controlPC, PCusername, PCpassword, ru, ru_type, build_release)
    ru_shell = ru_conn.invoke_shell()
    ru_shell.send(command)
    return ru_shell


if __name__ == "__main__":
    controlPC = sys.argv[1]
    PCusername = sys.argv[2]
    PCpassword = sys.argv[3]
    ru = sys.argv[4]
    command = sys.argv[5]
    ru_type = sys.argv[6]
    build_release = sys.argv[7]
    log_output_file = sys.argv[8]
#    index = 7
#    output_dir = sys.argv[index]
#    ip_ending = sys.argv[index+1]
    print("Start RU log in server %s" % controlPC)
    ru_shell = visit_ru_to_collect_logs(controlPC, PCusername, PCpassword, ru, command, ru_type, build_release)
    print("Will write to log file %s" % log_output_file)
    while True:
        fp = open(log_output_file, "a")
        output = ru_shell.recv(65535)
        fp.write(output)
        fp.close()
