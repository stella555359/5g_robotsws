# owner: liujia
# time: 1/11/24 1:58 PM

# *-coding=utf-8-*

import threading
import taf.transport.ssh as ssh
import time


class UpgradeViaKuafu:
    def __init__(self, target_build_file, match_mode):
        with open(target_build_file, 'r') as new_version_file:
            content_list = new_version_file.readlines()
            print(content_list)
            # find the string which contain match_mode
            version = [v for v in content_list if v.__contains__(match_mode)]
            new_version = version[0].split(":")[1].strip()
        self.v = new_version

    def delete_and_config_vcu(self, host, username, password, connection='vcu_client', tlname='cranuser239'):
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
            config_command = f"sed -i 's/{old_build}/build_version={self.v}/' " \
                             f"/var/home/{tlname}/{kuafu_name}/artifacts/vcu_config.ini"
            print(config_command)
            connection_ssh.execute(command=config_command, connection=connection)
            onboard_command = enter_scripts_folder_command_vcu + ';' + './16-onboard-vcu.sh'
            output16 = connection_ssh.execute(command=onboard_command, connection=connection)
            print(output16)
            create_command = enter_scripts_folder_command_vcu + ';' + './21-create-vcu.sh'
            output21 = connection_ssh.execute(command=create_command, connection=connection)
            print(output21)

    def delete_and_config_vdu(self, host, username, password, connection='vdu_client', tlname='core'):
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
            enter_scripts_folder_command_vdu = f'cd {kuafu_name}/' + ';' + '. ./10-vdu-l3call-test.sh'
            print(enter_scripts_folder_command_vdu)
            step_1 = connection_ssh.execute(command=enter_scripts_folder_command_vdu, connection=connection)
            print(step_1)
            delete_command = enter_scripts_folder_command_vdu + ';' + './20-delete-vdu.sh'
            print(delete_command)
            step_2 = connection_ssh.execute(command=delete_command, connection=connection)
            print(step_2)
            check_current_version_command = f"sed -n '/build_version/p' " \
                                            f"/var/home/{tlname}/{kuafu_name}/artifacts/vdu_config.ini"
            old_build_m = connection_ssh.execute(command=check_current_version_command, connection=connection)
            old_build = old_build_m.split('\r\n')[-2]
            print(old_build)
            config_command = f"sed -i 's/{old_build}/build_version={self.v}/' " \
                             f"/var/home/{tlname}/{kuafu_name}/artifacts/vdu_config.ini"
            print(config_command)
            connection_ssh.execute(command=config_command, connection=connection)
            load_command = enter_scripts_folder_command_vdu + ';' + './16-onboard-vdu.sh'
            output3 = connection_ssh.execute(command=load_command, connection=connection)
            print(output3)
            create_command = enter_scripts_folder_command_vdu + ';' + './21-create-vdu.sh'
            output5 = connection_ssh.execute(command=create_command, connection=connection)
            print(output5)

    def upgrade_via_threading(self, depart,
                              host_vcu1, username_vcu1, password_vcu1,
                              host_vcu2, username_vcu2, password_vcu2,
                              host_vdu1, username_vdu1, password_vdu1,
                              host_vdu2, username_vdu2, password_vdu2,
                              host_vdu3, username_vdu3, password_vdu3,
                              connection_vcu1='vcu1', connection_vcu2='vcu2', connection_vdu1='vdu1',
                              connection_vdu2='vdu2', connection_vdu3='vdu3'):
        threads = []
        if depart == 'vcu':
            th1 = threading.Thread(target=self.delete_and_config_vcu,
                                   args=(host_vcu1, username_vcu1, password_vcu1, connection_vcu1))
            threads.append(th1)
            th2 = threading.Thread(target=self.delete_and_config_vcu,
                                   args=(host_vcu2, username_vcu2, password_vcu2, connection_vcu2))
            threads.append(th2)
        elif depart == 'vdu':
            th1 = threading.Thread(target=self.delete_and_config_vdu,
                                   args=(host_vdu1, username_vdu1, password_vdu1, connection_vdu1))
            threads.append(th1)
            th2 = threading.Thread(target=self.delete_and_config_vdu,
                                   args=(host_vdu2, username_vdu2, password_vdu2, connection_vdu2))
            threads.append(th2)
            th3 = threading.Thread(target=self.delete_and_config_vdu,
                                   args=(host_vdu3, username_vdu3, password_vdu3, connection_vdu3))
            threads.append(th3)
        for t in threads:
            t.start()
            time.sleep(1)
        for t in threads:
            t.join()


def upgrade_cloud_via_kuafu(target_build_file, match_mode,
                            host_vcu1='none', username_vcu1='none', password_vcu1='none',
                            host_vcu2='none', username_vcu2='none', password_vcu2='none',
                            host_vdu1='none', username_vdu1='none', password_vdu1='none',
                            host_vdu2='none', username_vdu2='none', password_vdu2='none',
                            host_vdu3='none', username_vdu3='none', password_vdu3='none'):
    up = UpgradeViaKuafu(target_build_file, match_mode)
    up.upgrade_via_threading(depart=match_mode,
                             host_vcu1=host_vcu1, username_vcu1=username_vcu1, password_vcu1=password_vcu1,
                             host_vcu2=host_vcu2, username_vcu2=username_vcu2, password_vcu2=password_vcu2,
                             host_vdu1=host_vdu1, username_vdu1=username_vdu1, password_vdu1=password_vdu1,
                             host_vdu2=host_vdu2, username_vdu2=username_vdu2, password_vdu2=password_vdu2,
                             host_vdu3=host_vdu3, username_vdu3=username_vdu3, password_vdu3=password_vdu3)
