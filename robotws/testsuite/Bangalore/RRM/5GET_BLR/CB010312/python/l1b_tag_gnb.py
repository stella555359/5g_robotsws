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
