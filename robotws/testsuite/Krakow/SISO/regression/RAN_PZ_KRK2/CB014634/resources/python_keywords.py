import logging
from time import sleep
from datetime import datetime, timedelta, timezone
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations as RuOp
from taf.rfrl.procedures.resources.python.testline.TestLine import TestLine
from testsuite.Krakow.SISO.resources.RAN_PZ_KRK2.Blackbox.RmodOpCustom import RmodOpCustom
from taf.sbts.oam.coam.admin import admin

RuOp = RuOp()
RmodOpCustom = RmodOpCustom()


def get_timestamp_of_ru_startup(ru_id):
    rmod_id = get_rmod_id(ru_id)
    admin_obj = admin()
    admin_connection = admin_obj.connect_to()
    timestamp = RmodOpCustom.get_date_of_last_rmod_startup(rmod_id, admin_connection)
    admin_obj.teardown_admin()
    return timestamp


def reset_ru_and_wait_until_online_with_saving_timestamp(ru_id):
    timestamp = []
    rmod_id = get_rmod_id(ru_id)
    testline = TestLine()
    logging.info('Trigger reset of ru_{} ({})'.format(ru_id, testline.get_radio_serial_number(ru_id=ru_id)))
    timestamp.append(datetime.now())
    RuOp.reset_radio_unit(radio_unit_id=rmod_id)
    timestamp.append(datetime.now())
    logging.info('Waiting for {} to be online'.format(ru_id))
    RuOp.wait_for_radio_unit_to_be_online(ru_id=rmod_id)
    timestamp.append(datetime.now())
    timestamp.append(get_timestamp_of_ru_startup(ru_id))
    logging.info(
        "Timestamps [start of reset kw, end of reset keyword, ru become online, ru startup timestamp]: {}".format(
            [str(t) for t in timestamp]))
    logging.info("returning ru startup timestamp]: {}".format(timestamp[3]))
    return timestamp[3]


def get_rmod_id(ru_id):
    return int(RuOp.get_radio_unit_configuration_based_on_tl_config_id(ru_id)['configuration_id'])


def verify_number_of_samples_appeared_in_voltage_histograms(histograms_dict_1, histograms_dict_2,
                                                            expected_min_number_new_samples,
                                                            expected_max_number_new_samples):
    """Verifies Voltage values for all Voltage items present in given dictionaries"""
    assert histograms_dict_1.keys() == histograms_dict_2.keys(), "Item IDs of Voltage items in first histogram do not" \
                                                                 " match Item IDs in second histogram"
    if len(histograms_dict_1) > 1 or len(histograms_dict_2) > 1:
        logging.warning("More than one Voltage item found. Will verify incrementation for all of them.")

    wrong_number_of_samples_detected = False

    for item_id, voltage_data in histograms_dict_1.items():
        sum_values_dict_1 = sum(histograms_dict_1[item_id]["values"])
        sum_values_dict_2 = sum(histograms_dict_2[item_id]["values"])
        actual_number_of_new_samples = sum_values_dict_2 - sum_values_dict_1
        logging.debug("Voltage Item ID: {}".format(item_id))
        logging.debug("sum of all samples on 'Values' row in dict 1: {}".format(sum_values_dict_1))
        logging.debug("sum of all samples on 'Values' row in dict 2: {}".format(sum_values_dict_2))
        logging.debug("actual number of new samples: {}".format(actual_number_of_new_samples))

        if actual_number_of_new_samples < expected_min_number_new_samples or \
                actual_number_of_new_samples > expected_max_number_new_samples:
            wrong_number_of_samples_detected = True
            logging.warning("Wrong number of samples appeared in Voltage histogram for Item ID: {}. Actual: {}, "
                            "expected range: <{}, {}>".format(item_id, actual_number_of_new_samples,
                                                              expected_min_number_new_samples,
                                                              expected_max_number_new_samples))

    assert not wrong_number_of_samples_detected, "Wrong number of samples appeared in Voltage histogram for at least " \
                                                 "one Item ID, please check warnings in the log"


def verify_number_of_samples_appeared_in_current_histograms(histograms_dict_1, histograms_dict_2,
                                                            expected_min_number_new_samples,
                                                            expected_max_number_new_samples):
    """Verifies Current (electric current) values for all Current items present in given dictionaries"""
    assert histograms_dict_1.keys() == histograms_dict_2.keys(), "Item IDs of Current items in first histogram do not" \
                                                                 " match Item IDs in second histogram"
    if len(histograms_dict_1) > 1 or len(histograms_dict_2) > 1:
        logging.warning("More than one Current item found. Will verify incrementation of samples for all of them.")

    wrong_number_of_samples_detected = False

    for item_id, current_data in histograms_dict_1.items():
        sum_values_dict_1 = sum(histograms_dict_1[item_id]["values"])
        sum_values_dict_2 = sum(histograms_dict_2[item_id]["values"])
        actual_number_of_new_samples = sum_values_dict_2 - sum_values_dict_1
        logging.debug("Current Item ID: {}".format(item_id))
        logging.debug("sum of all samples on 'Values' row in dict 1: {}".format(sum_values_dict_1))
        logging.debug("sum of all samples on 'Values' row in dict 2: {}".format(sum_values_dict_2))
        logging.debug("actual number of new samples: {}".format(actual_number_of_new_samples))

        if actual_number_of_new_samples < expected_min_number_new_samples or \
                actual_number_of_new_samples > expected_max_number_new_samples:
            wrong_number_of_samples_detected = True
            logging.warning("Wrong number of samples appeared in Current histogram for Item ID: {}. Actual: {}, "
                            "expected range: <{}, {}>".format(item_id, actual_number_of_new_samples,
                                                              expected_min_number_new_samples,
                                                              expected_max_number_new_samples))

    assert not wrong_number_of_samples_detected, "Wrong number of samples appeared in Current histogram for at least " \
                                                 "one Item ID, please check warnings in the log"


def wait_time_since_reset(timestamp, minutes=0, seconds=0):
    target_timestamp = timestamp + timedelta(minutes=minutes, seconds=seconds)
    logging.info("Time now: {}, waiting until: {}".format(datetime.now(), target_timestamp))
    if datetime.now() > target_timestamp:
        logging.warning("Time already passed before wait_time_since_reset keyword started")
    while datetime.now() <= target_timestamp:
        sleep(1)
    logging.info("wait_time_since_reset keyword finished")


def get_current_date_in_utc_format():
    return datetime.now(timezone.utc)
