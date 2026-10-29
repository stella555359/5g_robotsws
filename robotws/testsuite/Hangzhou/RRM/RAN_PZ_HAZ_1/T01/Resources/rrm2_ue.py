from __future__ import absolute_import
from __future__ import print_function
from ute_common_abstract_core.aliases_registry import aliases_registry, release_aliases


def _access_get_info(ue_alias, info_type, timeout=None):
    ue = aliases_registry()[ue_alias]
    result = ue.get_info(info_type, timeout)
    print("Ue %s has info %s = %s" % (ue_alias, info_type, result))
    return result


def ue_show_basic_info(ue_alias):
    _access_get_info(ue_alias, "MCC")
    _access_get_info(ue_alias, "MNC")
    _access_get_info(ue_alias, "IP")
    _access_get_info(ue_alias, "CELL_ID")
    _access_get_info(ue_alias, "SIGNAL_STRENGTH")
    _access_get_info(ue_alias, "PCI")
    _access_get_info(ue_alias, "UE_OS_VER")
    _access_get_info(ue_alias, "DEVICE_MODEL")
