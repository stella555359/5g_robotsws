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
CBRS_LTE5703_FeVe_32_Grant_spectrum_reselection_caused_by_grant_suspension_with_no_frequency_guidance
    [Documentation]    Requirement:LTE5703, OM_GEN_SFS_CBRS.297
    [Timeout]    30min

    Kill All SAS Processes
    Set Test Variable    @{allowedGrantIds}    @{EMPTY}
    Append To List       ${allowedGrantIds}
    ...                  3550000000_3560000000
    ...                  3560000000_3570000000
    ...                  3570000000_3580000000
    ...                  3580000000_3590000000
    ...                  3600000000_3610000000
    ${enb_id}    Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}     Set Variable    RAT_1ST
    ${terminated_cell_number}   Set Variable    1
    ${expected_alarms}   Create List     SAS Grant Termination
    Wait Until BTS Is Not Busy
    Disable CBRS Feature On eNB
    Check If Cells Are Disabled    enb_id=${enb_id}
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    config=${CURDIR}/Data/FeVe32/SAS_Sim.conf
    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585    3600    3605
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
    Wait For All Cells To Be OnAir
    ${newCellGrantId}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=${terminated_cell_number}
    ${newGrantIds}   List Values of GrantId For All Cells    enb_id=${enb_id}    alias=RAT_1ST

    Check If Grant Of Suspended Cell Has Changed    old_grant_id=${oldCellGrantId}    new_grant_id=${newCellGrantId}
    Check If Grants Of Other Cell Remain Unchanged    old_grant_ids=${oldGrantIds}    new_grant_ids=${newGrantIds}
    ...    oldCellGrantId=${oldCellGrantId}    newCellGrantId=${newCellGrantId}
    Check If All Frequencies Are Within Allowed Range     grantIds=${newGrantIds}   allowedGrantIds=${allowedGrantIds}


    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Run Keyword And Continue On Failure    Save And Check Historical Alarms    expected_alarms=${expected_alarms}    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Kill All SAS Processes
