*** Settings ***

Documentation    :copyright: Nokia

Force Tags    RAN_5G    RAN_5G_TDD    RAN_5G_FDD    PY310
...           CLOUD_5G_I_LOO_AP_LOOO    SBTS00    SBTS25R1
...           NoResUsage

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta5g_throughput

Suite Setup      Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...              AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_TMOUS.lua    mplane_cells=@{mplane_cells}
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown   Stop Default Processes And Gather Logs And Compress Logs

Test Setup       Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Variables ***
${DURATION}                  600s
${THROUGHPUT_DL}             5m
${THROUGHPUT_UL}             5m
@{mplane_cells}=    5    6    9    12

*** Test Cases ***
1_TMO_STABILITY_SA
    Attach Ue    ue_id=1
    Start Traffic On Registered Ue SA
    Release Pdu Session    ue_id=1    pdu_id=1
    Deregister Ue    ue_id=1

2_TMO_STABILITY_NSA
    Attach Ue To Enb    ue_id=51
    Start gNB Addition Procedure
    ...    ue=51
    ...    target_gnb=2
    ...    target_cells=1
    ...    bearer=2
    ...    dc_type=split_scg
    ...    pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA

    Start Traffic On Registered Ue NSA
    Detach Ue    ue_id=51

*** Keywords ***
Start Traffic On Registered Ue SA
    Establish Pdu Session With Traffic    ue_id=1    pdu_id=1    nwslice=1    gw_id=1    direction=both    throughput=1mbps
    Wait For Throughput
    Expected Throughput For Ue Should Be Reached    ue_id=1    throughput=1
    ...    direction=ul    selection_type=average    retry=10    layer=physical    margin=0.15
    Expected Throughput For Ue Should Be Reached    ue_id=1    throughput=1
    ...    direction=dl    selection_type=average    retry=10    layer=physical    margin=0.15

Start Traffic On Registered Ue NSA
    Start Data Traffic
    ...    direction=both
    ...    ues=51
    ...    bearer_id=2
    ...    throughput=5mbps
    Wait For Throughput
    Expected Throughput For Ue Should Be Reached    ue_id=51    throughput=5
    ...    direction=ul    selection_type=average    retry=10    layer=physical    margin=0.15
    Expected Throughput For Ue Should Be Reached    ue_id=51    throughput=5
    ...    direction=dl    selection_type=average    retry=10    layer=physical    margin=0.15

Wait For Throughput
    Sleep    ${DURATION}
