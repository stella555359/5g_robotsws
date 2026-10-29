*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the TESTSUITE file for feature 5GC002481_AGBL_5GC001796-EB

Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py    WITH NAME    testline_preparation
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py    WITH NAME    1796_eb_btslog
Resource       ./resources/keywords_1796_EB.robot

Suite Setup      Run Keywords
...              testline_preparation.prepare_testline   0x1003F=1    0x10040=1    0x420000=1    0x10041=5      AND
...              initialise_attenuator

Test Setup       Run Keywords
...              nullify_attenuation_on_all_ports       AND
...              start_btslog_on_local_machine

Test Teardown    Run Keywords
    ...          Stop Data Transfer   DT_UL                       AND
    ...          Detach UE    UE_1                                AND
    ...          stop_and_collect_btslog                          AND
    ...          Teardown TTI Traces in Streaming mode            AND
    ...          nullify_attenuation_on_all_ports


*** Test Cases ***
[1]5GC001796_EB_TC46_UL_LA_64QAM-table_PTRS-ON_from_Near_to_Edge_Cell_radio_condition_SingleTX_BW-20MHz_SA
    [Documentation]    Check good table mapping
    5GC002481_AGBL_5GC001796_EB_TC46_UL_LA_64QAM-table_PTRS-ON_from_Near_to_Edge_Cell_radio_condition_SingleTX_BW-20MHz_SA
