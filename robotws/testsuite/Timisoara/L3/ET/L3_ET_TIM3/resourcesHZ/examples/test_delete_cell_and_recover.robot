*** Settings ***
Documentation   reources for et env
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/2cells_ecpri
${SA_UE_ID}    1
${NSA_UE_ID}    31
@{PARAMS_DELETE_CELL1}
...    NRBTS/NRDU-1:refNrCellGroup=1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4
...    delete:NRCELL-1
...    delete:NRCELL-1/NRREDRT-1
...    delete:NRCELL-1/NRREL-1
...    delete:NRCELL-2/NRREL-1
...    delete:NRCELLGRP-0

*** Test Cases ***
Test Case
    ${scf_full}    download scf
    delta commission parameters    ${PARAMS_DELETE_CELL1}
    recover scf configuration    ${scf_full}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}


Test SA UE Traffic
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${wait_timer}=0.5
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered    sleep_time=${wait_timer}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    QoS Routing Table    sleep_time=${wait_timer}
    Traffic Should Be Ok    ue_id=${ue_id}    pdu=1    type=SA

Test NSA UE Traffic
    [Arguments]    ${ue_id}=${NSA_UE_ID}    ${cmd_endc_regexp}=reported successful RA    ${wait_timer}=0.5
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE    sleep_time=${wait_timer}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    ${cmd_endc_regexp}
    ...    sleep_time=${wait_timer}
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA


