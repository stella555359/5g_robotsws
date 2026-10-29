import time
import shutil
import re
import subprocess
import pexpect
from robot.api import logger
from taf.sbts.oam.coam.admin import admin
from os import remove
from taf.transport.ssh import interface
from taf.ul.oam.selenium_coam import selenium_coam
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from cryptography.hazmat.backends import default_backend as crypto_default_backend
from cryptography.hazmat.primitives import serialization as crypto_serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from past.builtins import xrange
from pathlib import Path
from taf.config.scf import scf
from testsuite.Wroclaw.OAM.VRF_WRO3_T04.common_resources.admin.admin_utils import (
    get_mrbts_id,
    format_dist_name
)

account_exist_in_account_matrix = ['root', 'daemon', 'bin', 'sshd', 'ntp', 'tss', 'messagebus', 'btssw', 'oprof',
                                   'nobody', 'rpc', 'dhcp', 'rpcuser', 'ftp', 'avahi', 'systemd-network',
                                   'systemd-oom', 'systemd-resolve', 'systemd-timesync', 'systemd-coredump',
                                   'toor4nsn', 'serviceuser', 'lighttpd', 'dhcpd', 'radvd']
paths_on_classical = ['/usr/bin/busybox', '/usr/bin/chage', '/usr/bin/chfn', '/usr/bin/chsh', '/usr/bin/expiry',
                      '/usr/bin/fusermount', '/usr/bin/gpasswd', '/usr/bin/mount', '/usr/bin/newgidmap',
                      '/usr/bin/newgrp', '/usr/bin/newuidmap', '/usr/bin/passwd', '/usr/bin/rcp', '/usr/bin/rlogin',
                      '/usr/bin/rsh', '/usr/bin/su', '/usr/bin/traceroute', '/usr/bin/umount', '/usr/sbin/netserver',
                      '/usr/lib/lxc/lxc-user-nic', '/usr/lib/ssh/ssh-keysign', '/usr/sbin/mount.nfs',
                      '/usr/libexec/dbus-daemon-launch-helper', '/usr/sbin/unix_chkpwd', '/usr/bin/chfn.shadow',
                      '/usr/bin/chsh.shadow', '/usr/bin/mount.util-linux', '/usr/bin/newgrp.shadow',
                      '/usr/bin/passwd.shadow', '/usr/bin/ping.iputils', '/usr/bin/su.util-linux', '/usr/bin/netperf',
                      '/usr/bin/umount.util-linux', '/usr/libexec/lxc/lxc-user-nic', '/usr/libexec/ssh/ssh-keysign']
files_with_permissions = {'passwd': '644', 'group': '644', 'shadow': '600', 'fstab': '644', 'inittab': '644'}
account_for_classical = ['root', 'toor4nsn', 'serviceuser']


def check_ssh_session_login_delay(user1, user2):
    """
    Checking the attempt and delay for toor4nsn and serviceuser. First is login and
    sending 5 times wrong password for toor4nsn and then for serviceuser. The time measurement is started when
    the password is sent. The time measurement is finished when the password is pasted and refused.
    The tolerance for delay is 4s. E.g. calculation: delay=6.15 -> 8s - 6.15s = 1.85s < 4s (tolerance)
    :return:
    """
    for user in [user1, user2]:
        child = pexpect.spawn("ssh {}@192.168.255.129".format(user))
        child.expect(['Password', 'password'])
        measured_delays = []
        for i in range(5):
            start = time.time()
            child.sendline('badpass123!')
            child.expect(['Password', 'password'])
            end = time.time()
            diff = round(float(end - start), 2)
            measured_delays.append(diff)
            logger.console("Measured ssh session login delay: " + str(diff))
        child.sendcontrol('c')

        exp_delay_in_sec = 8
        tolerance = 4
        for measured_delay in measured_delays:
            assert abs(measured_delay - exp_delay_in_sec) <= tolerance, "Exp: {} <> Act: {}".format(exp_delay_in_sec,
                                                                                                    measured_delay)


def check_webem_account_lockout(login_try):
    """
    Login to WebEM with wrong password as many times as defined in login_try. Then one attempt is made with
    expecting error.
    :param login_try: the amount of login try
    :return: None
    """
    login_try = int(login_try)
    api = admin()
    for x in range(login_try):
        try:
            time.sleep(10)
            api.connect_to(password='wrongpassword') if login_try != login_try-1 else api.connect_to()
        except Exception as e:
            if x == login_try-1:
                return e


def check_groups_credentials(data):
    """
    Checking if there's only allowed characters in gshadow file.
    :param data:
    :return: none
    """
    allowed_characters = ['x', '!', '!!', '!*']
    output = data.split('\n')[:-1]
    print(output)
    for field in output:
        assert field.split(':')[1] in allowed_characters, 'In the password field not valid entry'


def get_last_event_number_from_gnb(ip_address, events_destination="EVENT_LOG"):
    """
    This function returns the highest number of the EVENT object under EVENT_LOG.
    EVENT_LOG-<number> - the number may change, so 'event_log_number' returns actual value
    bts_info - all EVENTs from gNB
    values_list - only values from 'bts_info'
    event_list - only elements contains EVENT like: u'distName': u'/MRBTS-1/RAT-1/EVENT_LOG-4/EVENT-1'
    event_log_list_only - only 'EVENT_LOG-4/EVENT-1', without 'SYSTEM_LOG-4/EVENT-1'
    event_number_list - only numbers from 'EVENT_LOG-4/EVENT-<number>' after split with pattern
    """

    api = admin()
    conn = api.connect_to(ip_address)
    event_log_instance = api.get_managed_objects(class_name=events_destination, connection=conn)
    event_log_number = list(event_log_instance[0].values())[0].split(events_destination + "-")[1]
    bts_info = api.get_managed_objects(class_name="EVENT", connection=conn)
    values_list = []
    for i in bts_info:
        values_list.append(i.values())
    event_list = []
    for j in values_list:
        event_list.append(list(j)[0])
    event_log_list_only = []
    for k in event_list:
        if events_destination in k:
            event_log_list_only.append(k)
        else:
            continue
    event_number_list = []
    for m in event_log_list_only:
        pattern = str(events_destination + "-" + str(event_log_number) + "/EVENT-")
        number = m.split(pattern)[1]
        event_number_list.append(int(number))
    api.teardown(conn)
    return max(event_number_list)


def is_toot4nsn_key_empty(toor4nsn_key):
    """
    The function check if toor4nsn_key is empty.
    :param toor4nsn_key: the path with toor4nsn_key
    :return: empty if toor4nsn is empty; if not empty - information about it
    """
    assert toor4nsn_key == "", "Toor4nsn authorized key file is not empty"


def check_local_account_for_no_extra_users(connection):
    """
    Checking if command will return users that will be others than allowed account for classical.
    If user is not root, toor4nsn or serviceuser - the AssertionError will be raised.
    :param connection: connection to BTS via SSH
    :return: None
    """
    present_users = []
    ssh = interface.ssh()
    for user in ssh.execute(command="cat  /etc/passwd | grep -v -E 'false|nologin'",
                            connection=connection).split('\n'):
        present_users.append(str(user.split(':')[0]))
    present_users.remove("")
    logger.console(present_users)
    assert account_for_classical == present_users, "invalid accounts"


def check_predefined_users(data):
    """
    Checking in first assert if users from passwd file are in account_matrix (if allowed only
    supported and allowed users).
    Checking if second assert if not supported users has /bin/false or /nologin permission
    what means that they cannot login.
    :param data:
    :return: none
    """
    whitelist = ['root', 'toor4nsn', 'serviceuser']
    output = data.split('\n')[:-1]
    account_list = [user.split(':')[0] for user in output]
    assert all([account in account_exist_in_account_matrix for account in account_list]), \
        'On BTS find account which not exist in account matrix'
    list_to_check = [user.split(':') for user in output]
    list_with_login_disable = [user for user in list_to_check if user[0] not in whitelist]
    for login_field in list_with_login_disable:
        assert '/bin/false' or '/sbin/nologin' in str(login_field[-1][:-1]), \
            'Login is possible for {}'.format(login_field[0])


def force_login_to_webem(software_version, delay, passwords, user='Nemuadmin', ip="https://192.168.255.129"):
    """
    Allow for performing many login attempts during single opened web browser session.
    Collect messages from text box as responses of login attempts.
    :param software_version    BTS software version
    :param delay:       Pauses in s between login attempts
    :param passwords:   List of passwords for login attempts
    :param user:        Webem username
    :param ip:          Address of Webem
    :return:            Collected messages which indicates results of login attempts
    """
    if 'SBT' in software_version:
        username_path = "//form/div[1]/input"
        password_path = "//form/div[2]/input"
        login = '//div[3]/p-button/button/span'
        error_div = '//*[@class="error-message"]'

    else:
        username_path = "//form/div[2]/input"
        password_path = "//form/div[3]/input"
        login = '//div[1]/div/ui-button/button'
        error_div = '//*[@class="error"]'
    messages = []
    driver = webdriver.Firefox()
    driver.get(ip)
    driver.implicitly_wait(10)
    username_in_webem = driver.find_element_by_xpath(username_path)
    username_in_webem.send_keys(user)
    for password in passwords:
        password_to_webem = driver.find_element_by_xpath(password_path)
        password_to_webem.send_keys(password)
        login_button = driver.find_element_by_xpath(login)
        login_button.click()
        driver.implicitly_wait(1)
        output = driver.find_element_by_xpath(error_div)
        logger.console(output.text)
        messages.append(output.text)
        driver.find_element_by_xpath(password_path).clear()
        time.sleep(delay)
    driver.quit()
    return messages


def check_SUID_SGID(connection):
    """
    Checking if elements in output from the executed command are allowed (the same as mentioned in
    the paths_on_classical variable).
    :param connection: connection to the BTS via SSH
    :return: None
    """
    ssh = interface.ssh()
    output = ssh.execute(command=r"find / -xdev \( -perm -4000 -o -perm -2000 \) -type f -print",
                         connection=connection).split('\n')
    output = output[:-1]
    file_to_check = [x.strip() for x in output]
    for x in file_to_check:
        logger.console(x)
    if output:
        assert all(item in paths_on_classical for item in file_to_check), 'Wrong permissions for paths: {}'.\
            format([x for x in file_to_check if x not in paths_on_classical])


def check_file_permission(file, connection):
    """
    Checkig the permission for the files. Checking first if file is hosts, issue or services - if yes, the
    permission is checked by ls -la command.
    If not, the stat -c command is executed and it is compared with the variable 'files_with_permissions'
    :param file: name of file that must be checked
    :param connection: connection to BTS via SSH
    :return: None
    """
    ssh = interface.ssh()
    if file in ['hosts', 'issue', 'services', 'shadow']:
        output = ssh.execute(command='ls -la /etc/{}'.format(file), connection=connection).split()[0][-2]
        assert output == '-', 'File /etc/{} has set write permision for other'.format(file)
    else:
        output = ssh.execute(command='stat -c "%a %n" /etc/{}'.format(file), connection=connection).split()[0]
        assert files_with_permissions['{}'.format(file)] == output, 'file {} has wrong permission: {}, should be: {}'.\
            format(file, output, files_with_permissions['{}'.format(file)])


def check_file_permission_rules(file, connection):
    """
    Checking the permission rules by checking owner of the file and permission of the file.
    :param file: name of file that must be checked
    :param connection: connection to BTS via SSH
    :return: None
    """
    ssh = interface.ssh()
    exist = ssh.execute(command='ls /etc/{}'.format(file), connection=connection)
    file_exist = False if 'No such file or directory' in exist else True
    if file_exist:
        logger.console(file)
        output = ssh.execute(command='ls -la /etc/{}'.format(file), connection=connection).split()
        assert output[2] == 'root', 'root is not owner {} file'.format(file)
        check_file_permission(file, connection)


def check_ssh_bruteforce_attempt(address, username, good_password, wrong_password, number):
    """
    Logging too toor4nsn with wrong password twice. Then expect message with information about too many
    authentication failures. Then waiting for next SSH login attempt which should end with success.
    :param address: address tp login
    :param username: username to login
    :param good_password: good password
    :param wrong_password: wrong password
    :param number: number of attempt to login
    :return: None
    """
    number = int(number)
    child = pexpect.spawn("ssh {}@{}".format(username, address))
    child.expect(['Password', 'password'])
    for i in range(number):
        child.sendline(wrong_password)
        child.expect(['Password', 'password'])
    child.sendline(wrong_password)
    child.expect(['Too many authentication failures'])
    logger.console('Wait for ssh login session recovery...')
    time.sleep(35)
    ssh = interface.ssh()
    connection = ssh.connect_to(address, username, good_password)
    logger.console('Connected...')
    ssh.disconnect(connection)


def check_webem_bruteforce_attempt(user):
    """
    The WebEM bruteforce attempt function. Checking if the account is locked when too many
    failed login attempt will be proceed
    :param user: the user
    :return: none
    """
    interface = selenium_coam()
    interface.enable_virtual_display()
    api = admin()
    connection = api.connect_to()
    software_version = connection.get_sw_version()
    connection.disconnect()
    passwords = ["PASSW32432@", "PASSW2343", "GFDJRKEwfjdk", "343hjfkdsu", "2384932d", "543Hy342!"]
    messages = force_login_to_webem(software_version=software_version, delay=1, user=user, passwords=passwords)
    for i, msg in enumerate(messages, start=1):
        if i == 6:
            exp_msg = "access denied due to account is locked"
        else:
            exp_msg = "invalid username or password"
        assert exp_msg in msg.lower(), "Exp: {} <> Act: {}".format(exp_msg, msg)
    logger.console("Waiting for account lockdown...")
    time.sleep(125)


def check_free_space(path, connection):
    '''
    Checking the free space on the BTS (SMOD) by command df -h /var/log | awk 'FNR == 2 {print $4}'.
    :param connection:
    :return: the free space on the BTS
    '''
    ssh = interface.ssh()
    output = ssh.execute(command="df -BM {} | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'".format(path),
                         connection=connection)
    return output


def delete_list_from(dist_name, abbreviation, connection, skip_parameter_relation_errors=False,
                     timeout=900):
    """
    Deleting the parameters from the SCF.
    :param dist_name: object path
    :param abbreviation: abbreviation of parameter
    :param connection: connection
    :param skip_parameter_relation_errors: False/True
    :param timeout: 900
    :return:
    """
    if 'MRBTS-' not in dist_name:
        bts_id = get_mrbts_id(connection)
        dist_name = 'MRBTS-{}/'.format(bts_id) + dist_name
    connection.perform_parameter_recommissioning(dist_name=dist_name, parameter=abbreviation,
                                                 operation='delete', value=False, timeout=timeout,
                                                 skip_parameter_relation_errors=skip_parameter_relation_errors)
    logger.console("Performed list delete on BTS ({}/{})".format(dist_name, abbreviation))


def delete_files(list_of_filepaths):
    """
    Remove all elements from the list.
    :param list_of_filepaths: the list of files
    :return: N/A
    """
    for filepath in list_of_filepaths:
        if type(filepath) is list:
            for fp in filepath:
                remove(fp)
        else:
            remove(filepath)


def check_exceptions(output):
    """
    Checking the exeception. Checking the output if it's correct according to the pattern
     /tftpboot/slot0./dev[ABC]/bootdt.uim - if not AssertionError is raised because unathorized file was found.
    :param output:
    :return:
    """
    files_to_remove = ["cgroup.event_control", "sys-fs-fuse-connections.mount",
                       "sys-kernel-config.mount", "sys-kernel-debug.mount", "bootdt.uim"]
    paths_to_remove = ["/ram/", "/tmp/", "/ffs/"]

    def should_remove(line):
        return any(path in line for path in paths_to_remove) or \
               any(re.search(fr"/{name}$", line) for name in files_to_remove)

    output = output.split('\n')[:-1]
    files_to_check = [x.split()[-1] for x in output]
    filtered = [line for line in files_to_check if not should_remove(line)]
    if filtered:
        raise AssertionError(f"Found unauthorized files: {filtered}")


def get_newest_data_from_logs(connection):
    '''
    Getting the newest data from the BTS.
    :param connection:
    :return: the data that was the last visible on BTS
    '''
    ssh = interface.ssh()
    output = str(ssh.execute(command="tail -1 /var/log/trs | awk '{print $1}'",
                             connection=connection).split('\n')[0][11:16])
    return output


def create_file_to_upload(size, filename):
    '''
    Creating the file with the defined size.
    :param size: the size of file
    :param filename: the name of file
    :return: none
    '''
    subprocess.call(['truncate', '-s', '{}M'.format(size), '{}'.format(filename)])


def compare_free_space(free_space):
    '''
    Comparing the free space. If the free space is bigger that 3, the error is visible.
    :param free_space:
    :return: error if folder is not full; none if it's full
    '''
    assert float(free_space) <= 3.0, 'Tmp folder is not full'


def remove_log_file(filename, path_to_file, ip_address, username, password):
    '''
    Removing the file.
    :param filename: name of file
    :param path_to_file: path to file
    :param ip_address: address to BTS
    :param username: username to login to BTS
    :param password: password to login to BTS
    :return: none
    '''
    ssh = interface.ssh()
    ssh.connect_to(ip_address, username, password)
    ssh.execute(command="rm {}/{}".format(path_to_file, filename))
    ssh.disconnect()


def check_logs(date_before, date_after):
    '''
    Checking the date of the logs
    :param date_before: date before
    :param date_after: date after
    :return:
    '''
    logger.console('NOTE: Differen between time in log file and os time could be shifted around 1 hour')
    assert date_before != date_after, 'Time in log is not correct'


def create_new_user(number, connection):
    '''
    Creating the new users on the BTS
    :param number: the number of the users that must be created
    :param connection: connection
    :return: none
    '''
    ssh = interface.ssh()
    for user_count in range(int(number)):
        ssh.execute(command='useradd test{}'.format(user_count), connection=connection)


def check_uniq_id(number, connection):
    '''
    Checking the unique ID of the user
    :param number: the number of the users
    :param connection: connection
    :return: none if UID are not the same, have unique UID; AssertionError is raised if UID is non unique
    '''
    uid_list = []
    ssh = interface.ssh()
    for user_count in range(int(number)):
        output = int(ssh.execute(command='id -u test{}'.format(user_count), connection=connection).split('\n')[0])
        uid_list.append(output)
    logger.console(uid_list)
    for x in uid_list:
        assert x != 0, 'New user has UID == 0'
    flag = 0
    flag = len(set(uid_list)) == len(uid_list)
    assert flag, 'New user do not have unique uid. UID list: {}'.format(uid_list)


def delete_new_user(number, connection):
    '''
    Deleting the users that was created
    :param number: the number of the users
    :param connection: connection
    :return: none
    '''
    ssh = interface.ssh()
    for user_count in range(int(number)):
        ssh.execute(command='userdel -r test{}'.format(user_count), connection=connection)


def log_to_webem_and_check_logout_timer(username, password):
    '''
    Login to WebEM and checking if the logout will be proceed after 600s of inactivity.
    :param username: username to WebEM
    :param password: password to WebEM
    :return: None
    '''
    profile = webdriver.ChromeOptions()
    profile.add_argument('ignore-certificate-errors')
    driver = webdriver.Chrome(chrome_options=profile)
    driver.get("https://192.168.255.129")
    username_field = driver.find_element_by_id("login-username")
    password_field = driver.find_element_by_id("login-password")
    assert driver.find_element_by_xpath('//input[@type="password"]'), 'Password is no hiding'
    username_field.send_keys(username)
    password_field.send_keys(password)
    login = driver.find_element(By.XPATH, '//span[text()="Login"]')
    login.click()
    try:
        legal_notice_element = WebDriverWait(driver, 15).\
            until(EC.element_to_be_clickable((By.XPATH, '//button[text()="Confirm]')))
        legal_notice_element.click()
    except Exception as e:
        pass
    login_time = time.time()
    for i in range(700):
        try:
            driver.find_element(By.XPATH, '//site-runtime-views/div/ul/li[1]/a')
        except Exception:
            logout_time = time.time()
            break
        time.sleep(1)
    else:
        raise RuntimeError(f"login timeout took too long for {username}")
    difference_time = logout_time - login_time
    logger.console('Time difference: {}'.format(difference_time))
    WebDriverWait(driver, 5).until(EC.element_to_be_clickable((By.XPATH, '//span[text()="Login"]')))
    driver.quit()


def create_ssh_keypair_for(owner):
    """
`   Generating the ssh keypairs
    :param owner: serviceuser/toor4nsn
    :return: keypaths of created keypairs
    """
    keypaths = []
    key = rsa.generate_private_key(
        backend=crypto_default_backend(),
        public_exponent=65537,
        key_size=2048
    )
    private_key = key.private_bytes(
        crypto_serialization.Encoding.PEM,
        crypto_serialization.PrivateFormat.TraditionalOpenSSL,
        crypto_serialization.NoEncryption())
    public_key = key.public_key().public_bytes(
        crypto_serialization.Encoding.OpenSSH,
        crypto_serialization.PublicFormat.OpenSSH
    )
    with open("private_{}.key".format(owner), 'wb') as priv:
        priv.write(private_key)
        keypaths.append("private_{}.key".format(owner))
    with open("public_{}.key".format(owner), 'wb') as pub:
        pub.write(public_key)
        keypaths.append("public_{}.key".format(owner))
    logger.console("SSH keypair for {} created.".format(owner))
    return keypaths


def return_first_element(list_of_elements):
    """
    Returning the first element from the list
    :param list_of_elements: list of the keys
    :return: the first element of the list
    """
    return list_of_elements[0]


def generate_keys_and_add_them_to_bts(add_to_bts, number_of_keys, owner, destination_name, connection):
    """
    Adding the key to the BTS or only generate the keys but not add them to BTS.
    :param add_to_bts: True= adding the key to the BTS; false = generate keys without adding them to BTS.
    :param number_of_keys: the number of the keys
    :param owner: toor4nsn/serviceuser keys
    :param destination_name: the destination of the keys that will be added on the BTS
    :param connection: connection
    :return: none
    """
    payload = []
    list_of_keypaths = []
    for i in xrange(int(number_of_keys)):
        keypaths = create_ssh_keypair_for(owner + str(i))
        logger.console(keypaths)
        list_of_keypaths.append(keypaths)
        public_key_path = keypaths[-1]
        if add_to_bts:
            with open(public_key_path, 'r') as f:
                public_key = f.read().replace('\n', '')
                payload.append({'keyDescription': '# TEST', 'keyValue': public_key})
    if add_to_bts:
        change_parameter_on_bts('MRBTS-{}/MNL-1/MNLENT-1/SECADM-1'.format(get_mrbts_id(connection)),
                                destination_name, payload, connection)
    return list_of_keypaths


def get_first_private_key_path_from_list_of_keypaths(list_of_keypaths):
    """
    Get the first element from the list that it's part of the list (list in list)
    :param list_of_keypaths: the list in the list
    :return: return the first element of the list in list
    """
    return list_of_keypaths[0][0]


def copy_files(list_of_filepaths, new_directory):
    """
    Copy file from one to the different directory
    :param list_of_filepaths: the reference to the object that should be copied
    :param new_directory: path to the new directory
    :return: none
    """
    Path(new_directory).mkdir(parents=True, exist_ok=True)
    for filepath in list_of_filepaths:
        if type(filepath) is list:
            for fp in filepath:
                shutil.copy(fp, new_directory)
        else:
            remove(filepath)


def get_all_keys(path, user, bts_id):
    """
`   Getting all the keys that are added to BTS
    :param path: the path to the SCF
    :param user: toor4nsn/serviceuser keys
    :param bts_id: the ID of the BTS
    :return: the key
    """
    scf_obj = scf()
    scf_obj.load_scf(path)
    key = scf_obj.get_all_values_from_scf(dist_name='MRBTS-{}/MNL-1/MNLENT-1/SECADM-1'.format(bts_id),
                                          p_name='keyValue',
                                          list_name=user)
    return key


def compare_keys(key_in_file, key_on_bts):
    """
    Comparing the keys, if there are the same or not
    :param key_in_file:
    :param key_on_bts:
    :return: none if keys are the same; if not return information about it
    """
    assert all([key in key_on_bts for key in key_in_file]), "Keys on bts are not the same in file"


def change_parameter_on_bts(
    dist_name,
    param_name,
    param_value,
    connection,
    skip_parameter_relation_errors=False,
    timeout=900,
):
    dist_name = format_dist_name(dist_name, connection)
    connection.perform_parameter_recommissioning(
        dist_name=dist_name,
        parameter=param_name,
        operation="update",
        value=param_value,
        timeout=timeout,
        skip_parameter_relation_errors=skip_parameter_relation_errors,
    )
    logger.console(
        "Performed parameter change on BTS ({}/{}), {}".format(
            dist_name, param_name, param_value
        )
    )
