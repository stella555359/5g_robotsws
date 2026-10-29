*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Artur.Czainski@nokia.com
...    = Summary =
...    Purpose: Verify whether eNB correctly calculates the maxEirp after increase of maxGrantPwrRed parameter in conditions of not providing service.
...    CBSD cells are brought up with new pMax

*** Keywords ***
CBRS_LTE5281_FeVe_04_maxGrantPwrRed_is_increased_by_an_operator_while_not_providing_service
    [Documentation]  Requirement: OM_LTE_SFS_RNL.22050
    [Timeout]    30min

    @{allowed_faults}     Set Variable    ${enb_allowed_faults}

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${ims_alias}   Set Variable    RAT_1ST
    Wait Until BTS Is Not Busy
    ${expected_alarms}   Create List    SAS Grant Failure
    ${release_version}       Get Active Release Version

    ${20Mhz_cell_present}   Check If 20MHz Cell Is Present    enb_id=${enb_id}
    ${AEQM_present}         Run Keyword And Return Status    Query Infomodel
    ...                       query=check /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-* is [productName=regex"(?i)AEQM"]
    ...                       timeout=30
    ...                       alias=RAT_1ST
    ${eCPRI_present}   Run Keyword And Return Status    Query Infomodel
    ...                  query=check /MRBTS-*/RAT-*/BTS_L-*/HWTOP_L-*/CABLNK_L-* is [cablinkType=regex"(?i)ECPRILink"]
    ...                  timeout=30
    ...                  alias=RAT_1ST

    IF  '${20Mhz_cell_present}'=='False' and '${AEQM_present}'=='False'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${21.9}   "CELL2"=${21.9}    "CELL3"=${21.9}    "CELL4"=${21.9}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='False'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${21.9}   "CELL2"=${21.9}    "CELL3"=${21.9}    "CELL4"=${21.9}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='True' and '${eCPRI_present}'=='False'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${20.9}   "CELL2"=${20.9}
    ELSE IF  '${20Mhz_cell_present}'=='False' and '${AEQM_present}'=='True' and '${eCPRI_present}'=='True'
        ${pMax_postcondition}  Create Dictionary    "CELL1"=${14.9}    "CELL2"=${14.9}
    END

    #Set supportedSpectrumV2 based on configuration
    ${required_spectrum}         Create List    3550    3555    3560    3565    3570    3575    3580    3585
    ${required_spectrum_ecpri}   Create List    3570    3575    3580    3585
    IF  ${eCPRI_present}
        Set Supported Spectrum  bts_id=${enb_id}  target_spectrum_list=${required_spectrum_ecpri}
    ELSE
        Set Supported Spectrum  bts_id=${enb_id}  target_spectrum_list=${required_spectrum}
    END

    Kill All SAS Processes
    Enable CBRS Feature On eNB
    IF  '${AEQM_present}'=='False'
        Start SAS Process  default  4433  config=${CURDIR}/Data/FeVe04/SAS_Sim.conf
    ELSE
        Start SAS Process  default  4433  config=${CURDIR}/Data/FeVe04/SAS_Sim_AEQM.conf
    END
    Wait For All Cells To Be OnAir
    ${cbsd_id}   Fetch CBSD ID    ${enb_id}

    Start Capturing Historical Alarms
    #Upload precondition delta

    Wait Until BTS Is Not Busy
    IF  '${AEQM_present}'=='True' and '${eCPRI_present}'=='True'
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe04/FEVE_4_Precond_delta_eCPRI_AEQM_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe04/FEVE_4_Precond_delta_eCPRI_AEQM.json
    ELSE IF  '${AEQM_present}'=='True' and '${eCPRI_present}'=='False'
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe04/FEVE_4_Precond_delta_AEQM_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe04/FEVE_4_Precond_delta_AEQM.json
    ELSE IF  '${AEQM_present}'=='False' and '${eCPRI_present}'=='False'
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe04/FEVE_4_Precond_delta_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe04/FEVE_4_Precond_delta.json
    END

    #step 1. Check if all CBSD cells are disabled
    Check If Cells Are Disabled    enb_id=${enb_id}
    Wait Until All Cells Reach State     enb_id=${enb_id}   state=operationalState    state_value=Disabled
    Sleep  60s  #purpose: to make sure eNB is ready for recommissioning

    #Step 2. Upload delta with specific parameters:
    Wait Until BTS Is Not Busy
    ${time_start}    Get Time

    IF  '${AEQM_present}'=='True' and '${eCPRI_present}'=='True'
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe04/FEVE_4_Test_delta_eCPRI_AEQM_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe04/FEVE_4_Test_delta_eCPRI_AEQM.json
    ELSE IF  '${AEQM_present}'=='True' and '${eCPRI_present}'=='False'
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe04/FEVE_4_Test_delta_AEQM_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe04/FEVE_4_Test_delta_AEQM.json
    ELSE IF  '${AEQM_present}'=='False' and '${eCPRI_present}'=='False'
        Create generic delta and perform commissioning    enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe04/FEVE_4_Test_delta_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe04/FEVE_4_Test_delta.json
    END

    #Step 3 Check if cells are temporarily disabled
    Check If Cells Are Temporarily Disabled and Recovered    enb_id=${enb_id}
    ${time_stop}    Get Time

    #Step 4. Check if Cells are brought onAir with desired pMax values
    Wait For All Cells To Be OnAir
    ${pMax_values}  List pMax Values For All Cells    ${enb_id}
    Compare pMax Values For All Cells    ${pMax_values}    ${pMax_postcondition}

    #Alarm checks
    ${active_faults}   List Active eNB Faults
    Check For Unwanted Faults     allowed_faults=@{allowed_faults}    active_alarm_list=${active_faults}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Save And Check Historical Alarms    expected_alarms=${expected_alarms}    AND
    ...                           Kill All SAS Processes
