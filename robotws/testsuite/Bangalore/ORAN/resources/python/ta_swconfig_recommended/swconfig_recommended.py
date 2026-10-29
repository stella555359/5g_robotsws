import subprocess
import time
import os
import paramiko


def _execute(cmds):
    for i in cmds:
        os.system(i)


def btscheck(ip):
    start_time = time.time()
    count = 0
    while time.time() - start_time < 180:
        result = subprocess.run(["ping", "-c", "1", ip], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if result.returncode == 0:
            print("Server is Up!")
            count = count + 1
            if count > 15:
                break
        else:
            print("Server is down!")
        time.sleep(1)


def swConfig(swconfigfilepath, ip="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"):
    cmd_backup = ['sshpass -p \"' + password + '\" scp ' + username + '@' +
                  ip + ':/ffs/run/swconfig_backup.txt .']
    cmd = ['sshpass -p \"' + password + '\" scp ' + swconfigfilepath + ' ' + username +
           '@' + ip + '://ffs/run/swconfig.txt']
    ssh = paramiko.SSHClient()
    # Load SSH host keys.
    ssh.load_system_host_keys()
    # Add SSH host key automatically if needed.
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    # Connect to router using username/password authentication.
    ssh.connect(ip, username=username, password=password)
    # Run command.
    sh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command('mv //ffs/run/swconfig.txt //ffs/run/swconfig_backup.txt')
    output = ssh_stdout.readlines()
    print(output, cmd)
    _execute(cmd_backup)
    time.sleep(3)
    _execute(cmd)
    time.sleep(3)
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("reboot")
    output = ssh_stdout.readlines()
    # Close connection.
    ssh.close()
    btscheck(ip)


if __name__ == '__main__':
    swConfig(swconfigfilepath="/home/ute/swconfig_recommended_CLOUD.txt")
