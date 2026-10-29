import json
from abc import abstractmethod, ABC
import sys


def __convert_list_to_dict(list_to_convert: list) -> dict:
    converted_dict = {}
    for elemetn in list_to_convert:
        converted_dict[elemetn] = []
    return converted_dict


def __compare_passed_snfs_and_slots(rnits_sfns) -> bool:
    all_sfns_and_slots = list(rnits_sfns.values())
    for sfn_slot in all_sfns_and_slots[0]:
        match_counter = 0
        for other_ues_sfns_slots in all_sfns_and_slots[1:]:
            if sfn_slot in other_ues_sfns_slots:
                match_counter += 1
                if match_counter == len(all_sfns_and_slots) - 1:
                    return True
    return False


def find_all_rntis(tti_logs: dict) -> list:
    all_rntis = []
    for log in tti_logs['events']:
        if 'dlFdSchedData' in log.keys():
            rnti = log['dlFdSchedData']['body']['eventHeader']['rnti']
            if rnti not in all_rntis:
                all_rntis.append(rnti)
    return all_rntis


def check_feature_conditions(tti_logs, rntis, feature_conditions):
    left_ues_to_check = rntis.copy()
    passed_sfns_for_ues = __convert_list_to_dict(rntis)
    for log in tti_logs['events']:
        if 'dlFdSchedData' in log.keys():
            single_ue_rnti = log['dlFdSchedData']['body']['eventHeader']['rnti']
            if single_ue_rnti in rntis:
                if feature_conditions(log):
                    if single_ue_rnti in left_ues_to_check:
                        left_ues_to_check.remove(single_ue_rnti)
                    sfn = log['dlFdSchedData']['body']['eventHeader']['onAirTime']['sfn']
                    slot = log['dlFdSchedData']['body']['eventHeader']['onAirTime']['slot']
                    if sfn not in passed_sfns_for_ues[single_ue_rnti]:
                        passed_sfns_for_ues[single_ue_rnti].append((sfn, slot))
    print("Founded UEs: {}".format(rntis))
    print("JSON size: {}".format(sys.getsizeof(passed_sfns_for_ues) / 1000))
    if not __compare_passed_snfs_and_slots(passed_sfns_for_ues):
        raise Exception("UEs don't match feature conditions in a same sfn slot. Slots for UEs"
                        .format(passed_sfns_for_ues))
    if len(left_ues_to_check) > 0:
        raise Exception("UEs with {} rnti don't match feature requrements".format(left_ues_to_check))
    if not __compare_passed_snfs_and_slots(passed_sfns_for_ues):
        raise Exception("UEs don't match feature conditions in a same sfn slot. SFNs and slots per UE \n{}"
                        .format(passed_sfns_for_ues))


class TTIParser(ABC):
    @abstractmethod
    def feature_conditions(self, single_log) -> bool:
        pass

    # This method should be used to check tti traces
    def verify_TTI_Traces(self, json_path: str):
        with open(json_path) as f:
            tti_logs = json.load(f)
            print("JSON size: {}".format(sys.getsizeof(tti_logs) / 1000))
            rntis = find_all_rntis(tti_logs)
            if len(rntis) == 0:
                raise Exception("No UEs founded in tti trace json logs !")
            print("Founded ues: {}".format(rntis))

            check_feature_conditions(tti_logs, rntis, self.feature_conditions)
