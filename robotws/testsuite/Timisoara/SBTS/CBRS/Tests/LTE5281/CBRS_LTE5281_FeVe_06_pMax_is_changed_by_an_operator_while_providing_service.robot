*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Artur.Czainski@nokia.com
...    = Summary =
...    Purpose: Verify whether reverts the value of pMax to the old value regardless of what is set by the operator

*** Keywords ***
CBRS_LTE5281_FeVe_06_pMax_is_changed_by_an_operator_while_providing_service
    [Documentation]    Requirement: OM_LTE_SFS_RNL.22076

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${20Mhz_cell_present}   Check If 20MHz Cell Is Present    enb_id=${enb_id}
    ${AEQM_present}   Run Keyword And Return Status    Query Infomodel    timeout=30    alias=RAT_1ST
    ...                 query=check /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-* is [productName=regex"(?i)AEQM"]

    IF  '${20Mhz_cell_present}'=='False' and '${AEQM_present}'=='False'
        ${pMax_set_by_sas}  Create Dictionary    "CELL1"=${17}    "CELL2"=${17}    "CELL3"=${18}    "CELL4"=${18}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='False'
        ${pMax_set_by_sas}  Create Dictionary    "CELL1"=${20}    "CELL2"=${20}    "CELL3"=${21}    "CELL4"=${21}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='True'
        ${pMax_set_by_sas}  Create Dictionary    "CELL1"=${20}    "CELL2"=${20}
    END

    IF  '${20Mhz_cell_present}'=='False' and '${AEQM_present}'=='False'
        ${pMax_set_by_operator}  Create Dictionary    "CELL1"=${21}    "CELL2"=${22}    "CELL3"=${23}    "CELL4"=${24}
    ELSE IF           '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='False'
        ${pMax_set_by_operator}  Create Dictionary    "CELL1"=${21}    "CELL2"=${22}    "CELL3"=${23}    "CELL4"=${24}
    ELSE IF           '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='True'
        ${pMax_set_by_operator}  Create Dictionary    "CELL1"=${21}    "CELL2"=${22}
    END

    Kill All SAS Processes
    IF  '${AEQM_present}'=='False'
        Start SAS Process    config=${CURDIR}/Data/FeVe06/SAS_Sim.conf
    ELSE
        Start SAS Process    config=${CURDIR}/Data/FeVe06/SAS_Sim_AEQM.conf
    END

    Wait For All Cells To Be OnAir
    ${cbsd_id}   Fetch CBSD ID    ${enb_id}

    #Upload precondition delta
    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    Wait For All Cells To Be OnAir
    Wait Until BTS Is Not Busy

    IF  '${AEQM_present}'=='False'
        Create generic delta and perform commissioning  enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe06/FEVE_6_Precond_delta_tmp.json  delta_file_final=${CURDIR}/Data/FeVe06/FEVE_6_Precond_delta.json
    ELSE
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe06/FEVE_6_Precond_delta_AEQM_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe06/FEVE_6_Precond_delta_AEQM.json
    END

    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection

    #Step 1 Check current pMax value for CBSD cells
    ${pMax_values}   List pMax Values For All Cells    ${enb_id}
    Compare pMax Values For All Cells    ${pMax_values}    ${pMax_set_by_sas}

    #Step 2. Upload delta with specific parameters:
    Wait Until BTS Is Not Busy

    IF  '${AEQM_present}'=='False'
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe06/FEVE_6_Test_delta_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe06/FEVE_6_Test_delta.json
    ELSE
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe06/FEVE_6_Test_delta_AEQM_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe06/FEVE_6_Test_delta_AEQM.json
    END

    #Step 3 Check if cells are temporarily disabled
    Check If Cells Are Disabled    enb_id=${enb_id}

    #Step 4 Check new value of pMax after operator modification
    Wait Until Keyword Succeeds    60x    2s    Check If pMax Change Is Reflected On eNB
    ...                                         enb_id=${enb_id}    template_values=${pMax_set_by_operator}
    Watchdog Check For Failures

    #Step 5 Check if Cells are brought back onAir with pMax reverted to the old value
    Wait For All Cells To Be OnAir
    Wait Until Keyword Succeeds    60x    2s    Check If pMax Change Is Reflected On eNB
    ...                                         enb_id=${enb_id}    template_values=${pMax_set_by_sas}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Kill All SAS Processes
