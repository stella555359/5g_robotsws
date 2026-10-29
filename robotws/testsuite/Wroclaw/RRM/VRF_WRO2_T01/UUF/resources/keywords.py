import paramiko


'''
    def check_and_update_flag()
    This function check, if already flag '0x10041=5' is in the path '/rom/swconfig.txt'.
    If not, this function will add this flag to this file.
    Connects to a remote server via SSH, checks for a specific flag in a file, and adds the flag if it is not present.
    This function performs the following steps:
    1. Connects to the remote server using SSH with the provided hostname, username, and password.
    2. Opens the specified file in read and write mode.
    3. Reads the content of the file and checks if the specified flag is present.
    4. If the flag is not present, it appends the flag to the file.
    5. Closes the file and the SSH connection.
'''


def check_and_update_flag():
    hostname = '192.168.255.129'
    username = 'toor4nsn'
    password = 'oZPS0POrRieRtu'
    file_path = '/rom/swconfig.txt'
    flag = '0x10041=5'
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        ssh.connect(hostname, username=username, password=password)
        print('Connected.')

        sftp = ssh.open_sftp()
        try:
            file = sftp.open(file_path, 'r+')
            try:
                content = file.read().decode('utf-8')
                if flag in content:
                    print('Flag is already in the file')
                else:
                    print('Flag is not in the file. Adding flag to the file...')
                    file.write(f'\n{flag}\n'.encode('utf-8'))
                    print('Flag is in the file now.')
            finally:
                file.close()
        finally:
            sftp.close()

    except Exception as e:
        print(f'The file is not available or it is no connection with: {e}')
    finally:
        ssh.close()


if __name__ == '__main__':
    check_and_update_flag()
