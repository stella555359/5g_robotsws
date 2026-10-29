# owner: liujia
# time: 1/11/24 1:58 PM

# *-coding=utf-8-*

import re
import taf.transport.ssh as ssh


def delete_and_config_vcu(host, username, password, new_build, connection='vcu_client', tlname='cranuser239'):
    try:
        # connect to vcu
        connection_ssh = ssh.ssh()
        connection_ssh.connect_to(hostname=host, username=username, password=password, alias=connection)
    except Exception as e:
        print(f"connection failed: {e}")
    else:
        get_kuafu_command = 'ls |grep kuafu | head -n1'
        kuafu_name_m = connection_ssh.execute(command=get_kuafu_command, connection=connection)
        kuafu_name = kuafu_name_m.split('\r')[0]
        print(kuafu_name)
        enter_kuafu_command = f'cd {kuafu_name}/'
        enter_scripts_folder_command_vcu = enter_kuafu_command + ';' + '. ./20-vcu-l3call-test.sh'
        output1 = connection_ssh.execute(command=enter_scripts_folder_command_vcu, connection=connection)
        print(output1)
        delete_command = enter_scripts_folder_command_vcu + ';' + './20-delete-vcu-and-pvc.sh'
        output_delete = connection_ssh.execute(command=delete_command, connection=connection)
        print(output_delete)
        check_current_version_command = f"sed -n '/build_version/p' " \
                                        f"/var/home/{tlname}/{kuafu_name}/artifacts/vcu_config.ini"
        old_build_m = connection_ssh.execute(command=check_current_version_command, connection=connection)
        old_build = old_build_m.split('\r\n')[-2]
        print(old_build)
        config_command = f"sed -i 's/{old_build}/build_version={new_build}/' " \
                         f"/var/home/{tlname}/{kuafu_name}/artifacts/vcu_config.ini"
        print(config_command)
        connection_ssh.execute(command=config_command, connection=connection)
        onboard_command = enter_scripts_folder_command_vcu + ';' + './16-onboard-vcu.sh'
        output16 = connection_ssh.execute(command=onboard_command, connection=connection)
        print(output16)
        create_command = enter_scripts_folder_command_vcu + ';' + './21-create-vcu.sh'
        output21 = connection_ssh.execute(command=create_command, connection=connection)
        print(output21)


def delete_and_config_vdu(host, username, password, new_build, connection='vdu_client', tlname='core'):
    try:
        # connect to vdu
        connection_ssh = ssh.ssh()
        connection_ssh.connect_to(hostname=host, username=username, password=password, alias=connection)
    except Exception as e:
        print(f"connection failed: {e}")
    else:
        get_kuafu_command = 'ls |grep kuafu | head -n1'
        kuafu_name_1 = connection_ssh.execute(command=get_kuafu_command, connection=connection)
        kuafu_name = kuafu_name_1.split('\r')[0]
        print(kuafu_name)
        check_current_version_command = f"sed -n '/build_version/p' " \
                                        f"/var/home/{tlname}/{kuafu_name}/artifacts/vdu_config.ini"
        old_build_m = connection_ssh.execute(command=check_current_version_command, connection=connection)
        old_build_list = old_build_m.split('\r\n')
        print(old_build_list)
        old_build = old_build_list[-2]
        print(old_build)
        config_command = f"sed -i 's/{old_build}/build_version={new_build}/' " \
                         f"/var/home/{tlname}/{kuafu_name}/artifacts/vdu_config.ini"
        print(config_command)
        connection_ssh.execute(command=config_command, connection=connection)
        enter_scripts_folder_command_vdu = f'cd {kuafu_name}/' + ';' + '. ./10-vdu-l3call-test.sh'
        print(enter_scripts_folder_command_vdu)
        step_1 = connection_ssh.execute(command=enter_scripts_folder_command_vdu, connection=connection)
        print(step_1)
        delete_command = enter_scripts_folder_command_vdu + ';' + './20-delete-vdu.sh'
        print(delete_command)
        step_2 = connection_ssh.execute(command=delete_command, connection=connection)
        print(step_2)
        load_command = enter_scripts_folder_command_vdu + ';' + './16-onboard-vdu.sh'
        output3 = connection_ssh.execute(command=load_command, connection=connection)
        print(output3)
        # update_command = enter_scripts_folder_command_vdu + ';' + './17-manage-rannic-firmware.sh'
        # output4 = connection_ssh.execute(command=update_command, connection=connection)
        # print(output4)
        create_command = enter_scripts_folder_command_vdu + ';' + './21-create-vdu.sh'
        output5 = connection_ssh.execute(command=create_command, connection=connection)
        print(output5)


def read_target_version(target_build_file, match_mode):
    with open(target_build_file, 'r') as new_version_file:
        content_list = new_version_file.readlines()
        print(content_list)
        # find the string which contain match_mode
        version = [v for v in content_list if v.__contains__(match_mode)]
        # for version_id in content_list:
        #     print(version_id)
        #     # if version_id.__contains__(match_mode):
        #     #     print(version_id)
        #     #     required = version_id.split(":")[1].strip()
        #     version_mode = re.compile(f'build_version_{match_mode}')
        #     print(version_mode)
        #     version = version_mode.findall(version_id)
        # version is a list, get value0, split and get the version number
        new_version = version[0].split(":")[1].strip()
    # return required
    return new_version
