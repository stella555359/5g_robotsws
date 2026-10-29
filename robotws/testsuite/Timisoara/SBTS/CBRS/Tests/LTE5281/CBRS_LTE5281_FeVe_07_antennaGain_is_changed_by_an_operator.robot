*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Artur.Czainski@nokia.com
...    = Summary =
...    Purpose: Verify whether eNB correctly calculates the maxEirp after decrease of desiredPmax parameter while eNB is not providing
...    service on CBSD cells.
...    CBSD cells are brought up with new pMax.

*** Keywords ***
CBRS_LTE5281_FeVe_07_antennaGain_is_changed_by_an_operator
    [Documentation]    Requirement: OAM_REQ_CBRS_6;OM_GEN_SFS_CBRS.450;OM_GEN_SFS_CBRS.452

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    &{expected_alarm}   Create Dictionary    fault_id=6828    fault_name=SAS Grant Failure    severity=Critical
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarm}
    ${20Mhz_cell_present}   Check If 20MHz Cell Is Present    enb_id=${enb_id}
    ${AEQM_present}   Run Keyword And Return Status    Query Infomodel    timeout=30    alias=${alias}
    ...                 query=check /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-* is [productName=regex"(?i)AEQM"]

    IF  '${20Mhz_cell_present}'=='False' and '${AEQM_present}'=='False'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${20}    "CELL2"=${19}    "CELL3"=${18}    "CELL4"=${17}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='False'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${23}    "CELL2"=${22}    "CELL3"=${21}    "CELL4"=${20}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='True'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${23}    "CELL2"=${22}
    END

    Kill All SAS Processes

    IF  '${AEQM_present}'=='False'
        Start SAS Process    config=${CURDIR}/Data/FeVe07/SAS_Sim.conf
    ELSE
        Start SAS Process    config=${CURDIR}/Data/FeVe07/SAS_Sim_AEQM.conf
    END

    #precondition delta
    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    Wait Until BTS Is Not Busy
    IF  '${AEQM_present}'=='False'
        Wait Until Keyword Succeeds  5x  30s  Create generic delta and perform commissioning  enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe07/FEVE_7_Precond_delta_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe07/FEVE_7_Precond_delta.json
    ELSE
        Wait Until Keyword Succeeds  5x  30s  Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe07/FEVE_7_Precond_delta_AEQM_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe07/FEVE_7_Precond_delta_AEQM.json
    END
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    timeout=60

    #Step1  Check Availability Status of CBSD cells
    ute_admin_infomodel.Query InfoModel    query=check //LNBTS_M-1/CELL_M-1 is [stateInfo.operationalState=regex"(?i)Disabled"]
    ...                                    timeout=60    alias=${alias}
    ute_admin_infomodel.Query InfoModel    query=check //LNBTS_M-1/CELL_M-2 is [stateInfo.operationalState=regex"(?i)Disabled"]
    ...                                    timeout=60    alias=${alias}
    IF  '${AEQM_present}'=='False'
        ute_admin_infomodel.Query InfoModel    query=check //LNBTS_M-1/CELL_M-3 is [stateInfo.proceduralState=regex"(?i)OnAirDone"]
        ...  timeout=60    alias=${alias}
        ute_admin_infomodel.Query InfoModel    query=check //LNBTS_M-1/CELL_M-4 is [stateInfo.proceduralState=regex"(?i)OnAirDone"]
        ...  timeout=60    alias=${alias}
    END
    #step2. Upload delta with specific parameters:
    Wait Until BTS Is Not Busy
    Perform Parameter Recommissioning    dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/CBSD-1    parameter=antennaGain
    ...                                  operation=update    value=0    connection=${alias}

    #step3. Check for available alarms on eNB - alarms cleared
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    timeout=120
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]
    Wait For All Cells To Be OnAir

    #step4. Check if Cells are brought back onAir with new increased pMax
    ${pMax_values}   List pMax Values For All Cells    ${enb_id}
    Run Keyword And Continue On Failure    Compare pMax Values For All Cells    ${pMax_values}    ${pMax_postcondition}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Kill All SAS Processes
