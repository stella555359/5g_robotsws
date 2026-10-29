# -*- coding: utf-8 -*-
# @Time    : 2023/10/9 16:02
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : concurrent_diagnostic_check.py
# @Software: PyCharm
from taf.sbts.oam.coam.admin.interface import admin
from taf.selenium.sbts.interface import sbts
from concurrent.futures import ThreadPoolExecutor
import time


def perform_parameter_recommissioning(dist_name, parameter, value, connection="GNB_OAM"):
    try:
        recommission_result = admin().perform_parameter_recommissioning(dist_name=dist_name,
                                                                        parameter=parameter,
                                                                        value=value,
                                                                        operation="update",
                                                                        skip_parameter_relation_errors=True,
                                                                        connection=connection)
        print(recommission_result)
        return recommission_result
    except Exception as e:
        print(e)
        return str(e)


def start_diagnostic_check_via_webem(scope, radio_checkpoints, allow_service_impact, alias):
    try:
        check_result = sbts().start_diagnostic_check(scope=scope,
                                                     timeout=870,
                                                     radio_checkpoints=radio_checkpoints,
                                                     allow_service_impact=allow_service_impact,
                                                     sbts=alias)
        print(check_result)
        return check_result
    except Exception as e:
        print(e)
        return str(e)


def concurrent_between_full_and_custom_webem(radio_checkpoints, alia1, alia2, sleep=10):
    pool = ThreadPoolExecutor(max_workers=2)
    future1 = pool.submit(start_diagnostic_check_via_webem,
                          "Customized diagnostic check", radio_checkpoints, True, alia1)
    time.sleep(sleep)
    future2 = pool.submit(start_diagnostic_check_via_webem, "Full diagnostic check", None, True, alia2)
    print("future1 status is: " + str(future1.done()))
    print("future2 status is: " + str(future2.done()))
    future1_result = future1.result()
    future2_result = future2.result()
    print(future1_result)
    print(future2_result)
    pool.shutdown()
    return future1_result, future2_result


def concurrent_between_recommission_and_custom_webem(dist_name, parameter, value, radio_checkpoints, alia1, sleep=10):
    pool = ThreadPoolExecutor(max_workers=2)
    future1 = pool.submit(start_diagnostic_check_via_webem,
                          "Customized diagnostic check", radio_checkpoints, True, alia1)
    time.sleep(abs(sleep))
    future2 = pool.submit(perform_parameter_recommissioning, dist_name, parameter, value)
    print("future1 status is: " + str(future1.done()))
    print("future2 status is: " + str(future2.done()))
    future1_result = future1.result()
    future2_result = future2.result()
    print(future1_result)
    print(future2_result)
    pool.shutdown()
    return future1_result, future2_result
