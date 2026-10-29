*** Settings ***
Documentation    ...
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup       Run Keywords    Common Suite Setup
#...               AND    Prepare QT LOLO Enviroment    TYPE=TDD
#Test Setup       Common Test Setup
#Test Teardown    Run Keyword    Testcase Teardown
##Suite Teardown    Common Suite Teardown
#Force Tags       Classical    FR1    IPV4    FGCR2875    Owner_trshen   RAN_5G
#...              CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD
#...              SBTS00    SBTS23R1    SBTS22R4
#
#*** Variables ***
#${GNBCUTYPE}    NSA
#${SCF_PATH}    ${CURDIR}/config
#${RESOURCE_PATH}       ${CURDIR}/resources
#@{log_name_list}    btslog
##fr1-Add-UE-NR-Capabilities    phy-ParametersFRX-Diff   mux-SR-HARQ-ACK-CSI-PUCCH-OncePerSlot  sameSymbol supported
#${UE_CAPACITY_CR2875}    ue_nr_capabilities=05000000010800000004DA00000000003018800803C00000000000008A80000000000000A8
#${Egatelog_path}    ${CURDIR}
#
#*** Test Cases ***
#FGCR2875-ET-A0015_Check_DL_thoughput_with_LA_disable_FGCR2875_enable_1070_frame_structure
#    [Tags]    case5    frame1070
#    Add flag for enable CR2875
#    Set gNB 1070 frame structure and CsiReport
#    Reboot testline and Wait Cell Onair
#    ${dl_tp_frame_1070_CR2875_open}=    Attach UE and Get DL Throughput
#    Save Egate Log    log_path=${Egatelog_path}
#    ${MuharqMessage}=    Get Muharq Message
#    Should Not Be Empty    @{MuharqMessage}[0]
#
#FGCR2875-ET-A0016_Check_DL_thoughput_with_LA_disable_FGCR2875_disable_1070_frame_structure
#    [Tags]    case6    frame1070
#    Add flag for disable CR2875
#    Reboot testline and Wait Cell Onair
#    ${dl_tp_frame_1070_CR2875_closed}=    Attach UE and Get DL Throughput
#    set suite variable    ${dl_tp_frame_1070_CR2875_closed}
#
#*** Keywords ***
#Change UE Capacity for CR2875
#    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
#    @{old_params_list}    Create List    ue_nr_capabilities=[0-9a-zA-Z]+
#    @{new_params_list}    Create List    ${UE_CAPACITY_CR2875}
#    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}
#
#Add flag for disable CR2875
#    Add RD Param To Swconfig File    0x59003E=0;0x58000E=0x00020
#
#Add flag for enable CR2875
#    Add RD Param To Swconfig File    0x59003E=1;0x58000E=0x00020
#
#Add flag for LA enable
#    Add RD Param To Swconfig File    0x580011=1;0x580012=1;0x580013=1;0x580014=1
#
#Add flag for disable LA
#    Add RD Param To Swconfig File    0x580011=0;0x580012=0;0x580013=0;0x580014=0
#
#Set gNB 1116-c frame structure and CsiReport
#    Delta Commission With SCF File    ${CURDIR}/delta_frame_structure_1116_c.json
#
#Set gNB 1208 frame structure and CsiReport
#    Delta Commission With SCF File    ${CURDIR}/delta_frame_structure_1208.json
#
#Set gNB 1070 frame structure and CsiReport
#    Delta Commission With SCF File    ${CURDIR}/delta_frame_structure_1070.json
#
#Reboot testline and Wait Cell Onair
#    Release Egate
#    Reboot TL And Check Configured
#    Start WTS And Check OnAir
#
#Attach UE and Get DL Throughput
#    NSA LTE Attach    ue_id=11
#    NSA 5G Attach    ue_id=11    gnb_id=2    cell_id=1    bearer_id=2
#    NSA Start DL Traffic    ue_id=11    bearer_id=2    mbps=175    trf_id=1
#    NSA Start DL Traffic    ue_id=11    bearer_id=2    mbps=175    trf_id=2
#    ${dl_tp}=    NSA Get UE Average Traffic    ue_id=11    bearer_id=2    dir=dl
#    log    DL Troughput is ${dl_tp}    console=True
#    [Teardown]    NSA LTE Detach    ue_id=11
#    [Return]    ${dl_tp}
#
#Common Suite Setup
#    Suite Setup Update GNB
#    Suite Setup Copy WTS Config Files From QT
#    Change UE Capacity for CR2875
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
#Start WTS And Check OnAir
#    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Start UTE WTS
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
#    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
#    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection
#    Verify Cell Setup
#
#Get Muharq Message
#    ${Muharqregex}=    Set Variable    deltaF-PUCCH-f1 -10
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${MuharqMessage}=    String.Get Regexp Matches    ${content}    ${Muharqregex}
#    [Return]    ${MuharqMessage}
#
#Release Egate
#    OperatingSystem.run    sudo pkill edaemon
#    OperatingSystem.run    sudo pkill egate
#
#Testcase Teardown
#    Common Test Teardown
#    clean edaemon and egate
#
#clean edaemon and egate
#    ute_wtssim.Teardown Edaemon    alias=edaemon
#    ute_wtssim.Teardown Egate
