*** Settings ***
Documentation
...    The purpose of this case is to verify that IQ Forwarding is achieved

# Force Tags    Classical    IPV4    IPV6    FR1
# ...    CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD    RAN_5G_TDD
# ...    RAN_5G    SBTS00
Resource            ./../Resources/common_setup.robot

Suite Setup         Common Suite Setup 2
Suite Teardown      Common Suite Teardown
# Test Setup        Create Test Directory
# Test Teardown     Common Test Teardown


*** Variables ***
${DST_FOR_BTS}          MRBTS-1/NRBTS-1
${DST_FOR_FRM}          MRBTS-1/NRBTS-1/NRCELL-1
${DST_FOR_GROUP}        MRBTS-1/NRBTS-1/NRCELLGRP-0
${DST_FOR_PMCADM}       MRBTS-1/MNL-1/PMCADM-1
${iphy_file}            ${CURDIR}/config/iphy.xml
${scf_file}             ${CURDIR}/config/scfc.xml
${SKIP_ADMIN_CLI}       ${True}
${LOCAL_WTS_DIR}        ${CURDIR}/config
${WTS_CFG}              basic_setup.cfg
${WTS_AP_XML}           iphy.xml
${DL_TPUT}              100
${UL_TPUT}              50
${DL_THRESHOLD}         80
${UL_THERSHOLD}         30
${log}                  ${True}


*** Test Cases ***
Setup with 5 cells and get throughput
    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    basic_setup.cfg
    ...    AND    Suite Setup Update GNB    scf_file=${scf_file}    iphy_file=${iphy_file}     log=${True}
    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_CFG}
    ...    AND    Suite Setup Start WTS And Check OnAir
    ...    AND    Common Test Setup 2

    Setup X2 Connection
    Log To Console    Connecting X2 link....

    NSA LTE Attach    ue_id=1
    NSA LTE Attach    ue_id=2
    NSA LTE Attach    ue_id=11
    NSA LTE Attach    ue_id=12
    NSA LTE Attach    ue_id=13

    NSA 5G Attach    ue_id=1    gnb_id=2    cell_id=1    bearer_id=2
    NSA 5G Attach    ue_id=2    gnb_id=2    cell_id=2    bearer_id=2
    NSA 5G Attach    ue_id=11    gnb_id=2    cell_id=11    bearer_id=2
    NSA 5G Attach    ue_id=12    gnb_id=2    cell_id=12    bearer_id=2
    NSA 5G Attach    ue_id=13    gnb_id=2    cell_id=13    bearer_id=2

    NSA Start DL Traffic     ue_id=1    bearer_id=2      mbps=${DL_TPUT}
    NSA Start DL Traffic     ue_id=2    bearer_id=2      mbps=${DL_TPUT}
    NSA Start DL Traffic     ue_id=11    bearer_id=2      mbps=${DL_TPUT}
    NSA Start DL Traffic     ue_id=12    bearer_id=2      mbps=${DL_TPUT}
    NSA Start DL Traffic     ue_id=13    bearer_id=2      mbps=${DL_TPUT}

    NSA Start UL Traffic     ue_id=1    bearer_id=2      mbps=${UL_TPUT}
    NSA Start UL Traffic     ue_id=2    bearer_id=2      mbps=${UL_TPUT}
    NSA Start UL Traffic     ue_id=11    bearer_id=2      mbps=${UL_TPUT}
    NSA Start UL Traffic     ue_id=12    bearer_id=2      mbps=${UL_TPUT}
    NSA Start UL Traffic     ue_id=13    bearer_id=2      mbps=${UL_TPUT}

    Wait Until Keyword Succeeds    3min    5s
    ...    NSA UE Check Throughput    UE_ID=1    dl_tp_threshold=${DL_THRESHOLD}    ul_tp_threshold=${UL_THERSHOLD}
    NSA UE Check Throughput    UE_ID=2    dl_tp_threshold=${DL_THRESHOLD}    ul_tp_threshold=${UL_THERSHOLD}
    NSA UE Check Throughput    UE_ID=11    dl_tp_threshold=${DL_THRESHOLD}    ul_tp_threshold=${UL_THERSHOLD}
    NSA UE Check Throughput    UE_ID=12    dl_tp_threshold=${DL_THRESHOLD}    ul_tp_threshold=${UL_THERSHOLD}
    NSA UE Check Throughput    UE_ID=13    dl_tp_threshold=${DL_THRESHOLD}    ul_tp_threshold=${UL_THERSHOLD}

    NSA Stop Traffic    ue_id=1    bearer_id=2    dir=ul
    NSA Stop Traffic    ue_id=2    bearer_id=2    dir=ul
    NSA Stop Traffic    ue_id=11    bearer_id=2    dir=ul
    NSA Stop Traffic    ue_id=12    bearer_id=2    dir=ul
    NSA Stop Traffic    ue_id=13    bearer_id=2    dir=ul

    NSA Stop Traffic    ue_id=1    bearer_id=2    dir=dl
    NSA Stop Traffic    ue_id=2    bearer_id=2    dir=dl
    NSA Stop Traffic    ue_id=11    bearer_id=2    dir=dl
    NSA Stop Traffic    ue_id=12    bearer_id=2    dir=dl
    NSA Stop Traffic    ue_id=13    bearer_id=2    dir=dl

    NSA LTE Detach    ue_id=1
    NSA LTE Detach    ue_id=2
    NSA LTE Detach    ue_id=11
    NSA LTE Detach    ue_id=12
    NSA LTE Detach    ue_id=13

