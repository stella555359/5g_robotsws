from taf.hw.pdu import pdu
import random
import string
import os
from datetime import datetime, timedelta
import time
import argparse
import json
import pandas as pd


# Requirements: pandas, taf.pdu
# Parameters:
#   location - folder where the output csv file will be saved.
#   duration - the total duration of the data collection in seconds.
#   repeat - how often should the data be collected
#   pdu_mode - can be cli (pdu data need to be specified) or init (pdu data can be supplied by PduPort)
#   info - data structure for pdu information in json format. can specify multiple times for multiple pdus
#           cli mode: '{"ip":"","model":"","login":"","password":"","protocol":"","alias":"","ports":[]}'
#                               ip - string; ip of the pdu
#                               model - string; model of the pdu
#                               login - string; username of the pdu
#                               password - string; password of the pdu
#                               protocol - string; protocol of the pdu
#                               alias - string; alias of the pdu. must be unique for each pdu
#                               ports - list of ints; ports where data will be gathered
#           robot/init mode: '{"alias":"","ports":["${INTERFACES[SMOD_AABBCCD].PduPort}"]}'
#                               alias - string; alias of the pdu. must be unique for each pdu
#                               ports - list containing only 1 string; name of the port where data will be gathered
#
#
# Execution in robot can be done by using Run Process keyword from Process library. Also pandas_gate.py and
# energy_consumption.py need to be imported and executed. See example below for suite execution
# *** Settings ***
# Resource    ../../../test_resources/NRL__STATE__NR_RM_Power_Off_On.robot
# Library     ../../../../resources/python_resources/pandas_gate.py  # Import Requirements Lib
#
# Suite Setup  install_and_import_pandas  # Execute the installation of the script
#
# *** Variables ***
# ${SCF_ID}    01
# ${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
# ${POWER_ON_FLAG}    ${True}
#
# *** Test Cases ***
# [1]NRL__STATE__NR_RM_Power_Off_On
#     [Timeout]    14400
#     [Setup]    Run Keywords
#     ...    Import Variables    ${ALM_PTH}/nrl__state__nr_rm_power_off_on_alarms_definitions.py
#     ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
#     ...    AND    Set Test Variable    ${OPERATION_ORDER}    ONE_BY_ONE
#     ...    AND    Set Test Variable    ${HW_RESET_TIME_INTERVAL}    480
#     ...    AND    Set Test Variable    ${HW_POWER_ON_WRN_THR}    240
#     ...    AND    Set Test Variable    ${HW_POWER_MAX_WAIT_TIME}    900
#
#     ...    AND    NRL__STATE__NR_RM_Power_Off_On.TC Setup
#     ...    AND    Modify Resource Search Order    NRL__STATE__NR_RM_Power_Off_On
#     ...    AND    Set Library Search Order    NRL__STATE__NR_RM_Power_Off_On
#     ...    AND    Run Process  python  ${CURDIR}/../../../../resources/python_resources/energy_consumption.py
#     ...    /home/ute/energy_logs  30  5  init
#     ...    {"alias":"myalias","ports":["${INTERFACES[SMOD_SMODSN].PduPort}"]}'
#     TC__NRL__STATE__NR_RM_Power_Off_On
#     [Teardown]    Run Keywords    NRL__STATE__NR_RM_Power_Off_On.TC Teardown
#     ...    AND    Restore Resource Search Order


class PduInfo(object):

    def __init__(self):
        self.pdu_class = pdu()

    def setup_pdu(self):
        print("Use specific class")

    def get_energy_consumption(self, pdu_alias, port):
        return self.pdu_class.get_energy_consumption(port=port, pdu_device=pdu_alias)

    def get_voltage(self, pdu_alias, port):
        return self.pdu_class.get_voltage(port=port, pdu_device=pdu_alias)

    def get_current(self, pdu_alias, port):
        return self.pdu_class.get_current(port=port, pdu_device=pdu_alias)


class PduInfoSpecified(PduInfo):
    def __init__(self, model, ip, alias, login, password, protocol):
        self.model = model
        self.ip = ip
        self.alias = alias
        self.login = login
        self.password = password
        self.protocol = protocol
        super().__init__()

    def setup_pdu(self):
        self.pdu_class.setup_pdu(model=self.model, host=self.ip, alias=self.alias, login=self.login,
                                 password=self.password, protocol=self.protocol)


class PduInfoNotSpecified(PduInfo):
    def __init__(self, model, alias):
        self.model = model
        self.alias = alias
        super().__init__()

    def setup_pdu(self):
        self.pdu_class.setup_pdu(model=self.model, alias=self.alias)


class Writer(object):

    def __init__(self, file_location):
        self.file_location = file_location

    def random_string(self, length):
        letters = string.ascii_lowercase
        result_str = ''.join(random.choice(letters) for i in range(length))
        return result_str

    def write_to_xlsx(self, df_tuples_list):
        file_path = self.create_filename()

        with pd.ExcelWriter(path=file_path, mode='w') as fd:
            for entry in df_tuples_list:
                entry[0].to_excel(excel_writer=fd, sheet_name=entry[1])

    def create_filename(self):
        filename = datetime.now().strftime("%Y-%m-%d_%H%M%S")
        timestamp_string = str(filename)
        random_chars = self.random_string(4)
        filename = "{}_{}.xlsx".format(timestamp_string, random_chars)
        complete_path = os.path.join(self.file_location, filename)
        return complete_path


class Executor(object):

    def timed_executor(self, args):
        writer = Writer(args.location)
        end_time = datetime.now() + timedelta(seconds=args.duration)
        output_list = []
        while datetime.now() < end_time:
            for entry in args.info:
                output = self.collect_data(entry, args.pdu_mode)
                output_list += output
            time.sleep(args.repeat)

        df_general_info = pd.DataFrame(output_list, columns=["Time", "PDU IP", "PDU Port", "Voltage", "Current",
                                                             "Power Consumption"])

        df_general_info['Relative Power Consumption'] = DataProcess().calculate_relative_power_consumption(
            df_general_info)
        df_general_info['Instant Power Consumption'] = DataProcess(
        ).calculate_instant_power(df_general_info)

        df_power_mean = DataProcess().calculate_mean_instant_power(df_general_info)
        writer.write_to_xlsx(
            [(df_general_info, 'General Information'), (df_power_mean, 'Power Mean')])

    @staticmethod
    def collect_data(entry, pdu_mode):
        pdu_obj = None
        if pdu_mode == "cli":
            pdu_obj = PduInfoSpecified(ip=entry['ip'], model=entry['model'], alias=entry['alias'],
                                       login=entry['login'], password=entry['password'], protocol=entry['protocol'])

        if pdu_mode == "init":
            pdu_obj = PduInfoNotSpecified(
                model=entry['ports'][0].pdu, alias=entry['alias'])
            entry['ip'] = entry['ports'][0].pdu.addr

        pdu_obj.setup_pdu()

        output = []
        for port in entry['ports']:
            output.append([datetime.now(), entry['ip'], port,
                           pdu_obj.get_voltage(
                               pdu_alias=entry['alias'], port=port),
                           pdu_obj.get_current(
                               pdu_alias=entry['alias'], port=port),
                           pdu_obj.get_energy_consumption(entry['alias'], port=port)])
        return output


class DataProcess(object):

    @staticmethod
    def calculate_relative_power_consumption(df):
        return df.groupby(['PDU Port'])['Power Consumption'].transform(
            lambda x: x - x.iloc[0])

    @staticmethod
    def calculate_instant_power(df):
        return df['Voltage'] * df['Current']

    @staticmethod
    def calculate_mean_instant_power(df):
        return df.groupby(['PDU Port'])['Instant Power Consumption'].mean()


def script():
    parser = argparse.ArgumentParser()
    parser.add_argument("location", type=str,
                        help="location where the output file will be saved")
    parser.add_argument("duration", type=int,
                        help="the duration of the data collection in seconds")
    parser.add_argument("repeat", type=int,
                        help="the duration of the repeated data collection in seconds")
    parser.add_argument('pdu_mode', choices=('cli', 'init'),
                        help="how pdu connection will be realised", type=str)
    parser.add_argument("--info", type=json.loads, action='append')
    args = parser.parse_args()

    return args


class EnergyConsumption():
    """
    Class to handle energy consumption data collection.
    """

    def __init__(self):
        pass

    def run_energy_consumption(self, location, duration, repeat, pdu_mode, info):
        """
        Run the energy consumption data collection.

        Parameters:
        location (str): Folder where the output csv file will be saved.
        duration (int): The total duration of the data collection in seconds.
        repeat (int): How often should the data be collected in seconds.
        pdu_mode (str): Can be 'cli' (PDU data need to be specified) or 'init' (PDU data can be supplied by PduPort).
        info (list): Data structure for PDU information in JSON format. Can specify multiple times for multiple PDUs.
                     cli mode: '{"ip":"","model":"","login":"","password":"","protocol":"","alias":"","ports":[]}'
                               ip - string; IP of the PDU
                               model - string; Model of the PDU
                               login - string; Username of the PDU
                               password - string; Password of the PDU
                               protocol - string; Protocol of the PDU
                               alias - string; Alias of the PDU. Must be unique for each PDU
                               ports - list of ints; Ports where data will be gathered
                     robot/init mode: '{"alias":"","ports":["${INTERFACES[SMOD_AABBCCD].PduPort}"]}'
                               alias - string; Alias of the PDU. Must be unique for each PDU
                               ports - list containing only 1 string; Name of the port where data will be gathered
        """
        args = argparse.Namespace(
            location=location, duration=duration, repeat=repeat, pdu_mode=pdu_mode, info=info)
        Executor().timed_executor(args)


# Prototype to run
args = script()
Executor().timed_executor(args)
