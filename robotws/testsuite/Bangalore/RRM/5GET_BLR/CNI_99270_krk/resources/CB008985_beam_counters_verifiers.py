"""
:copyright: Nokia Networks
:author: Marek Kieltyka <marek.kieltyka@nokia.com>, Mateusz Matusik <mateusz.matusik@nokia.com>
:maintainer: Marek Kieltyka <marek.kieltyka@nokia.com>, Mateusz Matusik <mateusz.matusik@nokia.com>
"""

import logging
import ast
from robot.libraries.BuiltIn import BuiltIn

NRCELL_1_MOID = 'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1'

PREFIX_DL_SERV_BEAM_ID_BEAM = 'M55305C000'
PREFIX_UL_SERV_BEAM_ID_BEAM = 'M55305C010'
PREFIX_SERV_BEAM_ID_HO = 'M55305C020'
PREFIX_BEAM_CHANGE = 'M55305C030'

MAX_COUNTER_ID_SUFFIX = 64


def verify_DL_SERV_BEAM_ID_BEAM_and_UL_SERV_BEAM_ID_BEAM_are_greater_than_zero_for_subcell(subcell_id):
    assert int(subcell_id) in range(1, MAX_COUNTER_ID_SUFFIX + 1)

    pi_dl_id = '{}{}'.format(PREFIX_DL_SERV_BEAM_ID_BEAM, subcell_id.zfill(2))
    pi_ul_id = '{}{}'.format(PREFIX_UL_SERV_BEAM_ID_BEAM, subcell_id.zfill(2))

    pm_counters_file = BuiltIn().get_variable_value("${PM_COUNTERS}")
    ta_5g_pm_lib = BuiltIn().get_library_instance('ta5g_pm_counters')

    ta_5g_pm_lib.verify_if_latest_pm_counters_from_the_list_are_bigger_than_the_given_value([pi_dl_id, pi_ul_id],
                                                                                            0,
                                                                                            NRCELL_1_MOID,
                                                                                            pm_counters_file)


def verify_value_for_BEAM_CHANGE_counters_for_given_subcells_switch_list_and_unmentioned_BEAM_CHANGE_are_equal_zero(
    subcells_switch_list,
    counter_value
):
    """
    Check if specific BEAM_CHANGE_${source_beam_id}_${target_beam_id} counters are equal to given counter_value
    Rest of BEAM_CHANGE_X_Y should be equal to 0
    :param subcells_switch_list: list of lists of integers
    [[2, 4], [4, 1]] - check BEAM_CHANGE_1_3 and BEAM_CHANGE_3_0 are equal to counter_value
    [[3, 2]]         - check BEAM_CHANGE_2_1 is equal to counter_value
    :param counter_value: counter integer expected value
    :return:
    """
    pm_counters_file = BuiltIn().get_variable_value("${PM_COUNTERS}")
    ta_5g_pm_lib = BuiltIn().get_library_instance('ta5g_pm_counters')

    subcells_switch_list = ast.literal_eval(subcells_switch_list)
    counter_ids_checked = []

    for switch_pair in subcells_switch_list:
        source_subcell_id = int(switch_pair[0])
        target_subcell_id = int(switch_pair[1])

        assert source_subcell_id in range(1, MAX_COUNTER_ID_SUFFIX + 1)\
               and target_subcell_id in range(1, MAX_COUNTER_ID_SUFFIX + 1)

        counter_id_end = (target_subcell_id-1) * 8 + source_subcell_id
        pi_id = '{}{}'.format(PREFIX_BEAM_CHANGE, str(counter_id_end).zfill(2))

        ta_5g_pm_lib.verify_if_latest_pm_counter_has_exact_value(pi_id,
                                                                 counter_value,
                                                                 NRCELL_1_MOID,
                                                                 pm_counters_file)
        counter_ids_checked.append(counter_id_end)

    rest_of_beam_change_counters = ['{}{}'.format(PREFIX_BEAM_CHANGE, str(counter_id_end).zfill(2))
                                    for counter_id_end in range(1, MAX_COUNTER_ID_SUFFIX + 1)
                                    if counter_id_end not in counter_ids_checked]

    ta_5g_pm_lib.verify_if_latest_pm_counters_in_counter_id_list_have_exact_value(rest_of_beam_change_counters,
                                                                                  0,
                                                                                  NRCELL_1_MOID,
                                                                                  pm_counters_file)
