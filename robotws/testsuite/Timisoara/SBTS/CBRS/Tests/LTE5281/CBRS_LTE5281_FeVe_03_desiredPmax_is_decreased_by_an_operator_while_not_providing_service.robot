*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Artur.Czainski@nokia.com
...    = Summary =
...    Purpose: Verify whether eNB correctly calculates the maxEirp after decrease of desiredPmax parameter while eNB
...    is not providing service on CBSD cells. CBSD cells are brought up with new pMax.

*** Keywords ***
CBRS_LTE5281_FeVe_03_desiredPmax_is_decreased_by_an_operator_while_not_providing_service
    [Documentation]  Requirement: OM_LTE_SFS_RNL.21937

    &{expected_alarm}   Create Dictionary    fault_id=6828    fault_name=SAS Grant Failure    severity=Critical
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarm}

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${20Mhz_cell_present}   Check If 20MHz Cell Is Present    enb_id=${enb_id}
    ${AEQM_present}   Run Keyword And Return Status    Query Infomodel    timeout=30    alias=RAT_1ST
    ...                 query=check /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-* is [productName=regex"(?i)AEQM"]

    IF  '${20Mhz_cell_present}'=='False' and '${AEQM_present}'=='False'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${20}    "CELL2"=${19}    "CELL3"=${18}    "CELL4"=${17}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='False'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${23}    "CELL2"=${22}    "CELL3"=${21}    "CELL4"=${20}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='True'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${17.9}    "CELL2"=${17.9}    "CELL3"=${17.9}    "CELL4"=${17.9}
    ELSE IF  '${20Mhz_cell_present}'=='False' and '${AEQM_present}'=='True'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${14.9}    "CELL2"=${14.9}    "CELL3"=${14.9}    "CELL4"=${14.9}
    END
    #Set supportedSpectrumV2 based on configuration
    IF  '${AEQM_present}'=='True'
        ${required_spectrum}  Create List    3550    3555    3560    3565    3570    3575    3580    3585
        ...  3590    3595    3600    3605    3610    3615    3620    3625
    ELSE
        ${required_spectrum}  Create List    3550    3555    3560    3565    3570    3575    3580    3585
    END
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    Kill All SAS Processes
    Enable CBRS Feature On eNB
    IF  '${AEQM_present}'=='False'
        Start SAS Process  config=${CURDIR}/Data/FeVe03/SAS_Sim.conf
    ELSE
        Start SAS Process    config=${CURDIR}/Data/FeVe03/SAS_Sim_AEQM.conf
    END

    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    #Upload precondition delta
    Wait Until BTS Is Not Busy

    IF  '${AEQM_present}'=='True'
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe03/FEVE_3_Precond_delta_eCPRI_AEQM_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe03/FEVE_3_Precond_delta_eCPRI_AEQM.json
    ELSE
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe03/FEVE_3_Precond_delta_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe03/FEVE_3_Precond_delta.json
    END
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    timeout=180

    #Step 1. Check if all CBSD cells are disabled
    Check If Cells Are Disabled    enb_id=${enb_id}    timeout=720s
    Wait Until All Cells Reach State    enb_id=${enb_id}    state=operationalState    state_value=Disabled

    #Step 2. Upload delta with specific parameters:
    Wait Until BTS Is Not Busy
    ${time_start}   Get Time

    IF  '${AEQM_present}'=='True'
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe03/FEVE_3_Test_delta_eCPRI_AEQM_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe03/FEVE_3_Test_delta_eCPRI_AEQM.json
    ELSE
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe03/FEVE_3_Test_delta_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe03/FEVE_3_Test_delta.json
    END
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    timeout=60
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]
    ${time_stop}   Get Time

    #Step 4. Check if Cells are brought onAir with desired pMax values
    Wait For All Cells To Be OnAir
    ${pMax_values}   List pMax Values For All Cells    ${enb_id}
    Compare pMax Values For All Cells    ${pMax_values}    ${pMax_postcondition}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Kill All SAS Processes
