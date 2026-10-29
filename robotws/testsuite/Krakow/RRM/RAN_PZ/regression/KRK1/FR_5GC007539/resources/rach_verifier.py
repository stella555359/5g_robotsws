import logging
import re
import csv


def check_prach_received_messages(l1l2_file, prach_config, prach_config_index):
    logging.basicConfig(level=logging.INFO)
    prach_configuration_slot, prach_configuration_sfn = _parse_expected_prach_configuration(prach_config)
    assert prach_config_index in prach_configuration_slot, \
        "prachConfigurationIndex {} not in expected prach slot configuration {}".format(
            prach_config_index,
            prach_configuration_slot
        )
    logging.info("Prach Expected sfn value MOD {} must be equal to {}".format(
        str(prach_configuration_sfn[prach_config_index][0]),
        str(prach_configuration_sfn[prach_config_index][1])
    ))
    logging.info("Prach Expected slot: {}".format(
        str(prach_configuration_slot[prach_config_index])
    ))
    _validate_l1l2_logs(
        l1l2_file,
        prach_config_index,
        prach_configuration_slot,
        prach_configuration_sfn
    )


def _parse_expected_prach_configuration(prach_config):
    """
    Read from given configuration line the expected PRACH sfn and slot for each defined prach configuration
    example:  175:8,1:9,19,29,39,49,59,69,79
    """

    prach_config = prach_config.split(":")
    prach_configuration_index = prach_config[0]
    prach_sfns = prach_config[1].split(',')
    prach_slots = prach_config[2].split(',')

    prach_configuration_slot = {
        prach_configuration_index: [int(x) for x in prach_slots]
    }
    prach_configuration_sfn = {
        prach_configuration_index: [int(x) for x in prach_sfns]
    }
    return prach_configuration_slot, prach_configuration_sfn


def _validate_l1l2_logs(l1l2_filepath, prach_configuration_index, prach_configuration_slot, prach_configuration_sfn):
    prach_slot_used = []

    with open(l1l2_filepath, 'r') as l1l2:
        reader = csv.reader(l1l2, delimiter=',')
        next(reader)
        for line in reader:
            current_prach_sfn = int(line[1])
            _verify_prach_sfn(
                current_prach_sfn,
                prach_configuration_sfn[prach_configuration_index]
            )
            current_prach_slot = int(line[2])
            _verify_prach_slot(
                current_prach_slot,
                prach_configuration_slot[prach_configuration_index]
            )
            if current_prach_slot not in prach_slot_used:
                prach_slot_used.append(current_prach_slot)

    for slotKey in prach_configuration_slot[prach_configuration_index]:
        if slotKey not in prach_slot_used:
            logging.warning("Slot defined in prach configuration file is not used: {}".format(
                str(slotKey)
            ))


def _verify_prach_sfn(current_prach_sfn, config_prach_sfn):
    division_remainder = current_prach_sfn % config_prach_sfn[0]
    assert division_remainder == config_prach_sfn[1], \
        "{} MOD {} must be set to {}, ".format(
            current_prach_sfn,
            config_prach_sfn[0],
            config_prach_sfn[1]
        )


def _verify_prach_slot(current_prach_slot, expected_prach_slots):
    assert current_prach_slot in expected_prach_slots, \
        "Slot {} expected In PrachReceiveRequest: {}".format(
            str(current_prach_slot),
            str(expected_prach_slots)
        )
