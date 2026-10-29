# -*- coding: utf-8 -*-
"""
Author: Przemyslaw Kusa, przemyslaw.kusa@nokia.com
Maintainer: Przemyslaw Kusa, przemyslaw.kusa@nokia.com
"""


def compareValue(dn, dn_param, param_value):
    """
    Compare parameter value obtained from scf file with parameters set by user

    :param dn: parameters related to class name obtained from scf file
    :param dn_param: name of distName parameter (e.g. mcc)
    :param param_value: value of parameter (e.g. 1)
    :return bool: Flag if parameter set by user is matching with scf parameter
    """
    value_param = dn[0]["params"].get(dn_param, None)
    if value_param is None:
        raise ValueError(f"{dn_param} not found in given parameters")
    values_from_dn = f"{dn_param} : {value_param}"
    param_to_compare = f"{dn_param} : {param_value}"

    return values_from_dn == param_to_compare
