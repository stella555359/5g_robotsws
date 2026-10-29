*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource    ../Resources/Setup/setup_and_teardown.robot
Resource  ./common_setup.robot
Resource  ./site_operations.robot
Resource  ./site_verifications.robot
Resource  ./variables.robot


Library  BuiltIn
Library  Collections
Library  String
Library  robot.libraries.DateTime
#Library  ute_fsmaccess
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ute_admin_infomodel    WITH NAME    admin_im

*** Keywords ***
Create RF Dictionary Fiber Length Description
  [Arguments]  ${tested_rf_list}=${cfg.scf_rmods_under_test}
  ${tested_rf_cablinks}=  Create Dictionary
  FOR  ${rf}  IN  @{tested_rf_list}
    ${rf_cablinks_fiberlength}=  Create RF Cablink Fiber Lenghth Description  ${rf}
    Log Dictionary  ${tested_rf_cablinks}
    Set To Dictionary  ${tested_rf_cablinks}  ${rf}=${rf_cablinks_fiberlength}
  END
  [Return]  ${tested_rf_cablinks}

Create RF Cablink Fiber Lenghth Description
  [Documentation]  KW creates dictiona
  [Arguments]  ${rf_serial_number}
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${rf_serial_number}
  ${cablinks}=  Get Parameters For All  CABLINK  alias=${ru_bts_id}
  ${tested_rf_cablinks}=  Create Dictionary
  FOR  ${cablink}  IN  @{cablinks}
    ${status}=  Run Keyword And Return Status  Should Match Regexp  ${cablink.secondEndpointDN}  ${ru_dist_name}
    Continue For Loop If  not ${status}
    ${cablink_parameter}=  Get Parameters  ${cablink.id}  alias=${ru_bts_id}
    ${port_id}=  Set Variable  ${cablink_parameter['secondEndpointPortId']}
    ${length}=  Set Variable  ${cablink_parameter['fiberLength']}
    ${port_id}=  Convert To String  ${port_id}
    Set To Dictionary  ${tested_rf_cablinks}  ${port_id}=${length}
  END
  [Return]  ${tested_rf_cablinks}

Check Fiber Length Of FR Cablnks
  [Documentation]  Verifies if optical fiber length of given set of CABLNK nodes is within expected range (x meters +/- delta %)
  ...  ${fr_cablnk_node_set}: list of dictionaries representing CABLNK Info Model nodes
  ...  (required keys in each dictionary are 'sourcePhysicalPortNo' and 'fiberLength')
  ...  ${expected_fiber_length}: dictionary containing reference values for cablnks' fiberLength,
  ...  e.g.: {'physical_port0': 1.5, 'physical_port1': 2, 'delta': 10}
  ${tested_rf_cablinks}=  Create RF Dictionary Fiber Length Description
  FOR  ${fr}  IN  @{tested_rf_cablinks}
    Verify Expected Cablink Link  ${fr}  ${tested_rf_cablinks['${fr}']}
  END

Verify Expected Cablink Link
  [Arguments]  ${fr}  ${tested_rf_cablinks}
  ${fr_cablinks}=  Get Dictionary Items  ${tested_rf_cablinks}
  FOR  ${cablink}  IN  @{tested_rf_cablinks}
    ${fr_dict}=  Get From Dictionary  ${RU_DICT}  ${fr}
    ${fiber_length}=  Get From Dictionary  ${fr_dict}  fiber_length
    ${port_number}=  Evaluate  ${cablink}-1
    ${delta_fiber_length}=  evaluate  ${fiber_length['physical_port${port_number}']} * 0.${fiber_length['delta']}
    ${min_fiber_length}=  evaluate  ${fiber_length['physical_port${port_number}']} - ${delta_fiber_length}
    ${max_fiber_length}=  evaluate  ${fiber_length['physical_port${port_number}']} + ${delta_fiber_length}
    ${result}=  evaluate  ${min_fiber_length} < ${tested_rf_cablinks['${cablink}']} < ${max_fiber_length}
    ${verdict}=  Set Variable If  ${result}  PASS  FAIL
    Logging With Timestamp
    ...  FR ${fr} Expected fiber length for PortNo=${cablink} is = ${fiber_length['physical_port${port_number}']} , delta=${fiber_length['delta']}
    run keyword if  '${result}'=='True'
    ...  Logging With Timestamp
    ...  FR ${fr} fiber length for PortNo=${cablink} is = ${tested_rf_cablinks['${cablink}']}
    ...  result=${verdict}
    run keyword if
    ...  '${result}'=='False'
    ...  Run Keywords
    ...  run keyword and continue on failure
    ...  FAIL
    ...  FR ${fr} fiber length for PortNo=${cablink} is ${tested_rf_cablinks['${cablink}']}, expected <> ${min_fiber_length} and ${max_fiber_length}
    ...  AND
    ...  Logging With Timestamp
    ...  FR ${fr} fiber length for PortNo=${cablink} is = ${tested_rf_cablinks['${cablink}']}
    ...  result=FAIL
    ...  AND
    ...  Logging With Timestamp
    ...  should be between ${min_fiber_length} and ${max_fiber_length}
    ...  result=FAIL
  END
#
#Get Radio Compatible SW From TargetBD
#  [Documentation]  In most cases returns a one element list containing compatible SW of given radio variant.
#  ...  In case of FRGP, list will have 2 elements (for FRGP and FRGP_B)
#  [Arguments]  ${variant}  ${download_path}=/home/ute/Downloads/
#  ...  ${ip_addr}=192.168.255.1  ${timeout}=20  ${alias}=default  ${remote_host}=None
#  Run Keyword If  "${remote_host}"=="None"
#  ...  Setup Enb Fsm Access  ip_addr=${ip_addr}  timeout=${timeout}  alias=${alias}
#  ...  ELSE
#  ...  Setup Enb Fsm Access  ip_addr=${ip_addr}  timeout=${timeout}  alias=${alias}  remote_host=${remote_host}
#  ${targetbd_path}=  Get Enb Targetbd File  ${download_path}  alias=${alias}
#  ${radio_compatible_sw_list}=  Get Elements
#  ...  ${targetbd_path}
#  ...  //hwResource[contains(@resourceBuildKey, '${variant}')]/@resourceSWVersion
#  [Teardown]  Teardown Enb Fsm Access  alias=${alias}
#  [Return]  ${radio_compatible_sw_list}
