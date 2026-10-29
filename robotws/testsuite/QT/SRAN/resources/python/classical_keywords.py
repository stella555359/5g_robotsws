import time
import os
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh import ssh
from robot.api import logger
import taf.sbts.oam.coam.admin as admin_cli_interface
import json

ssh = ssh()
admin_cli = admin_cli_interface.admin()
rf_pmax_map = {'AHFIB': 39.03, 'FRGU': 39.03, 'AHLOA': 40.79, 'FXJB': 39.03, 'AHEGA': 42.04,
               'AHCA': 39.03, 'AHEB': 39.03, 'AZQP': 37.3, 'AZNA': 36.02, 'FZHM': 33.01, 'AEHC': 23.98,
               'AEQE': 22, 'AHPB': 42.04, 'AVQL': 17, 'AEQN': 23.01, 'AHDB': 37}


def stop_rf_calibraton_feat_1834(rf_ip, alias, password):
    connection = ssh.get_connection_by_alias(alias)
    channel = connection.invoke_shell()
    passwd = ''.join((password, '\n'))
    node = '1'
    channel.send('hostname\n')
    time.sleep(1)
    hostname = channel.recv(65536)
    if '4a' in hostname:
        node = '2'
    channel.send('lxc-attach -n 0x{}018\n'.format(node))
    time.sleep(2)
    print(channel.recv(65536))
    cmd = ''.join(('ssh -o "StrictHostKeyChecking no" root@', rf_ip, '\n'))
    channel.send(cmd)
    time.sleep(6)
    print(channel.recv(65536))
    channel.send(passwd)
    time.sleep(3)
    print(channel.recv(65536))
    channel.send('bfcali -stop\n')
    time.sleep(3)
    print(channel.recv(65536))


def check_hw_status(hw_num):
    logger.info("Start to check board status: \n")
    amia_check = ssh.execute("hostname", "smod")
    py_check = ssh.execute("python --version", "smod")
    py_ver = "python3" if "command not found" in py_check else "python"
    sys_result = ssh.execute(
        "export PYTHONPATH=/opt/hwmt/python &&"
        " {} /opt/hwmt/python/hwapi/AdetS.py -s -p 15004 | grep {}".format(py_ver, hw_num),
        "smod")
    if 'ready[0]' not in sys_result and 'fct-4a' in amia_check:
        sys_result = ssh.execute(
            "export PYTHONPATH=/opt/hwmt/python &&"
            " {} /opt/hwmt/python/hwapi/AdetS.py -s -n 0x2011 -p 15004 | grep {}".format(py_ver, hw_num),
            "smod")
    if 'ready[0]' in sys_result:
        logger.info("ABIL board in right status")
        return True
    else:
        logger.info("Status is abnormal")
        return False


def verify_fsp_status(service):
    outcome = ssh.execute("systemctl status %s |awk 'NR<4{print}'"
                          % service, 'fsp')
    if "Active: active (running)" not in outcome:
        logger.error("status is abnormal")
        return False
    else:
        logger.info("service is in active status")
        return True


def reserve_iq_data_feat_1834(rf_ip, alias, password):
    """ this function is used to check the ul thoughput on viavi.
    In 1834 feature, rf should be acess by the container 0x1018.
    so ssh to asik, then input the 'lxc-attach -n 0x1018\n' to the shell.
    and then all the following commands were input into the shell directly instead of ssh.
    Author: kongshuai.fan
    :param rf_ip: the rf ip assigned by the OAM DHCP
    :param alias: The ssh alias which use to write data to rf
    """
    connection = ssh.get_connection_by_alias(alias)
    channel = connection.invoke_shell()
    passwd = ''.join((password, '\n'))
    node = '1'
    channel.send('hostname\n')
    time.sleep(1)
    hostname = channel.recv(65536)
    if '4a' in hostname:
        node = '2'
    channel.send('lxc-attach -n 0x{}018\n'.format(node))
    time.sleep(2)
    print(channel.recv(65536))
    cmd = ''.join(('ssh -o "StrictHostKeyChecking no" root@', rf_ip, '\n'))
    channel.send(cmd)
    time.sleep(6)
    print(channel.recv(65536))
    channel.send(passwd)
    time.sleep(2)
    print(channel.recv(65536))
    channel.send('/sbin/devmem 0xa0205030 32 0x0\n')
    time.sleep(2)
    print(channel.recv(65536))
    channel.send('ssh 192.168.100.2 /sbin/devmem 0xa0205030 32 0x0\n')
    time.sleep(2)
    print(channel.recv(65536))


def check_file_permission(file, permission, alias):
    file_path = '/'.join(file.strip().split('/')[:-1]) + '/'
    print('File path is,', file_path)
    checked_file = file.strip().split('/')[-1]
    print('Files to be checked is,', checked_file)
    if not ssh.file_exists(file, connection=alias):
        if 'stb' in file:
            logger.warn("File or directory {} does not exist on stb partition,\
            permission check skipped!".format(file))
            return True
        else:
            logger.error("File or directory {} does not exist, please check!".format(file))
            return False
    outcome = cycle_counter(cmd="ls -la %s | grep %s" % (file_path, checked_file), connection=alias)
    print('outcome is:', outcome)
    if len(outcome) == 0:
        logger.error("cannot read permission of {}, please manually check".format(file))
        return False
    else:
        outcome = outcome.split("\r\n")
        outcome = [line for line in outcome if line.strip() != '']
        print("The file to be checked is:,", outcome)
        for line in outcome:
            file_1 = line.split()[-1]
            cmd = "ls -la %s | grep -w %s |sed 's/r/4/g;s/w/2/g;s/x/1/g;s/-/0/g;s/./& /g' \
            |awk '{printf ($2+$3+$4)($5+$6+$7)($8+$9+$10)}'" % (file_path, file_1)
            file_permission = cycle_counter(cmd=cmd, connection=alias, value=permission)
            print("the permission of {} is: ".format(file_1), file_permission)
            if len(file_permission) == 0 or not file_permission.isdigit():
                print("cannot read the permission value of {}, please manually check".format(file_1))
                return False
            elif int(file_permission) < int(permission):
                logger.error("The permission of {} is {} instead of {}, \
                Please manually check".format(file_1, file_permission, permission))
                return False
    return True


def cycle_counter(cmd, connection, value=None):
    i = 0
    outcome = None
    while i < 3:
        outcome = ssh.execute(cmd, connection)
        if value is not None and outcome != value:
            i += 1
            time.sleep(10)
            print('permission check failed, retrying...')
        elif len(outcome) == 0:
            i += 1
            time.sleep(10)
        else:
            break
    return outcome


def get_rf_module_id(connection):
    rf_info = admin_cli.get_frm(connection=connection)
    rf_module_ids_map = {}
    # print('rf info is {}'.format(rf_info))
    if rf_info:
        for rf in rf_info:
            rf_product_name = rf['productName']
            rf_module_id = rf['id']['internal']
            rf_module_ids_map[rf_product_name] = rf_module_id
    return rf_module_ids_map


def get_cell_mapping_by_rf_module_ids(connection):
    rf_cell_map = {}
    rf_module_ids_map = get_rf_module_id(connection)
    print('rf_module_ids_map is '.format(rf_module_ids_map))
    if rf_module_ids_map:
        for rf_product_name in rf_module_ids_map:
            output = admin_cli.get_cell_mapping_by_module_id(module_id=rf_module_ids_map[rf_product_name],
                                                             connection=connection)
            rf_cell_map[rf_product_name] = output
    return rf_cell_map


def get_and_check_cell_power(connection):
    gsm_wcdma_power_key_map = {'GNCEL': 'maxOutputPowerPerTRX', 'WNCEL': 'maximumCarrierPower'}
    rf_cell_power_map = {}
    rf_cell_power_check_failed_map = {}
    rf_cell_map = get_cell_mapping_by_rf_module_ids(connection)
    print('rf_cell_map is {}'.format(rf_cell_map))
    if rf_cell_map:
        for rf_product_name in rf_cell_map:
            pmax_list = []
            for cell_dist_name in rf_cell_map[rf_product_name]:
                if 'NRCELL' in cell_dist_name or 'LNCEL' in cell_dist_name:
                    pmax = admin_cli.get_rf_output_power(lncel_dist_name=cell_dist_name, connection=connection)
                    pmax = list(pmax.values())[0]
                    pmax_list.append(pmax)
                    if rf_product_name in rf_pmax_map.keys():
                        if pmax < rf_pmax_map[rf_product_name]:
                            msg = 'pmax value on {} of RF module {} is {} \
which is lower than expected value {}'.format(cell_dist_name, rf_product_name, pmax, rf_pmax_map[rf_product_name])
                            rf_cell_power_check_failed_map[rf_product_name] = msg
                        else:
                            msg = 'pmax value on {} of RF module {} is {} \
meets target value {}'.format(cell_dist_name, rf_product_name, pmax, rf_pmax_map[rf_product_name])
                            print(msg)
                    else:
                        BuiltIn().log('Failed to find expected pmax value for RF {}, \
skip pmax check!!!'.format(rf_product_name), 'WARN')
                elif 'NCEL' in cell_dist_name:
                    pmax = admin_cli.get_cell_specific_info(cell_dist_name, connection=connection)[
                        gsm_wcdma_power_key_map[cell_dist_name.split('/')[-1].split('_')[0]]]
                    pmax_list.append(pmax)
                    if rf_product_name in rf_pmax_map.keys():
                        if pmax < rf_pmax_map[rf_product_name]:
                            msg = 'pmax value on {} of RF module {} is {} \
which is lower than expected value {}'.format(cell_dist_name, rf_product_name, pmax, rf_pmax_map[rf_product_name])
                            rf_cell_power_check_failed_map[rf_product_name] = msg
                        else:
                            msg = 'pmax value on {} of RF module {} is {} \
meets target value {}'.format(cell_dist_name, rf_product_name, pmax, rf_pmax_map[rf_product_name])
                            print(msg)
                else:
                    print('remove {}'.format(cell_dist_name))
            rf_cell_power_map[rf_product_name] = pmax_list
    return rf_cell_power_map, rf_cell_power_check_failed_map


def get_bts_sync_sources(connection='coam_admin'):
    """
    Retrieves the synchronization sources and their input types.

    Args:
        connection (str): The connection name. Defaults to 'coam_admin'.

    Returns:
        tuple: A tuple containing a list of sync input types and the sync sources.

    Example:
        sync_input_types, sync_sources = get_bts_sync_sources()
        print(sync_input_types)  # ['type1', 'type2', 'type3']
        print(sync_sources)  # [{'syncInputType': 'type1', ...}, {'syncInputType': 'type2', ...}, ...]
    """
    sync_sources = admin_cli.get_synchronization_information(timeout=30, connection=connection)['syncSourceInfo']
    print("sync_sources is: ", sync_sources)
    return ', '.join([source['syncInputType'] for source in sync_sources]), sync_sources


def check_gps_sync_status(connection='coam_admin'):
    """
    Check the GPS synchronization status.

    Args:
        connection (str): The connection name. Defaults to 'coam_admin'.

    Returns:
        list: A list containing two elements:
            - A boolean indicating if the GNSSE_R-1 operational state is 'enabled'.
            - A string describing the GNS operation status.

    """
    gns_status = admin_cli.get_gnsses_statuses(timeout=30, connection=connection)
    print("gns_status is: ", gns_status)
    return [
        gns_status['GNSSE_R-1']['operationalState'].lower() == 'enabled',
        "GNS operation status is {}".format(gns_status['GNSSE_R-1']['operationalState'])
    ]


def check_topp_sync_status(sync_sources):
    """
    Check the synchronization status of TOPP (Third-Party Provider) sync sources.

    Args:
        sync_sources (list): A list of sync sources to check.
        connection (str, optional): The connection to use for checking the status. Defaults to 'coam_admin'.

    Returns:
        list: A list containing two elements:
            - A boolean indicating if the TOPP sync status is active and usable.
            - A string describing the sync source's active status and usability status.

    If no TOPP sync source is found in the provided list, the function returns [True, "TOPP is not configured!!!"].
    """
    for sync_source in sync_sources:
        if sync_source['syncInputType'].startswith('TOP'):
            active_status = sync_source['isActive']
            usability_status = sync_source['status']['usability']
            return [
                active_status and usability_status.lower() == 'usable',
                "{} active status is {}, usability status is {}".format(
                    sync_source['syncInputType'],
                    active_status,
                    usability_status
                )
            ]
    return [True, "TOPP is not configured!!!"]


def get_all_sfp_info(connection='coam_admin'):
    """
    Retrieves information about all SFPs installed in BTS site and returns structured data for Robot keyword
    Save SFP File Data in Env Health Check.

    Args:
        connection (str): The connection object representing the BTS site connection.

    Returns:
        tuple: (True, sfp_data_dict) if SFPs are correct.
               (False, sfp_data_dict) if there are failures ar warnings for SFP(s).
    """

    sfp_info = admin_cli.get_sfp_data(connection=connection)

    sfp_data_dict = {}
    sfp_check_failed = ''
    sfp_warn_list = []

    for i, item in enumerate(sfp_info['connected'], start=1):
        source = item['source']
        destination = item['destination']
        source_type = source['type']
        ru_type = source_type[source_type.find('(') + 1: source_type.find(')')]
        source_sfp_code = source['connector']['sfp']['vendorPartNumber']
        dest_sfp_code = destination['connector']['sfp']['vendorPartNumber']

        source_path = source.get("connector", {}).get("path", "")
        destination_path = destination.get("connector", {}).get("path", "")
        full_path = f"{source['type']}/{source_path}&{destination_path}/{destination['type']}"

        print(f"Processing link {i}:\n\tRU type: {ru_type}"
              f"\n\tsource SFP: {source_sfp_code}\n\tdestination SFP: {dest_sfp_code}")

        source_sfp_return, source_msg, source_sfp_params = check_sfp(ru_type, source_sfp_code)
        destination_sfp_return, dest_msg, destination_sfp_params = check_sfp(ru_type, dest_sfp_code)

        sfp_data_dict[f"link_{i}"] = {
            "ru_type": ru_type,
            "source_sfp_code": source_sfp_code,
            "destination_sfp_code": dest_sfp_code,
            "source_sfp_msg": source_msg,
            "destination_sfp_msg": dest_msg,
            "path": full_path
        }

        if source_sfp_params:
            sfp_data_dict[f"link_{i}"]["source_sfp_type"] = source_sfp_params['SFP_type']
            sfp_data_dict[f"link_{i}"]["source_sfp_family"] = source_sfp_params['SFP_family']
            sfp_data_dict[f"link_{i}"]["source_sfp_status"] = source_sfp_params['Status']

        if destination_sfp_params:
            sfp_data_dict[f"link_{i}"]["destination_sfp_type"] = destination_sfp_params['SFP_type']
            sfp_data_dict[f"link_{i}"]["destination_sfp_family"] = destination_sfp_params['SFP_family']
            sfp_data_dict[f"link_{i}"]["destination_sfp_status"] = destination_sfp_params['Status']

        if not source_sfp_return or not destination_sfp_return:
            sfp_check_failed = True

    if sfp_check_failed:
        return False, sfp_data_dict
    else:
        return True, sfp_data_dict


def check_sfp(rf_name, bts_sfp_code):
    """
    Check the SFP compatibility for a given RF name and SFP code.

    Args:
        rf_name (str): The name of the RF.
        bts_sfp_code (str): SFP code on BTS.

    Returns:
        tuple: A tuple containing a boolean value with: compatibility status, message, dictionary with SFP details.
            - If the SFP is compatible, the boolean value is True and the message is the SFP's: code, type, family.
            - If the SFP family is unknown (not: SFP, SFP28, SFP+), the boolean value is False and the message
              is warning which suggests to check the SFP family in _rf_sfp_mapping_file file.
            - If the RF name is not listed in the _rf_sfp_mapping_file file, the boolean value is False and the message
              is a warning to add it in _rf_sfp_mapping_file file.
            - If the SFP is disqualified, the boolean value is False and the message indicates the reason and suggests
              replacement.
            - If the SFP type does not match the required type (type is any of: FOTA, FOTB, FOSC, FOSD), the boolean
              value is False and the message indicates the reason and suggests replacement.
            - If the SFP family does not match the required family, the boolean value is False and the message
              indicates the reason and suggests replacement.
            - If the SFP supplier code is not present in _supported_sfp_file, the boolean value is False and the message
              is a warning to check the _supported_sfp_file file.
            - If a family of SFP installed on a BTS site is "SFP+" while rf_name RMOD requires "SFP" type, the boolean
              value is False and the message is a warning to verify requirements and files: _supported_sfp_file,
              _rf_sfp_mapping_file.
    """

    _supported_sfp_file = BuiltIn().get_variable_value('${supported_sfp_file}')
    _rf_sfp_mapping_file = BuiltIn().get_variable_value('${rf_sfp_mapping_file}')

    # Uncomment below variables for testing using get_all_sfp_info_test function in __main__
    # _supported_sfp_file = "/home/ute/DSL-QT/text_files/configs/SFPs.json"
    # _rf_sfp_mapping_file = "/home/ute/DSL-QT/text_files/configs/RF_SFP_mapping.json"

    with open(_supported_sfp_file, 'r', encoding='utf-8') as f:
        expected_sfp_variables = json.load(f)
    with open(_rf_sfp_mapping_file, 'r', encoding='utf-8') as g:
        rf_sfp_mapping_variables = json.load(g)

    rf_sfp_dict = rf_sfp_mapping_variables["rf_sfp"]
    expected_sfp_params = next(
        (item for item in expected_sfp_variables if item['Supplierpartcode'] == bts_sfp_code), None)

    if rf_name in rf_sfp_dict:
        expected_sfp_family_list = rf_sfp_dict[rf_name]
        if not any(element in ['SFP', 'SFP28', 'SFP+'] for element in expected_sfp_family_list):
            return False, \
                f'WARN: Required SFP family for {rf_name} RMOD is unknown ({expected_sfp_family_list}). ' \
                f'Please check {_rf_sfp_mapping_file} file.', \
                expected_sfp_params
    else:
        return False, \
            f'WARN: {rf_name} RMOD does not exist in {_rf_sfp_mapping_file} file. Please add it.', \
            expected_sfp_params

    core_msg = f'{rf_name} RMOD requires {expected_sfp_family_list}.'
    reference_msg = f'See {_supported_sfp_file} file as a reference.'
    if expected_sfp_params:
        if expected_sfp_params['Status'] == 'disqualified':
            return False, \
                f"{bts_sfp_code} is disqualified. Please replace it. {reference_msg}", \
                expected_sfp_params
        if expected_sfp_params['SFP_type'] in ['FOTA', 'FOTB', 'FOSC', 'FOSD']:
            return False, \
                f"{bts_sfp_code} must not be used for RMOD as it\'s type is " \
                f"{expected_sfp_params['SFP_type']}. Please replace it. {reference_msg}", \
                expected_sfp_params
        if expected_sfp_params['SFP_family'] == 'SFP+' and expected_sfp_family_list == ['SFP']:
            return False, \
                f"WARN: {core_msg} {expected_sfp_params['SFP_type']} ({expected_sfp_params['SFP_family']}) is used on" \
                f" BTS site. Please verify requirements. See {_rf_sfp_mapping_file} and {_supported_sfp_file} files.", \
                expected_sfp_params
        if expected_sfp_params['SFP_family'] in expected_sfp_family_list:
            return True, \
                f"{bts_sfp_code} ({expected_sfp_params['SFP_type']}, {expected_sfp_params['SFP_family']}) " \
                f"is correct.", \
                expected_sfp_params
        else:
            return False, \
                f"{core_msg} {expected_sfp_params['SFP_type']} ({expected_sfp_params['SFP_family']}) " \
                f"is used on BTS site. Please replace it. {reference_msg}", \
                expected_sfp_params
    else:
        return True, \
            f"WARN: Installed SFP\'s supplier code {bts_sfp_code} is not present in {_supported_sfp_file} " \
            f"file. Please check it.", \
            expected_sfp_params


def get_all_smods_info(connection='coam_admin'):
    """
    Retrieves information about all SMODs (Service Modules) in the system.

    Args:
        connection (str): The connection name. Defaults to 'coam_admin'.

    Returns:
        dict: A dictionary containing SMOD IDs as keys and their product names and codes as values.
    """
    smod_info = admin_cli.get_fsm_info(connection=connection)
    smod_info_dict = {}
    for smod_details in smod_info:
        print(f"Processing SMOD ID: {smod_details['id']['internal']}")
        if 'productName' not in smod_details:
            logger.warn(
                f"SMOD ID {smod_details['id']['internal']} is missing the 'productName' key. "
                f"Please check if SMOD is detected correctly."
            )
            logger.debug(f"SMOD details: {json.dumps(smod_details, indent=2)}")
            continue
        smod_info_dict[smod_details['id']['internal']] = {
            smod_details['productName']: smod_details.get('productCode', 'Unknown')
        }
    return smod_info_dict


def is_specific_smod_version(smods_info_dict, target_product_name, target_product_code):
    """
    Checks if a specific SMOD (Service Module) with the given product name and product code exists.

    This function iterates through the provided SMOD information dictionary to find a match
    where the `target_product_name` is part of the product name and the `target_product_code`
    is part of the product code.

    Args:
        smods_info_dict (dict): A dictionary containing SMOD IDs as keys and their details as values.
                                Example structure:
                                {
                                    "smod_id_1": {"product_name_1": "product_code_1"},
                                    "smod_id_2": {"product_name_2": "product_code_2"}
                                }
        target_product_name (str): The product name to search for.
        target_product_code (str): The product code to search for.

    Returns:
        bool:
            - `True` if a matching SMOD is found.
            - `False` if no matching SMOD is found.

    Logs:
        - Logs a message when a match is found, including the SMOD ID, product name, and product code.
        - Logs a message if no match is found.

    Example:
        ```python
        smods_info = {
            "12345": {"ASOG A101": "A.101"},
            "67890": {"OTHER_PRODUCT": "B.202"}
        }
        if is_target_smod_version(smods_info, "ASOG", "A.101"):
            print("Target SMOD found!")
        else:
            print("Target SMOD not found.")
        ```
    """
    for smod_id, smod_details in smods_info_dict.items():
        for product_name, product_code in smod_details.items():
            if target_product_name in product_name and target_product_code in product_code:
                logger.info(
                    f"Found {target_product_name} {target_product_code} SMOD with ID {smod_id}, "
                    f"Product Name: {product_name}, "
                    f"Product Code: {product_code}"
                )
                return True

    logger.info(f"No {target_product_name} {target_product_code} SMOD found.")
    return False


def is_ASOG_A101(connection='coam_admin'):
    """
    Checks if the ASOG A.101 SMOD is present in the system.

    Args:
        connection (str): The connection name. Defaults to 'coam_admin'.

    Returns:
        bool: True if ASOG A.101 SMOD is found, False otherwise.
    """
    smods_info_dict = get_all_smods_info(connection=connection)
    return is_specific_smod_version(smods_info_dict, 'ASOG', 'A.101')


def get_rf_versions(rf_name='ALL', conn='coam_admin'):
    """
    Get the build versions of RF modules.

    Args:
        rf_name (str): The RF module name to filter. If "ALL", return all RF modules. Default is "ALL".
        conn (str): The connection name. Default is 'coam_admin'.

    Returns:
        dict: A dictionary mapping serial numbers to build versions.
              If rf_name is specified, only returns versions for that RF module.
    """
    output = admin_cli.get_parameters_for_all(class_name="RMOD", connection=conn)
    result = {}

    if rf_name != "ALL":
        for rf in output:
            name = rf.get("productName", "")
            sn = rf.get("serialNumber", "")
            if name == rf_name:
                result[sn] = rf.get("buildVersion", "")
        return result
    else:
        for rf in output:
            sn = rf.get("serialNumber", "")
            result[sn] = rf.get("buildVersion", "")
        return result


if __name__ == '__main__':
    admin_cli.connect_to(bts_host='192.168.255.129', name='coam_admin')
    output = get_rf_version(rf_name='AHCA', conn='coam_admin')
    smods_info_dict = get_all_smods_info(connection='coam_admin')
    print(is_specific_smod_version(smods_info_dict, 'ASOG', 'A.101'))
    admin_cli.teardown_admin(connection='coam_admin')
