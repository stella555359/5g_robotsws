from robot.api.logger import console
import os


def get_valid_gNodeBId(bts_id):
    """
    Creating neighbor BTS ID for NRADJGNB.gNodeBId parameter, which must be different from BTS testline ID
    :param: bts_id: Existing BTS ID
    :return: Changed BTS ID
    """
    return int(bts_id) - 1


def get_list_of_params_for_nrx2link_trust_object(ipv4_address, object_id):
    """
    Getting list of parameters required to create NRX2LINK_TRUST object. For object up to 256
    NRX2LINK_TRUST.x2LinkTrustCtrl parameter must be set to oamControlled, for object higher than 256
    NRX2LINK_TRUST.x2LinkTrustCtrl parameter must be set to gnbControlled.
    :param: ipv4_address: IPv4 address of new NRX2LINK_TRUST object
    :param: object_id: ID of new NRX2LINK_TRUST object
    :return: List of parameters and their values used to create NRX2LINK_TRUST object, in dictionary form
    """
    x2LinkTrustCtrl = 'oamControlled'
    if int(object_id) > 256:
        x2LinkTrustCtrl = 'gnbControlled'

    parameter = [
        {"parameterName": "ipV4Addr", "operation": "update", "value": ipv4_address},
        {"parameterName": "nrX2LinkTrustId", "operation": "update", "value": object_id},
        {"parameterName": "x2LinkTrustCtrl", "operation": "update", "value": x2LinkTrustCtrl}
    ]
    return parameter


def get_list_of_params_for_modified_nrx2link_trust_object(ipv4_address):
    """
    Getting list of parameters required to modify NRX2LINK_TRUST object.
    :param: ipv4_address: IPv4 address used to modify NRX2LINK_TRUST object
    :return: List of parameters and their values used to modify NRX2LINK_TRUST object, in dictionary form
    """
    parameter = [
        {"parameterName": "ipV4Addr", "operation": "update", "value": ipv4_address}
    ]
    return parameter


def get_list_of_params_for_nradjgnb_object(xnlink_ref_id, bts_id):
    """
    Getting list of parameters required to create NRADJGNB object.
    :param: xnlink_ref_id: ID of connected XNLINK object
    :param: bts_id: ID of real BTS. gNodeBId parameter requires BTS ID different from real BTS.
    To be sure that ID is different, real BTS ID is modified by get_valid_gNodeBId method
    :return: List of parameters and their values used to create NRADJGNB object, in dictionary form
    """
    parameter = [
        {"parameterName": "administrativeState", "operation": "update", "value": "Unlocked"},
        {"parameterName": "gNbIdLength", "operation": "update", "value": 22},
        {"parameterName": "gNodeBId", "operation": "update", "value": get_valid_gNodeBId(bts_id)},
        {"parameterName": "gNodeBIdCtrl", "operation": "update", "value": "oamControlled"},
        {"parameterName": "gnbPlmn", "operation": "update", "value": [
            {
                "mcc": 244,
                "mnc": 8,
                "mncLength": 2
            }]},
        {"parameterName": "xnLinkRef", "operation": "update", "value": xnlink_ref_id}
    ]
    return parameter


def get_list_of_params_for_xnlink_object(ipv4_address, object_id, is_actTrsSepaSARanSharing='false'):
    """
    Getting list of parameters required to create XNLINK object. If actTrsSepaSARanSharing is set to true, xnTnlId
    mut be set. If actTrsSepaSARanSharing is set to false, xnTnlId must NOT be set.
    :param: ipv4_address: IPv4 address of new XNLINK object
    :param: object_id: ID of new XNLINK object
    :param: is_actTrsSepaSARanSharing: if true, XNLINK object must be created with xnTnlId configured,
                                       if false, XNLINK object must be created with xnTnlId NOT configured
    :return: List of parameters and their values used to create XNLINK object, in dictionary form
    """
    if is_actTrsSepaSARanSharing.lower() == 'true':
        parameter = [
            {"parameterName": "cPlaneIpAddr", "operation": "update", "value": ipv4_address},
            {"parameterName": "cPlaneIpAddrCtrl", "operation": "update", "value": "oamControlled"},
            {"parameterName": "xnLinkId", "operation": "update", "value": object_id},
            {"parameterName": "xnTnlId", "operation": "update", "value": "1"}
        ]
    else:
        parameter = [
            {"parameterName": "cPlaneIpAddr", "operation": "update", "value": ipv4_address},
            {"parameterName": "cPlaneIpAddrCtrl", "operation": "update", "value": "oamControlled"},
            {"parameterName": "xnLinkId", "operation": "update", "value": object_id}
        ]
    return parameter


def create_id_list_of_new_objects(list_of_existing_ids):
    """
    Creating list of IDs used to create max amount of NRX2LINK_TRUST objects.
    :param: list_of_existing_ids: ID list of existing NRX2LINK_TRUST objects
    :return: ID list of not existing NRX2LINK_TRUST objects
    """
    list_of_new_objects = []
    for object_id in range(1, 513):
        if object_id not in list_of_existing_ids:
            list_of_new_objects.append(object_id)
    return list_of_new_objects


def modify_ipv4_address(ipv4):
    return ".".join(ipv4.split(".")[:3] + [str(int(ipv4.split(".")[-1])-2)])


def modify_ipv6_address(ipv6):
    hexets = ipv6.split(":")
    hexets[-1] = str(hex(int(hexets[-1], 16) - 1)[2:])
    return ":".join(hexets)


def check_if_ruleset_contains_address(path: str, address: str, should_be_in: bool) -> bool:
    container = list()
    with open(path, 'r') as nft:
        output = nft.readlines()
        for line in output:
            if address in line:
                container += line

    if should_be_in and container:
        return True

    if not should_be_in and not container:
        return False

    assert False, """
 =================================================================
 Addresses neither should be in output or are missing from output
 =================================================================
 """
