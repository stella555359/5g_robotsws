*** Settings ***
Test Teardown     Common Test Teardown
Suite Teardown    Common Suite Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G
...               SBTS00    VRF_HAZ4_T11    CB011080    owner_peafu
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          resources/CB011080_resource.robot

*** Variables ***
${SCF_PATH}         ${CURDIR}/Config/
${SCFC_FILE}        SCF_IWK_12149.xml
${LOCAL_WTS_DIR}    ${CURDIR}/Config/wts
${WTS_DIR}          /opt/iphy/latest
${IPHY_XML}         ${CURDIR}/Config/wts/iphy_CB011080.xml
${WTS_CFG}          basic_CB011080_12149.lua
${UE_ID_1}          1
${UE_ID_2}          2
${SCELL1_PCI}       51
${SCELL2_PCI}       52
${SCELL3_PCI}       53
${SCELL4_PCI}       55
${SCELL5_PCI}       56
${EGATE_FILE}       /opt/iphy/latest/egate_console.log

*** Test Cases ***
CB011080_ET_C901_Verify_6CC_IWK_R16_UL_Tx_Switch_Option1
    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}
    ...    AND    Configure IP For UEC2    
    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...    AND    Suite Setup Start WTS And Check OnAir With Egate Log
    ...    AND    Common Test Setup
    SA 5G CA Attach    ${UE_ID_1}    pdu_id=1
    SA 5G CA Attach    ${UE_ID_2}    pdu_id=1
    Send A1 Report    ${UE_ID_1}    srsrp_nr=120    phycell_id=54    meas_id=1    
    Send A1 Report    ${UE_ID_2}    srsrp_nr=120    phycell_id=54    meas_id=1    
    Start DLUL Traffic    ${UE_ID_1}    dl_trf=1500    ul_trf=100
    Start DLUL Traffic    ${UE_ID_2}    dl_trf=1500    ul_trf=100
    Check Scell Addition By OneShot
    Check 6CC Tput    1    
    Check TTitrace Layers    

*** Keywords ***
Check Scell Addition By OneShot
    Check SA Scell PhysicalID With UE ID    ue_id=${UE_ID_1}    scell_physicalid=${SCELL1_PCI}    scell_index=1
    Check SA Scell PhysicalID With UE ID    ue_id=${UE_ID_1}    scell_physicalid=${SCELL2_PCI}    scell_index=2
    Check SA Scell PhysicalID With UE ID    ue_id=${UE_ID_1}    scell_physicalid=${SCELL3_PCI}    scell_index=3
    Check SA Scell PhysicalID With UE ID    ue_id=${UE_ID_1}    scell_physicalid=${SCELL4_PCI}    scell_index=4
    Check SA Scell PhysicalID With UE ID    ue_id=${UE_ID_1}    scell_physicalid=${SCELL5_PCI}    scell_index=5
    Check SA Scell PhysicalID With UE ID    ue_id=${UE_ID_2}    scell_physicalid=${SCELL1_PCI}    scell_index=1
    Check SA Scell PhysicalID With UE ID    ue_id=${UE_ID_2}    scell_physicalid=${SCELL2_PCI}    scell_index=2
    Check SA Scell PhysicalID With UE ID    ue_id=${UE_ID_2}    scell_physicalid=${SCELL3_PCI}    scell_index=3
    Check SA Scell PhysicalID With UE ID    ue_id=${UE_ID_2}    scell_physicalid=${SCELL4_PCI}    scell_index=4
    Check SA Scell PhysicalID With UE ID    ue_id=${UE_ID_2}    scell_physicalid=${SCELL5_PCI}    scell_index=5

Start DLUL Traffic
    [Arguments]    ${ue}    ${dl_trf}    ${ul_trf}
    Start SA UE Big DL Traffic Internal    ${ue}    ${dl_trf}
    Start SA UE Big UL Traffic Internal    ${ue}    ${ul_trf}

Capture Logs And Check TTitrace
    [Arguments]    ${log_idx}
    CUDU L2 Capture And Decode TTitrace    log_id=${log_idx}    duration=0.2
    CUDU L2 Check DTXNACK Rate    log_id=${log_idx}
    CUDU L2 Check UL DTXCRC Rate    log_id=${log_idx}

Check 6CC Tput
    [Arguments]    ${log_id}
    Sleep    10s    reason=wait for traffic stable
    Capture Logs And Check TTitrace    ${log_id}
    Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    120
    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    1    30
    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    2    150
    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    3    100
    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    4    170
    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    5    170
    Check CA UE Pcell Scell Cell TPut On Target    1    ul    pcell    0    25
    Check CA UE Pcell Scell Cell TPut On Target    1    ul    scell    1    8
    Check CA UE Pcell Scell Cell TPut On Target    2    dl    pcell    0    120
    Check CA UE Pcell Scell Cell TPut On Target    2    dl    scell    1    30
    Check CA UE Pcell Scell Cell TPut On Target    2    dl    scell    2    150
    Check CA UE Pcell Scell Cell TPut On Target    2    dl    scell    3    100
    Check CA UE Pcell Scell Cell TPut On Target    2    dl    scell    4    170
    Check CA UE Pcell Scell Cell TPut On Target    2    dl    scell    5    150
    Check CA UE Pcell Scell Cell TPut On Target    2    ul    pcell    0    25
    Check CA UE Pcell Scell Cell TPut On Target    2    ul    scell    1    8

Check TTitrace Layers
    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis
    ...    ${CURDIR}${/}A2A/CB011080_UL_Tx_Switch.ini
    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace/1
