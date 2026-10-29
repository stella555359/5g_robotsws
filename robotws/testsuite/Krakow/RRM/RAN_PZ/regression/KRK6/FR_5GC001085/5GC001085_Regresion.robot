*** Settings ***
Force Tags    PY311    STATE_SW_UPLOADED   RAN_5G
Documentation
...  author:  Andrzej Pencak, Olga Urbanska
...  contact: andrzej.pencak@nokia.com, olga.urbanska@nokia.com

Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_5GC001085/resources/suite_specific_keywords.robot

Suite Setup    Suite Setup

Suite Teardown    Common Suite Teardown

*** Test Cases ***

5GC001085.C02_NRREL_removal_on_permanent_inability_of_reaching_CONFIRMED_PCI_status_intra_gNB_case
    [Setup]     suite_specific_keywords.Test Setup
    Set consecRecheckForNrNbRemoval to 2 parameter on gNB1
    Set idleTimeForNrNbRemoval to 2 parameter on gNB1
    Attach 5G UE to gNB1 cell1 and collect logs
    Trigger Handover from gNB1 cell1 to gNB1 cell2
    Trigger Handover from gNB1 cell2 to gNB1 cell1
    Check if relations appered under both cells
    Set reportAmountSA to r1 parameter on gNB1 cell1
    Change parameter maxNumOfRrc to 0 on gNB1 cell2
    Reattach UE to gNB1 cell1
    Perform few consecutive unsuccessful Handovers from gNB1 cell1 to gNB1 cell2 and check that NRREL was removed
    Change parameter on gNB1 cell2 maxNumOfRrc back to 250
    Set reportAmountSA to r4 parameter on gNB1 cell1
    Set actAutoNrNbRemoval to false on gNB1
    Reattach UE to gNB1 cell1
    Try to trigger successful Handover from gNB1 cell1 to gNB1 cell2
    Check if relation to gNB1 cell2 appeared
    [Teardown]    suite_specific_keywords.Test Teardown    clear_gnb0=${True}

CNI75624_01_ANR_SA_intra_gNB_success_case
    [Setup]     suite_specific_keywords.Test Setup
    Attach 5G UE to gNB1 cell1 and collect logs
    Perform handover from gNB1 cell1 to gNB1 cell2 With DRX Profile Reconfiguration
    [Teardown]    suite_specific_keywords.Test Teardown    clear_gnb0=${True}
