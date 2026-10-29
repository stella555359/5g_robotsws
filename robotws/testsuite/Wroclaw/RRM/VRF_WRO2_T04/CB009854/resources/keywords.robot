*** Settings ***
Documentation
...   author:  Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com

Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library    ute_ue
Resource   testsuite/Wroclaw/RRM/resources/logs.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py


*** Variables ***
@{counters_9854}    M55138C00048    M55138C00049    M55118C02014    M55118C02015    M55139C00024    M55139C00023
@{counters_8053}    M55118C09501    M55118C09502    M55118C09503    M55138C03001    M55138C03002    M55139C03001    M55139C03002
*** Keywords ***

5CC Counters Loop
     &{counters_values}=     Get Scell Add Counter Values    ${counters_9854}
     FOR    ${index}    IN    @{counters_9854}
        Run Keyword And Continue On Failure
        ...    Counter Incremented Successfully    ${index}    cell_id=211    counter_dict=counters_values    operator===

     END

Verify 4CC counters
    Log    Verifying 4CC counters    console=yes
    &{counters_values}=     Get Scell Add Counter Values    ${counters_8053}
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55118C09501    cell_id=1    counter_dict=counters_values    operator=>=
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55118C09502    cell_id=1    counter_dict=counters_values    operator=>=
     Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55118C09503    cell_id=1    counter_dict=counters_values    operator=>=
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55138C03001    cell_id=1    counter_dict=counters_values    operator=>=
     Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55138C03002    cell_id=1    counter_dict=counters_values    operator=>=
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55139C03001    cell_id=1    counter_dict=counters_values    operator=>=
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55139C03002    cell_id=1    counter_dict=counters_values    operator=>=


Verify 5CC counters
     Log    Verifying 5CC counters    console=yes
    &{counters_values}=     Get Scell Add Counter Values    ${counters_9854}
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55138C00048    cell_id=1    counter_dict=counters_values    operator===
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55138C00049    cell_id=1    counter_dict=counters_values    operator===
     Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55118C02014    cell_id=1    counter_dict=counters_values    operator===
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55118C02015    cell_id=1    counter_dict=counters_values    operator===
     Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55139C00024    cell_id=1    counter_dict=counters_values    operator===
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55139C00023    cell_id=1    counter_dict=counters_values    operator===

Set Attenuation For 5CC Cell With Id
    [Arguments]    ${cell_id}    ${attenuation}=90dB
    Initialise Attenuator
    Set Attenuation    ${attenuation}    port=${ATTENUATOR['NRCELL_${cell_id}']['ports']}    confirm=${TRUE}

5CC precondition
    Set Attenuation For 5CC Cell With Id    1    8
    Set Attenuation For 5CC Cell With Id    5    36
    Set Attenuation For 5CC Cell With Id    2    37
    Set Attenuation For 5CC Cell With Id    3    90
    Set Attenuation For 5CC Cell With Id    6    20

5CC trigger
    Set Attenuation For 5CC Cell With Id    5    15
    Set Attenuation For 5CC Cell With Id    1    0
    Set Attenuation For 5CC Cell With Id    2    16
    Set Attenuation For 5CC Cell With Id    7    0
    Set Attenuation For 5CC Cell With Id    6    0

Set Attenuation For 4CC PCell With Id
    [Arguments]    ${cell_id}    ${attenuation}=20dB
    Initialise Attenuator
    Set Attenuation    ${attenuation}    port=${ATTENUATOR['NRCELL_${cell_id}']['ports']}    confirm=${TRUE}

Decrease Attenuation For ANR Cell With Id
    [Arguments]    ${cell_id}    ${attenuation}=0
    Initialise Attenuator
    Set Attenuation    ${attenuation}    port=${ATTENUATOR['NRCELL_${cell_id}']['ports']}    confirm=${TRUE}

Set MaxnumScell
    [Arguments]    ${parameter}    ${value}
    admin.Setup admin    10.42.234.96    443    Nemuadmin    nemuuser    True    5000
    admin.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-51995/NRBTS-51995/NRCELL-1
    ...    parameter=${parameter}
    ...    operation=update
    ...    value=${value}
    ...    skip_parameter_relation_errors=True
    admin.Teardown admin

Set MaxnumScell 5CC
    [Arguments]    ${parameter}    ${value}
    admin.Setup admin    10.42.85.20    443    Nemuadmin    nemuuser    True    5000
    admin.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-55131/NRBTS-55131/NRCELL-211
    ...    parameter=${parameter}
    ...    operation=update
    ...    value=${value}
    ...    skip_parameter_relation_errors=True
    admin.Teardown admin