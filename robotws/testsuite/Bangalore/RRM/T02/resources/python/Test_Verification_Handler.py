# *Coding-utf-8 *
from taf.sbts.oam.coam.admin import admin
from taf.analyzer.syslog.syslog_reader import SyslogReader
# from taf.analyzer.syslog import syslog
from taf.analyzer.emil import EmilReader
import logging
import time
import datetime
import os
import shutil
import json
import robot

'''
Author: arunkumar.a@nokia.com
maintainer: MN_RAN_RD_VRF_BLR_1_T02
Catagory: Alarm, counters, Snapshort, etc...
'''


def check_connection(func):
    def wrapper(self, *args, **kwargs):
        if self.connection is None:
            self.connection = self.coam.connect_to()
        return func(self, *args, **kwargs)
    return wrapper


class Test_Verification_Handler:
    '''
    Class contain objects for Test Verifications such as PM counter, Alarm, file correction...
    '''
    current_time_ = datetime.datetime.now()

    def __init__(self) -> None:
        self.coam = admin()
        self.connection = None
        self.current_time_ = datetime.datetime.now()
        self.syslog_path = "/tmp/btslog2"

    @check_connection
    def CB012601_Emil_Log_Validation(self, decoded_json_path: str, call_count: int) -> bool:
        """
        Verfiying CB012601 Emil logs. Which decoded from taf.converters.emil.
        Filtering NRRRC Release, Redirect to nr,
        : Params - Decoded json path
        """
        try:
            decoded_json_files = os.listdir(decoded_json_path)
            rrc_release_nr_rediction_count: int = 0
            amf_initiated_abnormal: int = 0
            for json_file in decoded_json_files:
                with (open(decoded_json_path + "/" + json_file, "r") as rf):
                    file = rf.readlines()
                    for json_obj in file:
                        emil_log_entry = json.loads(json_obj)
                        get_keys = emil_log_entry.keys()
                        if "User_data" in get_keys:
                            if (emil_log_entry["Message_name"] == "ZmqMessage"
                                    and emil_log_entry['User_data'] == "DL RRC: rrcRelease, redirect to nr"
                                    and (emil_log_entry["JsonContent"][1]["DL-DCCH-Message"]
                                         ["message"]["c1"]["rrcRelease"]["criticalExtensions"]
                                         ["rrcRelease"]["deprioritisationReq"]["deprioritisationTimer"]) == "min5"
                                    and emil_log_entry["Local_component"] == "5G-CP-UE"):
                                rrc_release_nr_rediction_count += 1
                            elif (emil_log_entry["User_data"] == "F1AP: UEContextReleaseRequest"
                                  and emil_log_entry["JsonContent"]["F1AP-PDU"]["initiatingMessage"]
                                  ["value"]["UEContextReleaseRequest"]["protocolIEs"][2]["value"]["Cause"]
                                  ["radioNetwork"] == "amf-initiated-abnormal-release"):
                                amf_initiated_abnormal += 1
            print(f"rrc release count: {rrc_release_nr_rediction_count}")
            assert rrc_release_nr_rediction_count >= amf_initiated_abnormal, f"""Test suspected failed.
             UL Bler Triggered Redirect count{amf_initiated_abnormal}
             Redirection happend count is {rrc_release_nr_rediction_count}"""
            assert call_count <= rrc_release_nr_rediction_count
            return True
        except FileNotFoundError as err:
            raise FileNotFoundError(f"Decoded Json file not found.\n<REASON:{err}>")
        except json.JSONDecodeError as e:
            raise e(f"Json decoder Problem")

    @check_connection
    def Acitive_Alarm_Verification_Test(self, allowed_fault: list[int]) -> bool:
        '''
        :Active alarm validation. exception for allowd alarm
        :Param - allowed_fault - which can ignore
        :return unexpected alarm
        '''
        data = self.connection.get_active_alarms()
        for i in range(len(data)):
            for key, values in data[i].items():
                if key == 'faultId':
                    present_fault = values
                    if present_fault in allowed_fault:
                        continue
                    else:
                        print(f"Unexpected Alarm Found:\n{key}: {values}\n")
                        print(data[i])
                        return False

    @check_connection
    def Snapshot_Collection_test(self, snapshot_path: str, test_name: str) -> bool:
        '''
        :Collect snapshot file from bts.
        :retrun True
        '''
        snapfile_format = snapshot_path + test_name + str(self.current_time_)[:9] + ".zip"
        snapstatus = self.connection.get_snapshot(target_file_name=snapfile_format)
        if snapstatus:
            return True
        else:
            return False

    @check_connection
    def Im_Snapshot_Collection_test(self, im_snapshot_path: str, test_name: str) -> bool:
        '''
        :Collect IM Snapshot via admin
        :return True or False
        '''
        print(self.current_time_)
        im_snapshot_format = im_snapshot_path + test_name + str(self.current_time_)[:9] + ".ims2"
        im_status = self.connection.collect_im_snapshot(target_file_name=im_snapshot_format)
        if im_status:
            return True
        else:
            return False

    @check_connection
    def syslog_folder_tmp_empty(self):
        '''Syslogs are collecting and locating in /tmp/btslog2'''
        is_folder_empty = os.listdir(self.syslog_path)
        if is_folder_empty:
            print(f"{self.syslog_path} is not empty.")
            try:
                for file in is_folder_empty:
                    if os.path.isdir(f"{self.syslog_path}/{file}"):
                        shutil.rmtree(f"{self.syslog_path}/{file}")
                        print(f"{self.syslog_path}/{file} is removed.")
                    elif os.path.exists(f"{self.syslog_path}/{file}"):
                        os.remove(f"{self.syslog_path}/{file}")
                        print(f"File name: {file} is removed")
                    else:
                        print(f"No files are present under {self.syslog_path}")
                else:
                    print(f"No files are present under {self.syslog_path}")
            except OSError as err:
                raise err(f"{self.syslog_path} need to check in VM.!")
        return True

    @check_connection
    def move_syslog_to_test_case_folder(self, target_path: str) -> bool:
        '''Moveing syslogs files to test case folder'''
        is_folder_empty = os.listdir(self.syslog_path)
        if is_folder_empty:
            print(f"{self.syslog_path} is not empty.")
            try:
                syslog_path = target_path + "/btslog2"
                shutil.move(self.syslog_path, target_path)
                check = os.listdir(syslog_path)
                assert len(check) != 0, "Test failed.! Files are not moved.!"
                return syslog_path
            except AssertionError as err:
                raise err(f"Test is failed. no log present in {target_path}")
            except shutil.Error as err:
                raise err(f"Issue with file move function")
            except OSError as err:
                raise err(f"Check file list using os module failed.")
        else:
            return False

    @check_connection
    def validate_syslog_file_contents(self, dir_path=None, file_pattern="SYSLOG*.LOG", search_string=None):
        matching_dicts = []
        search_stri = []
        searchstr = ','.join(map(str, search_string))
        searchstr = searchstr.split(",")
        results = [log_entry.asdict() for log_entry in SyslogReader.from_dir(
            dir_path=dir_path, file_pattern=file_pattern) if log_entry.line]
        for item in results:
            line = item["line"]
            if any(err in line for err in [b"Please Contact", b"core dump"]):
                raise RuntimeError(
                    "Line: {} contains one of the following messages 'Please Contact, core dump', "
                    "Please check".format(line))
            for searchstring in searchstr:
                if searchstring.encode() in item['user_text'] and searchstring.encode() not in search_stri:
                    matching_dicts.append(item)
                    search_stri.append(searchstring.encode())
        match = "matched" if len(search_stri) == len(searchstr) else "notmatched"
        return [matching_dicts, match]

    def epoch_convert_ist(self, epoch_time: int) -> str:
        '''Convert IST time from epoch time. return ist time'''
        utc_time = datetime.datetime.fromtimestamp(epoch_time, tz=datetime.timezone.utc)
        ist_time_zone = datetime.timezone(datetime.timedelta(hours=5, minutes=30))
        ist_time = utc_time.astimezone(ist_time_zone)
        return ist_time

    @check_connection
    def __get_pm_counter_details__(self, CountersId: list[str], CellsId: list[int]):
        """Get PM Counter details form BTS Web Em by using taf
        :return status
        """
        CounterIdLength = len(CountersId)
        counter_value: dict = {}
        for CounterId in range(CounterIdLength):
            get_pm_counters = self.coam.get_pm_counters(counters_ids=CountersId[CounterId])

    @check_connection
    def Verify_PM_Counter_Test(self, MRBTS: str, NRBTS: str,
                               counter_id: list[str] = [], cell_ids: list[str] = None) -> str:
        '''Verify PM Counters.
        :How - get PM count using taf & the dict data collected and verfying in epoch time based.
        :Params MRBTS & NRBTS: Required MRBTS & NRBTS ID such as "MRBTS-1061" & "NRBTS-1061"
        :Params Counter_id: list - list of counters can be passed.
        :Params cell_ids: list -list cells ids can be passed.
        :raise Assertion error on Failed scenario. when counter value not incremetned from 0
        :return True if counter picked in WebEM '''
        for i in range(len(counter_id)):
            get_pm_counters = self.coam.get_pm_counters(counter_id[i])
            result: list = []
            if cell_ids is not None:
                for id in range(len(cell_ids)):
                    value_list: list = []
                    counter_level_value = get_pm_counters["BTS"][MRBTS][NRBTS][cell_ids[id]]["NRRCC"]
                    for key, value in counter_level_value.items():
                        if key != counter_id[i]:
                            raise Exception("Value not found")
                        else:
                            print("counter Id:", key)
                            for epoch_time, increment in value.items():
                                counter_time = self.epoch_convert_ist(int(epoch_time))
                                print(f"Counter Time: {counter_time} = {increment} value")
                                value_list += [increment]
                    try:
                        value_len = len(value_list)
                        num = 0
                        for item in range(value_len):
                            num += value_list[item]
                        assert num != 0, "Test failed. Conuter value not picked"
                        result += [[counter_id[i], num]]
                    except AssertionError:
                        raise AssertionError("PM Counter validation failed. Counter Value not incremented.",
                                             f"Counter id {counter_id[i]} and Value {num}")
            else:
                raise Exception("Invalid Argument for \"cell_ids\". ")
        print("result", result)
        return True

    def Unexpected_History_Alarm_Test(self):
        '''
        Verify the Unexpected History Alarm
        '''
        raise NotImplementedError

    def BTS_Cells_On_Air_Verification_Test(self):
        '''
        Verify BTS on air status
        return the current status
        '''
        raise NotImplementedError

    def Verify_Cells_Status_Test(self):
        '''Verify the cell status on BTS. '''
        raise NotImplementedError
