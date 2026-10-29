*** Settings ***
Documentation    Reporting Robot keywords

Library    taf.sw.reporting_portal    WITH NAME    rp

*** Keywords ***
Add Loop Number To Reporting Portal
    [Arguments]  ${loop_count}
    [Documentation]
    ...  Description:
    ...  Keyword reports to Reporting Portal the number of loops executed in the test case.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | loop_count             | Yes  | Number of loops performed in the test case.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    rp.Add To Test Data  data={"test_loops":"${loop_count}"}
