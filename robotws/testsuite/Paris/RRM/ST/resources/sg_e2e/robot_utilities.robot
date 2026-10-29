*** Settings ***
Documentation   Useful keywords to manage robot metadata

Library         String

*** Keywords ***
Get QC Test Case TAG
    [Documentation]    This keyword return Test Case TAG QC_XXXX
    ...                Author: Abderrahmane NEZROUK
    [Arguments]     ${suffix}=QC_
    ${matched_tag}=    Get Matches    ${TEST TAGS}    regexp=${suffix}\\d+
    #${test_case_num}    Get Regexp Matches    @{matched_tag}[0]    \\d+
    [Return]    @{matched_tag}[0]
