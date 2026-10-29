import re
import math

from testsuite.Krakow.RRM.Airphone.resources.Python.file_management import load_json_file
from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import logger_console, logger_console_info


class TargetShareException(Exception):
    pass


class MaxQuotaExceeded(Exception):
    pass


class MinMaxQuota(TargetShareException):
    def __init__(self, item, message=None):
        self.item = item
        if message is None:
            message = f'Max Quota smaller than min Quota for RG {self.item}'
        self.message = message
        super().__init__(self.message)


class InvalidPathError(TargetShareException):
    def __init__(self, counter_key, rg_key):
        self.counter_key = counter_key
        self.rg_key = rg_key
        super().__init__(f'Invalid path for counter {self.counter_key} and RG: {self.rg_key}')


class TargetShareNotMatch(TargetShareException):
    def __init__(self, rg_number):
        self.rg_number = rg_number
        super().__init__(f'Target share from counters does not match calculated target share for RG: {self.rg_number}')


class ResourceGroupMissing(TargetShareException):
    def __init__(self, rg_number):
        self.rg_number = rg_number
        super().__init__(f'Counters are not present for passed RG: {self.rg_number}')


def __map_rg_with_their_quotas_new_delta(quotas):
    """
    Map RGs with their quotas
    :param quotas: dictionary with min and max quotas values
    :return: dictionary in this format: {1: {'min': '10', 'max': '30'}, 2: {'min': '40', 'max': '60'}, 3: ...}
    """
    return {rg + 1: {'min': quotas['minQuotas'][rg], 'max': quotas['maxQuotas'][rg]} for rg in range(quotas[
                                                                                                         'RG_amount'])}


def __map_rg_with_their_quotas(quotas, new_delta):
    """
    Map RGs with their quotas
    :param quotas: dictionary with min and max quotas values
    :param new_delta: bool, if True call __map_rg_with_their_quotas_new_delta(quotas)
    :return: dictionary in this format: {1: {'min': '10', 'max': '30'}, 2: {'min': '40', 'max': '60'}, 3: ...}
    """

    if new_delta:
        return __map_rg_with_their_quotas_new_delta(quotas)
    rg_quotas = {}
    for key, value in quotas['quotas'].items():
        match = re.findall(r'\d+', key)
        match = int(match[0])
        if match not in rg_quotas:
            rg_quotas[match] = {}
        if 'min' in key:
            rg_quotas[match]['min'] = value
        elif 'max' in key:
            rg_quotas[match]['max'] = value
    return rg_quotas


def __get_counter_values(counter_path, value, counter_id, rg_group):
    """
    Get value of counters
    :param counter_path: string, path to counter
    :param value: counter value loaded from path_to_json
    :param counter_id: string, counter id
    :param rg_group: string, resource group identifier
    :return: value of counter
    :raises InvalidPathError: if path for counter is not found
    """
    path_list = counter_path.split('/')
    path_list.append(counter_id)
    try:
        for key in path_list:
            value = value[key]
    except KeyError as e:
        raise InvalidPathError(counter_id, rg_group) from e
    return value


def __map_rg_to_counter_values(prb_used, prb_avail, prb_util_max, counters):
    """
    Map RGs to their counter values
    :param prb_used: dictionary, dict with PRB_used counters
    :param prb_avail: dictionary, dict with PRB_available counters
    :param prb_util_max: dictionary, dict with Max PRB utilization counters
    :param counters: counters loaded from path_to_json
    :return: dictionary in this format: {1: {'M55910C00003': 0, 'M55308C10012': 100, 'M55910C00004': 60},
                                         2: {'M55910C00003': 54,'M55308C10012': 100, 'M55910C00004': 40},
                                         3: {'M55910C00003': 45, 'M55308C10012': 100, 'M55910C00004': 30}}
    """

    rg_counters = {}
    for counter_id, paths in prb_used.items():
        for rg, path in paths.items():
            if rg not in rg_counters:
                rg_counters[int(rg)] = {}
            rg_counters[int(rg)][counter_id] = __get_counter_values(path, counters, counter_id, rg)

    for counter_id, paths in prb_avail.items():
        for rg in rg_counters.keys():
            if isinstance(paths, str):
                rg_counters[int(rg)][counter_id] = __get_counter_values(paths, counters, counter_id, rg)
            else:
                rg_counters[int(rg)][counter_id] = __get_counter_values(paths[str(rg)], counters, counter_id, rg)

    for counter_id, paths in prb_util_max.items():
        for rg in rg_counters.keys():
            if isinstance(paths, str):
                rg_counters[int(rg)][counter_id] = __get_counter_values(paths, counters, counter_id, rg)
            else:
                rg_counters[int(rg)][counter_id] = __get_counter_values(paths[str(rg)], counters, counter_id, rg)

    return rg_counters


def __calculate_vars(rg_quotas):
    """
    Calculate variables: pool, sum of min and max quotas
    :param rg_quotas: dictionary created by calling __map_rg_with_their_quotas
    :return: values of: pool, min_quote_sum, max_quote_sum
    """

    pool = 0
    min_quote_sum = 0
    max_quote_sum = 0
    for rg in rg_quotas:
        pool += int(rg_quotas[rg]['max']) - int(rg_quotas[rg]['min'])
        min_quote_sum += int(rg_quotas[rg]['min'])
        max_quote_sum += int(rg_quotas[rg]['max'])
    return pool, min_quote_sum, max_quote_sum


def __calc_expected_ts(rg_quotas, pool, min_quote_sum, not_all_ts_used_rg, scale):
    """
    Calculate expected target share values
    :param rg_quotas: dictionary created by calling __map_rg_with_their_quotas
    :param pool: sum of differences between max and min quota in all RG respectively
    :param min_quote_sum: sum of min quote from all resource groups
    :param not_all_ts_used_rg: resource groups with not all target share used
    :param scale: ratio between large BWP and small BWP in case of IWK with feature CB007552
    :return: dictionary with calculated expected target share for each resource group
    """
    rg_with_quotas_and_ts = rg_quotas
    for rg in rg_with_quotas_and_ts:
        if int(rg_with_quotas_and_ts[rg]['max']) < int(rg_with_quotas_and_ts[rg]['min']):
            raise MinMaxQuota(rg)
        diff = int(rg_with_quotas_and_ts[rg]['max']) - int(rg_with_quotas_and_ts[rg]['min'])
        target_share = (int(rg_with_quotas_and_ts[rg]['min']) + diff / pool * (100 - min_quote_sum)) * scale
        rg_with_quotas_and_ts[rg]['target_share'] = target_share
    to_divide = 0
    for rg in not_all_ts_used_rg:
        current_target_share = rg_with_quotas_and_ts[rg]['target_share']
        not_used = current_target_share * (100 - not_all_ts_used_rg[rg]) / 100
        to_divide += not_used
        rg_with_quotas_and_ts[rg]['target_share'] = current_target_share - not_used

    denom = 0
    for rg in rg_with_quotas_and_ts:
        if rg not in not_all_ts_used_rg:
            denom += rg_with_quotas_and_ts[rg]['target_share']

    checked_rgs = list(not_all_ts_used_rg.keys())
    additional = 0
    for rg in rg_with_quotas_and_ts:
        if rg not in not_all_ts_used_rg:
            current_target_share = rg_with_quotas_and_ts[rg]['target_share']
            current_target_share += to_divide * current_target_share / denom
            if current_target_share > float(rg_with_quotas_and_ts[rg]['max']):
                additional += current_target_share - float(rg_with_quotas_and_ts[rg]['max'])
                current_target_share = float(rg_with_quotas_and_ts[rg]['max'])
                checked_rgs.append(rg)
            rg_with_quotas_and_ts[rg]['target_share'] = current_target_share

    unchecked_rgs = [rg for rg in list(rg_with_quotas_and_ts.keys()) if rg not in checked_rgs]
    while unchecked_rgs:
        denom = 0
        for rg in unchecked_rgs:
            denom += rg_with_quotas_and_ts[rg]['target_share']

        for rg in unchecked_rgs:
            current_target_share = rg_with_quotas_and_ts[rg]['target_share']
            add = additional * current_target_share / denom
            current_target_share += add
            additional -= add
            if current_target_share > float(rg_with_quotas_and_ts[rg]['max']):
                additional += current_target_share - float(rg_with_quotas_and_ts[rg]['max'])
                current_target_share = float(rg_with_quotas_and_ts[rg]['max'])
                unchecked_rgs.remove(rg)
            rg_with_quotas_and_ts[rg]['target_share'] = current_target_share
        if int(additional) == 0:
            break
    return rg_with_quotas_and_ts


def __get_last_counter_values(found_counter_values):
    """
    Get latest value for counter
    :param found_counter_values: values of counter
    :return: latest value for counter
    """
    if isinstance(found_counter_values, dict):
        latest_timestamp = max(list(found_counter_values.keys()))
        found_counter_values = found_counter_values[latest_timestamp]
    return found_counter_values


def __ts_counters_and_check(rg_with_quotas_and_ts, rg_counters, prb_used, prb_avail, margin, excessive_gbr=False,
                            excessive_gbr_groups=()):
    """
    Calculate TS from counters for each RG and check if this value is within the margin to expected target share
    :param rg_with_quotas_and_ts: dictionary with RGs associated with min, max quota and calculated target share
    :param rg_counters: dictionary with counters values
    :param prb_used: dictionary, dict with PRB_used counters
    :param prb_avail: dictionary, dict with PRB_available counters
    :param margin: acceptable percentage at which expected target share can differ from target
        share from counters
    :return: None
    :raises ZeroDivisionError: if value for prb_avail counter equals 0
    :raises TargetShareNotMatch: if expected TS value is not in margin with actual TS
    """
    if excessive_gbr:
        logger_console_info(f'For a Resource Group with an excessive GBR percentage,'
                            f' the actual percentage of resources used should be greater'
                            f' than the expected percentage. Conversely, for groups without '
                            f'GBR traffic, the situation should be the opposite.')
    target_share_counters = {}
    for rg, counter_values in rg_counters.items():
        if all(counter in counter_values for counter in {**prb_used, **prb_avail}.keys()):
            numerator = __get_last_counter_values(counter_values[list(prb_used.keys())[0]])
            denominator = __get_last_counter_values(counter_values[list(prb_avail.keys())[0]])
            if denominator != 0:
                target_share_counters[rg] = 100 * numerator / denominator  # 100 - to convert to %
            else:
                raise ZeroDivisionError(f'Value of {list(prb_avail.keys())[0]} can not be equal to 0')

    exception_dict_rg = list()
    for rg in target_share_counters:
        if rg in rg_with_quotas_and_ts:
            expected_ts = rg_with_quotas_and_ts[rg]['target_share']
            expected_ts_round = round(rg_with_quotas_and_ts[rg]['target_share'])
            real_ts = (target_share_counters[rg])
            real_ts_round = round(target_share_counters[rg])
            if excessive_gbr and rg in excessive_gbr_groups:
                check_passed = real_ts_round != 0 and expected_ts_round < real_ts
            elif excessive_gbr and rg not in excessive_gbr_groups:
                check_passed = real_ts_round != 0 and expected_ts_round > real_ts
            else:
                check_passed = (real_ts_round != 0 and abs(expected_ts_round - real_ts) < margin) or \
                               (real_ts_round == 0 and expected_ts_round == 0)
            if check_passed:
                logger_console_info(
                    f'Passed check for Resource Group {rg}, percentage of resource used: {real_ts:.3f}, '
                    f'percentage of resources expected: {expected_ts:.3f}, error margin: {margin}%')
            else:
                exception_dict_rg.append(rg)
                logger_console_info(
                    f'Failed check for Resource Group {rg}, percentage of resource used: {real_ts:.3f}, '
                    f'percentage of resources expected: {expected_ts:.3f}, error margin: {margin}%')

    if exception_dict_rg:
        raise TargetShareNotMatch(str(exception_dict_rg).strip('[]'))

    return target_share_counters


def __check_max_prb_util(rg_with_quotas_and_ts, rg_counters, prb_util_max, traffic_dir='ul', k2=2,
                         initial_slot_offset_ul=2, technology='TDD', rdSasBookkeepingDelay=4):
    """
    Calculate TS from counters for each RG and check if this value is within the margin to expected target share
    :param rg_with_quotas_and_ts: dictionary with RGs associated with min, max quota and calculated target share
    :param rg_counters: dictionary with counters values
    :param prb_util_max: dictionary, dict with Max PRB utilization counters
    :param traffic_dir: traffic direction
    :param k2: Offset between the DL slot where the PDCCH (DCI) for Uplink scheduling is received and the UL Slot
               where the UL data need to sent on PUSCH. Taken from ulFdSchedData.k2 in ttiTraces
    :param initial_slot_offset_ul: initialSlotOffsetUl can be seen in syslogs from cell startup, e.g.
           grep 'initialSlotOffsetUl' BTS1_223D_part_1/BTS1_2730_L2RT21_ASP-2730_startup/ASP-2730_startup.log:
           .uplane/L2-PS/src/pscommon/db/cell/data/slotTiming/SlotTimingConfigData.hpp:43 initialSlotOffsetDl:2,
           initialSlotOffsetUl:2
    :param technology: TDD or FDD
    :param rdSasBookkeepingDelay: L1 delay value defined in 5G_L2_16392, 4 by default
    :return: None
    :raises MaxQuotaExceeded: if Max PRB utilization exceeds maxQuota more than expected
    """
    technology_offset = 1 if technology == 'TDD' else 0
    ul_delay_slots = initial_slot_offset_ul + technology_offset + k2 + rdSasBookkeepingDelay
    for rg, counter_values in rg_counters.items():
        rrm_rg_target_share = float(rg_with_quotas_and_ts[rg]['target_share'])
        target_share_fraction = rrm_rg_target_share / 100
        excess_per_slot = (1 / 101 * 1 + 100 / 101 * target_share_fraction) - target_share_fraction
        total_excess = 100 * ul_delay_slots * excess_per_slot if traffic_dir == 'ul' else 1
        prb_util_max_value = __get_last_counter_values(counter_values[list(prb_util_max.keys())[0]])
        max_quota = float(rg_with_quotas_and_ts[rg]['max'])
        if prb_util_max_value <= (max_quota + math.ceil(total_excess)):
            logger_console_info(f"RG{rg} UL_PRB_UTIL_SLOT_MAX_NRG: {prb_util_max_value} <= maxQuota {max_quota} "
                                f"+ expected max excess: {math.ceil(total_excess)}")
        else:
            raise MaxQuotaExceeded(f"RG{rg} UL_PRB_UTIL_SLOT_MAX_NRG: {prb_util_max_value} exceeds maxQuota {max_quota}"
                                   f" + expected max excess: {math.ceil(total_excess)}")


def target_share_validation(quotas, path_to_json, prb_used, prb_avail, prb_util_max={}, tputs=None,
                            excessive_gbr_groups=(), margin=5, scale=1.0, new_delta=False, traffic_dir='dl', k2=2,
                            initial_slot_offset_ul=2, technology='TDD', rdSasBookkeepingDelay=4, excessive_gbr=False):
    """
    Check if min and max quota are passed correctly, calculate target share for each RG and compare it with counters

    :param quotas: dictionary, dict with minQuota and maxQuota values associated with RGs
    :param path_to_json: str, path to json file with counter values
    :param prb_used: dictionary, dict with PRB_used counters. Example:
        {"M55910C00003": {'1': "BTS/CELLS/NRCELL-2/NCELA/RG-1", '2': "BTS/CELLS/NRCELL-1/NCELA/RG-2", '3': ...}}
    :param prb_avail: dictionary, dict with PRB_available counters. Example:
        {"M55308C10012": {'1': "BTS/CELLS/NRCELL-2/NCELA/RG-1", '2': "BTS/CELLS/NRCELL-1/NCELA/RG-2", '3': ...}}
        if for all resource groups is the same only one path is sufficient, example:  {'M55328C00003':
        'BTS/BTS/NRBTS-1/MCC-311_MNC-489/SST-1_SD-13714341/NPSL'}
    :param prb_util_max: dictionary, dict with Max PRB utilization counters
    :param tputs: list, list of percentage usage of TS by each RG respectively (0%-100%). Example: [20, 100, 100],
        if None given assumes 100 for all resource groups
    :param margin: int, acceptable percentage at which calculated target share can differ from target
        share from counters. Default = 5 (5%)
    :param scale: float, ratio between large BWP and small BWP in case of IWK with feature CB007552.
        Default = 1.0
    :param new_delta: bool, when set to True parses quotas dictionary according to new delta function, default False
    :param traffic_dir: string, traffic direction
    :param k2: Offset between the DL slot where the PDCCH (DCI) for Uplink scheduling is received and the UL Slot
        where the UL data need to sent on PUSCH. Taken from ulFdSchedData.k2 in ttiTraces
    :param initial_slot_offset_ul: initialSlotOffsetUl can be seen in syslogs from cell startup, e.g.
           grep 'initialSlotOffsetUl' BTS1_223D_part_1/BTS1_2730_L2RT21_ASP-2730_startup/ASP-2730_startup.log:
           .uplane/L2-PS/src/pscommon/db/cell/data/slotTiming/SlotTimingConfigData.hpp:43 initialSlotOffsetDl:2,
           initialSlotOffsetUl:2
    :param technology: TDD or FDD
    :param rdSasBookkeepingDelay: L1 delay value defined in 5G_L2_16392, 4 by default
    :return: dictionary, dict with minQuota, maxQuota and target share for each RG in this format:
        {1: {'min': '10', 'max': '30', 'target_share': 16.0}, 2: ...}
    :raises MinMaxQuota: if max quota is smaller than min quota for any resource group
    :raises InvalidPathError: if path for counter is not found
    :raises ResourceGroupMissing: if counter for resource group provided in quotas is missing
    :raises ZeroDivisionError: if value for prb_avail counter equals 0
    :raises TargetShareNotMatch: if expected TS value is not in margin with actual TS
    """

    counters = load_json_file(path_to_json)  # load counters file and store it as dict
    rg_quotas = __map_rg_with_their_quotas(quotas, new_delta)  # map RG with their quotas
    rg_counters = __map_rg_to_counter_values(prb_used, prb_avail, prb_util_max, counters)  # map RG with counter values

    # check if resource group passed in Quotas is present in the counters
    missing_rg = [rg for rg in rg_quotas.keys() if rg not in rg_counters]
    if any(missing_rg):
        raise ResourceGroupMissing(str(missing_rg).strip('[]'))

    pool, min_quote_sum, max_quote_sum = __calculate_vars(rg_quotas)  # calc pool, sum of min and max quotas

    # dict with RGs number with not all TS used
    not_all_ts_used_rg = {}
    if tputs:
        not_all_ts_used_rg = {rg: tput for rg, tput in zip(rg_quotas.keys(), tputs) if tput < 100}

    rg_with_quotas_and_ts = rg_quotas
    if max_quote_sum > 100:  # calc TS and split it if RG does not use 100% of it
        rg_with_quotas_and_ts = __calc_expected_ts(rg_quotas, pool, min_quote_sum, not_all_ts_used_rg, scale)
    else:  # sum of max_Quotas <= 100 -> target_share = maxQuota
        for rg in rg_with_quotas_and_ts.values():
            rg['target_share'] = int(rg['max'])

    # check calculations with counters and given margin error
    calculated_target_shares = __ts_counters_and_check(rg_with_quotas_and_ts, rg_counters, prb_used, prb_avail, margin,
                                                       excessive_gbr_groups=list(excessive_gbr_groups),
                                                       excessive_gbr=excessive_gbr)

    if prb_util_max:
        __check_max_prb_util(rg_with_quotas_and_ts, rg_counters, prb_util_max, traffic_dir, k2,
                             initial_slot_offset_ul, technology, rdSasBookkeepingDelay)

    return rg_with_quotas_and_ts, calculated_target_shares
