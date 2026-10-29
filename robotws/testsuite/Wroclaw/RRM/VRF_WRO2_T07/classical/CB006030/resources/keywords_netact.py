from taf.ul.oam.netact.swm.interface import swm, logger
from taf.ul.oam.netact.swm.swhandler import SwHandler
import taf.transport.ssh as transport
from testsuite.Wroclaw.RRM.resources.webUI_operations import BuiltIn
import time


netact = swm()
ssh = transport.ssh()
swhander = SwHandler()

ip = BuiltIn().get_variable_value("${tl.nms.addr}")
bts_id = BuiltIn().get_variable_value("${tl.gnbs[0].instance_id}")
username_user = BuiltIn().get_variable_value("${tl.nms.nom.https_user_mgmt_info.username}")
username_root = BuiltIn().get_variable_value("${tl.nms.nom.ssh_connections_info.username}")
password_user = BuiltIn().get_variable_value("${tl.nms.nom.https_user_mgmt_info.password}")
password_root = BuiltIn().get_variable_value("${tl.nms.nom.ssh_connections_info.password}")


def upload_sw_to_netact_tmp(sw_version, download_dir, hostname_ip=ip, username=username_root,
                            password=password_root):
    path_to_file = str(download_dir) + 'AirScale-' + str(sw_version) + '.zip'
    ssh.connect_to(hostname=hostname_ip, username=username, password=password)
    ssh.upload_file(local_path=path_to_file,
                    remote_path='/d/oss/global/swmanager/swm_temp/AirScale-{}.zip'.format(sw_version))
    logger.info("Software has been uploaded to temp")
    ssh.disconnect()


def transfer_software_to_archive(sw_version, hostname_ip=ip, username=username_user, password=password_user):
    sw_file = "AirScale-{}.zip".format(sw_version)
    mo = "MRBTS"
    ssh.connect_to(hostname=hostname_ip, username=username, password=password)
    transfer_command = "swmCLI.sh import -f '{}' -m '{}'".format(sw_file, mo)
    ssh.execute(transfer_command)
    ssh.disconnect()
    logger.info("Software has been moved to archive")


def netact_activate_software(sw_version, mrbts_id, hostname_ip=ip, username=username_user, password=password_user):
    netact.connect(hostname=hostname_ip, username=username, password=password)
    sw_file = "AirScale-{}".format(sw_version)
    mo_id = "MRBTS-{}".format(mrbts_id)
    operation_id = netact.activate(mo_id=mo_id, sw_version=sw_file)
    while not netact.is_operation_done(operation_id[-5:-1]):
        time.sleep(30)
        logger.info("Activation in progress...")
    if netact.get_last_sw_operation_info(mo_id) == "Operation failed":
        raise AssertionError("Software activation failed")
    else:
        logger.info("Software has been activated")
    netact.disconnect()


def netact_provision_software(sw_version, mrbts_id, hostname_ip=ip, username=username_user, password=password_user):
    netact.connect(hostname=hostname_ip, username=username, password=password)
    sw_file = "AirScale-{}".format(sw_version)
    mo_id = "MRBTS-{}".format(mrbts_id)
    operation_id = netact.provision(mo_id=mo_id, sw_version=sw_file)
    BuiltIn().log("ID: " + operation_id)
    if operation_id[:-2] == "Error SWMT0160: Missing expected software archive in db.":
        logger.warn("Software {} in not in the software archive directory".format(sw_version))
        raise AssertionError("No software to provision")
    elif operation_id[:27] == "Error with status code: 404":
        operation_id = netact.provision(mo_id=mo_id, sw_version=sw_file)
        if operation_id[:27] == "Error with status code: 404":
            raise AssertionError("Command error - 404")
    operation_id = operation_id.split("_")[-1][:-2]
    BuiltIn().log("TEST ID: " + operation_id)
    while not netact.is_operation_done(operation_id):
        time.sleep(30)
        logger.info("Operation done in while: " + str(netact.is_operation_done(operation_id)))
        logger.info("Provision in progress...")
    if netact.get_last_sw_operation_info(mo_id) == "Operation failed":
        raise AssertionError("Software provision failed")
    else:
        logger.info("Software has been provisioned")
    netact.disconnect()


def sw_file_existing_check(sw_version, hostname_ip=ip, username=username_user, password=password_user):
    netact.connect(hostname=hostname_ip, username=username, password=password)
    result = netact.sw_file_exists(sw_version)
    netact.disconnect()
    return result


def netact_sw_upload(sw_version, download_dir):
    upload_sw_to_netact_tmp(sw_version, download_dir)
    transfer_software_to_archive(sw_version)
    logger.info("Software ready to use!")


def delete_software_from_netact_sw_archive(sw_version, hostname_ip=ip, username=username_root, password=password_root):
    ssh.connect_to(hostname=hostname_ip, username=username, password=password)
    delete_command = "rm -rf /var/opt/nokia/oss/global/swm/swm_arch/AirScale-{}".format(sw_version)
    ssh.execute(delete_command)
    ssh.disconnect()
    logger.info("Software {} has been deleted from archive".format(sw_version))


def netact_clean(sw_version, hostname_ip=ip, username=username_user, password=password_user):
    netact.connect(hostname=hostname_ip, username=username, password=password)
    if netact.sw_file_exists("AirScale-{}".format(sw_version)):
        delete_software_from_netact_sw_archive(sw_version)
    else:
        logger.info("There is no software: {} in NetAct Archive".format(sw_version))
    logger.info("NetAct clean done.")
    netact.disconnect()
