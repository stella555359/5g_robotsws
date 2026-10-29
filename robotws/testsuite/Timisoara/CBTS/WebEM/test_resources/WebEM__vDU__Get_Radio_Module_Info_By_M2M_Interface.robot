*** Settings ***
Documentation
    ...  This TC is created to test vDU is able to fetch on radio module information and
    ...  synchronization information of the radio module via M2M interface.
    ...  Generate the token and login.
    ...  Get RMOD information with curl command.
    ...  Check RMOD information responses.
    ...  Get RMOD sync information with curl command.
    ...  Check RMOD sync information responses.
    ...  Logout with initial token.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__Get_Radio_Module_Info_By_M2M_Interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25167
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 04.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25167 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-victor.banicioiu@nokia.com  MAINTAINER-victor.banicioiu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB007823

    Step0:Get All RMODs Distnames
    Step1:Get RMOD Information With Curl Command
    Step2:Check RMOD Information Responses
    Step3:Get RMOD Sync Information With Curl Command
    Step4:Check RMOD Sync Information Responses


Step0:Get All RMODs Distnames
    Log  Step0:Get all RMODs distnames  console=true
    ${rmods_statuses}  vdu.Get Rmods Status
    ${rmod_distname_list}  Create List
    FOR  ${rmod_status}  IN  @{rmods_statuses}
        Append To List  ${rmod_distname_list}  ${rmod_status}[dist_names][config]
    END
    Set Test Variable  ${RMOD_DISTNAME_LIST}


Step1:Get RMOD Information With Curl Command
    Log  Step1:Get RMOD information with curl command  console=true
    ${get_rmod_info_output}  Create List
    FOR  ${rmod_distname}  IN  @{RMOD_DISTNAME_LIST}
        ${rmod_distname}  Replace String  ${rmod_distname}  /  %2F
        ${url}  Set Variable  https://${VDU_OAM_IP}/api/licensed/v1/rmod?rmodDN=${rmod_distname}
        ${rmod_info_output}  Run M2M Command  GET  ${url}  Bearer  ${TOKEN}
        ${output}  Fetch From Right  ${rmod_info_output}  \n
        Append To List  ${get_rmod_info_output}  ${output}
    END
    Set Test Variable  ${GET_RMOD_INFO_OUTPUT}


Step2:Check RMOD Information Responses
    Log  Step2:Check RMOD information responses  console=true
    ${rmods_status_info}  vdu.Get Rmods Status
    FOR  ${rmod_dict}  IN  @{rmods_status_info}
        Remove From Dictionary  ${rmod_dict}  id  ant_ports
        ${rmod_name}  Fetch From Right  ${rmod_dict}[dist_names][config]  /
        Log  Checking the curl output for ${rmod_name}:  console=true
        Parse Dictionary List  ${rmod_dict}  ${GET_RMOD_INFO_OUTPUT}
    END
    Log  RMOD information obtained from curl command is valid!  console=true


Step3:Get RMOD Sync Information With Curl Command
    Log  Step3:Get RMOD sync information with curl command  console=true
    ${get_rmod_sync_output}  Create List
    FOR  ${rmod_distname}  IN  @{RMOD_DISTNAME_LIST}
        ${rmod_distname}  Replace String  ${rmod_distname}  /  %2F
        ${url}  Set Variable  https://${VDU_OAM_IP}/api/licensed/v1/rmods/syncInfo?rmodDN=${rmod_distname}
        ${rmod_info_output}  Run M2M Command  GET  ${url}  Bearer  ${TOKEN}
        Append To List  ${get_rmod_sync_output}  ${rmod_info_output}
    END
    Set Test Variable  ${GET_RMOD_SYNC_OUTPUT}


Step4:Check RMOD Sync Information Responses
    Log  Step4:Check RMOD sync information responses  console=true
    ${rmod_sync_info}  vdu.Get Rmods Syncinfolist
    FOR  ${rmod_sync_dict}  IN  @{rmod_sync_info}
        ${rmod_name}  Fetch From Right  ${rmod_sync_dict}[dist_name]  /
        Log  Checking the curl synchronization output for ${rmod_name}:  console=true
        Parse Dictionary List  ${rmod_sync_dict}  ${GET_RMOD_SYNC_OUTPUT}
    END
    Log  RMOD sync information obtained from curl command is valid!  console=true


Check RMOD Status Values
    [Documentation]  This keyword compares the RMOD information received from the curl command with the information
    ...  received from the get_rmods_status method
    ...  Mandatory arguments are:
    ...  ${status_rmod_item} - represents the current key from the dictionary returned by the get_rmods_status for the current RMOD
    ...  ${status_rmod_value} - represents the current value from the dictionary returned by the get_rmods_status for the current RMOD
    ...  ${curl_output} - represents the output from the curl command that is verified
    ...  The keyword will log success and continue the check if everything is [OK] and fail the test if any of the
    ...  checked fields are [NOK]
    [Arguments]  ${status_rmod_item}  ${status_rmod_value}  ${curl_output}

    ${check_status}  Run Keyword And Return Status
    ...  Should Contain  ${curl_output}[0]  ${status_rmod_value}
    ${check_status_list}  Run Keyword And Return Status
    ...  Should Contain  ${curl_output}[0]  ${status_rmod_value}[0]
    Run Keyword If  (${check_status}) or (${check_status_list})
    ...  Log  In curl command output, ${status_rmod_item}:${status_rmod_value} is visible correctly! [OK]  console=true
    ...  ELSE
    ...  Fail  In curl command output, ${status_rmod_item}:${status_rmod_value} is not visible correctly! [NOK]


Parse Dictionary List
    [Documentation]  This keyword parses the list of dictionaries obtained from the taf library commands and performs the
    ...  checks on each value requested.
    ...  Mandatory arguments are:
    ...  ${dict} - represents the current dictionary to be parsed
    ...  ${curl_output} - represents the output from the curl command that is verified
    [Arguments]  ${dict}  ${curl_output}

    FOR  ${key}  IN  @{dict}
        ${aux}  Set Variable  ${dict}[${key}]
        Choose Action  ${aux}  ${key}  ${dict}  ${curl_output}
    END


Choose Action
    [Documentation]  This keyword checks if ${item} is a string, list or dictionary and handles them accordingly.
    ...  For strings, it directly calls the keyword 'Check RMOD status values' in order to perform the check.
    ...  For lists, it calls the 'Tackle list' keyword which parses every element of the list, calling 'Check RMOD status values' on it.
    ...  For dictionaries, it calls the 'Tackle dictionary' keyword which parses each key-value pair and calls
    ...  'Check RMOD status values' on each value.
    [Arguments]  ${item}  ${key}  ${dict}  ${curl_output}

    ${is_string}  Check If String  ${item}
    ${is_list}  Check If List  ${item}
    ${is_dict}  Check If Dictionary  ${item}
    Run Keyword If  ${is_string}
    ...  Check RMOD Status Values  ${key}  ${dict}[${key}]  ${curl_output}
    ...  ELSE IF  ${is_list}
    ...  Tackle List  ${item}  ${key}  ${curl_output}
    ...  ELSE IF  ${is_dict}
    ...  Tackle Dictionary  ${item}  ${curl_output}
    ...  ELSE
    ...  Log  Unexpected data type for the current value checked: ${item}


Tackle List
    [Arguments]  ${list}  ${key}  ${curl_output}

    ${count}  Get Length  ${list}
    FOR  ${index}  IN RANGE  ${count}
        ${str}  Set Variable  ${list}[${index}]
        ${str}  Replace String  ${str}  '  "
        Check RMOD Status Values  ${key}  ${str}  ${curl_output}
    END


Tackle Dictionary
    [Arguments]  ${dict}  ${curl_output}

    FOR  ${key}  IN  @{dict}
        ${aux}  Set Variable  ${dict}[${key}]
        Check RMOD Status Values  ${key}  ${aux}  ${curl_output}
    END


Check If String
    [Documentation]  This keyword returns true if ${item} is a string and false otherwise
    [Arguments]  ${item}

    ${is_str}  Evaluate  issubclass(type($item), str)

    [Return]  ${is_str}


Check If Dictionary
    [Documentation]  This keyword returns true if ${item} is a dictionary and false otherwise
    [Arguments]  ${item}

    ${aux}  Evaluate  type($item).__name__
    ${is_dict}  Run Keyword And Return Status
    ...  Should Contain  ${aux}  dict

    [Return]  ${is_dict}


Check If List
    [Documentation]  This keyword returns true if ${item} is a list and false otherwise
    [Arguments]  ${item}

    ${is_list}  Evaluate  issubclass(type($item), list)

    [Return]  ${is_list}


TC Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__Get_Radio_Module_Info_By_M2M_Interface
    Login Using M2M Interface  ${VDU_OAM_IP}


TC Teardown
    Logout Using M2M Interface  ${VDU_OAM_IP}
    Common VDU Teardown
