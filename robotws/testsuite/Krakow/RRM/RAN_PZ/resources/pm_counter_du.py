import datetime
import ast
import os
from taf.analyzer.pmcounter import pmcounter
from taf.rfrl.utilities.tl_config import get_web_credentials_for_du
from testsuite.Krakow.RRM.RAN_PZ.resources.rrm_fixture import get_oam_type
from testsuite.Krakow.RRM.RAN_PZ.resources.pm_counters import wait_for_next_pm_period, get_last_quarter
from taf.collectors.pmcounters import pmcounters
import logging
from robot.libraries.BuiltIn import BuiltIn


class PmCounterDu:

    def __init__(self):
        self.counters_to_check = {}

    def add_counter_to_checklist_du(self, counter_id, object_name, object_name_value, expected_value,
                                    timezone='Europe/Warsaw'):
        """
                Adds counter that will be checked later
                :param counter_id:           str,  Id of counter
                :param object_name_value:    str, Value of checking object name
                :param object_name:          str, Name of checking object name
                :param expected_value:       str, expected value of searching counter
                :param timezone:             str, local time indicator
                """
        current_time = get_last_quarter(timezone=timezone)
        logging.debug("Current time = : {}".format(current_time))
        try:
            expected_value = ast.literal_eval(expected_value)
        except ValueError:
            logging.debug("Passed expected_value={} argument could not have been evaluated using ast.literal_eval. "
                          "Storing it directly in provided form".format(expected_value))
        self.counters_to_check[(counter_id, object_name, object_name_value, current_time)] = expected_value

    def verify_du_counter_checklist(self, wait_for_next_period=True):

        if wait_for_next_period:
            wait_for_next_pm_period()
        PmCounterDu.collect_counters()
        for counter, expected_value in self.counters_to_check.items():
            counter_value = PmCounterDu.get_last_counter_values(counter_ids=counter[0], object_name=counter[1],
                                                                check_in_time=counter[3])
            real_value = int(counter_value[counter[0]][counter[2]])
            logging.debug("Real counter value equal = : {}".format(real_value))
            if isinstance(expected_value, list):
                assert expected_value[0] <= real_value <= expected_value[1], \
                    "real value: {}\nexpected value: {}".format(real_value, expected_value)
            else:
                assert expected_value == real_value, \
                    "real value: {}\nexpected value: {}".format(real_value, expected_value)

    @staticmethod
    def extract_nrcell_id(object_hierarchy_str, object_name):
        for item in object_hierarchy_str.split("/"):
            if object_name in item:
                return item.split("-")[1]

    @staticmethod
    def collect_counters(bts_id=0):
        webservice = get_web_credentials_for_du(bts_id=bts_id)
        webservice = {'host': webservice['ip'], 'user': webservice['username'],
                      'password': webservice['password'], 'port': 443}
        oam_type = get_oam_type()
        oam_type = PmCounterDu.resolve_oam_type_name(oam_type)
        pmcounter_instance = pmcounters()
        name = 'du_pm_counters'
        path = BuiltIn().get_variable_value("${OUTPUT DIR}")
        pmcounter_instance.create_pm_collector(name=name, webservice=webservice, oam_type=oam_type)
        pmcounter_instance.setup_collectors(names=name)
        pmcounter_instance.collect_collectors(names=name,
                                              target_dir=path)
        pmcounter_instance.teardown_collectors(names=name)
        return os.path.join(path, name)

    @staticmethod
    def get_last_counter_values(counter_ids, object_name, check_in_time):
        counters_count = len(counter_ids)
        if not isinstance(counter_ids, list):
            counter_ids = [counter_ids]
        pm_counter_object = pmcounter()
        pi_dir = os.path.join(BuiltIn().get_variable_value("${OUTPUT DIR}"), 'du_pm_counters')
        pi_dict = pm_counter_object.get_pi_value(pi_list=counter_ids, pi_dir=pi_dir, pi_file_pattern="PM*")
        result_dict = {}
        pi_dict = [entry for entry in pi_dict if list(list(entry.values())[0].values())[0] != {}]
        logging.debug("Pi dict = : {}".format(pi_dict))
        logging.debug("Check in time= : {}".format(check_in_time))

        pi_dict_new = []
        for entry in pi_dict:
            for (k, v) in entry.items():
                if k.startswith(check_in_time):
                    pi_dict_new.append(entry)

        if not pi_dict_new:
            for entry in pi_dict:
                for (k, v) in entry.items():
                    if datetime.datetime.strptime(check_in_time, "%Y-%m-%d %H:%M:%S").minute < \
                            datetime.datetime.strptime(k[0:k.index('+')], "%Y-%m-%d %H:%M:%S").minute < \
                            datetime.datetime.strptime(check_in_time, "%Y-%m-%d %H:%M:%S").minute + 15:
                        pi_dict_new.append(entry)

        logging.debug("Pi dict new = : {}".format(pi_dict_new))

        for date_entry in pi_dict_new[-1 * counters_count:]:
            result_dict[list(list(date_entry.values())[0].keys())[0]] = \
                {PmCounterDu.extract_nrcell_id(k, object_name): v for (k, v) in
                 list(list(date_entry.values())[0].values())[0].items()}

        if not pi_dict_new:
            raise ValueError('Probably the local time zone may be different from the time zone set on gNB.')

        return result_dict

    @staticmethod
    def resolve_oam_type_name(name):
        name = str(name)
        if 'mz' in name.lower() or 'mega' in name.lower():
            return 'mzoam'
        elif 'coam' in name.lower() or 'common' in name.lower():
            return 'coam'
        return None
