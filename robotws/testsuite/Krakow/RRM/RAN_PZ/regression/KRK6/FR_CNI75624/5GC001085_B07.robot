*** Settings ***
Force Tags    PY36
Documentation
...  author:  Andrzej Pencak
...  contact: andrzej.pencak@nokia.com

Library   testsuite/Krakow/resources/RAN_PZ_KRK6/fail_watcher_sdk.py

Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CNI75624/resources/suite_specific_keywords.robot

Suite Setup    Suite Setup

*** Test Cases ***

5GC001085.B07_Intra_frequency_inter_gNB_neighbor_relation_update_after_manual_parameter_change
    [Setup]     suite_specific_keywords.Test Setup    scfc_gnb0=${5GC001085_B07_scfc_gnb0}    scfc_gnb1=${CNI75624_06_scfc_gnb1}
    Attach 5G UE to gNB1 cell1 and collect logs
    Trigger Measurement Report by the UE and perform handover from gNB1 cell1 to gNB2 cell1
    Detach UE

    Change ssbFrequency in newly created NRADJNRCELL
    Attach 5G UE to gNB1 cell1 and collect logs
    Trigger Measurement Report by the UE and perform handover from gNB1 cell1 to already known gNB2 cell1
    Detach UE
    Check ssbFrequency was updated in NRADJNRCELL after ANR

    Change physCellId in recently updated NRADJNRCELL
    Attach 5G UE to gNB1 cell1 and collect logs
    Trigger Measurement Report by the UE and perform handover from gNB1 cell1 to already known gNB2 cell1
    Detach UE
    Check physCellId was updated in NRADJNRCELL after ANR

    Perform three more ssbFrequency and physCellId changes followed by ANR
    Check if any resource was leaked during test

    [Teardown]    suite_specific_keywords.Test Teardown    clear_gnb1=${True}
