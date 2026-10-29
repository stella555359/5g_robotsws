*** Settings ***
Documentation    ...
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    VRF4_SG11    CB012528    owner_qiaren
#Resource          resources/CB011080_resource.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCFC_FILE}                CB011080_A801_Full_SCF.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
#${WTS_DIR}                  /opt/iphy/latest
#${IPHY_XML}                 ${CURDIR}/Config/wts/iphy_CB011080_A801.xml
#${WTS_CFG}                  CB011080_A801.lua
#${SWCONFIG_PARAM_GNB}       0x890071=1;
#
#${UE_1}                     1
#
#${MCC}                      311
#${MNC}                      489
#${AMF1_REGION}              1:2:2
#
#
#${6CC_NUM}                  6
#@{6CC_DL_TPUT}         400    120    250    380    380    390
#@{2CC_UL_TPUT_LIST}         23    62
#@{6CC_SCELL_PCI_3T3F}       51    52    53    54    55
#
#
#
#*** Test Cases ***
#CB011080_ET_A1101_Verify_IWK_3GPP_OAI
#    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}    #swconfig_param=${SWCONFIG_PARAM_GNB}
#    #[Setup]    Run Keywords      Suite Setup Update GNB    force_reboot=True
#    ...        AND    Configure IP For UEC2
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...        AND    Common Test Setup
#    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
#
#    Single Ue Attach    ${UE_1}    ${AMF1_REGION}
#    Check SA All Scell PhysicalID With UE ID    ${UE_1}    ${6CC_SCELL_PCI_3T3F}    ${6CC_NUM}
#    Start SA UE Big DL Traffic Internal    ${UE_1}    2700
#    Start SA UE Big UL Traffic Internal    ${UE_1}    200
#    Sleep    30s    reason=wait 30s for traffic statble
#    Wait Until Keyword Succeeds    30s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_1}    ${6CC_DL_TPUT}    ${6CC_NUM}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_1}    ${2CC_UL_TPUT_LIST}    ${6CC_NUM}
#    Capture And Check TTitrace Logs    1
#    Send Assistance Information And Check Scell Active Status    2    ${UE_1}     0    0    5    deactivated
#    Check All Scells Schedule Stop
#    Send Assistance Information And Check Scell Active Status    3    ${UE_1}     5    0    4    activated
#    Check Four DL Scell Resume
#    Send Assistance Information And Check Scell Active Status    3    ${UE_1}     5    1    1    activated
#    Wait Until Keyword Succeeds    30s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_1}    ${6CC_DL_TPUT}    ${6CC_NUM}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_1}    ${2CC_UL_TPUT_LIST}    ${6CC_NUM}
#    #Send Assistance Information And Check Scell Active Status    3    ${UE_1}     1    0    4    deactivated
#    #Check One DL Scell Left   //this four step is descope because of PR763156
#    #Send Assistance Information And Check Scell Active Status    3    ${UE_1}     4    1    3    activated
#    #Check Four DL Scell With One UL
#
#
#*** Keywords ***
#
#Send Assistance Information And Check Scell Active Status
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
#Check Scell Status
#    [Arguments]    ${scell_index}=1    ${scell_active_status}=activated    ${egate_file}=/opt/iphy/latest/egate_console.log.001
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    ${scell_activation}    Set Variable    SCellIndex ${scell_index} ${scell_active_status} successfully.
#    ${content}    OperatingSystem.Get File    path=${egate_file}
#    ${match_list}    Get Regexp Matches    ${content}    ${scell_activation}
#    ${check_rst}    Get Length    ${match_list}
#    ${scell_status}    Set Variable If    ${check_rst}>=1    pass    failed
#    [Return]    ${scell_status}
#
#Check Scell DL Schedule Stop
#    [Arguments]    ${ue_id}    ${scell_index}
#    ${scell_TP_DL}    Get CA Cell Average Throughput    ${ue_id}     dl    scell    ${scell_index}
#    Log To Console    DL Troughput is ${scell_TP_DL}    console=True
#    Should Be True    ${scell_TP_DL}==0
#
#Check Scell UL Schedule Stop
#    [Arguments]    ${ue_id}    ${scell_index}
#    ${scell_TP_UL}    Get CA Cell Average Throughput    ${ue_id}     ul    scell    ${scell_index}
#    Log To Console    DL Troughput is ${scell_TP_UL}    console=True
#    Should Be True    ${scell_TP_UL}==0
#
#Check All Scells Schedule Stop
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_1}    dl    pcell    0     400
#    Check Scell DL Schedule Stop    ${UE_1}    1
#	Check Scell DL Schedule Stop    ${UE_1}    2
#	Check Scell DL Schedule Stop    ${UE_1}    3
#	Check Scell DL Schedule Stop    ${UE_1}    4
#	Check Scell DL Schedule Stop    ${UE_1}    5
#	Check Scell UL Schedule Stop    ${UE_1}    2
#
#Check Four DL Scell Resume
#    Check Scell DL Schedule Stop    ${UE_1}    2
#	Check Scell UL Schedule Stop    ${UE_1}    2
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_1}    dl    pcell    0     400
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_1}    dl    scell    1     120
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_1}    dl    scell    3     380
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_1}    dl    scell    4     380
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_1}    dl    scell    5     390
#
#Check One DL Scell Left
#    Check Scell DL Schedule Stop    ${UE_1}    2
#	Check Scell DL Schedule Stop    ${UE_1}    3
#	Check Scell DL Schedule Stop    ${UE_1}    4
#	Check Scell DL Schedule Stop    ${UE_1}    5
#	Check Scell UL Schedule Stop    ${UE_1}    2
#	Check CA UE Pcell Scell Cell TPut On Target    ${UE_1}    dl    scell    1     120
#
#Check Four DL Scell With One UL
#    Check Scell DL Schedule Stop    ${UE_1}    1
#	Check CA UE Pcell Scell Cell TPut On Target    ${UE_1}    ul    scell    2     62
#	Check CA UE Pcell Scell Cell TPut On Target    ${UE_1}    dl    scell    2     250
#	Check CA UE Pcell Scell Cell TPut On Target    ${UE_1}    dl    scell    3     380
#	Check CA UE Pcell Scell Cell TPut On Target    ${UE_1}    dl    scell    4     380
#	Check CA UE Pcell Scell Cell TPut On Target    ${UE_1}    dl    scell    5     390
