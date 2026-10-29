*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Artur.Czainski@nokia.com
...    = Summary =
...    Purpose: Verify whether eNB correctly calculates the maxEirp after decrease of maxGrantPwrRed parameter
...    in conditions of providing service. This scenario covers OM_LTE_SFS_RNL.22051 – subcase where transmit power
...    of the cell(s) is not lower than desiredPmax - new maxGranPwrRed. This scenario assumes that new value of maxGrantPwrRed
...    is above the threshold where maxEirp is lower than minimal tolerant value – hence the service should be uninterrupted.

*** Keywords ***
CBRS_LTE5281_FeVe_05_maxGrantPwrRed_is_decreased_by_an_operator_while_providing_service
    [Documentation]  Requirement: OM_LTE_SFS_RNL.22051
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
        ${pMax_precondition}  Create Dictionary    "CELL1"=${17}    "CELL2"=${17}    "CELL3"=${18}    "CELL4"=${19}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='False'
        ${pMax_precondition}  Create Dictionary    "CELL1"=${20}    "CELL2"=${20}    "CELL3"=${21}    "CELL4"=${21.9}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='True'
        ${pMax_precondition}  Create Dictionary    "CELL1"=${20}    "CELL2"=${20}
    END

    IF  '${20Mhz_cell_present}'=='False' and '${AEQM_present}'=='False'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${17}    "CELL2"=${17}    "CELL3"=${18}    "CELL4"=${19}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='False'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${20}    "CELL2"=${20}    "CELL3"=${21}    "CELL4"=${21.9}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='True'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${20}    "CELL2"=${20}
    END

    Kill All SAS Processes

    IF  '${AEQM_present}'=='False'
        ${sas_pid}    ${sas_logs_dir}  Start SAS Process  default  4433  config=${CURDIR}/Data/FeVe05/SAS_Sim.conf
    ELSE
        ${sas_pid}    ${sas_logs_dir}  Start SAS Process  default  4433  config=${CURDIR}/Data/FeVe05/SAS_Sim_AEQM.conf
    END

    Wait For All Cells To Be OnAir
    ${cbsd_id}   Fetch CBSD ID    ${enb_id}
    Start Capturing Historical Alarms

    #Upload precondition delta
    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    Wait Until BTS Is Not Busy
    IF  '${AEQM_present}'=='False'
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe05/FEVE_5_Precond_delta_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe05/FEVE_5_Precond_delta.json
    ELSE
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe05/FEVE_5_Precond_delta_AEQM_tmp.json
        ...   delta_file_final=${CURDIR}/Data/FeVe05/FEVE_5_Precond_delta_AEQM.json
    END
    Wait For All Cells To Be OnAir

    #Step 1. Check current pMax values
    ${pMax_values}  List pMax Values For All Cells    ${enb_id}
    Compare pMax Values For All Cells    ${pMax_values}    ${pMax_precondition}

    #Step 2. Upload delta with specific parameters:
    Wait Until BTS Is Not Busy

    IF  '${AEQM_present}'=='False'
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe05/FEVE_5_Test_delta_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe05/FEVE_5_Test_delta.json
    ELSE
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe05/FEVE_5_Test_delta_AEQM_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe05/FEVE_5_Test_delta_AEQM.json
    END
    #Step 3 Check if all CBSD Cells remain onAir with unchanged pMax

    ${pMax_values}  List pMax Values For All Cells    ${enb_id}
    Compare pMax Values For All Cells    ${pMax_values}    ${pMax_postcondition}

    #Alarm checks
    ${active_faults}   List Active eNB Faults
    Check For Unwanted Faults     allowed_faults=@{allowed_faults}    active_alarm_list=${active_faults}

    [Teardown]    Run Keywords    Sleep    120s              AND
    ...                           Save And Check Historical Alarms    AND
    ...                           Collect Snapshot    target_file_name=${TEST_LOGS_DIR_PATH}/snapshot_RAT_1ST.zip    connection=RAT_1ST      AND
    ...                           Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Kill All SAS Processes
