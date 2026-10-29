*** Settings ***
Documentation      CB011080_ET_A801
Test Teardown     Common Test Teardown    check_tl=False
Suite Teardown    Common Suite Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
...               SBTS00    VRF4_SG11    CB012528    owner_qiaren
Resource          resources/CB011080_resource.robot

*** Variables ***
${SCF_PATH}                 ${CURDIR}/Config/
${SCFC_FILE}                CB011080_A801_Full_SCF.xml
${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
${WTS_DIR}                  /opt/iphy/latest
${IPHY_XML}                 ${CURDIR}/Config/wts/iphy_CB011080_A801.xml
${WTS_CFG}                  CB011080_A801.lua
${SWCONFIG_PARAM_GNB}       0x890071=1;

${UE_1}                     1
${UE_3}                     3

${MCC}                      311
${MNC}                      489
${AMF1_REGION}              1:2:2
${AMF2_REGION}              2:3:3


${6CC_NUM}                  6
@{6CC_DL_TPUT}         80    30    80    80    80    80
@{2CC_UL_TPUT_LIST}         11    30
@{6CC_SCELL_PCI_3T3F}       51    52    53    54    55



*** Test Cases ***
CB011080_ET_A801_Buffer_Based_Activation_3T3F_Peak_UCIs_Maximum_Throughput
    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}    #swconfig_param=${SWCONFIG_PARAM_GNB}
    #[Setup]    Run Keywords      Suite Setup Update GNB    force_reboot=True
    ...        AND    Configure IP For UEC2
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
    ...        AND    Common Test Setup
    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true

    Single Ue Attach    ${UE_1}    ${AMF1_REGION}
    Check SA All Scell PhysicalID With UE ID    ${UE_1}    ${6CC_SCELL_PCI_3T3F}    ${6CC_NUM}
    Single Ue Attach    ${UE_3}    ${AMF2_REGION}
    Check SA All Scell PhysicalID With UE ID    ${UE_3}    ${6CC_SCELL_PCI_3T3F}    ${6CC_NUM}
    Start SA UE Big DL Traffic Internal    ${UE_1}    1400
    Start SA UE Big DL Traffic Internal   ${UE_3}    1400
    Sleep    30s    reason=wait 30s for traffic statble
    Wait Until Keyword Succeeds    30s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_1}    ${6CC_DL_TPUT}    ${6CC_NUM}
    Wait Until Keyword Succeeds    30s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_3}    ${6CC_DL_TPUT}    ${6CC_NUM}
    ${status}    Run Keyword And Return Status    Capture TTItrace And Check UCI And Acknack    log_id=1
    Run Keyword If    "${status}"=="${False}"      Capture TTItrace And Check UCI And Acknack    log_id=2
    Start SA UE Big UL Traffic Internal    ${UE_1}    120
    Start SA UE Big UL Traffic Internal    ${UE_3}    120
    Sleep    30s    reason=wait 30s for traffic statble
    Wait Until Keyword Succeeds    30s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_1}    ${6CC_DL_TPUT}    ${6CC_NUM}
    Wait Until Keyword Succeeds    30s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_3}    ${6CC_DL_TPUT}    ${6CC_NUM}
    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_1}    ${2CC_UL_TPUT_LIST}    ${6CC_NUM}
    Capture And Check TTitrace Logs    1
    Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/2
    Check UCI Bit And Acknack Bit for Pusch    BIP/2


*** Keywords ***

Check UCI Bit With A2A For Pucch
    [Arguments]    ${log_id}    ${ini_file}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/${ini_file}    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

Capture TTItrace And Check UCI And Acknack
    [Arguments]    ${log_id}
    CUDU_L2 Capture And Decode TTitrace    log_id=${log_id}   duration=1
    Check UCI Bit With A2A For Pucch     log_id=${log_id}     ini_file=UCI_bit.ini
    CUDU_L2 Check DTXNACK Rate    log_id=${log_id}
    CUDU_L2 Check UL DTXCRC Rate    log_id=${log_id}

Check UCI Bit And Acknack Bit for Pusch
    [Arguments]    ${log_id}
    Convert BIP To CSV By MCShark For Uldata_puschreveivereq    BIP/2
    #Run    sed -i 's/"//g' ${TEST_LOG_DIRECTORY}/${log_id}/UlData_puschReceiveReqGrant.csv
    A2A_Check_CSV_Table    ${CURDIR}/A2A/UCI_bit_Pusch.ini    ${TEST_LOG_DIRECTORY}/${log_id}/UlData_puschReceiveReqGrant.csv
    ...    ${TEST_LOG_DIRECTORY}/${log_id}


Convert BIP To CSV By MCShark For Uldata_puschreveivereq
    [Arguments]    ${log_id}
    ${filter}=    Set Variable    uldata_puschreceivereq
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_puschReceiveReqGrant_t.numOfUciAckBits
    ...    UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits
    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/${log_id}    5GBipL2L1_filtering_off.pcap    ${True}
    Convert BIP To CSV By MCShark   @{bip_names}    ${TEST_LOG_DIRECTORY}/${log_id}/UlData_puschReceiveReqGrant.csv    ${filter}
    ...    ${csv_title_list}
    OperatingSystem.Run
    ...    cp ${TEST_LOG_DIRECTORY}/${log_id}/UlData_puschReceiveReqGrant.csv ${TEST_LOG_DIRECTORY}/${log_id}/UlData_puschReceiveReqGrant_bk.csv
