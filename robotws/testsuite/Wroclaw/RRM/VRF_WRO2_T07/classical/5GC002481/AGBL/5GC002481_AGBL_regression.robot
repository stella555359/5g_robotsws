*** Settings ***
Documentation   CIT regression TCs for 5GC002481_AGBL shall be added here for fully automated regression testing.

Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC002481/AGBL/B/resources/keywords_1796_B.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC002481/AGBL/E/resources/keywords_1796_EB.robot
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py    WITH NAME    testline_preparation
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py    WITH NAME    2481_agbl_btslog

Suite Setup      Run Keywords
...              prepare_testline                       AND
...              initialise_attenuator

Test Setup       Run Keywords
...              nullify_attenuation_on_all_ports       AND
...              start_btslog_on_local_machine

Test Teardown    Run Keywords
...              Detach UE    UE_1                                AND
...              teardown_btslog                                  AND
...              Teardown TTI Traces in Streaming mode            AND
...              nullify_attenuation_on_all_ports


*** Test Cases ***
5GC001796_BB_TC73_UL_LA_iniDeltaSinr_Calculation_Updated_Case_different_MCS0_or_MaxMCS_BW-5MHz_NSA
    [Documentation]  check that during the transient phase improvement of 1796-B is applied and update of iniDeltaSinr
    ...              occurs for MCS different than highest and lowest MCS when NIDD parameter is set to TRUE (default value)
    5GC002481_AGBL_5GC001796_BB_TC73_UL_LA_iniDeltaSinr_Calculation_Updated_Case_different_MCS0_or_MaxMCS_BW-5MHz_NSA

5GC001796_BB_TC76_DL_LA_iniDeltaCqi_Calculation_Updated_Case_different_MCS0_or_MaxMCS_BW-15MHz_SA
    [Documentation]  check that during the transient phase improvement of 1796-B is applied and update of iniDeltaCqi
    ...              occurs for MCS different than highest and lowest MCS when NIDD parameter is set to TRUE (default value)
    5GC002481_AGBL_5GC001796_BB_TC76_DL_LA_iniDeltaCqi_Calculation_Updated_Case_different_MCS0_or_MaxMCS_BW-15MHz_SA

5GC001796_EB_TC46_UL_LA_64QAM-table_PTRS-ON_from_Near_to_Edge_Cell_radio_condition_SingleTX_BW-20MHz_SA
    [Documentation]    Check good table mapping
    5GC002481_AGBL_5GC001796_EB_TC46_UL_LA_64QAM-table_PTRS-ON_from_Near_to_Edge_Cell_radio_condition_SingleTX_BW-20MHz_SA
