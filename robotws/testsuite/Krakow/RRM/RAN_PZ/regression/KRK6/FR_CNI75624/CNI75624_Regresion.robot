*** Settings ***
Force Tags    PY36
Documentation
...  author:  Andrzej Pencak, Olga Urbanska
...  contact: andrzej.pencak@nokia.com, olga.urbanska@nokia.com

Library   testsuite/Krakow/resources/RAN_PZ_KRK6/fail_watcher_sdk.py

Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CNI75624/resources/suite_specific_keywords.robot

Suite Setup    Suite Setup

*** Variables ***
${XN_SETUP_REQUEST_SENT}     M55126C00035
${XN_SETUP_RESPONSE_RECEIVED}     M55126C00005

*** Test Cases ***

CNI75624_03_ANR_SA_inter_gNB_without_Xn_link
    [Setup]     suite_specific_keywords.Test Setup    scfc_gnb0=${CNI75624_03_scfc_gnb0}   scfc_gnb1=${CNI75624_03_scfc_gnb1}
    Attach 5G UE to gNB1 cell1 and collect logs
    Try to Trigger HO to gNB2 cell1
    Perform handover from gNB1 cell1 to gNB2 cell1
    Verify Xn link existance in WebEM
    Verify NRREL existance in WebEM
    Check counters: XN_SETUP_REQUEST_SENT and XN_SETUP_RESPONSE_RECEIVED
    [Teardown]    suite_specific_keywords.Test Teardown    clear_gnb1=${True}

CNI75624_06_ANR_SA_RAN_sharing
    [Setup]     suite_specific_keywords.Test Setup    scfc_gnb0=${CNI75624_06_scfc_gnb0}    scfc_gnb1=${CNI75624_06_scfc_gnb1}
    Attach 5G UE to gNB1 cell1 and collect logs
    Trigger Measurement Report by the UE and perform handover from gNB1 cell1 to gNB2 cell1
    [Teardown]    suite_specific_keywords.Test Teardown    clear_gnb1=${True}
