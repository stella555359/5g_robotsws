from taf.transport.ssh import ssh
import sys
import os

csn = ssh()


def visit_abil_to_collect_logs(host, username, password, ip_ending):
    ip_addr = '192.168.253.%s' % ip_ending
    csn.connect_to(host, username, password, alias='abil_proxy')
    abil_conn = csn.connect_to(ip_addr, username, password, proxy='abil_proxy', alias='abil_general_log')
    abil_shell = abil_conn.invoke_shell()
    # abil_shell.send('journalctl -a -f\n')
    abil_shell.send('journalctl -f -n1000\n')
    return abil_shell


if __name__ == "__main__":
    host = sys.argv[1]
    if len(sys.argv) > 4:
        username = sys.argv[2]
        password = sys.argv[3]
        index = 4
    else:
        username = "toor4nsn"
        password = "oZPS0POrRieRtu"
        index = 2
    output_dir = sys.argv[index]
    ip_ending = sys.argv[index+1]
    abil_shell = visit_abil_to_collect_logs(host, username, password, ip_ending)
    print("Start the abil log collection")
    log_output_file = os.path.join(output_dir, "journal_abil%s.log" % ip_ending)
    print("Will write to log file %s" % log_output_file)
    while True:
        fp = open(log_output_file, "a")
        output = abil_shell.recv(65535)
        fp.write(output)
        fp.close()
