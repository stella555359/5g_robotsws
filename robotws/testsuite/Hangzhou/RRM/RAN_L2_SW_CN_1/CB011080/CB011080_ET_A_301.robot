*** Settings ***
Documentation    ...
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    VRF4_SG11    CB011080    owner_w13li
#Resource          resources/CB011080_resource.robot
#
#*** Variables ***
#${SCF_PATH}              ${CURDIR}/Config/
#${SCFC_FILE}             A301_SCF.xml
#${LOCAL_WTS_DIR}         ${CURDIR}/Config/wts/
#${WTS_DIR}               /opt/iphy/latest
#${IPHY_XML}              ${CURDIR}/Config/wts/iphy_CB011080_A301.xml
#${WTS_CFG}               basic_CB011080_A301.lua
#${SWCONFIG_PARAM}        0x890071=1
#${UE_1}                  1
#${MCC}                   311
#${MNC}                   489
#${AMF1_REGION}           1:2:2
#${AMF2_REGION}           2:3:3
#${PDU_ID}                1
#${6CC_NUM}               6
#@{6CC_DL_TPUT_LIST}      370    110    240    360    370    310
#@{2CC_UL_TPUT_LIST}      25    60
#@{6CC_SCELL_PCI_3T3F}    51    52    53    54    55
#${PUCCH_A2A_INI}         301_UCI_bit_Pucch.ini
#${PUSCH_A2A_INI}         301_UCI_bit_Pusch.ini
#
#*** Test Cases ***
#CB011080_ET_A301_Verify_Blind_Scell_Addition_With_HarqAn_Bit_Larger_Than_20
#    [Setup]    Run Keywords    Suite Setup Update GNB    swconfig_param=${SWCONFIG_PARAM}    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}
#    #[Setup]    Run Keywords    Suite Setup Update GNB    force_reboot=True
#    ...    AND    Configure IP For UEC2
#    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...    AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...    AND    Common Test Setup
#    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
#    Single Ue Attach    ${UE_1}    ${AMF1_REGION}
#    Check SA All Scell PhysicalID With UE ID    ${UE_1}    ${6CC_SCELL_PCI_3T3F}    ${6CC_NUM}
#    Start SA UE Big DL Traffic Internal    ${UE_1}    2000
#    Wait Until Keyword Succeeds    600s    10s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_1}
#    ...    ${6CC_DL_TPUT_LIST}    ${6CC_NUM}
#    Capture TTItrace And Check UCI And Acknack    log_id=1    ini_file=${PUCCH_A2A_INI}
#    Start SA UE Big UL Traffic Internal    ${UE_1}    300
#    Wait Until Keyword Succeeds    30s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_1}
#    ...    ${6CC_DL_TPUT_LIST}    ${6CC_NUM}
#    Wait Until Keyword Succeeds    30s    5s    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_1}    ${2CC_UL_TPUT_LIST}    2
#    Capture And Check TTitrace Logs    2
#    Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/2
#    Check UCI Bit And Acknack Bit For Pusch    BIP/2    ${PUSCH_A2A_INI}
#
#*** Keywords ***
#Configure IP For UEC2
#    OperatingSystem.Run    sudo ip addr add 10.0.2.3/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.61/24 dev eth3
#
#Single Ue Attach
#    [Arguments]    ${ue_id}    ${amf_region}=1:2:2
#    Log To Console    UE${ue_id} Start Attach...
#    SA 5G Attach    ue_id=${ue_id}
#    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${PDU_ID}
#    ute_wtssim.Execute Egate Command    cmd=ue_nr_rrc_setup_param id\=${ue_id} registered_amf\=${MCC}:${MNC}|${amf_region}
#    Sleep    0.5s    reason=wait it take effect
#    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1
#    ...    pass_regexp=setup/reestablishment complete    timeout=3minutes
#    Sleep    0.5s    reason=wait egate console log print
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
#
#Check All Ue Tput
#    [Arguments]    ${ue_id}
#    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=${ue_id} type=pusch scell=primary,secondary    pass_regexp=CellIndex
#    Sleep    1s    reason=wait egate console log print
#    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=${ue_id} type=pdsch scell=primary,secondary    pass_regexp=CellIndex
