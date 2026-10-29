import os
import os.path
import time
import taf.transport.ssh as ssh
import taf.gnb.oam.coam.admin as admin
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate


_allowed_alarms = ['LMP access via port',
                   'SSH enabled',
                   'R&D Service Port enabled',
                   'Temp Fault1',
                   'LMP access via port 443',
                   'LMP access via port 3600',
                   'BTS Reset Cause',
                   'Service account root access is enabled',
                   'Ethernet port security is disabled',
                   'Sanity Check Error']


def commissioning_classical_and_copy_swconfig_file(
        scf_file_name_req=None,
        test_cell_on_air_before=True,
        with_on_air_test=False,
        timeout_on_air_test=1200,
        timeout_commissioning=900,
        wait_after_commissioning=360,
        with_alarm_23=False,
        wait_for_alarm_23=600):

    sw_file_path, scf_file_path, enb_build, tl = get_commissioning_information(scf_file_name_req)
    admin_connection = gnb_connection_coam(tl)
    try:
        if not test_cell_on_air_before or not test_cells_on_air(admin_connection, 0):
            copy_sw_config(tl, sw_file_path)

            commissioning_gnb_classical(admin_connection, scf_file_path, timeout_commissioning)
            time.sleep(wait_after_commissioning)

            if with_alarm_23:
                if control_alarm_23(admin_connection, wait_for_alarm_23):
                    robot_log('CSaCC: Alarm 23 detected')
                    sw_reload(enb_build)
                    commissioning_gnb_classical(admin_connection, scf_file_path, timeout_commissioning)
                    time.sleep(wait_after_commissioning)

            if with_on_air_test:
                robot_log('CSaCC: test cell OnAir')
                if not test_cells_on_air(admin_connection, timeout_on_air_test, with_cell_info=True):
                    robot_log('CSaCC: Alarms: ' + str(admin_connection.get_active_alarms()))
                    raise Exception('CSaCC: Cells not on air')
        else:
            robot_log("CSaCC: Cell already on air, no commissioning")
        admin_connection.disconnect()

    except Exception as e:
        admin_connection.disconnect()
        raise e


def get_variables():
    enb_branch = BuiltIn().get_variable_value('${ENB_BRANCH}')
    enb_build = BuiltIn().get_variable_value('${ENB_BUILD}')
    configuration = BuiltIn().get_variable_value('${CONFIGURATION}')
    tl = BuiltIn().get_variable_value('${tl}')
    site_name = configuration.split('.')[0]
    tl_name = configuration.split('.')[1]
    branch = enb_branch.split('_')[0]

    current_dir = os.path.dirname(os.path.abspath(__file__))
    rep_path = current_dir.split('/testsuite/')[0]

    robot_log("CSaCC: ENB_BRANCH: " + branch + ", ENB_BUILD: " + enb_build + ", CONFIGURATION: " + configuration)
    return branch, enb_build, site_name, tl_name, rep_path, tl


def get_commissioning_information(scf_file_name_req=None):
    enb_branch, enb_build, site_name, tl_name, rep_path, tl = get_variables()
    robot_log("nb_branch: " + enb_branch + ", enb_build: " + enb_build + ", site_name: " + site_name
              + ", tl_name: " + tl_name + ", rep_path: " + rep_path)

    sw_path = get_swconfig_file_path(rep_path, site_name, tl_name, enb_branch)
    scf_name = get_scf_file_path(rep_path, site_name, tl_name, enb_branch, scf_file_name_req)

    robot_log("CSaCC: swconfig: " + sw_path + ", Scf file: " + scf_name)
    return sw_path, scf_name, enb_build, tl


def get_scf_file_path(rep_path, site_name, tl_name, branch_name, scf_file_name_req=None):

    p_comm = rep_path + "/commissionings/" + site_name + "/" + tl_name + "/" + branch_name + "/"
    path_file = get_scf_file_path_specific(p_comm, tl_name, branch_name, scf_file_name_req)

    if not path_file or not os.path.isfile(path_file):
        p_cust = rep_path + "/custom-config/" + site_name + "/" + tl_name + "/" + branch_name + "/"
        path_file = get_scf_file_path_specific(p_cust, tl_name, branch_name, scf_file_name_req)

    return path_file


def get_scf_file_path_specific(rep_path, tl_name, branch_name, scf_file_name_req=None):

    path_file = None
    if scf_file_name_req:
        if ".xml" in scf_file_name_req:
            path_file = rep_path + scf_file_name_req
        else:
            path_file = rep_path + scf_file_name_req + ".xml"

    if not (path_file and os.path.isfile(path_file)):
        path_file = rep_path + tl_name + "_" + branch_name + "_SCF.xml"
        if not os.path.isfile(path_file):
            path_file = rep_path + tl_name + "_" + branch_name + "_scf.xml"
            if not os.path.isfile(path_file):
                path_file = get_first_scf_file(rep_path)
                if path_file and not os.path.isfile(path_file):
                    path_file = None

    return path_file


def get_first_scf_file(path):
    path_file = None
    l_file = os.listdir(path)

    for pf in l_file:
        if pf[-8:] == "_SCF.xml" or pf[-8:] == "_scf.xml":
            path_file = path + "/" + pf

    if not path_file:
        for pf in l_file:
            if pf[:8] == "_scf.xml":
                path_file = path + "/" + pf

    return path_file


def get_swconfig_file_path(rep_path, site_name, tl_name, branch_name):

    path_file = rep_path + "/commissionings/" + site_name + "/" + tl_name + "/" + branch_name + "/swconfig.txt"
    if not (path_file and os.path.isfile(path_file)):
        path_file = rep_path + "/custom-config/" + site_name + "/" + tl_name + "/" + branch_name + "/swconfig.txt"
        if not (path_file and os.path.isfile(path_file)):
            path_file = None

    return path_file


def copy_sw_config(tl, sw_path):
    if not sw_path:
        raise Exception("swconfig.txt file not found")

    lmp = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection
    user = lmp.username
    pwd = lmp.password
    tempo = time.time()
    my_connection = ssh.connect(hostname="192.168.255.129", username=user, password=pwd)
    while (not my_connection) and ((time.time() - tempo) < 600):
        time.sleep(30)
        my_connection = ssh.connect(hostname="192.168.255.129", username=user, password=pwd)
        if not my_connection:
            my_connection = ssh.connect(hostname="192.168.255.1", username=user, password=pwd)

    if not my_connection:
        raise Exception("No ssh connection (192.168.255.129 or 192.168.255.1)")
    else:
        try:
            fp = my_connection.files
            fp.put(sw_path, "/ffs/run/swconfig.txt")

        except Exception as e:
            if my_connection:
                my_connection.disconnect()
            raise e
        my_connection.disconnect()


def commissioning_gnb_classical(admin_connection, scf_path, commissioning_timeout=900):
    if not scf_path:
        raise Exception("Scf file not found")

    robot_log('CSaCC: gNb commissioning with ' + scf_path)
    admin_connection.perform_commissioning(scf_file=scf_path, skip_parameter_relation_errors=False,
                                           should_activate=True, timeout=commissioning_timeout)
    robot_log('CSaCC: gNb commissioning: End')


def gnb_connection_coam(tl):
    user = tl.gnbs[0].cu.oam_http_connection_details.username
    pwd = tl.gnbs[0].cu.oam_http_connection_details.password
    tempo = time.time()
    admin_connection = admin.interface.AdminConnection(bts_host="192.168.255.129", username=user, password=pwd)
    while (not admin_connection) and ((time.time() - tempo) < 600):
        time.sleep(30)
        admin_connection = admin.interface.AdminConnection(bts_host="192.168.255.129", username=user, password=pwd)
        if not admin_connection:
            admin_connection = admin.interface.AdminConnection(bts_host="192.168.255.1", username=user, password=pwd)

    if not admin_connection:
        raise Exception("No ssh connection (192.168.255.129 or 192.168.255.1)")

    return admin_connection


def control_alarm_23(admin_connection, wait_for_alarm_23=600):
    robot_log('CSaCC: wait for the alarm 23 to disappear (' + str(wait_for_alarm_23) + 's)')
    tempo = time.time()
    alarm_23_detected = True
    while alarm_23_detected and ((time.time() - tempo) < wait_for_alarm_23):
        time.sleep(30)
        active_alarms_list = admin_connection.get_active_alarms()
        alarm_23 = [d for d in active_alarms_list if (d['faultId'] == 23)]
        alarm_23_detected = bool(alarm_23)

    if alarm_23_detected:
        robot_log('CSaCC: Alarm 23 is detected')
    else:
        robot_log('CSaCC: no Alarm 23')

    return alarm_23_detected


def sw_reload(enb_build):
    robot_log('CSaCC: Update sw version: ' + enb_build)

    sw_package_path = GnbSwUpdate().download_sw_package(enb_build, "/tmp")
    GnbSwUpdate().update_software(sw_package_dir=sw_package_path, timeout=900)

    robot_log('CSaCC: Update sw version: End')


def test_cells_on_air(admin_connection, timeout_on_air_test=1200, with_cell_info=False):

    robot_log('CSaCC: Test Cells OnAir')

    list_cells = admin_connection.get_cells_info()
    if list_cells:
        tempo = time.time()
        cells_on_air = True
        for cell in list_cells:
            cells_on_air = cells_on_air and (cell['status']['availabilityStatus'] == 'Online')
        if not cells_on_air and (timeout_on_air_test > 0):
            robot_log('CSaCC: wait cells on air (' + str(timeout_on_air_test) + 's)')
            while ((time.time() - tempo) < timeout_on_air_test) and not cells_on_air:
                time.sleep(30)
                cells_on_air = True
                for cell in admin_connection.get_cells_info():
                    cells_on_air = cells_on_air and (cell['status']['availabilityStatus'] == 'Online')
        if cells_on_air:
            robot_log('CSaCC: Cells on air')
        else:
            robot_log('CSaCC: Cells not on air')
            if with_cell_info:
                for cell in admin_connection.get_cells_info():
                    robot_log('CSaCC: cellId ' + str(cell['globalCellId']) + ',\n nrarfcn ' + str(cell['nrarfcn']) +
                              ',\n status ' + cell['status']['availabilityStatus'] + ',\n info ' + str(cell))
    else:
        cells_on_air = False
        robot_log('CSaCC: no cells in list')

    return cells_on_air


def robot_log(msg):
    BuiltIn().log(msg, level='INFO', html=True, console=True)
