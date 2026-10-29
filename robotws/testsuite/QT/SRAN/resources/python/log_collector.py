import logging
import time
from taf.transport.ssh import ssh

ssh = ssh()
log = logging.getLogger(__name__)
target_version = None


class NotEnoughSpace(Exception):
    pass


class Installfailure(Exception):
    pass


def get_logs_from_ru_lmi(alias, ru_type, rf_ip, user, password):
    connection = ssh.get_connection_by_alias(alias)
    channel = connection.invoke_shell()
    passwd = ''.join((password, '\n'))
    cmd = ''.join(('ssh ' + user + '@', rf_ip, '\n'))
    channel.send(cmd)
    time.sleep(3)
    channel.send(passwd)
    time.sleep(3)
    if ru_type == 'AEQE':
        channel.send('log -a -z ru_logs_lmi.zip\n')
        time.sleep(90)
    else:
        channel.send('ccsShell.sh log -c full -z ru_logs_lmi.zip\n')
        time.sleep(30)
    channel.send('exit\n')
    time.sleep(1)
    cmd2 = ''.join(('scp ' + user + '@', rf_ip, ':/ram/ru_logs_lmi.zip /tmp\n'))
    channel.send(cmd2)
    time.sleep(3)
    channel.send(passwd)
    time.sleep(3)
    print(channel.recv(65536))


def collect_rmod_logs(alias, container_id, fhgw_ip, fhgw_password):
    connection = ssh.get_connection_by_alias(alias)
    channel = connection.invoke_shell()
    print('Container ID: ', container_id)
    channel.send('docker exec -it ' + container_id + ' bash\n')
    time.sleep(1)
    channel.send('ssh -oHostKeyAlgorithms=+ssh-rsa root@169.254.1.2\n')
    time.sleep(1)
    channel.send('yes\n')
    time.sleep(1)
    channel.send('ccsShell.sh log -a -c full -z fhgw_ru_snapshot.zip\n')
    time.sleep(10)
    channel.send('ls -al | grep fhgw_ru_snapshot.zip\n')
    time.sleep(1)
    channel.send('exit\n')
    time.sleep(1)
    channel.send('cd /tmp/run\n')
    time.sleep(1)
    channel.send('scp -oHostKeyAlgorithms=+ssh-rsa root@169.254.1.2:/run/fhgw_ru_snapshot.zip .\n')
    time.sleep(1)
    channel.send('yes\n')
    time.sleep(3)
    channel.send('sftp toor4nsn@' + fhgw_ip + '\n')
    time.sleep(1)
    channel.send('yes\n')
    time.sleep(1)
    channel.send(fhgw_password + '\n')
    time.sleep(1)
    channel.send('put fhgw_ru_snapshot.zip\n')
    time.sleep(1)
    channel.send('exit\n')
    time.sleep(1)
    channel.send('exit\n')
    time.sleep(1)

    print('Channel REC: ' + channel.recv(65536))


def Start_tcpdump_on_RU(alias, ru_type, rf_ip, user, password):
    connection = ssh.get_connection_by_alias(alias)
    channel = connection.invoke_shell()
    passwd = ''.join((password, '\n'))
    cmd = ''.join(('ssh ' + user + '@', rf_ip, '\n'))
    channel.send(cmd)
    time.sleep(3)
    channel.send(passwd)
    time.sleep(3)
    if ru_type == 'AEQE' or ru_type == 'AEUB':
        channel.send('sudo rm /tmp/LMI_' + ru_type + '.pcap\n')
    else:
        channel.send('rm /tmp/LMI_' + ru_type + '.pcap\n')
    time.sleep(2)
    if ru_type == 'AEQE':
        channel.send("sudo rm /mnt/runtime/tcpdump_aarch64/nohup.out\n")
        time.sleep(1)
        channel.send('cd /mnt/runtime/tcpdump_aarch64 && nohup sudo ./tcpdump -i any -w /tmp/LMI_'+ru_type+'.pcap &\n')
        time.sleep(2)
        channel.send("\n")
        time.sleep(1)
        channel.send("sudo cat /mnt/runtime/tcpdump_aarch64/nohup.out\n")
        time.sleep(1)
        channel.send("ps aux | grep 'tcpdump' | grep -v grep | grep -v sctp | awk '{print $1}'\n")
    else:
        channel.send('cd /tmp && nohup tcpdump -i any -w LMI_' + ru_type + '.pcap &\n')
    time.sleep(2)
    print(channel.recv(65536))


def Stop_tcpdump_on_RU(alias, ru_type, rf_ip, user, password):
    connection = ssh.get_connection_by_alias(alias)
    channel = connection.invoke_shell()
    passwd = ''.join((password, '\n'))
    cmd = ''.join(('ssh ' + user + '@', rf_ip, '\n'))
    channel.send(cmd)
    time.sleep(3)
    channel.send(passwd)
    time.sleep(3)
    if ru_type == 'AEUB':
        channel.send("kill $(ps | grep 'tcpdump' | grep -v grep | grep -v sctp | awk '{print $1}')\n")
    elif ru_type == 'AEQE':
        channel.send("sudo kill $(ps aux | grep 'tcpdump' | grep -v grep | grep -v sctp | awk '{print $1}')\n")
    else:
        channel.send("kill $(ps aux | grep 'tcpdump' | grep -v grep | grep -v sctp | awk '{print $1}')\n")
    time.sleep(1)
    print(channel.recv(65536))


def Collect_tcpdump_on_RU(alias, ru_type, rf_ip, user, password):
    connection = ssh.get_connection_by_alias(alias)
    channel = connection.invoke_shell()
    passwd = ''.join((password, '\n'))
    channel.send('scp ' + user + '@' + rf_ip + ':/tmp/LMI_' + ru_type + '.pcap /tmp\n')
    time.sleep(3)
    channel.send(passwd)
    time.sleep(3)
    print(channel.recv(65536))


def Start_tcpdump_on_SMOD_FHNET(alias):
    connection = ssh.get_connection_by_alias(alias)
    channel = connection.invoke_shell()
    node = '1'
    channel.send('hostname\n')
    time.sleep(1)
    hostname = channel.recv(65536)
    if '4a' in hostname:
        node = '2'
    channel.send('lxc-attach -n 0x{}018\n'.format(node))
    time.sleep(2)
    channel.send('nohup tcpdump -i any -w FHNET.pcap &\n')
    print(channel.recv(65536))


def Stop_tcpdump_on_SMOD_FHNET(alias):
    connection = ssh.get_connection_by_alias(alias)
    channel = connection.invoke_shell()
    node = '1'
    channel.send('hostname\n')
    time.sleep(1)
    hostname = channel.recv(65536)
    if '4a' in hostname:
        node = '2'
    channel.send('lxc-attach -n 0x{}018\n'.format(node))
    time.sleep(2)
    channel.send('pkill -f "tcpdump -i any -w FHNET.pcap"\n')
    print(channel.recv(65536))


def add_tcpdump_for_AEQE(alias, rf_ip, user, password):
    connection = ssh.get_connection_by_alias(alias)
    channel = connection.invoke_shell()
    passwd = ''.join((password, '\n'))
    cmd = ''.join(('ssh ' + user + '@', rf_ip, '\n'))
    channel.send('scp -r /opt/ute/tcpdump_aarch64 ' + user + '@' + rf_ip + ':/tmp\n')
    time.sleep(3)
    channel.send(passwd)
    time.sleep(3)
    channel.send(cmd)
    time.sleep(3)
    channel.send(passwd)
    time.sleep(3)
    channel.send('sudo cp -r /tmp/tcpdump_aarch64 /mnt/runtime/\n')
    time.sleep(6)
    channel.send('cd /mnt/runtime/tcpdump_aarch64 && sudo chmod 777 *\n')
    time.sleep(1)
    channel.send('cd /usr/lib64 && sudo ln -s libpcap.so.1 libcrypto.so.1.0.2\n')
    time.sleep(1)
    print(channel.recv(65536))


def start_vdu_tcpdumps(alias, file_name, interface):
    connection = ssh.get_connection_by_alias(alias)
    channel = connection.invoke_shell()
    channel.send('sudo tmux new-session -s ' + alias + '\n')
    time.sleep(2)
    channel.send('toolbox\n')
    time.sleep(3)
    for i in interface:
        print(channel.recv(65536))
        time.sleep(2)
        channel.send('tcpdump --list-interface | grep "' + i + ' " \n')
        time.sleep(2)
        output = channel.recv(65536)
        print(output)
        if 'Connected' not in str(output):
            channel.send('exit\n')
            time.sleep(2)
            channel.send('sudo tmux kill-session -t ' + alias + '\n')
            time.sleep(3)
            return False
    channel.send('mkdir /host/tmp/tcpdumps\n')
    time.sleep(2)
    channel.send('chmod 777 /host/tmp/tcpdumps\n')
    time.sleep(2)
    for i in interface:
        channel.send(
            'nohup tcpdump -i ' + i + ' -C 200 -w /host/tmp/tcpdumps/' + i +
            '_' + file_name + ' > /host/tmp/tcpdumps/capture_' + i + '.log 2>&1 &\n'
            )
        time.sleep(2)
    print(channel.recv(65536))
    return True


def stop_vdu_tcpdumps(alias):
    connection = ssh.get_connection_by_alias(alias)
    channel = connection.invoke_shell()
    channel.send('oc debug node/master0\n')
    time.sleep(2)
    channel.send('chroot /host\n')
    time.sleep(1)
    channel.send('toolbox\n')
    time.sleep(2)
    channel.send('pkill -9 tcpdump*\n')
    time.sleep(2)
    print(channel.recv(65536))
    channel.send('tar -czf /host/tmp/tcpdumps.tgz  /host/tmp/tcpdumps/*; echo __DONE__\n')
    output = channel.recv(65536)
    while True:
        output += channel.recv(65536)
        time.sleep(0.5)
        channel.send('\n')
        if str(output).count('__DONE__') == 2:
            print(channel.recv(65536))
            channel.send('exit\n')
            time.sleep(1)
            channel.send('sudo tmux kill-session -t ' + alias + '\n')
            time.sleep(1)
            break
    print(channel.recv(65536))
    channel.send('sudo tmux kill-session -t ' + alias + '\n')
