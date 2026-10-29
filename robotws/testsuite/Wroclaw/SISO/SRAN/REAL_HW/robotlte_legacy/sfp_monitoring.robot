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

Resource  hran_ta/resources/ca_BSRF_general.robot


*** Keywords ***
Step 1: Get config parameters
  Log  Step 1: Get config parameters  console=${TRUE}
  _Check if sfp.yaml exists
  ${conf_sfp}  Get dictionary keys  ${SFP}
  _check_sfp_yaml  ${conf_sfp}
  _check_if_lower_than_trunk

Step 2: Check SFP parameters
  [Arguments]  ${alias}=${cfg.primary_node_bts_id}
  Log  Step 2: Check SFP parameters  console=${TRUE}
  ${modules}  Get dictionary keys  ${SFP}
  FOR  ${module}  IN  @{modules}
    _check_sfp_for_module  ${module}  ${alias}
  END

_check_sfp_for_module
  [Arguments]  ${module}  ${alias}=${cfg.primary_node_bts_id}
  ${sfps}  Get dictionary keys  ${SFP}[${module}]
  ${module_name_splt}  Split string  ${module}  _
  ${module_type}  Set variable  ${module_name_splt}[0]
  ${module_sn}  Set variable  ${module_name_splt}[1]
  ${module_obj}  admin_im.Query Infomodel
  ...  get object //${module_type}_R-* is [serialNumber=${module_sn}]
  ...  allow_negative_result=${TRUE}
  ...  alias=${alias}
  Should be true  ${module_obj}  ${module_type} with SN:${module_sn} not exist
  FOR  ${sfp_name}  IN  @{sfps}
    ${sfp_sn_split}  Split string  ${sfp_name}  _
    ${sfp_sn}  Set variable  ${sfp_sn_split}[1]
    ${sfp_obj}  admin_im.Query Infomodel
    ...  get list //SFP_R-* is [serialNumber=${sfp_sn}]
    ...  allow_negative_result=${TRUE}
    ...  timeout=60
    ...  alias=${alias}
    Should be true  ${sfp_obj}[0]  SFP with SN:${sfp_sn} not exist
    Log  Checking parameters for ${module_type} SN:${module_sn} SFP SN:${sfp_sn}  console=${TRUE}
    _parameters checking  ${SFP}[${module}][${sfp_name}]  ${sfp_obj}[0]
  END

_parameters checking
  [Arguments]  ${parameter_pointer_from_file}  ${parameter_pointer_from_IM}
  FOR  ${parameter_from_file}  ${parameter_from_IM}  IN  @{SFP_MAPPING}
    Log  Verify parameter: ${parameter_from_IM}  console=${TRUE}
    Dictionary Should Contain Key
    ...  ${parameter_pointer_from_IM}
    ...  ${parameter_from_IM}
    ...  Parameter ${parameter_from_IM} not exist in IM
    ${var}  Set Variable  ${parameter_pointer_from_file}[${parameter_from_file}]
    ${is_int}  Evaluate  isinstance($var, (int, float))
    Run Keyword If
    ...  ${is_int}
    ...  Should Be Equal As Numbers
    ...  ${parameter_pointer_from_file}[${parameter_from_file}]
    ...  ${parameter_pointer_from_IM}[${parameter_from_IM}]
    ...  Wrong parameter: ${parameter_from_IM}
    ...  ELSE
    ...  Should Be Equal As Strings
    ...  ${parameter_pointer_from_file}[${parameter_from_file}]
    ...  ${parameter_pointer_from_IM}[${parameter_from_IM}]
    ...  Wrong parameter: ${parameter_from_IM}
  END

_Check if sfp.yaml exists
  [Documentation]
  ...  Check if sfp.yam exists in config folder
  ${tl_folder}  Split string from right  ${SUITE_SOURCE}  separator=/  max_split=1
  ${tl_folder}  Set variable  ${tl_folder}[0]/device
  ${sfp_file_name_exist_in_cfg}  Run keyword and return status  Variable should exist  ${sfp_filename}
  ${sfp_filename}  Set variable if  ${sfp_file_name_exist_in_cfg}  ${sfp_filename}  sfp*.yaml
  ${list_sfp_file_paths}  List files in directory  ${tl_folder}  ${sfp_filename}  absolute
  Should not be empty  ${list_sfp_file_paths}  There is no SFP yaml file.
  ${sfp_file_paths_lenght}  Get length  ${list_sfp_file_paths}
  Run keyword if
  ...  ${sfp_file_paths_lenght} > 1
  ...  Fail
  ...  There is more than 1 SFP file. Please provide SFP file name as sfp_filename variable.
  ${sfp_file}  Set variable  ${list_sfp_file_paths}[0]
  ${msg_sfp}  Get Example Yaml Content
  ${blocked_msg}  Set variable  Please create ${sfp_file} with data structure:\n${msg_sfp}
  Set test variable  ${blocked_msg}
  ${passed}  Run keyword and return status  OperatingSystem.file should exist  ${sfp_file}
  Run keyword If  not ${passed}  Fail  ${blocked_msg}
  Run keyword if  ${passed}  Import variables  ${sfp_file}
  ${node_from_yaml}  _get node from imported yaml
  Set test variable  ${SFP}  ${SFP_SBTS_${node_from_yaml}}
  Set test variable  ${RMOD_NODE}  ${node_from_yaml}

_get node from imported yaml
  FOR  ${node}  IN  @{cfg.active_bts_list}
    ${varible_exist}  Run keyword and return status  Variable should exist  ${SFP_SBTS_${node}}
    Return from keyword if  ${varible_exist}  ${node}
  END
  [Return]  ${False}

_check_sfp_yaml
  [Arguments]  ${module_keys_from_yaml}
  @{SFP_MAPPING}  Create list
  ...  transMode  transmissionMode  # transMode not supported in newest trunk
  ...  manufacName  vendorName
  ...  hardwaRev  vendorPartNumber
  ...  trans_rate  transmissionRate
  ...  connType  connectorType
  ...  wave_len  waveLength
  Set test variable  @{SFP_MAPPING}
  FOR  ${module_key_from_yaml}  IN  @{module_keys_from_yaml}
    ${sfp_keys_from_yaml}  Get dictionary keys  ${SFP}[${module_key_from_yaml}]
    _sfp_parameters_from_yaml  ${module_key_from_yaml}  ${sfp_keys_from_yaml}
  END

_sfp_parameters_from_yaml
  [Arguments]  ${module_key_from_yaml}  ${sfp_keys_from_yaml}
  FOR  ${sfp_key_from_yaml}  IN  @{sfp_keys_from_yaml}
    ${parameters_key_from_yaml}  Get dictionary keys  ${SFP}[${module_key_from_yaml}][${sfp_key_from_yaml}]
    List Should Contain Sub List
    ...  ${parameters_key_from_yaml}
    ...  ${SFP_MAPPING}[::2]
    ...  ${sfp_key_from_yaml} parameter list do not contain all expected values
  END

_check_if_lower_than_trunk
  ${active_sw}  Get Software Release  Active  ${cfg.active_bts_list}[0]
  ${sw_number}  Get Regexp Matches  ${active_sw}  \\d+
  ${release_number}  Convert To Integer  ${sw_number}[0]
  ${subrelease_number}  Convert To Integer  ${sw_number}[1]
  Run Keyword If  ${subrelease_number}==4 and ${release_number}==22
  ...  Remove Values From List  ${SFP_MAPPING}  transMode  transmissionMode
  Run Keyword If  ${subrelease_number}>=1 and ${release_number}>=23
  ...  Remove Values From List  ${SFP_MAPPING}  transMode  transmissionMode

Get Example Yaml Content
  [Documentation]
  ...  Return decoded base64 message
  ...
  ...  *AUTHOR*
  ...  daniel.draus@nokia.com
  ${ret}  catenate
  ...  b'U0ZQOgoKICAgIFNNT0RfRjcxNzE4MDQ2MzUgOgoKICAgICAgICBTRlBfVkYxNzM2MDA4WjAgICA6CiAgICAgICAgICAgIHBvcnRfbGFiZWwgICAgOiAgICBS
  ...  Rl9FWFQxCiAgICAgICAgICAgIG1hbnVmYWNOYW1lICAgOiAgICBGSU5JU0FSQ09SUC4KICAgICAgICAgICAgaGFyZHdhUmV2ICAgICA6ICAgIEZUTEY4NTI2
  ...  UDNCTkwtTk4KICAgICAgICAgICAgdHJhbnNfcmF0ZSAgICA6ICAgIDYxMDAKICAgICAgICAgICAgd2F2ZV9sZW4gICAgICA6ICAgIDg1MAogICAgICAgICAg
  ...  ICB0cmFuc01vZGUgICAgIDogICAgTXVsdGltb2RlNQogICAgICAgICAgICBjb25uVHlwZSAgICAgIDogICAgTEMKICAgICAgICAgICAgY3Vycl9yYW5nZSAg
  ...  ICA6ICAgIFswLDIwMF0KICAgICAgICAgICAgdm9sdF9yYW5nZSAgICA6ICAgIFszMTQwLDM1MDBdCiAgICAgICAgICAgIHhQb3dfcmFuZ19kQm0gOiAgICBb
  ...  LTQwLDJdCiAgICAgICAgICAgIHRlbXBfcmFuZ2UgICAgOiAgICBbLTUwLDEwMF0KCiAgICBSTU9EX0Y3MTcxNTI0MzA5IDoKCiAgICAgICAgU0ZQX1ZGMTMz
  ...  NjAwOFpMIDoKICAgICAgICAgICAgcG9ydF9sYWJlbCAgICA6ICAgIE9QVF9JRjEKICAgICAgICAgICAgbWFudWZhY05hbWUgICA6ICAgIEZJTklTQVJDT1JQ
  ...  LgogICAgICAgICAgICBoYXJkd2FSZXYgICAgIDogICAgRlRMRjg1MjZQM0JOTC1OTgogICAgICAgICAgICB0cmFuc19yYXRlICAgIDogICAgNjEwMAogICAg
  ...  ICAgICAgICB3YXZlX2xlbiAgICAgIDogICAgODUwCiAgICAgICAgICAgIHRyYW5zTW9kZSAgICAgOiAgICBNdWx0aW1vZGU1CiAgICAgICAgICAgIGNvbm5U
  ...  eXBlICAgICAgOiAgICBMQwogICAgICAgICAgICBjdXJyX3JhbmdlICAgIDogICAgWzAsMjAwXQogICAgICAgICAgICB2b2x0X3JhbmdlICAgIDogICAgWzMx
  ...  NDAsMzUwMF0KICAgICAgICAgICAgeFBvd19yYW5nX2RCbSA6ICAgIFstNDAsMl0KICAgICAgICAgICAgdGVtcF9yYW5nZSAgICA6ICAgIFstNTAsMTAwXQ=='
  ${ret}  evaluate  base64.b64decode(${ret}).decode("utf-8", "ignore")  base64
  [Return]  ${ret}
