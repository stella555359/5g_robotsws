*** Settings ***
Documentation
...    author: winnie he
...    contact: winnie.he@nokia-sbell.com
...    ute file operation



*** Keywords ***

Get TestLine Topology Name
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Get the testline name from ute argfile.txt
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | No | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | ${TestLine_Name} | Testline name from ute argfile.txt |
    ...
    ...    Example
    ...    | ${testline_name}= | Get Active Bts Sw Version |
    ...
    ${status}    ${TestLine_Name}    Run Keyword And Ignore Error    get variable value    ${CONFIGURATION}
    ...    ${variablefile}
    ${key_list}    Create List    CM_RESOURCES    0    properties    name
    ${TestLine_Name}    Run Keyword If    '${status}'=='FAIL'
    ...    Get Info From UTE Reservation File    key_list=${key_list}
    ...    ELSE    Set Variable    ${TestLine_Name}
    Log to Console    \n***TestLine Name ${testline_name}***
    ${TestLine_Name_List}    Split String    ${TestLine_Name}    .
    Set Suite Variable    ${TESTLINE_NAME}    ${TestLine_Name_List[-1]}
    [Return]    ${TestLine_Name}

Get Reservation Owner
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Get the testline name from ute argfile.txt
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | No | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | ${TestLine_Name} | Testline name from ute argfile.txt |
    ...
    ...    Example
    ...    | ${testline_name}= | Get Active Bts Sw Version |
    ...
    ${key_list}    Create List    CM_USERNAME
    ${name}    Get Info From UTE Reservation File    key_list=${key_list}
    Log to Console    \n***Reservation Name ${name}***
    ${Name_List}    Split String    ${name}    .
    Set Suite Variable    ${RESERVATION_OWNER}    ${Name_List[-1]}
    [Return]    ${RESERVATION_OWNER}

Get Testline Type
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Get the UTE testline type
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | No | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | ${Testline_type} | UTE test line type |
    ...
    ...    Example
    ...    | ${testline_type}= | Get Testline Type |
    ...
    ${key_list}    Create List    CM_TOPOLOGY    name
    ${Testline_type}    Get Info From UTE Reservation File    key_list=${key_list}
    Set Suite Variable    ${TESTLINE_TYPE}    ${testline_type}
    Log to Console    \n***Testline Type ${Testline_type}***
    [Return]    ${Testline_type}

Get UTE Image Version
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Get the UTE testline type
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | No | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | ${Testline_type} | UTE test line type |
    ...
    ...    Example
    ...    | ${testline_type}= | Get Testline Type |
    ...
    ${key_list}    Create List    sysimage_build
    ${UTE_Image_Version}    Get Info From UTE Reservation File    key_list=${key_list}
    ...    file_path=${UTE_RESERVATION_JSON}
    Set Suite Variable    ${UTE_Image_Version}    ${UTE_Image_Version}
    Log to Console    \n***UTE Image Version ${UTE_Image_Version}***
    [Return]    ${UTE_Image_Version}

Get Expect Sw Version
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Get the expected sw version from ute argfile.txt
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | No | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | ${Expect_Sw_Version} | Expected sw version from ute argfile.txt |
    ...
    ...    Example
    ...    | ${expect_sw_version}= | Get Expect Sw Version |
    ...
    ${status}    ${Expect_Sw_Version}    Run Keyword And Ignore Error    get variable value    ${ENB_BUILD}
    ...    ${variablefile}
    ${key_list}    Create List    CM_ARTIFACTS    0    name
    ${Expect_Sw_Version}    Run Keyword If    '${status}'=='FAIL'    Get Info From UTE Reservation File    key_list=${key_list}
    ...                               ELSE                           Set Variable    ${Expect_Sw_Version}
    Log to Console    \n***Expect Sw Version ${Expect_Sw_Version}***
    Set Suite Variable    ${EXPECT_SW_VERSION}    ${Expect_Sw_Version}
    [Return]    ${Expect_Sw_Version}

Get Info From UTE Reservation File
    [Arguments]    ${key_list}    ${file_path}=${UTE_RESERVATION_CONTEXT_JSON}
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Get any information from any json file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${key_list} | Yes | The keys list need to get from ute reservation file |
    ...    | ${file_path} | No | The UTE reservation file. Default is ${UTE_RESERVATION_CONTEXT_JSON} |
    ...
    ...    | Return Value | Description |
    ...    | ${dict} | The needed info for the keys in key list |
    ...
    ...    Example
    ...    |  ${key_list}            |  Create List                         |  CM_ARTIFACTS          |  0  |  name  |
    ...    |  ${Expect_Sw_Version}=  |  Get Info From UTE Reservation File  |  key_list=${key_list}  |     |        |
    ...
    ${context}    OperatingSystem.Get File    ${file_path}
    &{context_dict}    json.Loads    ${context}
    ${dict}    Set Variable    ${context_dict}
    FOR    ${k}    IN    @{key_list}
        ${is_int}    Evaluate    bool(re.match(r'^-?\\d+$', '''${k}'''))    re
        ${k_convert}    Run Keyword If    ${is_int}    Convert To Integer    ${k}    ELSE    Set Variable    ${k}
        ${dict}    Run Keyword If    ${is_int}    Set Variable    ${dict}[${k_convert}]
        ...    ELSE    Collections.Get From Dictionary    ${dict}    ${k_convert}
    END
    [Return]    ${dict}

Get TestLine Name From UTE Cloud
    [Documentation]    This kw is used to get tl name
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
     ...    | Input Parameters | Man. | Description |
    ...    | NA | no | None|
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get TestLine Name |
    ...
    ${status}    ${TestLine_Name}    Run Keyword And Ignore Error    get variable value    ${CONFIGURATION}
    ...    ${variablefile}
    ${key_list}    Create List    CM_RESOURCES    0    properties    name
    ${TestLine_Name}    Run Keyword If    '${status}'=='FAIL'
    ...    Get Info From UTE Reservation File    key_list=${key_list}
    ...    ELSE    Set Variable    ${TestLine_Name}
    Log to Console    \n***TestLine Name ${testline_name}***
    ${TestLine_Name_List}    Split String    ${TestLine_Name}    .
    Set Suite Variable    ${TESTLINE_NAME}    ${TestLine_Name_List[-1]}
    [Return]    ${TestLine_Name}
