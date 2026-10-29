*** Keywords ***
Verify Prach Config Index
    [Arguments]    ${output}    ${index}
    ${prach_line}    String.Get Lines Matching Regexp    ${output}    prach-ConfigurationIndex [0-9]{3}    partial_match=True
    Should Contain    ${prach_line}    ${index}
