import os
import paramiko


def connect(server_ip, server_port, user, password):

    try:
        print("Establishing ssh connection to %s" % server_ip)
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(server_ip, port=server_port, username=user, password=password)
        print("Connected to the server %s" % server_ip)
        connection = get_shell(client)
        sftp = client.open_sftp()
        return connection, sftp

    except Exception as e:
        print('\n Exception in connecting to the server')
        print("Exception is:", e)
        os.abort()


def get_shell(client):
    connection = client.invoke_shell()
    return connection


def send_command(connection, command):
    try:
        print("executing command: %s" % command)
        connection.send(command + '\r')
        connection.timeout = 1
        while not connection.recv_ready():
            pass

        output = ''
        try:
            output += connection.recv(1024).decode(encoding='UTF-8', errors="ignore")
            while len(output):
                output += connection.recv(1024).decode(encoding='UTF-8', errors="ignore")
        except Exception as e:
            print("Exception is:", e)

        print(output)
        return output

    except Exception as e:
        print("Failed to execute the command!", command)
        print("Exception is:", e)
        os.abort()


def close_connection(connection, sftp):
    print("Closing Connection")
    sftp.close()
    connection.close()
    print("Connection Closed")


def add_l1bypass_sic_address_in_gnb(host, port, username, password):

    host = str(host)
    port = str(port)
    username = str(username)
    password = str(password)

    connection_c, sftp_c = connect(host, port, username, password)
    output = send_command(connection_c, 'ls -lrth')
    if 'root@fct-4a' in output:
        send_command(connection_c, 'telnet 0 15007')
        dummy = send_command(connection_c, 'tag -a')
        print(dummy)
        if 'app.btsom.nts.L1BypassMap, (14)[ 30783232 34443A30 78353234 4100 | 0x225D:0x574A' in dummy:
            print('app.btsom.nts.L1BypassMap Tag is present on 0x225D:0x574A')
            pass
        else:
            send_command(connection_c, 'tag -3w app.btsom.nts.L1BypassMap 0x225D:0x574A')
        send_command(connection_c, 'quit')

    else:
        send_command(connection_c, 'telnet 0 15007')
        dummy = send_command(connection_c, 'tag -a')
        if 'app.btsom.nts.L1BypassMap, (14)[ 30783232 34443A30 78353234 4100 | 0x124D:0x574A' in dummy:
            print('app.btsom.nts.L1BypassMap Tag is present on 0x124D:0x574A')
            pass
        else:
            send_command(connection_c, 'tag -3w app.btsom.nts.L1BypassMap 0x124D:0x574A')
        send_command(connection_c, 'quit')
        send_command(connection_c, 'ls -lrt')

    close_connection(connection_c, sftp_c)


def add_l1bypass_sic_address_in_gnb_bo(host, port, username, password):

    host = str(host)
    port = str(port)
    username = str(username)
    password = str(password)

    connection_c, sftp_c = connect(host, port, username, password)
    output = send_command(connection_c, 'ls -lrth')
    if 'root@fct-4a' in output:
        send_command(connection_c, 'telnet 0 15007')
        dummy = send_command(connection_c, 'tag -a')
        print(dummy)
        if 'app.btsom.nts.L1BypassMap, (14)[ 30783232 34443A30 78353234 4100 | 0x224D:0x574A' in dummy:
            print('app.btsom.nts.L1BypassMap Tag is present on 0x224D:0x574A')
            pass
        else:
            send_command(connection_c, 'tag -3w app.btsom.nts.L1BypassMap 0x224D:0x574A')
        send_command(connection_c, 'quit')

    else:
        send_command(connection_c, 'telnet 0 15007')
        dummy = send_command(connection_c, 'tag -a')
        if 'app.btsom.nts.L1BypassMap, (14)[ 30783232 34443A30 78353234 4100 | 0x124D:0x574A' in dummy:
            print('app.btsom.nts.L1BypassMap Tag is present on 0x124D:0x574A')
            pass
        else:
            send_command(connection_c, 'tag -3w app.btsom.nts.L1BypassMap 0x124D:0x574A')
        send_command(connection_c, 'quit')
        send_command(connection_c, 'ls -lrt')

    close_connection(connection_c, sftp_c)


def update_swconfig_gnb(rd_parameter_list):
    import os
    os.system('scp toor4nsn@192.168.255.1:/ffs/run/swconfig.txt /home/ute/Downloads/')

    parameter = rd_parameter_list.replace(';', '\n')
    with open('/home/ute/Downloads/swconfig.txt', 'r') as f:
        text = f.readlines()

    for item in parameter:
        if item not in text:
            text.append(item)

    with open('/home/ute/Downloads/swconfig.txt', 'w') as f:
        f.writelines(text)

    os.system('scp /home/ute/Downloads/swconfig.txt toor4nsn@192.168.255.1:/ffs/run/')
    os.system('ssh toor4nsn@192.168.255.1 "cat /ffs/run/swconfig.txt"')
    os.system('rm -rf /home/ute/Downloads/swconfig*')


def update_iphy_airphone():
    import os
    os.system('scp toor4nsn@192.168.200.1:/ffs/run/simmode/new_iphy.xml /home/ute/Downloads/')

    with open('/home/ute/Downloads/new_iphy.xml', 'r') as f:
        text = f.readlines()

    for line in text:
        if "<L1Bypass>true</L1Bypass>" not in line:
            index = text.index('    <AutoRebootOnLinkDown>true</AutoRebootOnLinkDown>\n')
            print(index)
            text.insert(index+1, '    <L1Bypass>true</L1Bypass>\n')
            break
        else:
            print('searching')

    with open('/home/ute/Downloads/new_iphy.xml', 'w') as f:
        f.writelines(text)

    os.system('scp /home/ute/Downloads/new_iphy.xml toor4nsn@192.168.200.1:/ffs/run/simmode/')
    os.system('ssh toor4nsn@192.168.200.1 "cat /ffs/run/simmode/new_iphy.xml"')
    os.system('rm -rf /home/ute/Downloads/new_iphy.xml')


def gnb_ap_reboot():
    os.system('ssh toor4nsn@192.168.200.1 "reboot"')
    os.system('ssh toor4nsn@192.168.255.1 "reboot"')
