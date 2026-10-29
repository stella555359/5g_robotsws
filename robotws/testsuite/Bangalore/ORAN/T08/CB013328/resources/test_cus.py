import paramiko
import time
import re


def cusmmilogin():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    # Define connection details
    hostname = "192.168.200.1"
    username = "toor4nsn"
    prompt = ">"
    password = "oZPS0POrRieRtu"
    try:
        ssh.connect(hostname, username=username, password=password, port=22)
        shell = ssh.invoke_shell()
        shell.send("mmi 2:1" + "\n")
        time.sleep(3)
        output = shell.recv(1024).decode('utf-8')
        print("Command output:")
        print(output)
        shell.send("dynamic_prach_conf_disp 0" + "\r\n")
        time.sleep(23)
        output = shell.recv(8192).decode('utf-8')
        print("Command output:", output)
        return (output)
    except paramiko.ssh_exception.AuthenticationException:
        print("Authentication failed. Please check your credentials.")

    finally:
        ssh.close()


def get_cus_output(result):
    pattern = r"fftSize=(.*?)scs"
    match = re.search(pattern, result)
    return match.group(1) if match else "Not found"
