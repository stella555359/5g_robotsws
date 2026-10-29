"""
:copyright: Nokia Networks
:authors:
    Maciej Majewski, maciej.majewski@nokia.com
    Patryk Wojcik, patryk.wojcik@nokia.com
:maintainers:
    Patryk Wojcik, patryk.wojcik@nokia.com
"""

from robot.api import logger
from math import floor
from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.csv_verifiers import csv_verifiers

csv_bip = csv_verifiers()


def calculate_timing_advance(dist):
    """
    Function which calculates timing advance (TA) for specific distance based on formula given by L1 expert
    https://confluence.ext.net.nokia.com/display/AirPhoneWTS/ue_ta_nr
    """
    c = 300000000
    ta = 2 * int(dist) / c
    ts = 64 / (480000 * 4096)
    tg = 16 * ts / (2 ** 3)
    return floor(ta / tg)


def calculate_symbol_and_delay(dist):
    """
    Function which calculates what values of delay and symbol delay should be used in below command on egate
    ue_ta_nr ue_p_delay_initial=${delay} ue_p_symbol_delay_initial=${symbol_delay} profile_id={ue_id}
    to simulate specific distance between UE and gNB.
    TA = symbol_delay * 128 + delay, therefore:
    Symbol delay is calculated by dividing the obtained timing advance result by 128.
    Symbol_delay should get value in range 0-8.
    Delay is calculated as the remainder of dividing the distance by 128. Delay should get value in range 0-127.
    +------------------+---------+------------+------------+------------+
    |     Example                                                       |
    +==================+=========+============+============+============+
    | ${symbol_delay}, ${delay}=  calculate_symbol_and_delay(dist)      |
    +------------------+---------+------------+------------+------------+
    :param dist:   distance from ue to gNB
    """
    timing_advance = calculate_timing_advance(dist)
    symbol_delay = int(timing_advance / 128)
    delay = int(timing_advance % 128)
    return symbol_delay, delay


def verify_initialTAs_in_bip_logs(csv_path, ta_values, diff=1):
    """
    This function verifies initialTa from BIP logs with their expected values.
    Each expected ta value depends on the distance; the greater the distance, the greater the expected
    ta value should be.
    Expected ta value = ue_p_symbol_delay_initial*128 + ue_p_delay_initial where ue_p_symbol_delay_initial
    and ue_p_delay_initial are taken from egate command ue_ta_nr

    +------------------+---------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                              |
    +==================+=========+============+============+============+============+============+============+
    | Verify initialTAs in BIP logs                                                                            |
    | ...       csv_path=${OUTPUT_DIR}/UE_register/BIP_PUCCH.csv                                               |
    | ...       ta_values=${ta1},${ta2},${ta3},${ta4}                                                          |
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    :param csv_path:        path to csv file
    :param ta_values:       ta value used to calculate expected value of initialTa from BIP logs
    :param diff:            accepted error in results
    """
    csv_list = csv_bip.create_list_of_lists_from_csv(csv_path)
    initialTa = csv_bip.filter_csv_by_column_value(
        csv_list=csv_list,
        column_name='UlData_detectedPrachPreambles_t.initialTa',
        condition='>=',
        value=0)
    initialTa_results = [int(item[-2]) for item in initialTa[1:]]
    ta_values_list = list(map(int, ta_values.split(',')))
    symbol_delays = [int(value / 128) for value in ta_values_list]
    delays = [int(value % 128) for value in ta_values_list]
    logger.info(f'expected values of initialTa={ta_values_list}')
    logger.info(f'initialTa_results={initialTa_results}')
    logger.info(f'ue_p_symbol_delay_initials={symbol_delays}')
    logger.info(f'ue_p_delay_initials={delays}')
    for item in ta_values_list:
        assert item in initialTa_results, (f'Not found expected {item} initialTa_results={initialTa_results}. '
                                           f'\nexpected values of initialTa={ta_values_list}'
                                           f'\ninitialTa_results={initialTa_results}'
                                           f'\nue_p_symbol_delay_initials={symbol_delays}'
                                           f'\nue_p_delay_initials={delays}')


def verify_initialUlEcidTAdv_in_bip_logs(csv_path, ta_values, diff=1, tc_res=128):
    """
    This function verifies initialUlEcidTAdv from BIP logs against to expected values calculated from TA value.
    Each expected value of initialUlEcidTAdv depends on the distance; the greater the distance,
    the greater the expected value of initialUlEcidTAdv should be.
    Expected ta value = (ue_p_symbol_delay_initial*128 + ue_p_delay_initial)*tc_res where ue_p_symbol_delay_initial
    and ue_p_delay_initial are taken from egate command ue_ta_nr.

    +------------------+---------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                              |
    +==================+=========+============+============+============+============+============+============+
    | Verify initialUlEcidTAdv in bip logs                                                                     |
    | ...       csv_path=${OUTPUT_DIR}/UE_register/BIP_PUCCH.csv                                               |
    | ...       ta_values=${ta1},${ta2},${ta3},${ta4}                                                          |
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    :param csv_path:        path to csv file
    :param ta_values:       ta value used to calculate expected value of initialUlEcidTAdv from BIP logs
    :param diff:            accepted error in results
    :param tc_res:          Tc resolution for timing advance. 128 Tc resolution for timing advance less than 262144 Tc
                            and 512 Tc for timing advance greater than or equal to 262144 Tc
    """
    csv_list = csv_bip.create_list_of_lists_from_csv(csv_path)
    initialUlEcidTAdv = csv_bip.filter_csv_by_column_value(
        csv_list=csv_list,
        column_name='UlData_detectedPrachPreambles_t.initialUlEcidTAdv',
        condition='>=',
        value=0)
    initialUlEcidTAdv_results = [int(item[-1]) for item in initialUlEcidTAdv[1:]]
    ta_values_list = list(map(int, ta_values.split(',')))
    symbol_delays = [int(value / 128) for value in ta_values_list]
    delays = [int(value % 128) for value in ta_values_list]
    expected_initialUlEcidTAdv = [tc_res*result for result in ta_values_list]

    logger.info(f'expected values of initialUlEcidTAdv={ta_values_list}')
    logger.info(f'initialUlEcidTAdv_results={initialUlEcidTAdv_results}')
    logger.info(f'ue_p_symbol_delay_initials={symbol_delays}')
    logger.info(f'ue_p_delay_initials={delays}')

    for index in range(0, len(ta_values_list)):
        assert ((tc_res * ta_values_list[index] * (1 + diff / 100)) >= float(initialUlEcidTAdv_results[index]) >=
                (tc_res * ta_values_list[index] * (1 - diff / 100))), \
            (f'expected_initialUlEcidTAdv={expected_initialUlEcidTAdv}, '
             f'but got initialUlEcidTAdv_results={initialUlEcidTAdv_results}')
