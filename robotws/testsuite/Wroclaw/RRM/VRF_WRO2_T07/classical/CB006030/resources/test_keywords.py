from taf.config.scf import scf
from taf.gnb.oam.coam.admin import admin
from testsuite.Wroclaw.RRM.resources.webUI_operations import download_current_scf, BuiltIn
from taf.ul.oam.netact.swm.swhandler import SwHandler

swhander = SwHandler()
scf = scf()
bts_id = BuiltIn().get_variable_value("${tl.gnbs[0].instance_id}")
api = admin()


def save_current_scf(scf_name="SCF_backup.xml"):
    scf_file = download_current_scf(scf_name)
    return scf_file


def scf_update(scf_path):
    connection = api.connect_to()
    BuiltIn().log("SCF path:" + scf_path)
    connection.perform_commissioning(scf_file=scf_path, skip_parameter_relation_errors=True)
    connection.disconnect()


def adj_object_check():
    save_current_scf()
    scf_path = BuiltIn().get_variable_value("${LOG_PATH}") + '/SCF_backup.xml'
    scf.load_scf(scf_path)
    nrrel_values = scf.get_all_values_from_scf_by_pattern(
        dist_name="MRBTS-{}/NRBTS-{}/NRCELL-.".format(bts_id, bts_id), p_name="gNbId")
    nradjnrcell_gnbid = scf.get_all_values_from_scf_by_pattern(
        dist_name="MRBTS-{}/NRBTS-{}/NRADJNRCELL-.".format(bts_id, bts_id), p_name="gNbId")
    nradjnrcell_gnbid_length = scf.get_all_values_from_scf_by_pattern(
        dist_name="MRBTS-{}/NRBTS-{}/NRADJNRCELL-.".format(bts_id, bts_id), p_name="gNbIdLength")
    nrbts_gnbid_length = scf.get_all_values_from_scf_by_pattern(
        dist_name="MRBTS-{}/NRBTS-{}$".format(bts_id, bts_id), p_name="gNbIdLength")

    if not nradjnrcell_gnbid:
        raise AssertionError("NRADJNRCELLs haven't been created")
    else:
        for el in nradjnrcell_gnbid:
            if el == bts_id:
                if nradjnrcell_gnbid_length[nradjnrcell_gnbid.index(el)] == nrbts_gnbid_length:
                    raise AssertionError(
                        "Invalid parameter in NRADJNRCELL\n "
                        "NRADJNRCELL.gNbIdLength shouldn't be equal to NRBTS.gNbIdLength")

    rel_indexes_to_own_bts = []
    for x in range(0, len(nrrel_values)):
        if nrrel_values[x] == bts_id and nrrel_values[x+1] == nrbts_gnbid_length[0]:
            rel_indexes_to_own_bts.append(x)
            rel_indexes_to_own_bts.append(x+1)
    for el in rel_indexes_to_own_bts[::-1]:
        del nrrel_values[el]

    if nrrel_values == nradjnrcell_gnbid:
        BuiltIn().log(message="There are copies of connections to external cells in NRREL")


def x2_link_availability():
    connection = api.connect_to()
    lteend_params = connection.get_objects_by_class_name(class_name="LTEENB_R", timeout=30)[0]['parameters']
    x2_link_status = lteend_params['x2LinkStatus']
    BuiltIn().log(x2_link_status)
    if x2_link_status != 'available':
        raise AssertionError("x2LinkStatus is not available")
    connection.disconnect()
    return True


def xn_link_availability():
    connection = api.connect_to()
    xnlink_params = connection.get_objects_by_class_name(class_name="XNLINK_R", timeout=30)[0]['parameters']
    xn_link_status = xnlink_params['xnLinkStatus']
    if xn_link_status != 'available':
        raise AssertionError("xnLinkStatus is not available")
    connection.disconnect()
    return True


def get_sw_version_from_bts():
    connection = api.connect_to()
    sw_version = connection.get_sw_version()
    sw_version = sw_version.split("_")
    sw_version = str(int(sw_version[2])) + "." + str(int(sw_version[3])) + "." + str(int(sw_version[4]))
    BuiltIn().log_to_console("SW VERSION FROM BTS: " + sw_version)
    connection.disconnect()
    return sw_version


def download_software_from_artifactory(sw_version):
    swhander.download_build_from_wft(sw_version, "/tmp")
    sw_path = "/tmp/"
    BuiltIn().log_to_console("Sw from artifactory path: " + sw_path)
    return sw_path


def download_current_sw_build():
    sw_version = get_sw_version_from_bts()
    sw_path = download_software_from_artifactory(sw_version)
    BuiltIn().log_to_console("Current sw build path: " + sw_path)
    return sw_path


def configuration_reset():
    connection = api.connect_to()
    connection.reset_configuration()
    connection.disconnect()


def sw_update(sw_dir, sw_version, timeout=900):
    connection = api.connect_to()
    sw_path = str(sw_dir) + 'AirScale-' + str(sw_version) + '.zip'
    BuiltIn().log_to_console("Sw path: {}".format(sw_path))
    BuiltIn().log_to_console("Starting update...")
    connection.update_software(sw_package=sw_path, timeout=timeout)
    BuiltIn().log_to_console("After update")
    connection.disconnect()
    BuiltIn().log_to_console("SW Update sw path: {}".format(sw_path))


def software_version_check():
    connection = api.connect_to()
    connection.get_sw_version()
    sw_version = connection.get_sw_version()
    connection.disconnect()
    return "5G21A" in sw_version


def teardown_clean(sw_path, sw_version):
    if not software_version_check():
        sw_update(sw_path, sw_version, 900)
