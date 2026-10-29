"""
:copyright: Nokia Networks
:author: Dawid Krawczuk <dawid.krawczuk@nokia.com>
:maintainer: Dawid Krawczuk <dawid.krawczuk@nokia.com>
"""
import copy
import pprint
import re
import traceback

from robot.libraries.BuiltIn import BuiltIn
from ta_emss.utilities.rtpmconverter import NoRtpmIntervalCollected as _NoRtpmIntervalCollected

COUNTERS_TO_VERIFY = {}


def _eq_func(value, *num):
    print('Received type of value: {}'.format(value))
    return True if value == int(num[0]) else False


def _neq_func(value, *num):
    print('Received type of value: {}'.format(value))
    return True if value != int(num[0]) else False


def _geq_func(value, *num):
    print('Received type of value: {}'.format(value))
    return True if value >= int(num[0]) else False


def _g_func(value, *num):
    print('Received type of value: {}'.format(value))
    return True if value > int(num[0]) else False


def _l_func(value, *num):
    print('Received type of value: {}'.format(value))
    return True if value < int(num[0]) else False


def _leq_func(value, *num):
    print('Received type of value: {}'.format(value))
    return True if value <= int(num[0]) else False


def _range_func(value, *num):
    print('Received type of value: {}'.format(value))
    return True if value in range(int(num[0]), int(num[1])) else False


ALLOWED_VERIFICATION_CONDITIONS = {
    re.compile(r'^eq (\d+)$'): {'func': _eq_func, 'name': r'eq \d+'},
    re.compile(r'^!=\s?(\d+)$'): {'func': _neq_func, 'name': r'!=\d+'},
    re.compile(r'^>=\s?(\d+)$'): {'func': _geq_func, 'name': r'>=\d+'},
    re.compile(r'^>\s?(\d+)$'): {'func': _g_func, 'name': r'>\d+'},
    re.compile(r'^<\s?(\d+)$'): {'func': _l_func, 'name': r'<\d+'},
    re.compile(r'^<=\s?(\d+)$'): {'func': _leq_func, 'name': '<='},
    re.compile(r'^in range\((\d+),\s?(\d+)\)$'):
    {'func': _range_func, 'name': r'in range(\d+,\d+)'}
}


def _get_conditional_verification_function_and_params(verification_condition):
    for allowed_condition_regexp in ALLOWED_VERIFICATION_CONDITIONS:
        if allowed_condition_regexp.search(verification_condition):
            function = ALLOWED_VERIFICATION_CONDITIONS[allowed_condition_regexp]['func']
            if 'no_params' not in ALLOWED_VERIFICATION_CONDITIONS[allowed_condition_regexp]:
                params = allowed_condition_regexp.findall(
                    verification_condition)[0]
            else:
                params = None
            return function, params
    raise Exception('No function matching sentence: {}\nAllowed conditions:\n{}'
                    .format(verification_condition,
                            pprint.pformat([ALLOWED_VERIFICATION_CONDITIONS[ac]['name']
                                            for ac in ALLOWED_VERIFICATION_CONDITIONS])))


def add_rtpm_for_validation(counter_id, object_id, value, description="", overwrite=False):
    """
    Before running the keyword use rtpm_activate keyword and start_rtpm_collection_interval.
    Non-blocking function, used to add counter to veirifcation queue.
    Counter id must be exact counter number.
    Object id may be full path or any string sub-path. String-based comparision is being made.
    Value can be from following:
    eq x
    !=x
    >=x
    >x
    <x
    <=x
    in range(x,y)
    Description is just user-friendly addition to easily connect counter value with counter name/function
    Overwrite is used overwrite values in consecutive counter checks.

    """
    object_id_key = "{};{}".format(counter_id, object_id)
    if overwrite is False:
        assert object_id_key not in COUNTERS_TO_VERIFY, \
            'Counter: {} already set, clear before re-using or use overwrite'.format(
                object_id_key)
    ver_function, params = _get_conditional_verification_function_and_params(
        str(value))
    COUNTERS_TO_VERIFY[object_id_key] = {'object_id': object_id, 'counter_id': counter_id,
                                         'value': value, 'ver_function': ver_function, 'params': params,
                                         'description': description}
    print('Counter: {} successfully added for verification with value: {}'.format(
        object_id_key, value))


def clear_rtpm_verification_queue():
    """
    Clears the queue from all expected cuonter values.
    """
    global COUNTERS_TO_VERIFY
    COUNTERS_TO_VERIFY = {}
    print('Cleared entire rtpm verifcation queue')


def _print_verification_queue():
    a = 'Verification queue:\n{}'.format("\n".join(COUNTERS_TO_VERIFY.keys()))
    print(a)
    return a


def clear_selected_rtpm_counter(counter_id, object_id=None):
    """
    Clear selected counter on given object only or on all objects (cells/PMQAP objects) if necessary.
    If object_id not provided, clears all counters on all objects
    """
    removed = False
    global COUNTERS_TO_VERIFY
    if object_id:
        object_id_key = "{};{}".format(counter_id, object_id)
        del COUNTERS_TO_VERIFY[object_id_key]
        print('Removed: {} from verification queue'.format(object_id_key))
        removed = True
    else:
        for value_dict in copy.deepcopy(COUNTERS_TO_VERIFY).values():
            if value_dict['counter_id'] == counter_id.strip():
                object_id_key = "{};{}".format(
                    value_dict['counter_id'], value_dict['object_id'])
                print('Removed: {} from verification queue'.format(object_id_key))
                del COUNTERS_TO_VERIFY[object_id_key]
                removed = True
    assert removed is True, \
        'Nothing has been removed! Current state of verification queue: {}'.format(
            _print_verification_queue())
    _print_verification_queue()


def verify_rtpm_counters(bts_id=1, timeout=240):
    """
    Keyword to verify the all counters that were added to the queue.
    Keyword automatically waits up to timeout before verify the counters.
    Timeout is realised as n * 120s sub-periods, while for each 120s keyword is waiting for new rtpm reception.
    During the verification all counters are checked and corresponding errors are collected
    and displayed at the end of keyword.
    """
    print('Verifying following counters')
    _print_verification_queue()
    ta_emss_inst = BuiltIn().get_library_instance('ta_emss')
    timeout_max_wait_intervals = int(timeout / 120)
    exceptions = []
    for counter_dict in COUNTERS_TO_VERIFY.values():
        object_id = counter_dict['object_id']
        counter_id = counter_dict['counter_id']
        counter_description = counter_dict['description']
        expected_value_condition = counter_dict['value']
        ver_func = counter_dict['ver_function']
        ver_params = counter_dict['params']
        while timeout_max_wait_intervals > 0:
            ta_emss_inst.wait_for_clean_rtpm_interval(clean_rtpm_files=False, wait_threshold=1,
                                                      timeout=120, bts_id=bts_id)
            try:
                counter_value = int(ta_emss_inst.get_value_of_rtpm_if_exists(object_name=object_id,
                                                                             counter_id=counter_id,
                                                                             bts_id=bts_id))
                timeout_max_wait_intervals = 0
            except _NoRtpmIntervalCollected:
                timeout_max_wait_intervals -= 1
        counter_value = int(ta_emss_inst.get_value_of_rtpm_if_exists(
            object_name=object_id, counter_id=counter_id, bts_id=bts_id))
        try:
            result = ver_func(counter_value, *ver_params)
        except Exception as e:
            traceback.print_exc()
            raise Exception(
                'Could not verify counter: {} due to exception:\n{}'.format(counter_id, e))
        if result is False:
            exc = "Counter: {}:{}{} with value: {} does not fulfill condition: {}"\
                .format(object_id, counter_id,
                        "" if not counter_description else " ({})".format(
                            counter_description),
                        counter_value, expected_value_condition)
            exceptions.append(exc)
        else:
            print("Counter: {}:{}{} with value: {} fulfilled condition: {}"
                  .format(object_id, counter_id,
                          "" if not counter_description else " ({})".format(
                              counter_description),
                          counter_value, expected_value_condition))
        if len(exceptions):
            exc_string = "RTPM verification failed with following exceptions:\n{}".format(
                "\n".join(exceptions))
            raise Exception(exc_string)


if __name__ == '__main__':
    add_rtpm_for_validation('X0', 'Y0', 'eq 1')
    add_rtpm_for_validation('X0', 'Y1', '>1')
    add_rtpm_for_validation('X0', 'Y2', '>=1')
    add_rtpm_for_validation('X0', 'Y3', '<1')
    add_rtpm_for_validation('X0', 'Y4', '<=1')
    add_rtpm_for_validation('X0', 'Y5', '!=1')
    add_rtpm_for_validation('X0', 'Y6', 'in range(5,10)')
    add_rtpm_for_validation('X1', 'Y6', 'in range(5,10)')
    add_rtpm_for_validation('X1', 'Y7', 'in range(5,10)')
    clear_selected_rtpm_counter('X0', 'Y0')
    clear_selected_rtpm_counter('X0', 'Y1')
    clear_selected_rtpm_counter('X1')
