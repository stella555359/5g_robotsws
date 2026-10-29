import os
import crypt


def add_vm_user(username, password):
    encPass = crypt.crypt(password, "22")
    os.system("sudo useradd -p " + encPass + " " + username)


def vm_network_config():
    os.system('sudo chmod 777 /etc/ssh/sshd_config')
    os.system('echo -e "port 22022" >> /etc/ssh/sshd_config')
    os.system('sudo service ssh restart')
    os.system('sudo iptables -I INPUT -p tcp --dport 22022 -j ACCEPT')


# if __name__ == "__main__":
#     # username = "coam"
#     # password = "zO&n1W*ktp7"
#     # add_vm_user(username, password)
#     vm_network_config()
