*** Settings ***
Documentation
...   author: Sara Nowak
...   contact: sara.nowak@nokia.com

Library      ./resources/keywords.py
Resource     ./resources/suite_specific_keywords.robot
Variables    ./resources/variables.py

Suite Setup       Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Teardown     Common Postconditions

*** Test Cases ***
CB008242-A_100_A#IWK1_Start_max_automatic_UAC_triggered_by_Overload_gNB-CU
    Collect PM Counters Before Test

    Collect BIP Log And Verify SIB1 Message With Static Uac Settings
    Enter Overload State on gNB-CU
    Verify Network Access Rate Reduction
    Wait Until StartUacBarringTimerOverload Expires
    Collect BIP Log And Verify SIB1 Message With Th4(max) Auto Uac Settings

    Collect PM Counters After Test
    Verify M55164C00001 Counter Updates

    [Teardown]     Test Teardown

CB008242-A_200_A#IWK2_Downgrade_automatic_UAC_triggered_by_Overload_gNB-CU
    Enter Overload State on gNB-CU
    Verify Network Access Rate Reduction
    Wait Until StartUacBarringTimerOverload Expires
    Collect BIP Log And Verify SIB1 Message With Th4(max) Auto Uac Settings
    Exit Overload State on gNB-CU
    Wait Until StopUacBarringTimerOverload And UacUpdateTimer Expires
    Collect BIP Log And Verify SIB1 Message With Th3 Auto Uac Settings
    Wait Until UacUpdateTimer Expires
    Collect BIP Log And Verify SIB1 Message With Th2 Auto Uac Settings
    Wait Until UacUpdateTimer Expires
    Collect BIP Log And Verify SIB1 Message With Th1 Auto Uac Settings
    Wait Until UacUpdateTimer Expires
    Collect BIP Log And Verify SIB1 Message With Static Uac Settings
    Verify No Alarm EFaultId_AutomaticUnifiedAccessControlBarringAl On Cell

    [Teardown]     Test Teardown

CB008242-G_100_G#B1_Automatic_UAC_parameters_uacAcCatListAuto_online_modification
    [Setup]     G 100 Test Setup

    Enter Overload State on gNB-CU
    Verify Network Access Rate Reduction
    Wait Until StartUacBarringTimerOverload Expires
    Collect BIP Log And Verify SIB1 Message With Th4(max) Auto Uac Settings

    Change Automatic UAC Parameters
    Wait Until UacUpdateTimer Expires After uacAcCatList modification
    Collect BIP Log And Verify SIB1 Message With New Th4(max) Auto Uac Settings

    [Teardown]     G 100 Test Teardown

CB008242-G_300_G#B3_Automatic_UAC_parameter_actUacAuto_online_modification
    [Setup]     G 100 Test Setup

    Enter Overload State on gNB-CU
    Verify Network Access Rate Reduction
    Wait Until StartUacBarringTimerOverload Expires
    Collect BIP Log And Verify SIB1 Message With Th4(max) Auto Uac Settings

    Deactivate automatic unified access control
    Collect BIP Log And Verify SIB1 Message With Static Uac Settings

    [Teardown]     G 300 Test Teardown

CB008242-D_300_D#IWK3_Automatic_UAC_load_and_overload_triggers_interactions
    [Setup]    D 300 Test Setup

    Set triggersBitmap on gNB    value=3
    Collect BIP Log And Verify SIB1 Message With Static Uac Settings

    Attach UE With PDU Session Setup to Cell 1 of gNB 1

    Wait Until StartUacBarringTimer Expires
    Collect BIP Log And Verify SIB1 Message With Th1 Auto Uac Settings
    Wait Until UacUpdateTimer Expires

    Enter Overload State on gNB-CU
    Verify Network Access Rate Reduction
    Wait Until StartUacBarringTimerOverload Expires

    Collect BIP Log And Verify SIB1 Message With Th4(max) Auto Uac Settings

    Detach UE
    Set triggersBitmap on gNB    value=1

    [Teardown]    D 300 Test Teardown
