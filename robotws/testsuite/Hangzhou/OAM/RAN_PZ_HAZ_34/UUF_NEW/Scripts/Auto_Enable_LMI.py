import os
import sys
import time
import ast
import subprocess


def send_commands(ru_info_file, ru_prompt, ru_username, ru_password):
    previous_logins = set()
    while True:
        current_logins = set()
        with open(ru_info_file, 'rb') as f:
            for line in f:
                if ru_prompt in line.strip():
                    current_logins.add(line.strip())

        new_logins = current_logins - previous_logins
        for login in new_logins:
            send_login_commands(ru_username, ru_password)

        previous_logins = current_logins

        if not previous_logins:
            continue


def send_login_commands(ru_username, ru_password):
    ru_info = [
        {"username": ru_username, "password": ru_password}
    ]
    for item in ru_info:
        if not isinstance(item, dict):
            item_dict = ast.literal_eval(item)
        else:
            item_dict = item
        command1 = b'echo "' + \
            item_dict['username'].encode() + b'" > /dev/ttyUSB0\n'
        command2 = b'echo "' + \
            item_dict['password'].encode() + b'" > /dev/ttyUSB0\n'
        subprocess.run([b"stty", b"-F", b"/dev/ttyUSB0", b"115200", b"parodd"])
        time.sleep(2)

        with open("/tmp/putty.txt", "rb") as f:
            file_content = f.read()
            try:
                decoded_content = file_content.decode('utf-8')
            except UnicodeDecodeError:
                decoded_content = file_content.decode('latin-1')
            print(decoded_content)
        subprocess.run(command1, shell=True)
        time.sleep(1)

        with open("/tmp/putty.txt", "rb") as f:
            file_content = f.read()
            try:
                decoded_content = file_content.decode('utf-8')
            except UnicodeDecodeError:
                decoded_content = file_content.decode('latin-1')
            print(decoded_content)
        subprocess.run(command2, shell=True)
        time.sleep(1)

        with open("/tmp/putty.txt", "rb") as f:
            file_content = f.read()
            try:
                decoded_content = file_content.decode('utf-8')
            except UnicodeDecodeError:
                decoded_content = file_content.decode('latin-1')
            print(decoded_content)
        print(b'*********sudo lmi-eth on***************')
        subprocess.run([b'echo "sudo lmi-eth on" > /dev/ttyUSB0'], shell=True)
        time.sleep(1)


if __name__ == "__main__":
    ru_info_file = sys.argv[1]
    ru_prompt = sys.argv[2]
    ru_username = sys.argv[3]
    ru_password = sys.argv[4]
    print(ru_info_file)
    print(ru_prompt)
    print(ru_username)
    print(ru_password)
    send_commands(ru_info_file, ru_prompt, ru_username, ru_password)
