from taf.transport.ssh import ssh
import sys
import os
import re
import ast
import time

csn = ssh()


def enable_ssh_to_ru(ip, username, password, ru_ip, ru_info):
    command = "ping " + ru_ip + " -c 3\n"
    print(command)
    enable = "3 packets transmitted, 3 received"
    print(ru_info)
    try:
        pc_conn = csn.connect_to(hostname=ip, username=username, password=password, alias='controlPC_%s' % ip)
        pc_shell = pc_conn.invoke_shell()
        pc_shell.send('sudo -i\n')
        # while True:
        # output = csn.execute(command=command, connection='controlPC', timeout=120)
        time.sleep(2)
        print(pc_shell.recv(65535))
        pc_shell.send(command)
        time.sleep(10)
        # print(pc_shell.recv(65535))
        output = pc_shell.recv(65535)
        output = output.decode()
        print(output)
        if enable not in output:
            for item in ru_info:
                if not isinstance(item, dict):
                    item_dict = ast.literal_eval(item)
                else:
                    item_dict = item
                command1 = 'echo "' + item_dict['username'] + '" > /dev/ttyUSB0\n'
                command2 = 'echo "' + item_dict['password'] + '" > /dev/ttyUSB0\n'
                pc_shell.send("stty -F /dev/ttyUSB0 115200 parodd\n")
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command1)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command2)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send('echo "sudo lmi-eth on" > /dev/ttyUSB0\n')
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command)
                time.sleep(10)
                output = pc_shell.recv(65535)
                output = output.decode()
                print(output)
                if enable in output:
                    break
    finally:
        csn.disconnect(connection='controlPC_%s' % ip)


if __name__ == "__main__":
    ip = sys.argv[1]
    username = sys.argv[2]
    password = sys.argv[3]
    ru_ip = sys.argv[4]
    ru_info = sys.argv[5:]
    print("monitor and download file...")
    enable_ssh_to_ru(ip, username, password, ru_ip, ru_info)
