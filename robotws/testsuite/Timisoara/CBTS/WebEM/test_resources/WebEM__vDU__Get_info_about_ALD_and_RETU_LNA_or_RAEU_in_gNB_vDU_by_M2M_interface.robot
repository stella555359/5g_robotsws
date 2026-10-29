*** Settings ***
Documentation
    ...  This TC is created to get vDU ALD and RETU info by M2M interface.
    ...  Generate the token and login.
    ...  Get vDU ALD data with curl command.
    ...  Get vDU ALD data with KW from taf library.
    ...  Check if control protocol, procedural status, availability status, operational state, config and runtime
    ...  are correct in output from curl command.
    ...  Logout with initial token.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__Get_info_about_ALD_and_RETU_LNA_or_RAEU_in_gNB_vDU_by_M2M_interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25189
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25189 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB006590

    Step0:TC Prerequisites
    Step1:Get VDU ALD Data With Curl Command
    Step2:Check VDU ALD Data To Be Correct


Step0:TC Prerequisites
    Log  \nStep0:TC Prerequisites  console=true
    ${alds_state_data}  vdu.Get Alds
    Set Test Variable  ${ALD_DIST_NAME}  ${alds_state_data}[0][dist_names][config]
    Set Test Variable  ${ALD_RUNTIME}  ${alds_state_data}[0][dist_names][runtime]
    ${ald_id}  Fetch From Right  ${ALD_RUNTIME}  ALD_R-
    Set Test Variable  ${ALD_ID}


Step1:Get VDU ALD Data With Curl Command
    Log  \nStep1:Get vDU ALD data with curl command  console=true
    ${url_string}  Catenate  SEPARATOR=  https://${VDU_OAM_IP}/api/licensed/v1/ald?aldDN=MRBTS
    ...  -${VDU_MRBTS_ID}%2FEQM_R-1%2FAPEQM_R-1%2FALD_R-${ALD_ID}
    ${get_vdu_ald_output}  Run M2M Command  GET  ${url_string}  Bearer  ${TOKEN}
    Set Test Variable  ${GET_VDU_ALD_OUTPUT}


Step2:Check VDU ALD Data To Be Correct
    Log  \nStep2:Check vDU ALD data to be correct  console=true
    ${ald_state_data}  vdu.Get Ald State Data  ${ALD_DIST_NAME}
    ${value_control_protocol}  Get From Dictionary  ${ald_state_data}  control_protocol
    ${value_procedural_status}  Get From Dictionary  ${ald_state_data}  procedural_status
    ${value_availability_status}  Get From Dictionary  ${ald_state_data}  availability_status
    ${value_operational_state}  Get From Dictionary  ${ald_state_data}  operational_state
    ${status_control_protocol}  Run Keyword And Return Status
    ...  Should Contain  ${GET_VDU_ALD_OUTPUT}  "controlProtocol":"${value_control_protocol}"
    Run Keyword If  ${status_control_protocol}
    ...  Log  In command output, control protocol: ${value_control_protocol} is visible correctly! [OK]  console=true
    ...  ELSE
    ...  Fail  In command output, control protocol is not visible correctly! [NOK]
    ${status_procedural_status}  Run Keyword And Return Status
    ...  Should Contain  ${GET_VDU_ALD_OUTPUT}  "proceduralStatus":"${value_procedural_status}"
    Run Keyword If  ${status_procedural_status}
    ...  Log  In command output, procedural status: ${value_procedural_status} is visible correctly! [OK]  console=true
    ...  ELSE
    ...  Fail  In command output, procedural status is not visible correctly! [NOK]
    ${status_availability_status}  Run Keyword And Return Status
    ...  Should Contain  ${GET_VDU_ALD_OUTPUT}  "availabilityStatus":"${value_availability_status}"
    Run Keyword If  ${status_availability_status}
    ...  Log  In command output, availability status: ${value_availability_status} is visible correctly! [OK]  console=true
    ...  ELSE
    ...  Fail  In command output, availability status is not visible correctly! [NOK]
    ${status_operational_state}  Run Keyword And Return Status
    ...  Should Contain  ${GET_VDU_ALD_OUTPUT}  "operationalState":"${value_operational_state}"
    Run Keyword If  ${status_operational_state}
    ...  Log  In command output, operational state: ${value_operational_state} is visible correctly! [OK]  console=true
    ...  ELSE
    ...  Fail  In command output, operational state is not visible correctly! [NOK]
    ${status_config}  Run Keyword And Return Status
    ...  Should Contain  ${GET_VDU_ALD_OUTPUT}  "config":"${ALD_DIST_NAME}"
    Run Keyword If  ${status_config}
    ...  Log  In command output, configuration: ${ALD_DIST_NAME} is visible correctly! [OK]  console=true
    ...  ELSE
    ...  Fail  In command output, configuration is not visible correctly! [NOK]
    ${status_runtime}  Run Keyword And Return Status
    ...  Should Contain  ${GET_VDU_ALD_OUTPUT}  "runtime":"${ALD_RUNTIME}"
    Run Keyword If  ${status_runtime}
    ...  Log  In command output, runtime: ${ALD_RUNTIME} is visible correctly! [OK]  console=true
    ...  ELSE
    ...  Fail  In command output, runtime is not visible correctly! [NOK]


TC Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__Get_info_about_ALD_and_RETU_LNA_or_RAEU_in_gNB_vDU_by_M2M_interface
    Login Using M2M Interface  ${VDU_OAM_IP}


TC Teardown
    Logout Using M2M Interface  ${VDU_OAM_IP}
    Common VDU Teardown
