import os
import time
from threading import Thread
from taf.transport.ssh import ssh
import functools


class BackgroundTask():
    def __init__(self):
        self.running = True
        self.timer_obj = None
        self.ssh = ssh()
        self.AP_IP = '192.168.200.1'
        self.gNB_IP = '192.168.255.129'
        self.gnb_pcap_copy_gz = 'scp {}:/tmp/*pcap*gz {}/bts_bip'
        self.gnb_pcap_copy = 'scp {}:/tmp/*pcap* {}/bts_bip'
        self.ap_pcap_copy = 'scp {}:/tmp/*pcap* {}/airphone_bip'
        self.vm_log_path = ''

    def login_to_ap(self):
        try:
            self.ssh.connect_to(self.AP_IP, 'toor4nsn', 'oZPS0POrRieRtu', alias='AP')
        except ConnectFailedError as e:
            logger.error('SSH Login To AP Failed with error {}'.format(str(e)))
            return False
        return True

    def login_to_gnb(self):
        try:
            self.ssh.connect_to(self.GNB_IP, 'toor4nsn', 'oZPS0POrRieRtu', alias='GNB')
        except ConnectFailedError as e:
            logger.error('SSH Login To GNB Failed with error {}'.format(str(e)))
            return False
        return True

    def disconnect_ap(self):
        try:
            self.ssh.disconnect(connection='AP')
        except Exception as e:
            pass
        return

    def disconnect_gnb(self):
        try:
            self.ssh.disconnect(connection='GNB')
        except Exception as e:
            pass
        return

    def gnb_ssh_connection(func):
        @functools.wraps(func)
        def wrapper(self, *args, **kwargs):
            try:
                if self.login_to_gnb():
                    return func(self, *args, **kwargs)
            finally:
                self.disconnect_gnb()
        return wrapper

    def ap_ssh_connection(func):
        @functools.wraps(func)
        def wrapper(self, *args, **kwargs):
            try:
                if self.login_to_ap():
                    return func(self, *args, **kwargs)
            finally:
                self.disconnect_ap()
        return wrapper

    @ap_ssh_connection
    @gnb_ssh_connection
    def bip_pcap_log_copy(self, log_path):
        while self.running:
            os.system(self.gnb_pcap_copy_gz.format(self.gNB_IP, log_path))
            os.system(self.ap_pcap_copy.format(self.AP_IP, log_path))
            print("Copy successful")
            self.ssh.send_command(command='rm -rf /tmp/*pcap*gz', connection='AP')
            self.ssh.send_command(command='rm -rf /tmp/*pcap*gz', connection='gNB')
            time.sleep(300)

    def terminate_background_copy_of_logs(self):
        self.running = False
        print("Status of thread:", self.timer_obj.isAlive())
        os.system(self.gnb_pcap_copy_gz.format(self.gNB_IP, self.vm_log_path))
        os.system(self.gnb_pcap_copy.format(self.gNB_IP, self.vm_log_path))
        os.system(self.ap_pcap_copy.format(self.AP_IP, self.vm_log_path))
        try:
            self.timer_obj._Thread__stop()
        except Exception as e:
            print("Exception : {}".format(e))
        print("Status of thread:", self.timer_obj.isAlive())

    def start_background_copy_of_logs(self, log_path):
        os.system("rm -rf {}".format(log_path))
        os.system("mkdir -p {}/airphone_bip".format(log_path))
        os.system("mkdir -p {}/bts_bip".format(log_path))
        os.system("ls -ltr {}".format(log_path))
        self.vm_log_path = log_path
        self.timer_obj = Thread(target=self.bip_pcap_log_copy, args=(log_path,), name="test_timer")
        self.timer_obj.setDaemon(True)
        self.timer_obj.start()


def start_background_copy(log_path):
    task_obj = BackgroundTask()
    task_obj.start_background_copy_of_logs(log_path)
    return task_obj


def stop_background_copy(task_obj):
    task_obj.terminate_background_copy_of_logs()


def main():
    obj = start_timer_copy_logs("/home/ute")
    time.sleep(60)
    stop_background_copy(obj)
    print("Main function completed")


if __name__ == '__main__':
    main()
