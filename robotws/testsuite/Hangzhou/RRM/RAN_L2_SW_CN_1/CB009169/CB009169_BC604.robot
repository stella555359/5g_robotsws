*** Settings ***
Documentation    ...
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup        #Common Suite Setup
##Test Setup         Common Test Setup
#Test Teardown      Common Test Teardown
#Suite Teardown     Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    CN1_SG06_SM1    CB009169    owner_qiaren
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCFC_FILE}                CB009169_BC604_4cc_scfc.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Resources/wts/
#${WTS_DIR}                  /opt/iphy/latest
#${IPHY_2F_2T}               ${CURDIR}/Resources/wts/iphy_2F_2T.xml
#${SWCONFIG_PARAM_GNB}     0x58057F=16;0x580692=1
#${SWCONFIG_PARAM_AP}        0x70690=1;
#${WTS_CFG}            CB009169_BC1101.cfg
#${WTS_AP_XML}               airphone.xml
#${UE_ID}                    2
#${4CC_3F1T_SCELL}           ('1', '50', '71'), ('2', '51', '25'), ('3', '61', '41')
#&{GNB_ASIK}                 ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
#@{4CC_DL_TPUT_LIST}          400    38    180    180
#@{2CC_UL_TPUT_LIST}          75    50
#
#*** Test Cases ***
#CB009169_ET_BC604_1TDD_3FDD_DL4CC_UL2CC_A1_ScellAdd_BufferBaseScellAct_3GPP_Overheating_CQI0
#    [Setup]    Run Keywords     Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_2F_2T}    swconfig_param=${SWCONFIG_PARAM_GNB}
#    ...    swconfig_param_AP=${SWCONFIG_PARAM_AP}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir
#    ...        AND    Common Test Setup
#    SA 5G CA Attach    ue_id=${UE_ID}     pdu_id=1
#    Trigger A1 Scell Addition    ue_id=${UE_ID}    phycell_id=61    srsrp_nr=120    meas_id=1
#    SA Start UL Traffic Internal    ue_id=${UE_ID}     pdu_id=1    mbps=150
#    Wait Until Keyword Succeeds    1min    5s   Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_ID}    ${2CC_UL_TPUT_LIST}    4
#    SA Start DL Traffic Internal    ue_id=${UE_ID}     pdu_id=1    mbps=900
#    Verify Scells Are Activation    cell_nums=4
#    Wait Until Keyword Succeeds    1min    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID}    ${4CC_DL_TPUT_LIST}    4
#    Wait Until Keyword Succeeds    1min    5s   Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_ID}    ${2CC_UL_TPUT_LIST}    4
#    Send Send Assistance Information And Check Scell Active Status    2    ${UE_ID}     2    1    1    deactivated
#    Send CQI Equal 0 And Check Scell Suspend
#    Send Send Assistance Information And Check Scell Active Status    3    ${UE_ID}     0    0    3    deactivated
#    Send CQI Equal 15 And Check Scell TP
#    Send Send Assistance Information And Check Scell Active Status    4    ${UE_ID}     3    1    4    activated
#    Wait Until Keyword Succeeds    1min    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID}    ${4CC_DL_TPUT_LIST}    4
#    Wait Until Keyword Succeeds    1min    5s   Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_ID}    ${2CC_UL_TPUT_LIST}    4
#
#*** Keywords ***
#Send Send Assistance Information And Check Scell Active Status
#    [Arguments]    ${log_id}    ${ue_id}    ${reducedCCsDL}    ${reducedCCsUL}    ${cell_nums}    ${scell_active_status}=activated
#    Start Ttitrace With Streaming Mode
#    Send OAI To GNB    ${ue_id}    yes    ${reducedCCsDL}    ${reducedCCsUL}
#    Check Scell Active Status From Egate    ${cell_nums}    ${scell_active_status}
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#    CUDU_L2 Check UL DTXCRC Rate   ${log_id}
#    CUDU_L2 Check DTXNACK Rate    ${log_id}
#
#Check Scell Active Status From Egate
#    [Arguments]    ${scell_nums}    ${scell_active_status}=activated
#    ${loop}    Evaluate    ${scell_nums}+1
#    Log To Console    \nverify Scell Activation or Deactivation Info...
#    FOR    ${id}    IN RANGE    1    ${loop}
#    Check Scell Status    ${id}    ${scell_active_status}
#    END
#
#Send CQI Equal 0 And Check Scell Suspend
#    Set CQI Testmode    profile_id=3    cqi=0
#    CUDU_L2 Send Action To GNB    ue_id=${UE_ID}     testmode=csi_override    action=activate    profile_id=3    scell=3
#    Sleep    10s    reason=Wait for scell DL data
#    ${scell_TP_DL}    Get CA Cell Average Throughput    ${UE_ID}     dl    scell    3
#	Log To Console    DL Troughput is ${scell_TP_DL}    console=True
#    Should Be True    ${scell_TP_DL}==0
#    ${scell_TP_UL}    Get CA Cell Average Throughput    ${UE_ID}     ul    scell    3
#	Log To Console    Ul Troughput is ${scell_TP_UL}    console=True
#    Should Be True    ${scell_TP_UL}==0
#
#Send CQI Equal 15 And Check Scell TP
#    Set CQI Testmode    profile_id=3    cqi=15
#    CUDU_L2 Send Action To GNB    ue_id=${UE_ID}     testmode=csi_override    action=activate    profile_id=3    scell=3
#    Sleep    10s    reason=Wait for scell DL data
#    ${scell_TP_DL}    Get CA Cell Average Throughput    ${UE_ID}     dl    scell    3
#    Log To Console    DL Troughput is ${scell_TP_DL}    console=True
#    Should Be True    ${scell_TP_DL}==0
#    ${scell_TP_UL}    Get CA Cell Average Throughput    ${UE_ID}     ul    scell    3
#    Log To Console    ul Troughput is ${scell_TP_UL}    console=True
#    Should Be True    ${scell_TP_UL}==0
#
#Check Scell Status
#    [Arguments]    ${scell_index}=1    ${scell_active_status}=activated    ${egate_file}=/opt/iphy/latest/egate_console.log.001
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    ${scell_activation}    Set Variable    SCellIndex ${scell_index} ${scell_active_status} successfully.
#    ${content}    OperatingSystem.Get File    path=${egate_file}
#    ${match_list}    Get Regexp Matches    ${content}    ${scell_activation}
#    ${check_rst}    Get Length    ${match_list}
#    ${scell_status}    Set Variable If    ${check_rst}>=1    pass    failed
#    [Return]    ${scell_status}
