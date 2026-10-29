from taf.sbts.oam.coam.admin import admin
import taf.config.scf as scf_interface
import logging

adm = admin()
scf = scf_interface.scf()


def get_radio_index(mrbts):
    return mrbts.split('-')[-1]


def get_admin_ru_mrbts_coam(connection):
    """
    Returns dist_name values for all cells as a list
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: list of dist_name values for all available Radio Units from admin info model
    :rtype: (list of str)
    """
    frm_output = adm.get_frm(connection=connection)
    return [elements['id']['internal'] for elements in frm_output]


def get_admin_cells_mrbts(connection):
    """
    Returns dist_name values for all cells as a list
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: list of dist_name values for all cells from admin info model
    :rtype: (list of str)
    """
    subcells_info_output = adm.get_subcells_info(connection=connection)

    dist_name_list = []

    for cell_groups, cell_groups_values in subcells_info_output.items():
        for nr_cell, nr_cell_values in cell_groups_values.items():
            dist_name_list.append(nr_cell_values['NRCELL_R']['distName'])
    return dist_name_list


def get_number_of_radio_units(connection="admin"):
    bts_info = adm.get_bts_info(connection=connection, timeout=30)
    return len(bts_info["radioModules"]["rmod"])


def get_admin_ru_conf(connection="admin"):
    frm_output = adm.get_frm(connection=connection)
    return [elements["id"]["configuration"] for elements in frm_output]


def lock_all_radio_units(connection="admin"):
    radios = get_admin_ru_conf
    for radio in radios:
        adm.unlock_ru(connection=connection, dist_name=radio)


def get_scf_file():
    adm = admin(connection="admin")
    adm.get_current_scf_file("/tmp", "current_scf.xml")
    scf.load_scf("/tmp/current_scf.xml")


def load_scf_now():
    scf.load_scf("/tmp/current_scf.xml")


def get_this_bts_name(mrbts_id):
    return scf.get_value_from_scf(dist_name="MRBTS-" + mrbts_id, p_name="btsName")


def verify_all_cells_status():
    expected_cell_status = {
        "usageState": "Active", "operationalState": "Enabled", "proceduralStatus": "configured",
        "blockingState": "Unblocked", "availabilityStatus": "Online",
        "administrativeState": "Unlocked"}
    cells_info = adm.get_cells_info(cell_type="nr", timeout=30, connection="admin")
    for cell in cells_info:
        if cell["status"] != expected_cell_status:
            raise Exception("The cell status is not as expected. Current cell status: %s "
                            "and Expected Cell Status : %s" % (cell["status"], expected_cell_status))


def verify_bts_status():
    expected_bts_status = {
        "operationalState": "Enabled", "proceduralState": "OnAir", "blockingState": "Unblocked"}
    bts_status = adm.get_bts_statuses(connection="admin", timeout=30)
    if bts_status != expected_bts_status:
        raise Exception("The BTS status is not as expected. Current BTS status: %s and Expected BTS status: %s" %
                        (bts_status, expected_bts_status))


def verify_all_radios_status():
    expected_radio_status = {
        "operationalState": "Enabled", "availabilityStatus": "Online", "administrativeState": "Unlocked",
        "blockingState": "Unblocked", "usageState": "Active"}
    radios_info = adm.get_frm(timeout=30)
    for radio in radios_info:
        if radio["status"] != expected_radio_status:
            raise Exception(
                "The radio status with productCode: %s is not as expected. Current radio status: %s "
                "and Expected Cell Status : %s" % (radio["productCode"], radio["status"], expected_radio_status))


def verify_all_radios_status_test():
    expected_radio_status = {
        "operationalState": "Enabled", "availabilityStatus": "Online", "administrativeState": "Unlocked",
        "blockingState": "Unblocked", "usageState": "Active"}
    radios_info = adm.get_bts_info(timeout=30)
    number_of_radios = radios_info["radioModules"]["rmod"]
    for radio in number_of_radios:
        if str(radio["status"]) != expected_radio_status:
            raise Exception(
                "The radio status with productCode: %s is not as expected. Current radio status: %s "
                "and Expected Cell Status : %s" % (radio["productCode"], radio["status"], expected_radio_status))


def check_alarms():
    """
    Check alarms and raise exception if there are unexpected alarms.
    :param allowed_alarms: dict: Dictionary of allowed alarms, key - fault ID and value fault Name.
    :param expected_alarms: list: List of expected alarms, fault ID.
    """
    allowed_alarms = {"61050": "Missing or non-compliant SFP module on SMOD-1, EIF1",
                      "61652": "R&D Service Port enabled",
                      "61524": "SSH Enabled",
                      "6149": "LMP access via port 443"}
    unexpected_alarms = {}
    expected_alarms = {}
    active_alarms = adm.get_active_alarms(timeout=30)
    allowed_alarms = {int(k): v for k, v in allowed_alarms.items()}
    for alarm in active_alarms:
        if alarm["faultId"] not in allowed_alarms.keys():
            if alarm["faultId"] in expected_alarms:
                raise Exception("Expected fault was raised: {}".format(expected_alarms))
            else:
                unexpected_alarms[alarm["faultId"]] = alarm["faultName"]
    if unexpected_alarms:
        raise Exception("Following unexpected faults were raised: {}".format(unexpected_alarms))


def verify_test_success_rate(results, expected_amount):
    """Set Test Variable
    Count how many reset were successful and print the result.
    :param results: list: List with true of false values.
    :param expected_amount: str: Expected amount of attaches.
    """
    if int(len(results)) != int(expected_amount):
        raise Exception("Not went through all! {}/{}".format(len(results), expected_amount))
    else:
        if not all(results):
            raise Exception("Test success rate: {}/{}".format(sum(results), expected_amount))


def check_verification_statuses(test_list_result):
    return True if all(test_list_result) else False
