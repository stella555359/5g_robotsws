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
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ute_admin_infomodel    WITH NAME    admin_im

*** Keywords ***

Check Fiber Length Of FR Cablnks
  [Arguments]  ${fr_cablnk_node_set}  ${expected_fiber_length}
  [Documentation]  Verifies if optical fiber length of given set of CABLNK nodes is within expected range (x meters +/- delta %)
  ...  ${fr_cablnk_node_set}: list of dictionaries representing CABLNK Info Model nodes
  ...  (required keys in each dictionary are 'sourcePhysicalPortNo' and 'fiberLength')
  ...  ${expected_fiber_length}: dictionary containing reference values for cablnks' fiberLength,
  ...  e.g.: {'physical_port0': 1.5, 'physical_port1': 2, 'delta': 10}
  FOR  ${node}  IN  @{fr_cablnk_node_set}
      ${delta_fiber_length}=
    ...  evaluate
    ...  ${expected_fiber_length['physical_port${node.sourcePhysicalPortNo}']} * ${expected_fiber_length['delta']}
    ${min_fiber_length}=
    ...  evaluate
    ...  ${expected_fiber_length['physical_port${node.sourcePhysicalPortNo}']} * 100 - ${delta_fiber_length} - 100
    ${max_fiber_length}=
    ...  evaluate
    ...  ${expected_fiber_length['physical_port${node.sourcePhysicalPortNo}']} * 100 + ${delta_fiber_length} + 100
    ${result}=  evaluate
    ...  ${min_fiber_length} < ${node.fiberLength} *100 < ${max_fiber_length}
    ${object_1}=  Set Variable  + FR fiber length for sourcePhysicalPortNo=${node.sourcePhysicalPortNo} is ${node.fiberLength}
    ${object_2}=  Set Variable
      ...  (expected=${expected_fiber_length['physical_port${node.sourcePhysicalPortNo}']}, delta=${expected_fiber_length['delta']}%)
    ${sum_object}=  Set Variable  ${object_1} ${object_2}
    ${object_3}=  Set Variable  - FR fiber length for sourcePhysicalPortNo=${node.sourcePhysicalPortNo} is ${node.fiberLength} whilst expected is
    ${object_4}=  Set Variable  ${expected_fiber_length['physical_port${node.sourcePhysicalPortNo}']} and delta=${expected_fiber_length['delta']}%
    ${sum_object_2}=  Set Variable  ${object_3} ${object_4}
    run keyword if
    ...  '${result}'=='True'
    ...  LOG  ${sum_object}
    ...  console=yes
    ...  run keyword if
    ...  '${result}'=='False'
    ...  run keyword and continue on failure
    ...  FAIL  ${sum_object_2}
  END

BTS SRAN Power Reset
  [Arguments]  ${alias}=default
  Log  Performing BTS power reset.  console=yes
  ${fsm_sn}=  Get From Dictionary   ${CFG['NODES']['${alias}']}    scf_hw_sm_list
  PDU Power Off Port By Serial Number  ${fsm_sn}
  Sleep  20
  PDU Power On Port By Serial Number  ${fsm_sn}
  Wait For Admin Response After Reset  timeout_for_reset=180  alias=${alias}
  Wait Until Keyword Succeeds  240  5  Check IM Active  alias=${alias}

#Check IM Active
#  [Arguments]  ${alias}
#  ${status}=  is_infomodel_connected  alias=${alias}
#  Should Be True  ${status}
#  [Return]  ${status}

BTS Site Reset
  [Arguments]  ${verbose}=true  ${alias}=default
  Log  Performing BTS site reset.  console=${verbose}
  ${status}  ${output}=  Run Keyword And Ignore Error  Reset Site  alias=${alias}
  Run Keyword If  "${status}"=="FAIL"  Log  BTS is unavailable. It's probably already resetting...  console=true
  ${timeout_for_reset}=  Set Variable If  "${status}"=="FAIL"  0  120
  Wait For Admin Response After Reset  timeout_for_reset=${timeout_for_reset}  timeout_for_response=500  alias=${alias}

HW Unit Reset
  [Arguments]  ${serial_number}  ${timeout}=300  ${verbose}=true  ${alias}=default
  [Documentation]  Supported HW:  RMOD, FHS
  Log  Performing ${serial_number} unit reset.  console=${verbose}
  ${rmod_l_dn}=  Info Model Get HW Distname  ${serial_number}  alias=${alias}
  ${rmod_r_ref}=  admin_im.Query Infomodel  query=get object //APEQM_R-1//REF-1 is [distName="${rmod_l_dn}"]  alias=${alias}
  ${rmod_r_dn}=  Replace String Using Regexp  ${rmod_r_ref.dist_name}  /REF-1$  ${EMPTY}
  Reset Unit  dist_name=${rmod_r_dn}  reset_type=Hard  timeout=${timeout}  alias=${alias}

RMOD Power Reset
  [Arguments]  ${serial_number}
  Log  Performing RMOD unit power reset.  console=yes
  PDU Power Off Port By Serial Number  ${serial_number}
  Sleep  20
  PDU Power On Port By Serial Number  ${serial_number}


Convert Serial Number List To Tolerate Short Version
  [Arguments]  ${fr_serial_number_list}
  @{regexed_list}=  Create List
  FOR  ${sn}  IN  @{fr_serial_number_list}
    Append To List  ${regexed_list}  regex".*${sn[2:]}"
  END
  [Return]  ${regexed_list}

#Reset BTS And Wait Until FR Is Available
#  [Arguments]  ${alias}=default
#  BTS SRAN Power Reset  alias=${alias}
#  Info Model FR State Check
#  ...  availabilityStatus
#  ...  Online
#  ...  ${FR_UNDER_TEST_SERIAL_NUMBER}
#  ...  RU_L
#  ...  timeout=${FR_AVAILABILITY_TIMEOUT}
#  ...  alias=${alias}

Perform Action At All Cost
  [Arguments]  ${keyword}  @{args}  &{kwargs}
  ${passed}=  Run Keyword And Return Status  ${keyword}  @{args}  &{kwargs}
  Return From Keyword If  ${passed}
  Reset BTS And Wait Until FR Is Available  alias=${TC_ALIAS}
  Run Keyword And Ignore Error  Setup Radio Module Connection
  Run Keyword  ${keyword}  @{args}  &{kwargs}
#
#Wait For Admin Response After Reset
#  [Arguments]  ${timeout_for_reset}=300  ${timeout_for_response}=400  ${alias}=default
#  wait until keyword succeeds  ${timeout_for_response}  10  Verify FV Mrbts State  Commissioned  ${alias}
#
#Verify FV Mrbts State
#  [Arguments]  ${state}  ${alias}=default
#  ${mrbts_state}=  Get MRBTS State  alias=${TC_ALIAS}
#  ${return_status}=  Should Be True  '${mrbts_state}' == '${state}'
#  [Teardown]  Log  \nMRBTS state = ${mrbts_state}  console=True
