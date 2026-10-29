*** Settings ***
Documentation    ...
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./../CB008015/resources/CB008015_lib.robot
#
#*** Variables ***
#${SCF_PATH}              ${CURDIR}/Config/
#${SCFC_FILE}             CB005934_LOO_A1003.xml
#${LOCAL_WTS_DIR}         ${CURDIR}/Config/wts/
#${WTS_DIR}               /opt/iphy/latest
#${IPHYFILE}              ${CURDIR}/Config/wts/iphy_4F_n25A_n66A_n71B_2T.xml
#${SWCONFIG_PARAM_GNB}    0x89003B=1
#${WTS_CFG}               5934_4F_n25A_n66A_n71B_2T_UL.cfg
#${WTS_AP_XML}            airphone.xml
#${UE_ID}                 1
#${PCELL_ID}              50
#${SCELL1_PCI}            51
#${SCELL2_PCI}            52
#${SCELL3_PCI}            53
#${SCELL4_PCI}            60
#
#*** Test Cases ***
#CB005934_ET_A1003_FDD_DL_4CC_A1_Based_Scell_Change_To_2CC_FT_With_UL_CA
#    [Tags]    CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_nilei
#    ...    SBTS00    CN1_SG06    CB005934
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHYFILE}    #swconfig_param=${SWCONFIG_PARAM_GNB}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA Attach    ${UE_ID}
#    Trigger A1 Scell Addition    ${UE_ID}    80    ${PCELL_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL1_PCI}    1
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL2_PCI}    2
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL3_PCI}    3
#    Start SA DLUL Big Traffic Internal For UE
#    Sleep    40s    reason=wait for dl traffic stable
#    Check TP On Target 4F    ${UE_ID}    670    90
#    Trigger A1 Scell Addition    ${UE_ID}    120    ${PCELL_ID}    5
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL4_PCI}    4
#    Sleep    40s    reason=wait for dl traffic stable
#    Wait Until Keyword Succeeds    1min    5s    Check TP On Target FT    ${UE_ID}    0    4    570    170
#
#*** Keywords ***
#Start SA DLUL Big Traffic Internal For UE
#    [Documentation]    this keyword is to start all traffic.
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=200    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=800    trf_id=1
#
#Check TP On Target 4F
#    [Arguments]    ${ueId}    ${target_dlsum_tp}    ${target_ulsum_tp}
#    ${pcell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    0
#    ${scell_dlTP1}    Get CA Cell Average Throughput    ${ueId}    dl    scell    1
#    ${scell_dlTP2}    Get CA Cell Average Throughput    ${ueId}    dl    scell    2
#    ${scell_dlTP3}    Get CA Cell Average Throughput    ${ueId}    dl    scell    3
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
