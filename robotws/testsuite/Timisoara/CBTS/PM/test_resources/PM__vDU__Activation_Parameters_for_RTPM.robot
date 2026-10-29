*** Settings ***
Documentation
...  This TC is reconfiguring vCU RTPM parameters: act5gRTPM, nrRTPMMeasurementsList and rTPmCollEntity with required values.
...  First, nrRTPMMeasurementsList and rTPmCollEntity are deleted (act5gRTPM is auto-configured and it can not be deleted).
...  Then these parameters are recreated.
...  Fault 4203 must not be visible.

Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RTPM_IP}  10.5.60.80


*** Keywords ***
TC__PM__vDU__Activation_Parameters_for_RTPM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29239
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  15.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29239 - Initial TAT creation
    ...  ******************

    Set Tags  CA-PM  OWNER-adrian.rosa@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf  FEATURE-CB009067
    ...  SW-vDU25R2

    Step0: TC Preconditions
    Step1: Delete RTPM Parameters
    Step2: Recreate RTPM Parameters
    Step3: Check If Fault 4203 Is Not Active


Step0: TC Preconditions
    ${param_value}  VDU Get Parameter Value  act5gRTPM  MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}
    IF  '${param_value}'=='true'  Change Specific Parameter For VDU  act5gRTPM  false  MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}
    Check If Parameter Exist  nrRTPMMeasurementsList  MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRPMRNL-1
    Check If Parameter Exist  rTPmCollEntity  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1


Step1: Delete RTPM Parameters
    Log  \nStep1: Delete RTPM Parameters  console=true
    ${MEASUREMENTS_LIST}  VDU Get Parameter Value  nrRTPMMeasurementsList  MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRPMRNL-1
    Set Test Variable  ${MEASUREMENTS_LIST}

    ${nrpmnrl_parameter}  Create Dictionary  parameterName=nrRTPMMeasurementsList  operation=delete
    ${nrpmnrl_parameter_change_list}  Create List  ${nrpmnrl_parameter}
    ${nrpmnrl_changed_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRPMRNL-1  operation=update
    ...  parameters=${nrpmnrl_parameter_change_list}

    ${pmcadm_parameter}  Create Dictionary  parameterName=rTPmCollEntity  operation=delete
    ${pmcadm_parameter_change_list}  Create List  ${pmcadm_parameter}
    ${pmcadm_changed_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1  operation=update
    ...  parameters=${pmcadm_parameter_change_list}

    ${changed_parameters_list}  Create List  ${nrpmnrl_changed_parameter}  ${pmcadm_changed_parameter}
    ${list_is_not_empty}  Run Keyword And Return Status  Should Not Be Empty  ${changed_parameters_list}
    IF  ${list_is_not_empty}
        ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameters_list})  json
        vdu.Perform Delta Recommissioning  ${changed_parameters_string}
    END

    ${nrpmnrl_parameter_exists}  Run Keyword And Return Status  Check If Parameter Exist  nrRTPMMeasurementsList
    ...  MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRPMRNL-1
    Should Be True  not ${nrpmnrl_parameter_exists}  nrRTPMMeasurementsList is not deleted.
    Log  nrRTPMMeasurementsList was deleted successfully.  console=true

    ${pmcadm_parameter_exists}  Run Keyword And Return Status  Check If Parameter Exist  rTPmCollEntity
    ...  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    Should Be True  not ${pmcadm_parameter_exists}  rTPmCollEntity is not deleted.
    Log  rTPmCollEntity was deleted successfully.  console=true


Step2: Recreate RTPM Parameters
    Log  \nStep2: Recreate RTPM Parameters  console=true
    ${nrpmnrl_parameter}  Create Dictionary  parameterName=nrRTPMMeasurementsList  value=${MEASUREMENTS_LIST}  operation=update
    ${nrpmnrl_parameter_change_list}  Create List  ${nrpmnrl_parameter}
    ${nrpmnrl_changed_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRPMRNL-1  operation=update
    ...  parameters=${nrpmnrl_parameter_change_list}

    ${coll_parameters}  Create Dictionary  certTypeForTlsAuth=RSA  rTPmCollEntityHost=${RTPM_IP}  rTPmCollEntityPortNum=49525
    ...  rTPmCollInterval=60s  tlsEnabled=false
    ${coll_parameters}  Create List  ${coll_parameters}
    ${pmcadm_parameter}  Create Dictionary  parameterName=rTPmCollEntity  value=${coll_parameters}  operation=create
    ${pmcadm_parameter_change_list}  Create List  ${pmcadm_parameter}
    ${pmcadm_changed_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1  operation=update
    ...  parameters=${pmcadm_parameter_change_list}

    ${changed_parameters_list}  Create List  ${nrpmnrl_changed_parameter}  ${pmcadm_changed_parameter}
    ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameters_list})  json
    vdu.Perform Delta Recommissioning  ${changed_parameters_string}
    Log  nrRTPMMeasurementsList and rTPmCollEntity are recreated.  console=true
    Change Specific Parameter For VDU  act5gRTPM  true  MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}


Step3: Check If Fault 4203 Is Not Active
    Log  \nStep3: Check If Fault 4203 Is Not Active  console=true
    Sleep  10s  TC waits for fault activation.
    ${active_alarms}  vdu.Vdu Get Active Alarms
    ${alarms_list}  Set Variable  ${active_alarms}[alarms]
    FOR  ${alarm}  IN  @{alarms_list}
        ${status_fault_id}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[fault_id]  4203
        Run Keyword If  ${status_fault_id}
        ...  Fail  Alarm with fault id 4203 is visible in WebEM. [NOK]
    END
    Log  Alarm with fault id 4203 is not active on vDU.  console=true


Check If Parameter Exist
    [Arguments]  ${parameter}  ${dist_name}

    ${object_params}  Get Managed Object Parameters Of Current Plan  ${dist_name}
    ${params_list}  Set Variable  ${object_params}[parameters]
    FOR  ${param_fields}  IN  @{params_list}
        ${simple_param_status}  Run keyword and return status  Should be equal as strings  ${param_fields}[simple_parameter][name]  ${parameter}
        ${simple_list_param_status}  Run keyword and return status  Should be equal as strings  ${param_fields}[simple_list_parameter][name]
        ...  ${parameter}
        ${complex_param_status}  Run keyword and return status  Should be equal as strings  ${param_fields}[complex_parameter][name]
        ...  ${parameter}

        IF  ${simple_param_status} or ${simple_list_param_status} or ${complex_param_status}  RETURN
    END

    Fail  Parameter ${parameter} is not defined.


TC Setup
    Common VDU Setup
    Modify Resource Search Order  PM__vDU__Activation_Parameters_for_RTPM


TC Teardown
    Common VDU Teardown
