*** Settings ***
Documentation
    ...  This TC is created to get vDU list of radio module by M2M interface.
    ...  Generate the token and login.
    ...  Get vDU rmods info with curl command.
    ...  Get vDU rmods info with KW from taf library.
    ...  Check if distNames, productName, serialNumber, operationalState and availabilityStatus
    ...  for each rmod are correct in output from curl command.
    ...  Get vDU sync info of rmods with curl command.
    ...  Get vDU sync info of rmods with KW from taf library.
    ...  Check if distName and state for each rmod are correct in output from curl command.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__Get_List_of_Radio_Module_By_M2M_Interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25168
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25168 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB007823

    Step1:Get Rmods Info With Curl Command
    Step2:Check List Of Rmods Info Responses
    Step3:Get Sync Info Of Rmods With Curl Command
    Step4:Check Sync Info List Of Rmods Responses


Step1:Get Rmods Info With Curl Command
    Log  Step1:Get rmods info with curl command  console=true
    ${get_rmods_info_data_output}  Run M2M Command  GET  https://${VDU_OAM_IP}/api/licensed/v1/rmods/diff  Bearer  ${TOKEN}
    Set Test Variable  ${GET_RMODS_INFO_DATA_OUTPUT}


Step2:Check List Of Rmods Info Responses
    Log  Step2:Check list of rmods info responses  console=true
    ${vdu_rmods_status}  vdu.Get Rmods Status
    FOR  ${index}  IN  @{vdu_rmods_status}
        ${status_config}  Run Keyword And Return Status
        ...  Should Contain  ${GET_RMODS_INFO_DATA_OUTPUT}  ${index}[dist_names][config]
        ${status_runtime}  Run Keyword And Return Status
        ...  Should Contain  ${GET_RMODS_INFO_DATA_OUTPUT}  ${index}[dist_names][runtime]
        Run Keyword If  ${status_config} and ${status_runtime}
        ...  Log  DistNames for config: ${index}[dist_names][config] and runtime ${index}[dist_names][runtime] are visible correctly! [OK]
        ...  console=true
        ...  ELSE
        ...  Fail  DistNames for config and runtime are not visible correctly! [NOK]
        ${status_product_name}  Run Keyword And Return Status
        ...  Should Contain  ${GET_RMODS_INFO_DATA_OUTPUT}  "productName":"${index}[product_name]"
        Run Keyword If  ${status_product_name}
        ...  Log  In command output, productName: ${index}[product_name] is visible correctly! [OK]  console=true
        ...  ELSE
        ...  Fail  In command output, productName is not visible correctly! [NOK]
        ${status_serial_number}  Run Keyword And Return Status
        ...  Should Contain  ${GET_RMODS_INFO_DATA_OUTPUT}  "serialNumber":"${index}[serial_number]"
        Run Keyword If  ${status_serial_number}
        ...  Log  In command output, serialNumber: ${index}[serial_number] is visible correctly! [OK]  console=true
        ...  ELSE
        ...  Fail  In command output, serialNumber is not visible correctly! [NOK]
        ${status_operational_state}  Run Keyword And Return Status
        ...  Should Contain  ${GET_RMODS_INFO_DATA_OUTPUT}  "operationalState":"${index}[operational_state]"
        Run Keyword If  ${status_operational_state}
        ...  Log  In command output, operationalState: ${index}[operational_state] is visible correctly! [OK]  console=true
        ...  ELSE
        ...  Fail  In command output, operationalState is not visible correctly! [NOK]
        ${status_availability_status}  Run Keyword And Return Status
        ...  Should Contain  ${GET_RMODS_INFO_DATA_OUTPUT}  "availabilityStatus":"${index}[availability_status]"
        Run Keyword If  ${status_availability_status}
        ...  Log  In command output, availabilityStatus: ${index}[availability_status] is visible correctly! [OK]  console=true
        ...  ELSE
        ...  Fail  In command output, availabilityStatus is not visible correctly! [NOK]
    END


Step3:Get Sync Info Of Rmods With Curl Command
    Log  Step3:Get sync info of rmods with curl command  console=true
    ${get_sync_info_data_output}  Run M2M Command  GET  https://${VDU_OAM_IP}/api/licensed/v1/rmods/syncInfoList  Bearer  ${TOKEN}
    Set Test Variable  ${GET_SYNC_INFO_DATA_OUTPUT}


Step4:Check Sync Info List Of Rmods Responses
    Log  Step4:Check sync info list of rmods responses  console=true
    ${vdu_rmods_sync_info}  Get Rmods Syncinfolist
    FOR  ${index}  IN  @{vdu_rmods_sync_info}
        ${status_dist_name_id}  Run Keyword And Return Status
        ...  Should Contain  ${GET_SYNC_INFO_DATA_OUTPUT}  "distName" : "${index}[dist_name]"
        Run Keyword If  ${status_dist_name_id}
        ...  Log  In command output, distName: ${index}[dist_name] is visible correctly! [OK]  console=true
        ...  ELSE
        ...  Fail  In command output, distName is not visible correctly! [NOK]
        ${status_state_id}  Run Keyword And Return Status
        ...  Should Contain  ${GET_SYNC_INFO_DATA_OUTPUT}  "state" : "${index}[state]"
        Run Keyword If  ${status_state_id}
        ...  Log  In command output, state: ${index}[state] is visible correctly! [OK]  console=true
        ...  ELSE
        ...  Fail  In command output, state is not visible correctly! [NOK]
    END


TC Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__Get_List_of_Radio_Module_By_M2M_Interface
    Login Using M2M Interface  ${VDU_OAM_IP}


TC Teardown
    Logout Using M2M Interface  ${VDU_OAM_IP}
    Common VDU Teardown
