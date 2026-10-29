import pexpect
import os
import time
import taf.transport.ssh as ssh
from datetime import datetime


ute_path = '/home/ute/'
server_file_path = '/home/cmw_sg1'
pc_file_path = '/home/ute/hanging_resource/'
file_name = 'hanging_resource.exe'
server_file_name = os.path.join(server_file_path, file_name)
pc_file_name = os.path.join(pc_file_path, file_name)
ute_file_name = os.path.join(ute_path, file_name)
log_path = '/home/ute/TAF'


def download_file_to_ute(server_ip, server_name, server_pwd, server_alias='appserver', timeout=60):
    """
    download hanging_resource.exe file from app server to ute of per tl
    para server_ip: iperf server ip
    para server_name: iperf server username
    para server_pwd: iperf server password
    para server_alias: iperf server alias, default value is 'appserver'
    """
    try:
        sshcon = ssh.ssh()
        sshcon.connect_to(hostname=server_ip, username=server_name, password=server_pwd,
                          alias=server_alias, timeout=60)
    except Exception as e:
        print('{} connection failed, reason: {}'.format(server_alias, e))
    else:
        sshcon.download_file(remote_path=server_file_name, local_path=ute_file_name, connection=server_alias,
                             timeout=timeout)
    finally:
        try:
            sshcon.disconnect(connection=server_alias)
        except UnboundLocalError:
            print('{} close failed'.format(server_alias))


def upload_file_to_pc(pc_ip, pc_name, pc_pwd, pc_alias='cpc', timeout=60):
    """
    upload hanging_resource.exe file from ute to control pc of per tl
    para pc_ip: control pc ip
    para pc_name: control pc username
    para pc_pwd: control pc password
    para pc_alias: control pc alias, default value is 'cpc'
    """
    try:
        sshcon = ssh.ssh()
        sshcon.connect_to(hostname=pc_ip, username=pc_name, password=pc_pwd,
                          alias=pc_alias, timeout=60)
    except Exception as e:
        print('{} connection failed, reason: {}'.format(pc_alias, e))
    else:
        is_catalogue = sshcon.execute(command='cd c:;ls -l | grep {}'.format('hanging_resource'),
                                      connection=pc_alias)
        print(is_catalogue)
        print(len(is_catalogue))
        if len(is_catalogue) == 0:
            sshcon.send_command(command='cd c:;mkdir hanging_resource', connection=pc_alias)
        elif len(is_catalogue) != 0:
            sshcon.send_command(command='cd {};rm -rf *'.format(pc_file_path), connection=pc_alias)
        sshcon.upload_file(local_path=ute_file_name, remote_path=pc_file_name, connection=pc_alias,
                           timeout=timeout)
        sshcon.send_command(command='chmod 777 {}'.format(pc_file_name), connection=pc_alias)
        print('{} Permission given successfully'.format(pc_file_name))
    finally:
        try:
            sshcon.disconnect(connection=pc_alias)
        except UnboundLocalError:
            print('{} close failed'.format(pc_alias))


def get_pc_sn(pc_ip, pc_name, pc_pwd, pc_alias='cpc'):
    """
    get sn of control pc via command 'hostname'
    para pc_ip: control pc ip
    para pc_name: control pc username
    para pc_pwd: control pc password
    para pc_alias: control pc alias, default value is 'cpc'
    return pc_sn: SN of control pc
    """
    try:
        sshcon = ssh.ssh()
        sshcon.connect_to(hostname=pc_ip, username=pc_name, password=pc_pwd,
                          alias=pc_alias, timeout=60)
    except Exception as e:
        print('{} connection failed, reason: {}'.format(pc_alias, e))
    else:
        pc_sn = sshcon.execute(command='hostname', connection=pc_alias)
    finally:
        try:
            sshcon.disconnect(connection=pc_alias)
        except UnboundLocalError:
            print('{} close failed'.format(pc_alias))
    return pc_sn


def execute_hanging_resource_file(ute_ip, ute_name, ute_pwd, gnb_ip):
    try:
        f = open('/home/ute/hanging_resource/result.txt', 'wb')
    except Exception as e:
        print(e)
    else:
        child = pexpect.spawn('ssh {}@{}'.format(ute_name, ute_ip), logfile=f)
        child.expect('password:')
        child.sendline('{}'.format(ute_pwd))
        child.sendline("cd {}".format(pc_file_path))
        child.expect('{}'.format(pc_file_path))
        child.sendline("wine {}{}".format(pc_file_path, file_name))
        child.expect('IP:')
        child.sendline('{}\r'.format(gnb_ip))
        child.logfile_read = f
        child.expect('connection successful')
        child.expect('Checked processes:')
        child.expect('Press any key to exit')
        child.sendline('')
    finally:
        f.close()


def save_check_result_to_ute(pc_ip, pc_name, pc_pwd, pc_alias='cpc', timeout=60):
    """
    save and download checked result from control pc to ute '/opt/workspace/CIT/Master/Case_Logs'
    para pc_ip: control pc ip
    para pc_name: control pc username
    para pc_pwd: control pc password
    para pc_alias: control pc alias, default value is 'cpc'
    """
    try:
        sshcon = ssh.ssh()
        sshcon.connect_to(hostname=pc_ip, username=pc_name, password=pc_pwd,
                          alias=pc_alias, timeout=60)
    except Exception as e:
        print('{} connection failed, reason: {}'.format(pc_alias, e))
    else:
        is_existed_file = sshcon.execute(command='cd {};ls -l | head -n 1'.format(pc_file_path),
                                         connection=pc_alias)
        print(is_existed_file)
        if int(is_existed_file.split(' ')[1]) == 0:
            print('there is no file on folder')
        elif int(is_existed_file.split(' ')[1]) != 0:
            result_file_name = pc_file_path.split('/')[3] + '_' + \
                               datetime.now().strftime("%Y%m%d_%H%M%S") + '.tar.gz'
            sshcon.send_command(command='cd {};tar -czvf {} *'.format(pc_file_path, result_file_name),
                                connection=pc_alias)
            pc_result_path_file_name = pc_file_path + '/' + result_file_name
            print(pc_result_path_file_name)
            ute_result_path_file_name = log_path + '/' + result_file_name
            print(ute_result_path_file_name)
            sshcon.download_file(remote_path=pc_result_path_file_name, local_path=ute_result_path_file_name,
                                 connection=pc_alias, timeout=timeout)
    finally:
        try:
            sshcon.disconnect(connection=pc_alias)
        except UnboundLocalError:
            print('{} close failed'.format(pc_alias))
