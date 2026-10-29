import os
import os.path
import time
import taf.config.testline
import taf.transport.ssh as ssh
import taf.sbts.oam.coam.admin as admin
from robot.libraries.BuiltIn import BuiltIn
import operator


on_debug = True


def robot_log(msg):
    BuiltIn().log('(' + time.strftime('%H:%M:%S') + ') ' + msg, level='INFO', html=True, console=True)


def robot_warning(msg):
    BuiltIn().log('(' + time.strftime('%H:%M:%S') + ') ' + msg, level='WARN', html=True, console=True)


def robot_error(msg):
    BuiltIn().log('(' + time.strftime('%H:%M:%S') + ') ' + msg, level='ERROR', html=True, console=True)


def gnb_connection_coam(user=None, pwd=None):
    tl = BuiltIn().get_variable_value('${tl}')
    if not user:
        user = tl.gnbs[0].cu.oam_http_connection_details.username
    if not pwd:
        pwd = tl.gnbs[0].cu.oam_http_connection_details.password
    tempo = time.time()
    my_admin = admin.interface.admin()
    admin_connection = my_admin.connect_to(bts_host="192.168.255.129", username=user, password=pwd)
    while (not admin_connection) and ((time.time() - tempo) < 600):
        time.sleep(30)
        admin_connection = my_admin.connect_to(bts_host="192.168.255.129", username=user, password=pwd)
        if not admin_connection:
            admin_connection = my_admin.connect_to(bts_host="192.168.255.1", username=user, password=pwd)
    if not admin_connection:
        raise Exception("No OaM connection (192.168.255.129 or 192.168.255.1)")
    return admin_connection, my_admin


def enb_connection_coam(enb_oam_ip, user=None, pwd=None):
    # tl = BuiltIn().get_variable_value('${tl}')
    # if not user:
    #     user = tl.enbs[0].cu.oam_http_connection_details.username
    # if not pwd:
    #     pwd = tl.enbs[0].cu.oam_http_connection_details.password
    tempo = time.time()
    my_admin = admin.interface.admin()
    admin_connection = my_admin.connect_to(bts_host=enb_oam_ip, username=user, password=pwd)
    while (not admin_connection) and ((time.time() - tempo) < 600):
        time.sleep(30)
        admin_connection = my_admin.connect_to(bts_host=enb_oam_ip, username=user, password=pwd)
    if not admin_connection:
        raise Exception("No OaM connection (" + enb_oam_ip + ")")
    return admin_connection, my_admin


def connection_coam(oam_ip=None, user=None, pwd=None):
    if oam_ip:
        return enb_connection_coam(oam_ip, "Nemuadmin", "nemuuser")
    else:
        return gnb_connection_coam(user, pwd)


def cell_is_on_air(cell):
    # robot_log('cell_is_on_air: cell[status] ' + str(cell['status']))
    # avail_status = cell['status']['availabilityStatus']
    op_status = cell['status']['operationalState']
    admin_status = cell['status']['administrativeState']
    # on_air = not avail_status or (avail_status == 'Online') or (avail_status == '')
    on_air = (op_status == 'enabled') or (op_status == 'Enabled') and (admin_status == 'Unlocked')

    return on_air


def get_cells_on_air_list(oam_ip=None):
    admin_connection, my_admin = connection_coam(oam_ip)
    try:
        bts_info = admin_connection.get_bts_info()
        admin_connection.disconnect()
        if oam_ip:
            list_cells = bts_info['cells']['lte']
        else:
            list_cells = bts_info['cells']['nr']

        if list_cells:
            l_cells_on_air = []
            for cell in list_cells:
                if cell_is_on_air(cell):
                    l_cells_on_air.append(cell['globalCellId'])
            if not l_cells_on_air:
                robot_error("get_cells_on_air_list: No cell OnAir")
                BuiltIn().fail()
            return l_cells_on_air
        else:
            robot_error("get_cells_on_air_list: No cell")
            BuiltIn().fail()
            return None
    except Exception as e:
        admin_connection.disconnect()
        raise e


def get_on_air_list(ti, oam_ip=None):
    admin_connection, my_admin = connection_coam(oam_ip)
    try:
        bts_info = admin_connection.get_bts_info()
        if oam_ip:
            list_cells = bts_info['cells']['lte']
        else:
            list_cells = bts_info['cells']['nr']
        admin_connection.disconnect()
        if list_cells:
            l_cells_on_air = []
            for cell in list_cells:
                if cell_is_on_air(cell):
                    l_cells_on_air.append(cell['globalCellId'])
            if l_cells_on_air:
                l_cells_on_air.sort()
                tc = '-'.join(str(i) for i in l_cells_on_air)
                return (ti == tc) or tc.find(ti), l_cells_on_air
            else:
                return False, None
    except Exception as e:
        admin_connection.disconnect()
        raise e


def test_initial_cells_on_air_list(initial_cells, oam_ip=None):

    if initial_cells:
        initial_cells.sort()
        ti = '-'.join(str(i) for i in initial_cells)
        admin_connection, my_admin = connection_coam(oam_ip)
        if admin_connection:
            try:
                # list_cells = admin_connection.get_cells_info()
                bts_info = admin_connection.get_bts_info()
                if oam_ip:
                    list_cells = bts_info['cells']['lte']
                else:
                    list_cells = bts_info['cells']['nr']
                admin_connection.disconnect()
                if list_cells:
                    l_cells_on_air = []
                    for cell in list_cells:
                        if cell_is_on_air(cell):
                            l_cells_on_air.append(cell['globalCellId'])
                    if l_cells_on_air:
                        l_cells_on_air.sort()
                        tc = '-'.join(str(i) for i in l_cells_on_air)
                        if (ti == tc) or tc.find(ti):
                            return l_cells_on_air
                        else:
                            BuiltIn().fail()
                            return l_cells_on_air
                    else:
                        robot_log('Test Initial Cells OnAir: no cells onAir')
                        BuiltIn().fail()
                        return None
                else:
                    robot_log('Test Initial Cells OnAir: no cells')
                    BuiltIn().fail()
                    return None

            except Exception as e:
                admin_connection.disconnect()
                raise e
        else:
            robot_log('Test Initial Cells OnAir: no connection')
            return None
    else:
        return None


def software_rollback(oam_ip=None):
    admin_connection, my_admin = connection_coam(oam_ip)
    try:
        result = my_admin.rollback_software(timeout=1200)
        admin_connection.disconnect()
        if not result:
            robot_error("Software rollback failed: " + str(result))
            BuiltIn().fail()

    except Exception as e:
        admin_connection.disconnect()
        raise e


def get_short_software_name(sw_name):
    sw_name_list = sw_name.split('_')
    return "_".join(sw_name_list[2:])
    # return "_".join(sw_name_list[1:])


def is_same_software_version(sw_1, sw_2):
    sw_1_list = sw_1.split('_')
    sw_2_list = sw_2.split('_')
    if sw_1_list[0] == "SBTS00" or sw_2_list[0] == "SBTS00":
        return get_short_software_name(sw_1) == get_short_software_name(sw_2)
    else:
        return sw_1 == sw_2


def is_new_software_release(versions):
    va = versions['Active'].split('_')
    vp = versions['Passive'].split('_')
    return va[0] != vp[0]


def get_software_version(oam_ip=None):
    admin_connection, my_admin = connection_coam(oam_ip)
    try:
        sw_info = admin_connection.get_software_info(timeout=1200)
        # robot_log('Info: ' + str(admin_connection.get_bts_info()))
        admin_connection.disconnect()
        return {'Active': sw_info['Active SW version'], 'Passive': sw_info['Passive SW version']}

    except Exception as e:
        admin_connection.disconnect()
        raise e


def scf_backup(scf_path, scf_name, oam_ip=None):
    admin_connection, my_admin = connection_coam(oam_ip)
    try:
        my_admin.get_current_scf_file(local_dir_path=scf_path, file_name=scf_name, timeout=300)
        admin_connection.disconnect()

    except Exception as e:
        admin_connection.disconnect()
        raise e


def nb_update_software(sw_path, oam_ip=None):
    admin_connection, my_admin = connection_coam(oam_ip)
    try:
        result = admin_connection.update_software(sw_package=sw_path, should_activate=True, timeout=2400)
        admin_connection.disconnect()
        if oam_ip:
            robot_log("4G eNB Update Software: " + str(result))
        else:
            robot_log("5G gNB Update Software: " + str(result))

    except Exception as e:
        admin_connection.disconnect()
        raise e


def nb_reset(oam_ip=None):
    admin_connection, my_admin = connection_coam(oam_ip)
    try:
        result = admin_connection.reset(reset_coverage='Site', wait_for_reconnection=False, timeout=300)
        admin_connection.disconnect()
        if oam_ip:
            robot_log("4G eNB Reset: " + str(result))
        else:
            robot_log("5G gNB Reset: " + str(result))

    except Exception as e:
        admin_connection.disconnect()
        raise e


def get_unexpected_alarm(alowed_alarm, oam_ip=None):
    aal = ':' + ':'.join(str(i) for i in alowed_alarm) + ':'
    admin_connection, my_admin = connection_coam(oam_ip)
    try:
        unexpected_alarm_list = []
        alarm_list = admin_connection.get_active_alarms()
        admin_connection.disconnect()
        if alarm_list:
            for a in alarm_list:
                if not aal.find(':' + str(a['faultId']) + ':')\
                        and (a['severity'] != 'Minor') and (a['severity'] != 'Warning'):
                    unexpected_alarm_list.append({'faultId': a['faultId'], 'severity': a['severity'],
                                                  'faultName': a['faultName'], 'alarmDetail': a['alarmDetail']})
        return unexpected_alarm_list

    except Exception as e:
        admin_connection.disconnect()
        raise e


def copy_sw_config(sw_path, user, pwd):
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
            if sw_path[-1] == '/':
                output_path = sw_path + "swconfig.txt"
            else:
                output_path = sw_path + "/swconfig.txt"
            fp = my_connection.files
            fp.get("/ffs/run/swconfig.txt", output_path)

        except Exception as e:
            if my_connection:
                my_connection.disconnect()
            raise e
        my_connection.disconnect()


def get_enb_ip(tl):
    try:
        enb_ip = tl.enbs[0].oam_ip.v4
        return enb_ip

    except Exception as e:
        return None
