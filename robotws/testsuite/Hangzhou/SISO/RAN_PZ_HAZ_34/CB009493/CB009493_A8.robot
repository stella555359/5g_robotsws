# @Time    : 2023/9/14 10:32
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB009493_A8.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB009493_A8

Suite Setup             SISO Coam Suite Setup
Suite Teardown          SISO Coam Suite Teardown
Test Setup              MMW5 Common Case Setup
Test Teardown           MMW5 Common Case Teardown
Force Tags              CRT_TRUNK    PY36

Resource                testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource                testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot

*** Variables ***
${if_commissioning}     True

*** Test Cases ***
CB009493-5G-A_114_24R1_N_CB009493_A8_Manual_SiSo_SM_BTS_Block_Site
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Log To Console    All of the TCs in this robot are optimized
#    Manual_SiSo_SM_BTS_Block_Site_2.0    ul_tp=40M    dl_tp=50M    shake_tp=${50}
#
#CB009493-5G-A_115_24R1_N_CB009493_A8_Manual_SiSo_SM_RF_Module_lock_unlock
#    [Documentation]    Author: jian.1.chen@nokia-sbell.com
#    Manual_SiSo_SM_RF_Module_lock_unlock_2.0
#
#CB009493-5G-A_116_24R1_N_CB009493_A8_General_SiSo_Auto_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    [Documentation]    Author: jian.1.chen@nokia-sbell.com
#    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_2.0
