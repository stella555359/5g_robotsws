*** Settings ***
Documentation
...   author: Andrzej Pencak
...   contact: andrzej.pencak@nokia.com
...   Test suite for CB014359-SR-B feature

Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.setups.Setups          WITH NAME    st
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.teardowns.Teardowns    WITH NAME    td
Resource     testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB014359/resources/suite_setup_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup        st.cb008490_suite_setup
Suite Teardown     td.cb008490_suite_teardown

Test Setup         Test Setup 4SK010
Test Teardown      Test Teardown 4SK010

*** Variables ***
@{critical_faults}       0010  0016  1806  1868  4341  4352  4383
@{ALLOWED_ALARMS}            61648    7115    4420    4655    61524    61652    4654    62003    62001    7331    7311
...                                 Failure in connection between BTS and 3rd party tool
...                                 LMP connectivity detected

*** Test Cases ***

CB014359_Verify_1T1R_cell_handover_scenarios

     Turn off NRDC to enable mobility
     Attach 4SK010 UE
     Start DL and UL data transmission
     Trigger inter-freq HO    area=1
     Verify DL and UL data transmission
     Verify inter-freq HO

     Setup second area for attach
     Attach 4SK010 UE
     Start DL and UL data transmission
     Trigger inter-freq HO    area=2
     Verify DL and UL data transmission
     Verify inter-freq HO

