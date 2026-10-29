import json
import time
import testsuite.Krakow.resources.RAN_PZ_KRK2.FR_CB009493_CB009055_CB009487.sbts_methods as sbts_keywords

from robot.api import logger
from taf.sbts.oam.coam.admin import admin
from testsuite.Krakow.resources.RAN_PZ_KRK2.FR_CB009493_CB009055_CB009487.AsirSelenium import AsirSelenium
from variables import *


def sfn_antmod_group(ant_cell_info=None):
    """
    keyword sfn_antmod_group:

    Get which two ants are a pair of sfn ants
    :param ant_cell_info: the input parameter is get from keyword: Kw Get Asir Celllist Xmod Mapping or
    Xmod Cell Relation Mapping, they should be used together

    :return: List of sfn ant pair [[xx, xx], [xx, xx], [xx, xx]]
    """
    sfn_ant_sub_group = []
    the_first_ant = None
    new_ant_cell_info = {k: v for k, v in ant_cell_info.items() if v}

    for k, v in new_ant_cell_info.items():
        if not the_first_ant:
            the_first_ant = k
        if v['asir_cell_id_list'] == new_ant_cell_info[the_first_ant]['asir_cell_id_list']:
            sfn_ant_sub_group.append(k.split("-")[-1])
    else:
        sfn_ant_group.append(sfn_ant_sub_group)
        for item in sfn_ant_sub_group:
            del new_ant_cell_info[f"ANTMOD-{item}"]

        if new_ant_cell_info:
            sfn_antmod_group(new_ant_cell_info)

    return sfn_ant_group


def block_antmod_and_check_status(sfn_antmod_group, ant_cell_mapping, oam_ip="192.168.255.129", virtual_display=True,
                                  timeout=60):
    """
    keyword block_antmod_and_check_status:

    Block ant one by one and check status
    :param sfn_antmod_group, the input parameter is get from keyword: sfn_antmod_group
    :param ant_cell_info: the input parameter is get from keyword: Kw Get Asir Celllist Xmod Mapping or
    Xmod Cell Relation Mapping, they should be used together
    :param oam_ip
    :param virtual_display
    :param timeout

    """
    for sfn_sub_group in sfn_antmod_group:
        for ant_id in sfn_sub_group:
            logger.info(f"Start block ANTMOD-{ant_id}", also_console=True)
            sbts_keywords.block_antmod(ant_id, ne=oam_ip)
            logger.info(f"End of blocking ANTMOD-{ant_id}", also_console=True)

            cell_status_after_block_ant_macro["availabilityStatus"] = \
                possiable_cell_availability_status_macro[str(sfn_sub_group.index(ant_id))]
            cell_status_after_block_ant_macro["operationalState"] = \
                possiable_cell_operational_state_macro[str(sfn_sub_group.index(ant_id))]
            cell_status_after_block_ant_asir = possiable_cell_status_asir[str(sfn_sub_group.index(ant_id))]
            macro_cell_id_list = ant_cell_mapping.get(f"ANTMOD-{ant_id}").get("macro_cell_id_list")
            asir_cell_id_list = ant_cell_mapping.get(f"ANTMOD-{ant_id}").get("asir_cell_id_list")

            logger.info(f"Start to check ANTMOD-{ant_id} change to {block_ant_status_asir!r} status in {timeout}s",
                        also_console=True)
            _check_antmod_status("block", ant_id, block_ant_status_asir, timeout)
            logger.info(f"ANTMOD-{ant_id} has changed to {block_ant_status_asir!r} status", also_console=True)

            logger.info(f"Start to check macro cell {macro_cell_id_list} status after block ANTMOD-{ant_id}",
                        also_console=True)
            _check_marco_cell_status(oam_ip, "block", ant_id, macro_cell_id_list,
                                     cell_status_after_block_ant_macro, timeout)
            logger.info(f"Macro cell {macro_cell_id_list} has been changed to status "
                        f"{cell_status_after_block_ant_macro!r}", also_console=True)

            logger.info(f"Start to check active alarm <Macro: {block_ant_required_alarm_macro},"
                        f" ASIR: {block_ant_required_alarm_asir}> should be appear after block ANTMOD-{ant_id}",
                        also_console=True)
            sbts_keywords.check_sbts_active_alarm(required_fault_id_list=block_ant_required_alarm_macro, oam_ip=oam_ip)
            sbts_keywords.check_asir_active_alarm(ne=oam_ip, required_fault_id_list=block_ant_required_alarm_asir)
            logger.info(f"End of check alarm after block ANTMOD-{ant_id}", also_console=True)

            logger.info(f"Check asir cell {asir_cell_id_list} should be change to status "
                        f"{cell_status_after_block_ant_asir!r}", also_console=True)
            _check_asir_cell_status(oam_ip, virtual_display, asir_cell_id_list, cell_status_after_block_ant_asir)
            logger.info(f"Asir cell {asir_cell_id_list} has been changed to right status: "
                        f"{cell_status_after_block_ant_asir!r}", also_console=True)


def unblock_antmod_and_check_status(sfn_antmod_group, ant_cell_mapping, oam_ip="192.168.255.129", virtual_display=True,
                                    timeout=60):

    """
    keyword unblock_antmod_and_check_status:

    Unblock ant one by one and check status
    :param sfn_antmod_group, the input parameter is get from keyword: sfn_antmod_group
    :param ant_cell_info: the input parameter is get from keyword: Kw Get Asir Celllist Xmod Mapping or
    Xmod Cell Relation Mapping, they should be used together
    :param oam_ip
    :param virtual_display
    :param timeout

    """
    for sfn_sub_group in sfn_antmod_group:
        ant_id = None
        for ant_id in sfn_sub_group:
            logger.info(f"Start unblock ANTMOD-{ant_id}", also_console=True)
            sbts_keywords.unblock_antmod(ant_id, ne=oam_ip)
            logger.info(f"End of unblocking ANTMOD-{ant_id}", also_console=True)

            logger.info(f"Start to check ANTMOD-{ant_id} change to {unblock_ant_status_asir!r} status in {timeout}s",
                        also_console=True)
            _check_antmod_status("unblock", ant_id, unblock_ant_status_asir, timeout)
            logger.info(f"ANTMOD-{ant_id} has changed to {unblock_ant_status_asir!r} status", also_console=True)

        macro_cell_id_list = ant_cell_mapping.get(f"ANTMOD-{ant_id}").get("macro_cell_id_list")
        asir_cell_id_list = ant_cell_mapping.get(f"ANTMOD-{ant_id}").get("asir_cell_id_list")

        logger.info(f"Start to check macro cell {macro_cell_id_list} status after unblock ANT",
                    also_console=True)
        _check_marco_cell_status(oam_ip, "unblock", ant_id, macro_cell_id_list, avaibility_cell_status_macro, timeout)
        logger.info(f"Macro cell {macro_cell_id_list} has been changed to status "
                    f"{avaibility_cell_status_macro!r}", also_console=True)

        logger.info(f"Check asir cell {asir_cell_id_list} should be change to status "
                    f"{avaibility_cell_status_asir!r}", also_console=True)
        _check_asir_cell_status(oam_ip, virtual_display, asir_cell_id_list, avaibility_cell_status_asir)
        logger.info(f"Asir cell {asir_cell_id_list} has been changed to right status: "
                    f"{avaibility_cell_status_asir!r}", also_console=True)

    logger.info(f"Start to check active alarm, only allowed alarm appeared",
                also_console=True)
    sbts_keywords.check_sbts_active_alarm(allowed_fault_id_list=allowed_faults_sbts, oam_ip=oam_ip)
    logger.info(f"End of check alarm after unblock all ANTs", also_console=True)


def bbmod_cell_relation_mapping(bbmod_id_list=[], oam_ip="192.168.255.129", port=443, connection=None):
    """
    keyword ubbmod_cell_relation_mapping:

    Get cells that on target bbmod
    :param bbmod_id_list, bbmod id list, if [] or None should be all bbmods
    :param oam_ip
    :param port
    :param connection

    return: Dictionary of bbmod id/rat/cell list
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip, bts_port=port)

    bbmod_ids = bbmod_id_list if type(bbmod_id_list) is list else str(bbmod_id_list).split()

    rat_mapping = {"nr": "NRCELL_R", "lte": "LNCEL_R"}
    dict_bbmod_cell_mapping = {}
    dist_internal_cell_by_xmod = {}

    try:
        bts_info = adm.get_bts_info(connection=connection)
        with open("/home/ute/get_bts_info.json", "w+") as f:
            json.dump(bts_info, f)

        for bbmod in bts_info["basebandModules"]:
            internal_cell = adm.get_cell_mapping_by_module_id(module_id=bbmod['id']['internal'], connection=connection)
            bbmod_id = bbmod['id']['configuration'].split('-')[-1]
            dist_internal_cell_by_xmod[bbmod_id] = internal_cell

        for bbmod, internal_cell_list in dist_internal_cell_by_xmod.items():
            if not bbmod_ids or int(bbmod) in bbmod_ids:
                dict_bbmod_cell_mapping[bbmod] = {}
                for rat in rat_mapping.keys():
                    dict_bbmod_cell_mapping[bbmod][rat] = []
                    cell_list = []
                    cell_info_list = adm.get_managed_objects(class_name=rat_mapping[rat], timeout=10,
                                                             connection=connection)
                    with open("/home/ute/get_managed_objects.json", "w+") as f:
                        json.dump(cell_info_list, f)

                    for internal_cell in internal_cell_list:
                        for cell in cell_info_list:
                            if internal_cell.split("/")[-1] == cell['distName'].split("/")[-1]:
                                cid = adm.get_cell_specific_info(cell_id=cell['distName'], connection=connection)[
                                    'globalCellId']
                                if str(cid) not in cell_list:
                                    cell_list.append(str(cid))
                    dict_bbmod_cell_mapping[bbmod][rat] = cell_list

    finally:
        if not connection:
            adm.teardown_admin()

    return dict_bbmod_cell_mapping


def bbmod_asir_cell_relation_mapping(all_asir_cell=None, dict_bbmod_cell_mapping=None, bts_cell_info=None):
    dict_bbmod_asir_cell_mapping = {}
    asir_cell = []
    for k, v in all_asir_cell.items():
        asir_cell += [*v]

    for bbmod_id, cell_info_dict in dict_bbmod_cell_mapping.items():
        dict_bbmod_asir_cell_mapping[bbmod_id] = []
        asir_cell_list = []
        for rat, cell_id_list in cell_info_dict.items():
            if not cell_id_list:
                continue
            for i_rat, btsid in bts_cell_info.items():
                if rat.lower() == i_rat.lower():
                    for cell_id in cell_id_list:
                        asir_cell_id = str(btsid) + '.' + str(cell_id)
                        if asir_cell_id in asir_cell:
                            asir_cell_list.append(asir_cell_id)
        dict_bbmod_asir_cell_mapping[bbmod_id] = asir_cell_list

    return dict_bbmod_asir_cell_mapping


def xmod_cell_relation_mapping(xmod_cell_info=None, bts_cell_info=None):
    xmod_cell_mapping = {}

    for k, v in xmod_cell_info.items():
        if not v:
            continue
        macro_cell_rat_dict = {}
        xmod_cell_mapping[k] = {}
        if v.get('asir_cell_id_list'):
            xmod_cell_mapping[k]['asir_cell_id_list'] = v.get('asir_cell_id_list')

        for rat in bts_cell_info.keys():
            macro_cell_rat_dict[rat.lower()] = []

        if v.get('macro_cell_id_list'):
            for item in v.get('macro_cell_id_list'):
                for rat, btsid in bts_cell_info.items():
                    if item['targetBtsId'] == str(btsid):
                        macro_cell_rat_dict[rat.lower()].append(item['lnCelId'])
            xmod_cell_mapping[k]['macro_cell_id_list'] = macro_cell_rat_dict

    if xmod_cell_mapping:
        return xmod_cell_mapping


def _check_antmod_status(oper, ant_id, expected_status_dict, timeout):
    stime = time.time()
    while time.time() <= stime + timeout:
        try:
            sbts_keywords.check_antmod_status(ant_list=ant_id, expected_status_dict=expected_status_dict)
            break
        except Exception as e:
            logger.error(f"ANTMOD-{ant_id} have not change to status: {expected_status_dict!r} "
                         f"after {oper} the ant, wait for 10s, then try again")
            time.sleep(10)
    else:
        raise Exception(f"ANTMOD-{ant_id} have not change to status: "
                        f"{expected_status_dict!r} in {timeout}s after {oper}")


def _check_marco_cell_status(oam_ip, oper, ant_id, macro_cell_id_list, expected_status_dict, timeout):
    stime = time.time()
    while time.time() <= stime + timeout * 2:
        try:
            sbts_keywords.check_sbts_cell_status(cell_list=macro_cell_id_list,
                                                 expected_status_dict=expected_status_dict, oam_ip=oam_ip)
            break
        except Exception as e:
            logger.error(f"Cell {macro_cell_id_list} have not change to status: {expected_status_dict!r} "
                         f"after {oper} the ant, wait for 10s, then try again")
            time.sleep(10)
    else:
        raise Exception(f"Cell {macro_cell_id_list} have not change to status: "
                        f"{expected_status_dict!r} in {timeout} after {oper} ANTMOD-{ant_id}")


def _check_asir_cell_status(oam_ip, virtual_display, id_list, expected_status):
    selenium_obj = AsirSelenium(virtual_enable=virtual_display)
    selenium_obj.clean_browser()
    selenium_obj.login(url=f'https://{oam_ip}:3601')
    selenium_obj.check_asir_cell_status(cell_type="BTS", id_list=id_list, expected_status=expected_status)
    selenium_obj.clean_browser()
