*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT_no_cloud    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG2    owner-junhui.he   release-SBTS22R2
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    7300    7107

#PM counter
${ENDC_X2_SETUP_REQUEST_RECEIVED}  M55110C00003
${ENDC_X2_SETUP_FAIL_NOSUP}        M55110C00006

@{ENDC_X2_Setup_Failure}
...  ${ENDC_X2_SETUP_REQUEST_RECEIVED}=1
...  ${ENDC_X2_SETUP_FAIL_NOSUP}=1

*** Test Cases ***
5GC000474_B_4201_Test_1_ENDC_X2_Setup_Failure_Due_to_the_initiating_NodeType_is_not_an_eNB
    [Tags]    QC_60650
    Set X2AP To GNB
    Clear Counter Files
    Setup X2 With NodeType Not LTE ENB
    check counters     ${ENDC_X2_Setup_Failure}
    Check Wireshark Log    ${CURDIR}${/}a2a_4201${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Set X2AP To GNB
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2

Setup X2 With NodeType Not LTE ENB
    [Arguments]    ${pass_regexp}=EN-DC X2 Setup Failure recvd
    Execute Egate Command    enb_x2_stats enb=1 clear sleep_time=1
    Execute Egate Command    enb_param id=1 send_x2_setup=off sleep_time=1
    Execute Egate Command    enb_x2_link_up enb=1 target=2 sleep_time=1
    Execute Egate Command    send_hex source=enb:1 target=gnb:2 hex=0024001600000100f4000f40000100fc00080052205500078900  ${pass_regexp}

