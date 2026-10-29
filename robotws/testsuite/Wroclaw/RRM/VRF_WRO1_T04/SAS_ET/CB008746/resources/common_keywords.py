"""
:copyright: Nokia Networks
:author: Agata Sidlo
:contact: agata.sidlo@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
from robot.libraries.BuiltIn import BuiltIn

from ta5g_ue_mobility import ta5g_ue_mobility

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.slice_scheduling.var_preparation \
    import get_spid_values_from_delta
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import *
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_wts import \
    attach_ue_to_plmn_and_perform_sgnb_addition
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.slice_scheduling.suite import \
    copy_files_from_local_to_local


class NoProperSetupDetectedException(Exception):
    pass


class DifferentNumberOfUesAndPlmnValuesException(Exception):
    pass


def prepare_check_spids_dict(prev_delta):
    spid_without_ues = BuiltIn().get_variable_value('${SPIDS_OBJ_WITHOUT_UES}')
    set_spid_dict = BuiltIn().get_variable_value('${CFG_SPID_RANGE_DICT}')
    prev_spid = get_spid_values_from_delta(prev_delta)
    temp = set_spid_dict.copy()
    for spid in prev_spid.keys():
        if spid not in spid_without_ues:
            try:
                del temp[spid]
            except KeyError:
                pass
    BuiltIn().set_suite_variable('${CFG_SPID_RANGE_DICT}', temp)


def perform_delta_recomissioning(delta_file, full_path=False, **kwargs):
    if not full_path:
        copy_files_from_local_to_local(os.path.join(CURDIR, 'configs/{}'.format(delta_file)),
                                       BuiltIn().get_variable_value('${OUTPUT_DIR}'))
        delta_file = '{}/{}'.format(BuiltIn().get_variable_value('${OUTPUT_DIR}'), delta_file)
    set_mrbts_nrbts_ids_on_delta(delta_file)
    set_cell_ids_on_delta(delta_file=delta_file)
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(kwargs)
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()
    perform_recomissioning_with_delta(delta_file)
    wait_for_delta_recommissioning()


def wait_for_delta_recommissioning():
    time.sleep(120)


def set_variables_based_on_deployment_and_release(test_cell_tech=None):
    fbb_info = get_fbb_info()
    cells_info = get_cells_info()
    unit_name = get_capability_unit_name()
    release = get_gnb_build_release(convert_to_trunk=True)
    build = get_gnb_build(convert_to_trunk=True)
    deltas = BuiltIn().get_variable_value('${DELTAS}')
    wts_cfg = BuiltIn().get_variable_value('${WTS_CONFIGS}')
    ue_ip = BuiltIn().get_variable_value('${UE_IP_DL}')
    plmns = BuiltIn().get_variable_value('${PLMN_PER_RESOURCE_GROUP}')
    cell_tech, cell_id, cell_id_inc = get_cell_tech_for_variables_setup(cells_info=cells_info, unit_name=unit_name,
                                                                        test_cell_tech=test_cell_tech)
    mrbts, nrbts = get_mrbts_nrbts_ids()
    tput_margin = BuiltIn().get_variable_value('${COUNTER_TPUT_MARGIN}')
    cell_grp_ids = [0] if 'ASIB' in unit_name and '0' in cell_id else [0, 1]
    cell_1_pci = __get_pci_from_cell_number(cells_info, cell_id)
    cell_2_pci = __get_pci_from_cell_number(cells_info, cell_id_inc)

    sib_dict = {2: [cell_id, cell_id_inc]}
    BuiltIn().set_suite_variable("${SIB_RECEPTION_DICT_SA_SANSA}", sib_dict)

    BuiltIn().set_suite_variable('${UNIT_NAME}', unit_name)
    BuiltIn().set_suite_variable('${FBB_INFO}', fbb_info)
    BuiltIn().set_suite_variable('${RELEASE}', release)
    BuiltIn().set_suite_variable('${SW_VERSION}', build)
    BuiltIn().set_suite_variable("${CELL_TECHNOLOGY}", cell_tech)
    BuiltIn().set_suite_variable("${CELL_1_ID}", cell_id)
    BuiltIn().set_suite_variable("${CELL_2_ID}", cell_id_inc)
    BuiltIn().set_suite_variable("${CELL_1_PCI}", cell_1_pci)
    BuiltIn().set_suite_variable("${CELL_2_PCI}", cell_2_pci)
    BuiltIn().set_suite_variable("${CELLS_PCI}", [cell_1_pci, cell_2_pci])
    BuiltIn().set_suite_variable('${MAX_TPUT}', '550m' if 'TDD' in cell_tech else '135m')
    BuiltIn().set_suite_variable('${MAX_INTERNAL_TPUT}', '175' if 'TDD' in cell_tech else '150')
    BuiltIn().set_suite_variable('${MAX_TPUT_VAL}', '550' if 'TDD' in cell_tech else '135')
    BuiltIn().set_suite_variable('${MAX_TPUT_PLMNS}', '500m')
    BuiltIn().set_suite_variable('${UE_IP_DL_1}', ue_ip[cell_tech][0])
    BuiltIn().set_suite_variable('${UE_IP_DL_2}', ue_ip[cell_tech][1])
    BuiltIn().set_suite_variable('${UE_IP_DL_3}', ue_ip[cell_tech][2])
    BuiltIn().set_suite_variable('${UE_IP_DL_4}', ue_ip[cell_tech][3])
    BuiltIn().set_suite_variable('${MRBTS_ID}', mrbts)
    BuiltIn().set_suite_variable('${NRBTS_ID}', nrbts)
    BuiltIn().set_suite_variable('${CELL_ID_VALIDATION_LIST_TO_GRP_IDS}', cell_grp_ids)
    BuiltIn().set_suite_variable('${CELL_WITH_ACTIVATED_FEATURE}', cell_id)
    BuiltIn().set_suite_variable('${CELL_WITH_ACTIVATED_FEATURE_INCREASED}', cell_id_inc)


def get_cell_tech_for_variables_setup(cells_info, unit_name, test_cell_tech=None):
    tdd_count = check_if_any_cell_is_tech(cells_info, 'TDD')
    fdd_count = check_if_any_cell_is_tech(cells_info, 'FDD')

    if 'ASIB' in unit_name and fdd_count == 4 and tdd_count == 2:
        logger_console('Assuming BOO_AP_KLLL setup with 4 FDD cells and two TDD')
        return 'FDD', '1', '2'
    elif 'ASIB' in unit_name and fdd_count == 1:
        logger_console('Assuming BL_AP_KL setup with one cell FDD')
        return 'FDD', '1', '2'
    elif 'ASIB' in unit_name and fdd_count == 2:
        logger_console('Assuming BO_AP_KL setup with two cells FDD')
        return 'FDD', '1', '2'
    elif 'ASIB' in unit_name and fdd_count in (6, 3) and tdd_count == 0:
        logger_console('Assuming BOO_AP_KLLL setup')
        return 'FDD', '1', '2'
    elif 'ASIL' in unit_name and tdd_count == 2 and fdd_count == 2:
        if test_cell_tech == 'FDD':
            logger_console("Assuming LO_AP_LO setup with two cells FDD")
            return "FDD", '3', '4'
        if test_cell_tech == 'TDD':
            logger_console("Assuming LO_AP_LO setup with two cells TDD")
            return "TDD", '1', '2'
    elif 'ASIL' in unit_name and tdd_count == 2:
        logger_console('Assuming LO_AP_LO setup with two cells TDD')
        return 'TDD', '1', '2'
    elif 'ASIL' in unit_name and fdd_count == 2:
        logger_console('Assuming LO_AP_LO setup with two cells FDD')
        return 'FDD', '1', '2'
    elif 'ASIL' in unit_name and (tdd_count == 0 and fdd_count == 3):
        logger_console("Assuming LO_AP_LOOO setup with three cells FDD")
        return "FDD", '1', '2'
    elif 'ASIM' in unit_name and tdd_count == 2:
        logger_console('Assuming MP_AP_LO setup with two cells TDD')
        return 'TDD', '0', '1'

    msg = 'No setup information!'
    logger_warning(msg)
    raise NoProperSetupDetectedException(msg)


def check_if_any_cell_is_tech(cells, tech):
    num_cells_with_tech = sum([1 for cell in cells if tech in cell['technology']])
    logger_console('Count of {} cells: {}'.format(tech, num_cells_with_tech))
    return num_cells_with_tech


def set_variables_based_on_tc(tc=None, additional=None):
    tcs, apx = __parse_tc_name_and_retrieve_crucial_info(BuiltIn().get_variable_value('${TEST_ID}'))
    tcs_add, apx_add = __parse_tc_name_and_retrieve_crucial_info(additional)
    tcs.update(tcs_add)

    BuiltIn().set_suite_variable('${RUNNING_TESTCASES}', tcs)
    BuiltIn().set_suite_variable('${RUNNING_TESTCASES_APPENDIX}', apx)
    BuiltIn().set_suite_variable('${UE_INFO.11.CELL_ID}', '${CELL_WITH_ACTIVATED_FEATURE_INCREASED}')
    BuiltIn().set_test_variable('${TEST_ID}', tc)
    BuiltIn().set_test_variable('${OUTPUT_DIR_TC}', '{}/{}'.format(BuiltIn().get_variable_value('${OUTPUT_DIR}'),
                                                                   BuiltIn().get_variable_value('${TEST_ID}')))

    __print_set_variables_based_on_tc()


def __print_set_variables_based_on_tc():
    logger_console(
        'Running Testcases: {}\n'.format(BuiltIn().get_variable_value('${RUNNING_TESTCASES}')) +
        'Cell with Slices: {}\n'.format(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}')) +
        'Cell with Slices Inc: {}\n'.format(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE_INCREASED}'))
    )


def set_variables_for_bip_validation(delta_setup):
    BuiltIn().set_suite_variable('${QUOTAS}', delta_setup['bip_quotas'])
    BuiltIn().set_suite_variable('${SPID_SLICING_ACTIVATED}', delta_setup['spid_slicing_activated'])
    BuiltIn().set_suite_variable('${DEFAULT_RESOURCE_GROUP_IDS}', delta_setup['default_resource_group_ids'])
    BuiltIn().set_suite_variable('${RESOURCE_GROUP_IDS}', delta_setup['resource_group_ids'])
    BuiltIn().set_suite_variable('${PLMNS}', delta_setup['plmns'])


def __parse_tc_name_and_retrieve_crucial_info(tc_name):
    tcs = {}
    appendix = ''
    if tc_name is None:
        return tcs, appendix
    if 'A_B601_OAM_TDD' in tc_name:
        tcs['A_B601_OAM_TDD'] = 'failed'
    if 'A_B601_OAM_FDD' in tc_name:
        tcs['A_B601_OAM_FDD'] = 'failed'
    if 'A_B601_CELLSETUPREQ_TDD' in tc_name:
        tcs['A_B601_CELLSETUPREQ_TDD'] = 'failed'
    if 'A_B601_CELLSETUPREQ_FDD' in tc_name:
        tcs['A_B601_CELLSETUPREQ_FDD'] = 'failed'
    if 'A_B105_NSA_Slicing_Ues_with_unknown_SPID_FDD' in tc_name:
        tcs['A_B105_unknown_SPID_FDD'] = 'failed'
    if 'check_qoutas_for_NSA_only_TDD' in tc_name:
        tcs['A_B105_CHECK_QUOTAS_TDD'] = 'failed'
    if 'check_qoutas_for_NSA_only_FDD' in tc_name:
        tcs['A_B105_CHECK_QUOTAS_FDD'] = 'failed'
    if '_verification_NSA_32_slices_TDD' in tc_name:
        tcs['A_B105_32_SLICES_FDD'] = 'failed'
    if 'A_B107_NRPMQAP_per_SPID_counters_TDD' in tc_name:
        tcs['A_B107_NRPMQAP_SPID_TDD'] = 'failed'
    if 'A_B107_NRPMQAP_per_SPID_counters_FDD' in tc_name:
        tcs['A_B107_NRPMQAP_SPID_FDD'] = 'failed'
    if 'NRPMQAP_spidRange_modification_TDD' in tc_name:
        tcs['A_B108_TDD'] = 'failed'
    if 'NRPMQAP_spidRange_modification_FDD' in tc_name:
        tcs['A_B108_FDD'] = 'failed'
    if 'with_default_value_FDD' in tc_name:
        tcs['A_B108_default_FDD'] = 'failed'
    if 'A_B401_SPID' in tc_name:
        tcs['A_B401_SPID_FDD'] = 'failed'
    if 'deactivation_for_NSA_only_FDD' in tc_name:
        tcs['A_B401_SPID_TDD'] = 'failed'
    if 'for_NSA_+_SA_TDD' in tc_name:
        tcs['A_B301_NSA_SA_TDD'] = 'failed'
    if 'for_NSA_+_SA_FDD' in tc_name:
        tcs['A_B301_NSA_SA_FDD'] = 'failed'
    if 'modification_NSA_+_SA_TDD' in tc_name:
        tcs['A_B301_NSA_SA_MODY_TDD'] = 'failed'
    if 'modification_NSA_+_SA_FDD' in tc_name:
        tcs['A_B301_NSA_SA_MODY_FDD'] = 'failed'
    return tcs, appendix


def attach_multiple_ues_to_plmns_and_perform_sgnb_addition(number_of_ues, selected_plmn):
    number_of_ues = int(number_of_ues)
    if not isinstance(selected_plmn, list) or number_of_ues != len(selected_plmn):
        raise DifferentNumberOfUesAndPlmnValuesException(f'Different number of ues: {number_of_ues} than PLMN list'
                                                         f'length: {len(selected_plmn)}')
    ta5g_ue_mobility().setup_x2_link()
    wait_for_requested_bts_state('onair')
    for ue in range(11, 11 + number_of_ues):
        attach_ue_to_plmn_and_perform_sgnb_addition(ue_id=ue, selected_plmn=selected_plmn[ue - 11],
                                                    serving_plmn=selected_plmn[ue - 11])


def set_bearers_for_many_ues(nr_ues):
    bearers = [2 for ue in nr_ues]
    BuiltIn().set_suite_variable('${BEARERS}', bearers)


def set_nsa_ues_ids(nr_ues, first_ue_id=11):
    if isinstance(nr_ues, list):
        ue_ids = nr_ues
    else:
        ue_ids = [ue + first_ue_id for ue in range(int(nr_ues))]
    BuiltIn().set_suite_variable('${UE_IDS}', ue_ids)


def wait_for_ng_logs_to_be_collected():
    sleep(30)


def wait_for_tput_stabilization():
    sleep(5)


def wait_for_counters_to_update():
    sleep(600)


def __get_pci_from_cell_number(cell_info, cell_number):
    for single_cell_info in cell_info:
        if single_cell_info['globalCellId'] == int(cell_number):
            return single_cell_info['physicalCellId']
    raise ValueError('No cell with number {} in cell info!'.format(cell_number))


def calculate_wts_pci(pci):
    first_part = pci // 3
    second_part = pci % 3
    return '{}:{}'.format(first_part, second_part)


def set_cell_ids_on_delta(delta_file):
    cell_1_id = BuiltIn().get_variable_value('${CELL_1_ID}')
    cell_2_id = BuiltIn().get_variable_value('${CELL_2_ID}')
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(nrcell_ID1=cell_1_id, nrcell_ID2=cell_2_id)
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()


def get_latest_file_with_counters():
    counters_list = BuiltIn().get_variable_value("${COUNTER_DIRECTORY_LIST}", [])
    return counters_list[-1]
