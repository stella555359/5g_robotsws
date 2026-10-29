*** Settings ***
Documentation
...    [Procedure] "[1]CB008660_A_04_Pre-validation_of_the_full_configuration_plan"
...    [Date] "Date of creation 27-02-2023"
...    [Author] "Vinay"
...    [QC_Path] "QC_Path in Test Plan"
...    [QC_ID] "QC_ID in Test Lab for reporting"
...    [Feature_ID] "CB008660_A_04"
...    [Validation_status] "Validated and Passed"
...    [Validated_TestLine] ASIB
...    [Validation Date]

Resource    ${CURDIR}/../resources/common_keywords.robot
Resource    ${CURDIR}/../resources/Admin_Common_Library.robot
Library     Telnet    prompt=$    default_log_level=DEBUG
Library     SSHLibrary
Library     ute_pdu
Library     Collections
Library     DateTime
Variables   ta_e2e_bts_trs_fw

Suite Setup       Run Keywords    Suite Setup Preconditions    AND    Setup Oamops
Suite Teardown    Run Keywords    Suite Teardown Postconditions    AND    Teardown Oamops


*** Test Cases ***
[1][1.0] CB008660_A_04_Pre-validation_of_full_configuration_plan_with_Shortened_DNs_via_NetAct_NOM
    Perform Commissioning    scf_file=${master_scf}    timeout=600
    Setup Ems    config_device=netact2005    alias=lab2005
    Cm Upload    config_device=netact2005    alias=lab2005

    ${pre_execution_alarms}=    Get Current Alarm List

    Copy File    ${master_scf}    ${CURDIR}/CB008660_scf.xml
    ${pre_DN}=    Configuration Get    config_device=netact2005    dist_name=${moc_full_DN}    alias=lab2005
    Log    ${pre_DN}
    Log    ${pre_DN['snssaiList']}[0]

    ${dic_DN_str}=    Set Variable    ${pre_DN['snssaiList']}[0]
    ${dic_DN_full}=    Set Variable    ${dic_DN_str['snssaiDN']}

    ${script_status_msg}=    Run Process    python3    ${CURDIR}/short_name_parse.py    ${scf_file}
    Log    ${script_status_msg.stdout}

    Should Contain    ${script_status_msg.stdout}    Short DN's changed in xml
    Should Contain    ${script_status_msg.stdout}    No removed parameters found

    Perform Commissioning    scf_file=${CURDIR}/${scf_file1}    verify_bts_status=True    timeout=900

    BuiltIn.Sleep    500

    Cm Upload    config_device=netact2005    alias=lab2005
    ${post_DN}=    Configuration Get    config_device=netact2005    dist_name=${moc_full_DN}    alias=lab2005
    Log    ${post_DN}
    Log    ${post_DN['snssaiList']}[0]

    ${dic_DN_str}=    Set Variable    ${post_DN['snssaiList']}[0]
    ${dic_DN_short}=    Set Variable    ${dic_DN_str['snssaiDN']}

    Should Not Be Equal    ${dic_DN_full}    ${dic_DN_short}

    ${post_execution_alarms}=    Get Current Alarm List
    ${alarms_post_execution}=    Fault list after reset    ${pre_execution_alarms}    ${post_execution_alarms}

    Should Be Empty    ${alarms_post_execution}


*** Keywords ***
Create fault id List
    [Arguments]    ${list}
    ${length}=    Get Length    ${list}
    ${list1}=     Create List

    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${list1}    ${list[${i}]['faultId']}
    END

    [return]    ${list1}


Fault list after reset
    [Arguments]    ${pre_alarm_faultids}    ${post_alarm_faultids}

    ${list}=    Create List

    FOR    ${i}    IN    @{post_alarm_faultids}
        Run Keyword If    ${i} in ${pre_alarm_faultids}    Continue For Loop
        Append To List    ${list}    ${i}
    END

    [return]    ${list}


Get Current Alarm List
    ${alarms}=    Verify Alarm    alarm_type=active
    ${alarm_faultids_list}=    Create List
    ${alarm_faultids_list}=    Create fault id List    ${alarms}
    [return]    ${alarm_faultids_list}

Get All Distnames
    [Arguments]    ${obj_element}    ${dist_names}
    Log    ${obj_element}
    Log    ${dist_names}
    ${dict}=    Get Element Attributes    ${obj_element}
    Run Keyword If    ${dict} != {}    Append To List    ${dist_names}    ${dict['distName']}
    [Return]    ${dist_names}

Get DistinguishedName Elements
    [Arguments]    ${obj_element}
    ${DN_list}=    Create List

    FOR    ${i}    IN    @{obj_element}
        ${dict}=    Get Element Attributes    ${i}
        ${value}=   Get Element Text    ${i}
        ${key}=     Set Variable    ${dict.keys()}[0]

        Log    ${dict}[${key}]

        ${DN_status}=    Run Keyword And Return Status
        ...    Should Match Regexp    '${dict}[${key}]'.*DN.$

        Run Keyword If    '${DN_status}'=='True'    Append To List    ${DN_list}    ${value}
        Run Keyword If    '${DN_status}'=='True'    Log    ${dict}[${key}],${value}
    END

    [Return]    ${DN_list}

Get Short DistinguishedName
    [Arguments]    ${dist_names}    ${DN}
    ${str1}=    Split String    ${DN}
    ${str2}=    Copy List    ${str1}
    ${dn_length}=    Get Length    ${str1}

    Reverse List    ${str1}

    FOR    ${j}    IN    @{str1}
        ${long_dn}    Should Match Regexp    ${DN}    ${j}*
        ${cnt}=       Get Match Count    ${dist_names}    *${j}

        Run Keyword If    ${cnt} == 1    Exit For Loop
    END

    [Return]    ${long_dn}
