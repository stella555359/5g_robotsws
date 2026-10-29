*** Settings ***
Documentation
...    = Author = Micha? Moska?a
...    michal.moskala@nokia.com
...    = Maintainer =
...
...    = Reviewer =
...
...    = Summary =
...    Purpose: Verify whether eNB correctly calculates the maxEirp after decrease of desiredPmax parameter
...    while eNB is providing service on CBSD cells. CBSD celld are brought up with new pMax.

*** Keywords ***
CBRS_LTE5281_FeVe_02_desiredPmax_is_decreased_by_an_operator_while_providing_service
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.324
    [Timeout]    30min

    @{allowed_faults}     Set Variable    ${enb_allowed_faults}

    ${release_version}       Get Active Release Version
    ${enb_id}    Set Variable    ${testlines.${testline_id}.enb_id}

    ${20Mhz_cell_present}   Check If 20MHz Cell Is Present    enb_id=${enb_id}
    ${AEQM_present}         Run Keyword And Return Status    Query Infomodel
    ...                       query=check /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-* is [productName=regex"(?i)AEQM"]
    ...                       timeout=30
    ...                       alias=RAT_1ST

    IF  '${20Mhz_cell_present}'=='False' and '${AEQM_present}'=='False'
        ${pMax_precondition}  Create Dictionary    "CELL1"=${20}    "CELL2"=${20}    "CELL3"=${19}    "CELL4"=${19}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='False'
        ${pMax_precondition}  Create Dictionary    "CELL1"=${23}    "CELL2"=${23}    "CELL3"=${22}    "CELL4"=${22}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='True'
        ${pMax_precondition}  Create Dictionary    "CELL1"=${23}    "CELL2"=${23}
    END

    IF  '${20Mhz_cell_present}'=='False' and '${AEQM_present}'=='False'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${19}    "CELL2"=${19}    "CELL3"=${18}    "CELL4"=${18}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='False'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${22}    "CELL2"=${22}    "CELL3"=${21}    "CELL4"=${21}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='True'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${22}    "CELL2"=${22}
    END


    Kill All SAS Processes
    IF  '${AEQM_present}'=='False'
        ${sas_pid}    ${sas_logs_dir}  Start SAS Process  default  4433  config=${CURDIR}/Data/FeVe02/SAS_Sim.conf
    ELSE
        ${sas_pid}    ${sas_logs_dir}  Start SAS Process  default  4433  config=${CURDIR}/Data/FeVe02/SAS_Sim_AEQM.conf
    END
    #Upload precondition delta
    Wait For All Cells To Be OnAir
    ${cbsd_id}   Fetch CBSD ID    ${enb_id}

    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    Wait Until BTS Is Not Busy
    IF  '${AEQM_present}'=='False'
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe02/FEVE_2_Precond_delta_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe02/FEVE_2_Precond_delta.json
    ELSE
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe02/FEVE_2_Precond_delta_AEQM_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe02/FEVE_2_Precond_delta_AEQM.json
    END
    Wait For Any Cell To Be Dropped
    Wait For All Cells To Be OnAir
    Start Tracking Historical Alarms
    #Step 1 Check current pMax value for CBSD cells
    ${pMax_values}   List pMax Values For All Cells    ${enb_id}
    Compare pMax Values For All Cells    ${pMax_values}    ${pMax_precondition}

    #Step 2. Upload delta with specific parameters:
    Wait Until BTS Is Not Busy
    ${time_start}    Get Time

    IF  '${AEQM_present}'=='False'
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe02/FEVE_2_Test_delta_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe02/FEVE_2_Test_delta.json
    ELSE
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe02/FEVE_2_Test_delta_AEQM_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe02/FEVE_2_Test_delta_AEQM.json
    END

    #Step 3 Check if cells are temporarily disabled
    Check If Cells Are Temporarily Disabled and Recovered    enb_id=${enb_id}

    ${time_stop}    Get Time

    ${pMax_values}  List pMax Values For All Cells    ${enb_id}
    Compare pMax Values For All Cells    ${pMax_values}    ${pMax_postcondition}

    #Alarm checks
    ${active_faults}   List Active eNB Faults
    Check For Unwanted Faults     allowed_faults=@{allowed_faults}    active_alarm_list=${active_faults}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Kill All SAS Processes    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Check Historical Alarms And Teardown Tracking Session

