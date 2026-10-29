*** Settings ***
Documentation    ...
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    VRF4_SG11    CB011080    owner_w13li
#Resource          resources/CB011080_resource.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCFC_FILE}                A501_SCF.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
#${WTS_DIR}                  /opt/iphy/latest
#${IPHY_XML}                 ${CURDIR}/Config/wts/iphy_CB011080_A501.xml
#${WTS_CFG}                  basic_CB011080_A501.lua
#${SWCONFIG_PARAM}           0x890071=1;0x5C0009=2
#
#
#${UE_2}                     2
#${UE_8}                     8
#
#${MCC}                      311
#${MNC}                      489
#${AMF1_REGION}              1:2:2
#${AMF2_REGION}              2:3:3
#
#${PDU_ID}                   1
#
#${6CC_NUM}                  6
#@{6CC_DL_TPUT_LIST}         320    274    63    274    200    393
#@{2CC_UL_TPUT_LIST}         20    66
#@{6CC_SCELL_PCI_2T4F}       50    51    52    53    56
#
#${PUCCH_A2A_INI}         501_UCI_bit_Pucch.ini
#${PUSCH_A2A_INI}         501_UCI_bit_Pusch.ini
#
#
#*** Test Cases ***
#CB011080_ET_A501_Verify_A2_Scell_Release_For_6CCs_CA_UE
#    [Setup]    Run Keywords      Suite Setup Update GNB    swconfig_param=${SWCONFIG_PARAM}    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}
#    ...        AND    Configure IP For UEC2
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...        AND    Common Test Setup
#    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
#
#	One Ue Attach And Check UCI
#	Two Ue Attach And Check Tput
#	Trigger A2 Release     ${UE_2}    scell_id=1    scell_rsrp=36    phycell_id=55    meas_id=2
#	Trigger A2 Release     ${UE_2}    scell_id=2    scell_rsrp=36    phycell_id=55    meas_id=3
#	Trigger A2 Release     ${UE_2}    scell_id=3    scell_rsrp=36    phycell_id=55    meas_id=4
#	Trigger A2 Release     ${UE_2}    scell_id=4    scell_rsrp=36    phycell_id=55    meas_id=5
#	Trigger A2 Release     ${UE_2}    scell_id=5    scell_rsrp=36    phycell_id=55    meas_id=6
#
#
#*** Keywords ***
#
#One Ue Attach And Check UCI
#    UE Attach And A1 Addition    ${UE_2}    ${AMF1_REGION}
#    Check SA All Scell PhysicalID With UE ID    ${UE_2}    ${6CC_SCELL_PCI_2T4F}    ${6CC_NUM}
#    Start SA UE Big DL Traffic Internal    ${UE_2}    2000
#    Capture TTItrace And Check UCI And Acknack    log_id=1    ini_file=${PUCCH_A2A_INI}
#    Start SA UE Big UL Traffic Internal    ${UE_2}    300
#    Capture And Check TTitrace Logs    2
#    Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/2
#    Check UCI Bit And Acknack Bit For Pusch    BIP/2    ${PUSCH_A2A_INI}
#	#SA 5G Detach    ${UE_2}
#	#Sleep    1s    reason=wait for detach effect
#
#Two Ue Attach And Check Tput
#    #UE Attach And A1 Addition    ${UE_2}    ${AMF1_REGION}
#    #Start SA UE Big DL Traffic Internal    ${UE_2}    1800
#    UE Attach And A1 Addition    ${UE_8}    ${AMF2_REGION}
#    Start SA UE Big DL Traffic Internal    ${UE_8}    1800
#    Wait Until Keyword Succeeds    600s    10s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_2}
#    ...    ${6CC_DL_TPUT_LIST}    ${6CC_NUM}
#    Wait Until Keyword Succeeds    600s    10s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_8}
#    ...    ${6CC_DL_TPUT_LIST}    ${6CC_NUM}
#
#    #Start SA UE Big UL Traffic Internal    ${UE_2}    300
#    #Wait Until Keyword Succeeds    30s    5s    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_2}    ${2CC_UL_TPUT_LIST}    2
#    Start SA UE Big UL Traffic Internal    ${UE_8}    300
#    Wait Until Keyword Succeeds    30s    5s    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_8}    ${2CC_UL_TPUT_LIST}    2
#
#UE Attach And A1 Addition
#    [Arguments]    ${ue_id}    ${amf_region}=1:2:2
#    Single Ue Attach    ${ue_id}    ${amf_region}
#    Trigger A1 RsrpCombain Scell Addition    ${ue_id}    100    70    55    meas_id=1
#    Sleep    1s    reason=wait it take effect
#
#Trigger A2 Release
#    [Arguments]    ${ue_id}    ${scell_id}=1    ${scell_rsrp}=36    ${phycell_id}=51    ${meas_id}=${EMPTY}
#    [Documentation]    This keyword is to trigger A2 scell release
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | yes | the id of ue |
#    ...    | scell_id | yes | the id of scell |
#    ...    | scell_rsrp | yes | the value of scell_rsrp |
#    ...    | phycell_id | yes | phycell id for scell |
#    ...
#    ...    Examples:
#    ...    | Trigger A2 Scell Release | 1 | 1 | 1 | 51 |
#    ...
#    ${cmd}    Catenate    SEPARATOR=${SPACE}    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2
#    ...    scell=${scell_id} scell_rsrp=${scell_rsrp} phycell_id=${phycell_id}
#    ${ret1}=    ute_wtssim.Execute Egate Command    cmd=${cmd}    pass_regexp=rrc(Connection)?ReconfigurationComplete
#    ...    timeout=3minutes
#
#Configure IP For UEC2
#    OperatingSystem.Run    sudo ip addr add 10.0.2.3/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.61/24 dev eth3
#
#
#Trigger A1 RsrpCombain Scell Addition
#	  [Arguments]    ${ue_id}    ${srsrp_nr}    ${srsrq_nr}    ${phycell_id}    ${meas_id}=${EMPTY}
#    [Documentation]    This keyword is to trigger A1 scell added.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | the id of ue |
#    ...    | srsrp_nr | Yes | the value of srsrp_nr |
#    ...    | phycell_id | Yes | phycell id of the cell |
#    ...
#    ...    Examples:
#    ...    | Trigger A1 Scell Addition | 1 | 70 | 50 |
#    ...
#    ${meas_id_from_egate}    _Get Measurement Id From Egate Log    A1    ${ue_id}
#    ${measida1}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${measida1} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} phycell_id=${phycell_id}
#    ...    pass_regexp=rrc(Connection)?ReconfigurationComplete
#
#Check UCI Bit With A2A For Pucch
#    [Arguments]    ${log_id}    ${ini_file}
#    A2A Check CSV Table    ${CURDIR}/A2A/${ini_file}    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
#    ...    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#
#Capture TTItrace And Check UCI And Acknack
#    [Arguments]    ${log_id}    ${ini_file}
#    CUDU L2 Capture And Decode TTitrace    log_id=${log_id}    duration=2
#    Check UCI Bit With A2A For Pucch    log_id=${log_id}    ini_file=${ini_file}
#    CUDU L2 Check DTXNACK Rate    log_id=${log_id}
#    CUDU L2 Check UL DTXCRC Rate    log_id=${log_id}
#
#Check UCI Bit And Acknack Bit For Pusch
#    [Arguments]    ${log_id}    ${ini_file}
#    Convert BIP To CSV By MCShark For Uldata Puschreveivereq    ${log_id}
#    Run    sed -i 's/"//g' ${TEST_LOG_DIRECTORY}/${log_id}/UlData_puschReceiveReqGrant.csv
#    A2A Check CSV Table    ${CURDIR}/A2A/${ini_file}    ${TEST_LOG_DIRECTORY}/${log_id}/UlData_puschReceiveReqGrant.csv
#    ...    ${TEST_LOG_DIRECTORY}/${log_id}
#
#Convert BIP To CSV By MCShark For Uldata Puschreveivereq
#    [Arguments]    ${log_id}
#    ${filter}=    Set Variable    uldata_puschreceivereq
#    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_puschReceiveReqGrant_t.numOfUciAckBits
#    ...    UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits
#    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/${log_id}    5GBipL2L1_filtering_off.pcap    ${True}
#    Convert BIP To CSV By MCShark    @{bip_names}    ${TEST_LOG_DIRECTORY}/${log_id}/UlData_puschReceiveReqGrant.csv    ${filter}
#    ...    ${csv_title_list}
#    OperatingSystem.Run
#    ...    cp ${TEST_LOG_DIRECTORY}/${log_id}/UlData_puschReceiveReqGrant.csv ${TEST_LOG_DIRECTORY}/${log_id}/UlData_puschReceiveReqGrant_bk.csv
