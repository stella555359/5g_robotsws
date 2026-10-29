from taf.transport.ssh import ssh
import time

csn = ssh()


def enable_lmi_on_ru(ip, username, password, ru_ip, ru_username, ru_password):
    command = "ping " + ru_ip + " -c 3\n"
    print(command)
    cmd_iptable = "sudo iptables -I INPUT -p udp -s 192.168.100.1/24 -j ACCEPT\n"
    print(cmd_iptable)
    enable = "3 packets transmitted, 3 received"
    try:
        pc_conn = csn.connect_to(hostname=ip, username=username, password=password, alias='controlPC')
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
        for i in range(1, 4):
            if enable not in output:
                pc_shell.send(cmd_iptable)
                time.sleep(10)
                print(pc_shell.recv(65535))
                command1 = 'echo "' + ru_username + '" > /dev/ttyUSB0\n'
                command2 = 'echo "' + ru_password + '" > /dev/ttyUSB0\n'
                command3 = 'echo "sudo ssh %s@%s" > /dev/ttyUSB0\n' % (ru_username, ru_ip)
                pc_shell.send("stty -F /dev/ttyUSB0 115200 parodd\n")
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command1)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command2)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command3)
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
                # print(pc_shell.recv(65535))
                output = pc_shell.recv(65535)
                output = output.decode()
                print(output)
                if enable in output:
                    break
        if enable not in output:
            return False
    finally:
        csn.disconnect(connection='controlPC')


def switch_to_other_node_ru(ip, username, password, ru_ip, ru_username, ru_password):
    command = "ping " + ru_ip + " -c 3\n"
    print(command)
    cmd_iptable = "sudo iptables -I INPUT -p udp -s 192.168.100.1/24 -j ACCEPT\n"
    print(cmd_iptable)
    enable = "3 packets transmitted, 3 received"
    try:
        pc_conn = csn.connect_to(hostname=ip, username=username, password=password, alias='controlPC')
        pc_shell = pc_conn.invoke_shell()
        pc_shell.send('sudo -i\n')
        # while True:
        # output = csn.execute(command=command, connection='controlPC', timeout=120)
        time.sleep(2)
        print(pc_shell.recv(65535))
        pc_shell.send(command)
        time.sleep(10)
        print(pc_shell.recv(65535))
        output = pc_shell.recv(65535)
        output = output.decode()
        print(output)
        for i in range(1, 10):
            if enable not in output:
                pc_shell.send(cmd_iptable)
                time.sleep(10)
                print(pc_shell.recv(65535))
                # output = pc_shell.recv(65535)
                # output = output.decode()
                # print(output)
                command1 = 'echo "' + ru_username + '" > /dev/ttyUSB0\n'
                command2 = 'echo "' + ru_password + '" > /dev/ttyUSB0\n'
                command3 = 'echo "sudo ssh %s@%s" > /dev/ttyUSB0\n' % (ru_username, ru_ip)
                pc_shell.send("stty -F /dev/ttyUSB0 115200 parodd\n")
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command1)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command2)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command3)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command2)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send('echo "sudo lmi-eth on" > /dev/ttyUSB0\n')
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send('echo "sudo -i" > /dev/ttyUSB0\n')
                time.sleep(5)
                print(pc_shell.recv(65535))
                pc_shell.send('echo "echo slave_beamer> /sys/bus/i2c/drivers/mico32/3-003c/uart_mux" > /dev/ttyUSB0\n')
                time.sleep(3)
                print(pc_shell.recv(65535))
                pc_shell.send('echo "\n" > /dev/ttyUSB0\n')
                time.sleep(3)
                print(pc_shell.recv(65535))
                # pc_shell.send(command2)
                # time.sleep(5)
                # print(pc_shell.recv(65535))
                pc_shell.send(command1)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command2)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send('echo "sudo ip addr" > /dev/ttyUSB0\n')
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
        csn.disconnect(connection='controlPC')


def save_ru_log(ip, username, password, ru_ip, ru_username, ru_password):
    command = "ping " + ru_ip + " -c 3\n"
    print(command)
    cmd_iptable = "sudo iptables -I INPUT -p udp -s 192.168.100.1/24 -j ACCEPT\n"
    print(cmd_iptable)
    enable = "3 packets transmitted, 3 received"
    try:
        pc_conn = csn.connect_to(hostname=ip, username=username, password=password, alias='controlPC')
        pc_shell = pc_conn.invoke_shell()
        pc_shell.send('sudo -i\n')
        # while True:
        # output = csn.execute(command=command, connection='controlPC', timeout=120)
        time.sleep(2)
        print(pc_shell.recv(65535))
        pc_shell.send('sudo apt install sshpass\n')
        time.sleep(20)
        print(pc_shell.recv(65535))
        pc_shell.send(command)
        time.sleep(10)
        # print(pc_shell.recv(65535))
        output = pc_shell.recv(65535)
        output = output.decode()
        print(output)
        for i in range(1, 10):
            if enable not in output:
                pc_shell.send(cmd_iptable)
                time.sleep(10)
                print(pc_shell.recv(65535))
                command1 = 'echo "' + ru_username + '" > /dev/ttyUSB0\n'
                command2 = 'echo "' + ru_password + '" > /dev/ttyUSB0\n'
                command3 = 'echo "sudo ssh %s@%s" > /dev/ttyUSB0\n' % (ru_username, ru_ip)
                pc_shell.send("stty -F /dev/ttyUSB0 115200 parodd\n")
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command1)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command2)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command3)
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
                # print(pc_shell.recv(65535))
                output = pc_shell.recv(65535)
                output = output.decode()
                print(output)
                if enable in output:
                    break
        rulog_flag = "RU_snapshot.tar"
        for i in range(1, 5):
            # ru_conn = csn.connect_to(hostname=ru_ip, username=ru_username, password=ru_password, alias='ru',
            #                          proxy='controlPC')
            # ru_conn.execute('ccsShell.sh log -a -c full -z RU_snapshot.tar')
            command1 = 'echo "' + ru_username + '" > /dev/ttyUSB0\n'
            command2 = 'echo "' + ru_password + '" > /dev/ttyUSB0\n'
            time.sleep(2)
            print(pc_shell.recv(65535))
            pc_shell.send(command1)
            time.sleep(2)
            print(pc_shell.recv(65535))
            pc_shell.send(command2)
            time.sleep(2)
            cmd_rulog = 'echo "ccsShell.sh log -a -c full -z RU_snapshot.tar" > /dev/ttyUSB0\n'
            pc_shell.send(cmd_rulog)
            time.sleep(2)
            print(pc_shell.recv(65535))
            time.sleep(120)
            # pc_shell.send('su ute\n')
            # time.sleep(2)
            # print(pc_shell.recv(65535))
            # cmd_ssh = 'ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "%s"' % (ru_ip)
            # pc_shell.send(cmd_ssh)
            # time.sleep(2)
            # print(pc_shell.recv(65535))
            pc_shell.send(
                'sshpass -p ' + ru_password + ' scp -r -i StrictHostKeyChecking=no ' + ru_username + '@' + ru_ip +
                ':/ram/RU_snapshot.tar /tmp\n')
            time.sleep(30)
            print(pc_shell.recv(65535))
            # pc_conn.download_file(remote_path='/ram/RU_snapshot.tar', local_path='/tmp', connection='ru')
            pc_shell.send('cd /tmp;ls | grep RU_snapshot\n')
            time.sleep(2)
            output = pc_shell.recv(65535)
            output = output.decode()
            print(output)
            if rulog_flag in output:
                break
    finally:
        # csn.disconnect(connection='ru')
        csn.disconnect(connection='controlPC')


def send_cmd_to_ru(ip, username, password, ru_ip, ru_username, ru_password, cmds):
    command = "ping " + ru_ip + " -c 3\n"
    print(command)
    cmd_iptable = "sudo iptables -I INPUT -p udp -s 192.168.100.1/24 -j ACCEPT\n"
    print(cmd_iptable)
    enable = ":~#"
    try:
        pc_conn = csn.connect_to(hostname=ip, username=username, password=password, alias='controlPC')
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
        for i in range(1, 4):
            if enable not in output:
                pc_shell.send(cmd_iptable)
                time.sleep(10)
                print(pc_shell.recv(65535))
                command1 = 'echo "' + ru_username + '" > /dev/ttyUSB0\n'
                command2 = 'echo "' + ru_password + '" > /dev/ttyUSB0\n'
                command3 = 'echo "sudo ssh %s@%s" > /dev/ttyUSB0\n' % (ru_username, ru_ip)
                pc_shell.send("stty -F /dev/ttyUSB0 115200 parodd\n")
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command1)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command2)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command3)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command2)
                time.sleep(2)
                print(pc_shell.recv(65535))
                for cmd in cmds:
                    pc_shell.send('echo ' + cmd + ' > /dev/ttyUSB0\n')
                    time.sleep(2)
                    output = pc_shell.recv(65535)
                    output = output.decode()
                    print(output)
                if enable in output:
                    break
        if enable not in output:
            return False
    finally:
        csn.disconnect(connection='controlPC')

# if __name__ == "__main__":
#     ip = sys.argv[1]
#     username = sys.argv[2]
#     password = sys.argv[3]
#     ru_ip = sys.argv[4]
#     ru_username = sys.argv[5]
#     ru_password = sys.argv[6]
#     print("switch ru to dfe0...")
#     save_ru_log(ip, username, password, ru_ip, ru_username, ru_password)
