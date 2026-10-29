*** Settings ***
Library     OperatingSystem

Library     taf.gnb.oam.coam.vdu              WITH NAME   coam_vdu
Library     python/robot_extension.py         WITH NAME   rbext_py
Library     python/aic_commissioning.py       WITH NAME   aic_comm_py
Library     python/testline_information.py

Resource    testline.robot
Resource    aic_vdu.robot
Resource    scf_checks.robot


*** Variables ***
${P_console}                        ${False}           # output to console can be enabled via "Set Console Output" from testline.robot


*** Keywords ***
Commission Managed Object List For Aic vDU
    [Documentation]
    ...    Keyword for commissioning a Managed Object List for Aic vDU
    ...    Equivalent to 'Commission Managed Object List' but dedicated for Aic vDU
    ...    Please refer to the documentation of the mentioned keyword for more detailed documentation and examples
    ...
    ...    *Scope* AIC gNB
    ...
    ...    | managed_objects | Structure with the objects to be commissionied |
    ...    | gnb_id          | id of the gnb |
    ...    | du_id           | id of the du |
    ...
    [Arguments]    ${managed_objects}     ${gnb_id}=${0}    ${du_id}=0
    ${json_delta}         Evaluate    json.dumps(${managed_objects})   json
    ${config_directory}   testline.Get Test Suite Config Directory

    OperatingSystem.Create File   ${config_directory}/AicVdu_tmp.json   ${json_delta}

    Execute Delta Commissioning For Aic vDU With Json
    ...   ManagedObj_vDU
    ...   ${config_directory}/AicVdu_tmp.json
    ...   ${gnb_id}
    ...   ${du_id}


Full Commissioning vDU
    [Documentation]
    ...    AiC DU commissioning keyword
    ...
    ...    | scf_path |  Path to SCF file |
    ...    | gnb_id | Id/Number of gNB |
    ...    | du_id | Id/Number of DU |
    ...
    [Arguments]   ${scf_path}   ${gnb_id}=0   ${du_id}=0
    aic_vdu.Connect to OAM DU   gnb_id=${gnb_id}  du_id=${du_id}   alias=du_commission

    ${upload_plan_response}   coam_vdu.upload_plan
    ...   path_to_plan_file=${scf_path}
    ...   vdu_connection=du_commission

    Wait Until Keyword Succeeds   3min   5s   Upload Plan Operation Should Be Successful
    ...   ${upload_plan_response['action_id']}

    ${validate_plan_response}   coam_vdu.validate_plan
    ...   plan_id=${upload_plan_response['plan_id']}
    ...   vdu_connection=du_commission

    Wait Until Keyword Succeeds   3min   5s   Validate Plan Operation Should Be Successful
    ...  ${upload_plan_response['plan_id']}
    ...  ${validate_plan_response['action_id']}

    ${activate_plan_response}   coam_vdu.activate_plan
    ...   ${upload_plan_response['plan_id']}
    ...   vdu_connection=du_commission

    Sleep  90s

    Wait Until Keyword Succeeds   20min   30s   Activate Plan Operation Should Be Successful
    ...  ${upload_plan_response['plan_id']}
    ...  ${activate_plan_response['id']}

    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_vdu.disconnect   du_commission


Upload Plan Operation Should Be Successful
    [Documentation]
    ...    AiC DU commissioning keyword
    ...
    ...    *Scope* All in Cloud (AiC) gNB only!
    ...
    [Arguments]  ${action_id}
    ${upload_operation_response}   coam_vdu.get_upload_plan_operation_status
    ...   operation_id=${action_id}
    ...   vdu_connection=du_commission

    Should Be Equal As Strings   ${upload_operation_response['status']}   success


Validate Plan Operation Should Be Successful
    [Documentation]
    ...    AiC DU commissioning keyword
    ...
    ...    *Scope* All in Cloud (AiC) gNB only!
    ...
    [Arguments]   ${plan_id}   ${action_id}
    ${validate_plan_response}   coam_vdu.get_validate_plan_operation_status
    ...   ${plan_id}
    ...   ${action_id}
    ...   vdu_connection=du_commission

    Should Be Equal As Strings   ${validate_plan_response['status']}  success


Activate Plan Operation Should Be Successful
    [Documentation]
    ...    AiC DU commissioning keyword
    ...
    ...    *Scope* All in Cloud (AiC) gNB only!
    ...
    [Arguments]   ${plan_id}   ${action_id}
    ${activate_plan_response}   coam_vdu.get_activate_plan_operation_status
    ...   ${plan_id}
    ...   ${action_id}
    ...   vdu_connection=du_commission

    Should Be Equal As Strings   ${activate_plan_response['status']}   success


Execute Delta Commissioning For Aic vDU
    [Documentation]
    ...    REST API commissioning keyword for AIC vDU.
    ...
    ...    *Scope* All in Cloud (AiC) gNB only!
    ...
    ...    | gnb_id          | id of the gnb |
    ...    | du_id           | id of the du |
    ...    | delta_plan_name | name of the plane the delta commisiong will be executed with |
    ...    | param_list_DU   | List of dictionary containing the distname, parameter name and desired value as shown below |
    ...    | ..              | NOTE: distname must be complete!! |
    ...
    ...    *Example*
    ...    | ${param1} | Create Dictionary | value=35 | dist_name=MRBTS-1/NRBTS-1/NRCELL-1 | p_name=rlpDetDlHarqThreshold |
    ...    | ${param2} | Create Dictionary | value=5  | dist_name=MRBTS-1/NRBTS-1/NRCELL-1 | p_name=rlpRecDlHarqThreshold |
    ...    | ${param3} | Create Dictionary | value=5  | dist_name=MRBTS-1/NRBTS-1/NRCELL-1 | p_name=rlpDetCsiBsiThreshold |
    ...    | ${param4} | Create Dictionary | value=2  | dist_name=MRBTS-1/NRBTS-1/NRCELL-1 | p_name=rlpRecCsiBsiThreshold |
    ...    | ${param5} | create dictionary | value=vDU1_BLR | dist_name=MRBTS-1 | p_name=btsName |
    ...    | ${param_list} | Create list | ${param1} | ${param2} | ${param3} | ${param4} | ${param5} |
    ...    | ${uploaded_scf} | Execute Delta Commissioning For Aic vDU | scf_path=${TEMPDIR} | param_list_DU=${param_list} |
    ...
    [Arguments]   ${delta_plan_name}   ${param_list_DU}   ${gnb_id}=0   ${du_id}=0
    ${scf_file}   Get DU current plan file
    ...   gnb_id=${gnb_id}
    ...   du_id=${du_id}

    scf_checks.Check If Commissioning Is Needed
    ...   param_list=${param_list_DU}
    ...   scf_file=${scf_file}
    Return From Keyword If   not ${P_COMISSIONING_REQUIRED}

    Create vDU plan for delta commissioning
    ...   delta_plan_name=${delta_plan_name}
    ...   gnb_id=${gnb_id}  du_id=${du_id}

    Delta commissioning vDU
    ...   param_list_DU=${param_list_DU}
    ...   gnb_id=${gnb_id}  du_id=${du_id}

    Validate and activate plan for vDU delta commissioning
    ...   gnb_id=${gnb_id}
    ...   du_id=${du_id}


Execute Delta Commissioning For Aic vDU With Json
    [Documentation]
    ...    REST API commissioning keyword for AIC vDU using json interface
    ...
    ...    *Scope* All in Cloud (AiC) gNB only!
    ...
    ...    | delta_plan_name | name of the plane the delta commisiong will be executed with |
    ...    | json_delta_file | path to json file containing delta commissioning data |
    ...    | gnb_id          | id of the gnb |
    ...    | du_id           | id of the du |
    ...
    [Arguments]   ${delta_plan_name}   ${json_delta_file}   ${gnb_id}=0   ${du_id}=0
    Create vDU plan for delta commissioning
    ...   delta_plan_name=${delta_plan_name}
    ...   gnb_id=${gnb_id}
    ...   du_id=${du_id}
    Delta Commissioning Json vDU And Wait For Success
    ...   json_delta_file=${json_delta_file}
    ...   gnb_id=${gnb_id}
    ...   du_id=${du_id}

    
Create vDU plan for delta commissioning
    [Documentation]
    ...
    ...     This keyword creates a delta plan for delta commissioning the vDU. 
    ...     A test scope variable named delta_plan_id to store the plan id is
    ...     created and used by the other keywords to identify the current delta plan. 
    ...     Simulaneous delta commissining of CU or vDU or mutiple vDUs is NOT allowed.
    ...
    ...     | delta_plan_name | name of delta plan |
    ...     | gnb_id          | Id of gnb          |
    ...     | du_id           | Id of du           |
    ...
    [Arguments]   ${delta_plan_name}   ${gnb_id}=0   ${du_id}=0
    ${DU_alias}   aic_vdu.Connect to OAM DU   gnb_id=${gnb_id}   du_id=${du_id}
    BuiltIn.Log   ${\n}Creation of delta plan for DU-${du_id} commissioning with name ${delta_plan_name}   console=${P_console}
    ${delta_plan_list}    coam_vdu.get_delta_plan_info_list   vdu_connection=${DU_alias}

    Run Keyword If   ${delta_plan_list}   coam_vdu.delete_delta_plan_file
    ...   plan_id=${delta_plan_list[0]['plan_id']}
    ...   vdu_connection=${DU_alias}

    ${dict_plan}   coam_vdu.generate_delta_plan
    ...    plan_name=${delta_plan_name}
    ...    vdu_connection=${DU_alias}

    Set Test Variable   ${delta_plan_id}   ${dict_plan['plan_id']}
    coam_vdu.disconnect   ${DU_alias}


Delta commissioning vDU
    [Documentation]
    ...
    ...     This keyword performs delta commissioning of vDU. A list of dictionaries is given
    ...     containing the parameters to be modified. The keys of the dictionary are
    ...     value,  dist_name and p_name.
    ...
    ...     | param_list_DU | list of dictionaries of parameters to be modified |
    ...     | gnb_id        | Id of gnb                                         |
    ...     | du_id         | Id of du                                          |
    ...
    [Arguments]   ${param_list_DU}   ${gnb_id}=0   ${du_id}=0
    BuiltIn.Log   ${\n}Updating DU parameter in delta plan   console=${P_console}
    ${DU_alias}   aic_vdu.Connect to OAM DU   gnb_id=${gnb_id}   du_id=${du_id}

    aic_comm_py.update_parameters_of_delta_plan_vdu
    ...   delta_plan_id=${delta_plan_id}
    ...   param_list=${param_list_DU}
    ...   connection=${DU_alias}

    coam_vdu.disconnect   ${DU_alias}


Validate and activate plan for vDU delta commissioning
    [Documentation]
    ...
    ...     This keyword attempts to validate and activate the delta plan.
    ...     Will fail if any of these 2 actions are not completed successfully.
    ...
    ...     | gnb_id | Id of gnb |
    ...     | du_id  | Id of du  |
    ...
    [Arguments]   ${gnb_id}=0   ${du_id}=0
    BuiltIn.Log   ${\n}Validation of delta plan   console=${P_console}
    ${DU_alias}   aic_vdu.Connect to OAM DU   gnb_id=${gnb_id}   du_id=${du_id}

    ${dict_validate}   coam_vdu.validate_delta_plan
    ...   delta_plan_id=${delta_plan_id}
    ...   vdu_connection=${DU_alias}

    coam_vdu.disconnect   ${DU_alias}

    Wait Until Keyword Succeeds   5x   5s   Validating vDU Delta Plan Operation Should Be Successful
    ...   delta_plan_id=${delta_plan_id}
    ...   action_id=${dict_validate['action_id']}
    ...   gnb_id=${gnb_id}
    ...   du_id=${du_id}

    BuiltIn.Log   ${\n}Activation of delta plan   console=${P_console}
    ${DU_alias}   aic_vdu.Connect to OAM DU   gnb_id=${gnb_id}   du_id=${du_id}
    ${dict_active}   coam_vdu.activate_delta_plan
    ...   delta_plan_id=${delta_plan_id}
    ...   vdu_connection=${DU_alias}

    coam_vdu.disconnect   ${DU_alias}
    Wait Until Keyword Succeeds   5x   60s   Activating vDU Delta Plan Operation Should Be Successful
    ...   delta_plan_id=${delta_plan_id}
    ...   operation_id=${dict_active['id']}
    ...   gnb_id=${gnb_id}
    ...   du_id=${du_id}



### Private ###
Delta Commissioning Json vDU And Wait For Success
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
    ...     | du_id           | Id of du                      |
    ...
    [Arguments]   ${json_delta_file}   ${gnb_id}=0   ${du_id}=0
    ${DU_alias}   aic_vdu.Connect to OAM DU   gnb_id=${gnb_id}   du_id=${du_id}
    ${mo_info_list}   aic_comm_py.admin_to_aic_json   ${json_delta_file}

    ${res}            coam_vdu.provision_vdu_delta_plan
    ...   mo_info_list=${mo_info_list}
    ...   timeout=${30}
    ...   vdu_connection=${DU_alias}
    BuiltIn.Log   ${res}   console=${P_console}

    Should Be Equal As Strings   ${res['status']}   ongoing

    Wait Until Keyword Succeeds   5min   3s   vDU Provision Delta Plan Status Should Be Success
    ...   operation_id=${res['id']}
    ...   gnb_id=${gnb_id}
    ...   du_id=${du_id}

    [Teardown]    Disconnect from OAM DU    ${DU_alias}


vDU Provision Delta Plan Status Should Be Success
    [Documentation]
    ...
    ...     *Scope*  Internal
    ...
    ...     This keyword checks if status=success of the operation provision vdu delta plan.
    ...     Will fail if the status in the response is not success. 
    ...     If the response is failure at some point it will call FATAL ERROR cause the test to fail
    ...
    ...     | operation_id  | id of the operation |
    ...     | gnb_id        | Id of gnb           |
    ...     | du_id         | Id of du            |
    ...
     [Arguments]   ${operation_id}   ${gnb_id}=0   ${du_id}=0
     ${DU_alias}   aic_vdu.Connect to OAM DU   gnb_id=${gnb_id}   du_id=${du_id}

     ${info}   coam_vdu.get_provision_vdu_delta_plan_status
     ...   operation_id=${operation_id}
     ...   timeout=${30}
     ...   vdu_connection=${DU_alias}
     BuiltIn.Log    ${info}   console=${P_console}

     coam_vdu.disconnect   ${DU_alias}
     Run Keyword If  '${info['status']}' == 'failure'  Fatal Error
     Should Be Equal As Strings    ${info['status']}  success


