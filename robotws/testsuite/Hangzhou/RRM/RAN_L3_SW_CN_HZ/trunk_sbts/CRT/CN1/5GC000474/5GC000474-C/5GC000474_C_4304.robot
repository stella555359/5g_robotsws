*** Settings ***
Documentation     this case is the 5GC000474_C_4304_and_5GSW_CP_EDA003_5GC000474_PR568631 for AP testline
...               \n Author: Carol.An@nokia-sbell.com CASE 5GC000474_C_4304_and_5GSW_CP_EDA_5GC000474_PR568631_shutdownNogNBCellTmr
...               \n Please do not edit the existing keywords in this file without testing.
...               \n PR568631: [21A][NSA][5GC00474][AEQN]counter M55110C00017 Number of SCTP shutdown due to no more gNB cell available pegged
...               \n value when shutdownNogNBCellTmr expired but no SCTP SHUTDOWN send out in wireshark
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG2    owner-junhui.he   release-SBTS22R2
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
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

@{first_delta_commission}
...    MRBTS-1/NRBTS-1:shutdownNogNBCellTmr=0
...    MRBTS-1/NRBTS-1:x2LinkReestabTmr=1

@{second_delta_commission}
...    MRBTS-1/NRBTS-1:shutdownNogNBCellTmr=2
...    MRBTS-1/NRBTS-1:x2LinkReestabTmr=1


#PM counter

${ENDC_X2_SETUP_REQUEST_RECEIVED}      M55110C00003
${ENDC_X2_SETUP_RESPONSE_SENT}         M55110C00004
${X2_SHUTDOWN_NO_GNB_CELL}                M55110C00017

@{ENDC_X2_SETUP_AND_SHUTDOWN}
...    ${ENDC_X2_SETUP_REQUEST_RECEIVED}=1
...    ${ENDC_X2_SETUP_RESPONSE_SENT}=1
...    ${X2_SHUTDOWN_NO_GNB_CELL}=2

@{FAULTS_EXCLUDED_CHECKING}
...    7300


*** Test Cases ***
5GC000474_C_4304_Test_Clean_up_of_X2C_Information_in_Mplane_when_gNB_initiates_the_SCTP_Association_Shutdown
    [Tags]    QC_60655
    Set X2AP To GNB And Clear Counter Files
    Online Param Change And Check LTEENB Status    ${first_delta_commission}
    Cell Group Lock And Verify LTEENB Deletion
    Cell Group Unlock
    Online Param Change And Check LTEENB Status    ${second_delta_commission}
    Cell Group Lock And Verify LTEENB Deletion
    Check Counters    ${ENDC_X2_SETUP_AND_SHUTDOWN}
    Check Wireshark Log    ${CURDIR}${/}a2a_4304${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Perform Steps After Onair
    Delta Commission Parameters    ${delete useless cell}

Set X2AP To GNB And Clear Counter Files
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2    timeout=60    sleep_time=5
    Clear Counter Files

Online Param Change And Check LTEENB Status
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
    object should exist    NRBTS-1/LTEENB-0:x2LinkStatus=available

Cell Group Lock And Verify LTEENB Deletion
    Lock Cell1
    object should not exist    NRBTS-1/LTEENB-0:x2LinkStatus=available

Cell Group Unlock
    UNLOCK CELL1



