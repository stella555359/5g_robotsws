"""
Author: Ming Shi
Contact: ming.shi@nokia-sbell.com
"""

import json
import time
from datetime import datetime

import requests
from lxml import etree
from taf.sbts.oam.coam.admin import admin
import taf.transport.ssh as ssh
from robot.libraries.BuiltIn import BuiltIn
import threading
from uuf_data import *

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
        fault_list = []
        for alarm in alarm_list:
            fault_list.append(alarm['faultId'])
        diff_faults = set(fault_list) - set(COMMON_FAULT_ID_LIST)
        if len(diff_faults) != 0:
            print(f"unexpected faults found: {diff_faults}")
            return list(diff_faults)
        else:
            print("no unexpected faults found")
            return True
        # for alarm in alarm_list:
        #     assert alarm['faultId'] != '10'
        #     assert alarm['faultId'] != '4527'
        #     assert alarm['faultId'] != '4341'
        #     assert alarm['faultId'] != '6450'
        #     assert alarm['faultId'] != '16'
        #     assert alarm['faultId'] != '1806'
        #     assert alarm['faultId'] != '1868'
        #     assert alarm['faultId'] != '4352'
        #     assert alarm['faultId'] != '4352'
        #     assert alarm['faultId'] != '6911'

    def get_history_alarms(self, connection='default'):
        return self.coam.get_alarm_history(timeout=30, connection=connection, detailed_output=True)

    def get_list_historic_alarms(self, connection='default', load_history=False):
        return self.coam.get_historic_alarms(timeout=30, connection=connection, severity=None,
                                             load_history=load_history)

    @staticmethod
    def check_history_faults(history_fault_list):
        fault_list = []
        for alarm in history_fault_list:
            fault_list.append(alarm['faultId'])
        diff_faults = set(fault_list) - set(HISTORY_FAULT_LIST)
        if len(diff_faults) != 0:
            print(f"unexpected faults found: {diff_faults}")
            return list(diff_faults)
        else:
            print("no unexpected faults found")
            return True

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

    def get_cell_list_info(self, timeout=60, connection='default', detailed_output=False):
        return self.coam.get_cell_list(timeout=timeout, connection=connection, detailed_output=detailed_output)

    # def get_cells_info(self):
    #     return self.coam.get_cells_info(cell_type='nr', timeout=10, connection=None, detailed_output=False)


class OperateGnb(GnbCommon):
    def __init__(self):
        super().__init__()

    @staticmethod
    def get_download_link_release(release_url=DOWNLOAD_PACKAGE_LINK):
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
                if i[:4].startswith('SBTS') and i[-2].isdigit():
                    release_name.append(i[:-1])
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
            times = 30
            try:
                if system_type != 'ASOD' or system_type != 'ASOE':
                    self.check_bmod_status(connection=connection_coam)
                    break
            except Exception as e:
                print(f"bmod_time check {bmod_time + 1} times: {e}")
                times -= 1
                if times >= 0:
                    time.sleep(20)
                else:
                    raise Exception("bmod is not ready, please check")
        for smod_time in range(30):
            times = 30
            try:
                self.check_smod_status(connection=connection_coam)
                break
            except Exception as e:
                print(f"smod_time check {smod_time + 1} times: {e}")
                times -= 1
                if times >= 0:
                    time.sleep(20)
                else:
                    raise Exception("smod is not ready, please check")
        for rmod_time in range(30):
            times = 30
            try:
                self.check_rmod_status(connection=connection_coam)
                break
            except Exception as e:
                print(f"rmod_time check {rmod_time + 1} times: {e}")
                times -= 1
                if times >= 0:
                    time.sleep(20)
                else:
                    raise Exception("rmod is not ready, please check")
        if bts_type == 'gnb':
            for x2_time in range(30):
                times = 30
                try:
                    if gnb_cu_type != 'SA':
                        self.check_x2_status(connection=connection_coam)
                        break
                except Exception as e:
                    print(f"x2_time check {x2_time + 1} times: {e}")
                    times -= 1
                    if times >= 0:
                        time.sleep(20)
                    else:
                        raise Exception("x2 is not ready, please check")
        for cell_time in range(30):
            times = 30
            try:
                self.check_cell_status(connection=connection_coam)
                break
            except Exception as e:
                print(f"cell_time check {cell_time + 1} times: {e}")
                times -= 1
                if times >= 0:
                    time.sleep(20)
                else:
                    raise Exception("cell is not ready, please check")

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
            times = 20
            try:
                self.connect_bts_coam(ip=bts_ip,
                                      connection=f'{bts_type}{index}_COAM')
                self.connect_bts_ssh(ip=bts_ip,
                                     username=tl.gnbs[index].dus[0].airscale.common_units[0].lmp_connection.
                                     username,
                                     password=tl.gnbs[index].dus[0].airscale.common_units[0].lmp_connection.
                                     password,
                                     connection=f'{bts_type}{index}_SSH')
                self.connect_bts_ssh(ip=tl.test_pc.default_ssh_connection_details.addr,
                                     username=tl.test_pc.default_ssh_connection_details.username,
                                     password=tl.test_pc.default_ssh_connection_details.password,
                                     connection=f'UTE_{index}')
                break
            except Exception as e:
                print(f"connection before upgrade {i + 1} times: {e}")
                times -= 0
                if times >= 0:
                    time.sleep(30)
                else:
                    raise Exception("connect failed, please check")

    def disconnections(self, bts_type='gnb', index=0):
        """
        disconnect all connections, <bts coam, bts ssh, ute ssh>
        :param index: bts index <0, 1, 2>
        :return:
        """
        self.disconnect_bts_coam(connection=f'{bts_type}{index}_COAM')
        self.disconnect_bts_ssh(connection=f'{bts_type}{index}_SSH')
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
                current_version = self.get_bts_version(connection=f'{bts_type}{index}_COAM')
                print(f"current activate version is {current_version['Active SW version']}")
                print(f"current passive version is {current_version['Passive SW version']}")
                # SBTS24R2_ENB_0000_000279_000000
                passive_version = current_version['Passive SW version']
                active_version = current_version['Active SW version']
                passive_year_num = int(passive_version.split("_")[0][-4:-2])
                passive_release_num = int(passive_version.split("_")[0][-1])
                active_year_num = int(active_version.split("_")[0][-4:-2])
                active_release_num = int(active_version.split("_")[0][-1])
                if (passive_year_num < active_year_num) or (
                        passive_year_num == active_year_num and passive_release_num < active_release_num):
                    self.bts_rollback(index=index, bts_type=bts_type, rollback_boolean=True)
                # get all release of download link
                release_ = self.get_download_link_release()
                initial_build = build
                if current_version['Active SW version'] != build:
                    # if release not in all release, version change to SBTS00
                    if build.split('_')[0] not in release_:
                        build = build.replace(build.split('_')[0], 'SBTS00')
                    # start upgrade
                    self.upgrade(package_path=DOWNLOAD_PATH,
                                 package_name=f"{build}_release_BTSSM_downloadable_A54.zip",
                                 connection=f'{bts_type}{index}_COAM')
                    self.disconnections(index=index)
                    # wait 120 second to activate new build
                    time.sleep(120)

                    self.connections(index=index, bts_type=bts_type)
                    after_upgrade_version = self.get_bts_version(connection=f'{bts_type}{index}_COAM')
                    print(f"after upgrade: version is {after_upgrade_version['Active SW version']}")
                    assert after_upgrade_version['Active SW version'] == initial_build
                    assert after_upgrade_version['Passive SW version'] == current_version['Active SW version']
                    self.get_upgrade_report(report_path=DOWNLOAD_PATH, report_name=UPGRADE_REPORT_FILE,
                                            connection=f'{bts_type}{index}_COAM')
                    self.check_upgrade_report(report_path=DOWNLOAD_PATH, report_name=UPGRADE_REPORT_FILE,
                                              connection=f'UTE_{index}')
                    self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                           connection_ssh=f'{bts_type}{index}_SSH',
                                                           bts_type=bts_type)
                    # wait 120 sec if some alarm raise
                    time.sleep(120)
                    activate_alarms = self.get_activate_alarms(connection=f'{bts_type}{index}_COAM')
                    result_activate_alarms = self.check_alarms(alarm_list=activate_alarms)
                    history_faults = bts_op.get_list_historic_alarms(connection=f'{bts_type}{index}_COAM',
                                                                     load_history=True)
                    result_history_faults = bts_op.check_history_faults(history_fault_list=history_faults)
                    assert result_activate_alarms is True and result_history_faults is True
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
        packages_list = self.get_bts_info_from_json_file(file=f"{JSON_FILE_PATH}/upgrade_rollback.json")[5]
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
                times = 6
                try:
                    self.connect_bts_ssh(ip=tl.test_pc.default_ssh_connection_details.addr,
                                         username=tl.test_pc.default_ssh_connection_details.username,
                                         password=tl.test_pc.default_ssh_connection_details.password,
                                         connection=f'UTE_{index}')
                    break
                except Exception as e:
                    print(f"connect ute to download package: {e}")
                    times -= 1
                    if times >= 0:
                        time.sleep(20)
                    else:
                        raise Exception("connect ute failed")
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
            self.download_package(package_local_path=DOWNLOAD_PATH,
                                  package_name=f"{build}_release_BTSSM_downloadable_A54.zip",
                                  package_link=f"{DOWNLOAD_PACKAGE_LINK}/{build.split('_')[0]}/{build}/",
                                  connection=f'UTE_{index}')
        finally:
            self.disconnect_bts_ssh(connection=f'UTE_{index}')

    def download_package_threading(self):
        """
        download multi packages simultaneously via threading
        :return:
        """
        if 'True' in self.get_bts_info_from_json_file(file=f"{JSON_FILE_PATH}/upgrade_rollback.json")[2]:
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
        result = self.get_bts_info_from_json_file(file=f"{JSON_FILE_PATH}/upgrade_rollback.json")
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
                current_version = self.get_bts_version(connection=f'{bts_type}{index}_COAM')
                print(f"current activate version is {current_version['Active SW version']}")
                # start rollback
                self.rollback(connection=f"{bts_type}{index}_COAM")
                self.disconnections(index=index)
                # wait 120 second to activate new build
                time.sleep(120)
                self.connections(index=index, bts_type=bts_type)
                after_rollback_version = self.get_bts_version(connection=f'{bts_type}{index}_COAM')
                print(f"after upgrade: version is {after_rollback_version['Active SW version']}")
                assert after_rollback_version['Active SW version'] == current_version['Passive SW version']
                assert after_rollback_version['Passive SW version'] == current_version['Active SW version']
                self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                       connection_ssh=f'{bts_type}{index}_SSH',
                                                       bts_type=bts_type)
                time.sleep(120)
                activate_alarms = self.get_activate_alarms(connection=f'{bts_type}{index}_COAM')
                result_activate_alarms = self.check_alarms(alarm_list=activate_alarms)
                history_faults = bts_op.get_list_historic_alarms(connection=f'{bts_type}{index}_COAM',
                                                                 load_history=True)
                result_history_faults = bts_op.check_history_faults(history_fault_list=history_faults)
                assert result_activate_alarms is True and result_history_faults is True
            finally:
                self.disconnections(index=index)

    def bts_rollback_threading(self):
        """
        multi ue operate rollback simultaneously via threading
        :return:
        """
        threads = []
        result = self.get_bts_info_from_json_file(file=f"{JSON_FILE_PATH}/upgrade_rollback.json")
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
                current_version = self.get_bts_version(connection=f'{bts_type}{index}_COAM')
                print(f"current activate version is {current_version['Active SW version']}")
                # start reset
                self.reset(connection=f"{bts_type}{index}_COAM")
                self.disconnections(index=index)
                # wait 120 second to trigger reset
                time.sleep(120)
                self.connections(index=index, bts_type=bts_type)
                after_reset_version = self.get_bts_version(connection=f'{bts_type}{index}_COAM')
                print(f"after upgrade: version is {after_reset_version['Active SW version']}")
                assert after_reset_version['Active SW version'] == current_version['Active SW version']
                assert after_reset_version['Passive SW version'] == current_version['Passive SW version']
                self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                       connection_ssh=f'{bts_type}{index}_SSH',
                                                       bts_type=bts_type)
                time.sleep(120)
                activate_alarms = self.get_activate_alarms(connection=f'{bts_type}{index}_COAM')
                result_activate_alarms = self.check_alarms(alarm_list=activate_alarms)
                history_faults = bts_op.get_list_historic_alarms(connection=f'{bts_type}{index}_COAM',
                                                                 load_history=True)
                result_history_faults = bts_op.check_history_faults(history_fault_list=history_faults)
                assert result_activate_alarms is True and result_history_faults is True
            finally:
                self.disconnections(index=index)

    def bts_reset_threading(self):
        """
        multi bts operate reset simultaneously via threading
        :return:
        """
        threads = []
        result = self.get_bts_info_from_json_file(file=f"{JSON_FILE_PATH}/upgrade_rollback.json")
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
        result = self.get_bts_info_from_json_file(file=f"{JSON_FILE_PATH}/upgrade_rollback.json")
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
                                          connection=f'{bts_type}{index}_COAM')
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
                                                    timeout=timeout, connection=f'{bts_type}{index}_COAM')
            assert commission_result['commissioningResult']['activationResult']['resultNode']['parameters']['result'] \
                   == 'Success'
            assert commission_result['validationResult']['niddValidationResult']['status'] == 'OK'
            if is_pdl_checking_needed is True:
                assert commission_result['validationResult']['pdlValidationResult']['status'] == 'OK'
            print(f"{bts_type}{index}_COAM Commission with scf file via rest API successfully.")

            # wait 120 second to bts setup after import scf file
            # time.sleep(120)

            # self.connections(index=index, bts_type=bts_type)
            # self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
            #                                       connection_ssh=f'{bts_type}{index}_SSH',
            #                                       bts_type=bts_type)
            # print(f"{bts_type}{index} cells is ready")
        finally:
            self.disconnect_bts_coam(connection=f'{bts_type}{index}_COAM')

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

    def bts_save_snapshot(self, local_dir_path, snapshot_name, timeout=900, index=0, bts_type='gnb'):
        """
        Collect snapshots
        :param local_dir_path: Local directory path
        :param snapshot_name: Snapshot name
        :param timeout: Timeout for the operation
        :param index: bts_index
        :param bts_type: bts type, gnb or enb
        """
        if bts_type == 'gnb':
            bts_ip = tl.gnbs[index].cu.oam_ssh_connection_details.addr
        elif bts_type == 'enb':
            bts_ip = tl.enbs[index].airscale.common_units[0].lmp_connection.addr
        try:
            for i in range(6):
                try:
                    self.connect_bts_coam(ip=bts_ip,
                                          connection=f'{bts_type}{index}_COAM')
                except Exception as e:
                    print(f"connect NB: {e}")
                    time.sleep(20)
                    continue
                else:
                    break
        except Exception as e:
            print(e)
        else:
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
        finally:
            self.disconnect_bts_coam(connection=f'{bts_type}{index}_COAM')

    def bts_save_snapshot_threading(self, index_list, local_dir_path, snapshot_name, timeout=900,
                                    bts_type='gnb'):
        """
        Collect snapshots simultaneously using threads
        :param index_list: (list) bts index list <[0, 1, 2]>
        :param local_dir_path: Local directory path
        :param snapshot_name: Snapshot name
        :param timeout: Timeout for the operation
        :param bts_type: bts type, gnb or enb
        """
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.bts_save_snapshot, args=(local_dir_path, f"{snapshot_name}{bts_type}{j}",
                                                                       timeout, j, bts_type))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def block_unblock_all_cells(self, local_dir_path, snapshot_name, index=0, bts_type='gnb', timeout=60,
                                snapshot_timeout=900):
        try:
            self.connections(index=index)
            cell_list = self.coam.get_cell_list(timeout=timeout, connection=f'{bts_type}{index}_COAM')
            cell_list_info = cell_list['cells']
            for i, v in enumerate(cell_list_info.keys()):
                if len(list(cell_list_info.values())[i]) != 0:
                    print(f"operate {v} cell")
                    self.coam.block_all_cells(rat=v.upper(), timeout=timeout, connection=f'{bts_type}{index}_COAM',
                                              )
                    time.sleep(5)
                    self.coam.unblock_all_cells(rat=v.upper(), timeout=timeout, connection=f'{bts_type}{index}_COAM',
                                                )
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
            time.sleep(120)
            activate_alarms = self.get_activate_alarms(connection=f'{bts_type}{index}_COAM')
            result_activate_alarms = self.check_alarms(alarm_list=activate_alarms)
            history_faults = self.get_list_historic_alarms(connection=f'{bts_type}{index}_COAM',
                                                           load_history=True)
            result_history_faults = self.check_history_faults(history_fault_list=history_faults)
            assert result_activate_alarms is True and result_history_faults is True
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            cell_list = self.coam.get_cell_list(timeout=timeout, connection=f'{bts_type}{index}_COAM')
            cell_list_info = cell_list['cells']
            for i, v in enumerate(cell_list_info.keys()):
                if len(list(cell_list_info.values())[i]) != 0:
                    if list(cell_list_info.values())[i]['status']['blockingState'] != 'Unblocked':
                        self.coam.unblock_all_cells(rat=v.upper(), timeout=timeout,
                                                    connection=f'{bts_type}{index}_COAM',
                                                    )
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
            self.disconnections(index=index)

    def block_unblock_all_cells_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=60,
                                          snapshot_timeout=900):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.block_unblock_all_cells, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, bts_type, timeout, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def block_unblock_per_cell(self, local_dir_path, snapshot_name, index=0, timeout=60, bts_type='gnb',
                               snapshot_timeout=900):
        try:
            self.connections(index=index)
            cell_list = self.coam.get_cell_list(timeout=timeout, connection=f'{bts_type}{index}_COAM')
            cell_list_info = cell_list['cells']
            for i, v in enumerate(cell_list_info.keys()):
                if len(list(cell_list_info.values())[i]) != 0:
                    for j in range(len(cell_list_info[v])):
                        self.coam.block_cell(dist_name=cell_list_info[v][j]['id']['configuration'], timeout=timeout,
                                             connection=f'{bts_type}{index}_COAM')
                        time.sleep(5)
                        self.coam.unblock_cell(dist_name=cell_list_info[v][j]['id']['configuration'], timeout=timeout,
                                               connection=f'{bts_type}{index}_COAM')
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            cell_list = self.coam.get_cell_list(timeout=timeout, connection=f'{bts_type}{index}_COAM')
            cell_list_info = cell_list['cells']
            for i, v in enumerate(cell_list_info.keys()):
                if len(list(cell_list_info.values())[i]) != 0:
                    if cell_list_info.values()[i]['status']['blockingState'] != 'Unblocked':
                        self.coam.unblock_all_cells(rat=v.upper(), timeout=timeout,
                                                    connection=f'{bts_type}{index}_COAM')
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
            self.disconnections(index=index)

    def block_unblock_per_cell_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=60,
                                         snapshot_timeout=900):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.block_unblock_per_cell, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, bts_type, timeout, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def block_unblock_bts(self, local_dir_path, snapshot_name, index=0, bts_type='gnb', timeout=60,
                          snapshot_timeout=900):
        try:
            self.connections(index=index)
            self.coam.block(connection=f'{bts_type}{index}_COAM', timeout=timeout)
            time.sleep(5)
            self.coam.unblock(connection=f'{bts_type}{index}_COAM', timeout=timeout)
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            self.disconnections(index=index)

    def block_unblock_bts_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=60,
                                    snapshot_timeout=900):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.block_unblock_bts, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, bts_type, timeout, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def lock_unlock_per_cell(self, local_dir_path, snapshot_name, index=0, timeout=60, bts_type='gnb',
                             snapshot_timeout=900):
        try:
            self.connections(index=index)
            cell_list = self.coam.get_cell_list(timeout=timeout, connection=f'{bts_type}{index}_COAM')
            cell_list_info = cell_list['cells']
            for i, v in enumerate(cell_list_info.keys()):
                if len(list(cell_list_info.values())[i]) != 0:
                    for j in range(len(cell_list_info[v])):
                        self.coam.lock(dist_name=cell_list_info[v][j]['id']['configuration'], timeout=timeout,
                                       connection=f'{bts_type}{index}_COAM')
                        time.sleep(5)
                        self.coam.unlock(dist_name=cell_list_info[v][j]['id']['configuration'], timeout=timeout,
                                         connection=f'{bts_type}{index}_COAM')
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            self.disconnections(index=index)

    def lock_unlock_per_cell_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=60,
                                       snapshot_timeout=900):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.lock_unlock_per_cell, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def block_unblock_rat(self, local_dir_path, snapshot_name, rat='NR', index=0, timeout=60, bts_type='gnb',
                          snapshot_timeout=900):
        try:
            self.connections(index=index)
            self.coam.block_rat(rat=rat, connection=f'{bts_type}{index}_COAM', timeout=timeout)
            time.sleep(5)
            self.coam.unblock_rat(rat=rat, connection=f'{bts_type}{index}_COAM', timeout=timeout)
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            self.disconnections(index=index)

    def block_unblock_rat_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=60,
                                    snapshot_timeout=900, rat='NR'):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.block_unblock_rat, args=(
                local_dir_path, f"{snapshot_name}_{j}", rat, j, timeout, bts_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def lock_unlock_bbmod(self, local_dir_path, snapshot_name, index=0, timeout=60, bts_type='gnb',
                          snapshot_timeout=900):
        try:
            self.connections(index=index)
            bts_info = self.coam.get_bts_info(timeout=timeout, connection=f'{bts_type}{index}_COAM')
            for baseband in bts_info['basebandModules']:
                self.coam.lock(dist_name=baseband['id']['configuration'], timeout=timeout,
                               connection=f'{bts_type}{index}_COAM')
            time.sleep(5)
            for baseband in bts_info['basebandModules']:
                self.coam.unlock(dist_name=baseband['id']['configuration'], timeout=timeout,
                                 connection=f'{bts_type}{index}_COAM')
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            self.disconnections(index=index)

    def lock_unlock_bbmod_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=60,
                                    snapshot_timeout=900):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.lock_unlock_bbmod, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def lock_unlock_rmod(self, local_dir_path, snapshot_name, index=0, timeout=60, bts_type='gnb',
                         snapshot_timeout=900):
        try:
            self.connections(index=index)
            bts_info = self.coam.get_bts_info(timeout=timeout, connection=f'{bts_type}{index}_COAM')
            for rmod in bts_info['radioModules']['rmod']:
                self.coam.lock(dist_name=rmod['id']['configuration'], timeout=timeout,
                               connection=f'{bts_type}{index}_COAM')
            time.sleep(5)
            for rmod in bts_info['radioModules']['rmod']:
                self.coam.unlock(dist_name=rmod['id']['configuration'], timeout=timeout,
                                 connection=f'{bts_type}{index}_COAM')
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            self.disconnections(index=index)

    def lock_unlock_rmod_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=60,
                                   snapshot_timeout=900):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.lock_unlock_rmod, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def power_reset(self, local_dir_path, snapshot_name, index=0, timeout=1200, bts_type='gnb',
                    snapshot_timeout=900):
        try:
            self.connections(index=index)
            self.coam.power_reset(connection=f'{bts_type}{index}_COAM', timeout=timeout)
            time.sleep(120)
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            self.disconnections(index=index)

    def power_reset_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=1200,
                              snapshot_timeout=900):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.power_reset, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def site_reset(self, local_dir_path, snapshot_name, index=0, timeout=300, bts_type='gnb',
                   snapshot_timeout=900):
        try:
            self.connections(index=index)
            self.coam.reset(connection=f'{bts_type}{index}_COAM', timeout=timeout)
            time.sleep(120)
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            self.disconnections(index=index)

    def site_reset_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=300,
                             snapshot_timeout=900):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.site_reset, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def reset_site(self, local_dir_path, snapshot_name, index=0, timeout=300, bts_type='gnb',
                   snapshot_timeout=900):
        try:
            self.connections(index=index)
            self.coam.reset_site(connection=f'{bts_type}{index}_COAM', timeout=timeout)
            time.sleep(120)
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            self.disconnections(index=index)

    def reset_site_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=300,
                             snapshot_timeout=900):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.reset_site, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def reset_all_cells_with_bts(self, local_dir_path, snapshot_name, technology='NR', index=0, timeout=300,
                                 bts_type='gnb', snapshot_timeout=900):
        try:
            self.connections(index=index)
            self.coam.reset_all_cells(technology=technology, connection=f'{bts_type}{index}_COAM', timeout=timeout)
            time.sleep(120)
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            self.disconnections(index=index)

    def reset_all_cells_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=300,
                                  snapshot_timeout=900, technology='NR'):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.reset_all_cells_with_bts, args=(
                local_dir_path, f"{snapshot_name}_{j}", technology, j, timeout, bts_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def reset_per_cell(self, local_dir_path, snapshot_name, index=0, timeout=60, bts_type='gnb',
                       snapshot_timeout=900):
        try:
            self.connections(index=index)
            cell_list = self.coam.get_cell_list(timeout=timeout, connection=f'{bts_type}{index}_COAM')
            cell_list_info = cell_list['cells']
            for i, v in enumerate(cell_list_info.keys()):
                if len(list(cell_list_info.values())[i]) != 0:
                    for j in range(len(cell_list_info[v])):
                        self.coam.reset_cell(cell_id=cell_list_info[v][j]['id']['internal'], timeout=timeout,
                                             connection=f'{bts_type}{index}_COAM')
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            self.disconnections(index=index)

    def reset_per_cell_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=300,
                                 snapshot_timeout=900):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.reset_per_cell, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def rat_reset(self, local_dir_path, snapshot_name, rat_type='NR', index=0, timeout=300, reset_type='Soft',
                  bts_type='gnb', snapshot_timeout=900):
        try:
            self.connections(index=index)
            self.coam.rat_reset(rat_type=rat_type, reset_type=reset_type, connection=f'{bts_type}{index}_COAM',
                                timeout=timeout)
            time.sleep(120)
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            self.disconnections(index=index)

    def soft_rat_reset(self, local_dir_path, snapshot_name, rat_type='NR', index=0, timeout=300, reset_type='Soft',
                       bts_type='gnb', snapshot_timeout=900):
        self.rat_reset(local_dir_path=local_dir_path, snapshot_name=snapshot_name, rat_type=rat_type, index=index,
                       timeout=timeout, reset_type=reset_type, bts_type=bts_type, snapshot_timeout=snapshot_timeout)

    def soft_rat_reset_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=300,
                                 snapshot_timeout=900, rat_type='NR', reset_type='Soft'):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.soft_rat_reset, args=(
                local_dir_path, f"{snapshot_name}_{j}", rat_type, j, timeout, reset_type, bts_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def hard_rat_reset(self, local_dir_path, snapshot_name, rat_type='NR', index=0, timeout=300, reset_type='Hard',
                       bts_type='gnb', snapshot_timeout=900):
        self.rat_reset(local_dir_path=local_dir_path, snapshot_name=snapshot_name, rat_type=rat_type, index=index,
                       timeout=timeout, reset_type=reset_type, bts_type=bts_type, snapshot_timeout=snapshot_timeout)

    def hard_rat_reset_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=300,
                                 snapshot_timeout=900, rat_type='NR', reset_type='Hard'):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.hard_rat_reset, args=(
                local_dir_path, f"{snapshot_name}_{j}", rat_type, j, timeout, reset_type, bts_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def reset_bbmod(self, local_dir_path, snapshot_name, index=0, timeout=300, bts_type='gnb', reset_type='Warm',
                    snapshot_timeout=900, force_radio_reset=True):
        try:
            self.connections(index=index)
            bts_info = self.coam.get_bts_info(timeout=timeout, connection=f'{bts_type}{index}_COAM')
            for baseband in bts_info['basebandModules']:
                self.coam.reset_unit(dist_name=baseband['id']['runtime'], timeout=timeout, reset_type=reset_type,
                                     connection=f'{bts_type}{index}_COAM', force_radio_reset=force_radio_reset)
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            self.disconnections(index=index)

    def warm_reset_bbmod(self, local_dir_path, snapshot_name, index=0, timeout=300, bts_type='gnb', reset_type='Warm',
                         snapshot_timeout=900, force_radio_reset=False):
        self.reset_bbmod(local_dir_path=local_dir_path, snapshot_name=snapshot_name, index=index,
                         force_radio_reset=force_radio_reset, timeout=timeout, reset_type=reset_type, bts_type=bts_type,
                         snapshot_timeout=snapshot_timeout)

    def warm_reset_bbmod_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=300,
                                   snapshot_timeout=900, reset_type='Warm', force_radio_reset=False):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.warm_reset_bbmod, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, reset_type, snapshot_timeout,
                force_radio_reset))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def warm_reset_bbmod_with_force_radio_reset(self, local_dir_path, snapshot_name, index=0, timeout=300,
                                                bts_type='gnb', reset_type='Warm', snapshot_timeout=900,
                                                force_radio_reset=True):
        self.reset_bbmod(local_dir_path=local_dir_path, snapshot_name=snapshot_name, index=index,
                         force_radio_reset=force_radio_reset, timeout=timeout, reset_type=reset_type, bts_type=bts_type,
                         snapshot_timeout=snapshot_timeout)

    def warm_reset_bbmod_with_force_radio_reset_threading(self, index_list, local_dir_path, snapshot_name,
                                                          bts_type='gnb', timeout=300,
                                                          snapshot_timeout=900, reset_type='Warm',
                                                          force_radio_reset=True):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.warm_reset_bbmod_with_force_radio_reset, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, reset_type, snapshot_timeout,
                force_radio_reset))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def hard_reset_bbmod(self, local_dir_path, snapshot_name, index=0, timeout=300, bts_type='gnb', reset_type='Hard',
                         snapshot_timeout=900, force_radio_reset=False):
        self.reset_bbmod(local_dir_path=local_dir_path, snapshot_name=snapshot_name, index=index,
                         force_radio_reset=force_radio_reset, timeout=timeout, reset_type=reset_type, bts_type=bts_type,
                         snapshot_timeout=snapshot_timeout)

    def hard_reset_bbmod_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=300,
                                   snapshot_timeout=900, reset_type='Hard', force_radio_reset=False):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.hard_reset_bbmod, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, reset_type, snapshot_timeout,
                force_radio_reset))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def hard_reset_bbmod_with_force_radio_reset(self, local_dir_path, snapshot_name, index=0, timeout=300,
                                                bts_type='gnb', reset_type='Hard', snapshot_timeout=900,
                                                force_radio_reset=True):
        self.reset_bbmod(local_dir_path=local_dir_path, snapshot_name=snapshot_name, index=index,
                         force_radio_reset=force_radio_reset, timeout=timeout, reset_type=reset_type, bts_type=bts_type,
                         snapshot_timeout=snapshot_timeout)

    def hard_reset_bbmod_with_force_radio_reset_threading(self, index_list, local_dir_path, snapshot_name,
                                                          bts_type='gnb', timeout=300,
                                                          snapshot_timeout=900, reset_type='Hard',
                                                          force_radio_reset=True):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.hard_reset_bbmod_with_force_radio_reset, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, reset_type, snapshot_timeout,
                force_radio_reset))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def reset_rmod(self, local_dir_path, snapshot_name, index=0, timeout=300, bts_type='gnb', reset_type='Warm',
                   snapshot_timeout=900):
        try:
            self.connections(index=index)
            bts_info = self.coam.get_bts_info(timeout=timeout, connection=f'{bts_type}{index}_COAM')
            for rmod in bts_info['radioModules']['rmod']:
                self.coam.reset_unit(dist_name=rmod['id']['runtime'], timeout=timeout, reset_type=reset_type,
                                     connection=f'{bts_type}{index}_COAM')
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            self.disconnections(index=index)

    def soft_reset_rmod(self, local_dir_path, snapshot_name, index=0, timeout=300, bts_type='gnb', reset_type='Soft',
                        snapshot_timeout=900):
        self.reset_rmod(local_dir_path=local_dir_path, snapshot_name=snapshot_name, index=index,
                        timeout=timeout, reset_type=reset_type, bts_type=bts_type,
                        snapshot_timeout=snapshot_timeout)

    def soft_reset_rmod_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=300,
                                  snapshot_timeout=900, reset_type='Soft'):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.soft_reset_rmod, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, reset_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def hard_reset_rmod(self, local_dir_path, snapshot_name, index=0, timeout=300, bts_type='gnb', reset_type='Hard',
                        snapshot_timeout=900, force_radio_reset=True):
        self.reset_rmod(local_dir_path=local_dir_path, snapshot_name=snapshot_name, index=index,
                        timeout=timeout, reset_type=reset_type, bts_type=bts_type,
                        snapshot_timeout=snapshot_timeout)

    def hard_reset_rmod_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=300,
                                  snapshot_timeout=900, reset_type='Hard'):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.hard_reset_rmod, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, reset_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def warm_reset_rmod(self, local_dir_path, snapshot_name, index=0, timeout=300, bts_type='gnb', reset_type='Warm',
                        snapshot_timeout=900):
        self.reset_rmod(local_dir_path=local_dir_path, snapshot_name=snapshot_name, index=index,
                        timeout=timeout, reset_type=reset_type, bts_type=bts_type,
                        snapshot_timeout=snapshot_timeout)

    def warm_reset_rmod_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=300,
                                  snapshot_timeout=900, reset_type='Warm'):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.warm_reset_rmod, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, reset_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def reset_gnsse(self, local_dir_path, snapshot_name, index=0, timeout=300, bts_type='gnb', reset_type='Warm',
                    snapshot_timeout=900):
        try:
            self.connections(index=index)
            bts_info = self.coam.get_bts_info(timeout=timeout, connection=f'{bts_type}{index}_COAM')
            for gnsse in bts_info['gnsse']:
                self.coam.reset_unit(dist_name=gnsse['id']['runtime'], timeout=timeout, reset_type=reset_type,
                                     connection=f'{bts_type}{index}_COAM')
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            self.disconnections(index=index)

    def warm_reset_gnsse(self, local_dir_path, snapshot_name, index=0, timeout=300, bts_type='gnb', reset_type='Warm',
                         snapshot_timeout=900):
        self.reset_gnsse(local_dir_path=local_dir_path, snapshot_name=snapshot_name, index=index,
                         timeout=timeout, reset_type=reset_type, bts_type=bts_type,
                         snapshot_timeout=snapshot_timeout)

    def warm_reset_gnsse_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=300,
                                   snapshot_timeout=900, reset_type='Warm'):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.warm_reset_gnsse, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, reset_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def hard_reset_gnsse(self, local_dir_path, snapshot_name, index=0, timeout=300, bts_type='gnb', reset_type='Hard',
                         snapshot_timeout=900):
        self.reset_gnsse(local_dir_path=local_dir_path, snapshot_name=snapshot_name, index=index,
                         timeout=timeout, reset_type=reset_type, bts_type=bts_type,
                         snapshot_timeout=snapshot_timeout)

    def hard_reset_gnsse_threading(self, index_list, local_dir_path, snapshot_name, bts_type='gnb', timeout=300,
                                   snapshot_timeout=900, reset_type='Hard'):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.hard_reset_gnsse, args=(
                local_dir_path, f"{snapshot_name}_{j}", j, timeout, bts_type, reset_type, snapshot_timeout))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    def commissioning_reset(self, local_dir_path, snapshot_name, scf_file, skip_parameter_relation_errors=False,
                            timeout=600, index=0, bts_type='gnb', snapshot_timeout=900, is_pdl_checking_needed=True):
        try:
            self.connections(index=index)
            commissioning_status = self.coam.perform_commissioning(
                scf_file=scf_file,
                skip_parameter_relation_errors=skip_parameter_relation_errors,
                connection=f'{bts_type}{index}_COAM',
                timeout=timeout)
            assert commissioning_status['commissioningResult']['activationResult']['resultNode']['parameters'][
                       'result'] == 'Success'
            assert commissioning_status['validationResult']['niddValidationResult']['status'] == 'OK'
            if is_pdl_checking_needed is True:
                assert commissioning_status['validationResult']['pdlValidationResult']['status'] == 'OK'
            print(f"{bts_type}{index}_COAM Commission with scf file via rest API successfully.")
            time.sleep(120)
            self.wait_for_bts_ready_and_cell_setup(connection_coam=f'{bts_type}{index}_COAM',
                                                   connection_ssh=f'{bts_type}{index}_SSH',
                                                   bts_type=bts_type)
        except Exception as e:
            print(f"case failed with reason: {e}")
            self.collect_snapshot(local_dir_path=local_dir_path, snapshot_name=snapshot_name,
                                  timeout=snapshot_timeout, connection=f'{bts_type}{index}_COAM')
            print(f"{bts_type}{index}_COAM snapshot collect completely.")
            raise Exception("please check result!")
        finally:
            self.disconnections(index=index)

    def commissioning_reset_threading(self, index_list, local_dir_path, snapshot_name, scf_file, bts_type='gnb',
                                      skip_parameter_relation_errors=False, timeout=600,
                                      snapshot_timeout=900, is_pdl_checking_needed=True):
        threads = []
        for i, j in enumerate(index_list):
            th = threading.Thread(target=self.commissioning_reset, args=(
                local_dir_path, f"{snapshot_name}_{j}", scf_file[i], skip_parameter_relation_errors, timeout, j,
                bts_type, snapshot_timeout, is_pdl_checking_needed))
            threads.append(th)
        for t in threads:
            t.start()
        for t in threads:
            t.join()


bts_op = OperateGnb()


def multi_bts_upgrade():
    bts_op.bts_upgrade_threading()


def multi_bts_rollback():
    bts_op.bts_rollback_threading()


def multi_bts_reset():
    bts_op.bts_reset_threading()


def download_packages_to_ute():
    bts_op.download_package_threading()


def upgrade_rollback_reset():
    bts_op.upgrade_rollback_reset()


def multi_bts_commission(index_list,
                         scf_list,
                         skip_parameter_relation_errors=True,
                         timeout=600,
                         bts_type='gnb',
                         is_pdl_checking_needed=True):
    bts_op.bts_commission_threading(index_list=index_list,
                                    scf_list=scf_list,
                                    skip_parameter_relation_errors=skip_parameter_relation_errors,
                                    timeout=timeout,
                                    bts_type=bts_type,
                                    is_pdl_checking_needed=is_pdl_checking_needed)


def multi_bts_save_snapshot(index_list, local_dir_path=SNAPSHOT_LOCAL_DIR_PATH, snapshot_name='snapshot_', timeout=900,
                            bts_type='gnb'):
    bts_op.bts_save_snapshot_threading(index_list=index_list, local_dir_path=local_dir_path,
                                       snapshot_name=snapshot_name, timeout=timeout, bts_type=bts_type)
