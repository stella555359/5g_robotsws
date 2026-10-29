# *** Settings ***
# Suite Setup    Run Keywords    SISO Coam Suite Setup    AND    Modify risingTime Value In Json File    init_value=1000    target_value=99999999
# Suite Teardown    Run Keywords    Modify risingTime Value In Json File    AND    SISO Coam Suite Teardown
# Test Setup    Run Keywords    SISO Coam Test Setup    AND    Check No Unexpect Alarms
# Test Teardown        SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource     Resources/CNI80168_common_keyword.robot
# Variables    TestData/CNI80168_variables.py
# 
# Documentation
# ...    Author: Linjiangjing
# ...    Contact: jiangjing.lin@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CNI-80168
# 
# Force Tags            RAN_5G_TDD    5G_RAN_TDD    SBTS00    RAN_5G    5G_RAN    CRT_UTE	   STATE_SW_UPLOADED
# ...   PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# #[1]CNI-80168_01_ Alarm_7653 CELL FAULTY FOR NRCELL reporting_Critical_When_16to32_ pipes_Broken_made1
# #    CNI-80168_01_ Alarm_7653 CELL FAULTY FOR NRCELL reporting_Critical_When_16to32_ pipes_Broken_made1
# #
# #[1]CNI-80168_02_ Alarm_7654 CELL OPERATION DEGRADED FOR NRCELL reporting _Major_ When_5to32_ pipes_Broken_made1
# #    CNI-80168_02_ Alarm_7654 CELL OPERATION DEGRADED FOR NRCELL reporting _Major_ When_5to32_ pipes_Broken_made1
# 
# [1]CNI-80168_AEQZ_002_Alarm_Major_Antenna_Calibration_Error_TX2922_RX2923
#     CNI-80168_03_ Alarm_7655 CELL NOTIFICATION FOR NRCELL reporting _Minor_When _3to4_ pipes_Broken_made1
