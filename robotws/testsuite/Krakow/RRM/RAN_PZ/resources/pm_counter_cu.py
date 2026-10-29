from taf.rfrl.bts.devices.cu.cu_operations import CuOperations, login_logout_GUI
from testsuite.Krakow.RRM.RAN_PZ.resources.pm_counters import wait_for_next_pm_period, get_last_quarter
import ast
import logging
from builtins import super


class PmCounterCu(CuOperations):

    def __init__(self):
        super(PmCounterCu, self).__init__()
        self.counters_to_check = {}

    def add_counter_to_checklist_cu(self, counter_id, object_class_name, object_name, expected_value,
                                    timezone='Europe/Warsaw'):
        """
                Adds counter that will be checked later

                :param counter_id:           str,  Name of selected counter
                :param object_class_name:    str, Name of Select object class
                :param object_name:          str, Name of select obejct
                :param expected_value:       str, expected value of searching counter
                :param timezone:             str, local time indicator
                """
        current_time = get_last_quarter(timezone=timezone)
        try:
            expected_value = ast.literal_eval(expected_value)
        except ValueError:
            logging.debug("Passed expected_value={} argument could not have been evaluated using ast.literal_eval. "
                          "Storing it directly in provided form".format(expected_value))
        self.counters_to_check[(counter_id, object_class_name, object_name, current_time)] = expected_value

    @login_logout_GUI
    def get_pm_counter_value_on_cu(self, object_class_name, counter_id, object_name, check_time, bts_id=0):
        val = self.gui_coam_cu.get_pm_counters(object_class_name=object_class_name, counter_id=counter_id,
                                               object_name=object_name)
        return val['counters'][0][check_time]

    @login_logout_GUI
    def verify_cu_counter_checklist(self, wait_for_next_period=True, bts_id=0):
        """
        Verifies counter list provided earlier and compares expected and real values

        :param wait_for_next_period:  str, Waits for next counter period before checking values
        :param bts_id:               BTS ID - related to Test Line configuration
        :type bts_id:                int
        """
        if wait_for_next_period:
            wait_for_next_pm_period()
        for counter, expected_value in self.counters_to_check.items():
            counter_object = self.gui_coam_cu.get_pm_counters(
                object_class_name=counter[1],
                counter_id=counter[0],
                object_name=counter[2]
            )
            real_value = int(counter_object['counters'][0][counter[3]])
            if isinstance(expected_value, list):
                assert expected_value[0] <= real_value <= expected_value[1], \
                    "{}: real value: {}\nexpected value: {}".format(counter[0], real_value, expected_value)
            else:
                assert expected_value == real_value, \
                    "{}: real value: {}\nexpected value: {}".format(counter[0], real_value, expected_value)
