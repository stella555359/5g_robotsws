*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Common Suite Setup
#...               AND    Prepare QT LOLO Enviroment    TYPE=TDD
#Test Setup        Common Test Setup
#Test Teardown     Run Keyword    Testcase Teardown
#Suite Teardown    Common Suite Teardown 2
#Force Tags       Classical    FR1    IPV4    FGCR2875    Owner_trshen    RAN_5G
#...              CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD
#...              SBTS00    SBTS23R1    SBTS22R4    CN1_SQ
#
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${GNBCUTYPE}    SA
#${WTS_CFG}    basic_setup.cfg
#@{log_name_list}    btslog
#${Egatelog_path}    ${CURDIR}
#
#*** Test Cases ***
#FGCR2875-ET-A005_Check the DL&UL thoughput with LA enable-enable FGCR2875_1208 frame structure
#    [Tags]    case1    frame1208
#    Set gNB 1208 frame structure and CsiReport
#    Reboot testline and Retart WTS till Cell Onair
#    UE attach And Do DL Traffic    2
#    ${traffic1208}    SA Get UE Average Traffic    dl
#    SA 5G Detach    2
#    UE attach And Do DL Traffic    1
#    ${traffic1208enable}    SA Get UE Average Traffic    dl
#    Save Egate Log    log_path=${Egatelog_path}
#    ${MuharqMessage}=    Get Muharq Message
#    Should Not Be Empty    @{MuharqMessage}[0]
#    SA 5G Detach    1
#
#
#FGCR2875-ET-A008_Check the DLUL thoughput with LA enable_disable FGCR2875_with 1116-c frame structure
#    [Tags]    case5    frame1116
#    Set gNB 1116-c frame structure and CsiReport
#    Reboot testline and Retart WTS till Cell Onair
#    UE attach And Do DL Traffic    2
#    ${traffic1116}    SA Get UE Average Traffic    dl
#    SA 5G Detach    2
#    UE attach And Do DL Traffic    1
#    ${traffic1116enable}    SA Get UE Average Traffic    dl
#    Save Egate Log    log_path=${Egatelog_path}
#    ${MuharqMessage}=    Get Muharq Message
#    Should Not Be Empty    @{MuharqMessage}[0]
#    SA 5G Detach    1
#
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB
#    Suite Setup Copy WTS Config Files From Local    ${CURDIR}
#    Enable CSI
#
#Set gNB 1070 frame structure and CsiReport
#    Delta Commission With SCF File    ${CURDIR}/Delta_Conf_FS1070.json
#
#Set gNB 1116-c frame structure and CsiReport
#    Delta Commission With SCF File    ${CURDIR}/Delta_Conf_FS1116.json
#
#Set gNB 1208 frame structure and CsiReport
#    Delta Commission With SCF File    ${CURDIR}/Delta_Conf_FS1208.json
#
#Enable CSI
#    Log To Console    enable csi in swconfig
#    Run Keyword And Ignore Error    SSH.Disconnect
#    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
#    SSH.Execute    sed -i -e '/0x5800F3/d' /ffs/run/swconfig.txt
#    [Teardown]    SSH.Disconnect
#
#Reboot testline and Retart WTS till Cell Onair
#    Release Egate
#    Reboot TL And Check Configured
#    Start WTS And Check OnAir
#
#Common Test Setup
#    [Arguments]    ${delta_jason}=${none}
#    Create Test Directory
#    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    before_case
#    Run Keyword If    '${delta_jason}' != '${none}'    Delta Commission With SCF File    ${delta_jason}
#    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    after_case
#    common_log_capture.Start Logs    ${log_name_list}
#    Run Keyword If    '${GNBCUTYPE}'=='NSA'    common_log_capture.Start Sos Report
#
#Release Egate
#    OperatingSystem.run    sudo pkill edaemon
#    OperatingSystem.run    sudo pkill egate
#
#Start WTS And Check OnAir
#    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Start UTE WTS
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
#    Run Keyword If    '${GNBCUTYPE}'=='NSA'    Setup X2 Connection
#    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
#    Verify Cell Setup
#    Run Keyword And Ignore Error    Stop Cell Setup Logs
#
#UE attach And Do DL Traffic
#    [Arguments]    ${ue}=${ue_id}
#    SA 5G Attach    ${ue}
#    SA 5G PDU Session Setup    ${ue}
#    SA Start DL Traffic    500
#    SA Stop DL Traffic
#
#Get Muharq Message
#    ${Muharqregex}=    Set Variable    mux-SR-HARQ-ACK-CSI-PUCCH-OncePerSlot
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${MuharqMessage}=    String.Get Regexp Matches    ${content}    ${Muharqregex}
#    [Return]    ${MuharqMessage}
#
#Testcase Teardown
#    Common Test Teardown
#    clean edaemon and egate
#
#clean edaemon and egate
#    ute_wtssim.Teardown Edaemon    alias=edaemon
#    ute_wtssim.Teardown Egate
