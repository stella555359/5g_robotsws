*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiStartupTimesInterface  WITH NAME  Startup
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommissioningInterface


*** Keywords ***
OMKPI RU SW Update One Package
    [Documentation]    Update SW to RF units and check KPIs. User gives build to be downloaded with argument ONE_BUILD.
    ...                ONE_BUILD can have value T1, T2 or normal.
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${ONE_BUILD}
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background   ${SYSLOG_LIST}
    ${suite_variables}=      Get variables
    IF  "\${ADD_KPI55D}" in $suite_variables
        Set Suite Variable  ${ADD_KPI55D}   ${True}
        Set Suite Variable  ${KPI55d_test}  ${True}
        Run Keyword And Continue On Failure   Kpi55d Commissioning
    ELSE IF    "\${ADD_KPI55E}" in $suite_variables
        Set Suite Variable  ${ADD_KPI55E}  ${True}
        IF  "\${RADIO_NAME}" not in $suite_variables
            Set Suite Variable  ${RADIO_NAME}   AHLOA
        END
        ${RADIOS_TO_UPDATE}=    Get Rmods Of Name   ${RADIO_NAME}
        Set Suite Variable          ${RADIOS_TO_UPDATE}
        Run Keyword And Continue On Failure   Kpi55e Commissioning   ${RADIOS_TO_UPDATE}
    END
#    Run Keyword And Continue On Failure    Check If Netboot Is Active And Deactivate It
    ${BUILD}=   Get Build given As One_build Argument    ${ONE_BUILD}
    Run Keyword And Continue On Failure    Check If Build In Passive Side Is Same That Is Planned To Be Downloaded
    ...                                    ${BUILD}    switch_order=${False}
    Run Keyword And Continue On Failure    Get Value Of Ru Phase Activation Reset Policy
# T1/T2/normal
    Run Keyword And Continue On Failure    Log Folders And Radio Software Update   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}
    ...                                                                            ${BUILD}  ${ONE_BUILD}   Collect_KPI55
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
