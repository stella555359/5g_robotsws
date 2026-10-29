# owner: liujia
# time: 1/11/24 1:58 PM

# *-coding=utf-8-*

import re
import taf.transport.ssh as ssh


def modify_Dockerfile(vdu_host, vdu_name, vdu_pwd, ute_file_name, path_command_1,
                      path_command_2, dockerfile, vdu_alias='vdu'):
    try:
        connection_ssh = ssh.ssh()
        connection_ssh.connect_to(hostname=vdu_host, username=vdu_name,
                                  password=vdu_pwd, alias=vdu_alias, timeout=60)
    except Exception as e:
        print('{} connection failed, reason: {}'.format(vdu_alias, e))
    else:
        get_kuafu_command = 'ls |grep kuafu | head -n 1'
        kuafu_name_m = connection_ssh.execute(command=get_kuafu_command, connection=vdu_alias)
        kuafu_name = kuafu_name_m.split('\r')[0]
        print(kuafu_name)
        aic_vdu_name_command = 'ls |grep aic | tail -n 1'
        enter_kuafu_command = f'cd {kuafu_name}/dockerfiles/vdu/'
        get_aic_command = enter_kuafu_command + ';' + aic_vdu_name_command
        print(get_aic_command)
        aic_vdu_name_m = connection_ssh.execute(command=get_aic_command, connection=vdu_alias)
        aic_vdu_name = aic_vdu_name_m.split('\r')[0]
        vdu_file_name = f'{kuafu_name}/dockerfiles/vdu/{aic_vdu_name}/'
        print(vdu_file_name)
        connection_ssh.upload_file(local_path=ute_file_name, remote_path=vdu_file_name + '/swconfig.txt',
                                   connection=vdu_alias)
        add_path_to_file_command_1 = f'echo {path_command_1} >> {vdu_file_name}/{dockerfile}'
        add_path_to_file_command_2 = f'echo {path_command_2} >> {vdu_file_name}/{dockerfile}'
        print(add_path_to_file_command_1)
        print(add_path_to_file_command_2)
        add_command_1 = connection_ssh.execute(command=add_path_to_file_command_1, connection=vdu_alias)
        add_command_2 = connection_ssh.execute(command=add_path_to_file_command_2, connection=vdu_alias)
        check_file = connection_ssh.execute(command=f'cat {vdu_file_name}/{dockerfile}', connection=vdu_alias)
        print(check_file)
    finally:
        try:
            connection_ssh.disconnect(connection=vdu_alias)
        except UnboundLocalError:
            print('{} close failed'.format(vdu_alias))


def delete_and_rebuild_vdu(vdu_host, vdu_name, vdu_pwd, connection='vdu_client'):
    try:
        # connect to vdu
        connection_ssh = ssh.ssh()
        connection_ssh.connect_to(hostname=vdu_host, username=vdu_name, password=vdu_pwd, alias=connection)
    except Exception as e:
        print('{} connection failed, reason: {}'.format(vdu_alias, e))
    else:
        get_kuafu_command = 'ls |grep kuafu | head -n1'
        kuafu_name_1 = connection_ssh.execute(command=get_kuafu_command, connection=connection)
        kuafu_name = kuafu_name_1.split('\r')[0]
        print(kuafu_name)
        enter_scripts_folder_command_vdu = f'cd {kuafu_name}/' + ';' + '. ./10-vdu-l3call-test.sh'
        delete_command = enter_scripts_folder_command_vdu + ';' + './20-delete-vdu.sh'
        print(delete_command)
        step_1 = connection_ssh.execute(command=delete_command, connection=connection)
        print(step_1)
        enter_knife_command = enter_scripts_folder_command_vdu + ';' + '. ./70-build-vdu-knife-image.sh'
        create_knife_command = enter_knife_command + ';' + './10-create-knife-images.sh'
        step_2 = connection_ssh.execute(command=create_knife_command, connection=connection)
        print(step_2)
        create_command = enter_scripts_folder_command_vdu + ';' + './21-create-vdu.sh'
        step_3 = connection_ssh.execute(command=create_command, connection=connection)
        print(step_3)
    finally:
        try:
            connection_ssh.disconnect(connection=connection)
        except UnboundLocalError:
            print('{} close failed'.format(connection))


def check_swconfig_add_success(vdu_host, vdu_name, vdu_pwd, vdu_alias='vdu'):
    try:
        connection_ssh = ssh.ssh()
        connection_ssh.connect_to(hostname=vdu_host, username=vdu_name, password=vdu_pwd,
                                  alias=vdu_alias, timeout=60)
    except Exception as e:
        print('{} connection failed, reason: {}'.format(vdu_alias, e))
    else:
        get_kuafu_command = 'ls |grep kuafu | head -n 1'
        kuafu_name_m = connection_ssh.execute(command=get_kuafu_command, connection=vdu_alias)
        kuafu_name = kuafu_name_m.split('\r')[0]
        print(kuafu_name)
        aic_vdu_name_command = 'ls |grep aic | tail -n 1'
        enter_kuafu_command = f'cd {kuafu_name}/dockerfiles/vdu/'
        get_aic_command = enter_kuafu_command + ';' + aic_vdu_name_command
        print(get_aic_command)
        aic_vdu_name_m = connection_ssh.execute(command=get_aic_command, connection=vdu_alias)
        aic_vdu_name = aic_vdu_name_m.split('\r')[0]
        charts_path = f'{kuafu_name}/charts/vdu/{aic_vdu_name}/aic-vdu/'
        print(charts_path)
        check_file = connection_ssh.execute(command=f'cat {charts_path}/values.yaml', connection=vdu_alias)
        print(check_file)
        if 'amd64-dev' in check_file:
            print('swconfig add success')
            return True
        else:
            print('swconfig add failed,should manual check')
            return False
    finally:
        try:
            connection_ssh.disconnect(connection=vdu_alias)
        except UnboundLocalError:
            print('{} close failed'.format(vdu_alias))
