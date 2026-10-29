*** Settings ***
Documentation    ...
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    VRF4_SG11    CB01080   owner_qiaren
#Resource          resources/CB011080_resource.robot
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCFC_FILE}                CB011080_C401_Full_SCF.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
#${WTS_DIR}                  /opt/iphy/latest
#${IPHY_XML}               ${CURDIR}/Config/wts/iphy_CB011080_A801.xml
#${WTS_CFG}                  CB011080_C401.lua
#${SWCONFIG_PARAM_GNB}       0x890071=1;
#
#${UE_1}                    1
#${MCC}                      311
#${MNC}                      489
#${AMF1_REGION}              1:2:2
#${6CC_NUM}                  6
#@{6CC_DL_TPUT}         400    120    250    380    380    390
#@{2CC_UL_TPUT_LIST}         25    45
#@{6CC_SCELL_PCI_3T3F}       51    52    53    55    56
#
#*** Test Cases ***
#
#CB011080_ET_C401_Verify_6CC_IWK_UL_SRS_Based_Beamforming
#    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}    #swconfig_param=${SWCONFIG_PARAM_GNB}
#    #[Setup]    Run Keywords      Suite Setup Update GNB    force_reboot=True
#    ...        AND    Configure IP For UEC2
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...        AND    Common Test Setup
#	Set SRS Testmode    profile_id=3    init_pos=0
#	CUDU L2 Send Action To GNB    ue_id=${UE_1}   testmode=ue_srs_beam_pos    action=activate    profile_id=3
#    Single Ue Attach    ${UE_1}    ${AMF1_REGION}
#	Check SA All Scell PhysicalID With UE ID    ${UE_1}    ${6CC_SCELL_PCI_3T3F}    ${6CC_NUM}
#    Start SA UE Big DL Traffic Internal    ${UE_1}    2300
#    Start SA UE Big UL Traffic Internal    ${UE_1}    150
#	Wait Until Keyword Succeeds    30s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_1}    ${6CC_DL_TPUT}    ${6CC_NUM}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_1}    ${2CC_UL_TPUT_LIST}    ${6CC_NUM}
#	Capture And Check TTitrace Logs    1
#	Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/1
#    Check Srsreceivereq With A2A    BIP/1    srsreceivereq_C401.ini
#    Check PatternID From Wirshark    /BIP/1    54    uldata_puschreceivereq    UlData_eCpriConfigStruct_t.patternId_item    1789,1708,0,0
#
#
#
#*** Keywords ***
#Check Srsreceivereq With A2A
#    [Arguments]    ${log_id}    ${ini_file}
#    Convert BIP To CSV By MCShark For UlData_SrsReceiveReq With Slots    ${log_id}
#    Run    sed -i 's/"//g' ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/${ini_file}    ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv
#    ...    ${TEST_LOG_DIRECTORY}/${log_id}
#
#Convert BIP To CSV By MCShark For UlData_SrsReceiveReq With Slots
#    [Arguments]    ${log_id}
#    ${filter}=    Set Variable    uldata_srsreceivereq
#    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_srsBmResource_t.srsResourceIdentity
#    Convert BIP To CSV By MCShark   ${TEST_LOG_DIRECTORY}/${log_id}/5GBipL2L1_filtering_off.pcap
#    ...    ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv    ${filter}    ${csv_title_list}
#    OperatingSystem.Run
#    ...    cp ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq_bk.csv
#
#Check PatternID From Wirshark
#    [Arguments]    ${log_id}    ${phycell_id}    ${msg_name}    ${field_name}    ${PatternID}=101,106
#    Convert BIP To CSV By MCShark For PatternId    ${log_id}    ${phycell_id}    ${msg_name}    ${field_name}
#    Check PatternID In Csv File    ${log_id}    ${msg_name}    ${field_name}    ${PatternID}
#
#Convert BIP To CSV By MCShark For PatternId
#    [Arguments]    ${log_id}    ${phycell_id}    ${msg_name}    ${field_name}
#	${filter}=    Set Variable    (${msg_name}) && (3gpp.dmrsScramblingSequenceInt == ${phycell_id})
#    @{csv_title_list}=    Create List    ${field_name}
#    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/${log_id}    5GBipL2L1_filtering_off.pcap    ${True}
#    Convert BIP To CSV By MCShark   @{bip_names}    ${TEST_LOG_DIRECTORY}/${log_id}/PatternId_${msg_name}.csv    ${filter}
#    ...    ${csv_title_list}
#
#Check PatternID In Csv File
#    [Arguments]    ${log_id}    ${msg_name}    ${field_name}    ${PatternID}
#    ${data_list_1}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${TEST_LOG_DIRECTORY}/${log_id}/PatternId_${msg_name}.csv     ${field_name}    ["${PatternID}"]
#    ...    include    no
#    ${count1}    Get Length    ${data_list_1}
#    Should Be True    ${count1}!=0
