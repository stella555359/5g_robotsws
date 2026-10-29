from string import Template
from robot.api.deco import keyword
import datetime
from ta5g_enb import ta5g_enb
import os

DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']

NRPGRP_ID = Template("""\
- ID: '${ID}'
  MOC: NRPGRP
""")

LIST_NAME = Template("""\
  ${list_name}:
""")

LBPS_CELL_LIST_TEMPLATE = Template("""\
    - lbpsCellSOOrder: '$lbpsCellSOOrder'
      nrCellId: '$nrCellId'
      lbpsUseExtConfig : '$lbpsUseExtConfig'
""")

LBPS_PERIOD_LIST_TIME_TEMPLATE = Template("""\
    - lbpsDayOfWeek: '$lbpsDayOfWeek'
      lbpsStartTimeHour: '$lbpsStartTimeHour'
      lbpsStartTimeMinute: '$lbpsStartTimeMinute'
      lbpsDuration: '$lbpsDuration'
      lbpsSuspended: '$lbpsSuspended'
""")

LBPS_CELL_PERIOD_LIST_TIME_TEMPLATE = Template("""\
    - nrCellId: $nrCellId
      lbpsCellSoMethod: $lbpsCellSoMethod
      lbpsCellDayOfWeek: '$lbpsCellDayOfWeek'
      lbpsCellStartTimeHour: '$lbpsCellStartTimeHour'
      lbpsCellStartTimeMinute: '$lbpsCellStartTimeMinute'
      lbpsCellDuration: '$lbpsCellDuration'
""")


@keyword(name='Create yaml for NRPGRP structured parameters')
def yaml_for_nrpgrp_structured_params(yaml_path,
                                      nrpgrp_id,
                                      lbpscelllist=None,
                                      lbpsperiodlist=None,
                                      lbpscellperiodlist=None,
                                      ):
    """
    This method updates yaml with NRPGRP structured parameters. Yaml can be further used by ta_emss
    keyword "configure". Before update yaml file is cleared.

    :param nrpgrp_id: (str) NRPGRP instance ID
    :param yaml_path: (str) path to yaml which needs to be updated
    :param lbpscelllist: (dict) dictionary containing information about list NRPGRP.lbpsCellList
     usage example:
            lbpscelllist = {'cells': "1,2,3,4", 'so_order': "1,2,3,4", 'use_ext_config': "0,1,0,1"}
            cells: NRPGRP.lbpsCellList.nrCellId
            so_order: NRPGRP.lbpsCellList.lbpsCellSOOrder
            use_ext_config: NRPGRP.lbpsCellList.lbpsUseExtConfig

    :param lbpsperiodlist: (dict) dictionary containing information about list NRPGRP.lbpsPeriodList
     usage example, two variants allowed:
        1. period configured according do pattern
            lbpsperiodlist = {'number_of_periods': 7, 'period_duration': 1440, 'gap_before_period': 0,
                              'suspended': 0, 'first_period_gap': 0}

        2. each period is different
            lbpsperiodlist = {'period_duration': "10,10,10", 'gap_before_period': "20,10,0", 'suspended': "1,1,1"}

            number_of_periods: number of structures on NRPGRP.lbpsPeriodList
            period_duration: NRPGRP.lbpsPeriodList.lbpsDuration
            gap_before_period: (default=0)
                               variant1:
                               time in minutes with gap between end of previous period and start of next period
                               variant 2:
                               time in minutes with gap between first period and current time,
                               time in minutes with gap between end of previous period and start of next period
            suspended: NRPGRP.lbpsPeriodList.lbpsSuspended
            first_period_gap: (default=0) time in minutes with gap between first period and current time

    :param lbpscellperiodlist: (list) list of dictionaries containing information about list NRPGRP.lbpsCellPeriodList
     usage example, two variants allowed::
        1. periods configured according do pattern
            lbpscellperiodlist = [{'cells': "1,2", 'number_of_periods': 3, 'period_duration': 20,
                                   'gap_before_period': 1, 'method': 'TX switch off', 'first_period_gap': 0},
                                  {'cells': "3,4", 'number_of_periods': 3, 'period_duration': 20,
                                   'gap_before_period': 1, 'method': 'cell switch off', 'first_period_gap': 0}]
        2. each period is different
            lbpscellperiodlist = [{'cells': "1,2", 'period_duration': "10,10,10", 'gap_before_period': "10,0,0",
                                   'method': "'TX switch off','cell switch off','mixed switch off'"},
                                  {'cells': "3", 'period_duration': "10,10", 'gap_before_period': "10,0",
                                   'method': "'cell switch off','TX switch off'"}]

            cells: NRPGRP.lbpsCellPeriodList.nrCellId
            number_of_periods: number of structures on NRPGRP.lbpsCellPeriodList
            period_duration: NRPGRP.lbpsCellPeriodList.lbpsCellDuration
            gap_before_period: (default=0)
                               variant1:
                               time in minutes with gap between end of previous period and start of next period
                               variant 2:
                               time in minutes with gap between first period and current time,
                               time in minutes with gap between end of previous period and start of next period
            method: NRPGRP.lbpsCellPeriodList.lbpsCellSOMethod
            first_period_gap: (default=0) time in minutes with gap between first period and current time
    """

    prepare_yaml(yaml_path, nrpgrp_id)
    if lbpscelllist:
        add_lbpscelllist(lbpscelllist, yaml_path)
    if lbpsperiodlist:
        add_lbpsperiodlist(lbpsperiodlist, yaml_path)
    if lbpscellperiodlist:
        add_lbpscellperiodlist(lbpscellperiodlist, yaml_path)


def add_lbpscelllist(lbpscelllist, yaml_path):
    yaml_content = LIST_NAME.substitute(list_name="lbpsCellList")
    cells_list = lbpscelllist['cells'].split(',')
    so_order_list = lbpscelllist['so_order'].split(',')
    use_ext_config_list = lbpscelllist['use_ext_config'].split(',')
    cells_params = zip(cells_list, so_order_list, use_ext_config_list)

    for cell, so_order, use_ext_config in cells_params:
        cell_list_item = prepare_cell_list_item(cell, so_order, use_ext_config)
        yaml_content += cell_list_item
    update_yaml(yaml_path, yaml_content)


def add_lbpsperiodlist(lbpsperiodlist, yaml_path):
    yaml_content = LIST_NAME.substitute(list_name="lbpsPeriodList")
    if 'number_of_periods' in lbpsperiodlist.keys():
        yaml_content += add_lbpsperiodlist_pattern(lbpsperiodlist)
    else:
        yaml_content += add_lbpsperiodlist_each_different(lbpsperiodlist)
    update_yaml(yaml_path, yaml_content)


def add_lbpsperiodlist_pattern(lbpsperiodlist):
    yaml_content = ""
    number_of_periods = int(lbpsperiodlist['number_of_periods'])
    period_duration = int(lbpsperiodlist['period_duration'])
    gap_before_period = int(lbpsperiodlist.setdefault('gap_before_period', 0))
    suspended = lbpsperiodlist['suspended']
    first_period_gap = int(lbpsperiodlist.setdefault('first_period_gap', 0))

    last_period_end_date = add_time_in_minutes_to_current_date(first_period_gap)
    for period in range(number_of_periods):
        period_start_date = add_time_in_minutes_to_date(last_period_end_date, gap_before_period)
        period_params = prepare_period_list_item(period_start_date, period_duration, suspended)
        last_period_end_date = add_time_in_minutes_to_date(period_start_date, period_duration)
        yaml_content += period_params
    return yaml_content


def add_lbpsperiodlist_each_different(lbpsperiodlist):
    yaml_content = ""
    last_period_end_date = get_date_from_du()
    duration_list = [int(x) for x in lbpsperiodlist['period_duration'].split(',')]
    gaps_list = [int(x) for x in lbpsperiodlist['gap_before_period'].split(',')]
    suspended_list = lbpsperiodlist['suspended'].split(',')
    period_list_params = zip(duration_list, gaps_list, suspended_list)
    for duration, gap, suspended in period_list_params:
        start_date = add_time_in_minutes_to_date(last_period_end_date, gap)
        period_params = prepare_period_list_item(start_date, duration, suspended)
        last_period_end_date = add_time_in_minutes_to_date(start_date, duration)
        yaml_content += period_params
    return yaml_content


def add_lbpscellperiodlist(lbpscellperiodlist, yaml_path):
    yaml_content = LIST_NAME.substitute(list_name="lbpsCellPeriodList")
    if 'number_of_periods' in lbpscellperiodlist[0].keys():
        yaml_content += add_lbpscellperiodlist_pattern(lbpscellperiodlist)
    else:
        yaml_content += add_lbpscellperiodlist_each_different(lbpscellperiodlist)
    update_yaml(yaml_path, yaml_content)


def add_lbpscellperiodlist_pattern(lbpscellperiodlist):
    yaml_content = ""
    algorithm_start_date = get_date_from_du()
    for periods_params in lbpscellperiodlist:
        cells_list = periods_params['cells'].split(',')
        number_of_periods = int(periods_params['number_of_periods'])
        period_duration = int(periods_params['period_duration'])
        gap_before_period = int(periods_params.setdefault('gap_before_period', 0))
        method = periods_params['method']
        first_period_gap = int(periods_params.setdefault('first_period_gap', 0))
        for cell in cells_list:
            last_period_end_date = add_time_in_minutes_to_date(algorithm_start_date, first_period_gap)
            for period in range(number_of_periods):
                period_start_date = add_time_in_minutes_to_date(last_period_end_date, gap_before_period)
                cell_period_params = prepare_cell_period_list_item(cell, period_start_date, period_duration, method)
                last_period_end_date = add_time_in_minutes_to_date(period_start_date, period_duration)
                yaml_content += cell_period_params
    return yaml_content


def add_lbpscellperiodlist_each_different(lbpscellperiodlist):
    yaml_content = ""
    algorithm_start_date = get_date_from_du()
    for periods_params in lbpscellperiodlist:
        cells_list = periods_params['cells'].split(',')
        duration_list = [int(x) for x in periods_params['period_duration'].split(',')]
        gaps_list = [int(x) for x in periods_params['gap_before_period'].split(',')]
        method_list = periods_params['method'].split(',')
        cell_period_list_params = tuple(zip(duration_list, gaps_list, method_list))
        for cell in cells_list:
            last_period_end_date = algorithm_start_date
            for duration, gap, method in cell_period_list_params:
                start_date = add_time_in_minutes_to_date(last_period_end_date, gap)
                cell_period_params = prepare_cell_period_list_item(cell, start_date, duration, method)
                last_period_end_date = add_time_in_minutes_to_date(start_date, duration)
                yaml_content += cell_period_params
    return yaml_content


def prepare_cell_list_item(cell, so_order, use_ext_config):
    cell_params = LBPS_CELL_LIST_TEMPLATE.substitute(nrCellId=str(cell), lbpsCellSOOrder=str(so_order),
                                                     lbpsUseExtConfig=str(use_ext_config))
    return cell_params


def prepare_period_list_item(start_date, duration, suspended):
    day, hour, minute = get_start_time(start_date)
    period_params = LBPS_PERIOD_LIST_TIME_TEMPLATE.substitute(lbpsDayOfWeek=str(day),
                                                              lbpsDuration=str(duration),
                                                              lbpsStartTimeHour=str(hour),
                                                              lbpsStartTimeMinute=str(minute),
                                                              lbpsSuspended=str(suspended))
    return period_params


def prepare_cell_period_list_item(cell, start_date, duration, method):
    day, hour, minute = get_start_time(start_date)
    cell_period_params = ""
    cell_period_params += LBPS_CELL_PERIOD_LIST_TIME_TEMPLATE.substitute(nrCellId=str(cell),
                                                                         lbpsCellSoMethod=str(method),
                                                                         lbpsCellDayOfWeek=str(day),
                                                                         lbpsCellDuration=str(duration),
                                                                         lbpsCellStartTimeHour=str(hour),
                                                                         lbpsCellStartTimeMinute=str(minute))
    return cell_period_params


def prepare_yaml(yaml_path, nrpgrp_id):
    yaml_header = NRPGRP_ID.substitute(ID=nrpgrp_id)
    with open(yaml_path, 'w+') as yaml:
        yaml.write(yaml_header)


def update_yaml(yaml_path, content):
    with open(yaml_path, 'a+') as yaml:
        print("yaml will be updated with:\n {}".format(content))
        yaml.write(content)


def get_date_from_du(remote_host=None):
    ta5g_enb_instance = ta5g_enb()
    date_from_du = ta5g_enb_instance.execute_enb_command("date +%Y/%m/%d/%H/%M/%S", remote_host)
    date_from_du = "".join(date_from_du.split())
    now = datetime.datetime.strptime(date_from_du, "%Y/%m/%d/%H/%M/%S")
    return now


def add_time_in_minutes_to_current_date(time_delta):
    current_date = get_date_from_du()
    now_plus_delta = current_date + datetime.timedelta(minutes=int(time_delta))
    return now_plus_delta


def add_time_in_minutes_to_date(date, time_delta):
    now_plus_delta = date + datetime.timedelta(minutes=time_delta)
    return now_plus_delta


def get_start_time(start_date):
    day_of_week = start_date.weekday()
    hour = start_date.hour
    minute = start_date.minute
    return DAYS[day_of_week], hour, minute


if __name__ == "__main__":
    current_directory = os.getcwd()
    yaml_pattern = f'{current_directory}/../config/yaml/NRPGRP_structured_params_pattern.yaml'
    yaml_each_different = f'{current_directory}/../config/yaml/NRPGRP_structured_params_each_different.yaml'

    celllist = {'cells': "1,2,3,4", 'so_order': "1,2,3,4", 'use_ext_config': "0,1,0,1"}
    periodlist_pattern = {'number_of_periods': 7, 'period_duration': 1440, 'gap_before_period': 0,
                          'suspended': 0, 'first_period_gap': 0}

    cellperiodlist_pattern = [{'cells': "1,2", 'number_of_periods': 3, 'period_duration': 20,
                               'gap_before_period': 1, 'method': 'TX switch off', 'first_period_gap': 0},
                              {'cells': "3,4", 'number_of_periods': 3, 'period_duration': 20,
                               'gap_before_period': 1, 'method': 'cell switch off', 'first_period_gap': 0}]

    periodlist_each_different = {'period_duration': "10,10,10", 'gap_before_period': "20,10,0",
                                 'suspended': "1,1,1"}

    cellperiodlist_each_different = [{'cells': "1,2", 'period_duration': "10,10", 'gap_before_period': "10,0",
                                      'method': "'TX switch off','cell switch off'"},
                                     {'cells': "3,4", 'period_duration': "10", 'gap_before_period': "10",
                                      'method': "'cell switch off'"}]

    yaml_for_nrpgrp_structured_params(yaml_path=yaml_pattern,
                                      nrpgrp_id=1,
                                      lbpscelllist=celllist,
                                      lbpsperiodlist=periodlist_pattern,
                                      lbpscellperiodlist=cellperiodlist_pattern)

    yaml_for_nrpgrp_structured_params(yaml_path=yaml_each_different,
                                      nrpgrp_id=1,
                                      lbpscelllist=celllist,
                                      lbpsperiodlist=periodlist_each_different,
                                      lbpscellperiodlist=cellperiodlist_each_different)
