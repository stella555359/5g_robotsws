from testsuite.Krakow.SISO.regression.RAN_PZ_KRK4.CB010348.resources.variables import CABLINK_DN_AWKUC_AH241904043
from testsuite.Krakow.resources.RAN_PZ_KRK4.delta_generator import generate_base_delta


def generate_cablink_delta(param_name, value, operation='update', *cablink_dist_names):
    """
    Generates a list of delta dictionaries for specified cablink dist names.

    Args:
        param_name (str): The name of the parameter to be updated.
        value (str or list): The value of the parameter. Can be a string or a list.
        operation (str, optional): The operation to be performed. Defaults to 'update'.
        *cablink_dist_names: Variable length argument list of cablink dist names.

    Returns:
        list: A list of dictionaries representing the deltas for the specified cablink dist names.
    """
    deltas = []
    for cablink_dn in cablink_dist_names:
        deltas.append(generate_base_delta(cablink_dn, param_name, value, operation))
    return deltas


DELTA_ETHERNET_MODES = {
    'eCpri25': [
        *generate_cablink_delta("linkSpeed", "eCpri25", "update", *CABLINK_DN_AWKUC_AH241904043),
        *generate_cablink_delta("radioProtocolType", "eCPRI", "update", *CABLINK_DN_AWKUC_AH241904043),
    ],
    'eCpri10': [
        *generate_cablink_delta("linkSpeed", "eCpri10", "update", *CABLINK_DN_AWKUC_AH241904043),
        *generate_cablink_delta("radioProtocolType", "eCPRI", "update", *CABLINK_DN_AWKUC_AH241904043),
    ],
}

DELTA_DEFAULT_ETHERNET_MODE = {
    'eCpri50': [
        *generate_cablink_delta("linkSpeed", "eCpri50", "update", *CABLINK_DN_AWKUC_AH241904043),
        *generate_cablink_delta("radioProtocolType", "eCPRI", "update", *CABLINK_DN_AWKUC_AH241904043),
    ]
}
