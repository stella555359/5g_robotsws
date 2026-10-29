*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    = Summary =
...    Purpose: Fault Management testing. Verification of fault triggering after disabling actCbrs.

*** Keywords ***
CBRS_Robustness_01_Feature_deactivation_while_providing_service
    [Documentation]    Requirement: Robustness scenario
    ...                Purpose: Fault Management testing. Verification of fault triggering after disabling actCbrs.
    [Timeout]    30min

    @{allowed_faults}     Set Variable    ${enb_allowed_faults}

    ${ENB_ROOT_USER}   Set Variable        toor4nsn
    ${ENB_ROOT_PASS}   Set Variable       oZPS0POrRieRtu

    Kill All SAS Processes
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    config=${CURDIR}/Data/Robustness_01/SAS_Sim.conf
    Wait For All Cells To Be OnAir
    ${enb_id}     Set Variable    ${testlines.${testline_id}.enb_id}
    ${bts_side}   Set Variable    *
    ${cbsd_id}    Fetch CBSD ID    ${enb_id}



    #Upload precondition delta
    Wait Until BTS Is Not Busy
    Create generic delta and perform commissioning    enb_id=${enb_id}
    ...                                               delta_file_tmp=${CURDIR}/Data/Robustness_01/Robustness_01_Precond_delta_tmp.json
    ...                                               delta_file_final=${CURDIR}/Data/Robustness_01/Robustness_01_Precond_delta.json
    Wait For All Cells To Be OnAir

    ${active_faults}   List Active eNB Faults
    Check For Unwanted Faults     allowed_faults=@{allowed_faults}    active_alarm_list=${active_faults}

    #Step1. Turn off CBRS Feature
    Wait Until BTS Is Not Busy
    Create generic delta and perform commissioning    enb_id=${enb_id}
    ...                                               delta_file_tmp=${CURDIR}/Data/Robustness_01/Robustness_01_Test_delta_tmp.json
    ...                                               delta_file_final=${CURDIR}/Data/Robustness_01/Robustness_01_Test_delta.json

    Assert Fault Presence On Selected Cell     cell_id=1    fault_id=6826    alarm_name=SAS Registration Failure    bts_side=${bts_side}
    Assert Fault Presence On Selected Cell     cell_id=2    fault_id=6826    alarm_name=SAS Registration Failure    bts_side=${bts_side}
    Assert Fault Presence On Selected Cell     cell_id=3    fault_id=6826    alarm_name=SAS Registration Failure    bts_side=${bts_side}
    Assert Fault Presence On Selected Cell     cell_id=4    fault_id=6826    alarm_name=SAS Registration Failure    bts_side=${bts_side}


    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Kill All SAS Processes













