*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     ../5GC002637_Throughput_counters/keywords_5GC002637.py
Library     ../5GC000774_ROHC/keywords_ROHC.py
Library     ta5g_bearers
Documentation
...    author: Anna Chabik
...    maintainer: Anna Chabik (anna.chabik@nokia.com)
...    testline: CLOUD_5G_I_MP_AP_LO_ANSA_FS_CPRI_CMWV_TDD
...    release: 23R2

Suite Setup     Run Keywords    Prepare Sa Test Environement
    ...       AND    Reach Onair    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...       AND    Set Internal Traffic Type To UEs
    ...       AND    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC001465/1465_delta.json
    ...       AND    Sleep    300s
Suite Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs

Test Teardown    Send Configuration ID To Scout

*** Test Cases ***
[1]5GC001465-A 30Mhz_TC30-2_cell bandwidth for cmWave Cell_setup Without LA and actFdmScheduling= false NSA call OK Traffic UL_DL 2mbps n78
    Test_Bandwidth_NSA_TDD_30Mhz    delta=Delta_disabled_LA.json    throughput=2    ue_id=11

[2]5GC001465-A 30Mhz_TC30-3_cell bandwidth for cmWave Cell_setup With LA NSA call OK Heavy Traffic UL_DL n78
    Test_Bandwidth_NSA_TDD_30Mhz    delta=Delta_heavy_throughput_with_LA.json    throughput=20    ue_id=12

[3]5GC001465-A 30Mhz_TC30-4_cell bandwidth for cmWave Cell_setup With LA NSA call OK Traffic UL_DL 2mbps 30mn n78
    Test_Bandwidth_NSA_TDD_30Mhz    delta=Delta_stable_throughput_with_LA.json    throughput=2    ue_id=13


*** Keywords ***
Test_Bandwidth_NSA_TDD_30Mhz
    [Arguments]    ${delta}    ${throughput}    ${ue_id}
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/5GC001465/${delta}
    Set Flow Control to F1U
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure    ue=${ue_id}    bearer=2    target_cells=1    dc_type=split_scg
    Verify Tshark For At Least Given Number Of Messages    alias=${DEFAULT_S1_MME_ALIAS}
    ...    packet_filter=${SGNB_RECONFIG_COMPLETE}    number_of_messages=1
    Start And Verify Data Traffic In Ul And DL    throughput=${throughput}    ue_id=${ue_id}
    Set Flow Control to X2
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure    ue=${ue_id}    bearer=2    target_cells=1    dc_type=split_scg
    Verify Tshark For At Least Given Number Of Messages    alias=${DEFAULT_S1_MME_ALIAS}
    ...    packet_filter=${SGNB_RECONFIG_COMPLETE}    number_of_messages=2
    Start And Verify Data Traffic In Ul And DL    throughput=${throughput}    ue_id=${ue_id}

Set Flow Control to F1U
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/Split_Mode/delta_dlDataSplitMode_set_to_dlOverF1U.json

Set Flow Control to X2
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/Split_Mode/delta_dlDataSplitMode_set_to_dlOverX2U.json

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
    Start Data Traffic  ues=${ues_id}     bearer_id=${user_bearer_id}    direction=${direction}
    ...    throughput=${throughput}mbps    optional_parameters=protocol=udp
