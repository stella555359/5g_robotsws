*** Settings ***

Documentation    :copyright: Nokia

Library      ta5g_testline_management
Library      ta5g_admin_operations
Library      ta5g_ue_measurements
Library      ta5g_iphy
Library      ta5g_pm_counters
Library      ./NrCgiCountersValidator.py      WITH NAME    counters_validator

*** Variables ***
${UE_ID_A_B2_4}=    12
${UE_ID_A_B3_4}=    13
${UE_ID}=    11
${NRREL_OBJECT_CREATION_TIME}=    120
${EXPECTED_NRREL_OBJECTID}=    256
${SERVING_CELL_ID}=    1
${NRPMRNL_ID}=    1

*** Keywords ***
Verify Existing NRREL
    Wait For Object To Exist    object_name=NRCELL_A-1/NRREL_A-${EXPECTED_NRREL_OBJECTID}    moc=NRREL_A    timeout=${NRREL_OBJECT_CREATION_TIME}

Verify Not Existing NRREL
    Wait For Object To Not Exist    object_name=NRCELL_A-1/NRREL_A-${EXPECTED_NRREL_OBJECTID}    moc=NRREL_A    timeout=${NRREL_OBJECT_CREATION_TIME}

Perform A2 And A5 Triggered Handover
    [Documentation]    Triggers A2/A5 HO. Depending on used regexp it expects HO to pass or fail.
    [Arguments]    ${PASS_REGEXP}

    Send Custom Ue Measurement Nr    id=${UE_ID_A_B3_4}    meas_id=1    event=A2    srsrp_nr=30
    ...                              pass_regexp=Sending SgNB Modification Confirm
    Send Custom Ue Measurement Nr    id=${UE_ID_A_B3_4}    meas_id=3    event=A5    srsrp_nr=19    phycell_id=51    nrsrp_nr=68
    ...                              pass_regexp=${PASS_REGEXP}

Validate NR CGI Report Counters
    [Documentation]    Validates NR CGI Report Counters.
    [Arguments]    ${cell_id}
    ...            ${nrpmrnl_id}

    Wait For Next NR RRC Counters Period    cell_id=${cell_id}
    ...                                     nrpmrnl_id=${nrpmrnl_id}
    counters_validator.Get Airphone Cell Nrcgi Report Counters    cell_id=${cell_id}
    counters_validator.Validate Nrcgi Report Counters

Wait For Next NR RRC Counters Period
    [Documentation]    Waits for next NR RRC counters period.
    [Arguments]    ${cell_id}
    ...            ${nrpmrnl_id}

    counters_validator.Wait For Next Nrrrc Counters Interval    cell_id=${cell_id}
    ...                                                         nrpmrnl_id=${nrpmrnl_id}