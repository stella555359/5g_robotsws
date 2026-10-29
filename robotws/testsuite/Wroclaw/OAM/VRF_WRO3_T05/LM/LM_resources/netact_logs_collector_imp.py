import os
import re
import paramiko


class NetActLogsCollector(object):
    def __init__(self, netact_dict):
        self.netact_dict = netact_dict

    def collect_env_info(self, netact_name):
        output = "NetAct version:\n"
        output += "".join(self._ssh_commands("cat /etc/mpp-netact-release", netact_name))
        output += "\nWAS node:\n"
        was_status = self._ssh_commands("smanager.pl status service was", netact_name)
        output += self._get_node(was_status, netact_name)
        output += "\nCOMMON node:\n"
        common_service = self._ssh_commands("smanager.pl status service common_mediations", netact_name)
        output += self._get_node(common_service, netact_name)
        output += "\nNE3S node:\n"
        status_ne3s = self._ssh_commands("smanager.pl status service ne3s", netact_name)
        output += self._get_node(status_ne3s, netact_name)
        output += "\nDNS-Master node:\n"
        output += self._get_dns_records(netact_name)
        return output

    def collect_env_status(self, netact_name):
        output = "NetAct status:\n"
        output += "".join(self._ssh_commands("smanager.pl status", netact_name))
        print(output)
        return output

    def collect_env_logs(self, netact_name):
        if not os.path.isdir(netact_name + "_logs"):
            os.mkdir(netact_name + "_logs")
        node_and_ip = self._ssh_commands("smanager.pl status service was", netact_name)
        node_and_ip = self._get_node_and_ip(node_and_ip, netact_name)
        if not os.path.isdir(netact_name + "_logs/was_logs"):
            os.mkdir(netact_name + "_logs/was_logs")
        for node, ip in node_and_ip:
            self._get_file(ip, "/var/opt/oss/log/", "swm", node, netact_name + "_logs/was_logs")
        node_and_ip = self._ssh_commands("smanager.pl status service common_mediation", netact_name)
        node_and_ip = self._get_node_and_ip(node_and_ip, netact_name)
        if not os.path.isdir(netact_name + "_logs/common_and_ne3s_logs"):
            os.mkdir(netact_name + "_logs/common_and_ne3s_logs")
        for node, ip in node_and_ip:
            self._get_file(
                ip, "/var/opt/oss/log/", "common_mediations", node, netact_name + "_logs/common_and_ne3s_logs")

    def collect_dns_records(self, netact_name):
        dns_node = self._get_dns_records(netact_name)
        dns_ip = re.findall(r'\d+.\d+.\d+.\d+', dns_node)
        print(dns_ip[0])
        with paramiko.SSHClient() as ssh:
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(dns_ip[0], username='root', password='arthur')
            _, stdout, stderr = ssh.exec_command("cat /var/named/chroot/var/named/db.netact.nsn-rdnet")
            result = "".join(stdout.readlines())
        print(result)
        return result

    def collect_btsmed_logs(self, netact_name):
        node_ip = self.netact_dict[netact_name]["virtual_north"]
        with paramiko.SSHClient() as ssh:
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(node_ip, username='toor4nsn', password='oZPS0POrRieRtu')
            _, stdout, stderr = ssh.exec_command("cd /runningBtsMed/ && zip -r "
                                                 + netact_name + "_btsmed_log.zip /runningBtsMed/log")
            print(stdout.read())
            with ssh.open_sftp() as ftp_client:
                ftp_client.get("/runningBtsMed/" + netact_name + "_btsmed_log.zip", netact_name + "_btsmed_log.zip")
            _, stdout, stderr = ssh.exec_command("rm -rf /runningBtsMed/" + netact_name + "_btsmed_log.zip")

    def _get_dns_records(self, netact_name):
        dns_service = self._ssh_commands("smanager.pl status service DNS-Master", netact_name)
        result = self._get_node(dns_service, netact_name)
        return result

    def _get_node(self, output, netact_name):
        node_list = []
        node_list_ip = ""
        for line in output:
            reline = re.findall(r':(.*?):', line)
            node_list.append(reline[0])
        node_list = list(set(node_list))
        for line in node_list:
            node_list_ip += "".join(self._ssh_commands("host " + line, netact_name))
        return node_list_ip

    def _ssh_commands(self, command, netact_name):
        node_ip = self.netact_dict[netact_name]["node_ip"]
        with paramiko.SSHClient() as ssh:
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(node_ip, username='root', password='arthur')
            _, stdout, stderr = ssh.exec_command(command)
            if not stderr.readlines():
                return stdout
            else:
                return ""

    def _get_node_and_ip(self, output, netact_name):
        node_list = []
        node_list_ip = []
        for line in output:
            reline = re.findall(r':(.*?):', line)
            node_list.append(reline[0])
        node_list = list(set(node_list))
        for line in node_list:
            temp = "".join(self._ssh_commands("host " + line, netact_name))
            reline = re.findall(r'\d+.\d+.\d+.\d+', temp)
            node_list_ip.append(reline[0])
            print(node_list_ip)
        return zip(node_list, node_list_ip)

    @staticmethod
    def _get_file(host, src, dirname, name, dst):
        with paramiko.SSHClient() as ssh:
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(host, username='root', password='arthur')
            _, stdout, stderr = ssh.exec_command("cd " + src + " && zip -r /home/omc/" + name + "_log.zip " + dirname)
            print(stdout.readlines())
            with ssh.open_sftp() as ftp_client:
                ftp_client.get("/home/omc/" + name + "_log.zip", os.path.join(dst, name) + "_log.zip")
            print("rm -rf " + name + "_log.zip")
            _, stdout, stderr = ssh.exec_command("rm -rf /home/omc/" + name + "_log.zip")
            print(stdout.readlines())
