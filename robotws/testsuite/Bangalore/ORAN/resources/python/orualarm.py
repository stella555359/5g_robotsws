import paramiko
import os
import time


# path='C:\Users\inbabtslabuser\Desktop\mem'
class orualarm:
    def __init__(self):
        pass

    def executecommand(self, obj):
        executor = obj.invoke_shell()
        executor.send(
            '{ echo "f_5g_du_lls"; sleep 0.5; echo "f_5g_du_lls"; '
            'sleep 0.5; echo "du -alm 7240"; sleep 0.5;} | '
            'lxc-attach -n 0x1018 -- telnet 172.22.48.2 \n')
        time.sleep(2)
        resp = executor.recv(9999)
        print(resp)

    # return resp

    def Establish_SSH_Connection(self, host, username, password):
        client = None
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        print(client)
        try:
            client.connect(host, username=username,
                           password=password, banner_timeout=5)
            print("SSH connection established to - " + str(host))
            return client
        except BaseException as err:
            raise 'ssh to system module resulted ' \
                  'in an exception :{}'.format(err)
            print("halting the memusage program")
            os._exit(0)
            return None

    def FJT_login(self, host='192.168.255.129',
                  username='toor4nsn', password='oZPS0POrRieRtu'):
        obj = self.Establish_SSH_Connection(host, username, password)
        output = self.executecommand(obj)
        print(output)


obj = orualarm()
# obj.login()
