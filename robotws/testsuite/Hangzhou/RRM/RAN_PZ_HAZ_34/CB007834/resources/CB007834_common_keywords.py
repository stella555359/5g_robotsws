import os
import logging
import subprocess
import threading
import time
from concurrent.futures import ThreadPoolExecutor
from typing import List

import yaml

# from taf.hw.rf_attenuator import rf_attenuator
from taf.transport.ssh import ssh
# from taf.sbts.oam.coam.admin import admin
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.CB007834.resources.CB007834_5G_A_variables import *
# from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.SG3.gnb_operations import paras_convert_to_json_file
# from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.sigspark_multiUE import SigSparkMutiUE
from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.CB008140.Resources.MTU_Power import SigSpark
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.sigspark import SigSpark as Spark
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.throughput.sigspark_tput import *

tl = BuiltIn().get_variable_value('${tl}')
pa_att_connection_port = tl.attenuator[1].attenuator_ports[5]
pa_att_api_port = tl.attenuator[1].port
pa_vendor = tl.attenuator[1].vendor
pa_model = tl.attenuator[1].model
pa_max_attenuation_value = 127
rf_matrix_att_connection_port = tl.attenuator[0].attenuator_ports[5]
rf_matrix_att_api_port = tl.attenuator[0].port
rf_matrix_vendor = tl.attenuator[0].vendor
rf_matrix_model = tl.attenuator[0].model
rf_matrix_max_attenuation_value = 120

# 1. Set up logging
log_path = os.path.join('/tmp/', 'e2e_case.log')
my_logger = logging.getLogger(log_path)
my_logger.setLevel(logging.DEBUG)
# 2. Create a file handler and a console handler
file_handler = logging.FileHandler(log_path, mode='w')
# console_handler = logging.StreamHandler()
# 3. Set the logging level for handlers
file_handler.setLevel(logging.DEBUG)
# console_handler.setLevel(logging.DEBUG)
# 4. Create a formatter and set it for both handlers
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)
# console_handler.setFormatter(formatter)
# 5. Add the handlers to the logger
my_logger.addHandler(file_handler)


def get_info_from_file(file_path):
    with open(file_path, "r") as f:
        test_info = yaml.safe_load(f)
    return test_info


def set_pa_value(att,
                 att_ports: List,
                 values: List,
                 att_connection_port,
                 att_ipaddr,
                 att_api_port,
                 model,
                 vendor,
                 max_attenuation_value=127):
    att.setup_attenuator(ip_addr=att_ipaddr, port=att_api_port, model=model,
                         attenuation_port_numbers=att_connection_port, max_attenuation=max_attenuation_value,
                         vendor=vendor)
    att.set_ports_attenuation(ports=att_ports, values=values)
    time.sleep(1)
    ports_values = att.read_ports_attenuation(ports=att_ports)
    print(sorted(ports_values))
    print(sorted(values))
    assert sorted(ports_values) == sorted(values)


def set_rf_matrix_value(att,
                        att_ports: List,
                        values: List,
                        att_connection_ports: List,
                        att_ipaddr,
                        att_api_port,
                        model,
                        vendor,
                        max_attenuation_value=127):
    att.setup_attenuator(ip_addr=att_ipaddr, port=att_api_port, model=model,
                         attenuation_port_numbers=att_connection_ports, max_attenuation=max_attenuation_value,
                         vendor=vendor)
    att.set_ports_attenuation(ports=att_ports, values=values)
    time.sleep(2)
    ports_values = att.read_ports_attenuation(ports=att_ports)
    print(sorted(ports_values))
    print(sorted(values))
    assert sorted(ports_values) == sorted(values)


class MultiueOperation(SigSpark, Spark):
    def __init__(self):
        super().__init__()

    def multi_ue_prepare(self,
                         ue_alias,
                         index,
                         power_reset='true',
                         detach_request=False,
                         get_spark_license=False,
                         reset_sol=None,
                         capabilities=None,
                         starting_cell=None,
                         starting_enb=None,
                         starting_phy_cell=None,
                         ue_num_input=None,
                         required_spark_license_time=2,
                         force_check_ue=False,
                         eq_index=None
                         ):
        self.require_ue(ue_alias=ue_alias,
                        power_reset=power_reset,
                        detach_request=detach_request,
                        get_spark_license=get_spark_license,
                        index=index,
                        reset_sol=reset_sol,
                        capabilities=capabilities,
                        starting_cell=starting_cell,
                        starting_enb=starting_enb,
                        starting_phy_cell=starting_phy_cell,
                        ue_num_input=ue_num_input,
                        required_spark_license_time=required_spark_license_time,
                        force_check_ue=force_check_ue,
                        eq_index=eq_index)

    def multi_ue_attach(self,
                        ue_alias,
                        attach_mode='5G_SA',
                        power_reset="False",
                        timeout=-1):
        self.attach_ue(ue_alias=ue_alias,
                       attach_mode=attach_mode,
                       power_reset=power_reset,
                       timeout=timeout)

    # def multi_ues_attach(self,
    #                      ue_index_mtu_all):
    #     for i in ue_index_mtu_all:
    #         self.multi_ue_attach(ue_alias=f'ue_{str(i)}')
    #         time.sleep(3)

    def multi_ue_detach(self,
                        ue_alias):
        self.detach_ue(ue_alias=ue_alias)

    def multi_ues_detach(self,
                         ue_index_mtu_all):
        for i in ue_index_mtu_all:
            self.multi_ue_detach(ue_alias=f'ue_{str(i)}')
            time.sleep(3)

    # def multi_ues_get_imsi(self,
    #                        ue_index_mtu_all,
    #                        power_reset='true',
    #                        detach_request=False,
    #                        get_spark_license=False,
    #                        reset_sol=None,
    #                        capabilities=None,
    #                        starting_cell=None,
    #                        starting_enb=None,
    #                        starting_phy_cell=None,
    #                        ue_num_input=None,
    #                        required_spark_license_time=2,
    #                        force_check_ue=False,
    #                        eq_index=None):
    #     for i in ue_index_mtu_all:
    #         self.multi_ue_prepare(ue_alias=f'ue_{str(i)}',
    #                               power_reset=power_reset,
    #                               detach_request=detach_request,
    #                               get_spark_license=get_spark_license,
    #                               index=i,
    #                               reset_sol=reset_sol,
    #                               capabilities=capabilities,
    #                               starting_cell=starting_cell,
    #                               starting_enb=starting_enb,
    #                               starting_phy_cell=starting_phy_cell,
    #                               ue_num_input=ue_num_input,
    #                               required_spark_license_time=required_spark_license_time,
    #                               force_check_ue=force_check_ue,
    #                               eq_index=eq_index)
    #         time.sleep(3)

    def multi_ue_power_off_or_on(self,
                                 ue_alias='ue_0',
                                 power_on='true',
                                 mtu_index=1,
                                 index=0,
                                 get_spark_license=True,
                                 reset_sol=None):
        self.mtu_power(ue_alias=ue_alias,
                       power_on=power_on,
                       mtu_index=mtu_index,
                       index=index,
                       get_spark_license=get_spark_license,
                       reset_sol=reset_sol
                       )

    def send_at_commond(self,
                        ue_alias,
                        param):
        self.send_AT_command_CPE(ue_alias=ue_alias,
                                 param=param)

    def get_multi_ue_pdu_ip(self,
                            apnaddress,
                            ue_alias):
        pdu_ip = self.get_pdu_ip(apnaddress=apnaddress,
                                 ue_alias=ue_alias)
        return pdu_ip

    def multi_ue_make_traffic(self,
                              ue_alias,
                              direction):
        self.start_data_transfer(ue_alias=ue_alias,
                                 direction=direction)

    def collect_multi_ue_throughput(self,
                                    ue_alias):
        self.check_throughput_on_ue(ue_alias=ue_alias)

    def check_multi_ue_throughput(self,
                                  tput,
                                  direction,
                                  target_throughput,
                                  target_avg_percent=0.95):
        get_sigspark_throughput(tput=tput,
                                direction=direction)
        check_sigspark_throughput(tput=tput,
                                  direction=direction,
                                  target_throughput=target_throughput,
                                  target_avg_percent=target_avg_percent)

    def multi_ue_stop_traffic(self,
                              direction,
                              ue_alias):
        self.stop_data_transfer(direction=direction,
                                ue_alias=ue_alias)


def to_close_mtu(ue_index,
                 MTU='MTU Monitor & Controller.exe',
                 alias='cygwin'):
    csn = ssh()
    try:
        csn.connect_to(
            hostname=tl.ues[ue_index].ssh_connection_details.addr,
            username=tl.ues[ue_index].ssh_connection_details.username,
            password=tl.ues[ue_index].ssh_connection_details.password,
            alias=alias,
            timeout=60
        )
        csn.execute(command=f"taskkill /F /IM '{MTU}'",
                    connection=alias)
    except Exception as e:
        print(e)
        my_logger.error(f'to_close_mtu: {ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def to_close_spark(ue_index,
                   alias='cygwin'):
    csn = ssh()
    try:
        csn.connect_to(
            hostname=tl.ues[ue_index].ssh_connection_details.addr,
            username=tl.ues[ue_index].ssh_connection_details.username,
            password=tl.ues[ue_index].ssh_connection_details.password,
            alias=alias,
            timeout=60
        )
        csn.execute(command=f"taskkill /F /IM Spark.exe",
                    connection=alias)
    except Exception as e:
        print(e)
        my_logger.error(f'to_close_spark: {ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def to_open_spark(ue_index,
                  alias='cygwin'):
    csn = ssh()
    try:
        csn.connect_to(
            hostname=tl.ues[ue_index].ssh_connection_details.addr,
            username=tl.ues[ue_index].ssh_connection_details.username,
            password=tl.ues[ue_index].ssh_connection_details.password,
            alias=alias,
            timeout=60
        )
        csn.execute(command=f"schtasks /run /tn spark_open",
                    connection=alias)
    except Exception as e:
        print(e)
        my_logger.error(f'to_close_spark: {ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def to_open_mtu(ue_index,
                alias='cygwin'):
    csn = ssh()
    try:
        csn.connect_to(
            hostname=tl.ues[ue_index].ssh_connection_details.addr,
            username=tl.ues[ue_index].ssh_connection_details.username,
            password=tl.ues[ue_index].ssh_connection_details.password,
            alias=alias,
            timeout=60
        )
        csn.execute(command=f"schtasks /run /tn MTU_open",
                    connection=alias)
    except Exception as e:
        print(e)
        my_logger.error(f'to_close_spark: {ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def ues_operate_via_py(path,
                       file_name,
                       pc_ip,
                       pc_usr,
                       pc_pwd,
                       tl_id='363'):
    print(f"source CIENV/7_5_UTE5G402T{tl_id}/bin/activate; ptyhon /{path}{file_name} {pc_ip} {pc_usr} {pc_pwd}")
    command = f"source CIENV/7_5_UTE5G402T{tl_id}/bin/activate; ptyhon /{path}{file_name} {pc_ip} {pc_usr} {pc_pwd}"
    subprocess.Popen(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )


def make_vonr_call_per_ue(ue_index):
    sn = tl.ues[ue_index].serial_number
    alias = f'cpc_{ue_index}'
    csn = ssh()
    try:
        csn.connect_to(
            hostname=tl.ues[ue_index].ssh_connection_details.addr,
            username=tl.ues[ue_index].ssh_connection_details.username,
            password=tl.ues[ue_index].ssh_connection_details.password,
            alias=alias,
            timeout=60
        )
        time.sleep(3)
        csn.execute(command=f'adb -s {sn} shell am start -a android.intent.action.CALL tel:+6688',
                    connection=alias)
        my_logger.info(f'adb -s {sn} shell am start -a android.intent.action.CALL tel:+6688')
        time.sleep(1)
    except Exception as e:
        print(e)
        my_logger.error(f'make_vonr_call: ue_index: {ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def make_vonr_calls(ue_index_list):
    with ThreadPoolExecutor(max_workers=40) as executor:
        futures = [executor.submit(make_vonr_call_per_ue, ue_index) for ue_index in ue_index_list]
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


def hang_up_vonr_call_per_ue(ue_index):
    sn = tl.ues[ue_index].serial_number
    alias = f'cpc_{ue_index}'
    csn = ssh()
    try:
        csn.connect_to(
            hostname=tl.ues[ue_index].ssh_connection_details.addr,
            username=tl.ues[ue_index].ssh_connection_details.username,
            password=tl.ues[ue_index].ssh_connection_details.password,
            alias=alias,
            timeout=60
        )
        time.sleep(3)
        csn.execute(command=f'adb -s {sn} shell input keyevent 6', connection=alias)
        my_logger.info(f'adb -s {sn} shell input keyevent 6')
        time.sleep(1)
    except Exception as e:
        print(e)
        my_logger.error(f'hang_up_vonr_call: ue_index: {ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def hang_up_vonr_calls(ue_index_list):
    with ThreadPoolExecutor(max_workers=40) as executor:
        futures = [executor.submit(hang_up_vonr_call_per_ue, ue_index) for ue_index in ue_index_list]
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


def make_emc_call_per_ue(ue_index):
    sn = tl.ues[ue_index].serial_number
    alias = f'cpc_{ue_index}'
    csn = ssh()
    try:
        csn.connect_to(
            hostname=tl.ues[ue_index].ssh_connection_details.addr,
            username=tl.ues[ue_index].ssh_connection_details.username,
            password=tl.ues[ue_index].ssh_connection_details.password,
            alias=alias,
            timeout=60
        )
        time.sleep(3)
        brand = csn.execute(command=f'adb -s {sn} shell getprop ro.product.brand', connection=alias)
        my_logger.info(f'adb -s {sn} shell getprop ro.product.brand')
        if 'samsung' in brand:
            home_key_event = '3'
        elif 'qti' in brand:
            home_key_event = '82'
        elif 'alps' in brand:
            home_key_event = '82'
        is_awake = csn.execute(command=f'adb -s {sn} shell dumpsys window | grep mAwake', connection=alias)
        my_logger.info(f'adb -s {sn} shell dumpsys window | grep mAwake')
        if 'mAwake=false' in is_awake:
            csn.execute(command=f'adb -s {sn} shell input keyevent {home_key_event}', connection=alias)
            my_logger.info(f'adb -s {sn} shell input keyevent {home_key_event}')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell input swipe 500 2050 500 800', connection=alias)
            my_logger.info(f'adb -s {sn} shell input swipe 500 2050 500 800')
            time.sleep(2)
        if ('samsung' in brand) or ('alps' in brand):
            csn.execute(command=f'adb -s {sn} shell input tap 302 2108', connection=alias)
            my_logger.info(f'adb -s {sn} shell input tap 302 2108')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell am start -a android.intent.action.CALL tel:911',
                        connection=alias)
            my_logger.info(f'adb -s {sn} shell am start -a android.intent.action.CALL tel:911')
            time.sleep(2)
            if 'alps' in brand:
                csn.execute(command=f'adb -s {sn} shell input tap 545 2121', connection=alias)
                my_logger.info(f'adb -s {sn} shell input tap 545 2121')
            else:
                csn.execute(command=f'adb -s {sn} shell input tap 538 1959', connection=alias)
                my_logger.info(f'adb -s {sn} shell input tap 538 1959')
        elif 'qti' in brand:
            csn.execute(command=f'adb -s {sn} shell am start -a android.intent.action.DIAL', connection=alias)
            my_logger.info(f'adb -s {sn} shell am start -a android.intent.action.DIAL')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell input text 911', connection=alias)
            my_logger.info(f'adb -s {sn} shell input text 911')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell input tap 711 2952', connection=alias)
            my_logger.info(f'adb -s {sn} shell input tap 711 2952')
        time.sleep(1)
    except Exception as e:
        print(e)
        my_logger.error(f'make_emc_call: ue_index: {ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def make_emc_calls(ue_index_list):
    with ThreadPoolExecutor(max_workers=40) as executor:
        futures = [executor.submit(make_emc_call_per_ue, ue_index) for ue_index in ue_index_list]
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


def hang_up_emc_call_per_ue(ue_index):
    sn = tl.ues[ue_index].serial_number
    alias = f'cpc_{ue_index}'
    csn = ssh()
    try:
        csn.connect_to(
            hostname=tl.ues[ue_index].ssh_connection_details.addr,
            username=tl.ues[ue_index].ssh_connection_details.username,
            password=tl.ues[ue_index].ssh_connection_details.password,
            alias=alias,
            timeout=60
        )
        time.sleep(3)
        brand = csn.execute(command=f'adb -s {sn} shell getprop ro.product.brand', connection=alias)
        my_logger.info(f'adb -s {sn} shell getprop ro.product.brand')
        if 'samsung' in brand:
            home_key_event = '3'
        elif 'qti' in brand:
            home_key_event = '82'
        elif 'alps' in brand:
            home_key_event = '82'
        is_awake = csn.execute(command=f'adb -s {sn} shell dumpsys window | grep mAwake', connection=alias)
        my_logger.info(f'adb -s {sn} shell dumpsys window | grep mAwake: {is_awake}')
        if 'mAwake=false' in is_awake:
            csn.execute(command=f'adb -s {sn} shell input keyevent {home_key_event}', connection=alias)
            my_logger.info(f'adb -s {sn} shell input keyevent {home_key_event}')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell input swipe 500 2050 500 800', connection=alias)
            my_logger.info(f'adb -s {sn} shell input swipe 500 2050 500 800')
            time.sleep(2)
        if 'samsung' in brand:
            csn.execute(command=f'adb -s {sn} shell input tap 302 2108', connection=alias)
            my_logger.info(f'adb -s {sn} shell input tap 302 2108')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell input tap 538 1959', connection=alias)
            my_logger.info(f'adb -s {sn} shell input tap 538 1959')
        elif 'qti' in brand:
            csn.execute(command=f'adb -s {sn} shell input tap 711 2752', connection=alias)
            my_logger.info(f'adb -s {sn} shell input tap 711 2752')
        elif 'alps' in brand:
            # csn.execute(command=f'adb -s {sn} shell input keyevent {home_key_event}', connection=alias)
            # my_logger.info(f'adb -s {sn} shell input keyevent {home_key_event}')
            csn.execute(command=f'adb -s {sn} shell input tap 545 2121', connection=alias)
            my_logger.info(f'adb -s {sn} shell input tap 545 2121')
        time.sleep(1)
    except Exception as e:
        print(e)
        my_logger.error(f'hang_up_emc_call: ue_index: {ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def hang_up_emc_calls(ue_index_list):
    with ThreadPoolExecutor(max_workers=40) as executor:
        futures = [executor.submit(hang_up_emc_call_per_ue, ue_index) for ue_index in ue_index_list]
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


# def connect_to_bts(oam,
#                    bts_host,
#                    connection,
#                    username='Nemuamdin',
#                    password='nemuuser',
#                    bts_port=443
#                    ):
#     oam.connect_to(bts_host=bts_host,
#                    bts_port=bts_port,
#                    username=username,
#                    password=password,
#                    name=connection)
#
#
# def disconnect_bts(coam,
#                    connection):
#     coam.teardown(connection=connection)
#
#
# def modify_parameters_via_admin(bts_host,
#                                 connection,
#                                 delta_file_name,
#                                 skip_parameter_relation_errors=False,
#                                 username='Nemuamdin',
#                                 password='numuuser',
#                                 bts_port=443):
#     coam = admin()
#     try:
#         connect_to_bts(oam=coam,
#                        bts_host=bts_host,
#                        bts_port=bts_port,
#                        username=username,
#                        password=password,
#                        connection=connection)
#     except Exception as e:
#         raise my_logger.error(f"coam connect bts failed: {e}")
#     else:
#         coam.perform_delta_recommissioning(delta_file=delta_file_name,
#                                            timeout=300,
#                                            skip_parameter_relation_errors=skip_parameter_relation_errors,
#                                            connection=connection)
#     finally:
#         disconnect_bts(coam=coam,
#                        connection=connection)


# def set_pa(ports: List,
#            values: List,
#            pa_index=1):
#     att = rf_attenuator()
#     set_pa_value(att=att,
#                  att_ports=ports,
#                  values=values,
#                  att_connection_port=tl.attenuator[pa_index].attenuator_ports[5],
#                  att_ipaddr=tl.attenuator[pa_index].ip_addr,
#                  att_api_port=tl.attenuator[pa_index].port,
#                  model=tl.attenuator[pa_index].model,
#                  vendor=tl.attenuator[pa_index].vendor,
#                  max_attenuation_value=pa_max_attenuation_value
#                  )


# def recover_pa(ports: List,
#                pa_index=1):
#     att = rf_attenuator()
#     set_pa_value(att=att,
#                  att_ports=ports,
#                  values=[pa_max_attenuation_value] * len(ports),
#                  att_connection_port=tl.attenuator[pa_index].attenuator_ports[5],
#                  att_ipaddr=tl.attenuator[pa_index].ip_addr,
#                  att_api_port=tl.attenuator[pa_index].port,
#                  model=tl.attenuator[pa_index].model,
#                  vendor=tl.attenuator[pa_index].vendor,
#                  max_attenuation_value=pa_max_attenuation_value
#                  )


# def recover_rf_matrix(rf_matrix_index=0):
#     att = rf_attenuator()
#     set_rf_matrix_value(att=att,
#                         att_ports=[i for i in range(1, 257)],
#                         values=[rf_matrix_max_attenuation_value] * 256,
#                         att_connection_ports=[i for i in range(1, 257)],
#                         att_ipaddr=tl.attenuator[rf_matrix_index].ip_addr,
#                         att_api_port=tl.attenuator[rf_matrix_index].port,
#                         model=tl.attenuator[rf_matrix_index].model,
#                         vendor=tl.attenuator[rf_matrix_index].vendor,
#                         max_attenuation_value=rf_matrix_max_attenuation_value
#                         )


# def set_precondition_values_with_rf_matrix(ports: List,
#                                            values: List,
#                                            rf_matrix_index=0):
#     att = rf_attenuator()
#     set_rf_matrix_value(att=att,
#                         att_ports=ports,
#                         values=values,
#                         att_connection_ports=ports,
#                         att_ipaddr=tl.attenuator[rf_matrix_index].ip_addr,
#                         att_api_port=tl.attenuator[rf_matrix_index].port,
#                         model=tl.attenuator[rf_matrix_index].model,
#                         vendor=tl.attenuator[rf_matrix_index].vendor,
#                         max_attenuation_value=rf_matrix_max_attenuation_value
#                         )


# def loop_cell21_ho_gnb2_cell1(source_ports: List[int],
#                               source_values: List[int],
#                               target_ports: List[int],
#                               target_values: List[int],
#                               step: int,
#                               ho_times=1000,
#                               rf_matrix_index=0):
#     att = rf_attenuator()
#     att.setup_attenuator(ip_addr=tl.attenuator[rf_matrix_index].ip_addr,
#                          port=tl.attenuator[rf_matrix_index].port,
#                          model=tl.attenuator[rf_matrix_index].model,
#                          attenuation_port_numbers=source_ports,
#                          max_attenuation=rf_matrix_max_attenuation_value,
#                          vendor=tl.attenuator[rf_matrix_index].vendor)
#
#     for t in range(ho_times):
#         for i in range(source_values[0], target_values[0] + step, step):
#             v = [i] * len(source_ports)
#             att.set_ports_attenuation(ports=source_ports, values=v)
#             time.sleep(1)
#             # ports_values = att.read_ports_attenuation(ports=source_ports)
#             # print(sorted(ports_values))
#             print(sorted(v))
#             # assert sorted(ports_values) == sorted(v)
#         for i in range(target_values[0], source_values[0] - step, -step):
#             v = [i] * len(target_ports)
#             att.set_ports_attenuation(ports=target_ports, values=v)
#             time.sleep(1)
#             # ports_values = att.read_ports_attenuation(ports=target_ports)
#             # print(sorted(ports_values))
#             print(sorted(v))
#             # assert sorted(ports_values) == sorted(v)


def group_2():
    multi_ue = MultiueOperation()
    for i in range(5, 8):
        multi_ue.multi_ue_prepare(ue_alias=f'ue_{str(i)}',
                                  index=i)
        time.sleep(10)
        multi_ue.multi_ue_attach(ue_alias=f'ue_{str(i)}',
                                 power_reset='true')
        time.sleep(10)
        pdu_ip = multi_ue.get_multi_ue_pdu_ip(apnaddress='dxstatic8',
                                              ue_alias=f'ue_{str(i)}')
        # multi_ue.multi_ue_make_traffic(ue_alias=0, direction='dl')
        # multi_ue.multi_ue_make_traffic(ue_alias=0, direction='ul')
    # UE detach


# def set_nr_pa_value_to_start_group_3(ports: List,
#                                      values: List):
#     att = rf_attenuator()
#     att.setup_attenuator(ip_addr=tl.attenuator[1].ip_addr,
#                          port=pa_att_api_port,
#                          model=pa_model,
#                          attenuation_port_numbers=pa_att_connection_port,
#                          max_attenuation=pa_max_attenuation_value,
#                          vendor=pa_vendor)
#     # 5G
#     att.set_ports_attenuation(ports=ports, values=values)
#     time.sleep(1)
#     ports_values = att.read_ports_attenuation(ports=ports)
#     print(sorted(ports_values))
#     print(sorted(values))
#     assert sorted(ports_values) == sorted(values)


# def inter_rat_ho_make_voice(lte_ports: List,
#                             lte_values: List,
#                             lte_source_value: int,
#                             lte_target_value: int,
#                             lte_steps: int,
#                             nr_ports: List,
#                             nr_values_1: List,
#                             nr_values_2: List,
#                             nr_source_value: int,
#                             nr_target_value: int,
#                             nr_steps: int,
#                             ho_times: int):
#     att = rf_attenuator()
#     att.setup_attenuator(ip_addr=tl.attenuator[1].ip_addr,
#                          port=pa_att_api_port,
#                          model=pa_model,
#                          attenuation_port_numbers=pa_att_connection_port,
#                          max_attenuation=pa_max_attenuation_value,
#                          vendor=pa_vendor)
#     for t in range(ho_times):
#         # 4G
#         att.set_ports_attenuation(ports=lte_ports, values=lte_values)
#         time.sleep(1)
#         ports_values = att.read_ports_attenuation(ports=lte_ports)
#         print(sorted(ports_values))
#         print(sorted(lte_values))
#         assert sorted(ports_values) == sorted(lte_values)
#         for i in range(nr_source_value, nr_target_value + nr_steps, nr_steps):
#             # 5G
#             att.set_ports_attenuation(ports=nr_ports, values=[i, i, i, i])
#             time.sleep(1)
#             ports_values = att.read_ports_attenuation(ports=nr_ports)
#             print(sorted(ports_values))
#             print(sorted([i, i, i, i]))
#             assert sorted(ports_values) == sorted([i, i, i, i])
#         time.sleep(10)
#         # 5G
#         att.set_ports_attenuation(ports=nr_ports, values=nr_values_1)
#         time.sleep(1)
#         ports_values = att.read_ports_attenuation(ports=nr_ports)
#         print(sorted(ports_values))
#         print(sorted(nr_values_1))
#         assert sorted(ports_values) == sorted(nr_values_1)
#         # 4G
#         for i in range(lte_source_value, lte_target_value + lte_steps, lte_steps):
#             att.set_ports_attenuation(ports=lte_ports, values=[i, i, i, i])
#             time.sleep(1)
#             ports_values = att.read_ports_attenuation(ports=lte_ports)
#             print(sorted(ports_values))
#             print(sorted([i, i, i, i]))
#             assert sorted(ports_values) == sorted([i, i, i, i])
#         time.sleep(10)
#         # 5G
#         att.set_ports_attenuation(ports=nr_ports, values=nr_values_2)
#         time.sleep(1)
#         ports_values = att.read_ports_attenuation(ports=nr_ports)
#         print(sorted(ports_values))
#         print(sorted(nr_values_2))
#         assert sorted(ports_values) == sorted(nr_values_2)


def make_vonr_and_emc_call(vonr_ue_index,
                           emc_ue_index):
    g1 = threading.Thread(target=make_vonr_call_per_ue, args=(vonr_ue_index,))
    g2 = threading.Thread(target=make_emc_call_per_ue, args=(emc_ue_index,))
    g1.start()
    g2.start()
    g1.join()
    g2.join()


def hang_up_vonr_and_emc_call(vonr_ue_index,
                              emc_ue_index):
    g1 = threading.Thread(target=hang_up_vonr_call_per_ue, args=(vonr_ue_index,))
    g2 = threading.Thread(target=hang_up_emc_call_per_ue, args=(emc_ue_index,))
    g1.start()
    g2.start()
    g1.join()
    g2.join()
