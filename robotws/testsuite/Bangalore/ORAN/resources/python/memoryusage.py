import paramiko
import time
import re
from pathlib import Path


# from robot.libraries.BuiltIn import BuiltIn

class memoryusage:
    def __init__(self):
        pass

    def executecommand(self, obj):
        executor = obj.invoke_shell()
        output = executor.send('df -k \n')
        print(str(output))
        time.sleep(10)
        rec_data = executor.recv(9999)
        return rec_data

    def storeinafile(self, path, output):
        with open(path, 'r+') as f:
            f.write(str(output))

    '''def delete_oldfiles(self,path):
        files=os.listdir(path)
        for i in files:
            if os.path.isfile(i):
                os.remove(i)'''

    def failurecheck(self, path, threshold=1):
        with open(path + '/pre.txt', 'r') as f1:
            lines = f1.read()
            pre_use = re.findall(r'[0-9]+%', lines)[0]
            pre_use = re.findall(r'[0-9]+', pre_use)

        with open(path + '/post.txt', 'r') as f:
            lines = f.read()
            used = re.findall(r'\d+%', lines)[0]
            used = re.findall(r'[0-9]+', used)

        if (int(pre_use[0]) + int(threshold) < int(used[0])):
            print("*WARN* fail")

        else:
            print("no increase in used memory")

    def Establish_SSH_Connection(self, host, username, password):
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            client.connect(host, username=username, password=password,
                           banner_timeout=5)
            print("SSH connection established to - " + str(host))
            return client
        except BaseException as err:
            raise 'ssh to system module resulted in an ' \
                  'exception :{}'.format(err)
            print("halting the memusage program")
            # os._exit(0)
            return None

    def current_memoryusage(self, host='192.168.255.129', username='toor4nsn',
                            password='oZPS0POrRieRtu',
                            dest='/home/ute/Desktop/mem'):
        # self.delete_oldfiles(path)
        obj = self.Establish_SSH_Connection(host, username, password)
        output = self.executecommand(obj)
        dest = dest + "/pre.txt"
        path = Path(dest)
        path.touch(exist_ok=True)
        self.storeinafile(path, output)

    def post_memoryusage(self, host='192.168.255.129', username='toor4nsn',
                         password='oZPS0POrRieRtu',
                         dest='/home/ute/Desktop/mem', threshold=1):
        obj = self.Establish_SSH_Connection(host, username, password)
        output = self.executecommand(obj)
        path1 = dest + "/post.txt"
        path1 = Path(path1)
        path1.touch(exist_ok=True)
        self.storeinafile(path1, output)
        self.failurecheck(dest, threshold)
