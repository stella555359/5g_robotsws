# @Time    : 2022/1/24 15:52
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : class_monitor.robot
# @Software: PyCharm
*** Settings ***
Documentation    Manage all python and robot in MMW_SG5
Library     python/http_request.py
Library     python/analysis_coam.py
Library     python/analysis_counter.py
Library     python/analysis_emil.py
Library     python/analysis_excel.py
Library     python/analysis_ipconfig.py
Library     python/analysis_json.py
Library     python/analysis_operation_history.py
Library     python/analysis_snapshot.py
Library     python/analysis_syslog.py
Library     python/analysis_time.py
Library     python/analysis_ttitrace_csv.py
Library     python/analysis_txt.py
Library     python/analysis_xml.py
Library     python/csvanalyzer.py
Library     python/get_delta_json.py
Library     python/get_param_value_from_scf.py
Library     python/niddanalyzer.py
Library     python/pdmlanalyzer.py
Resource    robot/admin_sbts.robot
Resource    robot/bip.robot
Resource    robot/common_setup_teardown.robot
Resource    robot/common_variables.robot
Resource    robot/counters.robot
Resource    robot/csvanalyzer.robot
Resource    robot/m5_dcap.robot
Resource    robot/multi_ue.robot
Resource    robot/nidd_verify.robot
Resource    robot/ru.robot
Resource    robot/sbts_status.robot
Resource    robot/traffic.robot
Resource    robot/ue.robot
Resource    robot/wireshark.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
