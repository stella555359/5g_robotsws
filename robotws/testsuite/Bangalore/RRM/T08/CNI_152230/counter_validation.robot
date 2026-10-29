*** Settings ***
Documentation
...  author: Amit Kumar Sahu
...  contact: Amit.kumar_sahu@nokia.com
...  Description: Test Suite for Counter validation

Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    BuiltIn
Library    Collections

*** Variables ***
${k}         0
${timestamp}
${now}
${SW}
${Activesw}
${value}

*** Keywords ***

SWinfo
    ${SW}=    CoamAdmin.get_software_info    timeout=10    alias=oam
    ${value}=    Get From Dictionary    ${SW}    Active SW version
    [Return]    ${value}

With Timestamp
    ${timestamp}=    Get Time    result_format=%Y-%m-%d %H:%M:%S
    [Return]   ${timestamp}

Counter validation
    [Arguments]    ${counter}        #${occurence}   # ${name}
	CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam
    ${now}=    with Timestamp
    ${Activesw}=    SWinfo
#    Log To Console    [${now}]BTS is Connected
    Log To Console   [${now}]Current active SW on BTS : ${Activesw}
    ${result} =    CoamAdmin.get_pm_counters    couter_ids=${counter}    timeout=100    connection=oam
    ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1066']['NRBTS-1066']['NRCELL-0']['NCAV']['${counter}']}
    Log To Console    ${values}
    ${Total_Count}=    Get_value_of_Counter    ${values}
	CoamAdmin.teardown    oam
#    Log To Console    [${now}]BTS IS Disconnected
	[Return]    ${Total_Count}


Get_value_of_Counter
    [Arguments]    ${Counter_value}
    FOR    ${a}    IN    @{Counter_value}
        ${k}    Evaluate    ${k} + ${a}
    END
    [Return]    ${k}
