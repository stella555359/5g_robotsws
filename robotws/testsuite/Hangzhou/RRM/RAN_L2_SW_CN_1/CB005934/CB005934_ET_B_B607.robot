*** Settings ***
Documentation    ...
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./../CB008015/resources/CB008015_lib.robot
#
#*** Variables ***
#${SCF_PATH}              ${CURDIR}/Config/
#${SCFC_FILE}             CB005934_LOO_B607.xml
#${LOCAL_WTS_DIR}         ${CURDIR}/Config/wts/
#${WTS_DIR}               /opt/iphy/latest
#${IPHYFILE}              ${CURDIR}/Config/wts/iphy_4F_n25A_n66A_n71B_2T.xml
#${SWCONFIG_PARAM_GNB}    0x89003B=1
#${WTS_CFG}               5934_4F_n25A_n66A_n71B_2T_UL.cfg
#${WTS_AP_XML}            airphone.xml
#@{LIST_UE_ID}            1    2    3
#${PCELL_ID}              50
#${SCELL1_PCI}            51
#${SCELL2_PCI}            52
#${SCELL3_PCI}            53
#${SCELL4_PCI}            60
#
#*** Test Cases ***
#CB005934_ET_B_B607_Scell_Change_From_ULscell_To_DLscell
#    [Tags]    CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_nilei
#    ...    SBTS00    CN1_SG06    CB005934
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHYFILE}    #swconfig_param=${SWCONFIG_PARAM_GNB}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    Attach 3 CA UE And Check Scell Addition Successful
#    Start SA DLUL Big Traffic Internal For 3UE
#    Sleep    40s    reason=wait for dl traffic stable
#    Check TP On Target FT    ${LIST_UE_ID}[0]    0    1    170    55
#    Check TP On Target FT    ${LIST_UE_ID}[1]    0    1    170    55
#    Check TP On Target FT    ${LIST_UE_ID}[2]    0    1    170    55
#    Trigger Scell Change And Check Scell Addition Successful
#    Sleep    20s    reason=wait for dl traffic stable
#    Check TP On Target 4F    ${LIST_UE_ID}[0]    210    25
#    Check TP On Target 4F    ${LIST_UE_ID}[1]    210    25
#    Check TP On Target 4F    ${LIST_UE_ID}[2]    210    25
#
#*** Keywords ***
#Attach 3 CA UE And Check Scell Addition Successful
#    [Documentation]    This keyword is to attach 3 CA UE:
#    ...    UE1 Fdd cell1+Tdd cell11
#    ...    UE2 Fdd cell1+Tdd cell11
#    ...    UE3 Fdd cell1+Tdd cell11
#    SA Attach    ${LIST_UE_ID}[0]
#    Trigger A1 Scell Addition    ${LIST_UE_ID}[0]    80    ${PCELL_ID}
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID}[0]    ${SCELL4_PCI}    1
#    SA Attach    ${LIST_UE_ID}[1]
#    Trigger A1 Scell Addition    ${LIST_UE_ID}[1]    80    ${PCELL_ID}
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID}[1]    ${SCELL4_PCI}    1
#    SA Attach    ${LIST_UE_ID}[2]
#    Trigger A1 Scell Addition    ${LIST_UE_ID}[2]    80    ${PCELL_ID}
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID}[2]    ${SCELL4_PCI}    1
#
#Trigger Scell Change And Check Scell Addition Successful
#    Trigger A1 Scell Addition    ${LIST_UE_ID}[0]    120    ${PCELL_ID}    3
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID}[0]    ${SCELL1_PCI}    2
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID}[0]    ${SCELL2_PCI}    3
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID}[0]    ${SCELL3_PCI}    4
#    Trigger A1 Scell Addition    ${LIST_UE_ID}[1]    120    ${PCELL_ID}    3
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID}[1]    ${SCELL1_PCI}    2
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID}[1]    ${SCELL2_PCI}    3
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID}[1]    ${SCELL3_PCI}    4
#    Trigger A1 Scell Addition    ${LIST_UE_ID}[2]    120    ${PCELL_ID}    3
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID}[2]    ${SCELL1_PCI}    2
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID}[2]    ${SCELL2_PCI}    3
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID}[2]    ${SCELL3_PCI}    4
#
#Start SA DLUL Big Traffic Internal For 3UE
#    [Documentation]    this keyword is to start all traffic.
#    SA Start DL Traffic Internal    ue_id=${LIST_UE_ID}[0]    pdu_id=1    mbps=300    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${LIST_UE_ID}[1]    pdu_id=1    mbps=300    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${LIST_UE_ID}[2]    pdu_id=1    mbps=300    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${LIST_UE_ID}[0]    pdu_id=1    mbps=100    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${LIST_UE_ID}[1]    pdu_id=1    mbps=100    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${LIST_UE_ID}[2]    pdu_id=1    mbps=100    trf_id=1
#
#Check TP On Target 4F
#    [Arguments]    ${ueId}    ${target_dlsum_tp}    ${target_ulsum_tp}
#    ${pcell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    0
#    ${scell_dlTP1}    Get CA Cell Average Throughput    ${ueId}    dl    scell    2
#    ${scell_dlTP2}    Get CA Cell Average Throughput    ${ueId}    dl    scell    3
#    ${scell_dlTP3}    Get CA Cell Average Throughput    ${ueId}    dl    scell    4
#    ${dlsum_tp}    Evaluate    ${pcell_dlTP}+${scell_dlTP1}+${scell_dlTP2}+${scell_dlTP3}
#    Log To Console    DL Troughput is ${dlsum_tp}    console=True
#    Should Be True    ${dlsum_tp}>=${target_dlsum_tp}
#    ${pcell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    0
#    Log To Console    UL Troughput is ${pcell_ulTP}    console=True
#    Should Be True    ${pcell_ulTP}>=${target_ulsum_tp}
#
#Check TP On Target FT
#    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_dlsum_tp}    ${target_ulsum_tp}
#    ${pcell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    ${pcell_index}
#    ${scell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
#    ${dlsum_tp}    Evaluate    ${pcell_dlTP}+${scell_dlTP}
#    Log To Console    DL Troughput is ${dlsum_tp}    console=True
#    Should Be True    ${dlsum_tp}>=${target_dlsum_tp}
#    ${pcell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    ${pcell_index}
#    ${scell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
#    ${ulsum_tp}    Evaluate    ${pcell_ulTP}+${scell_ulTP}
#    Log To Console    UL Troughput is ${ulsum_tp}    console=True
#    Should Be True    ${ulsum_tp}>=${target_ulsum_tp}
