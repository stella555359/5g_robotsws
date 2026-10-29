*** Settings ***
Documentation
    ...  First, default values are restored for all parameters.
    ...  Get software domains and get parameters requests should be successful.
    ...  ERadCcs_AaSysLogInputLevel and ERadCcs_AaSysLogOutputLevel parameters from Ccs software domain
    ...  should be updated according to TC requirements.
    ...  5 other parameters will be updated:
    ...  - ERadCcs_PrintAaSysCom, ERadCcs_PrintAaConfigRaDMaster, ERadCcs_PrintAaWcdmaTime from Ccs domain
    ...  - rdBearerLogMaskFeatureCfg from L2HICU domain
    ...  - LogsAppIdFilter from LteLIM domain.
    ...  TC checks that only these 7 parameters have non-default values.
    ...  Default values are restored for the updated parameters.
    ...  In the end, all parameters should have default values.

Resource  ../../common_resources/vcu_frame.robot
Resource  ../../common_resources/M2M_Interface.robot


*** Keywords ***
TC__WebEM__vCU__Rad_debug_parameters_M2M_interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26537
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  05.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26537 - Initial TAT creation
    ...  03.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29973 - Refactor output noise removal
    ...  ******************

    Set Tags  CA-WebEM  OWNER-cristian.bulea@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  FEATURE-CB009006-B  PHASE-CRT

    Step1: Restore Default Values
    Step2: Check If List Of Parameters With Non-default Values Is Empty
    Step3: Get All Software Domains
    Step4: Get Rad Debug Parameters From All Software Domains
    Step5: Update Rad Debug Parameters
    Step6: Check Parameters To Have Non-default Values
    Step7: Restore Default Values
    Step8: Check If List Of Parameters With Non-default Values Is Empty


Step${index}: Restore Default Values
    Log  \nStep${index}: Restore default values  console=true
    ${body}  Catenate  {\\"persistency\\": \\"notPersistent\\", \\"parameters\\": []}
    ${post_restore_values}  Run M2M Command  POST  https://${VCU_OAM_IP}/api/licensed/v1/rads/debug-params/operations/updates  Bearer  ${TOKEN}
    ...  -d "${body}"
    ${operation_id}  Fetch From Right  ${post_restore_values}  "operationId":"
    ${operation_id}  Fetch From Left  ${operation_id}  "
    ${restore_output}  Run M2M Command  GET  https://${VCU_OAM_IP}/api/licensed/v1/rads/debug-params/operations/updates/${operation_id}  Bearer
    ...  ${TOKEN}
    Should Contain  ${restore_output}  "status":"succeeded"  Restore operation failed.


Step${index}: Check If List Of Parameters With Non-default Values Is Empty
    Log  \nStep${index}: Check if list of parameters with non-default values is empty  console=true
    Create Directory  ${TEST_RESULTS_DIR}/RAD_debug_parameters
    ${post_non_default_params}  Run M2M Command  POST  https://${VCU_OAM_IP}/api/licensed/v1/rads/debug-params/operations/fetches  Bearer  ${TOKEN}
    ...  -d "{\\"nonDefaultOnly\\": true}"
    ${operation_id}  Fetch From Right  ${post_non_default_params}  "operationId":"
    ${operation_id}  Fetch From Left  ${operation_id}  "
    ${non_default_params}  Run M2M Command  GET  https://${VCU_OAM_IP}/api/licensed/v1/rads/debug-params/operations/fetches/${operation_id}  Bearer
    ...  ${TOKEN}
    ${non_default_params}  Remove M2M Rad Debug Parameters Output Noise  ${non_default_params}
    IF  '${index}'=='8'  Save M2M Output To Json File  output=${non_default_params}
    ...  file_path=RAD_debug_parameters/vcu_step${index}_non_default_values_after_restore.json

    Should Contain  ${non_default_params}  "status":"succeeded"
    ${non_default_params}  Refactor M2M Rad Debug Parameters Output  ${non_default_params}
    FOR  ${domain_details}  IN  @{non_default_params}
        Should Be Empty  ${domain_details}[parameters]  Parameters from ${domain_details}[domainName] don't have default values.
    END


Step3: Get All Software Domains
    Log  \nStep3: Get all software domains  console=true
    ${post_rad_domains}  Run M2M Command  POST  https://${VCU_OAM_IP}/api/licensed/v1/rads/debug-domains/operations/fetches  Bearer  ${TOKEN}
    ${operation_id}  Fetch From Right  ${post_rad_domains}  "operationId":"
    ${operation_id}  Fetch From Left  ${operation_id}  "
    ${rad_domains}  Run M2M Command  GET  https://${VCU_OAM_IP}/api/licensed/v1/rads/debug-domains/operations/fetches/${operation_id}  Bearer
    ...  ${TOKEN}
    ${rad_domains}  Remove M2M Rad Debug Parameters Output Noise  ${rad_domains}
    Save M2M Output To Json File  output=${rad_domains}  file_path=RAD_debug_parameters/vcu_rad_software_domains.json

    Should Contain  ${rad_domains}  "status":"succeeded"
    Should Contain  ${rad_domains}  "radDomains":  Request response doesn't contain informations about rad software domains.
    Should Contain  ${rad_domains}  "name":"Ccs"  Request response doesn't contain Ccs rad software domains.


Step4: Get Rad Debug Parameters From All Software Domains
    Log  \nStep4: Get rad debug parameters from all software domains  console=true
    ${post_params}  Run M2M Command  POST  https://${VCU_OAM_IP}/api/licensed/v1/rads/debug-params/operations/fetches  Bearer  ${TOKEN}
    ...  -d "{\\"nonDefaultOnly\\": false}"
    ${operation_id}  Fetch From Right  ${post_params}  "operationId":"
    ${operation_id}  Fetch From Left  ${operation_id}  "
    ${rad_params}  Run M2M Command  GET  https://${VCU_OAM_IP}/api/licensed/v1/rads/debug-params/operations/fetches/${operation_id}  Bearer  ${TOKEN}
    ${rad_params}  Remove M2M Rad Debug Parameters Output Noise  ${rad_params}
    Save M2M Output To Json File  output=${rad_params}  file_path=RAD_debug_parameters/vcu_all_rad_parameters.json

    Should Contain  ${rad_params}  "status":"succeeded"
    Should Contain  ${rad_params}  "radParams":  Request response doesn't contain informations about rad parameters.
    Should Contain  ${rad_params}  "name":"ERadCcs_AaSysLogInputLevel"  Request response doesn't contain ERadCcs_AaSysLogInputLevel parameter.
    Should Contain  ${rad_params}  "name":"ERadCcs_AaSysLogOutputLevel"  Request response doesn't contain ERadCcs_AaSysLogOutputLevel parameter.


Step5: Update Rad Debug Parameters
    Log  \nStep5: Update rad debug parameters  console=true
    ${ccs_params_to_update}  Catenate  "{\\"persistency\\": \\"notPersistent\\", \\"domainName\\": \\"Ccs\\",
    ...  \\"parameters\\": [{\\"name\\": \\"ERadCcs_AaSysLogInputLevel\\",  \\"value\\": \\"5\\"},  {\\"name\\": \\"ERadCcs_AaSysLogOutputLevel\\",
    ...  \\"value\\": \\"5\\"},  {\\"name\\": \\"ERadCcs_PrintAaSysCom\\",  \\"value\\": \\"true\\"},
    ...  {\\"name\\": \\"ERadCcs_PrintAaConfigRaDMaster\\",  \\"value\\": \\"true\\"},  {\\"name\\": \\"ERadCcs_PrintAaWcdmaTime\\",
    ...  \\"value\\": \\"true\\"}]}"
    ${l2_hicu_params_to_update}  Catenate  "{\\"persistency\\": \\"notPersistent\\", \\"domainName\\": \\"L2HICU\\",
    ...  \\"parameters\\": [{\\"name\\": \\"rdBearerLogMaskFeatureCfg\\",  \\"value\\": \\"10\\"}]}"
    ${lte_lim_param_to_update}  Catenate  "{\\"persistency\\": \\"notPersistent\\", \\"domainName\\": \\"LteLIM\\",
    ...  \\"parameters\\": [{\\"name\\": \\"LogsAppIdFilter\\",  \\"value\\": \\"10\\"}]}"
    ${params_list}  Create List  ${ccs_params_to_update}  ${l2_hicu_params_to_update}  ${lte_lim_param_to_update}
    FOR  ${params_to_update}  IN  @{params_list}
        Update Rad Parameters Through M2M Command  ${params_to_update}
    END
    Collect VCU Snapshot  directory_name=Snapshot_after_parameters_update


Step6: Check Parameters To Have Non-default Values
    Log  \nStep6: Check parameters to have non-default values  console=true
    ${post_non_default_params}  Run M2M Command  POST  https://${VCU_OAM_IP}/api/licensed/v1/rads/debug-params/operations/fetches  Bearer  ${TOKEN}
    ...  -d "{\\"nonDefaultOnly\\": true}"
    ${operation_id}  Fetch From Right  ${post_non_default_params}  "operationId":"
    ${operation_id}  Fetch From Left  ${operation_id}  "
    ${non_default_params}  Run M2M Command  GET  https://${VCU_OAM_IP}/api/licensed/v1/rads/debug-params/operations/fetches/${operation_id}  Bearer
    ...  ${TOKEN}
    ${non_default_params}  Remove M2M Rad Debug Parameters Output Noise  ${non_default_params}
    Save M2M Output To Json File  output=${non_default_params}
    ...  file_path=RAD_debug_parameters/vcu_non_default_params_after_update.json

    Should Contain  ${non_default_params}  "status":"succeeded"
    ${non_default_params}  Refactor M2M Rad Debug Parameters Output  ${non_default_params}
    ${params_ccs}  Create Dictionary  ERadCcs_AaSysLogInputLevel=5  ERadCcs_AaSysLogOutputLevel=5  ERadCcs_PrintAaSysCom=true
    ...  ERadCcs_PrintAaConfigRaDMaster=true  ERadCcs_PrintAaWcdmaTime=true
    ${params_l2_hicu}  Create Dictionary  rdBearerLogMaskFeatureCfg=10
    ${params_lte_lim}  Create Dictionary  LogsAppIdFilter=10
    FOR  ${domain_details}  IN  @{non_default_params}
        IF  '${domain_details}[domainName]' in ['Ccs', 'L2HICU', 'LteLIM']
            Check Current Values For Given Parameters  ${domain_details}[parameters]  ${PARAMS_${domain_details}[domainName]}
        ELSE
            Should Be Empty  ${domain_details}[parameters]  Parameters from ${domain_details}[domainName] don't have default values.
        END
    END


Update Rad Parameters Through M2M Command
    [Arguments]  ${params_to_update}

    ${post_update_params}  Run M2M Command  POST  https://${VCU_OAM_IP}/api/licensed/v1/rads/debug-params/operations/updates  Bearer  ${TOKEN}
    ...  -d ${params_to_update}
    ${operation_id}  Fetch From Right  ${post_update_params}  "operationId":"
    ${operation_id}  Fetch From Left  ${operation_id}  "
    ${update_params_output}  Run M2M Command  GET  https://${VCU_OAM_IP}/api/licensed/v1/rads/debug-params/operations/updates/${operation_id}  Bearer
    ...  ${TOKEN}
    Should Contain  ${update_params_output}  "status":"succeeded"


Check Current Values For Given Parameters
    [Arguments]  ${current_values}  ${expected_values}

    FOR  ${parameter}  IN  @{current_values}
        ${parameter_name}  Set Variable  ${parameter}[name]
        Should Be Equal As Strings  ${parameter}[currentValue]  ${expected_values}[${parameter_name}]
        ...  ${parameter_name} is ${parameter}[currentValue], not ${expected_values}[${parameter_name}].
    END


TC Setup
    Common VCU Setup
    Modify Resource Search Order  WebEM__vCU__Rad_debug_parameters_M2M_interface
    Login Using M2M Interface  ${VCU_OAM_IP}


TC Teardown
    Logout Using M2M Interface  ${VCU_OAM_IP}
    Common VCU Teardown