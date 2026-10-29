import testsuite.Wroclaw.RRM.resources.tti_verification.csv_verification as ttiv
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog

default_scf_params = {'actDl256Qam': 'true', 'dllaIniMcs': '3', 'ullaIniMcs': '0', 'actEnhancedLinkAdaptation': 'true',
                      'ullaDeltaSinrStepdown': '25', 'dllaDeltaCqiStepdown': '25'}

SLOTS_PER_SFN = 10


def check_that_laIniDelta_is_updated_correctly(tti_filepath):
    lainidelta_msg, harq_msg, fdsched_msg, ladelta_msg = \
        _get_messages_needed_for_lainidelta_update_check(tti_filepath)
    blog('laIniDelta:   {}\nFdSchedData:   {}\nHarqRxData:   {}\nLaDelta:   {}'
         .format(lainidelta_msg, fdsched_msg, harq_msg, ladelta_msg))
    _assert_lainidelta_conditions(lainidelta_msg, harq_msg, fdsched_msg)


def _get_messages_needed_for_lainidelta_update_check(tti_filepath):
    lainidelta_msg = _get_lainidelta_msg(tti_filepath)
    ladelta_msg = _get_ladelta_message_related_to_lainidelta(tti_filepath, lainidelta_msg)
    harq_feedback = _get_harq_feedback_related_to_given_ladelta(tti_filepath, ladelta_msg)
    fdshed_msg = _get_fdscheddata_related_to_given_harq(tti_filepath, harq_feedback)
    return lainidelta_msg, harq_feedback, fdshed_msg, ladelta_msg


def _get_lainidelta_msg(tti_filepath):
    ini_data = ttiv.process_needed_messages(tti_filepath, ['laIniDelta'])
    assert len(ini_data) == 1, "No laIniDelta message found (or more than 1)." \
                               " Number of found messages: {}".format(len(ini_data))
    return ini_data[0]


def _get_harq_feedback_related_to_given_ladelta(tti_filepath, ladelta):
    harq_msg_name = 'dlHarqRxDataArray' if 'Cqi' in ladelta['message_name'] else 'ulHarqRxData'
    harq_data = ttiv.process_needed_messages(tti_filepath, [harq_msg_name])
    return _determine_nearest_neighbour_message(harq_data, ladelta)


def _get_fdscheddata_related_to_given_harq(tti_filepath, harq_msg):
    direction = harq_msg['message_name'][:2]
    fdsched_data = ttiv.process_needed_messages(tti_filepath, ['{}FdSchedData'.format(direction)])
    harq_process_ind = harq_msg['{}HarqProcessIndex'.format(direction)]
    harq_reference_slot_val = int(harq_msg['sfn']) * SLOTS_PER_SFN + int(harq_msg['slot'])
    candidates = []
    for msg in fdsched_data:
        distance = int(msg['K1']) if direction == 'dl' else 0
        if (int(msg['sfn']) * SLOTS_PER_SFN + int(msg['slot']) + distance) == harq_reference_slot_val \
                and msg['{}HarqProcessIndex'.format(direction)] == harq_process_ind:
            candidates.append(msg)
    return _determine_nearest_neighbour_message(candidates, harq_msg)


def _get_ladelta_message_related_to_lainidelta(tti_filepath, lainidelta):
    message_name = 'dlLaDeltaCqiArray' if 'CQI' in lainidelta['id'] else 'ulLaDeltaSinr'
    ladelta_data = ttiv.process_needed_messages(tti_filepath, [message_name])
    return _determine_nearest_neighbour_message(ladelta_data, lainidelta)


def _assert_lainidelta_conditions(lainidelta_msg, harq_msg, fdsched_msg):
    param = lainidelta_msg['id'].split('_')[-1].capitalize()
    direction = harq_msg['message_name'][:2].capitalize()
    mcs = int(fdsched_msg['rrm{}UsedMcs'.format(direction)])

    assert lainidelta_msg['event'] == 'UPDATE' and mcs < 28, 'Highest mcs used to update ini{}'.format(param)


def _determine_nearest_neighbour_message(candidates, message, max_distance=200):
    best_candidate = None
    best_score = 999999
    for msg in candidates:
        score = message['line_number'] - msg['line_number']
        score = score if score >= 0 else 0 - score
        if score < best_score and score <= max_distance:
            best_score = score
            best_candidate = msg
    return best_candidate
