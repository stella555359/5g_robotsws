import logging


def _parse_expected_prach_configuration(prach_config_filepath):
    """
    Read from prach configuration file the expected PRACH sfn and slot for each defined prach configuration
    First line contains descriptions and is ignored.
    """
    prach_configuration_slot = {}
    prach_configuration_sfn = {}
    with open(prach_config_filepath, 'r') as prach_config:
        for line in prach_config.readlines()[1:]:
            prach_configuration_index, prach_line_sfn, prach_line_slot = line.split(":")[:3]
            prach_configuration_slot[prach_configuration_index] = []
            prach_configuration_sfn[prach_configuration_index] = []
            for single_sfn in prach_line_sfn.split(","):
                prach_configuration_sfn[prach_configuration_index].append(
                    int(single_sfn)
                )
            for single_slot in prach_line_slot.split(","):
                prach_configuration_slot[prach_configuration_index].append(
                    int(single_slot)
                )
    return prach_configuration_slot, prach_configuration_sfn


def _verify_prach_received_sfn(current_prach_sfn, config_prach_sfn):
    division_remainder = current_prach_sfn % config_prach_sfn[0]
    if len(config_prach_sfn) >= 2:
        assert division_remainder == config_prach_sfn[1], \
            "{} MOD {} must be set to {}, ".format(
                current_prach_sfn,
                config_prach_sfn[0],
                config_prach_sfn[1]
            )
    if len(config_prach_sfn) >= 3:
        assert division_remainder == config_prach_sfn[2], \
            "{} MOD {} must be set to {}, ".format(
                current_prach_sfn,
                config_prach_sfn[0],
                config_prach_sfn[2]
            )


def _verify_prach_received_slot(current_prach_slot, expected_prach_slots):
    assert current_prach_slot in expected_prach_slots, \
        "Slot {} expected In PrachReceiveRequest: {}".format(
            str(current_prach_slot),
            str(expected_prach_slots)
        )


def _validate_l1l2_logs(l1l2_filepath, prach_configuration_index, prach_configuration_slot, prach_configuration_sfn):
    prach_received_request_sfn = 1
    prach_received_request_slot = 2
    prach_received_indication_sfn = 1
    prach_received_indication_slot = 2
    prach_received_indication_noise_power = 4
    prach_received_indication_preambles_length = 5
    prach_received_indication_preambles_indexes = 6
    prach_received_indication_preamble_time_occasion = 7
    prach_received_indication_preambles_initial_ta = 8
    prach_received_indication_preambles_peak_metric = 9

    prach_slot_used = []
    prach_received_request = False
    prach_received_indication = False

    with open(l1l2_filepath, 'r') as l1l2:
        for line in l1l2.readlines()[1:]:
            sections = line.split(";")
            if "UlData_PrachReceiveReq" in sections[0]:
                prach_received_request = True
                current_prach_request_sfn = int(sections[prach_received_request_sfn], 10)
                _verify_prach_received_sfn(
                    current_prach_request_sfn,
                    prach_configuration_sfn[prach_configuration_index]
                )
                current_prach_request_slot = int(sections[prach_received_request_slot], 10)
                _verify_prach_received_slot(
                    current_prach_request_slot,
                    prach_configuration_slot[prach_configuration_index]
                )
                if current_prach_request_slot not in prach_slot_used:
                    prach_slot_used.append(current_prach_request_slot)
            elif "UlData_PrachReceiveInd" in sections[0]:
                prach_received_indication = True
                current_prach_indication_sfn = int(sections[prach_received_indication_sfn], 10)
                _verify_prach_received_sfn(
                    current_prach_indication_sfn,
                    prach_configuration_sfn[prach_configuration_index]
                )
                current_prach_indication_slot = int(sections[prach_received_indication_slot], 10)
                _verify_prach_received_slot(
                    current_prach_indication_slot,
                    prach_configuration_slot[prach_configuration_index]
                )
                noise_power = sections[prach_received_indication_noise_power]
                preambles_length = int(sections[prach_received_indication_preambles_indexes])
                if preambles_length > 0:
                    preambles_indexes = sections[prach_received_indication_preambles_indexes].split(',')
                    preambles_time_occasions = sections[prach_received_indication_preamble_time_occasion].split(',')
                    preambles_initial_ta = sections[prach_received_indication_preambles_initial_ta].split(',')
                    preambles_peak_metrics = sections[prach_received_indication_preambles_peak_metric].split(',')
                    logging.info("SFN: {}, Slot: {}, Number of preambles: {}, Noise power: {}".format(
                        str(current_prach_indication_sfn),
                        str(current_prach_indication_slot),
                        str(preambles_length),
                        str(noise_power)
                    ))
                for index in range(preambles_length):
                    logging.info("Preamble index: {}\ntime occasion: {}\n initial TA: {}\n Peak metric: {}".format(
                        str(int(preambles_indexes[index], 10)),
                        str(int(preambles_time_occasions[index], 10)),
                        str(int(preambles_initial_ta[index], 10)),
                        str((preambles_peak_metrics[index]))
                    ))
    assert prach_received_indication, "No prachReceiveInd in L1L2 traces"
    logging.info("Found prach received indication message")
    assert prach_received_request, "No prachReceiveReq in L1L2 traces"
    logging.info("Found prach received request message")
    for slotKey in prach_configuration_slot[prach_configuration_index]:
        if slotKey not in prach_slot_used:
            logging.warning("Slot defined in prach configuration file is not used: {}".format(
                str(slotKey)
            ))


def check_prach_received_messages(l1l2_file, prach_config_filepath, prach_config_index):
    logging.basicConfig(level=logging.INFO)
    prach_configuration_slot, prach_configuration_sfn = _parse_expected_prach_configuration(prach_config_filepath)
    assert prach_config_index in prach_configuration_slot, \
        "prachConfigurationIndex {} not in expected prach slot configuration {}".format(
            prach_config_index,
            prach_configuration_slot
        )
    logging.info("Prach Expected sfn value MOD {} must be equal to {}".format(
        str(prach_configuration_sfn[prach_config_index][0]),
        str(prach_configuration_sfn[prach_config_index][1])
    ))
    if len(prach_configuration_sfn[prach_config_index]) == 3:
        logging.info("Prach Expected sfn value MOD {} must be equal to {}".format(
            str(prach_configuration_sfn[prach_config_index][0]),
            str(prach_configuration_sfn[prach_config_index][2])
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
