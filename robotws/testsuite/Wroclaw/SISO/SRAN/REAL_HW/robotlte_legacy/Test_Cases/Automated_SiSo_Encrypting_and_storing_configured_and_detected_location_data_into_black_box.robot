*** Settings ***
Documentation  CB009077 - downloads black box files from SMOD, BBMOD, RF and FHS modules and analyses it contents
...  for location information.
...  You can specify which RMOD to test providing serial numbers in RF parameter when calling this test in testsuite.
...  You can specify which FHS to test providing serial numbers in FHS parameter when calling this test in testsuite.
...  You can provide several serial numbers in those parameters using | separator.
...
...  To test this feature GNSS device MUST be present in the configuration.
...  To test this feature the modulePositionInformation structure for each module MUST be configured in SCF.
...
...  Author:  dawid.bak@nokia.com
...  Maintainer:  Dawid Bak

Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Library  taf.transport.ssh  WITH NAME  ssh
Resource  ../hran_ta/resources/ca_BSRF_general.robot
Resource    ./Bbox/Automated_SiSo_RU_BlackBox_enhancements_testing.robot

*** Keywords ***

Check Location Information In Black Box File
  [Documentation]
  ...  Objective of the test is to check if Black Box files are generated on system, baseband, radio and front haul switch modules.
  ...  Black Box files contain encrypted location data.
  ...  Content of each file is verified based on following conditions:
  ...  1. For SMOD and BBMOD:
  ...  -if feature is deactivated file should be empty
  ...  -if feature is activated file should not be empty
  ...  -actual content of the file is not analysed
  ...  2. For RMOD and FHS:
  ...  -if feature is deactivated file shouldn't contain location section
  ...  -if feature is activated file should contain location section
  ...  -content of location section is checked for meaningfull values
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=Check Location Information In Black Box File will be executed
  ...  style=ONGOING

  ${rf_list}=  Set Variable  ${cfg.scf_hw_all_fr_list}
  ${RF_status}=  Run Keyword And Return Status  Variable Should Exist  ${CUSTOM_RADIO_UNIT_LIST}
  ${rf_list}=  Set Variable If  ${RF_status}  ${CUSTOM_RADIO_UNIT_LIST}  ${rf_list}

  ${fhs_list}=  Set Variable  ${cfg.scf_hw_all_fhs_list}
  ${FHS_status}=  Run Keyword And Return Status  Variable Should Exist  ${CUSTOM_FHS_UNIT_LIST}
  ${fhs_list}=  Set Variable If  ${FHS_status}  ${CUSTOM_FHS_UNIT_LIST}  ${fhs_list}

  Log  ${cfg}
  Create Directory  ${cfg.test_logs_path}/BlackBox/
  ${INITIAL_SCF_VALUES_DICT}  Create Dictionary
  Set Test Variable  ${INITIAL_SCF_VALUES_DICT}
  FOR  ${node}  IN  @{cfg.active_bts_list}
    Log  ***** Performing BlackBox check on node ${node} *****${\n}  console=true
    Delete preventParamModifList  bts_id=${node}
    Check If GPS Is Present  bts_id=${node}
    Activate Location Information Storage  bts_id=${node}
    ${BBMOD_PARAMS}  admin.Get parameters for all  BBMOD  alias=${node}
    Set Global Variable  ${BBMOD_PARAMS}
    Create Directory  ${cfg.test_logs_path}/BlackBox/${node}/
    Check Black Box Files on SMODs  bts_id=${node}  content_check=not_empty
    Check Black Box Files on BBMODs  bts_id=${node}  content_check=not_empty
    Check Black Box Files on RFs  bts_id=${node}  content_check=not_empty  rf_list=${rf_list}
    Check Black Box Files on FHSs  bts_id=${node}  content_check=not_empty  fhs_list=${fhs_list}
    Dectivate location information storage  bts_id=${node}
    Check Black Box Files on SMODs  bts_id=${node}  content_check=empty
    Check Black Box Files on BBMODs  bts_id=${node}  content_check=empty
    Check Black Box Files on RFs  bts_id=${node}  content_check=empty  rf_list=${rf_list}
    Check Black Box Files on FHSs  bts_id=${node}  content_check=empty  fhs_list=${fhs_list}
  END
  [Teardown]  Run Keywords
  ...  Restore Initial Configuration
  ...  AND   Common Test Teardown

Delete preventParamModifList
    [Arguments]  ${bts_id}
    [Documentation]  Changes according to CB006530. Necessary to delete value actLocInfoStore from
    ...  preventParamModifList as test needs to change the value of actLocInfoStore.
    ${parameter}  Get Scf  connection=${bts_id}
    ${scfc_xml}  Parse XML  source=${parameter}
    ${preventParamModifList}  Evaluate Xpath  ${scfc_xml}
    ...  boolean(//list[@name='preventParamModifList'])
    Return From Keyword If  '${preventParamModifList}' == 'False'
    ${value} =  Get Element  ${scfc_xml}  //list[@name='preventParamModifList']/p/text()
    Return From Keyword If  'actLocInfoStore' not in '${value}'

    ${delta_part1}  Set Variable  [{"distName":"MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1","operation":"update","parameters"
    ${delta_full}  Set Variable  ${delta_part1}:[{"parameterName":"preventParamModifList","value":"","operation":"delete"}]}]
    Logging With Timestamp
    ...  message=preventParamModifList is going to be deleted because of 24R3 software active.
    ...  style=ONGOING
    ${result}  Perform Delta Recommissioning
    ...  delta_file=${delta_full}
    ...  skip_parameter_relation_errors=True
    ...  should_activate=True
    ...  timeout=360
    ...  connection=${bts_id}
    Should Match  '${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}'  'Success'
    Logging With Timestamp
    ...  message=preventParamModifList deleted because of 24R3 software active.
    ...  style=DONE

Check If GPS Is Present
  [Arguments]  ${bts_id}
  [Documentation]
  ...  Checks if testline is equiped with GNSS device
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | bts_id  | Yes  | bts identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+

  ${gps_status}=  admin.Get GPS Status  timeout=120
  ...  alias=${bts_id}
  ...  detailed_output=False
  ${gps_present}=  Set Variable  ${false}
  FOR  ${gnsse}  IN  @{gps_status['gnsse']}
    ${gps_present}=  Set Variable If  '${gnsse['stateInfo']['operationalState']}'=='enabled'
    ...  ${true}
    ...  ${gps_present}
  END
  Should Be True  condition=${gps_present}
  ...  msg=ERROR: GPS module should be present!

Check Black Box Files on RFs
  [Arguments]  ${bts_id}  ${content_check}  ${rf_list}
  [Documentation]
  ...  For each radio module Black Box file is downloaded and verified for existence/non existence of location information
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | bts_id  | Yes  | bts identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | content_check  | Yes  | allowed values: empty | not_empty  |
  ...  |  |  | specifies what is expected content of location information in the  |
  ...  |  |  | file under verification  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | rf_list  |  | list of tested RMOD serial numbers  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+

  Log  +++ Checking Black Box Files on RFs +++${\n}  console=true
  Create Directory  ${cfg.test_logs_path}/BlackBox/${bts_id}/RF/${content_check}/
  FOR  ${rf}  IN  @{rf_list}
    Continue For Loop If  '${rf}' not in @{cfg.NODES['${bts_id}'].scf_hw_fr_list}
    Log  --- RF S/N:${rf} ---${\n}  console=true
    ${local_path}  Set Variable  ${cfg.test_logs_path}/BlackBox/${bts_id}/RF/${content_check}/${rf}/
    Create Directory  ${local_path}
    ${file_name}  Download File From RF  rf_sn=${rf}
    ...  local_path=${local_path}
    ...  bts_id=${bts_id}
    Check XML File Object Content  local_path=${file_name}
    ...  object_name=moduleDetectedLocation
    ...  content_check=${content_check}
    Check XML File Object Content  local_path=${file_name}
    ...  object_name=moduleConfiguredLocation
    ...  content_check=${content_check}
  END

Check Black Box Files on FHSs
  [Arguments]  ${bts_id}  ${content_check}  ${fhs_list}
  [Documentation]
  ...  For each front haul switch module Black Box file is downloaded and verified for existence/non existence of location information
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | bts_id  | Yes  | bts identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | content_check  | Yes  | allowed values: empty | not_empty  |
  ...  |  |  | specifies what is expected content of location information in the  |
  ...  |  |  | file under verification  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | fhs_list  |  | list of tested FHS serial numbers  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+

  Log  +++ Checking Black Box Files on FHSs +++${\n}  console=true
  Create Directory  ${cfg.test_logs_path}/BlackBox/${bts_id}/FHS/${content_check}/
  FOR  ${fhs}  IN  @{fhs_list}
    Continue For Loop If  '${fhs}' not in @{cfg.NODES['${bts_id}'].scf_hw_fhs_list}
    Log  --- FHS S/N:${fhs} ---${\n}  console=true
    ${local_path}  Set Variable  ${cfg.test_logs_path}/BlackBox/${bts_id}/FHS/${content_check}/${fhs}/
    Create Directory  ${local_path}
    ${file_name}  Download File From FHS  fhs_sn=${fhs}
    ...  bts_id=${bts_id}
    ...  local_path=${local_path}
    Check XML File Object Content  local_path=${file_name}
    ...  object_name=moduleDetectedLocation
    ...  content_check=${content_check}
    Check XML File Object Content  local_path=${file_name}
    ...  object_name=moduleConfiguredLocation
    ...  content_check=${content_check}
  END

Download File From RF
  [Arguments]  ${rf_sn}  ${local_path}  ${bts_id}
  [Documentation]
  ...  Downloads Black Box file from radio module with given serial number.
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | rf_sn  | Yes  | radio module serial number  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | bts_id  | Yes  | bts identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | local_path  | Yes  | local path where downloaded file will be stored  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...
  ...  **Return parameters**
  ...
  ...  +---------------------+--------------------------------------------------+
  ...  | Parameter  | Description  |
  ...  +=====================+==================================================+
  ...  | file_name  | downloaded file name  |
  ...  +---------------------+--------------------------------------------------+

  Log  Connecting to radio module ${rf_sn}...${\n}  console=true
  ${node_number}=  Select SMOD For RU  ${rf_sn}
  radio.Send File Via SCP  ru_serial_number=${rf_sn}
  ...  direction=to_smod
  ...  file_path=/mnt/runtime/rfsw/uoam/permanent.xml
  ...  destination_directory=/ffs/
  Run Keyword If    ${node_number} == 1    Run Keywords
  ...    tafssh.Connect To  192.168.255.1  toor4nsn  oZPS0POrRieRtu  alias=primary
  ...    AND    ssh.Download File  /ffs/permanent.xml  ${local_path}permanent.xml  connection=primary
  ...    ELSE   Run Keywords    tafssh.Connect To  ${CFG.NODES['${bts_id}']['secondary_sm_vm_ip_LMP_address']}  ute  alias=vm${node_number}
  ...    AND    tafssh.Connect To  192.168.255.119  toor4nsn  oZPS0POrRieRtu  proxy=vm${node_number}  alias=secondary
  ...    AND    tafssh.Download File  /ffs/permanent.xml  ${local_path}permanent.xml  connection=secondary
  [Teardown]     Run Keyword If    ${node_number} == 1  ssh.Disconnect  connection=primary
  ...    ELSE    Run Keyword    ssh.Disconnect    connection=secondary
  [Return]  ${local_path}permanent.xml

Download File From FHS
  [Arguments]  ${fhs_sn}  ${bts_id}  ${local_path}
  [Documentation]
  ...  Downloads Black Box file from front haul switch module with given serial number.
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | fhs_sn  | Yes  | front haul switch module serial number  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | bts_id  | Yes  | bts identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | local_path  | Yes  | local path where downloaded file will be stored  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...
  ...  **Return parameters**
  ...
  ...  +---------------------+--------------------------------------------------+
  ...  | Parameter  | Description  |
  ...  +=====================+==================================================+
  ...  | file_name  | downloaded file name  |
  ...  +---------------------+--------------------------------------------------+

  Log  Enabling Root Account on FHS module ${fhs_sn}...${\n}  console=true
  radio.Enable Root Account On FHS  ru_serial_number=${fhs_sn}
  Verify All Cells OnAir  ${bts_id}
  Log  Connecting to FHS module ${fhs_sn}...${\n}  console=true
  radio.Send File Via SCP  ru_serial_number=${fhs_sn}
  ...  direction=to_smod
  ...  file_path=/mnt/runtime/rfsw/uoam/permanent.xml
  ...  destination_directory=/ffs/
  ...  username=toor4nsn
  ...  password=oZPS0POrRieRtu
  ssh.Connect To  192.168.255.1  toor4nsn  oZPS0POrRieRtu  alias=primary
  ssh.Download File  /ffs/permanent.xml  ${local_path}permanent.xml  connection=primary
  ssh.Disconnect  connection=primary
  [Teardown]  Run Keywords  radio.Disable Root Account On FHS  ru_serial_number=${fhs_sn}
  ...  AND  Verify All Cells OnAir  ${bts_id}
  [Return]  ${local_path}permanent.xml

Check XML File Object Content
  [Arguments]  ${local_path}  ${object_name}  ${content_check}
  [Documentation]
  ...  Checks if in given XML file specified object exists. If the object should exist content is checked for meningful
  ...  values as well.
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | local_path  | Yes  | local path where file to be verified is stored  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | object_name  | Yes  | specifies which XML object in the file should undergo verification  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | content_check  | Yes  | allowed values: empty | not_empty  |
  ...  |  |  | specifies what is expected content of the file under verification  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+

  Log
  ...  Veryfing content of the xml object ${object_name} for ${content_check}...${\n}File path: ${local_path}${\n}
  ...  console=true
  ${xml}=  Parse Xml  source=${local_path}
  ...  keep_clark_notation=False
  ...  strip_namespaces=False

  Run Keyword If  '${content_check}'=='empty'
  ...  Element Should Not Exist  source=${xml}
  ...  xpath=//managedObject[@distName='${object_name}']
  ...  message=ERROR: Object ${object_name} should not exist!
  ...  ELSE IF  '${content_check}'=='not_empty'
  ...  Element Should Exist  source=${xml}
  ...  xpath=//managedObject[@distName='${object_name}']
  ...  message=ERROR: Object ${object_name} should exist!
  ...  ELSE  Fail  msg=ERROR: content_check parameter can only take values: empty / not_empty

  Run Keyword If  '${content_check}'=='not_empty'
  ...  Run Keywords
  ...  Element Should Exist  source=${xml}
  ...  xpath=//managedObject[@distName='${object_name}']/parameter/parameterName[text()='Location']
  ...  message=ERROR: Object ${object_name} should have 'Location' node!
  ...  AND  Element Text Should Match  source=${xml}
  ...  pattern=?*
  ...  xpath=//managedObject[@distName='${object_name}']/parameter/parameterName[text()='Location']/../value
  ...  normalize_whitespace=true
  ...  message=ERROR: Node 'Location' of object ${object_name} should have value different than 'None'!

Activate Location Information Storage
  [Arguments]  ${bts_id}
  [Documentation]
  ...  Changes parameters necessary for location information storage feature activation.
  ...  Before activating the feature initial values of related parameters are stored in
  ...  dictionary ${INITIAL_SCF_VALUES_DICT}
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | bts_id  | Yes  | bts identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+

  Log  +++ +++${\n}  console=true
  ${bts_params}  admin.Get parameters for all  BTS  alias=${bts_id}
  Set Test Variable  ${ACTLOCINFOSTORE_OBJECT}  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
  Set To Dictionary  ${INITIAL_SCF_VALUES_DICT}  ${bts_id}=&{EMPTY}
  Log  Gathering information about initial values of SCF parameters related to the feature...${\n}  console=true
  ${initial_scf}  admin.Get Scf  export_type=configurationAndRuntimeObjects
  ...  parameters_save_variant=actualValues
  ...  alias=${bts_id}
  ${initial_scf_xml}  Parse XML  source=${initial_scf}
  ${actLocInfoStore}  Evaluate Xpath  ${initial_scf_xml}
  ...  string(.//managedObject[@distName='${ACTLOCINFOSTORE_OBJECT}']/p[@name='actLocInfoStore']/text())
  Log  Initial value of actLocInfoStore=${actLocInfoStore}${\n}  console=true
  ${accLevSet}  Evaluate Xpath  ${initial_scf_xml}
  ...  string(.//managedObject[@distName='${ACTLOCINFOSTORE_OBJECT}']/p[@name='accLevSet']/text())
  Log  Initial value of accLevSet=${accLevSet}${\n}  console=true
  Set To Dictionary  ${INITIAL_SCF_VALUES_DICT}[${bts_id}]  actLocInfoStore  ${actLocInfoStore}
  Set To Dictionary  ${INITIAL_SCF_VALUES_DICT}[${bts_id}]  accLevSet  ${accLevSet}
  Set To Dictionary  ${INITIAL_SCF_VALUES_DICT}[${bts_id}]  actlocinfostore_object  ${ACTLOCINFOSTORE_OBJECT}

  Log  Performing delta recommissioning for feature activation...${\n}  console=true
  ${delta_id}  Set Variable  activate_cb009077
  admin.Create Delta  delta_id=${delta_id}
  admin.Append Parameter Update To Delta  dist_name=${ACTLOCINFOSTORE_OBJECT}
  ...  parameter=actLocInfoStore
  ...  value=true
  ...  delta_id=${delta_id}
  admin.Append Parameter Update To Delta  dist_name=${ACTLOCINFOSTORE_OBJECT}
  ...  parameter=accLevSet
  ...  value=Low
  ...  delta_id=${delta_id}
  ${delta}  admin.Get Delta  delta_id=${delta_id}
  admin.Perform Delta Recommissioning  delta_file=${delta}
  ...  alias=${bts_id}
  admin.Remove Delta  delta_id=${delta_id}
  Log  Delta recommissioning for feature activation completed!${\n}  console=true

Dectivate location information storage
  [Arguments]  ${bts_id}
  [Documentation]
  ...  Changes parameters necessary for location information storage feature deactivation.
  ...  Test variable ${ACTLOCINFOSTORE_OBJECT} containing SCF object that changed parameters belong to  must exist.
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | bts_id  | Yes  | bts identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+

  Log  +++ +++${\n}  console=true
  Log  Performing parameter recommissioning for feature deactivation...${\n}  console=true
  Log  Updating parameter actLocInfoStore to "false"...${\n}  console=true
  admin.Perform Parameter Recommissioning  dist_name=${ACTLOCINFOSTORE_OBJECT}
  ...  parameter=actLocInfoStore
  ...  value=false
  ...  operation=update
  ...  should_activate=True
  ...  alias=${bts_id}
  Log  Done updating parameter actLocInfoStore to "false"!${\n}  console=true
  Log  Parameter recommissioning for feature deactivation completed!${\n}  console=true

Restore Initial Configuration
  [Documentation]
  ...  Restores BTS configuration to state from the start of the test.
  ...  Delta SCF is created based on test variable ${INITIAL_SCF_VALUES_DICT} where initial values of all parameters
  ...  changed during the test for each node should be stored.
  ...  ${INITIAL_SCF_VALUES_DICT} in each node should contain key actlocinfostore_object which value is SCF object that
  ...  changed parameters belong to.
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com

  Log  +++ +++${\n}  console=true
  Log  Restoring initial configuration...${\n}  console=true
  FOR  ${node}  IN  @{INITIAL_SCF_VALUES_DICT.keys()}
    Log  Preparing delta for node ${node}...${\n}  console=true
    ${delta_id}  Set Variable  restore_config
    admin.Create Delta  delta_id=${delta_id}
    Add Parameters To Delta  parameters_dict=${INITIAL_SCF_VALUES_DICT}[${node}]
    ...  delta_id=${delta_id}
    ${delta}  admin.Get Delta  delta_id=${delta_id}
    admin.Perform Delta Recommissioning  delta_file=${delta}
    ...  alias=${node}
    admin.Remove Delta  delta_id=${delta_id}
    Log  Delta recommissioning completed! Initial configuration on node ${node} restored!${\n}  console=true
  END
  Log  Completed restoring initial configuration!${\n}  console=true

Add Parameters To Delta
  [Arguments]  ${parameters_dict}  ${delta_id}
  [Documentation]
  ...  Keyword itarates over dictionary where parameters that should be changed and their coresponding values are stored
  ...  Each parameter is than added to delta SCF indicated by ${delta_id} either as update or delete operation.
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | parameters_dict | Yes  | dictionary containing parameters to change and their corresponding values  |
  ...  |  |  | Must contain key actlocinfostore_object with SCF object for parameters being changed |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | delta_id  | Yes  | id of delta SCF that parameters will be append to  |
  ...  +-----------------+------+--------------------------------------------------------------------------------------+

  ${object}  Pop From Dictionary  dictionary=${parameters_dict}
  ...  key=actlocinfostore_object
  FOR  ${parameter}  IN  @{parameters_dict.keys()}
    Run Keyword If  '${parameters_dict}[${parameter}]'==''
    ...  admin.Append Parameter Delete To Delta  dist_name=${object}
    ...  parameter=${parameter}
    ...  delta_id=${delta_id}
    ...  ELSE  admin.Append Parameter Update To Delta  dist_name=${object}
    ...  parameter=${parameter}
    ...  value=${parameters_dict}[${parameter}]
    ...  delta_id=${delta_id}
  END

Check Black Box Files on SMODs
  [Arguments]  ${bts_id}  ${content_check}
  [Documentation]
  ...  For each system module Black Box file is downloaded and verified for empty/not empty
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | bts_id  | Yes  | bts identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | content_check  | Yes  | allowed values: empty | not_empty  |
  ...  |  |  | specifies what is expected content of the file under verification  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+

  Log  +++ Checking Black Box Files on SMODs +++${\n}  console=true
  Create Directory  ${cfg.test_logs_path}/BlackBox/${bts_id}/SMOD/${content_check}/
  FOR  ${smod}  IN  @{cfg.NODES['${bts_id}'].scf_hw_sm_list}
    Log  --- SMOD S/N:${smod} ---${\n}  console=true
    ${local_path}  Set Variable  ${cfg.test_logs_path}/BlackBox/${bts_id}/SMOD/${content_check}/${smod}/
    Create Directory  ${local_path}
    ${file_name}  Download File From SMOD  smod_sn=${smod}
    ...  bts_id=${bts_id}
    ...  local_path=${local_path}
    Verify If File Is Empty  local_path=${local_path}${file_name}  content_check=${content_check}
  END

Check Black Box Files on BBMODs
  [Arguments]  ${bts_id}  ${content_check}
  [Documentation]
  ...  For each base band module Black Box file is downloaded and verified for empty/not empty
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | bts_id  | Yes  | bts identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | content_check  | Yes  | allowed values: empty | not_empty  |
  ...  |  |  | specifies what is expected content of the file under verification  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+

  Log  +++ Checking Black Box Files on BBMODs +++${\n}  console=true
  Create Directory  ${cfg.test_logs_path}/BlackBox/${bts_id}/BBMOD/${content_check}/
  FOR  ${bbmod}  IN  @{cfg.NODES['${bts_id}'].scf_hw_bbmod_list}
    Log  --- BBMOD S/N:${bbmod} ---${\n}  console=true
    ${dist_name}  ${productName}  Get BBMOD informations  bbmod_sn=${bbmod}
    Run Keyword If  '${productName}'=='ABIA AirScale Capacity'
    ...  Run Keywords
    ...  Log  \[INFO\] Blackbox file creation not supported for ABIA! Skipping...${\n}  console=true
    ...  AND  Continue For Loop
    ${local_path}  Set Variable  ${cfg.test_logs_path}/BlackBox/${bts_id}/BBMOD/${content_check}/${bbmod}/
    Create Directory  ${local_path}
    ${file_name}  Download File From BBMOD  bbmod_sn=${bbmod}
    ...  bts_id=${bts_id}
    ...  local_path=${local_path}
    Verify If File Is Empty  local_path=${local_path}${file_name}  content_check=${content_check}
  END

Get BBMOD informations
  [Arguments]  ${bbmod_sn}
  [Documentation]
  ...  Retrieves information about product name and SCF dist_name fir given base band module serial number.
  ...  Test variable ${BBMOD_PARAMS} containing return from admin.Get parameters for all  BBMOD
  ...  must exist.
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | bbmod_sn  | Yes  | baseband module serial number  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | bts_id  | Yes  | bts identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...
  ...  **Return parameters**
  ...
  ...  +---------------------+--------------------------------------------------+
  ...  | Parameter  | Description  |
  ...  +=====================+==================================================+
  ...  | dist_name  | base band module SCF identifier  |
  ...  +---------------------+--------------------------------------------------+
  ...  | productName  | product name (ie. ABIA AirScale Capacity)  |
  ...  +---------------------+--------------------------------------------------+

  FOR  ${bbmod}  IN  @{BBMOD_PARAMS}
    ${dist_name}  Set Variable  ${bbmod}[id]
    ${productName}  Set Variable  ${bbmod}[productName]
    Exit For Loop If  '${bbmod}[serialNumber]'=='${bbmod_sn}'
  END
  [Return]  ${dist_name}  ${productName}

Download File From SMOD
  [Arguments]  ${smod_sn}  ${bts_id}  ${local_path}
  [Documentation]
  ...  Downloads Black Box file from system module with given serial number.
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | smod_sn  | Yes  | system module serial number  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | bts_id  | Yes  | bts identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | local_path  | Yes  | local path where downloaded file will be stored  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...
  ...  **Return parameters**
  ...
  ...  +---------------------+--------------------------------------------------+
  ...  | Parameter  | Description  |
  ...  +=====================+==================================================+
  ...  | file_name  | downloaded file name  |
  ...  +---------------------+--------------------------------------------------+


  ${SW_RELEASE}  Check If Current Build Is Newer Than  SBTS25R2_ENB_9999_250107_000011  ${bts_id}
  IF  ${SW_RELEASE}
    ${bbox_path}  Set Variable  /ffs/run/logs/lifetimedata
  ELSE
    ${bbox_path}  Set Variable  /ffs/run/config/lifedata
  END

  ${alias}  ${smod_role}  Connect To SMOD By Serial Number  smod_sn=${smod_sn}
  ...  bts_id=${bts_id}
  ${file_name}  Download BlackBox File  remote_path=${bbox_path}
  ...  local_path=${local_path}
  ...  alias=${alias}
  [Teardown]  Run Keyword If  '${smod_role}'=='master'
  ...  ssh.Disconnect  connection=${alias}
  ...  ELSE IF  '${smod_role}'=='slave'
  ...  Run Keywords
  ...  ssh.Disconnect  connection=${alias}
  ...  AND  ssh.Disconnect  connection=master
  [Return]  ${file_name}

Download File From BBMOD
  [Arguments]  ${bbmod_sn}  ${bts_id}  ${local_path}
  [Documentation]
  ...  Downloads Black Box file from base band module with given serial number.
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | bbmod_dist_name | Yes  | base band module SCF identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | bbmod_sn  | Yes  | baseband module serial number  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | bts_id  | Yes  | bts identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | local_path  | Yes  | local path where downloaded file will be stored  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...
  ...  **Return parameters**
  ...
  ...  +---------------------+--------------------------------------------------+
  ...  | Parameter  | Description  |
  ...  +=====================+==================================================+
  ...  | file_name  | downloaded file name  |
  ...  +---------------------+--------------------------------------------------+
  ${alias}  Connect To BBMOD By SSH  bts_id=${bts_id}  bbmod_serial_number=${bbmod_sn}
  ${file_name}  Download BlackBox File  remote_path=/run/blackbox/
  ...  local_path=${local_path}
  ...  alias=${alias}
  [Teardown]  Run Keyword  ssh.Disconnect  connection=${alias}
  [Return]  ${file_name}

Connect To SMOD By Serial Number
  [Arguments]  ${smod_sn}  ${bts_id}
  [Documentation]
  ...  Connects to system module with given serial number.
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | smod_sn  | Yes  | system module serial number  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | bts_id  | Yes  | bts identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...
  ...  **Return parameters**
  ...
  ...  +---------------------+---------------------------------------------------+
  ...  | Parameter  | Description  |
  ...  +=====================+===================================================+
  ...  | alias  | connection alias  |
  ...  +---------------------+---------------------------------------------------+
  ...  | smod_role  | information if given smod acts as slave or master |
  ...  +---------------------+---------------------------------------------------+

  ${alias}  Set Variable  ssh_smod_${smod_sn}
  ${smod_role}  Run Keyword If  '${cfg.NODES['${bts_id}'].primary_sm}'=='${smod_sn}'
  ...  Set Variable  master
  ...  ELSE IF  '${cfg.NODES['${bts_id}'].secondary_sm}'=='${smod_sn}'
  ...  Set Variable  slave
  ...  ELSE  Fail
  Log  Connecting to system module ${smod_sn} with alias ${alias} as ${smod_role}${\n}  console=true
  Run Keyword If  '${smod_role}'=='master'
  ...  ssh.Connect To  hostname=192.168.255.1
  ...  username=toor4nsn
  ...  password=oZPS0POrRieRtu
  ...  alias=${alias}
  Run Keyword If  '${smod_role}'=='slave'
  ...  Run Keywords
  ...  ssh.Connect To  hostname=192.168.255.1
  ...  username=toor4nsn
  ...  password=oZPS0POrRieRtu
  ...  alias=master
  ...  AND  ssh.Connect To  hostname=fct-4a
  ...  username=toor4nsn
  ...  password=oZPS0POrRieRtu
  ...  proxy=master
  ...  alias=${alias}
  [Return]  ${alias}  ${smod_role}

Connect To BBMOD By DistName
  [Arguments]  ${bbmod_sn}  ${bts_id}
  [Documentation]
  ...  Connects to base band module with given SCF identifier.
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | bbmod_dist_name | Yes  | base band module SCF identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | bbmod_sn  | Yes  | baseband module serial number  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | bts_id  | Yes  | bts identifier  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...
  ...  **Return parameters**
  ...
  ...  +---------------------+--------------------------------------------------+
  ...  | Parameter  | Description  |
  ...  +=====================+==================================================+
  ...  | alias  | connection alias  |
  ...  +---------------------+--------------------------------------------------+

  FOR  ${bbmod}  IN  @{BBMOD_PARAMS}
    ${dist_name}  Set Variable  ${bbmod}[id]
    Exit For Loop If  '${bbmod}[serialNumber]'=='${bbmod_sn}'
  END
  ${bbmod_info}=  admin.Get parameters  dist_name=${dist_name}
  ...  alias=${bts_id}
  Should Be True  '${bbmod_info}[serialNumber]'=='${bbmod_sn}'
  ${position}  Evaluate  (${bbmod_info}[horizontalPosition]-1)*4 + (${bbmod_info}[verticalPosition]-1)
  ${alias}  Set Variable  ssh_bbmod_${bbmod_sn}
  Log  Connecting to system module with alias ssh_smod at IP 192.168.255.1${\n}  console=true
  ssh.Connect To  hostname=192.168.255.1
  ...  username=toor4nsn
  ...  password=oZPS0POrRieRtu
  ...  alias=ssh_smod
  Log
  ...  Connecting to base band module ${bbmod_sn} with alias ${alias} at position fsp${position}s0icom${\n}
  ...  console=true
  ssh.Connect To  hostname=fsp${position}s0icom
  ...  username=toor4nsn
  ...  password=oZPS0POrRieRtu
  ...  proxy=ssh_smod
  ...  alias=${alias}
  [Return]  ${alias}

Download BlackBox File
  [Arguments]  ${remote_path}  ${local_path}  ${alias}
  [Documentation]
  ...  Downloads Black Box file frome remote path to local path using given connection.
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | remote_path  | Yes  | remote path where file will be downloaded from  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | local_path  | Yes  | local path where downloaded file will be stored  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | alias  | Yes  | connection alias  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...
  ...  **Return parameters**
  ...
  ...  +---------------------------+--------------------------------------------------+
  ...  | Parameter  | Description  |
  ...  +===========================+==================================================+
  ...  | ${matching_files_list}[0] | downloaded file name  |
  ...  +---------------------------+--------------------------------------------------+

  ${pattern}  Set Variable  blackbox_stored\\d{14}_geolocation
  Log  Looking for blackbox files at ${remote_path}${\n}  console=true
  ssh.Send Command  command=ls -a ${remote_path}
  ...  connection=${alias}
  ssh.Assert Exit Status  expected_exit_code=0  connection=${alias}
  ${files_at_remote_path}=  ssh.Read Output  connection=${alias}
  ${files_at_remote_path}=  Split String  ${files_at_remote_path}  \n
  @{matching_files_list}=  Get Matches  list=${files_at_remote_path}
  ...  pattern=regexp=${pattern}
  Length Should Be  item=@{matching_files_list}
  ...  length=1
  ...  msg=ERROR: Exactly one blackbox file should exist on module!
  Log  Downloading file from ${remote_path}/${matching_files_list}[0] to ${local_path}${\n}  console=true
  ssh.Download File  remote_path=${remote_path}/${matching_files_list}[0]
  ...  local_path=${local_path}${matching_files_list}[0]
  ...  connection=${alias}
  [Return]  ${matching_files_list}[0]

Verify If File Is Empty
  [Arguments]  ${local_path}  ${content_check}
  [Documentation]
  ...  Checks if file in given local path is either empty or not empty.
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------+------+--------------------------------------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +=================+======+======================================================================================+
  ...  | local_path  | Yes  | local path where file to be verified is stored  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+
  ...  | content_check  | Yes  | allowed values: empty | not_empty  |
  ...  |  |  | specifies what is expected content of the file under verification  |
  ...  +---------------- +------+--------------------------------------------------------------------------------------+

  Log  Veryfing file for ${content_check}...${\n}File path: ${local_path}${\n}  console=true
  Run Keyword If  '${content_check}'=='empty'
  ...  File Should Be Empty  path=${local_path}  msg=ERROR: File not empty!
  ...  ELSE IF  '${content_check}'=='not_empty'
  ...  File Should Not Be Empty  path=${local_path}  msg=ERROR: File empty!
  ...  ELSE  Fail  msg=ERROR: content_check parameter can only take values: empty / not_empty

Connect To BBMOD By SSH
  [Arguments]  ${bts_id}  ${bbmod_serial_number}  ${target_ip}=192.168.255.129  ${platform_type}=multicore  ${timeout}=30
  [Documentation]
  ...  Description:
  ...  KW connects to a specific BBMOD and returns the alias.
  ...
  ...  +------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | Argument               | Man. | Description                                                                                       |
  ...  +========================+======+===================================================================================================+
  ...  | bts_id                 | Yes  | BTS_ID used as alias                                                                              |
  ...  +------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | bbmod_serial_number    | Yes  | Serial number of the BBMOD                                                                        |
  ...  +------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | target_ip              | No   | Target IP address for the connection (default is 192.168.255.129)                                 |
  ...  +------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | timeout                | No   | Timeout in seconds                                                                                |
  ...  +------------------------+------+---------------------------------------------------------------------------------------------------+

  Logging With Timestamp
  ...  message=SSH Send Command On Specific BBMOD
  ${bts_alias_type}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_alias_type
  ${bts_ip_address}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_ip_address
  IF  '${bts_alias_type}' == 'localhost'
    tafssh.Connect To
    ...  hostname=${target_ip}
    ...  username=toor4nsn
    ...  password=oZPS0POrRieRtu
    ...  alias=sm_ssh
  ELSE IF  '${bts_ip_address}'=='${EMPTY}'
    Run Keywords
    ...  tafssh.Connect To
    ...  hostname=${CFG.NODES['${bts_id}']['vm_ip_LMP_address']}
    ...  username=ute
    ...  alias=sm_ssh_proxy
    ...  timeout=${timeout}
    ...  AND  tafssh.Connect To
    ...  hostname=${target_ip}
    ...  username=toor4nsn
    ...  password=oZPS0POrRieRtu
    ...  alias=sm_ssh
    ...  proxy=sm_ssh_proxy
    ...  timeout=${timeout}
  ELSE
    tafssh.Connect To
    ...  hostname=${bts_ip_address}
    ...  username=toor4nsn
    ...  password=oZPS0POrRieRtu
    ...  alias=sm_ssh
  END
  IF  '${platform_type}'=='multicore'
    ${board_type}=  Set Variable    fsp
  ELSE
    ${board_type}=  Set Variable    fct
  END
  ${horizontalPosition}  ${verticalPosition}=  SCFC Get BBMOD Position Id  ${CFG.NODES['${bts_id}']['scf_file_path']}  ${bbmod_serial_number}
  ${horizontalPosition}=  Set Variable If  '${platform_type}'=='multicore'  ${horizontalPosition}  1
  ${verticalPosition}=  Set Variable If  '${platform_type}'=='multicore'  ${verticalPosition}  1
  ${sm_tunnel_needed}=  Set Variable If  ${CFG.NODES['${bts_id}']['scf_active_node']}==${horizontalPosition}  ${False}  ${True}
  ${sm_tunnel_domain}=  Set Variable If  ${CFG.NODES['${bts_id}']['scf_active_node']}==1  4  1
  IF  '${platform_type}'=='multicore'
    ${bbmod_domain_id}=  Set Variable If
    ...  ${horizontalPosition}==1 and ${verticalPosition}==2  1
    ...  ${horizontalPosition}==1 and ${verticalPosition}==3  2
    ...  ${horizontalPosition}==1 and ${verticalPosition}==4  3
    ...  ${horizontalPosition}==2 and ${verticalPosition}==2  5
    ...  ${horizontalPosition}==2 and ${verticalPosition}==3  6
    ...  ${horizontalPosition}==2 and ${verticalPosition}==4  7
    ${processor_number}=  Set Variable  0
  ELSE
    ${bbmod_domain_id}=  Set Variable  0
    ${processor_number}=  Set Variable  1
  END
  IF  '${sm_tunnel_needed}'=='True'
    Run Keywords
    ...  tafssh.Connect To
    ...  hostname=fct-${sm_tunnel_domain}a
    ...  username=toor4nsn
    ...  password=oZPS0POrRieRtu
    ...  alias=sm_ssh_tunnel
    ...  proxy=sm_ssh
    ...  AND  tafssh.Connect To
    ...  hostname=${board_type}${bbmod_domain_id}s${processor_number}icom
    ...  username=toor4nsn
    ...  password=oZPS0POrRieRtu
    ...  proxy=sm_ssh_tunnel
    ...  alias=bb_ssh
  ELSE
    tafssh.Connect To
    ...  hostname=${board_type}${bbmod_domain_id}s${processor_number}icom
    ...  username=toor4nsn
    ...  password=oZPS0POrRieRtu
    ...  proxy=sm_ssh
    ...  alias=bb_ssh
  END
    ${bb_ssh_alias}    Set Variable    bb_ssh
  [Return]  ${bb_ssh_alias}
