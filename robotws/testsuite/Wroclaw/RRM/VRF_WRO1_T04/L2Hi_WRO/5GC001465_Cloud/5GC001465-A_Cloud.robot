*** Settings ***
Library     ta5g_tshark
Library     ta5g_tshark.interface

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...    release: 24R3


*** Variables ***
${disabled_LA}=   ${DELTA_FILES_PATH_AIC}/5GC001465/delta_disable_LA_DU.json
${heavy_throughput_with_LA}=   ${DELTA_FILES_PATH_AIC}/5GC001465/delta_set_heavy_throughput_with_LA_DU.json
${stable_throughput_with_LA}=   ${DELTA_FILES_PATH_AIC}/5GC001465/delta_set_stable_throughput_with_LA_DU.json

*** Keywords ***
5GC001465-A 30Mhz_TC30-2_cell bandwidth for cmWave Cell_setup Without LA and actFdmScheduling= false NSA call OK Traffic UL_DL 2mbps n78
    Test_Bandwidth_NSA_TDD_30Mhz    du_delta=${disabled_LA}    throughput=2    ue_id=11

5GC001465-A 30Mhz_TC30-3_cell bandwidth for cmWave Cell_setup With LA NSA call OK Heavy Traffic UL_DL n78
    Test_Bandwidth_NSA_TDD_30Mhz    du_delta=${heavy_throughput_with_LA}    throughput=20    ue_id=12

5GC001465-A 30Mhz_TC30-4_cell bandwidth for cmWave Cell_setup With LA NSA call OK Traffic UL_DL 2mbps 30mn n78
    Test_Bandwidth_NSA_TDD_30Mhz    du_delta=${stable_throughput_with_LA}    throughput=2    ue_id=13

Test_Bandwidth_NSA_TDD_30Mhz
    [Arguments]    ${du_delta}    ${throughput}    ${ue_id}
    Perform DU Delta Commissioning    ${du_delta}
    Set Flow Control to X2
    Attach Ue And Perform SgNBAdditionRequest    ue_id=${ue_id}
    Start And Verify Data Traffic In Ul And DL    throughput=${throughput}    ue_id=${ue_id}
    Set Flow Control to F1U
    Attach Ue And Perform SgNBAdditionRequest    ue_id=${ue_id}    tshark_msg_num=2
    Start And Verify Data Traffic In Ul And DL    throughput=${throughput}    ue_id=${ue_id}

Start And verify Data Traffic In Ul And DL
    [Arguments]    ${throughput}    ${ue_id}
    Execute Egate Command    cmd=sim_debug_log level=6
    Start Data Traffic With Udp    ues_id=${ue_id}    user_bearer_id=2     throughput=${throughput}    direction=ul
    Start Data Traffic With Udp    ues_id=${ue_id}    user_bearer_id=2     throughput=${throughput}    direction=dl
    Sleep    60s
    Check Bearer Throughput For Single Ue     ue_id=${ue_id}    bearer_id=2    throughput=${throughput}
    ...    direction=ul
    Check Bearer Throughput For Single Ue     ue_id=${ue_id}    bearer_id=2    throughput=${throughput}
    ...    direction=dl
    Detach Ue    ue_id=${ue_id}

Start Data Traffic With Udp
    [Arguments]    ${ues_id}    ${user_bearer_id}     ${throughput}    ${direction}
    ta5g_throughput.Start Data Traffic  ues=${ues_id}     bearer_id=${user_bearer_id}    direction=${direction}
    ...    throughput=${throughput}mbps    optional_parameters=protocol=udp

Set Flow Control to F1U
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Split_Mode/delta_set_dlDataSplitMode_dlOverF1U_CU.json

Set Flow Control to X2
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Split_Mode/delta_set_dlDataSplitMode_dlOverX2U_CU.json

Enable AiC 1465 Delta
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC001465/delta_enable_1465_CU.json
    Perform DU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC001465/delta_enable_1465_DU.json
    Reset Aic Airphone
