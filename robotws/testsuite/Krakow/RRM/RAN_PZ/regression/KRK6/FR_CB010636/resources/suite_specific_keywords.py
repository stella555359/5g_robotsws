"""
:copyright: Nokia Networks
:author:   Kamil Bielecki <kamil.bielecki@nokia.com>
:maintainer:   Kamil Bielecki <kamil.bielecki@nokia.com>
"""

import logging

counter_verification_failed = False


def check_counter_incremented(counter_id, counter_values):
    global counter_verification_failed
    last_value = list(counter_values.values())[-1]
    logging.info("Counter {} for cell A equals {}".format(counter_id, last_value))
    if last_value == 0:
        logging.error("Counter {} for cell A incorrect".format(counter_id))
        counter_verification_failed = True


def check_counter_zero(counter_id, counter_values):
    global counter_verification_failed
    last_value = list(counter_values.values())[-1]
    logging.info("Counter {} for cell A equals {}".format(counter_id, last_value))
    if last_value != 0:
        logging.error("Counter {} for cell A incorrect".format(counter_id))
        counter_verification_failed = True


def check_counter_almost_zero(counter_id, counter_values):
    global counter_verification_failed
    last_value = list(counter_values.values())[-1]
    logging.info("Counter {} for cell A equals {}".format(counter_id, last_value))
    if last_value > 100000:
        logging.error("Counter {} for cell A incorrect".format(counter_id))
        counter_verification_failed = True


def check_counter_almost_zero_cc(counter_id, counter_values):
    global counter_verification_failed
    last_value = list(counter_values.values())[-1]
    logging.info("Counter {} for cell A equals {}".format(counter_id, last_value))
    if last_value > 1500000:
        logging.error("Counter {} for cell A incorrect".format(counter_id))
        counter_verification_failed = True


def check_cb010636_a_counters(counters):
    """
    Check if values of params correct for CB010636-A
    :param counters: array
        Array of counters fetched from gNB
    :return: boolean
        Check of counters successful=True or failed=False
    """
    cells_counters = counters['BTS']['MRBTS-79050']['NRBTS-79050']
    cell_a_counters = cells_counters['NRCELL-260']
    cell_b_counters = cells_counters['NRCELL-261']
    cell_c_counters = cells_counters['NRCELL-262']
    for counter_type in cell_a_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55310C20001':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55310C20000':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55310C02025':
                check_counter_almost_zero(counter_id, counter_values)
            if counter_id == 'M55310C02026':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55310C02027':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55310C02028':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55310C02031':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55316C14001':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55316C14002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55310C02033':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55310C02034':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55310C02035':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55310C02036':
                check_counter_zero(counter_id, counter_values)
    for counter_type in cell_b_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55310C20001':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55310C20000':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55310C02025':
                check_counter_almost_zero(counter_id, counter_values)
            if counter_id == 'M55310C02026':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55310C02027':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55310C02028':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55310C02031':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55316C14001':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55316C14002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55310C02033':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55310C02034':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55310C02035':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55310C02036':
                check_counter_zero(counter_id, counter_values)
    for counter_type in cell_c_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55310C20001':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55310C20000':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55310C02025':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55310C02026':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55310C02027':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55310C02028':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55310C02031':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55316C14001':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55316C14002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55310C02033':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55310C02034':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55310C02035':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55310C02036':
                check_counter_zero(counter_id, counter_values)
    return counter_verification_failed


def check_cb010636_b_13_counters(counters):
    """
    Check if values of params correct for CB010636-B-13
    :param counters: array
        Array of counters fetched from gNB
    :return: boolean
        Check of counters successful=True or failed=False
    """
    cells_counters = counters['BTS']['MRBTS-79050']['NRBTS-79050']
    cell_a_counters = cells_counters['NRCELL-260']
    cell_b_counters = cells_counters['NRCELL-261']
    cell_c_counters = cells_counters['NRCELL-262']
    for counter_type in cell_a_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55309C00036':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00037':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00002':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00003':
                check_counter_incremented(counter_id, counter_values)
    for counter_type in cell_b_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55309C00036':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00037':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00002':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00003':
                check_counter_incremented(counter_id, counter_values)
    for counter_type in cell_c_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55309C00036':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00037':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00002':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00003':
                check_counter_incremented(counter_id, counter_values)
    for counter_type in cell_a_counters['NRPMQAP-1'].values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55373C00001':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55373C00002':
                check_counter_incremented(counter_id, counter_values)
    for counter_type in cell_b_counters['NRPMQAP-1'].values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55373C00001':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55373C00002':
                check_counter_zero(counter_id, counter_values)
    for counter_type in cell_a_counters['NRPMQAP-2'].values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55373C00001':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55373C00002':
                check_counter_zero(counter_id, counter_values)
    for counter_type in cell_b_counters['NRPMQAP-2'].values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55373C00001':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55373C00002':
                check_counter_zero(counter_id, counter_values)
    return counter_verification_failed


def check_cb010636_b_19_counters(counters):
    """
    Check if values of params correct for CB010636-B-19
    :param counters: array
        Array of counters fetched from gNB
    :return: boolean
        Check of counters successful=True or failed=False
    """
    cells_counters = counters['BTS']['MRBTS-79050']['NRBTS-79050']
    cell_a_counters = cells_counters['NRCELL-260']
    cell_b_counters = cells_counters['NRCELL-261']
    cell_c_counters = cells_counters['NRCELL-262']
    for counter_type in cell_a_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55309C00036':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00037':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00002':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00003':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55349C03002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55349C04002':
                check_counter_zero(counter_id, counter_values)
    for counter_type in cell_b_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55309C00036':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00037':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00002':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00003':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55349C03002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55349C04002':
                check_counter_zero(counter_id, counter_values)
    for counter_type in cell_c_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55309C00036':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00037':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00002':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00003':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55349C03002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55349C04002':
                check_counter_zero(counter_id, counter_values)
    for counter_type in cell_a_counters['NRPMQAP-1'].values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55373C00001':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55373C00002':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55353C00002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55353C00003':
                check_counter_zero(counter_id, counter_values)
    for counter_type in cell_b_counters['NRPMQAP-1'].values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55373C00001':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55373C00002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55353C00002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55353C00003':
                check_counter_zero(counter_id, counter_values)
    return counter_verification_failed


def check_cb010636_b_19_counters_empty(counters):
    """
    Check if values of params correct for CB010636-B-19 when feature disabled
    :param counters: array
        Array of counters fetched from gNB
    :return: boolean
        Check of counters successful=True or failed=False
    """
    cells_counters = counters['BTS']['MRBTS-79050']['NRBTS-79050']
    cell_a_counters = cells_counters['NRCELL-260']
    cell_b_counters = cells_counters['NRCELL-261']
    cell_c_counters = cells_counters['NRCELL-262']
    for counter_type in cell_a_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55309C00036':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00037':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00003':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55349C03002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55349C04002':
                check_counter_zero(counter_id, counter_values)
    for counter_type in cell_b_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55309C00036':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00037':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00003':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55349C03002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55349C04002':
                check_counter_zero(counter_id, counter_values)
    for counter_type in cell_c_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55309C00036':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00037':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00003':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55349C03002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55349C04002':
                check_counter_zero(counter_id, counter_values)
    for counter_type in cell_a_counters['NRPMQAP-1'].values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55373C00001':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55373C00002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55353C00002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55353C00003':
                check_counter_zero(counter_id, counter_values)
    for counter_type in cell_b_counters['NRPMQAP-1'].values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55373C00001':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55373C00002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55353C00002':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55353C00003':
                check_counter_zero(counter_id, counter_values)
    return counter_verification_failed


def check_cb010636_c_10_counters(counters):
    """
    Check if values of params correct for CB010636-C-10
        :param counters: array
    Array of counters fetched from gNB
        :return: boolean
    Check of counters successful=True or failed=False
    """
    cells_counters = counters['BTS']['MRBTS-79050']['NRBTS-79050']
    cell_a_counters = cells_counters['NRCELL-260']
    cell_b_counters = cells_counters['NRCELL-261']
    for counter_type in cell_a_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55309C00004':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00005':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00006':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00007':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00008':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00009':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00010':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00011':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00020':
                check_counter_almost_zero_cc(counter_id, counter_values)
            if counter_id == 'M55309C00021':
                check_counter_almost_zero_cc(counter_id, counter_values)
            if counter_id == 'M55309C00022':
                check_counter_almost_zero_cc(counter_id, counter_values)
            if counter_id == 'M55309C00023':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00024':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00025':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00026':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00027':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00036':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00037':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00002':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00003':
                check_counter_incremented(counter_id, counter_values)
    for counter_type in cell_b_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55309C00004':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00005':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00006':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00007':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00008':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00009':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00010':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00011':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00020':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00021':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00022':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00023':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00024':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00025':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00026':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00027':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00036':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00037':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00002':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00003':
                check_counter_incremented(counter_id, counter_values)
    return counter_verification_failed


def check_cb010636_c_11_counters(counters):
    """
    Check if values of params correct for CB010636-C-11
    :param counters: array
        Array of counters fetched from gNB
    :return: boolean
        Check of counters successful=True or failed=False
    """
    cells_counters = counters['BTS']['MRBTS-79050']['NRBTS-79050']
    cell_a_counters = cells_counters['NRCELL-260']
    cell_b_counters = cells_counters['NRCELL-261']
    for counter_type in cell_a_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55309C00004':
                check_counter_almost_zero_cc(counter_id, counter_values)
            if counter_id == 'M55309C00005':
                check_counter_almost_zero_cc(counter_id, counter_values)
            if counter_id == 'M55309C00006':
                check_counter_almost_zero_cc(counter_id, counter_values)
            if counter_id == 'M55309C00007':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00008':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00009':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00010':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00011':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00020':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00021':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00022':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00023':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00024':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00025':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00026':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00027':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00036':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00037':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00002':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00003':
                check_counter_incremented(counter_id, counter_values)
    for counter_type in cell_b_counters.values():
        for counter_id, counter_values in counter_type.items():
            if counter_id == 'M55309C00004':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00005':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00006':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00007':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00008':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00009':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00010':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00011':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00020':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00021':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00022':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00023':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00024':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00025':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00026':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00027':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00036':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00037':
                check_counter_zero(counter_id, counter_values)
            if counter_id == 'M55309C00002':
                check_counter_incremented(counter_id, counter_values)
            if counter_id == 'M55309C00003':
                check_counter_incremented(counter_id, counter_values)
    return counter_verification_failed
