*** Settings ***
Documentation
...    = Author =
...    michal.moskala@nokia.com
...    = Maintainer =
...    michal.moskala@nokia.com
...    = Reviewer =
...    karol.palamarz@nokia.com
...    artur.czainski@nokia.com
...    lukasz.lechowicz@nokia.com
...    = Summary =
...    The purpose of this test is to verify whether grant spectrum reselection procedure fullfills requirements
...    stated by WInnForum Technical Specification version 2.0. This scenario tests if the system can manage the case
...    correctly if one grant was taken away due to grant termination if there are no more available frequencies.
...    The frequencies are supposed to be chosen based on frequency guidance.

*** Keywords ***
CBRS_LTE5703_FeVe_34_Grant_spectrum_reselection_failed_due_to_no_available_channel_in_frequency_guidance
    [Documentation]    Requirement:LTE5703, OM_GEN_SFS_CBRS.297

    Kill All SAS Processes
    Set Test Variable    @{allowedGrantIds}    @{EMPTY}
    Append To List    ${allowedGrantIds}    3550000000_3560000000    3560000000_3570000000    3570000000_3580000000    3580000000_3590000000
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    &{expected_alarm_1}   Create Dictionary    fault_id=6823    fault_name=SAS Grant Termination Revocation Failure    severity=Critical
    ...                                          reason=Heartbeat Exception with Reason: 500.
    &{expected_alarm_2}   Create Dictionary    fault_id=6828    fault_name=SAS Grant Failure    severity=Critical
    ...                                          reason=No available frequency.
    ${expected_alarms_list}   Create List    ${expected_alarm_1}    ${expected_alarm_2}
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarms_list}
    ${enabled_cells_list}   List Phycell Values For All Cells    enb_id=${enb_id}
    ${alias}   Set Variable    RAT_1ST
    ${terminated_cell_number}   Get Random Cell Number    cells_list=${enabled_cells_list}
    Remove Values From List    ${enabled_cells_list}    ${terminated_cell_number}
    ${ca_status}   Run Keyword And Return Status    Query Infomodel    alias=${alias}
    ...    query=check /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id} is [actDLCAggr=true]

    Wait Until BTS Is Not Busy
    Disable CBRS Feature On eNB
    Check If Cells Are Disabled    enb_id=${enb_id}
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    config=${CURDIR}/Data/FeVe34/SAS_Sim.conf
    Restore Supported Spectrum    bts_id=${enb_id}
    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    ${cbsd_id}   Fetch CBSD ID    enb_id=${enb_id}
    ${oldCellGrantId}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=${terminated_cell_number}
    ${oldGrantIds}   List Values of GrantId For All Cells    enb_id=${enb_id}    alias=${alias}
    ute_admin_infomodel.Query Infomodel
    ...                    query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/CBRSPR_R-* is [wINNFTSVersion="2.0"]
    ...                    timeout=360
    ...                    alias=${alias}
    ${TS_Version_CBSD}   Get WInnForum TS Version From Infomodel    alias=${alias}
    Should be Equal    ${TS_Version_CBSD}    2.0
    Check If All Frequencies Are Within Allowed Range    grantIds=${oldGrantIds}    allowedGrantIds=${allowedGrantIds}
    Terminate Grant And Confirm Cell Drop    cbsd_id=${cbsdId}    grant_id=${oldCellGrantId}
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                   severity=${expected_alarm_1}[severity]    reason=${expected_alarm_1}[reason]    timeout=60
    IF  '${ca_status}'=='False'    Check If Only Terminated Cell is Disabled 34
    ...    terminated_cell_number=${terminated_cell_number}    enabled_cells_list=${enabled_cells_list}    alias=${alias}
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                     severity=${expected_alarm_1}[severity]    reason=${expected_alarm_1}[reason]    timeout=120
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                        severity=${expected_alarm_1}[severity]    reason=${expected_alarm_1}[reason]
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                   severity=${expected_alarm_2}[severity]    reason=${expected_alarm_2}[reason]    timeout=60

    ${newCellGrantId}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=${terminated_cell_number}
    ${newGrantIds}   List Values of GrantId For All Cells    enb_id=${enb_id}    alias=${alias}

    Check If Grants Of Other Cell Remain Unchanged    old_grant_ids=${oldGrantIds}    new_grant_ids=${newGrantIds}
    ...                                               oldCellGrantId=${oldCellGrantId}    newCellGrantId=${newCellGrantId}

    [Teardown]    Run Keywords
    ...           Get SAS Logs To Logs Dir    alias=default    AND
    ...           Stop Watchdog Alarm Detection And Check For Failures    AND
	...			  BuiltIn.Sleep    50sec    AND
    ...           Reset Site    connection=${alias}    AND
    ...           Kill All SAS Processes    AND
    ...           Check If Cells Are Disabled    enb_id=${enb_id}

Check If Only Terminated Cell is Disabled 34
    [Arguments]    ${terminated_cell_number}    ${enabled_cells_list}    ${alias}
    Repeat Keyword    25    Check If Only One Cell Is Disabled And Other Remain Enabled    alias=${alias}
    ...    terminated_cell_number=${terminated_cell_number}    enabled_cells_list=${enabled_cells_list}
