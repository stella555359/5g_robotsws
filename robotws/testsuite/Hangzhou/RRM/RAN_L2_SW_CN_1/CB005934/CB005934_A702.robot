*** Settings ***
Documentation    ...
#Test Teardown      Common Test Teardown
#Suite Teardown     Common Suite Teardown
#Force Tags         CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    RAN_5G_TDD    RAN_5G
#...                SBTS00    CN1_SG06_SM1    CB005934    owner_suxu
#
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCFC_FILE}                CB005934_A702_5fdd_scfc.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts
#${WTS_DIR}                  /opt/iphy/latest
#${IPHY_4F_2T}               ${CURDIR}/Config/wts/iphy_A702_5fdd_30MHz_40MHz.xml
#${SWCONFIG_PARAM_GNB}       0x89003B=1
#${WTS_CFG}                  CB005934_A702_5fdd.cfg
#${UE_ID3}                   3
#${UE3_4CC_4F_SCELL}         ('1', '50', '71'), ('2', '53', '25'), ('3', '54', '66')
#${UE3_4CC_4F_PCELL5}        ('1', '50', '71'), ('2', '51', '25'), ('3', '53', '25')
#@{UE3_4CC_DL_TPUT_LIST}     180    38    280    375
#@{UE3_DL_TPUT_PCELL5}       375    38    180    280
#
#${GNB_SCELL_3_ADMI_REQ_SA_ID}           M55138C03001
#${GNB_SCELL_3_ADMI_SUCC_SA_ID}          M55138C03002
#${GNB_DU_SCELL_3_ADMI_REQ_SA_ID}        M55139C03001
#${GNB_DU_SCELL_3_ADMI_SUCC_SA_ID}       M55139C03002
#${RRC_RECONF_ADD3DLSCELL_ATT_SA_ID}     M55118C09503
#${RRC_RECONF_ADD3DLSCELL_SUCC_SA_ID}    M55118C09502
#${UE_PCELL_3_CONF_SCELL_DL_SA_ID}       M55118C09501
#${CELL2_RSACU_PATH}                     CELLS/NRCELL-2/RSACU
#${CELL2_RSADU_PATH}                     CELLS/NRCELL-2/RSADU
#${CELL2_NCAC_PATH}                      CELLS/NRCELL-2/NCAC
#${CELL5_RSACU_PATH}                     CELLS/NRCELL-5/RSACU
#${CELL5_RSADU_PATH}                     CELLS/NRCELL-5/RSADU
#${CELL5_NCAC_PATH}                      CELLS/NRCELL-5/NCAC
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB005934_ET_A702_FDD_DL_4CC_A2_Event_Pcell_Change_RSRP_ActHoOptimizationCa_Enable
#    [Setup]    Run Keywords     Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_4F_2T}    swconfig_param=${SWCONFIG_PARAM_GNB}
#    #[Setup]    Run Keywords     Suite Setup Update GNB    force_reboot=True
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir
#    ...        AND    Common Test Setup
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1    actHoOptimizationCa    true
#    SA 5G CA Attach    ue_id=${UE_ID3}
#    Trigger A1 Scell Addition    ue_id=${UE_ID3}    phycell_id=51    srsrp_nr=100    meas_id=1
#    Get And Check Scell Infos     ${UE3_4CC_4F_SCELL}
#    SA Start DL Traffic Internal    ue_id=${UE_ID3}     pdu_id=1    mbps=950
#    Wait Until Keyword Succeeds    1min    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID3}    ${UE3_4CC_DL_TPUT_LIST}    4
#    SA Start UL Traffic Internal    ue_id=${UE_ID3}    pdu_id=1    mbps=175
#    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID3}    ${UE3_4CC_DL_TPUT_LIST}    4
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID3}    ul    pcell    0    165
#    Send A2 Event For Pcell Change    ue_id=${UE_ID3}    newpcell=54
#	Sleep    3s    reason=waiting for scell info printed in egate log
#    Get And Check Scell Infos     ${UE3_4CC_4F_PCELL5}
#    Wait Until Keyword Succeeds    1min    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID3}    ${UE3_DL_TPUT_PCELL5}    4
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${UE_ID3}    dir=ul    cell_type=pcell    scell_index=0    target_tp=165
#    Wait Until Keyword Succeeds    10min    5min    Check PM Counters For Pcell Change
#    Capture Logs And Check TTitrace    log_id=2
#
#*** Keywords ***
#Capture Logs And Check TTitrace
#    [Arguments]    ${log_id}
#    Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/${log_id}
#    CUDU_L2 Capture And Decode TTitrace    log_id=${log_id}    duration=3
#    CUDU_L2 Check DTXNACK Rate    log_id=${log_id}    expect_rate=0.05
#    CUDU_L2 Check UL DTXCRC Rate    log_id=${log_id}    expect_rate=0.05
#
#Check PM Counters For Pcell Change
#    #Wait Until PM Counter Update    5min    0
#    Check PM Counter Value    ${GNB_SCELL_3_ADMI_REQ_SA_ID}    ${CELL5_RSACU_PATH}
#    Check PM Counter Value    ${GNB_SCELL_3_ADMI_SUCC_SA_ID}    ${CELL5_RSACU_PATH}
#    Check PM Counter Value    ${GNB_DU_SCELL_3_ADMI_REQ_SA_ID}    ${CELL5_RSADU_PATH}
#    Check PM Counter Value    ${GNB_DU_SCELL_3_ADMI_SUCC_SA_ID}    ${CELL5_RSADU_PATH}
#    Check PM Counter Value    ${RRC_RECONF_ADD3DLSCELL_ATT_SA_ID}    ${CELL5_NCAC_PATH}
#    Check PM Counter Value    ${RRC_RECONF_ADD3DLSCELL_SUCC_SA_ID}    ${CELL5_NCAC_PATH}
#    Check PM Counter Value    ${UE_PCELL_3_CONF_SCELL_DL_SA_ID}    ${CELL5_NCAC_PATH}
#    Check PM Counter Value    ${GNB_SCELL_3_ADMI_REQ_SA_ID}    ${CELL2_RSACU_PATH}
#    Check PM Counter Value    ${GNB_SCELL_3_ADMI_SUCC_SA_ID}    ${CELL2_RSACU_PATH}
#    Check PM Counter Value    ${GNB_DU_SCELL_3_ADMI_REQ_SA_ID}    ${CELL2_RSADU_PATH}
#    Check PM Counter Value    ${GNB_DU_SCELL_3_ADMI_SUCC_SA_ID}    ${CELL2_RSADU_PATH}
#    Check PM Counter Value    ${RRC_RECONF_ADD3DLSCELL_ATT_SA_ID}    ${CELL2_NCAC_PATH}
#    Check PM Counter Value    ${RRC_RECONF_ADD3DLSCELL_SUCC_SA_ID}    ${CELL2_NCAC_PATH}
#    Check PM Counter Value    ${UE_PCELL_3_CONF_SCELL_DL_SA_ID}    ${CELL2_NCAC_PATH}
#
#Check PM Counter Value
#    [Arguments]    ${counter_id}    ${counter_path}
#    ${counter_value}    Get Max Value Of PM Counter With Admin    ${counter_id}    ${counter_path}
#    should be true    ${counter_value}>0
#
#Get Max Value Of PM Counter With Admin
#    [Arguments]    ${counter_id}    ${counter_path}    ${bts_id}=1
#    [Documentation]    This keyword is to get counter value with counter id and counter path from admin
#    @{path_list}    Split String    ${counter_path}    /
#    Append To List    ${path_list}    ${counter_id}
#    ${path_format}    Evaluate    ''.join(["['"+x+"']" for x in ${path_list}])
#    ${status_cell}    ${value}    Run Keyword And Ignore Error    Should Contain    ${path_format}    NRCELL
#    ${path_format_2}    Remove String    ${path_format}    ['CELLS']
#    COAM.Setup Admin
#    ${counter_dict}    COAM.Get Pm Counters    ${counter_id}
#    ${status}    ${value}    Run Keyword And Ignore Error    Evaluate    &{counter_dict}[BTS]${path_format}
#    ${counter_value_dict}    Run Keyword If    '${status_cell}'=='PASS' and '${status}'=='PASS'
#    ...    Evaluate    &{counter_dict}[BTS]${path_format}
#    ...    ELSE IF    '${status_cell}'=='PASS' and '${status}'=='FAIL'
#    ...    Evaluate    &{counter_dict}[BTS]['MRBTS-1']['NRBTS-${bts_id}']${path_format_2}
#    ...    ELSE IF    '${status_cell}'=='FAIL'    Evaluate    &{counter_dict}${path_format}
#    ${counter_value_list}    Get Dictionary Values    ${counter_value_dict}
#    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
#    ${max_counter_value}    Evaluate    max(${counter_value_list})
#    Log To Console    counter_path = ${counter_path} counter_id = ${counter_id} max_counter_value = ${max_counter_value} \n
#    [Return]    ${max_counter_value}
#
#Send A2 Event For Pcell Change
#    [Arguments]    ${ue_id}=1    ${newpcell}=50
#    [Documentation]    This keyword is to Send A2 Event For Pcell Change:
#    ...    5G-UE supports band combination nXA(cell 1)-nYA(cell 2)-nZA(cell 4)-nQA(cell 5) with UL support in nYA, nZA and nQA sub-blocks
#    ...    RSRP_Cell_2 for PCell
#    ...    RSRP_Cell_1 > RSRP_Cell_5
#    ...    RSRP_Cell_4 < a2MeasPCellSwitchSsbRsrp-pCellSwitchOffsetSsbRsrp + RSRP_Cell_2
#    ...    RSRP_Cell_5 > a2MeasPCellSwitchSsbRsrp-pCellSwitchOffsetSsbRsrp + RSRP_Cell_2
#    ...    Since only Cell5 meet PCell Change criteria,it's selected as PCell Change target, which is executed via intra-DU inter-freq handover.
#    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=5 event=A2 srsrp_nr=70 srsrq_nr=66
#    ...    scell=1 scell_rsrp=120 scell_rsrq=100
#    ...    scell=2 scell_rsrp=60 scell_rsrq=60
#    ...    scell=3 scell_rsrp=115 scell_rsrq=100
#    Log To Console    ${command} \n
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=2minutes
#    ${flag}    Catenate    reconfigurationWithSync with physCellId ${newpcell} is present in masterCellGroup.
#    ...    Handover will be triggered using CBRA.
#    Run Keyword and Ignore Error    Should Contain    ${output}    ${flag}
