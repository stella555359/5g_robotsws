
import os
import sys
from tak_airphone import *
import json
import multiprocessing
import time
import re
import random
import signal
import subprocess
from optparse import OptionParser
from taf.internal.aliasing import aliasing_scope
from datetime import datetime, timedelta
import traceback
from ute_wtssim import ute_wtssim
from ta5g_ue_measurements import measurements
# try:
# import robot.api.logger as logging
# # except ImportError:
import logging


GBR_5QIs = {}
NON_GBR_5QIs = {}


def airphone_setup_teardown(func):
    def wrapper(self, *args, **kwargs):
        # run airphone_setup
        self.airphone = tak_airphone()
        alias = f"ue{self.ue_id}_{func.__name__}"
        self.airphone.airphone_setup(alias=alias)
        print(f"alias is ue{self.ue_id}_{func.__name__} start")
        try:
            result = func(self, alias, *args, **kwargs)
        except Exception as e:
            logging.error(f"{func.__name__} error {e}, at {traceback.format_exc()}")
        finally:
            # run airphone_teardown
            print(f"alias is {alias} end")
            self.airphone.airphone_teardown(alias=alias)
        return result
    return wrapper


def exeception_handle(func):
    def wrapper(self, *args, **kwargs):
        try:
            result = func(self, *args, **kwargs)
        except Exception as e:
            logging.error(f"{func.__name__} error {e}, at {traceback.format_exc()}")
            raise e
        return result
    return wrapper


# 定义全局共享锁
global_shared_lock = multiprocessing.Lock()


class HandoverFileLock:
    def __init__(self):
        current_script_path = os.path.abspath(__file__)
        current_directory = os.path.dirname(current_script_path)
        self.file_path = os.path.join(current_directory, "handover_file.txt")

    def lock_handover_file(self):
        if not os.path.exists(self.file_path):
            with open(self.file_path, "w") as file:
                pass

    def check_handover_file_and_wait_until_unlock(self, timeout=180):
        start_time = time.time()
        while os.path.exists(self.file_path):
            if time.time() - start_time > timeout:
                raise TimeoutError("Timeout waiting for handover file to be unlocked")
            time.sleep(1)

    def unlock_handover_file():
        if os.path.exists(self.file_path):
            os.remove(self.file_path)


class Airphone():
    def setup(self,
              alias="default",
              edaemon_port=22222,
              egate_port=20000,
              tool_dir="/opt/iphy/latest",
              host_ip='127.0.0.1'):
        self.alias = alias
        self.airphone = tak_airphone()
        self.airphone.airphone_setup(alias=alias,
                                     edaemon_port=edaemon_port,
                                     egate_port=egate_port,
                                     tool_dir=tool_dir,
                                     host_ip=host_ip)

    def get_alias_name(self):
        return self.alias

    def teardown(self):
        self.airphone.airphone_teardown(alias=self.alias)


class Ue():
    AVAILABLE_TRF_ID = [str(i) for i in range(1, 32)]
    UNAVAILABLE_TRF_ID = []
    udp_qfi_list = []
    tcp_qfi_list = []

    def __init__(self,
                 ue_id,
                 alias="default",
                 airphone_obj=None):
        # TODO:
        self.ue_id = ue_id
        self.airphone = airphone_obj
        self.alias = alias
        self.measurement_obj = None
        self.attach_info = None

    # @airphone_setup_teardown
    def reattach_from_idle(self):
        cmd = f"ue_im_exit id={self.ue_id} by=ue"
        self.airphone.airphone_execute_egate_command(
            cmd,
            pass_regexp="Initial Context Setup Successful",
            timeout=60,
            alias=self.alias)

    # @airphone_setup_teardown
    def attach(self, info, timeout=15):
        global global_shared_lock
        with global_shared_lock:
            self.attach_info = info
            state = self.__check_ue_state()
            logging.info(f"ue {self.ue_id} state is: {state}")
            if state == "OFF" or state == "IDLE":
                if state == "IDLE":
                    self.reattach_from_idle()
                else:
                    if "SA" == info["call_type"]:
                        self._sa_attach(info)
                    elif "NSA" == info["call_type"]:
                        self._nsa_attach(info)
                    else:
                        logging.error("attach type error")
                        raise ValueError(f"attach type error {info}")
                    logging.info(f"ue{self.ue_id} attach success")
                time.sleep(1)
                # self.__get_physcell_id()
            else:
                logging.info(f"ue{self.ue_id} is already attached")

    def _nsa_attach(self, info):
        logging.info(f"ue{self.ue_id} sa attach")
        self.gnb_id = self.airphone.airphone_get_gnb_id(alias=self.alias)
        cmd = f"ue_attach id={self.ue_id}"
        # attach LTE
        output = self.airphone.airphone_execute_egate_command(
            cmd, pass_regexp="UE IS ACTIVE", timeout=60, alias=self.alias)
        # attach 5g
        cmd = f"ue_dc_enb_start ue={self.ue_id} target_gnb={self.gnb_id} " \
              f"target_cells={cell_id} bearer={bearer_id} type=split_scg"
        output = self.airphone.airphone_execute_egate_command(
            cmd, pass_regexp="reported successful RA", timeout=60, alias=self.alias)

    def _sa_attach(self, info):
        logging.info(f"ue{self.ue_id} sa attach")
        nogbr_list, gbr_list = info["nogbr_list"], info["gbr_list"]
        gbr_nogbr_id_list = []
        qfi = 1
        configured_udp_qfi_list = []
        configured_tcp_qfi_list = []
        for i, nogbr in enumerate(nogbr_list):
            nogbr_id = nogbr.replace("5QI", "")
            if i == 0:
                cmd = f"qosflow_modify qos_flow={NON_GBR_5QIs[f'{nogbr_id}']} default=on"
                self.airphone.airphone_execute_egate_command(cmd, alias=self.alias)
            else:
                gbr_nogbr_id_list.append(NON_GBR_5QIs[f'{nogbr_id}'])
            # cmd = f"set_pdu_param ue={self.ue_id} pdu=1 qfi={qfi} trf_type=internal"
            # self.airphone.airphone_execute_egate_command(cmd, alias=self.alias)
            configured_udp_qfi_list.append(qfi)
            configured_tcp_qfi_list.append(qfi)
            qfi += 1
        for gbr in gbr_list:
            gbr_id = gbr.replace("5QI", "")
            gbr_nogbr_id_list.append(GBR_5QIs[f'{gbr_id}'])
            # cmd = f"set_pdu_param ue={self.ue_id} pdu=1 qfi={qfi} trf_type=internal"
            # self.airphone.airphone_execute_egate_command(cmd, alias=self.alias)
            qfi += 1
            if GBR_5QIs[f'{gbr_id}'] in self.udp_qfi_list:
                configured_udp_qfi_list.append(qfi)
            else:
                configured_tcp_qfi_list.append(qfi)
        cmd = f"set_pdu_param ue={self.ue_id} pdu=1 trf_type=internal"
        self.airphone.airphone_execute_egate_command(cmd, alias=self.alias)
        logging.info(f"ue{self.ue_id} gbr_nogbr_id_list {gbr_nogbr_id_list}")
        cmd = f"smf_param id=1 additional_qosflows_to_activate={','.join(gbr_nogbr_id_list)}"
        self.airphone.airphone_execute_egate_command(cmd, alias=self.alias)
        self.udp_qfi_list = configured_udp_qfi_list
        self.tcp_qfi_list = configured_tcp_qfi_list
        logging.info(f"ue{self.ue_id} udp_qfi_list: {self.udp_qfi_list} tcp_qfi_list: {self.tcp_qfi_list}")
        # change the cell info if needed
        if "attach_cell" in info.keys():
            cmd = f"ue_change_location id={self.ue_id} enb=2 cell={info['attach_cell']}"
            self.airphone.airphone_execute_egate_command(
                cmd,
                timeout=60,
                alias=self.alias)

        cmd = f"ue_register id={self.ue_id}"
        self.airphone.airphone_execute_egate_command(
            cmd,
            pass_regexp="Received REGISTRATION COMPLETE from UE with RAN UE NGAP ID",
            timeout=60,
            alias=self.alias)

        cmd = f"ue_pdu_session_setup pdu=1 ue={self.ue_id} nwslice=1 gw={self.ue_id}"
        self.airphone.airphone_execute_egate_command(
            cmd,
            alias=self.alias,
            pass_regexp="Initial Context Setup Successful|reestablishment complete",
            timeout=180)

    # @airphone_setup_teardown
    def detach(self, info, timeout=15):
        state = self.__check_ue_state()
        if state == "OFF":
            logging.info(f"ue{self.ue_id} is already detached")
        else:
            if "SA" == info["call_type"]:
                self._sa_detach(info)
            elif "NSA" == info["call_type"]:
                self._nsa_detach(info)
            else:
                logging.error("detach type error")
                raise ValueError(f"detach type error {info}")
            # wait for ue state changed
            for i in range(timeout):
                state = self.__check_ue_state()
                if state == "OFF":
                    break
                time.sleep(3)
            if state != "OFF":
                logging.error(f"ue{self.ue_id} detach failed")
            else:
                logging.info(f"ue{self.ue_id} detach success")

    def is_idle(self):
        state = self.__check_ue_state()
        if state == "IDLE":
            return True
        else:
            return False

    def __check_ue_state(self):
        # state                      ACTIVE
        cmd = f"ue_disp id={self.ue_id}"
        ret = self.airphone.airphone_execute_egate_command(
            cmd, alias=self.alias, pass_regexp="nr_idle_mode_beam")
        logging.info(f"ue state: {ret} alias: {self.alias}")
        if re.search(r"state\s+ACTIVE", ret):
            return "ACTIVE"
        elif re.search(r"state\s+IDLE", ret):
            return "IDLE"
        else:
            return "OFF"

    def _sa_detach(self, info):
        logging.info(f"ue{self.ue_id} sa detach")
        cmd = f"ue_deregister id={self.ue_id} ue_deregister_type=switch_off"
        self.airphone.airphone_execute_egate_command(
            cmd, pass_regexp="UE Context Release Complete", timeout=60, alias=self.alias)

    def _nsa_detach(self, info):
        logging.info(f"ue{self.ue_id} nsa detach")
        cmd = f"ue_detach id={self.ue_id}"
        self.airphone.airphone_execute_egate_command(
            cmd, pass_regexp="detached", timeout=60)

    def reattach(self):
        state = self.__check_ue_state()
        logging.info(f"ue{self.ue_id} state is: {state}")
        if self.__check_ue_state() == "IDLE":
            self.reattach_from_idle()

    # @airphone_setup_teardown
    def udp_dl(self, info):
        logging.info(f"ue{self.ue_id} udp_dl")
        tput_data = str(re.match(r"\d+", info['value']).group(0))
        tput_unit = info['value'].replace(tput_data, "")
        tput_value = f"{tput_unit}ps={tput_data}"
        for i in range(info["times"]):
            global global_shared_lock
            with global_shared_lock:
                self.reattach()
                used_trf_id_list = self.__start_traffic(tput_data,
                                                        tput_value,
                                                        "dl",
                                                        info["call_type"],
                                                        info["duration"])
                logging.info(f"{self.ue_id} udp_dl start traffic {i} times, waiting for traffic {info['duration']}")
                time.sleep(2)
            time.sleep(info["duration"])
            logging.info(f"{self.ue_id} udp_dl stop traffic {i} times, waiting for traffic {info['interval']}")
            self.__stop_traffic("dl", used_trf_id_list)
            time.sleep(info["interval"])

    def __get_a_trf_id(self):
        trf_id = self.AVAILABLE_TRF_ID[0]
        self.AVAILABLE_TRF_ID.remove(trf_id)
        self.UNAVAILABLE_TRF_ID.append(trf_id)
        return trf_id

    def __release_a_trf_id(self, trf_id):
        self.AVAILABLE_TRF_ID.append(trf_id)
        self.UNAVAILABLE_TRF_ID.remove(trf_id)

    def __start_traffic(self, tput_data, tput_value, direction, call_type, seconds, protocol="UDP"):
        used_trf_id_list = []
        if "kbps" in tput_value:
            trf_id = self.__get_a_trf_id()
            self.__send_start_traffic_cmd(tput_value, direction, trf_id, seconds, call_type, protocol)
            used_trf_id_list.append(trf_id)
        else:
            repeat_times = int(int(tput_data) / 175)
            if repeat_times > 0:
                for i in range(repeat_times):
                    trf_id = self.__get_a_trf_id()
                    self.__send_start_traffic_cmd("mbps=175", direction, trf_id, seconds, call_type, protocol)
                    used_trf_id_list.append(trf_id)
            last_tput_value = (int(tput_data) % 175)
            logging.info(f"existing_tput_value {last_tput_value}")
            if last_tput_value > 0:
                trf_id = self.__get_a_trf_id()
                self.__send_start_traffic_cmd(f"mbps={last_tput_value}",
                                              direction,
                                              trf_id,
                                              seconds,
                                              call_type,
                                              protocol)
                used_trf_id_list.append(trf_id)
        return used_trf_id_list

    def get_random_qfi(self, protocol):
        return 1
        # if protocol == "UDP":
        #     # get random from udp_qfi_list
        #     qfi = random.choice(self.udp_qfi_list)
        # else:
        #     qfi = random.choice(self.tcp_qfi_list)
        # return qfi

    def __send_start_traffic_cmd(self, tput_value, direction, trf_id, seconds, call_type, protocol="UDP"):
        if call_type == "SA":
            cmd = f"trf_data_start ue={self.ue_id} pdu=1 qfi={self.get_random_qfi(protocol)} dir={direction} " + \
                  f"{tput_value} trf_id={trf_id} seconds={seconds}"
            if protocol == "TCP":
                cmd = cmd + " protocol=tcp"
            else:
                cmd = cmd + " protocol=udp"
            self.airphone.airphone_execute_egate_command(
                cmd,
                pass_regexp="Internal traffic Receiver on Ue", alias=self.alias,
                timeout=60)
            # to get the tput average
            # cmd = f"bearer_stats ue={self.ue_id} pdu=1 qfi=1 dir={direction} dc_cell_group=all"
            # msg = self.airphone.airphone_execute_egate_command(
            #     cmd,
            #     pass_regexp="Average packet interval", alias=self.alias)
            # logging.info(msg)
        else:
            cmd = f" trf_data_start ue=${ue_id} id=2 dir=${direction} {tput_value} trf_id=${trf_id} "
            if protocol == "TCP":
                cmd = cmd + " protocol=tcp"
            self.airphone.airphone_execute_egate_command(
                cmd,
                pass_regexp="Internal traffic Receiver on Ue", alias=self.alias,
                timeout=60)

    def __stop_traffic(self, direction, trf_ids):
        # no handle the traffic due to time limition
        # pass
        global global_shared_lock
        with global_shared_lock:
            # if len(trf_ids) == 0:
            #     self.airphone.airphone_execute_egate_command(
            #         cmd=f"trf_data_stop ue={self.ue_id} pdu=1 dir={direction}", alias=self.alias)
            # else:
            #     self.airphone.airphone_execute_egate_command(
            #         cmd=f"trf_data_stop ue={self.ue_id} pdu=1 dir={direction} trf_id={','.join(trf_ids)}",
            #         alias=self.alias)
            for trf_id in trf_ids:
                self.__release_a_trf_id(trf_id)

    # @airphone_setup_teardown
    def udp_ul(self, info):
        # run command
        logging.info(f"ue{self.ue_id} udp_ul info {info}")
        tput_data = str(re.match(r"\d+", info['value']).group(0))
        tput_unit = info['value'].replace(tput_data, "")
        tput_value = f"{tput_unit}ps={tput_data}"
        for i in range(info["times"]):
            global global_shared_lock
            with global_shared_lock:
                self.reattach()
                used_trf_id_list = self.__start_traffic(tput_data,
                                                        tput_value,
                                                        "ul",
                                                        info["call_type"],
                                                        info["duration"])
                logging.info(f"{self.ue_id} udp_ul start traffic {i} times, waiting for traffic {info['duration']}")
                time.sleep(2)
            time.sleep(info["duration"])
            logging.info(f"{self.ue_id} udp_ul stop traffic {i} times, waiting for traffic {info['interval']}")
            self.__stop_traffic("ul", used_trf_id_list)
            time.sleep(info["interval"])

    # @airphone_setup_teardown
    def tcp_dl(self, info):
        logging.info(f"ue{self.ue_id} tcp_dl info {info}")
        tput_data = str(re.match(r"\d+", info['value']).group(0))
        tput_unit = info['value'].replace(tput_data, "")
        tput_value = f"{tput_unit}ps={tput_data}"
        for i in range(info["times"]):
            self.reattach()
            used_trf_id_list = self.__start_traffic(
                tput_data,
                tput_value,
                "dl",
                info["call_type"],
                info["duration"],
                protocol="TCP")
            logging.info(f"{self.ue_id} tcp_dl start traffic {i} times, waiting for traffic {info['duration']}")
            time.sleep(info["duration"])
            logging.info(f"{self.ue_id} tcp_dl stop traffic {i} times, waiting for traffic {info['interval']}")
            self.__stop_traffic("dl", used_trf_id_list)
            time.sleep(info["interval"])

    # @airphone_setup_teardown
    def tcp_ul(self, info):
        logging.info(f"ue{self.ue_id} tcp_ul info {info}")
        tput_data = str(re.match(r"\d+", info['value']).group(0))
        tput_unit = info['value'].replace(tput_data, "")
        tput_value = f"{tput_unit}ps={tput_data}"
        for i in range(info["times"]):
            self.reattach()
            used_trf_id_list = self.__start_traffic(
                tput_data,
                tput_value,
                "ul",
                info["call_type"],
                info["duration"],
                protocol="TCP")
            logging.info(f"tcp_ul start traffic {i} times, waiting for traffic {info['duration']}")
            time.sleep(info["duration"])
            logging.info(f"tcp_ul stop traffic {i} times, waiting for traffic {info['interval']}")
            self.__stop_traffic("ul", used_trf_id_list)
            time.sleep(info["interval"])

    # @airphone_setup_teardown
    def __get_physcell_id(self):
        self.psycell_id = []
        egate_log_path = "/opt/wts/latest/egate_console.log"
        logging.info(f"ue{self.ue_id} start to get psycell_id")
        with open(egate_log_path, "r") as f:
            lines = f.readlines()
            for line in lines:
                s = re.search(r"UeId:"+self.ue_id+r", BwpId:\d+, pcid:(?P<pcid>\d+), scellIdx:\d+", line)
                if s is not None:
                    pcid = s.group("pcid")
                    if pcid not in self.psycell_id:
                        psycell_id.append(s.group("pcid"))
        logging.info(f"ue{self.ue_id} get psycell_id {self.psycell_id}")

    def __get_event_type(self, info):
        if "A3" in info.keys():
            return "A3"
        elif "A5" in info.keys():
            return "A5"

    # @airphone_setup_teardown
    def intra_frequency_handover(self, info):
        global global_shared_lock
        with global_shared_lock:
            try:
                self.reattach()
                event_type = self.__get_event_type(info)
                logging.info(f"ue{self.ue_id} intra frequency handover start")
                self.__send_handover_cmd_for_event_type(
                    event_type,
                    info["target_frequency"],
                    info["target_pci"],
                    info,
                    pass_regexp=r"Intra-eNB handover from EXT_ENB-")
                time.sleep(3)
                self.__send_handover_cmd_for_event_type(
                    event_type,
                    info["source_frequency"],
                    info["source_pci"],
                    info)
                logging.info(f"ue{self.ue_id} intra frequency handover end")
            except Exception as e:
                logging.error(f"ue{self.ue_id} intra frequency handover error {e}, at {traceback.format_exc()}")
                raise e
            # finally:
            time.sleep(info['interval'])

    def __get_handover_cmd_by_info(self, event_info, psycell_id):
        cmd = ""
        if "srsrp_nr" in event_info.keys():
            cmd += "srsrp_nr=" + str(event_info["srsrp_nr"])
        if "srsrq_nr" in event_info.keys():
            cmd += " srsrq_nr=" + str(event_info["srsrq_nr"])
        cmd += " phycell_id=" + str(psycell_id)
        if "nrsrp_nr" in event_info.keys():
            cmd += " nrsrp_nr=" + str(event_info["nrsrp_nr"])
        if "nrsrq_nr" in event_info.keys():
            cmd += " nrsrq_nr=" + str(event_info["nrsrq_nr"])
        return cmd

    def __send_handover_cmd_for_event_type(self, event_type, frequency, psyid=None, info=None, pass_regexp=None):
        measurement_handler = measurements.Measurements(self.ue_id, self.airphone.get_wtssim_obj())
        if event_type == "A2":
            ue_measurement_id = measurement_handler.get_meas_id_for_measurement_on_frequency(
                meas_type="EventA2",
                carrier_freq=str(frequency),
                trigger='rsrp')
            logging.info(f"UE{self.ue_id} EventA2 ue_measurement_id {ue_measurement_id}")
            self.airphone.airphone_execute_egate_command(
                cmd=f"ue_measurement_send_nr id={self.ue_id} meas_id={ue_measurement_id} event=A2",
                alias=self.alias,
                pass_regexp="EGATE>")
        elif event_type == "A3":
            ue_measurement_id = measurement_handler.get_meas_id_for_measurement_on_frequency(
                meas_type=f"Event{event_type}",
                carrier_freq=str(frequency),
                trigger='rsrp')
            logging.info(f"UE{self.ue_id} EventA3 ue_measurement_id {ue_measurement_id}")
            self.airphone.airphone_execute_egate_command(
                cmd=f"ue_measurement_send_nr id={self.ue_id} meas_id={ue_measurement_id} event={event_type} " +
                self.__get_handover_cmd_by_info(info[event_type], psyid),
                pass_regexp=pass_regexp,
                alias=self.alias
            )

    # @airphone_setup_teardown
    def inter_frequency_handover(self, info, timeout=180):
        global global_shared_lock
        with global_shared_lock:
            try:
                self.reattach()
                logging.info(f"ue{self.ue_id} inter frequency handover start")
                self.__send_handover_cmd_for_event_type("A2", frequency=info["source_frequency"])
                time.sleep(3)
                event_type = self.__get_event_type(info)
                logging.info(f"ue{self.ue_id} inter frequency handover event type {event_type}")
                self.__send_handover_cmd_for_event_type(
                    event_type,
                    frequency=info["target_frequency"],
                    psyid=info["target_pci"],
                    info=info,
                    pass_regexp="XN Handover Successfully completed at Target")
                time.sleep(3)
                self.__send_handover_cmd_for_event_type(
                    event_type,
                    frequency=info["source_frequency"],
                    psyid=info["source_pci"],
                    info=info,
                    pass_regexp="XN Handover Successfully completed at Source")

                logging.info(f"ue{self.ue_id} inter frequency handover finish")
            except Exception as e:
                logging.error(f"ue{self.ue_id} inter frequency handover error {e}, at {traceback.format_exc()}")
                raise e
        time.sleep(info['interval'])

    def vonr(self, info, timeout=180):
        logging.info(f"ue{self.ue_id} vonr info {info}")
        for i in range(info["times"]):
            global global_shared_lock
            with global_shared_lock:
                self.reattach()
                if info['direction'] == "bi":
                    cmd_list = [f"trf_data_start ue={self.ue_id} pdu=1 qfi=2 ",
                                f"dir=ul trf_id=1",
                                f"rtp_codec=amr_wb_23_85 period_ms=20 burst=1 periods={info['duration']}"]
                    self.airphone.airphone_execute_egate_command(
                        " ".join(cmd_list),
                        alias=self.alias,
                        timeout=60)
                    cmd_list = [f"trf_data_start ue={self.ue_id} pdu=1 qfi=2 ",
                                f"dir=dl trf_id=1",
                                f"rtp_codec=amr_wb_23_85 period_ms=20 burst=1 periods={info['duration']}"]
                    self.airphone.airphone_execute_egate_command(
                        " ".join(cmd_list),
                        alias=self.alias,
                        timeout=60)
                else:
                    cmd_list = [f"trf_data_start ue={self.ue_id} pdu=1 qfi=2 ",
                                f"dir={info['direction'] if 'direction' in info.keys() else 'dl'} trf_id=1",
                                f"rtp_codec=amr_wb_23_85 period_ms=20 burst=1 periods={info['duration']}"]
                    self.airphone.airphone_execute_egate_command(
                        " ".join(cmd_list),
                        alias=self.alias,
                        timeout=60)
            logging.info(f"vonr start traffic {i} times, waiting for traffic {info['duration']}")
            time.sleep(info["duration"])
            logging.info(f"vonr stop traffic {i} times, waiting for traffic {info['interval']}")
            time.sleep(info["interval"])

    def cell_edage(self, info, timeout=180):
        logging.info(f"ue{self.ue_id} cell_edage info {info}")
        time.sleep(info["offset_time"])
        global global_shared_lock
        with global_shared_lock:
            logging.info(f"offset time finished, start entrance cell_edage ue{self.ue_id}")
            cmd = "bler_testmode_nr profile_id=1 dl_bler=400,200,100 ul_bler=400,200,100"
            self.airphone.airphone_execute_egate_command(
                cmd,
                alias=self.alias,
                timeout=60)
            cmd = "csi_override_testmode_nr profile_id=10 cqi_mode=fixed cqi=5"
            self.airphone.airphone_execute_egate_command(
                cmd,
                alias=self.alias,
                timeout=60)
            cmd = f"ue_testmode_set_nr id={self.ue_id} testmode=bler profile_id=1 action=activate"
            self.airphone.airphone_execute_egate_command(
                cmd,
                alias=self.alias,
                timeout=60)
            cmd = f"ue_testmode_set_nr id={self.ue_id} testmode=cqi profile_id=10 action=activate"
            self.airphone.airphone_execute_egate_command(
                cmd,
                alias=self.alias,
                timeout=60)
            logging.info(f"cell_edage entrance cell_edage ue{self.ue_id} success")
            time.sleep(1)
        time.sleep(info["duration"])
        with global_shared_lock:
            cmd = f"ue_testmode_set_nr id={self.ue_id} testmode=bler profile_id=1 action=deactivate"
            self.airphone.airphone_execute_egate_command(
                cmd,
                alias=self.alias,
                timeout=60)
            cmd = f"ue_testmode_set_nr id={self.ue_id} testmode=cqi profile_id=10 action=deactivate"
            self.airphone.airphone_execute_egate_command(
                cmd,
                alias=self.alias,
                timeout=60)
            logging.info(f"cell_edage exit cell_edage ue{self.ue_id} success")
            time.sleep(1)
        time.sleep(info["interval"])


# add timeout global variable
timeout_flag = False


class UeProtector(object):
    def __init__(self, ue_id_list, timeout=180):
        self.ap = Airphone()
        self.alias = "ue_protector"
        self.ap.setup(alias=self.alias)
        self.timeout = timeout
        self.ue_id_list = ue_id_list
        self.uelist_handler = {}
        self.starttime = datetime.now()
        for ue_id in ue_id_list:
            self.uelist_handler[ue_id] = Ue(ue_id,
                                            airphone_obj=self.ap.airphone,
                                            alias=self.alias)

    def reattach(self):
        global global_shared_lock
        with global_shared_lock:
            for ue_id in self.ue_id_list:
                if self.uelist_handler[ue_id].is_idle():
                    self.uelist_handler[ue_id].reattach_from_idle()

    def timeout_check(self):
        while True:
            try:
                if (datetime.now() - self.starttime).seconds > self.timeout:
                    logging.info(f"Time running out of {self.timeout}")
                    os.system("ps -ef | grep traffic_model_for_et.py | grep -v grep | awk '{print $2}' | xargs kill -9")
                    return None
                else:
                    logging.info(f"Protector time running {datetime.now()}")
                self.reattach()
                time.sleep(30)
            except Exception as e:
                logging.error(f"Protector process encountered an error: {e} {traceback.print_exc()}")
                # raise e


class UeSequenceHandle():
    def __init__(self, ue_id, airphone_obj, alias):
        self.ue_id = ue_id
        self.sequence_stream_list = []
        self.ue = Ue(self.ue_id, airphone_obj=airphone_obj, alias=alias)

    def multiple_ue_sequence(self):
        logging.info(f"Multiple UE Sequence {self.sequence_stream_list}")
        for sequence in self.sequence_stream_list:
            self.single_ue_sequence(sequence)

    def single_ue_sequence(self, sequence):
        logging.info(f'single_ue_sequence {self.ue_id}')
        for t in range(sequence["times"]):
            logging.info(f"start sequence ue {self.ue_id} {t} times")
            process_pool = []
            if "serial_step" in sequence.keys():
                for step in sequence["serial_step"]:
                    p = getattr(self.ue, step["traffic_type"])(step)
            elif "parallel_step" in sequence.keys():
                for step in sequence["parallel_step"]:
                    p = multiprocessing.Process(target=getattr(self.ue, step["traffic_type"]), args=(step,))
                    p.start()
                    process_pool.append(p)
            for p in process_pool:
                p.join()
            logging.info(f"end sequence ue {self.ue_id} {t} times")
            time.sleep(sequence["interval"])


class TrafficModelHandle(object):
    def __init__(self, traffic_module_path, lua_path, timeout, output):
        self.ap = Airphone()
        self.ap.setup()
        self.parse_json(traffic_module_path)
        self.parse_lua(lua_path)
        self.timeout = timeout
        self.output = output

    def parse_json(self, json_file):
        self.config = json.load(open(json_file))
        logging.info(f"Loading traffic model success, {self.config}")
        self.ue_list = []
        for _ue_group, sequence_info in self.config.items():
            if "-" in _ue_group:
                _ue_start, _ue_end = _ue_group.replace("UE_", "").split("-")
            else:
                _ue_start = _ue_end = _ue_group.replace("UE_", "")
            for _ue in range(int(_ue_start), int(_ue_end) + 1):
                ue = UeSequenceHandle(f"{_ue}",
                                      self.ap.airphone,
                                      alias=self.ap.get_alias_name())
                self.ue_list.append(ue)
                ue.sequence_stream_list = sequence_info

    def parse_lua(self, lua_path):
        with open(lua_path, 'r') as f:
            lua_content = f.read()
            ngbr_str = re.search(r"GBR_5QIs\s+\=\s+\{[^{}]+\}", lua_content).group(0)
            nongbr_str = re.search(r"NON_GBR_5QIs\s+\=\s+\{[^{}]+\}", lua_content).group(0)
            ngbr_str = ngbr_str.split('=', 1)[-1].strip().replace('=', ':')
            ngbr_str = ngbr_str.replace('[', '\"').replace(']', '\"').replace('\'', '"')
            nongbr_str = nongbr_str.split('=', 1)[-1].strip().replace('=', ':')
            nongbr_str = nongbr_str.replace('[', '\"').replace(']', '\"').replace('\'', '"')
            global GBR_5QIs
            global NON_GBR_5QIs
            GBR_5QIs = json.loads(ngbr_str)
            GBR_5QIs = dict((v, k) for k, v in GBR_5QIs.items())
            NON_GBR_5QIs = json.loads(nongbr_str)
            NON_GBR_5QIs = dict((v, k) for k, v in NON_GBR_5QIs.items())
            logging.info(f'GBR_5QIs: {GBR_5QIs}')
            logging.info(f'NON_GBR_5QIs: {NON_GBR_5QIs}')

    def hold_for_multiples_of_5_minutes(self):
        current_time = time.time()
        time_to_sleep = 300 - current_time % 300
        logging.info(f"sleep {time_to_sleep} seconds")
        time.sleep(time_to_sleep)

    def handle(self):
        ue_id_list = []
        # for all prehandle_step like attach
        for ue in self.ue_list:
            ue_id_list.append(ue.ue_id)
            for sequence in ue.sequence_stream_list:
                logging.info(sequence.keys())
                if "prehandle_step" in sequence.keys():
                    for step in sequence["prehandle_step"]:
                        try:
                            print(f"prehandle_step {step}")
                            getattr(ue.ue, step["traffic_type"])(step)
                        except Exception as e:
                            logging.error(f"prehandle_step error {e}, at {traceback.format_exc()}")
                            ue_id_list.remove(ue.ue_id)
        if len(ue_id_list) == 0:
            raise Exception("ue_id_list is empty after prehandle")
        # start to call ue protecter
        logging.info(f"hold for 5 minutes {ue_id_list}")
        self.hold_for_multiples_of_5_minutes()
        logging.info(f"start to call ue protecter {ue_id_list}")
        ue_id_list_str = ",".join(ue_id_list)
        command = [
            "python3", f"{os.path.abspath(__file__)}",
            "--action", "protector",
            "--id_list", ue_id_list_str,
            "--timeout", str(self.timeout),
            "--output", self.output
        ]
        logging.info(f"start to handle traffic model: {' '.join(command)}")
        subprocess.Popen(command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        i = 0
        starttime = time.time()
        while True:
            if time.time() - starttime > self.timeout:
                logging.info(f"traffic model handle killed for timeout {self.timeout}")
                os.system("ps -ef | grep traffic_model_for_et.py | grep -v grep | awk '{print $2}' | xargs kill -9")
                break
            logging.info(f"start to handle traffic model loop {i+1}")
            process_pool = []
            error_queue = multiprocessing.Queue()
            for ue in self.ue_list:
                p = multiprocessing.Process(target=ue.multiple_ue_sequence, args=())
                p.start()
                process_pool.append(p)
            logging.info(process_pool)
            for p in process_pool:
                p.join()
            while not error_queue.empty():
                ue_id, error_log = error_queue.get()
                logging.warn(f"Error in UE {ue_id}:\n{error_log}")
            logging.info(f"end to handle traffic model loop {i+1}")
            i += 1
        logging.info("traffic model handle success")


def get_user_paras():
    opt = OptionParser()
    opt.add_option("-c",
                   "--config_path",
                   type="string",
                   action="store",
                   dest="config_path",
                   help="the config path used to config the ue sequence")

    opt.add_option("-l",
                   "--lua_path",
                   type="string",
                   action="store",
                   dest="lua_path",
                   default="cer1.lua",
                   help="the lua path used to config the 5qi")
    opt.add_option("-i",
                   "--id_list",
                   type="string",
                   action="store",
                   dest="id_list",
                   help="the ue id list, just used for ue protection")
    opt.add_option("-t",
                   "--timeout",
                   type="string",
                   action="store",
                   dest="timeout",
                   help="the model will be timeout, just used for ue protection")
    opt.add_option("-o",
                   "--output",
                   type="string",
                   action="store",
                   dest="output",
                   default="~/test_results/rrm_traffic_with_airphone",
                   help="the module will output all log in dir: output")
    opt.add_option("-a",
                   "--action",
                   type="string",
                   action="store",
                   dest="action",
                   help="use for main or protector")
    (options, sys.argv[1:]) = opt.parse_args()
    return options


def protector_main(ue_id_list, timeout):
    try:
        ue_protector = UeProtector(ue_id_list, timeout)
        ue_protector.timeout_check()
    except Exception as e:
        logging.error(f"Protector process encountered an error: {e}")
        raise e


if __name__ == "__main__":
    options = get_user_paras()
    if options.action == "protector":
        logging.basicConfig(
            filename=os.path.join(options.output, "traffic_model_protector.log"),
            level=logging.DEBUG,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        ue_id_list = options.id_list.split(",")
        ue_id_list = [ue_id.strip() for ue_id in ue_id_list]
        protector_main(ue_id_list, float(options.timeout))
    else:
        time_obj = datetime.strptime(options.timeout, "%H:%M:%S").time()
        options.timeout = timedelta(hours=time_obj.hour,
                                    minutes=time_obj.minute,
                                    seconds=time_obj.second).total_seconds()
        logging.basicConfig(
            filename=os.path.join(options.output, "traffic_model.log"),
            level=logging.DEBUG,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')

        traffic_model = TrafficModelHandle(traffic_module_path=options.config_path,
                                           lua_path=options.lua_path,
                                           timeout=options.timeout,
                                           output=options.output)
        traffic_model.handle()
