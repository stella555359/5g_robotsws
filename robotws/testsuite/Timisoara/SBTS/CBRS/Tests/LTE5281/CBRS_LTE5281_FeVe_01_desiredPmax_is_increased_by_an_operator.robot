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
...    is not providing service on CBSD cells.
...    CBSD cells are brought up with new pMax.

*** Keywords ***
CBRS_LTE5281_FeVe_01_desiredPmax_is_increased_by_an_operator
    [Documentation]    Requirement: OM_LTE_SFS_RNL.21877

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${20Mhz_cell_present}   Check If 20MHz Cell Is Present    enb_id=${enb_id}
    ${AEQM_present}   Run Keyword And Return Status    Query Infomodel    timeout=30    alias=RAT_1ST
    ...                 query=check /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-* is [productName=regex"(?i)AEQM"]

    IF  '${20Mhz_cell_present}'=='False' and '${AEQM_present}'=='False'
        ${pMax_precondition}  Create Dictionary    "CELL1"=${17}    "CELL2"=${18}    "CELL3"=${19}    "CELL4"=${20}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='False'
        ${pMax_precondition}  Create Dictionary    "CELL1"=${20}    "CELL2"=${21}    "CELL3"=${22}    "CELL4"=${23}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='True'
        ${pMax_precondition}  Create Dictionary    "CELL1"=${20}    "CELL2"=${21}
    END

    IF  '${20Mhz_cell_present}'=='False' and '${AEQM_present}'=='False'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${18}    "CELL2"=${19}    "CELL3"=${20}    "CELL4"=${21}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='False'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${21}    "CELL2"=${22}    "CELL3"=${23}    "CELL4"=${24}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='True'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${21}    "CELL2"=${22}
    END

    Kill All SAS Processes
    Enable CBRS Feature On eNB
    IF  '${AEQM_present}'=='False'
        ${sas_pid}    ${sas_logs_dir}  Start SAS Process    config=${CURDIR}/Data/FeVe01/SAS_Sim.conf
    ELSE
        ${sas_pid}    ${sas_logs_dir}  Start SAS Process    config=${CURDIR}/Data/FeVe01/SAS_Sim_AEQM.conf
    END
    #Upload precondition delta
    Wait For All Cells To Be OnAir

    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}
    Wait For All Cells To Be OnAir

    IF  '${AEQM_present}'=='False'
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe01/FEVE_1_Precond_delta_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe01/FEVE_1_Precond_delta.json
    ELSE
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe01/FEVE_1_Precond_delta_AEQM_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe01/FEVE_1_Precond_delta_AEQM.json
    END
    Wait For Any Cell To Be Dropped
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection

    #Step 1 Check current pMax value for CBSD cells
    ${pMax_values}   List pMax Values For All Cells    ${enb_id}
    Compare pMax Values For All Cells    ${pMax_values}    ${pMax_precondition}

    #Step 2. Upload delta with specific parameters:
    Wait Until BTS Is Not Busy
    ${time_start}   Get Time
    IF  '${AEQM_present}'=='False'
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe01/FEVE_1_Test_delta_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe01/FEVE_1_Test_delta.json
    ELSE
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe01/FEVE_1_Test_delta_AEQM_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe01/FEVE_1_Test_delta_AEQM.json
    END

    #Step 3 Check if cells are temporarily disabled
    Check If Cells Are Temporarily Disabled and Recovered    enb_id=${enb_id}
    ${time_stop}   Get Time

    #Step 4.Check if previous Grants are relinquished
    ${grantId_list}   List Values of GrantId For All Cells    ${enb_id}
    Verify Grant Relinquishment Procedure    ${time_start}    ${time_stop}    sas_log_path=${sas_logs_dir}    grantId_list=${grantId_list}

    #Step 5. Check if Cells are brought back onAir with new increased pMax
    ${pMax_values}   List pMax Values For All Cells    ${enb_id}
    Compare pMax Values For All Cells    ${pMax_values}    ${pMax_postcondition}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Kill All SAS Processes
