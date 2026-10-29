*** Settings ***
Documentation    These keywords allow actions related to report portal, such as "Dynamic set QC instance ID tag".
    ...    author:  Xu Zhuoyan
    ...    contact: zhuoyan.xu@nokia-sbell.com
Library           OperatingSystem
Library           Collections

*** Variables ***

*** Keywords ***
Dynamic set QC instance ID tag
    [Arguments]    @{tags}
    [Documentation]    This keyword can dynamic set QC instance ID tag in automation cases to map the corresponding ET
    ...    cases according to different release build. And the number of parameters is variable.one tag should be contain
    ...    two parts: tag_type and tag_value
    ...    Now you can choose one or more of these four for the tag_type section:
    ...    Cloud_5G19 | Classical_5G19 | Cloud_Trunk | Classical_Trunk
    ...    tag_value is the corresponding QC instance ID
    ...    ${BUILD_TAG_TYPE} is a global variable that we plug in when we trigger run the case
    ...    ${BUILD_TAG_TYPE} is one of these four values：Cloud_5G19 | Classical_5G19 | Cloud_Trunk | Classical_Trunk
    ...    author:  Xu Zhuoyan
    ...    contact: zhuoyan.xu@nokia-sbell.com
    ...    | param string tags: @{tags}
    ...    | Examples:
    ...    | Dynamic set QC instance ID tag    Classical_Trunk    QC_1111    Classical_5G19    QC_2222
    &{dict} =    Create Dictionary    @{tags}
    ${is_tag}    Get Variable Value    ${dict.${BUILD_TAG_TYPE}}    False
    Run Keyword If    '${is_tag}' != 'False'    Set Tags    ${dict.${BUILD_TAG_TYPE}}
