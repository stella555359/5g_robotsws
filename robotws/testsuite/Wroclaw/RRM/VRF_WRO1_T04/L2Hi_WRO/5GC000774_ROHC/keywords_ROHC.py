from __future__ import division
from builtins import object
from past.utils import old_div
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from ute_wtssim import *

LOCAL_MOID_CELL_1 = "DN:NE-LNBTS-1/LNCEL-1/MCC-244/MNC-09"
pdcp_sn_length_15bit = 32768
pdcp_sn_length_18bit = 262144

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def perform_intracell_handover_with_nr_sec_cap_defined_and_wait_for_confirmation(ue_id, nr_sec_cap, timeout=5):
    # :param ue_id:
    # :param timeout:
    logger.console("Performing intracell handover for UE {}".format(ue_id))
    ute_wtssim_instance.execute_egate_command(
        cmd='ue_reauth id={} nr_sec_cap={}'.format(ue_id, nr_sec_cap),
        pass_regexp='Reauthentication procedure is complete.',
        timeout=timeout,
    )
