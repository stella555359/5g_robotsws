import os
import paramiko
import sys


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

        # print(output)
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


def increase_buffer_size(host, port, username, password):

    host = str(host)
    port = str(port)
    username = str(username)
    password = str(password)

    cmd_list_vm = ['sudo sysctl -a',
                   'sudo sysctl -w net.core.rmem_default=26214400',
                   'sudo sysctl -w net.core.rmem_max=26214400',
                   'sudo sysctl -w net.core.wmem_default=26214400',
                   'sudo sysctl -w net.core.wmem_max=26214400',
                   'sudo sysctl -a | grep net.core.rmem',
                   'sudo sysctl -a | grep net.core.wmem']
    for cmd in cmd_list_vm:
        cmd = cmd + '\n'
        os.system(cmd)

    connection_c, sftp_c = connect(host, port, username, password)
    cmd_list = ['sysctl -a',
                'sysctl -w net.core.rmem_default=20971520',
                'sysctl -w net.core.rmem_max=20971520',
                'sysctl -w net.core.wmem_default=20971520',
                'sysctl -w net.core.wmem_max=20971520',
                'sudo sysctl -a | grep net.core.rmem',
                'sudo sysctl -a | grep net.core.wmem',
                'quit']
    for cmd in cmd_list:
        output = send_command(connection_c, cmd)
        # print(output)
    close_connection(connection_c, sftp_c)


def get_file_from_rotta(source, destination, filename):
    os.system('sudo chmod -R 777 ' + destination)
    ssh_client = paramiko.SSHClient()
    host = "esrottav01.emea.nsn-net.net"
    username = "shh"
    password = "Temp1234"
    port = '22'
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh_client.connect(hostname=host, port=port, username=username, password=password)
        ftp = ssh_client.open_sftp()
        print('====', os.path.join(destination, filename))
        files = ftp.get(os.path.join(source, filename), os.path.join(destination, filename))
        ftp.close()
        ssh_client.close()
    except Exception as e:
        os.chdir(destination)
        dllink = 'https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/CB008509_TC2/'
        cmd = 'sudo wget ' + dllink + filename + ' --user=nakumarr --password=AP77uPPBwkEmnyA1anQzR6fXLyVxx3qRNufG22'
        os.system(cmd)
    os.system('sudo chmod -R 777 ' + os.path.join(destination, filename))


def download_mcshark(destination, filename):
    os.system('sudo chmod -R 777 ' + destination)
    os.chdir(destination)
    dllink = 'https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/CB008509_TC2/'
    cmd = 'sudo wget ' + dllink + filename + ' --user=nakumarr --password=AP77uPPBwkEmnyA1anQzR6fXLyVxx3qRNufG22'
    os.system(cmd)
    os.system('sudo chmod -R 777 ' + os.path.join(destination, filename))
    isexist = os.path.exists(os.path.join(destination, filename))
    # if isexist !=True:
    #     sys.exit()
    if isexist is not True:
        sys.exit()
