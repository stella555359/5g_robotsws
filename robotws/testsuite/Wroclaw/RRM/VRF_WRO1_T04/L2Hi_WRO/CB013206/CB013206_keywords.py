# -*- coding: utf-8 -*-


from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger

LOCAL_MOID_BTS_CELL1 = 'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1'
LOCAL_MOID_BTS_CELL2 = 'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2'
LOCAL_MOID_BTS = 'PLMN-PLMN/MRBTS-1/NRBTS-1'


def check_if_cell_and_pmqap_has_expected_value(counters_id_list, expected_value, local_moid=LOCAL_MOID_BTS_CELL1):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    pm_counters = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    counters_ids = counters_id_list
    logger.console(type(counters_ids))
    logger.console(counters_ids)
    ta5g_pm.verify_multiple_counters_value(counters_ids, expected_value, local_moid, pm_counters)
