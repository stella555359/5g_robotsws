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
...    This test checks if eNB chooses frequencies according to supported spectrum.
...    There are 5 channels available, after which 2 are taken away

*** Keywords ***
CBRS_LTE5703_FeVe_33_Grant_spectrum_reselection_caused_by_grant_termination_with_frequency_guidance
    [Documentation]    Requirement:LTE5703, OM_GEN_SFS_CBRS.297

    Kill All SAS Processes
    Set Test Variable    @{allowedGrantIds}    @{EMPTY}
    Append To List    ${allowedGrantIds}    3550000000_3560000000    3560000000_3570000000    3570000000_3580000000    3580000000_3590000000
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    ${terminated_cell_number}   Set Variable    1
    ${required_new_grant_id}   Set Variable    3620000000_3630000000
    &{expected_alarm}   Create Dictionary    fault_id=6825    fault_name=SAS Grant Suspension Failure    severity=Critical
    ...                                        reason=responseCode : 501 transmitExpireTime expires.
    ${expected_alarms_objects}   Create Watchdog Alarm List     ${expected_alarm}
    Wait Until BTS Is Not Busy
    Disable CBRS Feature On eNB
    Check If Cells Are Disabled    enb_id=${enb_id}
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    config=${CURDIR}/Data/FeVe33/SAS_Sim.conf
    Restore Supported Spectrum    bts_id=${enb_id}
    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    ${cbsd_id}   Fetch CBSD ID    enb_id=${enb_id}
    ${oldCellGrantId}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=${terminated_cell_number}
    ${oldGrantIds}   List Values of GrantId For All Cells    enb_id=${enb_id}    alias=${alias}
    ute_admin_infomodel.Query Infomodel
    ...    query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/CBRSPR_R-* is [wINNFTSVersion="2.0"]
    ...    timeout=360
    ...    alias=${alias}
    ${TS_Version_CBSD}   Get WInnForum TS Version From Infomodel    alias=${alias}
    Should be Equal    ${TS_Version_CBSD}    2.0
    Check If All Frequencies Are Within Allowed Range    grantIds=${oldGrantIds}    allowedGrantIds=${allowedGrantIds}
    Send Command To SAS Manager    alias=default    command=grant_suspend ${cbsdId} ${oldCellGrantId}
    Wait For Any Cell To Be Dropped    wait_time=5min
    Wait For All Cells To Be OnAir
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]
    ${newCellGrantId}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=${terminated_cell_number}
    ${newGrantIds}   List Values of GrantId For All Cells    enb_id=${enb_id}    alias=${alias}

    Check If Grant Of Terminated Cell Has Changed    old_grant_id=${oldCellGrantId}    new_grant_id=${newCellGrantId}
    ...    required_new_grant_id=${required_new_grant_id}
    Check If Grants Of Other Cell Remain Unchanged    old_grant_ids=${oldGrantIds}    new_grant_ids=${newGrantIds}
    ...    oldCellGrantId=${oldCellGrantId}    newCellGrantId=${newCellGrantId}

    [Teardown]    Run Keywords
    ...           Get SAS Logs To Logs Dir    alias=default    AND
    ...           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...           Kill All SAS Processes
