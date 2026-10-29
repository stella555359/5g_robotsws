# *-coding=utf-8-*

# Name: Ming Shi
# Time: 2023/3/6 17:37
import json
import time
from datetime import datetime

import requests
from lxml import etree
from taf.sbts.oam.coam.admin import admin
import taf.transport.ssh as ssh
from robot.libraries.BuiltIn import BuiltIn
import threading


download_package_link = "https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/"
json_file_path = "/opt/workspace/SCF"
download_path = "/home/ute/Downloads"
upgrade_report_file = "update_report.txt"
tl = BuiltIn().get_variable_value("${tl}")


class GnbCommon:
    def __init__(self):
        self.sshconn = ssh.ssh()
        self.coam = admin()
        self.built_in = BuiltIn()

    def connect_bts_coam(self, ip, username='Nemuadmin', password='nemuuser', connection='default'):
        self.coam.connect_to(bts_host=ip, bts_port=443, username=username, password=password,
                             use_ssl=True, update_interval=5000, admin_api_log_dir='', name=connection,
                             bundle_path=None, release=None, timeout=30)

    def disconnect_bts_coam(self, connection='default'):
        self.coam.teardown(connection=connection)

    def connect_bts_ssh(self, ip, username, password, connection='default'):
        self.sshconn.connect_to(hostname=ip, username=username, password=password, alias=connection)

    def disconnect_bts_ssh(self, connection='default'):
        self.sshconn.disconnect(connection=connection)

    def check_testline_type(self, connection='default'):
        result = self.sshconn.execute(command='ddal -s ddal_sysinfo_module_get_unit_id 0',
                                      connection=connection)
        bts_type = result.split('\n')[1].split('=')[1][1:-2]

        return bts_type

    def check_bmod_status(self, connection='default'):
        hw_info = self.coam.get_detected_hw_info(timeout=60, connection=connection)
        for bmod in hw_info['basebandModules']:
            assert bmod['status']['administrativeState'] == 'Unlocked'
            assert bmod['status']['operationalState'] == 'enabled'
            assert bmod['status']['proceduralStatus'] == 'configured'
            assert bmod['status']['usageState'] == 'Active'
        print("bmod check success!")

    def check_smod_status(self, connection='default'):
        hw_info = self.coam.get_detected_hw_info(timeout=60, connection=connection)
        for smod in hw_info['systemModules']:
            assert smod['status']['administrativeState'] == 'Unlocked'
            assert smod['status']['operationalState'] == 'enabled'
            assert smod['status']['proceduralStatus'] == 'configured'
            assert smod['status']['usageState'] == 'Active'
        print("smod check success!")

    def check_rmod_status(self, connection='default'):
        hw_info = self.coam.get_detected_hw_info(timeout=60, connection=connection)
        for rmod in hw_info['radioModules']['rmod']:
            assert rmod['status']['administrativeState'] == 'Unlocked'
            assert rmod['status']['operationalState'] == 'enabled'
            assert rmod['status']['proceduralStatus'] == 'configured'
            assert rmod['status']['usageState'] == 'Active'
        print("rmod check success!")

    def check_x2_status(self, connection='default'):
        lteenb_a_list = self.coam.get_managed_objects(class_name='LTEENB_A', timeout=60, connection=connection)
        lteenb_r_list = self.coam.get_managed_objects(class_name='LTEENB_R', timeout=60, connection=connection)
        x2_lock_state_dict = self.coam.get_parameters(dist_name=lteenb_a_list[0]['distName'], pattern='.*', timeout=60,
                                                      connection=connection)
        x2_status_dict = self.coam.get_parameters(dist_name=lteenb_r_list[0]['distName'], pattern='.*', timeout=60,
                                                  connection=connection)
        assert x2_lock_state_dict['x2LinkLock'] == 'unlocked'
        assert x2_status_dict['x2LinkStatus'] == 'available'
        print("x2 check success!")

    def check_cell_status(self, connection='default'):
        cell_status_list = self.coam.get_cells_info(timeout=60, connection=connection)
        for cell in cell_status_list:
            assert cell['status']['administrativeState'] == 'Unlocked'
            assert cell['status']['operationalState'] == 'enabled'
            assert cell['status']['proceduralStatus'] == 'configured'
            assert cell['status']['usageState'] == 'Active'
        print("cell check success!")

    def get_gnb_cu_type(self, connection='default'):
        para_list = self.coam.get_managed_objects(class_name="NRBTS_A", timeout=60, connection=connection)
        gnb_cu_type_dict = self.coam.get_parameters(dist_name=para_list[0]['distName'], pattern='.*', timeout=60,
                                                    connection=connection)
        print(f"gnb cu type is: {gnb_cu_type_dict['gNbCuType']}")
        return gnb_cu_type_dict['gNbCuType']

    def get_activate_alarms(self, connection='default'):
        return self.coam.get_active_alarms(severity=None, timeout=60, connection=connection)

    @staticmethod
    def check_alarms(alarm_list):
        for alarm in alarm_list:
            assert alarm['faultId'] != '10'
            assert alarm['faultId'] != '4527'
            assert alarm['faultId'] != '4341'
            assert alarm['faultId'] != '6450'
            assert alarm['faultId'] != '16'
            assert alarm['faultId'] != '1806'
            assert alarm['faultId'] != '1868'
            assert alarm['faultId'] != '4352'
            assert alarm['faultId'] != '4352'
            assert alarm['faultId'] != '6911'

    def get_history_alarms(self, connection='default'):
        return self.coam.get_alarm_history(timeout=30, connection=connection, detailed_output=True)

    def get_bts_version(self, connection='default'):
        return self.coam.get_software_info(timeout=30, connection=connection)

    def upgrade(self, package_path, package_name, connection='default'):
        self.coam.update_software(sw_package=f"{package_path}/{package_name}", should_activate=True,
                                  timeout=7200, connection=connection, should_reset_radios=False)

    def get_upgrade_report(self, report_path, report_name, connection='default'):
        self.coam.get_sw_update_report(target_file_name=f"{report_path}/{report_name}", timeout=120,
                                       connection=connection)

    def rollback(self, connection='default'):
        self.coam.rollback_software(timeout=2400, detailed_output=False, connection=connection)

    def reset(self, connection='default'):
        self.coam.reset_site(timeout=300, connection=connection, wait_for_reconnection=True, detailed_output=False)

    def scf_commission(self, scf_file, skip_parameter_relation_errors=True, timeout=300, connection='default'):
        result = self.coam.perform_commissioning(bts_id=None, scf_file=scf_file,
                                                 skip_parameter_relation_errors=skip_parameter_relation_errors,
                                                 should_activate=True, timeout=timeout, connection=connection)
        return result

    def get_scf_file(self, local_dir_path, file_name, timeout=60, connection='default'):
        time_stamp = datetime.now().strftime("%Y%m%d%H%M%S")
        scf_file_name = f"{file_name}_scf_backup_{time_stamp}.xml"
        scf_path = self.coam.get_current_scf_file(local_dir_path=local_dir_path, file_name=scf_file_name,
                                                  timeout=timeout, connection=connection)
        return scf_path

    def collect_snapshot(self, local_dir_path, snapshot_name, timeout=360, connection='default'):
        time_stamp = datetime.now().strftime("%Y%m%d%H%M%S")
        snapshot_file_name = f"{local_dir_path}/{snapshot_name}_snapshot_rest_api_{time_stamp}.zip"
        self.coam.get_snapshot(target_file_name=snapshot_file_name, timeout=timeout, connection=connection)

    def collect_syslog(self):
        pass

    def collect_ru_logs(self):
        pass


class OperateGnb(GnbCommon):
    def __init__(self):
        super().__init__()

    @staticmethod
    def get_download_link_release(release_url=download_package_link):
        """
        get release names from download link
        :param release_url: download link
        :return:  list of release names
        """
        release_name = []
        response = requests.get(url=release_url)
        if response.status_code == 200:
            html = etree.HTML(response.text)
            release = html.xpath('//a/text()')
            for i in release:
                if i[:-1].endswith('packages'):
                    release_name.append(i[:-1].split('_')[0])
        return release_name

    @staticmethod
    def get_bts_info_from_json_file(file):
        """
        Get the information in the json file
        :param file: the path and name of json file
        :return: list with fields
        """
        node_index_list = []
        node_type_list = []
        node_upgrade_boolean_list = []
        node_rollback_boolean_list = []
        node_reset_boolean_list = []
        download_version_list = []
        repeat_times_list = []
        action_first_list = []
        with open(file=file, mode='r') as f:
            json_data = json.load(f)
        for info in json_data:
            node_index_list.append(info['node_index'])
            node_type_list.append(info['node_type'])
            node_upgrade_boolean_list.append(info['node_upgrade_boolean'])
            node_rollback_boolean_list.append(info['node_rollback_boolean'])
            node_reset_boolean_list.append(info['node_reset_boolean'])
            download_version_list.append(info['download_version'])
            repeat_times_list.append(info['repeat_times'])
            action_first_list.append(info['action_first'])
        return node_index_list, node_type_list, node_upgrade_boolean_list, node_rollback_boolean_list, \
            node_reset_boolean_list, download_version_list, repeat_times_list, action_first_list

    def download_package(self, package_local_path, package_name, package_link, connection='default'):
        """
        download package on ute
        :param package_local_path: The path where the package is stored
        :param package_name: build name <SBTS23R2_ENB_0000_000328_000000>
        :param package_link: The download link of the package
        :param connection: connection to use
        :return:
        """
        check_package_result = self.sshconn.execute(command=f'cd {package_local_path};ls -l | grep {package_name}',
                                                    connection=connection)
        print(f"check_package_result: {check_package_result}")
        if package_name not in check_package_result:
            download_result = self.sshconn.execute(command=f'cd {package_local_path};wget {package_link}{package_name}',
                                                   connection=connection, timeout=6000)
            if 'saved' in download_result:
                pass
            else:
                print(f'package {package_name} download failed, please check!')

    def check_upgrade_report(self, report_path, report_name, connection='default'):
        """
        check upgrade report
        :param report_path: path of report file
        :param report_name: name of report file
        :param connection: AdminConnection object or if used, string name alias.
        :return:
        """
        line_number = self.sshconn.execute(command=f'cat {report_path}/{report_name} |grep -n '
                                                   f'"Software Build Download" |tail -1 |cut -d ":" -f1',
                                           connection=connection)
        output = self.sshconn.execute(command=f"tail -n \\+{int(line_number)} {report_path}/{report_name}",
                                      connection=connection)
        assert "error" or "failed" not in output

    def wait_for_bts_ready_and_cell_setup(self, connection_coam='default', connection_ssh='default', bts_type='gnb'):
        """
        check bmod, smod, rmod, x2, cell status
        :param connection_coam: AdminConnection object or if used, string name alias.
        :param connection_ssh: connection to use
        :param bts_type: bts type <gnb, enb>
        :return:
        """
        system_type = self.check_testline_type(connection=connection_ssh)
        gnb_cu_type = self.get_gnb_cu_type(connection=connection_coam)
        for bmod_time in range(30):
            try:
                if system_type != 'ASOD' or system_type != 'ASOE':
                    self.check_bmod_status(connection=connection_coam)
            except Exception as e:
                print(f"bmod_time: {e}")
                time.sleep(20)
                continue
            else:
                break
        for smod_time in range(30):
            try:
                self.check_smod_status(connection=connection_coam)
            except Exception as e:
                print(f"smod_time: {e}")
                time.sleep(20)
                continue
            else:
                break
        for rmod_time in range(30):
            try:
                self.check_rmod_status(connection=connection_coam)
            except Exception as e:
                print(f"rmod_time: {e}")
                time.sleep(20)
                continue
            else:
                break
        if bts_type == 'gnb':
            for x2_time in range(30):
                try:
                    if gnb_cu_type != 'SA':
                        self.check_x2_status(connection=connection_coam)
                except Exception as e:
                    print(f"x2_time: {e}")
                    time.sleep(20)
                    continue
                else:
                    break
        for cell_time in range(30):
            try:
                self.check_cell_status(connection=connection_coam)
            except Exception as e:
                print(f"cell_time: {e}")
                time.sleep(20)
                continue
            else:
                break

    def connections(self, index=0, bts_type='gnb'):
        """
        connect all connections <bts coam, bts ssh, ute ssh>
        :param index: bts index <0, 1, 2>
        :param bts_type: bts type <gnb, enb>
        :return:
        """
        if bts_type == 'gnb':
            bts_ip = tl.gnbs[index].cu.oam_ssh_connection_details.addr
        elif bts_type == 'enb':
            bts_ip = tl.enbs[index].airscale.common_units[0].lmp_connection.addr
        # wait for bts startup 20 times per 30 second after reset
        for i in range(20):
            try:
                self.connect_bts_coam(ip=bts_ip,
                                      connection=f'GNB{index}_COAM')
                self.connect_bts_ssh(ip=bts_ip,
                                     username=tl.gnbs[index].dus[0].airscale.common_units[0].lmp_connection.
                                     username,
                                     password=tl.gnbs[index].dus[0].airscale.common_units[0].lmp_connection.
                                     password,
                                     connection=f'GNB{index}_SSH')
                self.connect_bts_ssh(ip=tl.test_pc.default_ssh_connection_details.addr,
                                     username=tl.test_pc.default_ssh_connection_details.username,
                                     password=tl.test_pc.default_ssh_connection_details.password,
                                     connection=f'UTE_{index}')
            except Exception as e:
                print(f"connection before upgrade: {e}")
                time.sleep(30)
                continue
            else:
                break

    def disconnections(self, index=0):
        """
        disconnect all connections, <bts coam, bts ssh, ute ssh>
        :param index: bts index <0, 1, 2>
        :return:
        """
        self.disconnect_bts_coam(connection=f'GNB{index}_COAM')
        self.disconnect_bts_ssh(connection=f'GNB{index}_SSH')
        self.disconnect_bts_ssh(connection=f'UTE_{index}')

    def bts_upgrade(self, build, index=0, bts_type='gnb', upgrade_boolean=True):
        """
        bts upgrade
        :param build: build name <SBTS23R2_ENB_0000_000328_000000>
        :param index: bts index <0, 1, 2>
        :param bts_type:  bts type <gnb, enb>
        :param upgrade_boolean: is need operate upgrade action <True, False>
        :return:
        """
        if upgrade_boolean == 'True':
            try:
                self.connections(index=index, bts_type=bts_type)
            except Exception as e:
                print(f"all connection: {e}")
            else:
                # get current version on bts
                current_version = self.get_bts_version(connection=f'GNB{index}_COAM')
                print(f"current activate version is {current_version['Active SW version']}")
                # get all release of download link
                release_ = self.get_download_link_release()
                initial_build = build
                if current_version['Active SW version'] != build:
                    # if release not in all release, version change to SBTS00
                    if build.split('_')[0] not in release_:
                        build = build.replace(build.split('_')[0], 'SBTS00')
                    # start upgrade
                    self.upgrade(package_path=download_path,
                                 package_name=f"{build}_release_BTSSM_downloadable_A54.zip",
                                 connection=f'GNB{index}_COAM')
                    self.disconnections(index=index)
                    # wait 120 second to activate new build
                    time.sleep(120)

                    self.connections(index=index, bts_type=bts_type)
                    after_upgrade_version = self.get_bts_version(connection=f'GNB{index}_COAM')
                    print(f"after upgrade: version is {after_upgrade_version['Active SW version']}")
                    assert after_upgrade_version['Active SW version'] == initial_build
                    assert after_upgrade_version['Passive SW version'] == current_version['Active SW version']
                    self.get_upgrade_report(report_path=download_path, report_name=upgrade_report_file,
                                            connection=f'GNB{index}_COAM')
                    self.check_upgrade_report(report_path=download_path, report_name=upgrade_report_file,
                                              connection=f'UTE_{index}')
                    self.wait_for_bts_ready_and_cell_setup(connection_coam=f'GNB{index}_COAM',
                                                           connection_ssh=f'GNB{index}_SSH',
                                                           bts_type=bts_type)
                    # wait 120 sec if some alarm raise
                    time.sleep(120)
                    activate_alarms = self.get_activate_alarms(connection=f'GNB{index}_COAM')
                    self.check_alarms(alarm_list=activate_alarms)
                else:
                    print("current version is same with version that needs to be upgraded, so need not to be upgraded!")
            finally:
                self.disconnections(index=index)

    def get_all_packages(self):
        """
        Get all the packages that need to be downloaded
        :return: all the packages that need to be downloaded
        """
        all_package = []
        packages_list = self.get_bts_info_from_json_file(file=f"{json_file_path}/upgrade_rollback.json")[5]
        for p in packages_list:
            all_package.extend(p[:])
        all_packages = list(set(all_package))
        print(all_packages)
        return all_packages

    def download_all_packages(self, build, index):
        """
        download package
        :param build: build name <SBTS23R2_ENB_0000_000328_000000>
        :param index: ute index
        :return:
        """
        try:
            for i in range(6):
                try:
                    self.connect_bts_ssh(ip=tl.test_pc.default_ssh_connection_details.addr,
                                         username=tl.test_pc.default_ssh_connection_details.username,
                                         password=tl.test_pc.default_ssh_connection_details.password,
                                         connection=f'UTE_{index}')
                except Exception as e:
                    print(f"connect ute to download package: {e}")
                    time.sleep(20)
                    continue
                else:
                    break
        except Exception as e:
            print(f"connection: {e}")
        else:
            # get all release of download link
            release_ = self.get_download_link_release()
            # if release not in all release, version change to SBTS00
            if build.split('_')[0] not in release_:
                build = build.replace(build.split('_')[0], 'SBTS00')
            print(build)
            # download package via wget command on ute
            self.download_package(package_local_path=download_path,
                                  package_name=f"{build}_release_BTSSM_downloadable_A54.zip",
                                  package_link=f"{download_package_link}/{build.split('_')[0]}_"
                                               f"packages/{build}/",
                                  connection=f'UTE_{index}')
        finally:
            self.disconnect_bts_ssh(connection=f'UTE_{index}')

    def download_package_threading(self):
        """
        download multi packages simultaneously via threading
        :return:
        """
        if 'True' in self.get_bts_info_from_json_file(file=f"{json_file_path}/upgrade_rollback.json")[2]:
            threads = []
            all_packages = self.get_all_packages()
            for i in range(len(all_packages)):
                th = threading.Thread(target=self.download_all_packages, args=(all_packages[i], i))
                threads.append(th)
            for t in threads:
                t.start()
            for t in threads:
                t.join()

    def bts_upgrade_threading(self):
        """
        multi bts operate upgrade simultaneously via threading
        :return:
        """
        threads = []
        result = self.get_bts_info_from_json_file(file=f"{json_file_path}/upgrade_rollback.json")
        # result[0] get bts index from json file
        for i in range(len(result[0])):
            th = threading.Thread(target=self.bts_upgrade, args=(result[5][i][0], result[0][i], result[1][i],
                                                                 result[2][i]))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def bts_rollback(self, index=0, bts_type='gnb', rollback_boolean=True):
        """
        bts rollback
        :param index: bts index <0, 1, 2>
        :param bts_type: bts type <gnb, enb>
        :param rollback_boolean: is need operate rollback action <True, False>
        :return:
        """
        if rollback_boolean == 'True':
            try:
                self.connections(index=index, bts_type=bts_type)
            except Exception as e:
                print(f"all connection: {e}")
            else:
                # get current version on bts
                current_version = self.get_bts_version(connection=f'GNB{index}_COAM')
                print(f"current activate version is {current_version['Active SW version']}")
                # start rollback
                self.rollback(connection=f"GNB{index}_COAM")
                self.disconnections(index=index)
                # wait 120 second to activate new build
                time.sleep(120)
                self.connections(index=index, bts_type=bts_type)
                after_rollback_version = self.get_bts_version(connection=f'GNB{index}_COAM')
                print(f"after upgrade: version is {after_rollback_version['Active SW version']}")
                assert after_rollback_version['Active SW version'] == current_version['Passive SW version']
                assert after_rollback_version['Passive SW version'] == current_version['Active SW version']
                self.wait_for_bts_ready_and_cell_setup(connection_coam=f'GNB{index}_COAM',
                                                       connection_ssh=f'GNB{index}_SSH',
                                                       bts_type=bts_type)
                time.sleep(120)
                activate_alarms = self.get_activate_alarms(connection=f'GNB{index}_COAM')
                self.check_alarms(alarm_list=activate_alarms)
            finally:
                self.disconnections(index=index)

    def bts_rollback_threading(self):
        """
        multi ue operate rollback simultaneously via threading
        :return:
        """
        threads = []
        result = self.get_bts_info_from_json_file(file=f"{json_file_path}/upgrade_rollback.json")
        # result[0] get bts index from json file
        for i in range(len(result[0])):
            th = threading.Thread(target=self.bts_rollback, args=(result[0][i], result[1][i], result[3][i]))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def bts_reset(self, index=0, bts_type='gnb', reset_boolean=True):
        """
        bts reset
        :param index: bts index <0, 1, 2>
        :param bts_type: bts type <gnb, enb>
        :param reset_boolean: is need operate reset action <True, False>
        :return:
        """
        if reset_boolean == 'True':
            try:
                self.connections(index=index, bts_type=bts_type)
            except Exception as e:
                print(f"all connection: {e}")
            else:
                # get current version on bts
                current_version = self.get_bts_version(connection=f'GNB{index}_COAM')
                print(f"current activate version is {current_version['Active SW version']}")
                # start reset
                self.reset(connection=f"GNB{index}_COAM")
                self.disconnections(index=index)
                # wait 120 second to trigger reset
                time.sleep(120)
                self.connections(index=index, bts_type=bts_type)
                after_reset_version = self.get_bts_version(connection=f'GNB{index}_COAM')
                print(f"after upgrade: version is {after_reset_version['Active SW version']}")
                assert after_reset_version['Active SW version'] == current_version['Active SW version']
                assert after_reset_version['Passive SW version'] == current_version['Passive SW version']
                self.wait_for_bts_ready_and_cell_setup(connection_coam=f'GNB{index}_COAM',
                                                       connection_ssh=f'GNB{index}_SSH',
                                                       bts_type=bts_type)
                time.sleep(120)
                activate_alarms = self.get_activate_alarms(connection=f'GNB{index}_COAM')
                self.check_alarms(alarm_list=activate_alarms)
            finally:
                self.disconnections(index=index)

    def bts_reset_threading(self):
        """
        multi bts operate reset simultaneously via threading
        :return:
        """
        threads = []
        result = self.get_bts_info_from_json_file(file=f"{json_file_path}/upgrade_rollback.json")
        # result[0] get bts index from json file
        for i in range(len(result[0])):
            th = threading.Thread(target=self.bts_reset, args=(result[0][i], result[1][i], result[4][i]))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def upgrade_rollback_reset(self):
        """
        multi bts operate upgrade, rollback and reset
        :return:
        """
        result = self.get_bts_info_from_json_file(file=f"{json_file_path}/upgrade_rollback.json")
        # result[7][0] Get which action is executed first
        # result[6][0] Get the number of executions
        for time_index in range(int(result[6][0])):
            if result[7][0] == 'upgrade':
                self.download_package_threading()
                self.bts_upgrade_threading()
                self.bts_rollback_threading()
                self.bts_reset_threading()
            elif result[7][0] == 'rollback':
                self.download_package_threading()
                self.bts_rollback_threading()
                self.bts_upgrade_threading()
                self.bts_reset_threading()
            elif result[7][0] == 'reset':
                self.download_package_threading()
                self.bts_reset_threading()
                self.bts_upgrade_threading()
                self.bts_rollback_threading()

    def bts_commission(self, scf_file, skip_parameter_relation_errors=True, timeout=600, index=0, bts_type='gnb',
                       is_pdl_checking_needed=True):
        """
        import scf file
        :param scf_file: scf
        :param skip_parameter_relation_errors:
        :param timeout: Timeout for the operation
        :param index: bts_index
        :param bts_type: bts type, gnb or enb
        :param is_pdl_checking_needed: pdl validation is needed
        :return:
        """
        if bts_type == 'gnb':
            bts_ip = tl.gnbs[index].cu.oam_ssh_connection_details.addr
        elif bts_type == 'enb':
            bts_ip = tl.enbs[index].airscale.common_units[0].lmp_connection.addr
        try:
            for i in range(6):
                try:
                    self.connect_bts_coam(ip=bts_ip,
                                          connection=f'GNB{index}_COAM')
                except Exception as e:
                    print(f"connect NB: {e}")
                    time.sleep(20)
                    continue
                else:
                    break
        except Exception as e:
            print(e)
        else:
            commission_result = self.scf_commission(scf_file=scf_file,
                                                    skip_parameter_relation_errors=skip_parameter_relation_errors,
                                                    timeout=timeout, connection=f'GNB{index}_COAM')
            assert commission_result['commissioningResult']['activationResult']['resultNode']['parameters']['result'] \
                   == 'Success'
            assert commission_result['validationResult']['niddValidationResult']['status'] == 'OK'
            if is_pdl_checking_needed is True:
                assert commission_result['validationResult']['pdlValidationResult']['status'] == 'OK'
            print(f"GNB{index}_COAM Commission with scf file via rest API successfully.")

            # wait 120 second to bts setup after import scf file
            # time.sleep(120)

            # self.connections(index=index, bts_type=bts_type)
            # self.wait_for_bts_ready_and_cell_setup(connection_coam=f'GNB{index}_COAM',
            #                                       connection_ssh=f'GNB{index}_SSH',
            #                                       bts_type=bts_type)
            # print(f"GNB{index} cells is ready")
        finally:
            self.disconnect_bts_coam(connection=f'GNB{index}_COAM')

    def bts_commission_threading(self, index_list, scf_list, skip_parameter_relation_errors=True, timeout=600,
                                 bts_type='gnb', is_pdl_checking_needed=True):
        """
        Simultaneous operation of imported scf using threads
        :param index_list: (list) bts index list <[0, 1, 2]>
        :param scf_list: (list) scf list of bts
        :param skip_parameter_relation_errors: Skip parameter relation errors
        :param timeout: Timeout for the operation
        :param bts_type: bts type, gnb or enb
        :param is_pdl_checking_needed: pdl validation is needed
        :return:
        """
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.bts_commission, args=(scf_list[i], skip_parameter_relation_errors,
                                                                    timeout, j, bts_type, is_pdl_checking_needed))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()
