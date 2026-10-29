import os.path

from .facade import *
import threading
import requests


def sw_upgrade(loadname, comm_subtype=None, oam_ip="192.168.255.1",
               username="toor4nsn", password="oZPS0POrRieRtu", ssh_port=22, https_port=443, timeout=600):
    # *******************************Get local testline info*************************** #
    try:
        local_testline, local_tl_info = get_master_tl_info()
    except Exception as e:
        logger.error("local testline info:".format(str(e)))
        return
    # print(f"{local_testline}, {local_tl_info}")
    # *******************************Get remote testline info**************************** #
    remote_upgrade_flag = False
    try:
        remote_tl_info, bts_kvm_ip, bts_kvm_user, bts_kvm_password = get_slave_tl_info(local_tl_info)
        remote_upgrade_flag = True
    except Exception as e:
        logger.error("remote testline info:".format(str(e)))

    # print(f"{remote_tl_info}, {bts_kvm_ip}, {bts_kvm_user}, {bts_kvm_password}")
    # ******************************Get upgrade method********************************** #
    local_upgrade_method_name = upgrade_method_selection(local_tl_info, loadname)
    if remote_upgrade_flag:
        remote_upgrade_method_name = upgrade_method_selection(remote_tl_info, loadname)
        logger.info("Due to remote bts is upgraded with anther thread in python, the log wont appear in xml log")
        logger.info("remote upgrade method = {}".format(remote_upgrade_method_name))
    logger.info("local upgrade method = {}".format(local_upgrade_method_name))
    # ********************************************************************************* #
    upgrade_local = getattr(SysUpgradeType, local_upgrade_method_name.lower(), None)
    upgrade_local_obj = upgrade_local()
    # ********************************************************************************* #
    """
    If active load upgrade methed = dualcore, current load upgrade methed = dualcore then remote only need yaft,
    If active load upgrade methed = dualcore, current load upgrade methed = others, then remote need upgrade
    if active load upgrade methed = dualcore, config reset is need
    """
    active_load_upgrade_methed = get_active_load_upgrade_method(local_tl_info)
    logger.info("active_load_upgrade_methed = {}".format(active_load_upgrade_methed))
    if "dualcore" in active_load_upgrade_methed or not active_load_upgrade_methed:
        logger.info('=' * 10 + 'Start: Reset Configuraion before yaft, since this is dualcore testline' + '=' * 10,
                    also_console=True)
        reset_sbts_configuration(oam_ip=oam_ip, timeout=timeout)
        logger.info('=' * 10 + 'End: Reset Configuraion before yaft, since this is dualcore testline' + '=' * 10,
                    also_console=True)
        # ********************************************************************************* #
        logger.info('=' * 10 + 'Start: Check sysmod status after reset configuraion' + '=' * 10,
                    also_console=True)
        upgrade_local_obj._check_sysmod_status(oam_ip=oam_ip, https_port=https_port, remote_ssh_ip=None,
                                               remote_ssh_user=None, remote_ssh_passwd=None,
                                               remote_ssh_port=None, remote_oper_flag=None, timeout=timeout,
                                               connection="for_dualcore")
        logger.info('=' * 10 + 'Start: Check sysmod status after reset configuraion' + '=' * 10,
                    also_console=True)

    # ********************************************************************************* #
    if remote_upgrade_flag:
        upgrade_remote = getattr(SysUpgradeType, remote_upgrade_method_name.lower(), None)
        upgrade_remote_obj = upgrade_remote()

    # ********************************************************************************* #
    loadpkg = loadpkg_download(loadname)
    # ********************************************************************************* #
    if remote_upgrade_flag:
        logger.info('=' * 10 + 'Start<remote_connection>: Yaft' + '=' * 10, also_console=True)
        upgrade_remote_obj._yaft(loadpkg=loadpkg, oam_ip=oam_ip, port=ssh_port,
                                 remote_ssh_ip=bts_kvm_ip, remote_ssh_user=bts_kvm_user,
                                 remote_ssh_passwd=bts_kvm_password, remote_ssh_port=22,
                                 remote_oper_flag=True, timeout=timeout)
        logger.info('=' * 10 + 'End<remote_connection>: Yaft' + '=' * 10, also_console=True)

    if "dualcore" in local_upgrade_method_name.lower():
        remote_upgrade_flag = False
    # ********************************************************************************* #
    # logger.info('=' * 10 + 'Start<local_connection>: Yaft' + '=' * 10, also_console=True)
    # upgrade_local_obj._yaft(loadpkg=loadpkg, oam_ip=oam_ip, port=ssh_port, timeout=timeout)
    # logger.info('=' * 10 + 'End<local_connection>: Yaft' + '=' * 10, also_console=True)
    # ********************************************************************************* #

    if remote_upgrade_flag:
        remote_dict = {"loadname": loadname,
                       "loadpkg": loadpkg,
                       "testline": remote_tl_info.name,
                       "comm_subtype": comm_subtype,
                       "oam_ip": oam_ip,
                       "username": username,
                       "password": password,
                       "ssh_port": ssh_port,
                       "https_port": https_port,
                       "remote_vm_ip": bts_kvm_ip,
                       "remote_vm_user": bts_kvm_user,
                       "remote_vm_passwd": bts_kvm_password,
                       "remote_vm_port": 22,
                       "timeout": timeout,
                       "remote_oper_flag": True,
                       "connection": "remote_connection"}

        remote_t = threading.Thread(target=upgrade_remote_obj.upgrade, kwargs=remote_dict)
        remote_t.start()

    upgrade_local_obj.upgrade(loadname=loadname, loadpkg=loadpkg,
                              comm_subtype=comm_subtype, testline=local_tl_info.name, oam_ip=oam_ip,
                              username=username,
                              password=password, ssh_port=ssh_port, https_port=https_port,
                              remote_oper_flag=False, timeout=timeout, connection="local_connection")

    if remote_upgrade_flag:
        remote_t.join(timeout=timeout * 9)
    # ********************************************************************************* #
    try:
        loadpkg_delete(loadname)
    except Exception as e:
        logger.error(str(e))
    # ********************************************************************************* #


def change_siso(loadname, comm_subtype=None, oam_ip="192.168.255.129",
                username="toor4nsn", password="oZPS0POrRieRtu", ssh_port=22, https_port=443, timeout=600):
    # *******************************Start: Get local testline info*************************** #

    try:
        local_testline, local_tl_info = get_master_tl_info()
    except Exception as e:
        logger.error(str(e))
        return
    # *******************************End: Get local testline info*************************** #
    local_change_siso = AsirChangeSiso()
    local_change_siso.change_siso(loadname=loadname, comm_subtype=comm_subtype, testline=local_tl_info.name,
                                  oam_ip=oam_ip, username=username, password=password,
                                  ssh_port=ssh_port, https_port=https_port, remote_oper_flag=False,
                                  timeout=timeout, connection="local_change_siso")
    try:
        loadpkg_delete(loadname)
    except Exception as e:
        logger.error(str(e))


def save_bts_scf(local_dir_path, connection=None, export_type=None, parameters_save_variant=None,
                 sub_file_name=None, timeout=800):
    dict_ips = get_all_ips_from_init()

    for bts, ips in dict_ips.items():
        file_name = "{}____{}.xml".format(sub_file_name, bts)
        try:
            download_sbts_commissioning(oam_ip=ips["bts_oam_ip"], local_dir_path=local_dir_path, connection=connection,
                                        export_type=export_type,
                                        parameters_save_variant=parameters_save_variant,
                                        file_name=file_name, timeout=timeout)
        except Exception as e:
            logger.error("Backup {} commission failed with error: {}".format(bts, str(e)))


# def backup_asir_scf(loadname, local_path, sub_file_name):
#     dict_ips = get_all_ips_from_init()
#
#     for bts, ips in dict_ips.items():
#         file_name = "{}____{}_asirmgr.xml".format(sub_file_name, bts)
#         try:
#             download_install_asicli(loadname=loadname, remote_ssh_ip=ips["bts_kvm_ip"],
#                                     remote_ssh_user=ips["bts_kvm_user"], remote_ssh_passwd=ips["bts_kvm_password"])
#             save_asir_scf(file_name=file_name, local_path=local_path, remote_ssh_ip=ips["bts_kvm_ip"],
#                           remote_ssh_user=ips["bts_kvm_user"], remote_ssh_passwd=ips["bts_kvm_password"])
#         except Exception as e:
#             logger.error("Backup {} asir commission failed with error {}".format(bts, str(e)))

def save_asir_scf(local_path, sub_file_name):
    dict_ips = get_all_ips_from_init()
    for bts, ips in dict_ips.items():
        file_name = "{}____{}_asirmgr.xml".format(sub_file_name, bts)
        try:
            os.system("cd /opt/asir/ && bash -C collectfiles.sh -ne {} -pw Nemuadmin:nemuuser -outdir {} -comm".
                      format(ips["bts_oam_ip"], local_path))
            os.system("mv {}/{}_scf.xml {}/{}".format(local_path, ips["bts_oam_ip"], local_path, file_name))
        except Exception as e:
            logger.error("Backup {} asir commission failed with error: {}".format(bts, str(e)))


def save_snapshot(target_log_dir, sub_file_name, coverage="Full", force=True, regexp_filter=None, reason=None,
                  cells=None, timeout=900, detailed_output=False, connection=None):
    dict_ips = get_all_ips_from_init()
    for bts, ips in dict_ips.items():
        try:
            filename = "snapshot_{}_{}_{}.zip".format(sub_file_name, bts, ips["bts_oam_ip"])
            collect_sbts_snapshot(target_file_name=os.path.join(target_log_dir, filename), coverage=coverage,
                                  force=force, regexp_filter=regexp_filter, reason=reason, cells=cells,
                                  timeout=timeout, detailed_output=detailed_output, oam_ip=ips["bts_oam_ip"],
                                  connection=connection)
        except Exception as e:
            logger.error("Collect snapshot for {} failed with error: {}".format(bts, str(e)))


def send_msg_to_dataspark(ute_ip, sw_build, scf_path):
    url = "https://eztoolset.int.nokia-sbell.com/dev-api/dev_test/scf_trans"
    payload = {'os_info': get_os_info(), 'ip': ute_ip, 'load': sw_build, 'path': scf_path}
    logger.info("Post msg to dataspark: {}".format(payload))
    try:
        r = requests.post(url, json=payload, verify=False)
    except Exception as e:
        logger.error("Post msg to dataspack failed with error: {}".format(str(e)))


if __name__ == "__main__":
    print("*" * 10 + "start testing" + "*" * 10)
    # sw_upgrade(loadname="SBTS00_ENB_9999_221024_000005", testline="7_21_UTE5G034TL087")
    sw_upgrade(loadname="SBTS00_ENB_9999_221026_000012", testline="7_21_UTE5G040TL109", comm_subtype="4spec")
