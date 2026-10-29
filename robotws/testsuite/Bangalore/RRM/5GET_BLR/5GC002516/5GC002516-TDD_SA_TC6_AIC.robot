*** Settings ***
Documentation
...	author/contact: naveen.m_s@nokia.com
...
...	Test case to verify Frame Structure and TPut with enabled 5GC002516.
...     for 1 UE on 1CC. DL MCS lowered to 5 to keep full buffer.
...     UE supports simultaneous HARQ ACK + CSI.
...	It uses some common setup/teardown keywords
#
#
#Resource          5GC002516_keyword.robot
#Resource          resources/common/common_setup_teardown.robot
#Resource          resources/common/common_log_capture.robot
#Resource          resources/common/common_file_operation.robot
#Resource          resources/common/common_deal_config_file.robot
#
#Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
#Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
#Library             taf.transport.ssh           WITH NAME    taf_ssh
#Resource            ../resources/robot/AIC_Common_Keywords.robot
#Resource            ../resources/robot/Common_Keywords.robot
#Resource           ../resources/robot/ConformanceConstants/Constants_general.robot
#Resource           ../CB007120/resources/ConformanceTest_keywords_AiC.robot
#Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog.robot
#Resource           ../CB008541/resources/CB008541_Keywords.robot
#
#Force Tags      CRT    RAN_5G_TDD      SBTS00   SBTS23R1    CONFIGURED
##Force Tags        CRT    5G_RAN_TDD    RAN_5G_TDD    RAN_5G
##...   PY27
##...               SBTS00    SBTS22R1     SBTS22R2     CONFIGURED
##...               CLOUD_5G_I_BO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#
#
#
#
#
#Suite Setup             Run keywords     Test Suite Setup
#...                     AND              AIC Software Build Info
#...                     AND              Fetch Taf Library used in TL
#...                     AND              Update and Activate Delta Plan Parameter    basic
#...                                      ${CURDIR}/config/Delta_configuration_scf_dl_muting.json
#...                     AND              BuiltIn.Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${120}
#...                     AND              BuiltIn.Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${120}
#...                     AND              BuiltIn.Run Keyword And Ignore Error   Verify RMODs Online Status       ${800}
#...                     AND              SLeep   100s
#
#
#Test Setup    Run Keywords   Start Syslog Monitoring
#...     AND       Configure UTE ETH3 IPs
#...     AND       Start WTS Using WTS_Runner   ${wts_cfg_file}
#...     AND       Sleep   100s
#
#*** Variables ***
#${wts_cfg_file}     ${CURDIR}/config/basic_setup.cfg
#&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
#${WTS_DIR}          /opt/iphy/latest
#${UE_ID}        1
#${nwslice_ID}   1
#${gw_ID}     1
#${Pdu_session_ID}       1
#${QFI_ID}    1
#${TRF_ID}    1
#${TRF_ID2}    2
#${TRF_ID3}    3
#${TRF_ID4}    4
#${epc_log_path}    /tmp/
#@{cellsetup_params}    actInfTddFrameMuting    bilateralAgreement
#
#
#*** Test Cases ***
#[1][1.0] TC6_5GC002516_A-d_VerifyMutingSlot_Scenario34
#    [Documentation]    This test case is to verify Frame Structure and TPut with enabled 5GC002516;
#    ...    Source Frame Structure: Semi 14, 10-2-2;
#    ...    Interfering  Frame Structure: tdLte 3ms, 6-4-4.
#    ${TEST_NAME}     Replace String    ${TEST_NAME}    ${SPACE}    ${EMPTY}
#    ${TEST_NAME}    Remove String    ${TEST_NAME}    [1][1.0]
#    ${TESTCASE_LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
#    set test variable     ${TESTCASE_LOG_PATH}
#    ${CURRENT_SYSLOG_PATH}    Set Variable    ${TESTCASE_LOG_PATH}/Syslog_vDU
#    set test variable       ${CURRENT_SYSLOG_PATH}
#    log to console    Triggering UE attach...
#    UE Register should be Successful     ue_id=${UE_ID}
#    Start 450 Mbps Big DL Data Transfer
#    Verify DL Tput For 1CC TDD
#    Stop and Collect Syslog Monitoring
#    Check Parameter in syslog
#    UE Deregister should be Successful   ue_id=${UE_ID}
#
#
#*** Keywords ***
#Start 450 Mbps Big DL Data Transfer
#    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=1
#    sleep   5s
#    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=2
#    sleep   5s    reason=Wait for successful traffic start
#    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=3
#    sleep   5s
#    sleep   10s    reason=Wait for successful traffic start
#
#Check Parameter in syslog
#    log to console     Verifying cell setup messages in syslog
#    FOR   ${item}   IN    @{cellsetup_params}
#          #${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog* | grep "${item}"
#          ${status} =   run    command=sudo grep "${item}" ${CURRENT_SYSLOG_PATH}/syslog*
#          Should Not Be Empty    ${status}
#          Should Contain     ${status}    "${item}":true
#    END
#
#Verify DL Tput For 1CC TDD
#    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
#    Should Be True    ${pcell_tput} > ${300}
