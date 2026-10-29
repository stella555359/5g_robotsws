from taf.sbts.oam.coam.admin import admin
from moler.util.moler_test import MolerTest


def get_param_value_by_asirmod_id(param, asirmod_id, oam_ip='192.168.255.129', connection=None):
    """
    Main Function:
      Get Parameter value by asirmod id

    Arguments:
      :param param: parameter name
      :param param: asirmod_id

    Return Value:
        parameter value

    Example:
        | $value | get_param_value_by_asirmod_id | param=configuredSplitModePrrhCount | asirmod_id=2 |

    Version:
        | Author | Version | Delivery Date | Comments |
        | Zhao Longmei | 1.0.0 | 2022/08/12 | First approved version by VA |
    """

    adm = admin()

    try:
        if not connection:
            adm.setup_admin(bts_host=oam_ip)
        managed_objects = adm.get_managed_objects('ASIRMOD_R', 10)
        for objects in managed_objects:
            if asirmod_id == objects['parameters']['configDN'].split('-')[-1]:
                dist_name = objects['distName']
        param_value = adm.get_parameters(dist_name, param)
        return str(param_value[param])
    except Exception as e:
        MolerTest.error(str(e))
    finally:
        if not connection:
            adm.teardown_admin()
