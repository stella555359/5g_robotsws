"""
:copyright: Nokia Networks
:authors:
    Arkadiusz Sobejko <arkadiusz.sobejko@nokia.com>
:maintainers:
    Arkadiusz Sobejko <arkadiusz.sobejko@nokia.com>
"""
from ta5g_pm_counters import ta5g_pm_counters
from ta_egate_cmd_parser import ta_egate_cmd_parser
from ta_emss import ta_emss
from ta_messaging.message_flows import get_flow
from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.csv_verifiers import csv_verifiers


csv_bip = csv_verifiers()
pm_counters = ta5g_pm_counters()
ta_egate = ta_egate_cmd_parser()


def wait_for_next_raw_pm_interval_and_get_raw_counters():
    """
    wait_for_next_pm_interval_and_get_counters - lets to collect pm counters from latest pm interval
    +------------------+-------+------------+------------+------------+
    |     Example                                                     |
    +==================+=======+============+============+============+
    | ${pm_counters}=  Wait for next pm interval and get counters     |
    +------------------+-------+------------+------------+------------+

    :return:  file with last pm counters
    """
    pm_counters_file = pm_counters.get_next_unpacked_raw_rd_counters_file()
    return pm_counters_file


def get_from_message(flow_alias, message_alias, field):
    """
    Gets specific field value from message of specific flow
    :param flow_alias: flow aliases from earlier defined flow
    :param message_alias: message aliases from earlier defined flow
    :param field: filed which lokking in message
    :return: filed from message
    """
    msg = get_flow(flow_alias).get_message(message_alias)
    field_values = msg.get_all_values_by_key(field)
    if len(field_values) > 1:
        if field != 'eventId':
            return field_values[0]
        field_value_list = list()
        for field_value in field_values:
            field_value_list.append(field_value.keys()[0])
        return field_value_list
    else:
        return field_values[0]


def verify_nrrel_mro_counters(counter, localmoid, filepath, value, nrrel=1):
    """
        Get counter values from specific NRREL on cell
        :param counter: counter id or counter name
        :param localmoid: for example NRCELL-1
        :param filepath: path to xml with counters
        :param nrrel: nrrel id
    """
    counter_value = pm_counters.get_pm_counter_value(counter, localmoid, filepath)[nrrel - 1]
    assert int(counter_value) == int(value), f"counter {counter} value {counter_value} is not as expected value {value}"


def verify_ue_is_on_cell(ue_id, cell_id):
    """
        Check if ue is on cell
        :param ue_id: ue id
        :param cell_id: cell id
    """
    cmd = ta_egate.get_command('ue_disp')
    ue_location = cmd(id=ue_id).execute_and_parse()['cell']['Value']
    assert int(cell_id) == int(ue_location), f"UE {ue_id} is on wrong cell-{ue_location}, should be on cell-{cell_id}"


def verify_dc_state(ue_id, state):
    """
        Check on egate console NR-DC state
        :param ue_id: ue id
        :param state: wanted NR-DC state
    """
    cmd = ta_egate.get_command('ue_disp')
    dc_state = cmd(id=ue_id).execute_and_parse()['DC state']['Value']
    assert dc_state == state, f"UE {ue_id} is not in expected NR-DC expected:{state}, but is {dc_state}"
