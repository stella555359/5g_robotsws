"""
:copyright: Nokia Networks
:author: Grzegorz Kaczor
:contact: grzegorz.kaczor@nokia.com
"""
import random
import logging
import copy
from taf.sbts.oam.coam.admin.exceptions import DataNotAvailable
from taf.internal.robot_typecasts import time_to_seconds, to_boolean
from taf.rfrl.bts.devices.generic_bts import login_logout
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter as GnbCounter
from testsuite.Krakow.SISO.regression.RAN_PZ_KRK2.CNI144608.resources.additional_variables import *


class GnbCustomCounter(GnbCounter):

    def __init__(self):
        super(GnbCustomCounter, self).__init__()
        self.selected_beams = []
        self.beams_to_check = []

    def unmute_beam(self, beam: dict, bts_id=0, du_id=0, cell_id=0):
        logging.debug(f"Unmuting beam: {beam}")
        delta = copy.deepcopy(beam_dist_data)
        delta[0]["parameters"][0]["value"][0]["beamsMuted"] = beam["unmuted_value"]
        self.perform_bts_delta_commissioning(delta=delta, bts_id=bts_id, du_id=du_id, cell_id=cell_id)
        self.beams_to_check.append(beam)

    def select_set_of_beams_to_test(self, number_of_beams: int = 10) -> list[dict]:
        self.selected_beams = random.sample(beams_data, number_of_beams)
        logging.info(f"Whole beam set:{beams_data}")
        logging.info(f"Selected {number_of_beams} beams:{self.selected_beams}")
        return self.selected_beams

    def validate_pm_counters_for_beams(self, expected_value: int, cell_id: int = 0, bts_id=0, du_id=0):
        beam_fail_check = []
        pm_counters = []
        logging.debug(f"Beams to check PM counters for: {self.beams_to_check}")
        for beam in self.beams_to_check:
            pm_counters.append(beam["pm_counter"])
        counters_response = self.get_counters_verbose(counters=pm_counters, bts_id=bts_id, du_id=du_id)
        for beam in self.beams_to_check:
            pm_counter_value = self._extract_counter_value(counters_data=counters_response, counter=beam["pm_counter"])
            if pm_counter_value != expected_value:
                logging.info(f"PM counter {beam['pm_counter']} value for beam {beam['beam_id']} is {pm_counter_value},"
                             f" expected {expected_value}")
                beam_fail_check.append(beam)
        self.beams_to_check = beam_fail_check
        logging.info(f"Beams to check after validation: {self.beams_to_check}")

    def end_of_test_validate_pm_counters_for_beams(self, expected_value: int, cell_id: int = 0, bts_id=0, du_id=0):
        self.validate_pm_counters_for_beams(expected_value=expected_value, cell_id=cell_id, bts_id=bts_id, du_id=du_id)
        if self.beams_to_check:
            raise AssertionError(f"Beams failed to match expected value of {expected_value}: {self.beams_to_check}")

    def validate_pm_counters_for_scell_additions(self, expected_value: int, cell_id: int = 0, bts_id=0, du_id=0):
        counters_response = self.get_counters_verbose(counters=[RRC_RECONF_6_SCELL_DL_ATT, RRC_RECONF_6_SCELL_DL_SUCC],
                                                      bts_id=bts_id, du_id=du_id)
        att_value = self._extract_counter_value(counters_data=counters_response, counter=RRC_RECONF_6_SCELL_DL_ATT)
        succ_value = self._extract_counter_value(counters_data=counters_response, counter=RRC_RECONF_6_SCELL_DL_SUCC)
        assert att_value == succ_value, (f"Value of {RRC_RECONF_6_SCELL_DL_ATT}={att_value} "
                                         f"does not match {RRC_RECONF_6_SCELL_DL_SUCC}={succ_value}")
        assert att_value == expected_value, f"Value of counters={att_value} does not match expected={expected_value}"

    def get_counters_verbose(self, counters: list, bts_id=0, du_id=0) -> dict[dict]:
        counter_string = ",".join(counters)
        logging.debug(f"Counters to get: {counter_string}")
        response = {}
        for counter in counters:
            response[counter] = self.get_pm_counter_info_via_gui(counter, bts_id=bts_id, du_id=du_id,
                                                                 only_latest_value=False)
        logging.debug(f"RESPONSE: {response}")
        return response

    def _extract_counter_value(self, counters_data: dict, counter: str) -> int:
        logging.debug(f"counters_data: {type(counters_data)}")
        counter_periods = counters_data[counter]
        logging.debug(f"{counter} values for all found periods: {counter_periods}")
        counter_sum = 0
        for value in counter_periods.values():
            if value == '-':
                value = '0'
            counter_sum += int(value)
        logging.info(f"{counter} sum of all periods: {counter_sum}")
        return counter_sum

    @login_logout
    def perform_bts_delta_commissioning(self, delta, bts_id=0, skip_parameter_relation_errors=False,
                                        should_activate=True, timeout=300, du_id=0, cell_id=0, adjust_dist_name=True):
        timeout = time_to_seconds(time=timeout)
        skip_parameter_relation_errors = to_boolean(item=skip_parameter_relation_errors)
        should_activate = to_boolean(item=should_activate)
        if adjust_dist_name:
            mrbts_id = self.get_bts_instance_id(bts_id=bts_id, du_id=du_id)
            global_bts_id = self.get_global_bts_id(bts_id=bts_id, du_id=du_id)
            for param_dict in delta:
                param_dict['distName'] = param_dict['distName'].format(mrbts_id, global_bts_id, cell_id)

        parameters = {"planObjects": delta, "shouldBeActivated": should_activate}

        connection = self.admin.store.get(self.rest_alias.format(bts_id, du_id))
        logging.debug(f"Recommissioning with following parameters: {delta}")
        if skip_parameter_relation_errors:
            parameters["skipParameterRelationErrors"] = True
        status = connection._api_client.execute_procedure("recommission", parameters, timeout)
        if status is None:
            raise DataNotAvailable("Recommissioning status has not been provided by M-Plane.")
        logging.debug(f"Recommissioning status: {status}")
        if status["commissioningResult"]["activationResult"]["resultNode"]["parameters"]["result"] != "Success":
            raise RuntimeError("Recommissioning beams failed")
        return status
