*** Settings ***
Documentation
    ...  This test case gets hardware info via ADMIN CLI.
    ...  actCli parameter is changed to be true.
    ...  Check getHwInfo command via ADMIN CLI to be send with error code 0.
    ...  Check hardware product names from WebEM to be the same as in CLI response.
    ...  Check bts id and name from WebEM to be the same as in CLI response.
    ...  Check current date to be the same as in CLI response.
    ...  actCli parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Admin_CLI_getHwInfo
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26248
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 26.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26248 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CB010545

    Step1: Sending GetHwInfo Command Via ADMIN CLI
    Step2: Check Output From GetHwInfo Command


Step1: Sending GetHwInfo Command Via ADMIN CLI
    Log  \nStep1: Sending getHwInfo command via ADMIN CLI  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    Log  \nSending command via Admin CLI for getHwInfo...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  {"requestId":1,"parameters":{"name":"getHwInfo"}}
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}![OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}![NOK]
    ${hw_info_dict_cli}  Get From Dictionary  ${request_message}  hwInfo
    ${hw_info_cli}  Convert To String  ${hw_info_dict_cli}
    ${current_time_full_cli}  Get From Dictionary  ${request_message}  currentTime
    Log  Current time from cli response is ${current_time_full_cli}!  console=true
    ${date_cli}  Fetch From Left  ${current_time_full_cli}  T
    ${bts_id_cli}  Get From Dictionary  ${request_message}  btsId
    Log  BTS id from cli response is ${bts_id_cli}!  console=true
    ${bts_name_cli}  Get From Dictionary  ${request_message}  btsName
    Log  BTS name from cli response is ${bts_name_cli}!  console=true
    Set Test Variable  ${BTS_ID_CLI}
    Set Test Variable  ${BTS_NAME_CLI}
    Set Test Variable  ${HW_INFO_CLI}
    Set Test Variable  ${DATE_CLI}


Step2: Check Output From GetHwInfo Command
    Log  \nStep2: Check output from getHwInfo command  console=true
    ${bts_name}  Get Bts Name
    ${all_product_names_list}  Get Product Name From All BBMODs, SMODs And RMODs
    ${date}  Get Current Date  result_format=%Y-%m-%d
    Run Keyword If  '${BTS_ID}' == '${BTS_ID_CLI}' and '${bts_name}' == '${BTS_NAME_CLI}'
    ...  Log  BTS id and name from WebEM are the same as in cli response![OK]  console=true
    ...  ELSE
    ...  Fail  BTS id and name from WebEM are not the same as in cli response![NOK]
    Run Keyword If  '${date}' == '${DATE_CLI}'
    ...  Log  Date from WebEM are the same as in cli response![OK]  console=true
    ...  ELSE
    ...  Fail  Date from WebEM are not the same as in cli response![NOK]
    FOR  ${product_name}  IN  @{all_product_names_list}
        Should Contain  ${HW_INFO_CLI}  ${product_name}  Hardware product name from cli response is not the same as in WebEM![NOK]
    END
    Log  Hardware product names from cli response are the same as in WebEM![OK]  console=true


Get Product Name From All BBMODs, SMODs And RMODs
    ${rmods_parameters_list}  coam.Get Parameters For All  RMOD
    ${bbmods_parameters_list}  coam.Get Parameters For All  BBMOD
    ${smods_parameters_list}  coam.Get Parameters For All  SMOD
    ${all_hw_parameters_list}  Combine Lists  ${rmods_parameters_list}  ${bbmods_parameters_list}  ${smods_parameters_list}
    ${all_product_names_list}  Create List
    FOR  ${hw}  IN  @{all_hw_parameters_list}
        Append To List  ${all_product_names_list}  ${hw}[productName]
    END

    [Return]  @{all_product_names_list}


TC Setup
    Common Test Setup
    Change ActCli Parameter  true


TC Teardown
    Change ActCli Parameter  false
    Common Test Teardown
