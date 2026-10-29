*** Settings ***
Documentation    ...
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    VRF4_SG11    CB011080    owner_suxu
#Resource          resources/CB011080_resource.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCFC_FILE}                Full_SCF_CB011080_A1202.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
#${WTS_DIR}                  /opt/iphy/latest
#${IPHY_XML}                 ${CURDIR}/Config/wts/iphy_CB011080.xml
#${WTS_CFG}                  basic_CB011080_A1202.lua
#${UE_2}                     2
#${AMF1_REGION}              1:2:2
#${AMF2_REGION}              2:3:3
#${6CC}                      6
#@{6CC_DL_TPUT_LIST}         345    330    40    235    160    430
#@{2CC_UL_TPUT_LIST}         50    115
#@{6CC_SCELL_PCI_2T4F}       50    51    52    53    56
#${GBR_TPUT_DL}              100
#${GBR_TPUT_UL}              10
#
#*** Test Cases ***
#CB011080_ET_A1202_Verify_6CC_IWK_With_DRX_VONR
#    [Documentation]    NRRELs for cell 6 is: cell 1/2/3/4/6 to setup 2T4F CA.
#    ...    Fdd cell 1:40MHz, Fdd cell 2:10MHz, Fdd cell 3:40MHz, Fdd cell 4:30MHz
#    ...    Tdd cell 5:40MHz, Tdd cell 6:60MHz, Tdd cell 7:80MHz
#    ...    UE2 Tdd cell 6+Fdd cell 1+Fdd cell 2+Fdd cell 3+Fdd cell 4+Tdd cell 7
#    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}
#    ...        AND    Configure IP For UEC2
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...        AND    Common Test Setup
#    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
#    Single Ue Attach    ${UE_2}    ${AMF1_REGION}
#    Trigger A1 Scell Addition    ue_id=${UE_2}    srsrp_nr=100    phycell_id=55
#    Check SA All Scell PhysicalID With UE ID    ${UE_2}    ${6CC_SCELL_PCI_2T4F}    ${6CC}
#    Add VONR Bearer And start VONR DL and UL Traffic
#    Check RRC Reconfig For VoNRDrx Profile2
#    Start nonGBR Traffic And Check Tput    ${UE_2}    1600    200
#    SA UE Check Throughput    ${UE_2}    dl_tp_threshold=50    ul_tp_threshold=1    qfi=3
#    Run Keyword And Ignore Error    Capture And Check TTitrace Logs    1    0.5
#
#*** Keywords ***
#Add VONR Bearer And start VONR DL and UL Traffic
#    Trigger 5QI Setup    ue_id=${UE_2}    qfi=2    qosflows_id_5qi=5
#    Trigger 5QI Setup    ue_id=${UE_2}    qfi=3    qosflows_id_5qi=1
#    Start SA VONR GBR DL And UL Traffic    ueId=${UE_2}    qfi_id=3    dl_trf=${GBR_TPUT_DL}    ul_trf=${GBR_TPUT_UL}
#    Wait Until Keyword Succeeds    30s    5s    SA UE Check Throughput    ${UE_2}    dl_tp_threshold=50    ul_tp_threshold=0.1    qfi=3
#
#Check RRC Reconfig For VoNRDrx Profile2
#    Save Egate Log
#    OperatingSystem.Run    mv ${SUITE_LOG_DIRECTORY}/egate_console.log ${SUITE_LOG_DIRECTORY}/egate_console-DrxProfile2.log
#    ${egate_console_file}=    Set Variable    ${SUITE_LOG_DIRECTORY}/egate_console-DrxProfile2.log
#    ${DrxCfgRelease}=    Grep File    ${egate_console_file}    drx-Config release
#    ${output}    String.Get Lines Matching Regexp    ${DrxCfgRelease}    drx-Config release    partial_match=${true}
#    Log To Console    ${output}
#    ${DrxCfgSetup}=    Grep File    ${egate_console_file}    drx-Config setup
#	Log To Console    ${DrxCfgSetup}
#    Should Contain    ${DrxCfgSetup}    drx-Config setup
#    ${DrxProfile2}=    Grep File    ${egate_console_file}    drx-InactivityTimer ms4,
#    Log To Console    ${DrxProfile2}
#    Should Contain    ${DrxProfile2}    drx-InactivityTimer ms4,
#
#Start nonGBR Traffic And Check Tput
#    [Arguments]    ${ue}    ${dl_trf}    ${ul_trf}
#    ${uestats_dltput}    Set Variable    0
#    ${uestats_ultput}    Set Variable    0
#    Start SA UE Big UL Traffic Internal    ${ue}    ${ul_trf}
#    Start SA UE Big DL Traffic Internal    ${ue}    ${dl_trf}
#	Sleep    25s    reason=wait for traffic stable
#
#    ${uedltput}=    Check UE DL All Pcell Scell TPut Uestats    ${ue}    ${6CC_DL_TPUT_LIST}    ${6CC}
#    ${ueultput}=    Check UE 2CCUL Pcell Scell TPut Uestats    ${ue}    ${2CC_UL_TPUT_LIST}    ${6CC}
#    ${uestats_dltput}    Evaluate    ${uestats_dltput}+${uedltput}
#    ${uestats_ultput}    Evaluate    ${uestats_ultput}+${ueultput}
#    Log To Console    all UE's uestats_ dl tput=${uestats_dltput} Mbps
#    Log To Console    all UE's uestats_ ul tput=${uestats_ultput} Mbps
#
#Start SA VONR GBR DL And UL Traffic
#    [Arguments]    ${ueId}    ${qfi_id}    ${dl_trf}    ${ul_trf}
#    Log To Console    Start VONR DL UDP Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=${qfi_id} trf_id=1 mbps\=${dl_trf} dir=dl protocol=udp
#    Log To Console    Start VONR UL UDP Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=${qfi_id} trf_id=1 mbps\=${ul_trf} dir=ul protocol=udp
#    Sleep    15s    reason=wait DL/UL traffic is stable
