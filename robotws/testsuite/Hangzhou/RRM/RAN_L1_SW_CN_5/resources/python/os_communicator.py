import errno
import io
import socket
import time
import re
import os
import string
# from pathlib import Path
# from stat import S_ISDIR
# from contextlib import contextmanager
import paramiko
import datetime

# slot 1: lokiA ip=fsp1s1icom , lokiB ip=fsp1s2icom
# slot 2: lokiA ip=fsp2s1icom, lokiB ip=fsp2s2icom
# slot 3: lokiA ip=fsp3s1icom, lokiB ip=fsp3s2icom


def start_collect_journal_log(log_name, loki_ip):
    fct_os = OsCommunicator(
        username="toor4nsn",
        password="oZPS0POrRieRtu",
        ip="192.168.255.129",
        port=22, jump_host=""
        )
    fsp_os = OsCommunicator(username="toor4nsn", password="oZPS0POrRieRtu", ip=loki_ip, port=22, jump_host=fct_os)
    command = 'journalctl -o short-precise --no-tail --no-pager -f > /ffs/run/logs/' + log_name + ' &'
    with fsp_os as target:
        print(target.run_command(command))


def stop_collect_journal_log(loki_ip):
    fct_os = OsCommunicator(
        username="toor4nsn", password="oZPS0POrRieRtu", ip="192.168.255.129", port=22, jump_host=""
        )
    fsp_os = OsCommunicator(
        username="toor4nsn", password="oZPS0POrRieRtu", ip=loki_ip, port=22, jump_host=fct_os
        )
    with fsp_os as target:
        print(target.run_command('pgrep journalctl | xargs kill -s 9'))


def get_local_date():
    return datetime.datetime.now().strftime("%Y-%m-%d")


def write_l1sw_version_to_Local(file, version):
    with open(file, 'w+') as f:
        f.write(version)
        f.close


def get_l1sw_version_from_local(file):
    if os.path.isfile(r'{}'.format(file)):
        with open(file, 'rb+') as f:
            return f.readlines()[-1]


def get_l1sw_version_from_bts(loki_ip):
    fct_os = OsCommunicator(username="toor4nsn",
                            password="oZPS0POrRieRtu",
                            ip="192.168.255.129",
                            port=22,
                            jump_host="")
    fsp_os = OsCommunicator(username="toor4nsn", password="oZPS0POrRieRtu", ip=loki_ip, port=22, jump_host=fct_os)
    with fsp_os as target:
        version = target.get_file_content('/etc/l1sw-release')
    return version


def get_l1sw_version(loki_ip, file):
    today = get_local_date()
    print(today)
    if os.path.isfile(file):
        version = get_l1sw_version_from_local(file)
        if today in version:
            print('version from local is : %s.' % version)
            return version
        else:
            version = get_l1sw_version_from_bts(loki_ip)
            write_l1sw_version_to_Local(file, version)
            print('version from bts is : %s.' % version)
            return version
    else:
        version = get_l1sw_version_from_bts(loki_ip)
        write_l1sw_version_to_Local(file, version)
        print('version3 from bts is : %s.' % version)
        return version


def get_iq(rat, lokiid, cellid, path):
    assert rat.lower() in ('nr', 'lte'), "rat should be input 'nr'|'NR', 'lte'|'LTE'."
    fct_os = OsCommunicator(username="toor4nsn",
                            password="oZPS0POrRieRtu",
                            ip="192.168.255.129",
                            port=22,
                            jump_host="")
    command_nr_dl = 'bsh %s /usr/lib64/python/antenna_snapshot_config.py --dlsubcellid %s' % (lokiid, cellid)
    command_nr_ul = 'bsh %s /usr/lib64/python/antenna_snapshot_config.py --subcellid %s' % (lokiid, cellid)
    command_lte_dl = 'bsh %s /usr/lib64/python/antenna_snapshot_config.py --dllncellid %s' % (lokiid, cellid)
    command_lte_ul = 'bsh %s /usr/lib64/python/antenna_snapshot_config.py --lncellid %s' % (lokiid, cellid)
    command_blind = 'bsh %s /usr/lib64/python/antenna_snapshot_config.py --blind' % lokiid
    command_stop = 'bsh %s /usr/lib64/python/antenna_snapshot_config.py --stop' % lokiid
    command_scp_to_fct = 'bsh %s scp -r /tmp/mine/ /ffs/run/logs' % lokiid
    command_clear_log_fsp = 'bsh %s rm -rf /tmp/mine' % lokiid
    command_clear_log_fct = 'rm -rf /ffs/run/logs/mine'
    command_clear_log_local = 'rm -rf {}/*_mine'.format(path)
    os.popen(command_clear_log_local)
    with fct_os as target:
        if rat.lower() == 'nr':
            cmd_list = [command_nr_dl, command_nr_ul]
        else:
            cmd_list = [command_lte_dl, command_lte_ul]
        for cmd in cmd_list:
            target.execute_command(command_clear_log_fsp)
            target.execute_command(command_clear_log_fct)
            target.execute_command(cmd)
            target.execute_command(command_blind)
            time.sleep(20)
            target.execute_command(command_stop)
            target.execute_command(command_scp_to_fct)
            if 'dl' in cmd:
                log_dir = 'dl_mine'
            else:
                log_dir = 'ul_mine'
            if not os.path.exists('{}/{}'.format(path, log_dir)):
                os.popen('mkdir {}/{}'.format(path, log_dir))
                os.popen('sshpass -p oZPS0POrRieRtu scp -r toor4nsn@192.168.255.129:/ffs/run/logs/mine \
{}/{}'.format(path, log_dir))
                output = os.popen('ls -lt {}/{}/mine'.format(path, log_dir))
                print('{} captured'.format(log_dir))
                print(output.read())


def check_connection(func):
    def wrapper(self, *args, **kwargs):
        for count in range(3):
            transport = self.ssh.get_transport() if self.ssh else None
            if not (transport and transport.is_active()):
                print('Retry connection attempt: %d' % (count))
                time.sleep(3)
                self.ssh = paramiko.SSHClient()
                self.ssh.set_missing_host_key_policy(paramiko.MissingHostKeyPolicy())
                self.connect_ssh()
            else:
                break
        return func(self, *args, **kwargs)

    return wrapper


class OsCommunicator:
    def __init__(self, username, password, ip, port=22, jump_host=None):
        self.target_ip = ip
        self.port = port
        self.username = username
        self.password = password
        # self.key = rsa_key_path
        self.ssh = paramiko.SSHClient()
        self.ssh.set_missing_host_key_policy(paramiko.MissingHostKeyPolicy())
        self.jump_host = jump_host
        self.channel = None
        self.sftp = None

    def __enter__(self):
        self.connect_ssh()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

    def connect_ssh(self):
        fault = None
        if self.jump_host:
            time.sleep(90)
            self.channel = self.jump_host.get_channel(self.target_ip, self.port)
        # print(f'Opening connection for ip: {self.target_ip} channel: {repr(self.channel)}')
        print('Opening connection for ip: %s channel: %s' % (self.target_ip, repr(self.channel)))
        for _ in range(3):
            try:
                self.ssh.connect(self.target_ip,
                                 int(self.port),
                                 self.username,
                                 self.password,
                                 timeout=2,
                                 banner_timeout=2,
                                 auth_timeout=1,
                                 sock=self.channel
                                 )
                return
            except paramiko.ssh_exception.SSHException as error:
                fault = error
                # print(f'Connecting to {self.target_ip}:{self.port} raised {error}')
                print('Connecting to %s:%d raised %s' % (self.target_ip, self.port, error))
        if fault:
            raise fault

    @check_connection
    def connect_sftp(self):
        transport = self.ssh.get_transport()
        transport.set_keepalive(30)
        window_size = paramiko.common.MAX_WINDOW_SIZE
        max_packet_size = paramiko.common.MAX_WINDOW_SIZE
        self.sftp = paramiko.SFTPClient.from_transport(transport,
                                                       window_size=100000000,
                                                       max_packet_size=100000000)

        self.sftp.get_channel().settimeout(10)

    def get_file_content(self, location):
        print('Get contents of file: %s' % (location))
        self.connect_sftp()
        with self.sftp.open(str(location), "rb") as in_file:
            content = in_file.read().rstrip()
        return content

    def get_file_part(self, location, start, length):
        print('Get partial contents of file: {}, start {}, length {}'.format(location, start, length))
        self.connect_sftp()
        with self.sftp.open(str(location), "rb") as in_file:
            in_file.seek(start, 0)
            data = in_file.read(length)
        return data

    @check_connection
    def get_channel(self, dest_ip, src_port, dest_port=22):
        dest = (dest_ip, int(dest_port))
        src = (self.target_ip, int(src_port))
        # print(f'opening channel from {src} to {dest}')
        print('opening channe; from %s to %s' % (dest, src))
        transport = self.ssh.get_transport()
        transport.set_keepalive(30)
        # to avoid trx receiving multi messages in one package,turn off TCP nodelay function
        transport.sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        # return transport.open_channel('direct-tcpip', dest, src)
        return transport.open_channel('direct-tcpip', dest, src, timeout=2)

    @check_connection
    def execute_command(self, command, timeout=30):
        channel = None
        try:
            # print(f'Executing command: {command}')
            print('Executing command: %s' % (command))
            channel = self.ssh.get_transport().open_session()
            _, stdout, stderr = self.ssh.exec_command(command, timeout=int(timeout))

            out_raw = stdout.read(1)
            err_raw = stderr.read(1)
            try:
                out = str(out_raw.decode('utf-8'))
                error = str(err_raw.decode('utf-8'))
            except UnicodeEncodeError:
                out = str(out_raw)
                error = str(err_raw)
            exit_status = stdout.channel.recv_exit_status()
            transport = self.ssh.get_transport()
            return {'stdout': out, 'stderr': error, 'status': exit_status}
        except socket.error as err:
            print(str(err))
            # print(f'"{command}" returned "{err}"')
            print('%s returned %s' % (command, err))
            return {'stdout': '', 'stderr': err, 'status': 1}
        except socket.timeout as err:
            # print(f'"{command}" returned timeout error: "{err}"')
            print('%s returned timeout error %s' % (command, err))
            return {'stdout': '', 'stderr': err, 'status': 1}
        finally:
            if channel:
                channel.close()

    @check_connection
    def run_command(self, command):
        # print(f'Running command and ignoring return values, command:  {command}')
        print('Running command and ignoring return values, command: %s' % (command))
        transport = self.ssh.get_transport()
        transport.set_keepalive(30)
        channel = transport.open_session()
        # channel.exec_command(command)
        result = channel.exec_command(command)
        print(result)
        # print(f"channel id is:", channel.get_id())
        print('channel id is: %d' % (channel.get_id()))
        channel.close()

    def ping_remote(self, ip):
        transport = self.ssh.get_transport()
        transport.set_keepalive(30)
        channel = transport.open_session()
        ping_result = channel.exec_command('ping ' + ip + ' -c 1 -w 1')
        print(ping_result)
        channel.close()

    def download_file(self, file, localpath, remotepath):
        print('download file from %s to %s' % (remotepath, localpath))
        self.connect_sftp()
        try:
            for file in self.sftp.listdir_attr(remotepath):
                remote = os.path.join(remotepath, file)
                local = os.path.join(localpath, file)
                self.sftp.download(remote, local)
        except (OSError, paramiko.ssh_exception.SSHException) as error:
            # print(f'Could not get files from path: {remotepath} due to {error}')
            print('Could not get file from path: %s due to %s' % (remotepath, error))

    def close(self):
        # print(f'Close connection for ip: {self.target_ip} channel: {repr(self.channel)}')
        print('Close connection for ip: %s channel: %s' % (self.target_ip, repr(self.channel)))
        if self.sftp is not None:
            self.sftp.close()
        if self.channel is not None:
            self.channel = None
        self.ssh.close()


if __name__ == '__main__':
    get_iq('lte', 1, '/home/ute/Logs')
