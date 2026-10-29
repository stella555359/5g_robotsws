*** Settings ***
Documentation
    ...  This TC is created to get information about AMF on vCU.
    ...  Generate the token and login.
    ...  Get AMF data with curl command.
    ...  Verify AMF parameters to have the same value as those in SERVEDAMF objects.
    ...  Logout with initial token.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vcu_frame.robot


*** Keywords ***
TC__WebEM__vDU__Cloud_Get_AMF_data_using_M2M_interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26585
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  11.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26585 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  PHASE-CRT  FEATURE-CB010545

    Step 1: Get AMF Data And Verify Parameters


Step 1: Get AMF Data And Verify Parameters
    Log  \nStep 1: Get AMF data and verify parameters.  console=true
    ${amf_data}  Run M2M Command  GET  https://${VCU_OAM_IP}/api/licensed/v1/amf-data  Bearer  ${TOKEN}
    ${output}  Remove M2M Output Noise  ${amf_data}
    ${output}  Remove String Using Regexp  ${output}  (${SPACE}+:00.+None|curl.+None)
    ${amf_data}  Evaluate  json.loads('''${output}''')  json
    Verify AMF Parameters  ${amf_data}
    Should Be Equal As Strings  ${VCU_MRBTS_ID}  ${amf_data}[content][btsId]  BTS ID is not correctly set in the response from M2M interface. [NOK]
    Should Be Equal As Strings  ${VCU_MRBTS_NAME}  ${amf_data}[content][btsName]
    ...  BTS name is not correctly set in the response from M2M interface. [NOK]
    Log  All parameters values obtained from M2M interface correspond to parameters values from SERVEDAMF objects. [OK]  console=true


Verify AMF Parameters
    [Arguments]  ${amf_data}

    ${amf_list}  Set Variable  ${amf_data}[content][amfInfos]
    ${amf_list_length}  Get Length  ${amf_data}[content][amfInfos]
    FOR  ${amf}  IN  @{amf_list}
        ${amf_parameters_dict}  Create Dictionary  amfName=${amf}[amfName]  amfPointer=${amf}[details][guAMI][0][amfPointer]
        ...  amfRegionID=${amf}[details][guAMI][0][amfRegionID]  amfSetID=${amf}[details][guAMI][0][amfSetID]
        ...  guamiStatus=${amf}[details][guAMI][0][guamiStatus]  localCuIpAddr=${amf}[details][localCuIpAddr]
        ...  relativeAMFCapacity=${amf}[details][relativeAMFCapacity]  sd=${amf}[details][snssaiAMFList][0][sd]
        ...  sst=${amf}[details][snssaiAMFList][0][sst]
        ${amf_guami_parameters_dict}  Create Dictionary  mcc=${amf}[details][guAMI][0][mcc]  mnc=${amf}[details][guAMI][0][mnc]
        ...  mncLength=${amf}[details][guAMI][0][mncLength]
        ${amf_plmn_parameters_dict}  Create Dictionary  mcc=${amf}[details][plmnSupportList][0][mcc]  mnc=${amf}[details][plmnSupportList][0][mnc]
        ...  mncLength=${amf}[details][plmnSupportList][0][mncLength]
        Verify SERVEDAMF Objects  ${amf}  ${amf_list_length}  ${amf_parameters_dict}  ${amf_guami_parameters_dict}  ${amf_plmn_parameters_dict}
    END


Verify SERVEDAMF Objects
    [Arguments]  ${amf}  ${amf_list_length}  ${amf_parameters_dict}  ${amf_guami_parameters_dict}  ${amf_plmn_parameters_dict}

    FOR  ${served_amf_no}  IN RANGE  1  ${amf_list_length}+1
        Log  Verifying SERVEDAMF-${served_amf_no} object for AMF with ip: ${amf}[amfIPAddress]  console=true
        ${served_amf_parameters}  Get Parameters  MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}/SERVEDAMF-${served_amf_no}
        ${parameter_match}  Get Regexp Matches  '${served_amf_parameters}'
        ...  'name': 'amfIPAddress',\n${SPACE}*'state': 'unchanged',\n${SPACE}*'value': '${amf}[amfIPAddress]'
        ${ip_status}  Run Keyword And Return Status
        ...  Should Not Be Empty  ${parameter_match}
        Continue For Loop If  not ${ip_status}
        ${parameters_status}  Run Keyword And Return Status
        ...  Check Every Parameter From AMF  ${amf_parameters_dict}  ${served_amf_parameters}
        ${guami_parameters_status}  Run Keyword And Return Status
        ...  Check Every GuAMI Parameter From AMF  ${amf_guami_parameters_dict}  ${served_amf_parameters}
        ${plmn_parameters_status}  Run Keyword And Return Status
        ...  Check Every PLMN Parameter From AMF  ${amf_plmn_parameters_dict}  ${served_amf_parameters}
        Run Keyword If  ${parameters_status} and ${guami_parameters_status} and ${plmn_parameters_status}
        ...  Return From Keyword
    END
    Fail  AMF with ip address: ${amf}[amfIPAddress] did not match with any of the SERVEDAMF objects. [NOK]


Check Every Parameter From AMF
    [Arguments]  ${parameters_dict}  ${served_amf_parameters}

    FOR  ${key}  IN  @{parameters_dict.keys()}
        ${parameter_match}  Get Regexp Matches  '${served_amf_parameters}'
        ...  'name': '${key}',\n${SPACE}*'state': 'unchanged',\n${SPACE}*'value': '${parameters_dict["${key}"]}'
        Should Not Be Empty  ${parameter_match}  Parameter ${key} not found with expected value. [NOK]
        Log  \t${key} has the value: ${parameters_dict["${key}"]}. [OK]  console=true
    END


Check Every GuAMI Parameter From AMF
    [Arguments]  ${parameters_dict}  ${served_amf_parameters}

    FOR  ${key}  IN  @{parameters_dict}
        ${upper_case_key}  Convert To Upper Case  ${key}
        ${regex}  Catenate  SEPARATOR=  'full_name': '${upper_case_key} '\n${SPACE}*'of '\n${SPACE}*
        ...  'PLMN '\n${SPACE}*'ID in '\n${SPACE}*'GUAMI',\n${SPACE}*
        ...  'name': '${key}',\n${SPACE}*'state': 'unchanged',\n${SPACE}*'value': '${parameters_dict["${key}"]}'
        ${mnc_length_regex}  Catenate  SEPARATOR=  'full_name': 'MNC '\n${SPACE}*'Length '\n${SPACE}*'of '\n${SPACE}*
        ...  'the '\n${SPACE}*'Served '\n${SPACE}*'AMF',\n${SPACE}*'name': '${key}',\n${SPACE}*
        ...  'state': 'unchanged',\n${SPACE}*'value': '${parameters_dict["${key}"]}'
        ${parameter_match}  Run Keyword If  '${key}' == 'mncLength'
        ...  Get Regexp Matches  '${served_amf_parameters}'  ${mnc_length_regex}
        ...  ELSE
        ...  Get Regexp Matches  '${served_amf_parameters}'  ${regex}
        Should Not Be Empty  ${parameter_match}  Parameter ${key} not found with expected value. [NOK]
        Log  \tguAMI ${key} has the value: ${parameters_dict["${key}"]}. [OK]  console=true
    END


Check Every PLMN Parameter From AMF
    [Arguments]  ${parameters_dict}  ${served_amf_parameters}

    FOR  ${key}  IN  @{parameters_dict}
        ${upper_case_key}  Convert To Upper Case  ${key}
        ${regex}  Catenate  SEPARATOR=  'full_name': '${upper_case_key} '\n${SPACE}*'in '\n${SPACE}*'PLMN',\n${SPACE}*
        ...  'name': '${key}',\n${SPACE}*'state': 'unchanged',\n${SPACE}*'value': '${parameters_dict["${key}"]}'
        ${mnc_length_regex}  Catenate  SEPARATOR=  'full_name': 'MNC '\n${SPACE}*'Length '\n${SPACE}*'of '\n${SPACE}*
        ...  'the '\n${SPACE}*'supported '\n${SPACE}*'PLMN',\n${SPACE}*  'name': '${key}',\n${SPACE}*'state': 'unchanged',\n${SPACE}*
        ...  'value': '${parameters_dict["${key}"]}'
        ${parameter_match}  Run Keyword If  '${key}' == 'mncLength'
        ...  Get Regexp Matches  '${served_amf_parameters}'  ${mnc_length_regex}
        ...  ELSE
        ...  Get Regexp Matches  '${served_amf_parameters}'  ${regex}
        Should Not Be Empty  ${parameter_match}  Parameter ${key} not found with expected value. [NOK]
        Log  \tPLMN ${key} has the value: ${parameters_dict["${key}"]}. [OK]  console=true
    END


TC Setup
    Common VCU Setup
    Modify Resource Search Order  WebEM__vDU__Cloud_Get_AMF_data_using_M2M_interface
    Login Using M2M Interface  ${VCU_OAM_IP}


TC Teardown
    Logout Using M2M Interface  ${VCU_OAM_IP}
    Common VCU Teardown
