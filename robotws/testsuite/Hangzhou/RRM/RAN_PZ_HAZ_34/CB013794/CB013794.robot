# @Time    : 2026/03/31 14:17
# @Author  : zhu.felix
# @Email   : felix.zhu@nokia.com
# @File    : CB009855_A.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: zhu felix
...    contact: felix.zhu@nokia.com
...    squad group: VRF_HAZ_07
...    Feature CB013794-A

Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    allowed_faults_ids=4291
Test Teardown        SISO Coam Test Teardown    allowed_faults_ids=4291

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB013794/CB013794_Resources/CB013794_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot

*** Variables ***

@{212_CELLS}    LNCEL-212
@{232_CELLS}    LNCEL-232
${SCF_A101_SA1}         ${CURDIR}/CB013794_Resources/SCF_A101_SA1.xml
${SCF_A101_SA2}         ${CURDIR}/CB013794_Resources/SCF_A101_SA2.xml
${SCF_A103_SA1_cell232_TM3}   ${CURDIR}/CB013794_Resources/SCF_A103_SA1_cell232_TM3.xml
${CASE1_SET_tddSpecSubfConf_5}    ${CURDIR}/CB013794_Resources/case1_set_tddSpecSubfConf_5.json
${CASE1_SET_tddSpecSubfConf_6}    ${CURDIR}/CB013794_Resources/case1_set_tddSpecSubfConf_6.json
${case2_set_prachConfIndex}    ${CURDIR}/CB013794_Resources/case2_set_prachConfIndex.json
${case3_set_15M}    ${CURDIR}/CB013794_Resources/case3_set_15M.json
${case3_set_10M}    ${CURDIR}/CB013794_Resources/case3_set_10M.json

*** Test Cases ***
[1]CB013794-A_101_Different_frame_structeres_configuraiton_without_eNB_timing_shifter_SA2
    [Documentation]    Author: felix.zhu@nokia.com
    [Tags]    101_SA2
    COAM Commission with scf file    ${SCF_A101_SA2}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
    UE Attach On Different tddSpecSubfConf
    ...    ${CASE1_SET_tddSpecSubfConf_6}    ${CASE1_SET_tddSpecSubfConf_5}    ${212_CELLS}

[1]CB013794-A_101_Different_frame_structeres_configuraiton_without_eNB_timing_shifter_SA1
    [Documentation]    Author: felix.zhu@nokia.com
    [Tags]    101_SA1
    COAM Commission with scf file    ${SCF_A101_SA1}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
    UE Attach On Different tddSpecSubfConf
    ...    ${CASE1_SET_tddSpecSubfConf_6}    ${CASE1_SET_tddSpecSubfConf_5}    ${212_CELLS}

[1]CB013794-A_103_Peak_throughput_with_UL_64QAM_Modulation_on_different_bandwidth
    [Documentation]    Author:felix.zhu@nokia.com
    [Tags]    103
    COAM Commission with scf file    ${SCF_A101_SA2}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
    verify_LTE_peak_throughput    dl_tp=125    ul_tp=10    protocol=udp
    ...    target_avg_percent=0.98    min_percent=0.85    check_source=Iperf
    Reconfigure_LTE_different_bandwidth    ${case3_set_15M}
    verify_LTE_peak_throughput    dl_tp=85    ul_tp=7.5    protocol=udp
    ...    target_avg_percent=0.98    min_percent=0.85    check_source=Iperf
    Reconfigure_LTE_different_bandwidth    ${case3_set_10M}
    verify_LTE_peak_throughput    dl_tp=60    ul_tp=4.4    protocol=udp
    ...    target_avg_percent=0.98    min_percent=0.85    check_source=Iperf

[1]CB013794-A_102_attach_SR_on_different_Prach_configuration_recommison
    [Documentation]    Author: felix.zhu@nokia.com
    [Tags]    102
    COAM Commission with scf file    ${SCF_A101_SA2}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
    UE Attach On Different prachConfIndex
    ...    ${case2_set_prachConfIndex}    ${212_CELLS}
    Verify RIP M8056C0 Update Normal

[1]CB013794-A_103_Peak_throughput_with_DL_64QAM_Modulation_on_different_bandwidth_TM3
    [Documentation]    Author:Author:felix.zhu@nokia.com
    [Tags]    103_TM3
    COAM Commission with scf file    ${SCF_A103_SA1_cell232_TM3}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
    verify_LTE_peak_throughput    dl_tp=75    ul_tp=22    protocol=udp
    ...    target_avg_percent=0.98    min_percent=0.75    check_source=Iperf
    Reconfigure_LTE_different_bandwidth    ${case3_set_15M}
    verify_LTE_peak_throughput    dl_tp=54.5    ul_tp=15    protocol=udp
    ...    target_avg_percent=0.98    min_percent=0.75    check_source=Iperf
    Reconfigure_LTE_different_bandwidth    ${case3_set_10M}
    verify_LTE_peak_throughput    dl_tp=30    ul_tp=9    protocol=udp
    ...    target_avg_percent=0.98    min_percent=0.75    check_source=Iperf