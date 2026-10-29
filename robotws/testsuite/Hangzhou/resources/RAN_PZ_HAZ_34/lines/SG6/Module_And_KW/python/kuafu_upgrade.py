#!/usr/bin/python3
import os
import re
import paramiko
import sys


def main():
    # para list = [gnbid, cu/du, version]
    paras = sys.argv[1:]
    # paras = ['10.71.165.242', 'cranuser1', 'systeM!23', '6.16.0', 'vdu', '0.300.13763']
    print("sysargs: {}".format(paras))
    if paras[0] == '--help':
        print("Usage python3 {} gNBid cu/du".format(sys.argv[0].strip()))
    else:
        host_ip, username, password, kuafu, vxu, version = [i.strip() for i in paras]
        ssh = SSHConnection(host_ip, username, password)
        print("Try to upgrade to {}".format(version))
        new_build_version = "build_version={}".format(version)
        cmd_edit_version = "cd kuafu-v{kuafu}/artifacts/ ; sed -i 's/^build.*/{version}/g' {vxu}_config.ini".format(
            version=new_build_version, kuafu=kuafu, vxu=vxu)
        cmd_to_workdir = "cd ; cd kuafu-v{kuafu}/scenarios/{vxu}*".format(kuafu=kuafu, vxu=vxu)
        cmd_load_image = "./16*.sh"
        cmd_update_rannic = "./17*.sh update"
        cmd_delete_deploy = "./20*.sh"
        cmd_create_deploy = "./21*.sh"
        cmd_autoload_scf = "./42*.sh"
        cmd_cp_scf_to_kuafu = "mv ~/xxx_scf_file.xml ~/kuafu-v{kuafu}/scf/{vxu}/".format(
            kuafu=kuafu, vxu=vxu)

        if vxu == "vcu":
            cmd = "{};{};{};{};{};{}".format(
                cmd_edit_version, cmd_to_workdir, cmd_load_image, cmd_delete_deploy,
                cmd_create_deploy, cmd_autoload_scf)
        else:
            cmd = "{};{};{};{};{};{};{}".format(
                cmd_edit_version, cmd_to_workdir, cmd_load_image, cmd_delete_deploy,
                cmd_update_rannic, cmd_create_deploy, cmd_autoload_scf)

        print(cmd)
        print("Start to upgrade your {vxu} to {version}".format(vxu=vxu, version=version))
        print("Start to move scf file to kuafu..")
        ssh.ssh_channel(cmd_cp_scf_to_kuafu)
        print("Start to undeploy and deploy sw.")
        if vxu == "vcu":
            ssh.ssh_channel(cmd)
        else:
            ssh.execute_command(cmd)
        print("Hah...It seems done, pls check on your WebUI")

    return 0


class SSHConnection:
    def __init__(self, hostname, username, password=None, private_key=None, port='22'):
        self.hostname = hostname
        self.username = username
        self.password = password
        self.client = paramiko.SSHClient()
        self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.client.connect(self.hostname, username=self.username, password=self.password)

    def execute_command(self, command):
        try:
            stdin, stdout, stderr = self.client.exec_command(command)
            result = stdout.read().decode('utf-8').strip('\n')
        except Exception as e:
            result = stderr.read().decode('utf-8').strip('\n')
        return result

    def ssh_sftp(self):
        trans = self.client.get_transport()
        sftp = paramiko.SFTPClient.from_transport(trans)
        return sftp

    def ssh_channel(self, command):
        channel = self.client.invoke_shell()
        cmd = command + '\n'
        channel.send(cmd)
        channel.send('exit\n')
        while not channel.exit_status_ready():
            if channel.recv_ready():
                output = channel.recv(8).decode('utf-8', errors='ignore')
                print(output, end='')
        channel.close()

    def close(self):
        self.client.close()


main()
