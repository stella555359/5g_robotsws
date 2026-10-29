*** Settings ***
Documentation     this case is the 5GC000474_G_4732 and 5GC000474_HB_4807 for AP testline
...               \n Author: peach.fu@nokia-sbell.com
...               \n The default value for maxX2EnDcCfUpRetry is 5, so M55110C00021/M55110C00015 equals 6.
...               \n Please do not edit the existing keywords in this file without testing.
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG2    owner-junhui.he   release-SBTS22R2
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    7300    7107    7101

@{delete useless cell}
...    delete:MRBTS-1/NRBTS-1/NRCELL-2
...    delete:MRBTS-1/NRBTS-1/NRCELLGRP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
...    NRDU-1:refNrCellGroup=0
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs

@{X2_ALARM}
...    MRBTS-1/NRBTS-1:x2LinkSupervisionTmr=1
...    MRBTS-1/NRBTS-1:x2EnDcCfUpNbInfoBackOffTmr=0




#PM counter

${X2_ENDC_CONF_UPDATE_SENT}      M55110C00015
${X2_ENDC_CONF_UPDATE_ACK_RCVD}         M55110C00016
${X2_ENDC_CONF_UPDATE_FAIL_RCVD}       M55110C00021

@{ENDC_X2_UPDATE}
...    ${X2_ENDC_CONF_UPDATE_SENT}=2
...    ${X2_ENDC_CONF_UPDATE_ACK_RCVD}=2

@{ENDC_X2_UPDATE_FAIL}
...    ${X2_ENDC_CONF_UPDATE_SENT}=6
...    ${X2_ENDC_CONF_UPDATE_FAIL_RCVD}=6

*** Test Cases ***
5GC000474_G_4732_Number_of_couter_in_successful_outgoing_ENDC_Configuration_Update
    [Tags]    QC_60652
    Set X2AP To GNB And Clear Counter Files
    Cell Group Lock
    Cell Group Unlock
    Check Counters    ${ENDC_X2_UPDATE}
    Check Wireshark Log    ${CURDIR}${/}a2a_4732${/}a2a.ini

5GC000474_HB_4807_Test_Outgoing_ENDC_Configuration_Update_failure_by_receiving_failure_message
    [Tags]    QC_60646
    Set X2AP To GNB And Clear Counter Files
    Online Param Change And Set ENDC Update Failure    ${X2_ALARM}
    Cell Group Lock
    Cell Group Unlock
    Check Counters    ${ENDC_X2_UPDATE_FAIL}
    Check Wireshark Log    ${CURDIR}${/}a2a_4807${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Perform Steps After Onair
    Delta Commission Parameters    ${delete useless cell}

Set X2AP To GNB And Clear Counter Files
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2    timeout=60    sleep_time=5
    Clear Counter Files

Cell Group Lock
    Lock Cell1

Cell Group Unlock
    UNLOCK CELL1

Online Param Change And Set ENDC Update Failure
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
    Execute Egate Command    link_x2_management_abnormal_cases endc_cfg_update_rsp=failure id=1 partner=2    timeout=60    sleep_time=5
