import paramiko
import os
import time
import re
# from pathlib import Path
path = '/ffs/run/config/safe/'


class deletefiles:
    def __init__(self):
        pass

    def executecommand(self, obj):
        obj = self.delete_files()
        executor = obj.invoke_shell()
        executor.send('cd /ffs/run/config/safe/')
        executor.send('rm userAddAccount.txt')
        # op = executor.send('df -k \n')
        # time.sleep(10)
        # opp= executor.recv(9999)
        # return opp

    def Establish_SSH_Connection(self, host, username, password):
        cleint = None
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            client.connect(host, username=username,
                           password=password, banner_timeout=5)
            print("SSH connection established to - " + str(host))
            client.exec_command('rm /ffs/run/config/safe/userAddAccount.txt')
            client.exec_command('reboot')
            return client
        except BaseException as err:
            raise 'ssh to system module resulted in an exception :{}'.format(
                err)
            print("halting the memusage program")
            os._exit(0)
            return None

    def delete_files(self, host='192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu',
                     dest='/home/ute/Desktop/mem'):
        obj = self.Establish_SSH_Connection(host, username, password)
        # output=self.executecommand(obj)
        # self.delete_oldfiles(path)

    def Establish_SSH_Connection1(self, host, username, password):
        cleint = None
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            client.connect(host, username=username,
                           password=password, banner_timeout=5)
            print("SSH connection established to - " + str(host))
            client.exec_command(
                'rm /tmp/node_FHNET80/tmp/RMOD_L-1_NetconfRpcMessageTrace*.log')
            client.exec_command(
                'rm /tmp/node_FHNET80/tmp/RMOD_L-2_NetconfRpcMessageTrace*.log')
            client.exec_command(
                'rm /tmp/node_FHNET80/tmp/RMOD_L-3_NetconfRpcMessageTrace*.log')
            client.exec_command(
                'rm /tmp/node_FHNET80/tmp/RMOD_L-4_NetconfRpcMessageTrace*.log')
            # client.exec_command('reboot')
            return client
        except BaseException as err:
            raise 'ssh to system module resulted in an exception :{}'.format(
                err)
            print("halting the memusage program")
            os._exit(0)
            return None

    def delete_files_netconf(self, host='10.58.239.89', username='toor4nsn', password='oZPS0POrRieRtu',
                             dest='/home/ute/Desktop/mem'):
        obj = self.Establish_SSH_Connection1(host, username, password)
        # output=self.executecommand(obj)
        # self.delete_oldfiles(path)

    def Establish_SSH_Connection2(self, host, username, password):
        cleint = None
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            client.connect(host, username=username,
                           password=password, banner_timeout=5)
            print("SSH connection established to - " + str(host))
            client.exec_command(
                'rm /tmp/node_FHNET00/tmp/RMOD_L-1_NetconfRpcMessageTrace*.log')
            client.exec_command(
                'rm /tmp/node_FHNET00/tmp/RMOD_L-2_NetconfRpcMessageTrace*.log')
            client.exec_command(
                'rm /tmp/node_FHNET00/tmp/RMOD_L-3_NetconfRpcMessageTrace*.log')
            client.exec_command(
                'rm /tmp/node_FHNET00/tmp/RMOD_L-4_NetconfRpcMessageTrace*.log')
            # client.exec_command('reboot')
            return client
        except BaseException as err:
            raise 'ssh to system module resulted in an exception :{}'.format(
                err)
            print("halting the memusage program")
            os._exit(0)
            return None

    def delete_files_netconf_opc(self, host='10.58.239.89', username='toor4nsn', password='oZPS0POrRieRtu',
                                 dest='/home/ute/Desktop/mem'):
        obj = self.Establish_SSH_Connection2(host, username, password)
        # output=self.executecommand(obj)
        # self.delete_oldfiles(path)
