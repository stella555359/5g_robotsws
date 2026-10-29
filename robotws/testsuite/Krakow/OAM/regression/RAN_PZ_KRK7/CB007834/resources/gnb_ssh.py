import re
from contextlib import contextmanager
from datetime import datetime

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh import ssh


tl = BuiltIn().get_variable_value("${tl}")


@contextmanager
def connect_gnb(hostname=None, username=None, password=None):
    hostname = hostname if hostname else tl.gnbs[0].cu.oam_ssh_connection_details.addr
    username = username if username else tl.gnbs[0].cu.oam_ssh_connection_details.username
    password = password if password else tl.gnbs[0].cu.oam_ssh_connection_details.password
    ssh_connection = ssh()
    ssh_connection.connect_to(hostname=hostname, username=username, password=password)
    try:
        yield ssh_connection
    except Exception as err:
        logger.console(err)
    finally:
        ssh_connection.disconnect()


def get_historical_alarm_list():
    with connect_gnb() as connection:
        history_path = '/tmp/RawAlarmHistory.txt'
        output = connection.execute('cat {}'.format(history_path))
        return preparing_data(output)


def preparing_data(output):
    parameters = ['time', 'fault_id']
    inactive_alarms = output.split('Inactive faults')[-1]
    str_output = inactive_alarms.split('=')[-1]
    regexp = r'(?P<time>\d{4}\-\w{3,4}-\d{2}\s\d{2}:\d{2}:\d{2})\s+\((?P<fault_id>\d{4})\)'
    alarm_list = re.findall(regexp, str_output)
    dict_date = [dict(zip(parameters, alarm)) for alarm in alarm_list]
    return find_string_month_and_replace_into_int(dict_date)


def find_string_month_and_replace_into_int(output):
    for alarm in output:
        old_time = alarm['time']
        new_time = create_new_date_and_time_format(old_time)
        alarm['time'] = new_time
    return output


def create_new_date_and_time_format(item):
    regex = r'[A-Za-z]{3}'
    string_month = re.search(regex, item).group()
    if string_month:
        datetime_object = datetime.strptime(string_month, "%b")
        month_number = '{:02d}'.format(datetime_object.month)
        new_date = item.replace(string_month, str(month_number))
        return new_date
    raise Exception('Not found regex {} in string {}'.format(regex, item))
