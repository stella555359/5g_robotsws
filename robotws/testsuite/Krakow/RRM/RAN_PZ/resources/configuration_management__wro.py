from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from taf.gnb.oam.coam.admin import admin


def get_library_instance(library):
    instance = BuiltIn().get_library_instance(library)
    if not instance:
        raise ImportError("Unable to access %s instance, check if library is imported" % instance)
    return instance


def is_cell_parameter_value_equal_to(physcellid, name, value):
    """
    Check if the value of the parameter has the given value.

    :param physcellid: str: Physical Cell Id
    :param name: str: Abbreviation of parameter
    :param value: str: Expected value of the parameter
    :return: bool: True or False
    """
    admin_cli = get_library_instance('coam')
    cells_info = admin_cli.get_managed_objects(class_name='NRCELL_A')
    for cell_info in cells_info:
        if str(cell_info["parameters"]['physCellId']) == str(physcellid):
            return str(cell_info["parameters"][name]).lower() == str(value).lower()
    raise BaseException("There is no cell with given physical cell id")


def is_mimo_set_up(physical_cell_id, mimo_param, value):
    return is_cell_parameter_value_equal_to(physical_cell_id, mimo_param, value)


def set_mimo_parameters(physical_cell_id, mimo_param, value):
    update_nrcell_parameter(physical_cell_id, mimo_param, value)


def configure_mimo(physical_cell_id, stream, mode):
    mimo_param = get_mimo_param(stream)
    if not is_mimo_set_up(physical_cell_id, mimo_param, mode):
        set_mimo_parameters(physical_cell_id, mimo_param, mode)


def is_mcs_configured(physical_cell_id, mcs_param, value):
    return is_cell_parameter_value_equal_to(physical_cell_id, mcs_param, value)


def set_mcs_parameters(physical_cell_id, mcs_param, value):
    update_nrcell_parameter(physical_cell_id, mcs_param, value)


def configure_mcs(physical_cell_id, stream, value):
    mcs_param = get_mcs_param(stream)
    if not is_mcs_configured(physical_cell_id, mcs_param, value):
        set_mcs_parameters(physical_cell_id, mcs_param, value)


def is_modulation_configure():
    raise NotImplementedError("We don't know which parameters we should set")


def set_modulation_parameters():
    raise NotImplementedError


def configure_modulation():
    if not is_modulation_configure():
        set_modulation_parameters()


def is_bandwidth_configure(value):
    admin_cli = get_library_instance('coam')
    bw_info = admin_cli.get_managed_objects(class_name='NRCELL_FDD_A')
    for cell_bw_info in bw_info:
        if not(str(cell_bw_info["parameters"]['chBwDl']).lower() == str(value).lower() and
               str(cell_bw_info["parameters"]['chBwUl']).lower() == str(value).lower()):
            return False
    return True


def set_bandwidth_parameters(physical_cell_id, value):
    delta_store = get_library_instance('delta_store')
    coreset_index = {'5MHz': '0', '10MHz': '6', '15MHz': '6', '20MHz': '6'}
    physical_cell_id = int(physical_cell_id)
    for iter_cell_id in [physical_cell_id]:
        iter_cell_id = str(iter_cell_id)
        dist_name = get_dist_name_nrcell(iter_cell_id)
        dist_name = dist_name + '/NRCELL_FDD-1'
        update_nrcell_parameter(iter_cell_id, 'type0CoresetConfigurationIndex', coreset_index[value])
        delta_store.add_param_to_delta(dist_name, 'chBwDl', value)
        delta_store.add_param_to_delta(dist_name, 'chBwUl', value)


def configure_bandwidth(physical_cell_id, value):
    if not is_bandwidth_configure(value):
        set_bandwidth_parameters(physical_cell_id, value)


def update_nrcell_parameter(physical_cell_id, param_name, value):
    """
    This Keyword is used to update the Cell Parameter by using delta commissioning.

    :param physical_cell_id: str, cell id of the configured cell.
    :param param_name: str, name of the parameter.
    :param value: str, value of the parameter.
    :recommission: bool, value to see if recommission will be done.
    """

    dist_name = get_dist_name_nrcell(physical_cell_id)
    delta_store = get_library_instance('delta_store')
    delta_store.add_param_to_delta(dist_name, param_name, value)
    return


def get_dist_name_nrcell(physical_cell_id):
    """
    This Keyword returns the dist_name of the NRCell.

    :param physical_cell_id: str, cell id of the cell.
    """
    mrbts_id = get_mrbts_id()
    nrbts_id = get_nrbts_id()
    nr_cell_id = get_nrcell_id_for_physical_id(physical_cell_id)
    return "/".join([mrbts_id, nrbts_id, nr_cell_id])


def verify_all_cells_are_onAir_with_Admin_CLI():
    """
    This Keyword confirms all cells configured are onAir with Admin CLI
    """
    expected_cell_state = {'operationalState': 'Enabled', 'proceduralStatus': 'configured',
                           'blockingState': 'Unblocked', 'availabilityStatus': 'Online',
                           'administrativeState': 'Unlocked', 'usageState': 'Active'}
    expected_bts_status = {'operationalState': 'Enabled', 'proceduralState': 'OnAir', 'blockingState': 'Unblocked'}
    admin_cli = BuiltIn().get_library_instance('coam')
    cells_info = admin_cli.get_cells_info(cell_type='nr', timeout=30)
    for cell in cells_info:
        if cell['status'] != expected_cell_state:
            raise Exception("The cell status is not as expected. Current cell status : %s "
                            "and Expected Cell Status : %s" % (cell['status'], expected_cell_state))
    bts_status = admin_cli.get_bts_statuses(timeout=30)
    if bts_status != expected_bts_status:
        raise Exception("The BTS status is not as expected. Current BTS status : %s and Expected BTS status : %s" %
                        (bts_status, expected_bts_status))


def get_mrbts_id():
    """
    This Keyword returns the mrbts_id of the BTS.
    """
    admin_cli = get_library_instance('coam')
    return "".join(["MRBTS", "-", str(admin_cli.get_bts_info()['mrbtsID'])])


def get_nrbts_id():
    """
    This Keyword returns the nrbts_id of the BTS.
    """
    admin_cli = get_library_instance('coam')
    nrbts = admin_cli.get_managed_objects('NRBTS_A')
    return nrbts[0]['distName'].split('/')[-1].replace("_A", "")


def get_nrcell_id(cell_id):
    """
    This Keyword returns the NRCell Id string
    """
    return "".join(["NRCELL", "-", str(cell_id)])


def get_nrcell_id_for_physical_id(physical_cell_id):
    """
    This Keyword returns the Cell Id for the physical Cell Id.
    """
    admin_cli = get_library_instance('coam')
    cells_info = admin_cli.get_managed_objects(class_name='NRCELL_A')
    for cell_index, cell_info in enumerate(cells_info, 1):
        if str(cell_info["parameters"]['physCellId']) == str(physical_cell_id):
            return cell_info['distName'].split('/')[-1].replace("_A", "")

    raise AssertionError("No Cell Found for given physical cell id: %s" % (physical_cell_id, ))


def configure_srb3support_parameter(value):
    param_name = "srb3SupportEnabled"
    if not is_srb3support(param_name, value):
        set_srb3support_parameter(param_name, value)


def is_srb3support(param_name, value):
    return is_nrbts_parameter_equal_to(param_name, value)


def set_srb3support_parameter(param_name, value):
    update_nrbts_parameter(param_name, value)


def configure_256qam_parameter(physical_cell_id, value):
    qam_parameter = "actDl256Qam"
    if not is_256qam(physical_cell_id, qam_parameter, value):
        set_256qam_parameters(physical_cell_id, qam_parameter, value)


def is_256qam(physical_cell_id, param_name, value):
    return is_cell_parameter_value_equal_to(physical_cell_id, param_name, value)


def set_256qam_parameters(physical_cell_id, param_name, value):
    update_nrcell_parameter(physical_cell_id, param_name, value)
    return


def configure_general_connectivity_silver(value):
    param_name = "actGeneralConnectivitySilver"
    if not is_general_connectivity_silver(param_name, value):
        set_general_connectivity_silver(param_name, value)


def is_general_connectivity_silver(param_name, value):
    return is_nrbts_parameter_equal_to(param_name, value)


def set_general_connectivity_silver(param_name, value):
    update_nrbts_parameter(param_name, value)


def is_nrbts_parameter_equal_to(param_name, value):
    admin_cli = get_library_instance('coam')
    nrbts = admin_cli.get_managed_objects(class_name='NRBTS_A')[0]
    return str(nrbts['parameters'][param_name]).lower() == str(value).lower()


def update_nrbts_parameter(param_name, value):
    mrbts_id = get_mrbts_id()
    nrbts_id = get_nrbts_id()
    dist_name = "/".join([mrbts_id, nrbts_id])
    delta_store = get_library_instance('delta_store')
    delta_store.add_param_to_delta(dist_name, param_name, value)
    return


def get_mcs_param(stream):
    valid_stream_values = ['uplink', 'downlink']
    stream_mcs_mapping = {'uplink': 'ullaIniMcs', 'downlink': 'dllaIniMcs'}
    assert stream in valid_stream_values, 'Stream %s not valid should be %s' % (stream, valid_stream_values)
    return stream_mcs_mapping[stream]


def get_mimo_param(stream):
    valid_stream_values = ['uplink', 'downlink']
    stream_mimo_mapping = {'uplink': 'ulMimoMode', 'downlink': 'dlMimoMode'}
    assert stream in valid_stream_values, 'Stream %s not valid should be %s' % (stream, valid_stream_values)
    return stream_mimo_mapping[stream]


def configure_nrcell_type(physical_cell_id, value):
    param_name = "nrCellType"
    if not is_nrcell_type(physical_cell_id, param_name, value):
        set_nrcell_type_parameters(physical_cell_id, param_name, value)


def is_nrcell_type(physical_cell_id, param_name, value):
    return is_cell_parameter_value_equal_to(physical_cell_id, param_name, value)


def set_nrcell_type_parameters(physical_cell_id, param_name, value):
    update_nrcell_parameter(physical_cell_id, param_name, value)
    return


def get_vlan_id_for_x2cplane(library_instance='coam'):
    """
    Get vlan id for x2cplane interface for IPv6, if not exist try it for IPv4.
    :param library_instance: str: Used name for the imported taf.gnb.oam.coam.admin
    :return: str: vlan id for x2cplane
    """
    admin_cli = get_library_instance(library_instance)
    nrbts = admin_cli.get_managed_objects(class_name='NRBTS_A')
    x2cplane_dn = nrbts[0]['parameters']['x2Cplane'][0]['ipV6AddressDN1']
    if x2cplane_dn:
        return _return_vlan_id_base_on_x2cplane_dn(x2cplane_dn, admin_cli)
    else:
        x2cplane_dn = nrbts[0]['parameters']['x2Cplane'][0]['ipV4AddressDN1']
        return _return_vlan_id_base_on_x2cplane_dn(x2cplane_dn, admin_cli)


def _return_vlan_id_base_on_x2cplane_dn(x2cplane_dist_name, admin_inst):
    """
    Return vlan id for a interface base on the given x2cplane dist name.
    :param x2cplane_dist_name: str: Dist name for x2cplane.
    :param admin_inst: str: Admin cli instance.
    :return: str: vlan id for x2cplane
    """
    ipif_dist_name = '/'.join(x2cplane_dist_name.split('/')[:-1])
    ipif_parameters = admin_inst.get_parameters(dist_name=ipif_dist_name)
    vlan_interface_dn = ipif_parameters['interfaceDN']
    try:
        return '.' + str(admin_inst.get_parameters(dist_name=vlan_interface_dn)['vlanId'])
    except KeyError:
        return ''


def verify_attach_success_rate_from_one_to_amounts_of_loops(results, expected_amount):
    """
    Count how many attach were successful and print the result.
    :param results: list: List with true of false values.
    :param expected_amount: str: Expected amount of attaches.
    """
    if len(results) != int(expected_amount):
        raise Exception("Not went through all!")
    else:
        if not all(results):
            raise Exception('Attach success rate: {}/{}'.format(sum(results), expected_amount))


def verify_attach_procedure(result):
    """
    Verify attach was successful.
    :param results: boolean: true or false value.
    """
    if not result:
        raise Exception("Not went through all!")
