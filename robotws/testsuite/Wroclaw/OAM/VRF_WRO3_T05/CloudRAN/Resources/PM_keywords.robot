*** Settings ***

Documentation    Description:  Cloud Library with common PM keywords


*** Keywords ***
Change Parameters activeBulkPmReportingFormat and reportingIntervalPm
    [Documentation]
    ...    Checks the current values of 'reportingIntervalPm' and 'activeBulkPmReportingFormat'
    ...    on the PMCADM managed object. If they are not set to '5min' and '3GPP_OMeS' respectively,
    ...    it changes them to these values. It also sets internal flags (${IntervalPm_changes}, ${PmReportingFormat_changes})
    ...    to indicate that these parameters were modified, which is used by the teardown to revert changes.
    ...    This keyword assumes ${PMCADM_DN} is already set as a test variable.

    ${reportingIntervalPm}=    parameters.Check Parameter Value
    ...    dist_name=${PMCADM_DN}
    ...    param_name=reportingIntervalPm
    ...    hw_type=vCU
    Set Test Variable    ${reportingIntervalPm}
    ${activeBulkPmReportingFormat}=    parameters.Check Parameter Value
    ...    dist_name=${PMCADM_DN}
    ...    param_name=activeBulkPmReportingFormat
    ...    hw_type=vCU

    Change Parameter If Needed    reportingIntervalPm    5min    IntervalPm_changes
    Change Parameter If Needed    activeBulkPmReportingFormat    3GPP_OMeS    PmReportingFormat_changes

Change Parameter If Needed
    [Documentation]    Checks if a BTS parameter has a specific value,
    ...                 and if not, updates it and sets a test variable to True.
    ...                 Arguments:
    ...                 - ${param}: The name of the parameter to check or update.
    ...                 - ${value}: The expected value of the parameter.
    ...                 - ${variable_name}: The name of the test variable to set if the parameter is updated.
    [Arguments]         ${param}
    ...                 ${value}
    ...                 ${variable_name}
    [Return]           None

    Run Keyword If    '${param}' != '${value}'    Run Keywords
    ...    Change Parameter on BTS    ${PMCADM_DN}    ${param}    ${value}    update    vCU
    ...    AND    Set Test Variable    ${${variable_name}}    ${True}

Remove activeBulkPmReportingFormat
    [Documentation]
    ...    Removes the 'activeBulkPmReportingFormat' parameter from the specified
    ...    PMCADM managed object on the vCU.
    Delete Parameter on BTS    ${PMCADM_DN}    activeBulkPmReportingFormat    vCU    ${vcu_connection}
    Log to console   Removed activeBulkPmReportingFormat.

Change reportingIntervalPm
    [Documentation]
    ...    Changes the 'reportingIntervalPm' parameter in the specified
    ...    PMCADM managed object on the vCU.
    Change Parameter on BTS    ${PMCADM_DN}    reportingIntervalPm    ${reportingIntervalPm[0]}    update    vCU
    Log to console    Changed reportingIntervalPm to ${reportingIntervalPm[0]}.
