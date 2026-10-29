*** Settings ***
Documentation
...   author: xxx xxx
...   contact: xxx.xxx@nokia.com
...   This is the TESTSUITE file for feature 5GC001178_BB for Real UE

Force Tags    PY36

Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py
Resource     ./resources/keywords_1178_BB.robot

Suite Setup      Run Keywords
...              testline_preparation.prepare_testline            AND
...              initialise_attenuator

Test Setup       Run Keywords
...              nullify_attenuation_on_all_ports                 AND
...              start_btslog_on_local_machine

Test Teardown    Run Keywords
...              Detach UE    UE_1                                AND
...              stop_and_collect_btslog                          AND
...              TcpdumpSmod.teardown_tcpdump_on_smod             AND
...              nullify_attenuation_on_all_ports


*** Test Cases ***
[1]5GC001178_BB_TC06_5GC001178_BB_DL_UL_HARQ_With_No_HARQ_Retransmissions
    [1]5GC001178_BB_TC06_5GC001178_BB_DL_UL_HARQ_With_No_HARQ_Retransmissions


[1]5GC001178_BB_TC05_5GC001178_BB_DL_UL_HARQ_With_HARQ_Retransmissions
    [1]5GC001178_BB_TC05_5GC001178_BB_DL_UL_HARQ_With_HARQ_Retransmissions
