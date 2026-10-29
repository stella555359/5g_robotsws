*** Settings ***
Library     OperatingSystem

Library     taf.gnb.oam.coam.cu               WITH NAME   coam_cu
Library     python/robot_extension.py         WITH NAME   rbext_py
Library     python/aic_commissioning.py       WITH NAME   aic_comm_py
Library     python/testline_information.py

Resource    testline.robot
Resource    aic_cu.robot
Resource    scf_checks.robot


*** Variables ***
${P_console}     ${False}          # output to console can be enabled via "Set Console Output" from testline.robot


*** Keywords ***
Commission Managed Object List for Aic CU
    [Documentation]
    ...    Keyword for commissioning a Managed Object List for Aic CU
    ...    Equivalent to 'Commission Managed Object List' but dedicated for Aic CU
    ...    Please refer to the documentation of the mentioned keyword for more detailed documentation and examples
    ...
    ...    *Scope* AIC gNB
    ...
    ...    | managed_objects | Structure with the objects to be commissionied |
    ...    | gnb_id          | id of the gnb |
    ...
    [Arguments]   ${managed_objects}   ${gnb_id}=${0}
    ${json_delta}   Evaluate   json.dumps(${managed_objects})   json
    ${config_directory}   testline.Get Test Suite Config Directory
    OperatingSystem.Create File   ${config_directory}/AicCu_tmp.json   ${json_delta}
    Execute Delta Commissioning for Aic CU With Json
    ...   ManagedObj_CU
    ...   ${config_directory}/AicCu_tmp.json
    ...   ${gnb_id}


Full Commissioning CU
    [Documentation]
    ...    AiC CU commissioning keyword
    ...
    ...    | scf_path |  Path to SCF file |
    ...    | gnb_id | Id/Number of gNB |
    ...
    [Arguments]   ${scf_path}   ${gnb_id}=0
    aic_cu.Connect to OAM CU   gnb_id=${gnb_id}    alias=cu_commission
    ${result_upload}   coam_cu.upload_plan_file    ${scf_path}   connection=cu_commission

    Wait Until Keyword Succeeds   3min   5s   Check If CU Plan Upload Successful
    ...   ${result_upload["action_id"]}
    ${validate_result}   coam_cu.plan_validation    ${result_upload["plan_id"]}   connection=cu_commission

    Wait Until Keyword Succeeds    3min   5s  Check If CU Plan Validate Successful
    ...   ${result_upload["plan_id"]}
    ...   ${validate_result["action_id"]}

    ${activate_result}   coam_cu.plan_activation   ${result_upload["plan_id"]}   connection=cu_commission

    Wait Until Keyword Succeeds    20min   30s  Check If CU Plan Activate Successful
    ...   ${result_upload["plan_id"]}
    ...   ${activate_result["id"]}
    ...   ${gnb_id}
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_cu.disconnect   cu_commission


Check If CU Plan Upload Successful
    [Documentation]
    ...    AiC CU commissioning keyword
    ...
    ...    *Scope* All in Cloud (AiC) gNB only!
    ...
    [Arguments]   ${operation_id}
    ${operation_response}  coam_cu.get_operation_state_of_uploading_plan
    ...   operation_id=${operation_id}
    ...   connection=cu_commission
    Should Be Equal As Strings   ${operation_response["status"]}   success


Check If CU Plan Validate Successful
    [Documentation]
    ...    AiC CU commissioning keyword
    ...
    [Arguments]   ${plan_id}   ${operation_id}
    ${operation_response}   coam_cu.get_operation_state_of_validating_plan
    ...   plan_id=${plan_id}
    ...   operation_id=${operation_id}
    ...   connection=cu_commission
    Should Be Equal As Strings   ${operation_response["status"]}   success


Check If CU Plan Activate Successful
    [Documentation]
    ...    AiC CU commissioning keyword
    ...
    ...    *Scope* All in Cloud (AiC) gNB only!
    ...
    [Arguments]   ${plan_id}   ${operation_id}   ${gnb_id}=0
    aic_cu.Connect to OAM CU   gnb_id=${gnb_id}   alias=cu_activate_commission
    ${operation_response}   coam_cu.get_operation_state_of_activating_plan
    ...   plan_id=${plan_id}
    ...   operation_id=${operation_id}
    ...   connection=cu_activate_commission
    Should Be Equal As Strings   ${operation_response["status"]}   success
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_cu.disconnect   cu_activate_commission


Execute Delta Commissioning For Aic CU
    [Documentation]
    ...    REST API commissioning keyword for AIC CU.
    ...
    ...    *Scope* All in Cloud (AiC) gNB only!
    ...
    ...    | gnb_id          | id of the gnb |
    ...    | delta_plan_name | name of the plane the delta commisiong will be executed with |
    ...    | param_list_CU   | List of dictionary containing the distname, parameter name and desired value as shown below |
    ...    | ..              | NOTE: distname must be complete!! |
    ...
    ...    *Example*
    ...    | ${param1} | Create Dictionary | value=35 | dist_name=MRBTS-1/NRBTS-1/NRCELL-1 | p_name=rlpDetDlHarqThreshold |
    ...    | ${param2} | Create Dictionary | value=5  | dist_name=MRBTS-1/NRBTS-1/NRCELL-1 | p_name=rlpRecDlHarqThreshold |
    ...    | ${param3} | Create Dictionary | value=5  | dist_name=MRBTS-1/NRBTS-1/NRCELL-1 | p_name=rlpDetCsiBsiThreshold |
    ...    | ${param4} | Create Dictionary | value=2  | dist_name=MRBTS-1/NRBTS-1/NRCELL-1 | p_name=rlpRecCsiBsiThreshold |
    ...    | ${param5} | create dictionary | value=vDU1_BLR | dist_name=MRBTS-1 | p_name=btsName |
    ...    | ${param_list} | Create list | ${param1} | ${param2} | ${param3} | ${param4} | ${param5} |
    ...    | ${uploaded_scf} | Execute Delta Commissioning For Aic CU | scf_path=${TEMPDIR} | param_list_CU=${param_list} |
    ...
    [Arguments]   ${delta_plan_name}   ${param_list_CU}   ${gnb_id}=0
    ${scf_file}   aic_cu.Get CU Current Plan File   gnb_id=${gnb_id}
    scf_checks.Check If Commissioning Is Needed
    ...   param_list=${param_list_CU}
    ...   scf_file=${scf_file}
    Return From Keyword If   not ${P_COMISSIONING_REQUIRED}

    Create CU Plan For Delta Commissioning
    ...   delta_plan_name=${delta_plan_name}
    ...   gnb_id=${gnb_id}

    Delta Commissioning CU
    ...   param_list_CU=${param_list_CU}
    ...   gnb_id=${gnb_id}

    Validate And Activate Plan For CU Delta Commissioning   gnb_id=${gnb_id}


Execute Delta Commissioning for Aic CU With Json
    [Documentation]
    ...    REST API commissioning keyword for AIC CU using json interface
    ...
    ...    *Scope* All in Cloud (AiC) gNB only!
    ...
    ...    | delta_plan_name | name of the plane the delta commisiong will be executed with |
    ...    | json_delta_file | path to json file containing delta commissioning data |
    ...    | gnb_id          | id of the gnb |
    ...
    [Arguments]  ${delta_plan_name}    ${json_delta_file}    ${gnb_id}=0
    Create CU Plan For Delta Commissioning             delta_plan_name=${delta_plan_name}  gnb_id=${gnb_id}
    Delta commissioning json CU and wait for success   json_delta_file=${json_delta_file}  gnb_id=${gnb_id}


Create CU Plan For Delta Commissioning
    [Documentation]
    ...
    ...     This keyword creates a delta plan for delta commissioning the CU. 
    ...     A test scope variable named delta_plan_id to store the plan id is
    ...     created and used by the other keywords to identify the current delta plan. 
    ...     Simulaneous delta commissining of CU and vDU is NOT allowed.
    ...
    ...     | delta_plan_name | name of delta plan |
    ...     | gnb_id          | Id of gnb          |
    ...
    [Arguments]   ${delta_plan_name}   ${gnb_id}=0
    ${CU_alias}   aic_cu.Connect to OAM CU   gnb_id=${gnb_id}
    BuiltIn.Log   ${\n}Creation of delta plan for CU commissioning with name ${delta_plan_name}   console=${P_console}
    ${delta_plan_list}   coam_cu.get_delta_plan_list   connection=${CU_alias}

    Run Keyword If   ${delta_plan_list}   coam_cu.delete_delta_plan
    ...   plan_id=${delta_plan_list[0]['plan_id']}
    ...   connection=${CU_alias}

    ${dict_plan}   coam_cu.generate_delta_plan   plan_name=${delta_plan_name}   connection=${CU_alias}
    Set Test Variable    ${delta_plan_id}   ${dict_plan['plan_id']}
    coam_cu.disconnect   ${CU_alias}


Delta Commissioning CU
    [Documentation]
    ...
    ...     This keyword performs delta commissioning of CU. A list of dictionaries is given
    ...     containing the parameters to be modified. The keys of the dictionary are
    ...     value, dist_name and p_name.
    ...
    ...     | param_list_CU | list of dictionaries of parameters to be modified |
    ...     | gnb_id        | Id of gnb                                         |                                         |
    ...
    [Arguments]   ${param_list_CU}   ${gnb_id}=0
    BuiltIn.Log   ${\n}Updating CU parameter in delta plan   console=${P_console}
    ${CU_alias}   aic_cu.Connect to OAM CU   gnb_id=${gnb_id}
    aic_comm_py.update_parameters_of_delta_plan_cu
    ...   delta_plan_id=${delta_plan_id}
    ...   param_list=${param_list_CU}
    ...   connection=${CU_alias}
    coam_cu.disconnect   ${CU_alias}


Validate And Activate Plan For CU Delta Commissioning
    [Documentation]
    ...
    ...     This keyword attempts to validate and activate the delta plan. 
    ...     Will fail if any of these 2 actions are not completed successfully.
    ...
    ...     | gnb_id | Id of gnb |
    ...
    [Arguments]    ${gnb_id}=0
    BuiltIn.Log   ${\n}Validation of delta plan   console=${P_console}
    ${CU_alias}   aic_cu.Connect to OAM CU   gnb_id=${gnb_id}
    ${dict_validate}   coam_cu.validate_delta_plan   plan_id=${delta_plan_id}   connection=${CU_alias}
    coam_cu.disconnect   connection=${CU_alias}

    Wait Until Keyword Succeeds   5x   5s   Validating CU Delta Plan Operation Should Be Successful
    ...   plan_id=${delta_plan_id}
    ...   action_id=${dict_validate['action_id']}
    ...   gnb_id=${gnb_id}

    BuiltIn.Log   ${\n}Activation of delta plan   console=${P_console}
    ${CU_alias}   aic_cu.Connect to OAM CU   gnb_id=${gnb_id}
    ${dict_active}   coam_cu.activate_delta_plan   plan_id=${delta_plan_id}   connection=${CU_alias}
    coam_cu.disconnect    connection=${CU_alias}

    Wait until keyword succeeds   3x  30s   Activating CU Delta Plan Operation Should Be Successful
    ...    plan_id=${delta_plan_id}
    ...    operation_id=${dict_active['operation_id']}
    ...    gnb_id=${gnb_id}




### Private ###
Validating CU Delta Plan Operation Should Be Successful
    [Documentation]
    ...
    ...     *Scope*  Internal
    ...
    ...     This keyword check if status=success for validation of CU delta plan. 
    ...     Will fail if status in response not success.
    ...
    ...     | delta_plan_id | id of delta plan           |
    ...     | action_id     | Id of validation procedure |
    ...     | gnb_id        | Id of gnb                  |
    ...
    [Arguments]   ${delta_plan_id}   ${action_id}    ${gnb_id}=0
    ${CU_alias}   aic_cu.Connect to OAM CU   gnb_id=${gnb_id}
    ${res}   coam_cu.get_action_state_of_validating_delta_plan   ${delta_plan_id}   ${action_id}   connection=${CU_alias}
    Should Be Equal As Strings   ${res['status']}   success
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_cu.disconnect   ${CU_alias}


Activating CU Delta Plan Operation Should Be Successful
    [Documentation]
    ...
    ...     *Scope*  Internal
    ...
    ...     This keyword check if status=success for activation of CU delta plan. 
    ...     Will fail if status in response not success.
    ...
    ...     | delta_plan_id | id of delta plan           |
    ...     | operation_id  | Id of activation procedure |
    ...     | gnb_id        | Id of gnb                  |
    ...
    [Arguments]   ${delta_plan_id}   ${operation_id}   ${gnb_id}=0
    ${CU_alias}   aic_cu.Connect to OAM CU   gnb_id=${gnb_id}
    ${res}   coam_cu.get_operation_state_of_activating_delta_plan   ${delta_plan_id}   ${operation_id}   connection=${CU_alias}
    BuiltIn.Log   ${res}   console=${P_console}
    Should Be Equal As Strings   ${res['status']}   success
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_cu.disconnect   ${CU_alias}


Delta commissioning json CU and wait for success
    [Documentation]
    ...
    ...     *Scope*  Internal
    ...
    ...     Perform delta commissioning and wait for success. 
    ...     Fails if operation returns failure or does not reach success in 5min. 
    ...     Json delta file format following the protocol defined for taf.sbts.oam.coam.admin.
    ...
    ...     | json_delta_file | json file delta commissioning |
    ...     | gnb_id          | Id of gnb                     |
    ...
    [Arguments]   ${json_delta_file}   ${gnb_id}=0
    ${CU_alias}   aic_cu.Connect to OAM CU   gnb_id=${gnb_id}
    ${mo_info_list}   aic_comm_py.admin_to_aic_json  ${json_delta_file}
    ${res}   coam_cu.provision_vcu_delta_plan   mo_info_list=${mo_info_list}   timeout=${30}   connection=${CU_alias}
    BuiltIn.Log    ${res}   console=${P_console}
    Should Be Equal As Strings    ${res['status']}   ongoing
    Wait Until Keyword Succeeds   5min   3s   CU provision delta plan status should be Success
    ...   operation_id=${res['id']}   gnb_id=${gnb_id}


CU provision delta plan status should be Success
    [Documentation]
    ...
    ...     *Scope*  Internal
    ...
    ...     This keyword checks if status=success of the operation provision cu delta plan. 
    ...     Will fail if the status in the response is not success. 
    ...     If the response is failure at some point it will call FATAL ERROR cause the test to fail.
    ...
    ...     | operation_id | Id of the operation |
    ...     | gnb_id       | Id of gnb           |
    ...
   [Arguments]   ${operation_id}   ${gnb_id}=0
   ${CU_alias}   aic_cu.Connect to OAM CU   gnb_id=${gnb_id}
   ${info}   coam_cu.get_provision_vcu_delta_plan_status   operation_id=${operation_id}   timeout=${30}   connection=${CU_alias}
   BuiltIn.Log   ${info}   console=${P_console}
   coam_cu.disconnect   ${CU_alias}
   Run Keyword If   '${info['status']}'=='failure'   Fatal Error
   Should Be Equal As Strings    ${info['status']}   success
