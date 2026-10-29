*** Settings ***
Documentation
...   feature keywords

Library       ute_admin_infomodel
Library       ute_admin

Library    ute_ue

Library       SSHLibrary
Library       ../../../resources/rrm_fixture.py
Library       ../../../resources/webui/interface.py
Library      ../../5GC001167/resources/pcap_verifiers.py
Resource     ../../5GC001167/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/common_keywords.robot

Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py
Variables    ./variables_8281.py

*** Variables ***
${FIRST_CELL}       3
${SECOND_CELL}       5
${THIRD_CELL}       2
${FOURTH_CELL}      1
${UE_1}=     UE_1
${UE_2}=     UE_2
${UE_3}=    UE_3

*** Keywords ***
Set Initial Attenuation For Test
    Initialise Attenuator
    Set Attenuation  ${ATTENUATOR['NRCELL_2']['attenuation']}  ${ATTENUATOR['NRCELL_2']['ports']}  confirm=${TRUE}

Set Initial Attenuation 2 cells
    Attenuate All Cells
    Set Attenuation  ${ATTENUATOR['NRCELL_2']['attenuation']}  ${ATTENUATOR['NRCELL_2']['ports']}  confirm=${TRUE}
    Set Attenuation  ${ATTENUATOR['NRCELL_3']['attenuation']}  ${ATTENUATOR['NRCELL_3']['ports']}  confirm=${TRUE}

Set Initial Attenuation For CA Cell
    keywords_8281.Attenuate All Cells
    Set Attenuation  ${ATTENUATOR['NRCELL_3']['attenuation']}  ${ATTENUATOR['NRCELL_3']['ports']}  confirm=${TRUE}

Attenuate All Cells
    attenuator_keywords.Initialise Attenuator
    attenuator_keywords.Set Attenuation  90dB  confirm=${TRUE}

Gradually Increase Attenuation For Cell
    [Arguments]    ${cell_id}    ${init_value}=0    ${max_value}=90    ${grad_step}=20
    Initialise Attenuator
    Gradually Increase Attenuation    port=${ATTENUATOR['NRCELL_${cell_id}']['ports']}    step=${grad_step}    interval=1
    ...    init_value=${init_value}
    ...    max_value=${max_value}

Gradually Decrease Attenuation For Cell
    [Arguments]    ${cell_id}    ${init_value}=90    ${min_value}=0    ${grad_step}=20
    Initialise Attenuator
    Gradually Decrease Attenuation    port=${ATTENUATOR['NRCELL_${cell_id}']['ports']}    step=${grad_step}    interval=1
    ...    init_value=${init_value}
    ...    min_value=${min_value}

Clear Attenuation
    Set Attenuation  0dB  confirm=${TRUE}

Activate Ecid
    [Arguments]    ${cell_id}
    Update Parameter     param=actUlNrEcIdPosMethod    value=true   distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}

Deactivate Ecid
    [Arguments]    ${cell_id}
    Update Parameter     param=actUlNrEcIdPosMethod    value=false   distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}

Activate MultipleDedicatedBWPs
    [Arguments]    ${cell_id}
    Update Parameter     param=actMultipleDedicatedBWPs    value=true   distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}

Deactivate MultipleDedicatedBWPs
    [Arguments]    ${cell_id}
    Update Parameter     param=actMultipleDedicatedBWPs    value=false   distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}

Activate MultipleEnhancedBWPs
    [Arguments]    ${cell_id}
    Update Parameter     param=actEnhMultipleDedicatedBWPs    value=true   distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}

Deactivate MultipleEnhancedBWPs
    [Arguments]    ${cell_id}
    Update Parameter     param=actEnhMultipleDedicatedBWPs    value=false   distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}

Activate EcidTimer
    Update Parameter     param=nrEcidMeasSupervisionTimer    value=3000

Deactivate EcidTimer
    Update Parameter     param=nrEcidMeasSupervisionTimer    operation=delete

Trigger First
    Ecid Trigger    imsi=2660    meas_quantities=SS_RSRQ

Trigger Second
    Ecid Trigger    imsi=2660    meas_quantities=SS_RSRQ    report_characteristics=Periodic

Trigger Third
    Ecid Trigger    imsi=2660    meas_quantities=SS_RSRP,SS_RSRQ

Trigger Fourth
    Ecid Trigger    imsi=2660    meas_quantities=AngleOfArrivalNR,CSI_RSRQ,CSI_RSRP

Trigger Fifth
    Ecid Trigger    imsi=2660    meas_quantities=SS_RSRP,AngleOfArrivalNR

Trigger Default Values for MeasurementQuantities
    BuiltIn.sleep    5
    Ecid Trigger    imsi=2660    meas_quantities=TimingAdvanceNR,SS_RSRP,SS_RSRQ,AngleOfArrivalNR
    BuiltIn.sleep    10

Activate CB008281_CB009842
    [Arguments]    ${cell_id}
    Update Parameter     param=nrEcidMeasSupervisionTimer    value=3000
    Update Parameter     param=actUlNrEcIdPosMethod    value=true   distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}
    Update Parameter     param=actUlNrEcIdTAdv    value=true   distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}

Deactivate CB008281_CB009842
    [Arguments]    ${cell_id}
    Update Parameter     param=actUlNrEcIdTAdv    value=false   distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}
    Update Parameter     param=actUlNrEcIdPosMethod    value=false   distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}
    Update Parameter     param=nrEcidMeasSupervisionTimer    value=3000

Ecid Counters Check
    counter desc
    &{counters_values}=     ccheck.Get Scell Add Counter Values    ${ecid_counter}    wait_for_interval=${FALSE}
    ccheck.Counter Incremented Successfully    M55113C00013    cell_id=1    counter_dict=counters_values    operator=>=
    ccheck.Counter Incremented Successfully    M55113C00014    cell_id=1    counter_dict=counters_values    operator=>=
    ccheck.Counter Incremented Successfully    M55125C00024    cell_id=1    counter_dict=counters_values    operator=>=
    ccheck.Counter Incremented Successfully    M55125C00025    cell_id=1    counter_dict=counters_values    operator=>=
    ccheck.Counter Incremented Successfully    M55113C00015    cell_id=1    counter_dict=counters_values    value=0
    ccheck.Counter Incremented Successfully    M55113C00016    cell_id=1    counter_dict=counters_values    value=0
    ccheck.Counter Incremented Successfully    M55113C00017    cell_id=1    counter_dict=counters_values    value=0
    ccheck.Counter Incremented Successfully    M55113C00018    cell_id=1    counter_dict=counters_values    value=0

Set Inactivity Timer
    Update Parameter     param=drbInactivityTimerSA    value=30
    Update Parameter     param=srbInactivityTimerSA    value=30

Set Off Inactivity Timer
    Update Parameter     param=drbInactivityTimerSA    value=600
    Update Parameter     param=srbInactivityTimerSA    value=600

Perform Nglink Shutdown
    keywords_cb008954.Block Target Cell   5
    keywords_cb008954.Block Target Cell   2
    keywords_cb008954.Block Target Cell   3
    keywords_cb008954.Block Target Cell   1

Restore Cells onair
    keywords_cb008954.Unblock Target Cell    5
    keywords_cb008954.Unblock Target Cell    2
    keywords_cb008954.Unblock Target Cell    3

Disable Nala
    Update Parameter    param=administrativeState    value=Locked    distname=MRBTS-50924/NRBTS-50924/SERVEDAMF-1

Enable Nala
    Update Parameter    param=administrativeState    value=Unlocked    distname=MRBTS-50924/NRBTS-50924/SERVEDAMF-1
