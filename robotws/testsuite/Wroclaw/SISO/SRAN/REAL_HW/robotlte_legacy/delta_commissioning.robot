*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Library  ute_admin_infomodel    WITH NAME    admin_im
Library  taf.sbts.oam.coam.admin    WITH NAME    admin

Library  BuiltIn
Library  Collections
Library  String
Library  robot.libraries.DateTime

Resource    ../Resources/Setup/setup_and_teardown.robot
Resource  ./common_setup.robot
Resource  ./site_operations.robot
Resource  ./site_verifications.robot
Resource  ./variables.robot




*** Keywords ***
Execute Delta Recommissioning On Every Node
  FOR  ${node}  IN  @{cfg.active_bts_list}
    ${delta_scf_file}=  Delta Commissioning Define JSON File Path  ${node}  ${DELTA}
    Perform Delta File Commissioning  ${node}  ${delta_scf_file}
    Run Keyword If  '${DELTA_RESET}'=='True'  Run Keyword And Continue On Failure  BTS Is Resetting  ${node}
    Verify BTS State  ${node}  600
    Verify Alarms  alias=${node}
  END

Delta Commissioning Define JSON File Path
  [Arguments]  ${node}  ${delta_file_name}
  ${testsuite_name}=  Fetch From Right
  ...  string=${SUITE_SOURCE}
  ...  marker=/
  ${delta_scf_file}=  Replace String Using Regexp
  ...  string=${SUITE_SOURCE}
  ...  pattern=${testsuite_name}
  ...  replace_with=delta_${node}_${delta_file_name}.json
  ${file_status}=  OperatingSystem.File Should Exist
  ...  path=${delta_scf_file}
  [Teardown]  Run Keyword If  '${file_status}'=='${False}'  Fail
  [Return]  ${delta_scf_file}

Perform Delta File Commissioning
  [Arguments]  ${bts_id}  ${delta_scf_file}  ${ignore_errors}=False
  Log  \nBTS Delta commissioning procedure on bts_id node=${bts_id} started  console=True
  Log  \nSource File = ${delta_scf_file}.\nProcedure Parameters: Ignore Errors = ${ignore_errors}.  console=True
  Run Keyword And Ignore Error  admin.Wait Sw Update Possible
  ...  bts_ready=True
  ...  readiness_timeout=900
  ...  timeout=1000
  ...  connection=${bts_id}
  ${result}=  Run Keyword And Continue On Failure  admin.Perform Delta Recommissioning
  ...  delta_file=${delta_scf_file}
  ...  skip_parameter_relation_errors=${ignore_errors}
  ...  should_activate=True
  ...  timeout=1200
  ...  connection=${bts_id}
  ${status}  ${response}=  Run Keyword And Ignore Error
  ...  Set Variable  ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}
  Run Keyword If  '${response}' != 'Success'  Log  Recommissioning failed due to  ${response}
  Should Be True  '${response}' == 'Success'
  [Teardown]  Log  \nBTS template commissioning procedure on bts_id node=${bts_id} finished.  console=True
  [Return]  ${status}  ${result}
