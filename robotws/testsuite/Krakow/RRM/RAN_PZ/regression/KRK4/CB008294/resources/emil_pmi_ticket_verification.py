"""
:copyright: Nokia Networks
:author: Mateusz Plinta
:maintainer: Mateusz Plinta
:contact: mateusz.plinta@nokia.com
"""
import json
import os
import re

from robot.libraries.BuiltIn import BuiltIn

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.utilities import logger_info
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.dcap_emil_json_decoder import EmilJsonDecoderClient

from pm_counters_vars import pmi_ticket_counters_validation_dict, counters_name_to_id_map


def decode_emil_to_json(filepath):
    emil_dec_client = EmilJsonDecoderClient()
    resp = emil_dec_client.upload_log_file(log_filepath=filepath)
    logger_info(f"Emil decode resp: {resp}")
    session = resp["sessionId"]
    grid_ids = resp["gridIds"]
    operation_status = resp["operationStatus"]
    if operation_status != "Success":
        raise ValueError(f"Emil decode error: resp: {resp}")
    if len(grid_ids) != 1:
        raise ValueError(f"GridIds length is != 1. GridIds={grid_ids}")
    return emil_dec_client.get_call_grid_data(grid=grid_ids[0], connection=session)


def pmi_ticket_verification_from_emil_decoded_data(filepath):
    def assert_counter_value_in_pmi_data(counter_name, value):
        for emil_counter_str, occurrence in pmi_occurrence_dict.items():
            if counter_name in emil_counter_str and counters_name_to_id_map[counter_name] in emil_counter_str:
                if occurrence == value:
                    logger_info(f"PMI {counter_name}={value} passed")
                    break
                else:
                    validation_failed_list.append(f"PMI {counter_name}={occurrence} instead of {value}")
        else:
            validation_failed_list.append(f"PMI {counter_name} could not have been found!")

    cc_dl = BuiltIn().get_variable_value("${CC_DL}")
    cc_ul = BuiltIn().get_variable_value("${CC_UL}")
    scc_dl = cc_dl - 1
    scc_ul = cc_ul - 1
    ue_ids = BuiltIn().get_variable_value("${UE_IDS}")
    ues = len(ue_ids)
    emil_json_decoded = decode_emil_to_json(filepath=filepath)
    pmi_list = []
    for row in emil_json_decoded['EmilData']['Rows']:
        pmi_list += row["PM_Counters"]
    pmi_occurrence_dict = {item: pmi_list.count(item) for item in set(pmi_list)}
    logger_info(f"pmi_occurrence_dict: {pmi_occurrence_dict}")
    validation_failed_list = []
    for counter, value in pmi_ticket_counters_validation_dict.items():
        counter = counter.format(scc_dl=scc_dl, scc_ul=scc_ul)
        value = int(value.format(ues=ues))
        assert_counter_value_in_pmi_data(counter_name=counter, value=value)
    joined_errors = '\n'.join(validation_failed_list)
    assert len(validation_failed_list) == 0, f"PMI Ticket verification failure. Failed counters:\n{joined_errors}"
