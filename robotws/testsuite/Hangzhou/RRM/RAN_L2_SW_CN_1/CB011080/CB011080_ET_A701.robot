*** Settings ***
Documentation    ...
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    VRF_HAZ4_T11    CB011080    owner_peafu
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          resources/CB011080_resource.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/Config/
#${SCFC_FILE}        SCF_IWK_8311.xml
#${LOCAL_WTS_DIR}    ${CURDIR}/Config/wts
#${WTS_DIR}          /opt/iphy/latest
#${IPHY_XML}         ${CURDIR}/Config/wts/iphy_CB011080.xml
#${WTS_CFG}          basic_CB011080.lua
#${UE_ID}            1
#${SCELL1_PCI}       51
#${SCELL2_PCI}       52
#${SCELL3_PCI}       53
#${SCELL4_PCI}       54
#${SCELL5_PCI}       55
#${EGATE_FILE}       /opt/iphy/latest/egate_console.log
#
#*** Test Cases ***
#CB011080_ET_A701_IWK_CB008311_Data_Activity_Based_Scell_Addition_And_Bad_RLQ_Release
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}
#    ...    AND    Configure IP For UEC2
#    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...    AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ${UE_ID}    pdu_id=1
#	DL BLER And CQI Profile Setting
#	Scell 1 Good RLQ
#    Send A1 Report    ${UE_ID}    srsrp_nr=120    phycell_id=56
#    Start DLUL Traffic    ${UE_ID}    dl_trf=2600    ul_trf=200
#    Check Scell Addition By OneShot
#    Check 6CC Tput    1
#    Scell 1 Bad RLQ
#    Check Scell 1 Deactivated And Rlease
#    Check 5CC Tput    2
#    Scell 1 Good RLQ
#    Stop Traffic
#    Send A1 Report    ${UE_ID}    srsrp_nr=120    phycell_id=56
#    Start DLUL Traffic    ${UE_ID}    dl_trf=2600    ul_trf=200
#    Check 6CC Tput    3
#
#*** Keywords ***
#Check Scell Addition By OneShot
#    Check SA Scell PhysicalID With UE ID    ue_id=${UE_ID}    scell_physicalid=${SCELL1_PCI}    scell_index=1
#    Check SA Scell PhysicalID With UE ID    ue_id=${UE_ID}    scell_physicalid=${SCELL2_PCI}    scell_index=2
#    Check SA Scell PhysicalID With UE ID    ue_id=${UE_ID}    scell_physicalid=${SCELL3_PCI}    scell_index=3
#    Check SA Scell PhysicalID With UE ID    ue_id=${UE_ID}    scell_physicalid=${SCELL4_PCI}    scell_index=4
#    Check SA Scell PhysicalID With UE ID    ue_id=${UE_ID}    scell_physicalid=${SCELL5_PCI}    scell_index=5
#
#Start DLUL Traffic
#    [Arguments]    ${ue}    ${dl_trf}    ${ul_trf}
#    Start SA UE Big DL Traffic Internal    ${ue}    ${dl_trf}
#    Start SA UE Big UL Traffic Internal    ${ue}    ${ul_trf}
#
#Capture Logs And Check TTitrace
#    [Arguments]    ${log_idx}
#    CUDU L2 Capture And Decode TTitrace    log_id=${log_idx}    duration=2
#    CUDU L2 Check DTXNACK Rate    log_id=${log_idx}
#    CUDU L2 Check UL DTXCRC Rate    log_id=${log_idx}
#
#Check 6CC Tput
#    [Arguments]    ${log_id}
#    Sleep    10s    reason=wait for traffic stable
#    Capture Logs And Check TTitrace    ${log_id}
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    500
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    1    80
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    2    300
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    3    200
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    4    200
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    5    300
#    Check CA UE Pcell Scell Cell TPut On Target    1    ul    pcell    0    80
#    Check CA UE Pcell Scell Cell TPut On Target    1    ul    scell    2    80
#
#Check 5CC Tput
#    [Arguments]    ${log_id}
#    Sleep    10s    reason=wait for traffic stable
#    Capture Logs And Check TTitrace    ${log_id}
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    500
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    2    300
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    3    200
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    4    200
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    5    300
#    Check CA UE Pcell Scell Cell TPut On Target    1    ul    pcell    0    80
#    Check CA UE Pcell Scell Cell TPut On Target    1    ul    scell    2    80
#
#Stop Traffic
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir=dl trf_id=1-15
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir=ul trf_id=1-2
#    Sleep    20s    reason=wait for traffic stop
#
#DL BLER And CQI Profile Setting
#    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
#    Set BLER Testmode    profile_id=1    dl_bler=150,150,150,150,150,150,150,150
#    Set BLER Testmode    profile_id=2    dl_bler=0,0,0,0,0,0,0,0
#    Setting CQI Profile
#
#Setting CQI Profile
#    Log To Console    Set Value For CQI Testmode...
#    ${cmd1}    Catenate    csi_override_testmode_nr profile_id=1 cqi=3 cqi_mode=fixed
#    ...    ri=3 ri_mode=fixed
#    ${cmd2}    Catenate    csi_override_testmode_nr profile_id=2 cqi=15 cqi_mode=fixed
#    ...    ri=3 ri_mode=fixed
#    ute_wtssim.Execute Egate Command    ${cmd1}
#    ute_wtssim.Execute Egate Command    ${cmd2}
#
#Scell 1 Bad RLQ
#    CUDU L2 Send Action To GNB    ue_id=1    testmode=csi_override    action=activate    profile_id=1    scell=1
#    CUDU L2 Send Action To GNB    ue_id=1    testmode=bler    action=activate    profile_id=1    scell=1
#
#Scell 1 Good RLQ
#    CUDU L2 Send Action To GNB    ue_id=1    testmode=csi_override    action=activate    profile_id=2    scell=1
#    CUDU L2 Send Action To GNB    ue_id=1    testmode=bler    action=activate    profile_id=2    scell=1
#
#Check Scell 1 Deactivated And Rlease
#    [Arguments]    ${ue_id}=1    ${pdu_id}=1
#    ${pattern1}    Set Variable    SCellIndex 1 deactivated successfully
#    ${pattern2}    Set Variable    sCellToReleaseList
#    Sleep    30s    reason=wait for scell release
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    ${content}    OperatingSystem.Get File    path=${EGATE_FILE}
#    ${match_times1}    Get Count    ${content}    ${pattern1}
#    ${match_times2}    Get Count    ${content}    ${pattern2}
#    Should Be True    ${match_times1}==1
#    Should Be True    ${match_times2}==1
