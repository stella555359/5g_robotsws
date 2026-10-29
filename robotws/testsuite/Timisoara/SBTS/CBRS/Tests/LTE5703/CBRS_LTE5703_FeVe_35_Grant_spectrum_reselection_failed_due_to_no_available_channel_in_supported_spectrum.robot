*** Settings ***
Documentation
...    = Author =
...    michal.moskala@nokia.com
...    = Maintainer =
...    michal.moskala@nokia.com
...    = Reviewer =
...    artur.czainski@nokia.com
...    = Summary =
...    The purpose of this test is to verify whether grant spectrum reselection procedure fullfills requirements
...    stated by WInnForum Technical Specification version 2.0. This scenario tests if the system can manage the case
...    correctly if one grant was taken away due to grant termination if there are no more available frequencies.
...    The frequencies are supposed to be chosen based on supported spectrum

*** Keywords ***
CBRS_LTE5703_FeVe_35_Grant_spectrum_reselection_failed_due_to_no_available_channel_in_supported_spectrum
    [Documentation]    Requirement:LTE5703, OM_GEN_SFS_CBRS.297
    [Timeout]    30min

    Kill All SAS Processes
    Set Test Variable    @{allowedGrantIds}    @{EMPTY}
    Append To List       ${allowedGrantIds}
    ...                  3550000000_3560000000
    ...                  3560000000_3570000000
    ...                  3570000000_3580000000
    ...                  3580000000_3590000000
    ${expected_alarms}   Create List     SAS Grant Termination    SAS Grant Failure
    ${enb_id}    Set Variable    ${testlines.${testline_id}.enb_id}
    ${enabled_cells_list}   List Phycell Values For All Cells     enb_id=${enb_id}
    ${alias}     Set Variable    RAT_1ST
    ${terminated_cell_number}   Get Random Cell Number    cells_list=${enabled_cells_list}
    Remove Values From List    ${enabled_cells_list}    ${terminated_cell_number}
    ${ca_status}   Run Keyword And Return Status    Query Infomodel   alias=${alias}
    ...    query=check /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id} is [actDLCAggr=true]

    Wait Until BTS Is Not Busy
    Disable CBRS Feature On eNB
    Check If Cells Are Disabled    enb_id=${enb_id}
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    config=${CURDIR}/Data/FeVe35/SAS_Sim.conf
    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}
    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    Wait For All Cells To Be OnAir
    Start Capturing Historical Alarms

    ${cbsd_id}   Fetch CBSD ID    enb_id=${enb_id}
    ${oldCellGrantId}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=${terminated_cell_number}
    ${oldGrantIds}   List Values of GrantId For All Cells    enb_id=${enb_id}    alias=RAT_1ST
    ute_admin_infomodel.Query Infomodel
    ...                    query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/CBRSPR_R-* is [wINNFTSVersion="2.0"]
    ...                    timeout=360
    ...                    alias=${alias}
    ${TS_Version_CBSD}   Get WInnForum TS Version From Infomodel    alias=${alias}
    Should be Equal        ${TS_Version_CBSD}   2.0
    Check If All Frequencies Are Within Allowed Range    grantIds=${oldGrantIds}   allowedGrantIds=${allowedGrantIds}
    Terminate Grant And Confirm Cell Drop    cbsd_id=${cbsdId}    grant_id=${oldCellGrantId}

    IF  '${ca_status}'=='True'
        Sleep and display progress    300    sec
    ELSE
        Check If Only Terminated Cell is Disabled 35
        ...     terminated_cell_number=${terminated_cell_number}    enabled_cells_list=${enabled_cells_list}    alias=${alias}
    END

    #KW is repeated to continously check if cells have not dropped for about 5 min.
#    Repeat Keyword    25    Check If Only One Cell Is Disabled And Other Remain Enabled    alias=${alias}
#    ...    terminated_cell_number=${terminated_cell_number}    enabled_cells_list=${enabled_cells_list}

    ${newCellGrantId}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=${terminated_cell_number}
    ${newGrantIds}   List Values of GrantId For All Cells    enb_id=${enb_id}    alias=RAT_1ST

    Check If Grants Of Other Cell Remain Unchanged    old_grant_ids=${oldGrantIds}    new_grant_ids=${newGrantIds}
    ...    oldCellGrantId=${oldCellGrantId}    newCellGrantId=${newCellGrantId}

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Run Keyword And Continue On Failure    Save And Check Historical Alarms    expected_alarms=${expected_alarms}    AND
    ...    Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...    Kill All SAS Processes

Check If Only Terminated Cell is Disabled 35
    [Arguments]    ${terminated_cell_number}    ${enabled_cells_list}    ${alias}
    Repeat Keyword    25    Check If Only One Cell Is Disabled And Other Remain Enabled    alias=${alias}
    ...    terminated_cell_number=${terminated_cell_number}    enabled_cells_list=${enabled_cells_list}
