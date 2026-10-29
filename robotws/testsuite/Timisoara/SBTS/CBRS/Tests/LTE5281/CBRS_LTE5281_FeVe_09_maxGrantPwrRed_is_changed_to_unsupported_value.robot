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
CBRS_LTE5281_FeVe_09_maxGrantPwrRed_is_changed_to_unsupported_value
    [Documentation]    Requirement: OM_LTE_SFS_RNL.21877
    [Timeout]    30min
    Set Test Variable    @{ALLOWED_FAULTS}    @{EMPTY}
    Append To List       ${ALLOWED_FAULTS}
    ...                  ${61524}  #SSH_ENABLED
    ...                  ${61649}   #LMP_ACCESS_VIA_PORT
    ...                  ${61652}   #R&D_SERVICE_PORT_ENABLED
    ...                  ${9000}   #TEMP FAULT
    ...                  ${6351}    #SIB overflow
    ...                  ${4592}    #BTS Reset Cause

    ${release_version}       Get Active Release Version
    ${ENB_ROOT_USER}   Set Variable        toor4nsn
    ${ENB_ROOT_PASS}   Set Variable       oZPS0POrRieRtu

    ${pMax_precondition}    Create Dictionary    "CELL1"=${21.9}    "CELL2"=${21.9}    "CELL3"=${21.9}    "CELL4"=${21.9}

    Kill All SAS Processes
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    default
    ...                                                     4433
    ...                                                     config=${CURDIR}/Data/FeVe09/SAS_Sim.conf

    Wait For All Cells To Be OnAir
    ${enb_id}    Set Variable    ${testlines.${testline_id}.enb_id}
    ${cbsd_id}   Fetch CBSD ID    ${enb_id}
    ${bts_side}   Set Variable    *

    #Upload precondition delta
    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    Wait Until BTS Is Not Busy
    Create generic delta and perform commissioning    enb_id=${enb_id}
    ...                                               delta_file_tmp=${CURDIR}/Data/FeVe09/FEVE_9_Precond_delta_tmp.json
    ...                                               delta_file_final=${CURDIR}/Data/FeVe09/FEVE_9_Precond_delta.json

    Wait For All Cells To Be OnAir

    #Step 1 Check current pMax value for CBSD cells
    ${pMax_values}   List pMax Values For All Cells    ${enb_id}
    Compare pMax Values For All Cells    ${pMax_values}    ${pMax_precondition}

    #Step 2. Upload delta with specific parameters:
    ${time_start}    Get Time
    ${grantId_list}   List Values of GrantId For All Cells    ${enb_id}

    Wait Until BTS Is Not Busy
    Create generic delta and perform commissioning    enb_id=${enb_id}
    ...                                               delta_file_tmp=${CURDIR}/Data/FeVe09/FEVE_9_Test_delta_tmp.json
    ...                                               delta_file_final=${CURDIR}/Data/FeVe09/FEVE_9_Test_delta.json

    #Step 3. Check if cells are disabled
    Wait Until All Cells Reach State     enb_id=${enb_id}   state=operationalState    state_value=Disabled

    Sleep    30s   #purpose: to make sure GrantRelinquishment procedure is complete

    ${time_stop}    Get Time

    #Step 4.Check if previous Grants are relinquished
    Verify Grant Relinquishment Procedure    ${time_start}    ${time_stop}    sas_log_path=${sas_logs_dir}   grantId_list=${grantId_list}


    #Step 5. Check if all CBSD Cells remain disabled
    Wait Until All Cells Reach State     enb_id=${enb_id}   state=operationalState    state_value=Disabled

    #Alarm checks
    Assert Alarm Active    faultId=6828    alias=RAT_1ST
    Assert Fault Presence On Selected Cell     cell_id=1    fault_id=6828    alarm_name=SAS Grant Failure    bts_side=${bts_side}
    Assert Fault Presence On Selected Cell     cell_id=2    fault_id=6828    alarm_name=SAS Grant Failure    bts_side=${bts_side}
    Assert Fault Presence On Selected Cell     cell_id=3    fault_id=6828    alarm_name=SAS Grant Failure    bts_side=${bts_side}
    Assert Fault Presence On Selected Cell     cell_id=4    fault_id=6828    alarm_name=SAS Grant Failure    bts_side=${bts_side}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Kill All SAS Processes
