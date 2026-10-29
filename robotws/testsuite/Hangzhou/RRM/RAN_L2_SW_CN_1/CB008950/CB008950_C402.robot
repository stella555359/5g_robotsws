*** Settings ***
Documentation      CB008950_ET_C402
Test Teardown      Common Test Teardown    check_tl=False
Suite Teardown     Common Suite Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
...               SBTS00    CN1_SG06_SM1    CB009169    owner_qiaren
Resource          ./../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${SCF_PATH}                 ${CURDIR}/Config/
${SCFC_FILE}                CB008950_c402_scfc.xml
${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts
${WTS_DIR}                  /opt/iphy/latest
${IPHY_12F_2T}              ${CURDIR}/Config/wts/iphy_12F_2T.xml
#${SWCONFIG_PARAM_GNB}       0x58057F=16;0x580641=1;0x58057a=3;0x58062d=1;0x580692=1
${WTS_CFG}                  CB008950_12F_2T.cfg
${UE_ID}                    1
@{3CC_DL_TPUT_LIST}         180    180    440
@{2CC_UL_TPUT_LIST}          50    75
@{UE1_SCELL_PHYSICALID_LIST}       50    64
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB008950_ET_C402_Scell_Swap_SA_White_List_Enabled
    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_12F_2T}
    ...        AND    Configure IP For UEC2
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
    ...        AND    Common Test Setup
    SA 5G CA Attach    ue_id=1    pdu_id=1
    Trigger A1 Scell Addition    ue_id=1    srsrp_nr=110    phycell_id=51
    Check SA All Scell PhysicalID With UE ID    ue_id=1    scell_physicalid_list=${UE1_SCELL_PHYSICALID_LIST}    cc_num=3
    Check Egate Log With Message    /opt/iphy/latest/egate_console.log     allowedCellsToAddModList

    SA Start DL Traffic Internal    ue_id=${UE_ID}     pdu_id=1    mbps=900
    SA Start UL Traffic Internal    ue_id=${UE_ID}     pdu_id=1    mbps=150
    Wait Until Keyword Succeeds    1min    5s     Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID}    ${3CC_DL_TPUT_LIST}    3
    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    ul    pcell    0    100
    Trigger A6 Event For Scell Swap    ${UE_ID}    5    1    58
    Wait Until Keyword Succeeds    1min    5s    Check Pcell Scell TP On Target After Scell Swap    ${UE_ID}    ${3CC_DL_TPUT_LIST}

    Capture Logs And Check TTitrace    log_idx=1

*** Keywords ***
Capture Logs And Check TTitrace
    [Arguments]    ${log_idx}
    #Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/${log_idx}
    CUDU_L2 Capture And Decode TTitrace    log_id=${log_idx}    duration=3
    CUDU_L2 Check DTXNACK Rate    log_id=${log_idx}
    CUDU_L2 Check UL DTXCRC Rate    log_id=${log_idx}

Trigger A6 Event For Scell Swap
    [Arguments]    ${UE_ID}    ${meas_id}    ${scell_index}    ${target_scell_id}
    Log To Console    Trigger A6 Event For Scell Swap
    ${pattern}    Set Variable    rrcReconfigurationComplete
    ${cmd}    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A6
    ...    scell=${scell_index} scell_rsrp=60 phycell_id=${target_scell_id} nrsrp_nr=80
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
    Sleep    5s    reason=wait for traffic stable

Check Pcell Scell TP On Target After Scell Swap
    [Arguments]    ${ue_id}    ${exp_dl_tput_list}
    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${exp_dl_tput_list[0]}
    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=2    target_tp=${exp_dl_tput_list[2]}
    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=3    target_tp=${exp_dl_tput_list[1]}

Configure IP For UEC2
    OperatingSystem.Run    sudo ip addr add 10.0.2.3/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.61/24 dev eth3
