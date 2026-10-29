from string import Template
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
import datetime
from ta5g_enb import ta5g_enb
import os


DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']

NRPGRP_NOT_STRUCTURED_PARAMS = """\
- ID: 1
  MOC: NRPGRP
  lbpsSOMethod: ${NRPGRP-1.lbpsSOMethod}
  lbpsLastCellSOEnabled: ${NRPGRP-1.lbpsLastCellSOEnabled}
  lbpsCSONCtlEnabled: 'false'

# 5GC000431 specific parameters
  lbpsMaxLoad: '60'
  lbpsMinLoad: '20'
  lbpsPdcchLoadOffset: '4'
  lbpsLastCellMinLoad: '0'

# CB008392 specific paramters
  lbpsRTXMaxLoad: ${NRPGRP-1.lbpsRTXMaxLoad}
  lbpsRTXMinLoad: ${NRPGRP-1.lbpsRTXMinLoad}
  lbpsRTXCellCapOffset: ${NRPGRP-1.lbpsRTXCellCapOffset}
  lbpsRTXSOffTime: ${NRPGRP-1.lbpsRTXSOffTime}
  lbpsRTXSOnTime: ${NRPGRP-1.lbpsRTXSOnTime}
  lbpsLastCellRTXMinLoad: ${NRPGRP-1.lbpsLastCellRTXMinLoad}
"""

LBPS_CELL_LIST_TEMPLATE = Template("""\
    - lbpsCellSOOrder: $lbpsCellSOOrder
      nrCellId: $nrCellId
""")

LBPS_PERIOD_LIST_TIME_TEMPLATE = Template("""\
    - lbpsDayOfWeek: $lbpsDayOfWeek
      lbpsDuration: $lbpsDuration
      lbpsStartTimeHour: $lbpsStartTimeHour
      lbpsStartTimeMinute: $lbpsStartTimeMinute
""")

LBPS_PERIOD_LIST_LBPS_SUSPENDED = """\
      lbpsSuspended: ${NRPGRP-1.lbpsSuspended}
"""

CB008392_ACTIVATION = """\
- ID: 1
  MOC: NRBTS
  actNrLBRTXPowerSaving: true
"""

CURDIR = os.path.dirname(os.path.realpath(__file__))
YAML_PATH = "{}/../config/yaml_config/dynamically_created_yaml.yaml".format(CURDIR)


@keyword('Create yaml for NRPGRP-1 with ${lbps_periods_num} lbpsPeriods with ${interval}min intervals '
         'and CB008392 activation')
def create_nrpgrp(lbps_periods_num, interval):

    nrpgrp_section = NRPGRP_NOT_STRUCTURED_PARAMS + "\n"
    nrpgrp_section += _add_nr_cellid_list() + "\n"
    nrpgrp_section += _add_lbps_period_list(lbps_periods_num, interval)

    with open(YAML_PATH, 'w+') as yaml:
        yaml.write(nrpgrp_section)
        yaml.write(CB008392_ACTIVATION)
    return YAML_PATH


def _add_nr_cellid_list():
    lbps_cell_so_order_list = BuiltIn().get_variable_value('@{NRPGRP-1.lbpsCellSOOrder}')
    nr_cellid_list = BuiltIn().get_variable_value('@{NRPGRP-1.nrCellId}')
    lbps_cell_list = zip(lbps_cell_so_order_list, nr_cellid_list)

    nr_cellid_list = 2 * " " + "lbpsCellList:\n"

    for lbps_cell_so_order, nr_cellid in lbps_cell_list:
        lbps_cell = LBPS_CELL_LIST_TEMPLATE.substitute(lbpsCellSOOrder=lbps_cell_so_order, nrCellId=nr_cellid)
        nr_cellid_list += lbps_cell
    return nr_cellid_list


def _add_lbps_period_list(lbps_periods_num, interval):
    lbps_periods_num = int(lbps_periods_num)
    interval = int(interval)

    lbps_duration = int(BuiltIn().get_variable_value('${NRPGRP-1.lbpsDuration}'))
    default_offset = 0
    offset = int(BuiltIn().get_variable_value('${NRPGRP-1.offset}', default_offset))

    lbps_period_list = 2 * " " + "lbpsPeriodList:\n"

    start_date = get_date_from_du()
    for period in range(lbps_periods_num):
        day, hour, minute = get_time_with_offset_from_start_date(start_date,
                                                                 offset + (lbps_duration + interval) * period)

        lbps_period_list_time = LBPS_PERIOD_LIST_TIME_TEMPLATE.substitute(lbpsDayOfWeek=str(day),
                                                                          lbpsDuration=str(lbps_duration),
                                                                          lbpsStartTimeHour=str(hour),
                                                                          lbpsStartTimeMinute=str(minute))
        lbps_period_list += lbps_period_list_time
        lbps_period_list += LBPS_PERIOD_LIST_LBPS_SUSPENDED

    return lbps_period_list


def get_date_from_du(remote_host=None):
    ta5g_enb_instance = ta5g_enb()
    date_from_du = ta5g_enb_instance.execute_enb_command("date +%Y/%m/%d/%H/%M/%S", remote_host)
    date_from_du = "".join(date_from_du.split())
    now = datetime.datetime.strptime(date_from_du, "%Y/%m/%d/%H/%M/%S")
    logger.info("Current time: {}".format(now))
    return now


def add_time_in_minutes_to_current_date(current_date, time_delta):
    now_plus_delta = current_date + datetime.timedelta(minutes=int(time_delta))
    day_of_week_plus_delta = now_plus_delta.weekday()
    hour_plus_delta = now_plus_delta.hour
    minute_plus_delta = now_plus_delta.minute
    return now_plus_delta, day_of_week_plus_delta, hour_plus_delta, minute_plus_delta


def get_time_with_offset(time_delta=0):
    current_time = get_date_from_du()
    time_plus_delta = current_time + datetime.timedelta(minutes=int(time_delta))
    day_of_week_plus_delta = time_plus_delta.weekday()
    hour_plus_delta = time_plus_delta.hour
    minute_plus_delta = time_plus_delta.minute
    logger.info("Time + delta: {}".format(time_plus_delta))
    return DAYS[day_of_week_plus_delta], hour_plus_delta, minute_plus_delta


def get_time_with_offset_from_start_date(start_date, time_delta):
    _, day_of_week, hour, minute = add_time_in_minutes_to_current_date(start_date, time_delta)
    return DAYS[day_of_week], hour, minute
