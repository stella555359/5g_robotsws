*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    json
Library    taf.hw.pdu
Library    taf.hw.optical_switch    WITH NAME    optical_switch
Library    taf.selenium.gnb.oam.coam.vdu  WITH NAME  svdu
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio

#Resource    ../../resources/Robot/common_resources.robot
#Resource    ../../resources/Robot/setup_teardown.robot
#Resource    ../../resources/tl_init.robot
#Resource    ../../resources/pdu.robot
#Resource    ../../resources/optical_switch.robot
#Resource    ../../resources/scfc.robot
#Resource    ../../resources/aic_test_cases.robot
#Resource    ../../resources/logs.robot
#Resource    ../../resources/vdu_vcu_operations.robot
#Resource    ../../resources/svdu_operations.robot
#Resource    ../../resources/vdu_oam_operations.robot
Resource    ../../resources/Robot/ru_operations.robot
Resource    ../../resources/Robot/vcu_oam_operations.robot
Resource    ../../../resources/common_kw.robot
Resource    ../../../resources/Robot/common_kw.robot
#Resource    ../../resources/call.robot
Resource    ../../resources/variables.robot
Resource    ../../TestCases/PM/Cloud_PM_PIM_Alarms_Triggering.robot
Resource    ../../TestCases/CM/Cloud_CM_vDU_Delta_Recommissioning.robot
Resource    ../../TestCases/TEST/Cloud_TEST_Online_RF_Scanning.robot
Resource    ../../TestCases/PM/Cloud_PM_PIMC_Counters.robot
Resource    ../../TestCases/CM/Cloud_CM_vDU_Commissioning.robot
Resource    ../../TestCases/REC/Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock.robot
Resource    ../../TestCases/PM/Cloud_PM_Radio_Module_Thermal_Counters_Monitoring.robot
Resource    ../../TestCases/PM/Cloud_PM_MicroDTX_Activation_Verification.robot

*** Variables ***
${VDU_SCF_PATH}=       ${CURDIR}/SCF/SCFC_vDU.xml
${VCU_SCF_PATH}=       ${CURDIR}/SCF/SCFC_vCU.xml
${DELTA_FILE_PATH}=    ${CURDIR}/SCF/SCFC_vDU_delta.json

@{CHANNEL_SETUP_LIST}=  1  1  4  1  1  1
@{RMOD_LIST}=           1
&{CHANNELS_SETUP_DICT}  ${1}=${1}  ${2}=${1}  ${3}=${1}  ${4}=${1}  ${5}=${1}  ${6}=${1}
&{CHANNEL_SETUP_DICT}   ${3}=${1}
@{L1181111025_OFF}=      1  1  4  1  1  1
@{L1181111025_ON}=       1  1  1  1  1  1
&{SWITCH_OFF_ALL_DICT}=  L1181111025=@{L1181111025_OFF}
&{SWITCH_ON_ALL_DICT}=   L1181111025=@{L1181111025_ON}

#@{RMOD_SN_LIST}=  K9181046216  K9175116255  K9190632468
#@{RMOD_SN_LIST}=  K9181046216  K9175116255
#@{RMOD_SN_LIST}=  SELECT  K9181046216  K9190632468
#@{RMOD_SN_LIST}=  RANDOM  2
#@{RMOD_SN_LIST}=  ALL

*** Test Cases ***
Test
    Set Message Colors
    Set Log Prefix  set_prefix=True
    ${log_to_console}=  Set Variable  True
    ${log_prefix}=  Set Variable  ${info_prefix}
#    Log  \u00b0C  console=True

#    vDU Rest Login
##    vdu.Get Local Snapshot  directory=${SUITE_LOGS_DIR_PATH}
##    ...  compressed_or_not=False
#    ${pod_info}=  vdu.Get Pods Info
#    vDU Rest Logout

#    ${result_value}=  Evaluate Xpath  ${VDU_SCF_PATH}
#    ...  .//managedObject[@class='com.nokia.srbts.mnl:TRBLCADM']/list/item/p[@name='faultNumber']/text()
#    Log  \nresult_value:\n${result_value}  console=${log_to_console}

#    ${parameters_list}=  Create List
#    ${parameters_dict}=  Create Dictionary
#    ${item_list}=  Get Elements  source=${VDU_SCF_PATH}
#    ...  xpath=//managedObject[@class='com.nokia.srbts.mnl:TRBLCADM']/list[@name="faultSnapshotTriggers"]/item
#    FOR  ${item_element}  IN  @{item_list}
#      ${element_list}=  Get Elements  source=${item_element}  xpath=.//*
#      FOR  ${element}  IN  @{element_list}
#        ${element_attribute}=  Get Element Attribute  source=${element}  name=name
#        ${element_text}=  Get Element Text  source=${element}  xpath=.
#        Set To Dictionary  ${parameters_dict}  ${element_attribute}=${element_text}
#      END
#      Append To List  ${parameters_list}  ${parameters_dict}
#      ${parameters_dict}=  Create Dictionary
#    END
#    Log  \nparameters_list:\n${parameters_list}\n  console=${log_to_console}
#
#    ${parameters_list}=  Create List
#    ${parameters_dict}=  Create Dictionary
#    ${item_list}=  Get Elements  source=${VDU_SCF_PATH}
#    ...  xpath=//managedObject[@class='com.nokia.srbts.mnl:TRBLCADM']/list[@name="kpiAlarmTriggers"]/item
#    FOR  ${item_element}  IN  @{item_list}
#      ${element_list}=  Get Elements  source=${item_element}  xpath=.//*
#      FOR  ${element}  IN  @{element_list}
#        ${element_attribute}=  Get Element Attribute  source=${element}  name=name
##        Log  element_attribute: ${element_attribute}  console=${log_to_console}
#        ${element_text}=  Get Element Text  source=${element}  xpath=.
##        Log  element_text: ${element_text}  console=${log_to_console}
#        Set To Dictionary  ${parameters_dict}  ${element_attribute}=${element_text}
#      END
#      Append To List  ${parameters_list}  ${parameters_dict}
#      ${parameters_dict}=  Create Dictionary
#    END
#    Log  \nparameters_list:\n${parameters_list}\n  console=${log_to_console}


#    ${all_sensors_temperature_dict}  radio.Get Sensors Temperature From RF Logs
#    ...  ru_serial_number=K9181046216  cloud_server_ip=10.42.126.53
#    ${module_temp}  Get From Dictionary  ${all_sensors_temperature_dict}  MODULE
#    Log  \nLog_temperature: ${module_temp}  console=${log_to_console}

#    ${rmods_ip}=  Get IP For All Radio Modules  print_table=False  cloud_server_ip=10.42.126.53
#    Log  NEW RMODS SN/IP: ${rmods_ip}  console=${log_to_console}
#    ${rmod_serial_number_list}=  Get Dictionary Keys  dictionary=${rmods_ip}
#    Log  \nNEW RMODS SN: ${rmod_serial_number_list}  console=${log_to_console}
#    ${rmod_ip_addr_list}=  Get Dictionary Values  dictionary=${rmods_ip}
#    Log  \nNEW RMODS IP: ${rmod_ip_addr_list}  console=${log_to_console}

#    vDU Rest Login
#    ${rmod_ip_addr_list}=  Get Radio Modules Ip Address List
#    Log  \nOld RMODS IP: ${rmod_ip_addr_list}  console=${log_to_console}
#
#    ${rmod_power_dict}=  Get All Radio Module Power  rmod_ip_addr_list=${rmod_ip_addr_list}
#    ...  rmod_serial_number_list=${rmod_serial_number_list}  log_prefix=${info_prefix}
#    Log  \nOld Power: ${rmod_power_dict}  console=${log_to_console}
#    vDU Rest Logout

#    ${client_id}=  Set Variable  31:4D:32:31:32:38:30:37:30:35:32
#    ${client_id}=  Remove String  ${client_id}  :
#    ${byte_string}=  Evaluate  bytes.fromhex('${client_id}')
#    Log  \nbyte_string: ${byte_string}\n  console=True
#
#    ${client_id}=  Set Variable  ff:28:23:2c:3f:00:02:00:00:6f:2a:34:37:35:36:35:36:41:2e:31:30:31:2f:42:4c:32:32:32:30:4e:34:30:33:53
#    ${client_id}=  Remove String  ${client_id}  :
#    ${byte_string}=  Evaluate  bytes.fromhex('${client_id}')
#    Log  \nbyte_string: ${byte_string}\n  console=True

*** Keywords ***
Check Radio Modules Connection From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${fhgw_index}=0  ${rannic_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword checks if the same radio modules are connected to FHGW or RANNIC.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fhgw_index             |  No  | Index of FHGW class instance object list.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rannic_index           |  No  | Index of RANNIC class instance object list.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmods_sn_list}=  Create List
    ${fhgw_rmods_count}=  Get Length  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus}
    ${rannic_rmods_count}=  Get Length  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus}
    FOR  ${rmod_index}  IN RANGE  ${fhgw_rmods_count}
      Append To List  ${rmods_sn_list}
      ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${rmod_index}].serial_number}
    END
    FOR  ${rmod_index}  IN RANGE  ${rannic_rmods_count}
      Append To List  ${rmods_sn_list}
      ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${fhgw_index}].rus[${rmod_index}].serial_number}
    END
    List Should Not Contain Duplicates  ${rmods_sn_list}
    ...  msg=Error in TL configuration file. The same radio modules are connected to FHGW and RANNIC !

Get FHGW Single Radio Module Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${fhgw_index}=0  ${ru_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets radio module parameters from TL configuration init file based on radio module index.
    ...  Radio module is connected to FHGW.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fhgw_index             |  No  | Index of FHGW class instance object list.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ru_index               |  No  | Index of RU (Radio Unit) classes list.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of radio module parameters:
    ...  {'serial_number': '1M190413180', 'pdu_port': 1, 'radio_type': 'AHCA', 'ru_hw_group': 'FRMr5.1_1_4T4R'}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${serial_number}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${ru_index}].serial_number}
    ${pdu_port}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${ru_index}].pdu_port.port_no}
    ${radio_type}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${ru_index}].radio_type}
    ${ru_hw_group}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${ru_index}].ru_hw_group}
    ${rmod_parameters}=  Create Dictionary
    ...  serial_number=${serial_number}  pdu_port=${pdu_port}  radio_type=${radio_type}  ru_hw_group=${ru_hw_group}
    [Return]  ${rmod_parameters}

Get FHGW Radio Modules Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${fhgw_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets radio modules parameters from TL configuration init file.
    ...  Radio modules are connected to FHGW.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fhgw_index             |  No  | Index of FHGW class instance object list.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of radio module parameters, where the key is the radio module serial number:
    ...  {{'1M190413180': {'pdu_port': 1, 'radio_type': 'AHCA', 'ru_hw_group': 'FRMr5.1_1_4T4R'}}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_parameters_dict}=  Create Dictionary
    ${rmods_count}=  Get Length  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus}
    FOR  ${rmod_index}  IN RANGE  ${rmods_count}
      ${serial_number}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${rmod_index}].serial_number}
      ${rmod_parameters}=  Get FHGW Single Radio Module Parameters From Init File
      ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}  ru_index=${rmod_index}
      Remove From Dictionary  ${rmod_parameters}  serial_number
      Set To Dictionary  ${rmod_parameters_dict}  ${serial_number}=${rmod_parameters}
    END
    [Return]  ${rmod_parameters_dict}

Get RANNIC Single Radio Module Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${rannic_index}=0  ${ru_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets radio module parameters from TL configuration init file based on radio module index.
    ...  Radio module is connected to RANNIC.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rannic_index           |  No  | Index of RANNIC class instance object list.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ru_index               |  No  | Index of RU (Radio Unit) classes list.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of radio module parameters:
    ...  {'serial_number': '1M190413180', 'pdu_port': 1, 'radio_type': 'AHCA', 'ru_hw_group': 'FRMr5.1_1_4T4R'}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${serial_number}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus[${ru_index}].serial_number}
    ${pdu_port}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus[${ru_index}].pdu_port.port_no}
    ${radio_type}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus[${ru_index}].radio_type}
    ${ru_hw_group}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus[${ru_index}].ru_hw_group}
    ${rmod_parameters}=  Create Dictionary
    ...  serial_number=${serial_number}  pdu_port=${pdu_port}  radio_type=${radio_type}  ru_hw_group=${ru_hw_group}
    [Return]  ${rmod_parameters}

Get RANNIC Radio Modules Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${rannic_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets radio modules parameters from TL configuration init file.
    ...  Radio modules are connected to RANNIC.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rannic_index           |  No  | Index of RANNIC class instance object list.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of radio module parameters:
    ...  {'serial_number': '1M190413180', 'pdu_port': 1, 'radio_type': 'AHCA', 'ru_hw_group': 'FRMr5.1_1_4T4R'}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_parameters_dict}=  Create Dictionary
    ${rmods_count}=  Get Length  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus}
    FOR  ${rmod_index}  IN RANGE  ${rmods_count}
      ${serial_number}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus[${rmod_index}].serial_number}
      ${rmod_parameters}=  Get RANNIC Single Radio Module Parameters From Init File
      ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}  rannic_index=${rannic_index}  ru_index=${rmod_index}
      Remove From Dictionary  ${rmod_parameters}  serial_number
      Set To Dictionary  ${rmod_parameters_dict}  ${serial_number}=${rmod_parameters}
    END
    [Return]  ${rmod_parameters_dict}
