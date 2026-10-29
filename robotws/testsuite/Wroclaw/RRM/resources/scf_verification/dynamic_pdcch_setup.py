from testsuite.Wroclaw.RRM.resources.log.log import blog

bwpDN = 'bwpDN'
chBwUl = 'chBwUl'
chBwDl = 'chBwDl'
type0Coreset = 'type0CoresetConfigurationIndex'
msg1_frequency_start = 'msg1FrequencyStart'
msg = 'Parameter: {param}\nCurrent: {current_value}\nExpected: {expected_value}\n'


def check_expected_pdcch_parameters(scf, bandwidth):
    check_bwp_profile(scf, bandwidth)
    check_chbw(scf, bandwidth)
    check_type0Coreset(scf, bandwidth)
    check_msg1_frequency_start(scf, bandwidth)


def check_bwp_profile(scf, bandwidth):
    fetched_values = scf.get_all_values_from_scf(p_name=bwpDN)
    for idx, value in enumerate(fetched_values):
        value = value.split('-')[-1]
        bwp_profile_ids = get_bwp_profile_id_for_given_bandwidth(bandwidth)
        if idx % 2 == 0:
            expected_value = bwp_profile_ids[0]
        else:
            expected_value = bwp_profile_ids[1]

        blog(msg.format(param=bwpDN, current_value=value, expected_value=expected_value))
        assert int(value) == int(expected_value), blog('bwp profile is incorrect.')


def check_chbw(scf, bandwidth):
    params_to_check = [chBwUl, chBwDl]
    expected_value = bandwidth + 'MHz'
    for param in params_to_check:
        fetched_values = scf.get_all_values_from_scf(p_name=param)

        for idx, value in enumerate(fetched_values):
            blog(msg.format(param=param, current_value=value, expected_value=expected_value))
            assert value == expected_value, blog('chbW value is incorrect.')


def check_type0Coreset(scf, bandwidth):
    expected_value = get_type0_coreset_for_given_bandwidth(bandwidth)
    fetched_values = scf.get_all_values_from_scf(p_name=type0Coreset)
    for idx, value in enumerate(fetched_values):
        blog(msg.format(param=type0Coreset, current_value=value, expected_value=expected_value))
        assert int(value) == int(expected_value), blog('type0CoresetConfigurationIndex value is incorrect.')


def check_msg1_frequency_start(scf, bandwidth):
    expected_value = get_msg1_frequency_start_for_given_bandwidth(bandwidth)
    fetched_values = scf.get_all_values_from_scf(p_name=msg1_frequency_start)
    for idx, value in enumerate(fetched_values):
        blog(msg.format(param=msg1_frequency_start, current_value=value, expected_value=expected_value))
        assert int(value) == int(expected_value), blog('msg1FrequencyStart value is incorrect.')


def setup_expected_pdcch_parameters(scf, bandwidth):
    setup_bwp_profile(scf, bandwidth)
    setup_chbw(scf, bandwidth)
    setup_type0Coreset(scf, bandwidth)
    setup_msg1_frequency_start(scf, bandwidth)
    setup_actpdschatssbslots(scf, bandwidth)


def setup_bwp_profile(scf, bandwidth):
    fetched_values = scf.get_all_values_from_scf(p_name=bwpDN)
    for idx, value in enumerate(fetched_values):
        bwp_profile_ids = get_bwp_profile_id_for_given_bandwidth(bandwidth)
        value = value.split('-')[:-1]
        value = '-'.join(value) + '-'

        if idx % 2 == 0:
            bwp_to_set = value + str(bwp_profile_ids[0])
            scf.modify_scf_element(value=bwp_to_set, p_name=bwpDN, index=idx)
        else:
            bwp_to_set = value + str(bwp_profile_ids[1])
            scf.modify_scf_element(value=bwp_to_set, p_name=bwpDN, index=idx)


def setup_chbw(scf, bandwidth):
    params_to_set = [chBwUl, chBwDl]
    chbw_to_set = bandwidth + 'MHz'
    for param in params_to_set:
        fetched_values = scf.get_all_values_from_scf(p_name=param)
        for idx, value in enumerate(fetched_values):
            scf.modify_scf_element(value=chbw_to_set, p_name=param, index=idx)


def setup_type0Coreset(scf, bandwidth):
    expected_value = get_type0_coreset_for_given_bandwidth(bandwidth)
    fetched_values = scf.get_all_values_from_scf(p_name=type0Coreset)
    for idx, value in enumerate(fetched_values):
        scf.modify_scf_element(value=expected_value, p_name=type0Coreset, index=idx)


def setup_msg1_frequency_start(scf, bandwidth):
    expected_value = get_msg1_frequency_start_for_given_bandwidth(bandwidth)
    fetched_values = scf.get_all_values_from_scf(p_name=msg1_frequency_start)
    for idx, value in enumerate(fetched_values):
        scf.modify_scf_element(value=expected_value, p_name=msg1_frequency_start, index=idx)


def setup_actpdschatssbslots(scf, bandwidth):
    expected_value = 'false' if bandwidth == '5' else 'true'
    fetched_values = scf.get_all_values_from_scf(p_name='actPdschAtSsbSlots')
    for idx, value in enumerate(fetched_values):
        scf.modify_scf_element(value=expected_value, p_name='actPdschAtSsbSlots', index=idx)


def get_bwp_profile_id_for_given_bandwidth(bandwidth):
    bwp_profile_mapping = {'5': (9, 30), '10': (4, 31), '15': (4, 32), '20': (4, 33)}
    return bwp_profile_mapping[bandwidth]


def get_type0_coreset_for_given_bandwidth(bandwidth):
    type0Coreset_mapping = {'5': 0, '10': 6, '15': 6, '20': 6}
    return type0Coreset_mapping[bandwidth]


def get_msg1_frequency_start_for_given_bandwidth(bandwidth):
    msg1_frequency_start_mapping = {'5': 5, '10': 5, '15': 7, '20': 7}
    return msg1_frequency_start_mapping[bandwidth]
