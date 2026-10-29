*** Settings ***
Test Teardown      Common Test Teardown
Suite Teardown     Common Suite Teardown
Force Tags         CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G
...                SBTS00    CN1_SG06_SM1    CB008950    owner_suxu

Resource          ./../CUDU_L2/common_setup_teardown.robot
Documentation    CB008950_ET_A405_A1_Scell_Change_FtoT_Different_Scellprio
*** Variables ***
${SCF_PATH}                 ${CURDIR}/Config/
${SCFC_FILE}                8950_2F_6T_SCF_A405.xml
${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts
${WTS_DIR}                  /opt/iphy/latest
${IPHY_2F_4T}               ${CURDIR}/Config/wts/iphy_2F_6T.xml
${WTS_CFG}                  CB008950_2F_6T_A405.cfg
${SWCONFIG_PARAM_GNB}       0x58057d=0x80400000;0x58057a=3
@{LOG_NAME_LIST}            btslog    snapshot    egatelog
${UE1_ID}                   1
${UE2_ID}                   2
@{2CA_UE_LIST}              1    2
@{2CC_DLTPUT_LIST}          80    80
${2CC_SCELL_PCI_CELL2}      51
${2CC_SCELL_PCI_CELL11}     60
${2CC_SCELL_PCI_CELL12}     61

*** Test Cases ***
CB008950_ET_A405_A1_Scell_Change_FtoT_Different_Scellprio
    [Setup]    Run Keywords    Modify SosReport ASIL From Common Log Capture File
    ...        AND    Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_2F_4T}    swconfig_param=${SWCONFIG_PARAM_GNB}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
    ...        AND    Common Test Setup
    SA 5G CA Attach    ue_id=1    pdu_id=1
    Trigger And Check A1 Scell Addition    ueId=1    srsrp_nr=100    scell_pci=${2CC_SCELL_PCI_CELL2}    meas_id=1    scellId=1
    SA 5G CA Attach    ue_id=2
    Trigger And Check A1 Scell Addition    ueId=2    srsrp_nr=100    scell_pci=${2CC_SCELL_PCI_CELL2}    meas_id=1    scellId=1
    SA Multi UE Start DL And UL Traffic    ue_id_list=${2CA_UE_LIST}    dl_mbps=450    ul_mbps=60
    Wait Until Keyword Succeeds    30s    6s    Check Multi UE DLCA And ULnonCA L1 Cell tput    ${2CA_UE_LIST}    40    ${2CC_DLTPUT_LIST}    2
    #Collect All Logs Use StartTest_ASIL
    #Start Ttitrace With Streaming Mode
    Trigger And Check A1 Scell Addition    ueId=1    srsrp_nr=115    scell_pci=${2CC_SCELL_PCI_CELL11}    meas_id=3    scellId=2
    Trigger And Check A1 Scell Addition    ueId=2    srsrp_nr=115    scell_pci=${2CC_SCELL_PCI_CELL12}    meas_id=3    scellId=2
    Sleep    2s
    Run Keyword And Continue On Failure    Check Tput After Scell Change    ueId=1    dl_pcell=60    dl_scell=50    ul_pcell=30
    Run Keyword And Continue On Failure    Check Tput After Scell Change    ueId=2    dl_pcell=60    dl_scell=50    ul_pcell=30
    #Collect All Logs Use StopTest_ASIL
    #Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
    Wait Until Keyword Succeeds    10s    5s    Check Tput After Scell Change    ueId=1    dl_pcell=60    dl_scell=335    ul_pcell=40
    Wait Until Keyword Succeeds    10s    5s    Check Tput After Scell Change    ueId=2    dl_pcell=60    dl_scell=335    ul_pcell=40
    #Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace

*** Keywords ***
Collect All Logs Use StartTest_ASIL
    ${time}    Get Current Date    result_format=timestamp
    Log To Console    \n${time}:startTest_ASIL...... before
    OperatingSystem.Run    cp ${CURDIR}/Config/wts/sosReport.cfg ${wts_dir}
    OperatingSystem.Run    cp ${CURDIR}/Config/wts/startTest_ASIL.sh ${wts_dir}/sosReport_ASIL
    OperatingSystem.Run    cp ${CURDIR}/Config/wts/stopTest_ASIL.sh ${wts_dir}/sosReport_ASIL
    ${rc}    OperatingSystem.Run And Return Rc
    ...    cd ${wts_dir}/sosReport_ASIL && bash -x ${wts_dir}/sosReport_ASIL/startTest_ASIL.sh > /dev/null 2>\&1
    ${time}    Get Current Date    result_format=timestamp
    Log To Console    \n${time}:startTest_ASIL...... after

Collect All Logs Use StopTest_ASIL
    ${time}    Get Current Date    result_format=timestamp
    Log To Console    \n${time}:stopTest_ASIL...... before
    ${rc}    OperatingSystem.Run And Return Rc
    ...    cd ${wts_dir}/sosReport_ASIL && bash -x ${wts_dir}/sosReport_ASIL/stopTest_ASIL.sh > /dev/null 2>\&1
    ${time}    Get Current Date    result_format=timestamp
    Log To Console    \n${time}:stopTest_ASIL...... after

Check Tput After Scell Change
    [Arguments]    ${ueId}    ${dl_pcell}    ${dl_scell}    ${ul_pcell}
    [Documentation]    This keyword is to check tput after scell change from cell 2 to cell 11 and cell 12:
    ...    Fdd cell 1:20MHz, Fdd cell 2:20MHz, Tdd cell 11:60MHz, Tdd cell 12 60MHz
    ...    UE1 Fdd cell 1+Fdd cell 2
    ...    UE2 Fdd cell 1+Fdd cell 2
    ...    After A1 Scell Change:
    ...    UE1 Fdd cell 1+Tdd cell 11
    ...    UE2 Fdd cell 1+Tdd cell 12 due to maxNumOfSCellAlloc=1 for cell 11
    ${pcell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    0
    Log To Console    UE${ueId} pcell DL Troughput is ${pcell_dlTP}    console=True
    ${scell1_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    1
    Log To Console    UE${ueId} scell 1 DL Troughput is ${scell1_dlTP}    console=True
    ${scell2_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    2
    Log To Console    UE${ueId} scell 2 DL Troughput is ${scell2_dlTP}    console=True
    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ueId}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${dl_pcell}
    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ueId}    dir=dl    cell_type=scell    scell_index=2    target_tp=${dl_scell}
    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ueId}    dir=ul    cell_type=scell    scell_index=0    target_tp=${ul_pcell}

Modify SosReport ASIL From Common Log Capture File
    ${logfilecapture_path}    Set Variable    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/common_log_capture.robot
    @{old_sosReport}    Create List    sosReport_ASIK_ASIL.sh
    @{new_sosReport}    Create List    sosReport_ASIL/sosReport_ASIL.sh
    Modify Text File    ${logfilecapture_path}    ${old_sosReport}    ${new_sosReport}

Trigger And Check A1 Scell Addition
    [Arguments]    ${ueId}    ${srsrp_nr}    ${scell_pci}    ${meas_id}    ${scellId}
    Trigger A1 Scell Addition    ${ueId}    ${srsrp_nr}    50    ${meas_id}
    Check SA Scell PhysicalID With UE ID    ${ueId}    ${scell_pci}    ${scellId}
