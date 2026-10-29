# -*- coding: utf-8 -*-
# @Time    : 2022/8/10 14:15
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : launch_troubleshooting_script.py
# @Software: PyCharm
from taf.sbts.oam.coam.admin.interface import admin
from taf.selenium.sbts.interface import sbts
from concurrent.futures import ThreadPoolExecutor
import time

launch_status = True
launch_result = {}


def launch_troubleshooting_script_via_admin_cli(script_name, output_file_name, cell_list, rmod_list, connection):
    try:
        launch_result = admin().launch_troubleshooting_script(script_name=script_name,
                                                              output_file_name=output_file_name,
                                                              cell_list=cell_list,
                                                              rmod_list=rmod_list,
                                                              free_parameters="",
                                                              timeout=1500,
                                                              connection=connection)
        print(launch_result)
        return launch_result
    except Exception as e:
        print(e)
        return str(e)


def launch_troubleshooting_script_via_webem(script_name, cell_list, rmod_list, timeout=1500, alias=None):
    try:
        launch_result = sbts().launch_troubleshooting_script(script_name=script_name,
                                                             script_owner_module="Radio module",
                                                             cells_name=cell_list,
                                                             mods_name=rmod_list,
                                                             timeout=timeout,
                                                             sbts=alias)
        print(launch_result)
        return launch_result
        # if "Launching failed" not in launch_result:
        #     launch_status = False
    except Exception as e:
        print(e)
        # if "Launching failed" not in e:
        #     launch_status = False
        return e


def concurrent_ru_disconnect():
    admin().perform_parameter_recommissioning(dist_name="MRBTS-2006/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1",
                                              parameter="administrativeState",
                                              value="Locked",
                                              operation="update",
                                              skip_parameter_relation_errors=True,
                                              connection="GNB_OAM")


def concurrent_ru_reset(ru_index, alia):
    sbts().reset_ru(ru_index=ru_index, with_graceful=False, sbts=alia)


def concurrent_site_reset(alia):
    sbts().reset_site(sbts=alia)


def concurrent_collect_snapshot():
    collect_result = sbts().collect_snapshot()
    return collect_result


def concurrent_between_IQ_data_and_RU_restart(cell_list, rmod_list):
    pool = ThreadPoolExecutor(max_workers=3)
    future1 = pool.submit(launch_troubleshooting_script_via_webem,
                          "RU_Common_capture_IQ_data", cell_list, rmod_list, 600, "sbts1")
    time.sleep(30)
    future2 = pool.submit(concurrent_ru_reset, 2, "sbts2")
    time.sleep(30)
    future3 = pool.submit(launch_troubleshooting_script_via_webem,
                          "RU_Common_capture_IQ_data", cell_list, rmod_list, 600, "sbts3")
    print("future1 status is：" + str(future1.done()))
    print("future2 status is：" + str(future2.done()))
    print("future3 status is：" + str(future3.done()))
    future1_result = future1.result()
    future2_result = future2.result()
    future3_result = future3.result()
    print(future1_result)
    print(future2_result)
    print(future3_result)
    pool.shutdown()
    return future1_result, future2_result, future3_result


def concurrent_between_regular_shapshot_and_IQ_data_and_register_dump(script_name_1, output_file_name_1,
                                                                      script_name_2, output_file_name_2,
                                                                      cell_list, rmod_list,
                                                                      connection1, connection2):
    pool = ThreadPoolExecutor(max_workers=3)
    future1 = pool.submit(concurrent_collect_snapshot)
    time.sleep(30)
    future2 = pool.submit(launch_troubleshooting_script_via_admin_cli,
                          script_name_1, output_file_name_1, cell_list, rmod_list, connection1)
    future3 = pool.submit(launch_troubleshooting_script_via_admin_cli,
                          script_name_2, output_file_name_2, cell_list, rmod_list, connection2)
    print("future1 status is：" + str(future1.done()))
    print("future2 status is：" + str(future2.done()))
    print("future3 status is：" + str(future3.done()))
    future1_result = future1.result()
    future2_result = future2.result()
    future3_result = future3.result()
    print(future1_result)
    print(future2_result)
    print(future3_result)
    pool.shutdown()
    return future1_result, future2_result, future3_result


def concurrent_between_IQ_data_and_regular_shapshot(script_name, output_file_name, cell_list, rmod_list, connection):
    pool = ThreadPoolExecutor(max_workers=2)
    future1 = pool.submit(launch_troubleshooting_script_via_admin_cli,
                          script_name, output_file_name, cell_list, rmod_list, connection)
    time.sleep(10)
    future2 = pool.submit(concurrent_collect_snapshot)
    print("future1 status is：" + str(future1.done()))
    print("future2 status is：" + str(future2.done()))
    future1_result = future1.result()
    future2_result = future2.result()
    print(future1_result)
    print(future2_result)
    pool.shutdown()
    return future1_result, future2_result


def concurrent_between_NE_Reset_and_IQ_data_or_L1low_dump(script_name, cell_list, rmod_list):
    pool = ThreadPoolExecutor(max_workers=3)
    future1 = pool.submit(launch_troubleshooting_script_via_webem, script_name, cell_list, rmod_list, 600, "sbts1")
    time.sleep(30)
    future2 = pool.submit(concurrent_site_reset, "sbts2")
    time.sleep(30)
    future3 = pool.submit(launch_troubleshooting_script_via_webem, script_name, cell_list, rmod_list, 600, "sbts3")
    print("future1 status is：" + str(future1.done()))
    print("future2 status is：" + str(future2.done()))
    print("future3 status is：" + str(future3.done()))
    future1_result = future1.result()
    future2_result = future2.result()
    future3_result = future3.result()
    print(future1_result)
    print(future2_result)
    print(future3_result)
    pool.shutdown()
    return future1_result, future2_result, future3_result


def concurrent_between_IQ_data_and_RU_disconnect(script_name, cell_list, rmod_list):
    pool = ThreadPoolExecutor(max_workers=2)
    future1 = pool.submit(launch_troubleshooting_script_via_webem, script_name, cell_list, rmod_list)
    time.sleep(30)
    future2 = pool.submit(concurrent_ru_disconnect)
    print("future1 status is：" + str(future1.done()))
    print("future2 status is：" + str(future2.done()))
    future1_result = future1.result()
    future2_result = future2.result()
    print(future1_result)
    print(future2_result)
    pool.shutdown()
    return future1_result


def concurrent_two_scripts_form_webem(first_script, second_script, cell_list, rmod_list):
    pool = ThreadPoolExecutor(max_workers=2)
    future1 = pool.submit(launch_troubleshooting_script_via_webem, first_script, cell_list, rmod_list, 1200, "sbts1")
    time.sleep(10)
    future2 = pool.submit(launch_troubleshooting_script_via_webem, second_script, cell_list, rmod_list, 300, "sbts2")
    print("future1 status is：" + str(future1.done()))
    print("future2 status is：" + str(future2.done()))
    future1_result = future1.result()
    future2_result = future2.result()
    print(future1_result)
    print(future2_result)
    pool.shutdown()
    return future1_result, future2_result
