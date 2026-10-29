import threading
import time

import pexpect
import os
import taf.transport.ssh as ssh
from datetime import datetime
from taf.sbts.oam.coam.admin import admin
from robot.libraries.BuiltIn import BuiltIn


ute_path = '/home/ute/'
server_file_path = '/home/'
pc_file_path = '/cygdrive/c/hanging_resource'
file_name = 'hanging_resource.exe'
pc_file_name = os.path.join(pc_file_path, file_name)
ute_file_name = os.path.join(ute_path, file_name)
log_path = '/opt/workspace/CIT/Master/Case_Logs'
coam = admin()
built_in = BuiltIn()
tl = built_in.get_variable_value("${tl}")


def download_file_to_ute(server_ip, server_name, server_pwd, server_alias='appserver', timeout=60):
    """
    download hanging_resource.exe file from app server to ute of per tl
    para server_ip: iperf server ip
    para server_name: iperf server username
    para server_pwd: iperf server password
    para server_alias: iperf server alias, default value is 'appserver'
    """
    server_file_path1 = server_file_path + server_name
    server_file_name = os.path.join(server_file_path1, file_name)
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


def execute_hanging_resource_file(pc_ip, pc_name, pc_pwd, gnb_ip, pc_alias='cpc'):
    """
    run hanging_resource.exe and check result if there is hanging resource or not
    para ip: control pc ip
    para username: control pc username
    para password: control pc password
    para gnb_ip(type is list): need to check which gnb ips, e.g. [10.57.228.6,10.57.227.4]
    para pc_alias: control pc alias, default value is 'cpc'
    """
    try:
        f = open('result.txt', 'wb')
    except Exception as e:
        print(e)
    else:
        pc_sn = get_pc_sn(pc_ip=pc_ip, pc_name=pc_name, pc_pwd=pc_pwd, pc_alias=pc_alias)
        expect_pc_login = '@' + pc_sn
        expect_pc_login = expect_pc_login.strip()
        print(expect_pc_login)
        child = pexpect.spawn('ssh {}@{}'.format(pc_name, pc_ip), logfile=f)
        child.expect('password:')
        child.sendline('{}'.format(pc_pwd))
        child.expect(expect_pc_login)
        child.sendline("cd {}".format(pc_file_path))
        child.expect('{}'.format(pc_file_path))
        child.sendline('./{}'.format(file_name))
        child.expect('IP:')
        ips = ','.join(gnb_ip)
        child.sendline('{}\r'.format(ips))
        child.expect('connection successful')
        child.expect('Checked processes:')
        child.expect('No hanging resources')
        child.expect('Press any key to exit')
        child.sendline('')
    finally:
        f.close()


def save_check_result_to_ute(pc_ip, pc_name, pc_pwd, pc_alias='cpc', timeout=60, ute_log_path=log_path):
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
            last_file_name = sshcon.execute(
                command=f"cd {pc_file_path};ls -l | tail -n 1", connection=pc_alias)
            sshcon.send_command(command='cd {};tar -czvf {} *'.format(pc_file_path, result_file_name),
                                connection=pc_alias)
            sshcon.read_output_until(match=last_file_name.split(' ')[-1].strip(), connection=pc_alias)
            pc_result_path_file_name = pc_file_path + '/' + result_file_name
            print(pc_result_path_file_name)
            ute_result_path_file_name = ute_log_path + '/' + result_file_name
            print(ute_result_path_file_name)
            sshcon.download_file(remote_path=pc_result_path_file_name, local_path=ute_result_path_file_name,
                                 connection=pc_alias, timeout=timeout)
    finally:
        try:
            sshcon.disconnect(connection=pc_alias)
        except UnboundLocalError:
            print('{} close failed'.format(pc_alias))


def connection_bts(index=0, username='Nemuadmin', password='nemuuser', bts_type='nr'):
    for i in range(20):
        try:
            if bts_type == 'nr':
                coam.connect_to(bts_host=tl.gnbs[index].cu.oam_ssh_connection_details.addr,
                                username=username, password=password, name=f'GNB{index}_COAM')
            elif bts_type == 'lte':
                coam.connect_to(bts_host=tl.enbs[index].airscale.common_units[0].lmp_connection.addr,
                                username=username, password=password, name=f'GNB{index}_COAM')
        except Exception as e:
            print(f"connection: {e}")
            time.sleep(30)
            continue
        else:
            break


def operate_all_cell_of_bts(index=0, rat='NR', action='unblock', bts_type='nr'):
    try:
        connection_bts(index=index, bts_type=bts_type)
    except Exception as e:
        print(e)
    else:
        if action == 'block':
            coam.block_all_cells(rat=rat, connection=f'GNB{index}_COAM')
        elif action == 'unblock':
            coam.unblock_all_cells(rat=rat, connection=f'GNB{index}_COAM')
    finally:
        coam.teardown(connection=f'GNB{index}_COAM')


def operate_all_cell_of_bts_threading(rat='NR', action='unblock', bts_type='nr'):
    """
    operate all cells of bts, block or unblock
    para rat (string) – RAT technology cells to unblock. <NR, LTE, WCDMA, GSM, TETRA>
    para action: block or unblock
    para bts_type: bts type. <nr, lte>
    """
    threads = []
    if bts_type == 'nr':
        bts_num = len(tl.gnbs)
    elif bts_type == 'lte':
        bts_num = len(tl.enbs)
    for num in range(bts_num):
        th = threading.Thread(target=operate_all_cell_of_bts, args=(num, rat, action, bts_type))
        threads.append(th)
    for t in threads:
        t.start()
    for t in threads:
        t.join()
