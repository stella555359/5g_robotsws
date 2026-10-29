*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the TESTSUITE file for feature 5GC002481_5GC001796_B

Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py    WITH NAME    1796_b_btslog
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC002481/AGBL/B/resources/keywords_1796_B.robot

Suite Setup      Run Keywords
...              testline_preparation.prepare_testline         AND
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
[1]5GC001796_BB_TC73_UL_LA_iniDeltaSinr_Calculation_Updated_Case_different_MCS0_or_MaxMCS_BW-5MHz_NSA
    [Documentation]  check that during the transient phase improvement of 1796-B is applied and update of iniDeltaSinr
    ...              occurs for MCS different than highest and lowest MCS when NIDD parameter is set to TRUE (default value)
    5GC002481_AGBL_5GC001796_BB_TC73_UL_LA_iniDeltaSinr_Calculation_Updated_Case_different_MCS0_or_MaxMCS_BW-5MHz_NSA


5GC001796_BB_TC76_DL_LA_iniDeltaCqi_Calculation_Updated_Case_different_MCS0_or_MaxMCS_BW-15MHz_SA
    [Documentation]  check that during the transient phase improvement of 1796-B is applied and update of iniDeltaCqi
    ...              occurs for MCS different than highest and lowest MCS when NIDD parameter is set to TRUE (default value)
    5GC002481_AGBL_5GC001796_BB_TC76_DL_LA_iniDeltaCqi_Calculation_Updated_Case_different_MCS0_or_MaxMCS_BW-15MHz_SA
