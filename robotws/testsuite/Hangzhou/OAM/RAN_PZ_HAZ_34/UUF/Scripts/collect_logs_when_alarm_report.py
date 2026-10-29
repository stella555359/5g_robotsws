import threading
import time
import sys
import ast
from taf.transport.ssh import ssh
import gnb_handler
import UUF_common
import enable_ssh_to_ru

csn = ssh()


def get_unexpected_active_history_alarm(ignore_fault, ignore_history_fault, conn='get_alarm'):
    if_collect_log = False
    active_alarm = gnb_handler.get_active_alarms(connection=conn, except_alarms=ignore_fault)
    history_alarm = gnb_handler.get_history_alarms(connection=conn, except_alarms=ignore_history_fault)
    print('active_alarm:%s' % active_alarm)
    print('history_alarm:%s' % history_alarm)
    print('----------------------------------')
    if active_alarm != [] or history_alarm != []:
        if_collect_log = True
    return if_collect_log


def save_snapshot_via_ssh(vm_ip, vm_username, vm_password, log_location):
    try:
        vm_conn = csn.connect_to(hostname=vm_ip, username=vm_username, password=vm_password, alias='vm')
        asik_conn = csn.connect_to('192.168.255.129', 'toor4nsn', 'oZPS0POrRieRtu', proxy='vm', alias='asik_log')
        asik_shell = asik_conn.invoke_shell()
        asik_shell.send('telnet 0 15007\n')
        time.sleep(2)
        print(asik_shell.recv(65535))
        asik_shell.send('log -a -z snapshot.zip\n')
        _wait_for_special_string(asik_shell, 'AaShell>', 90)
        vm_shell = vm_conn.invoke_shell()
        time_stamp = time.strftime("%Y-%m-%d_%H-%M-%S")
        vm_shell.send('scp toor4nsn@192.168.255.129:/ram/snapshot.zip %s/snapshot_%s.zip\n' % (log_location,
                                                                                               time_stamp))
        time.sleep(2)
        vm_shell.send('oZPS0POrRieRtu\n')
        time.sleep(5)
        _wait_for_special_string(vm_shell, '$', 20)
        asik_shell.send('quit\n')
        asik_shell.send('rm /ram/snapshot.zip\n')
        print(asik_shell.recv(65535))
    finally:
        csn.disconnect(connection='vm')


def _wait_for_special_string(shell, special_string, timeout):
    time_start = time.time()
    time_end = time.time()
    output = ''
    while time_end - time_start < timeout:
        time.sleep(5)
        output = output + shell.recv(65535).decode()
        if special_string in output:
            break


class CollectRuLog(threading.Thread):
    def __init__(self, vm_addr, vm_user, vm_pass, ru_addr, ru_type, release, log_location, gnb_vm_ip, gnb_vm_username,
                 gnb_vm_password, if_need_open_lmi):
        threading.Thread.__init__(self)
        self.vm_addr = vm_addr
        self.vm_user = vm_user
        self.vm_pass = vm_pass
        self.ru_addr = ru_addr
        self.ru_type = ru_type
        self.release = release
        self.log_location = log_location
        self.gnb_vm_ip = gnb_vm_ip
        self.gnb_vm_username = gnb_vm_username
        self.gnb_vm_password = gnb_vm_password
        self.if_need_open_lmi = if_need_open_lmi

    def run(self):
        print('start...%s' % self.vm_addr)
        pc_conn = None
        ru_conn = None
        ru_user_pass = UUF_common.get_ru_username_password(self.ru_type, self.release, if_need_handle_dollar=False)
        if self.if_need_open_lmi:
            enable_ssh_to_ru.enable_ssh_to_ru(self.vm_addr, self.vm_user, self.vm_pass, self.ru_addr, ru_user_pass)
        try:
            vm_conn = csn.connect_to(hostname=self.gnb_vm_ip, username=self.gnb_vm_username,
                                     password=self.gnb_vm_password, alias='vm_%s' % self.vm_addr)
            ru_conn, pc_conn = UUF_common.connet_to_ru(self.vm_addr, self.vm_user, self.vm_pass, self.ru_addr,
                                                       self.ru_type, self.release)
            ru_shell = ru_conn.invoke_shell()
            ru_shell.send('ccsShell.sh log -a -c full -z RULOG_%s.tar\n' % self.vm_addr)
            _wait_for_special_string(ru_shell, 'AaShell>', 5)
            _wait_for_special_string(ru_shell, 'AaShell>', 90)
            pc_shell = pc_conn.invoke_shell()
            pc_shell.send('scp %s@%s:/ram/RULOG_%s.tar /home/ute/RULOG_%s.tar\n' % (ru_user_pass[0]['username'],
                                                                                    self.ru_addr, self.vm_addr,
                                                                                    self.vm_addr))
            time.sleep(2)
            output = pc_shell.recv(65535).decode()
            print('-----output----------')
            print(output)
            if 'ECDSA key' in output:
                pc_shell.send('ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "%s"\n' % self.ru_addr)
                time.sleep(2)
                pc_shell.send('scp %s@%s:/ram/RULOG_%s.tar /home/ute/RULOG_%s.tar\n' % (ru_user_pass[0]['username'],
                                                                                        self.ru_addr, self.vm_addr,
                                                                                        self.vm_addr))
                time.sleep(2)
                pc_shell.send('yes\n')
                time.sleep(2)
            pc_shell.send('%s\n' % ru_user_pass[0]['password'])
            _wait_for_special_string(pc_shell, '$', 20)
            ru_shell.send('quit\n')
            ru_shell.send('rm /ram/RULOG_%s.tar\n' % self.vm_addr)
            print(ru_shell.recv(65535))
            vm_shell = vm_conn.invoke_shell()
            time_stamp = time.strftime("%Y-%m-%d_%H-%M-%S")
            vm_shell.send('scp %s@%s:/home/ute/RULOG_%s.tar %s/RULOG_%s_%s.tar\n' % (self.vm_user, self.vm_addr,
                                                                                     self.vm_addr, self.log_location,
                                                                                     self.vm_addr, time_stamp))
            time.sleep(2)
            output = vm_shell.recv(65535).decode()
            print(output)
            if 'ECDSA key' in output:
                vm_shell.send('ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "%s"\n' % self.vm_addr)
                time.sleep(2)
                vm_shell.send('scp %s@%s:/home/ute/RULOG_%s.tar %s/RULOG_%s_%s.tar\n' % (self.vm_user, self.vm_addr,
                                                                                         self.vm_addr,
                                                                                         self.log_location,
                                                                                         self.vm_addr, time_stamp))
                time.sleep(2)
                vm_shell.send('yes\n')
                time.sleep(2)
            vm_shell.send('%s\n' % self.vm_pass)
            time.sleep(2)
            _wait_for_special_string(vm_shell, '$', 20)
            pc_shell.send('rm /home/ute/RULOG_%s.tar\n' % self.vm_addr)
            print(pc_shell.recv(65535))
        finally:
            UUF_common.disconnect_ru(pc_conn, ru_conn)
            csn.disconnect(connection='vm_%s' % self.vm_addr)
            print('stop...%s' % self.vm_addr)


def collect_ru_log_via_control_pc(ru_info, release, log_location, gnb_vm_ip, gnb_vm_username, gnb_vm_password,
                                  if_need_open_lmi):
    threads = []
    if not isinstance(ru_info, (dict, list)):
        ru_info = ast.literal_eval(ru_info)
    else:
        ru_info = ru_info
    for ru in ru_info:
        vm_addr = ru['ctrl_addr']
        vm_user = ru['ctrl_username']
        vm_pass = ru['ctrl_password']
        ru_addr = ru['addr']
        ru_type = ru['ru_type']
        if vm_addr == '1.1.1.1':
            continue
        thread = CollectRuLog(vm_addr, vm_user, vm_pass, ru_addr, ru_type, release, log_location, gnb_vm_ip,
                              gnb_vm_username, gnb_vm_password, if_need_open_lmi)
        thread.daemon = True
        thread.start()
        threads.append(thread)
    for thread in threads:
        thread.join()
    print('end of main ..')


if __name__ == "__main__":
    ip = sys.argv[1]
    username = sys.argv[2]
    password = sys.argv[3]
    ru_info = sys.argv[4]
    ignore_fault = sys.argv[5]
    ignore_history_fault = sys.argv[6]
    vm_ip = sys.argv[7]
    vm_username = sys.argv[8]
    vm_password = sys.argv[9]
    log_location = sys.argv[10]
    release = sys.argv[11]
    if_need_open_lmi = sys.argv[12]
    need_collect_log = False
    try:
        gnb_handler.login(ip, username, password, connection='get_alarm')
        while not need_collect_log:
            need_collect_log = get_unexpected_active_history_alarm(ignore_fault, ignore_history_fault, 'get_alarm')
            if need_collect_log:
                start_time = time.time()
                save_snapshot_via_ssh(vm_ip, vm_username, vm_password, log_location)
                collect_ru_log_via_control_pc(ru_info, release, log_location, vm_ip, vm_username, vm_password,
                                              if_need_open_lmi)
                end_time = time.time()
                total = end_time - start_time
                print('total time of collect logs:%s' % total)
                need_collect_log = True
            else:
                time.sleep(30)
    finally:
        gnb_handler.logout(connection='get_alarm')
