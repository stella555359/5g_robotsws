*** Settings ***
Documentation  To be done
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
${VDU_SCF_PATH}=       ${CURDIR}/SCF_8471/SCFC_vDU.xml
${VCU_SCF_PATH}=       ${CURDIR}/SCF_8471/SCFC_vCU.xml

#@{RMOD_SN_LIST}=  K9181046216  K9175116255  K9190632468
#@{RMOD_SN_LIST}=  K9181046216  K9175116255
#@{RMOD_SN_LIST}=  SELECT  K9181046216  K9190632468
#@{RMOD_SN_LIST}=  RANDOM  2
#@{RMOD_SN_LIST}=  ALL
@{RMOD_SN_LIST}=  1M193703395  L1174815324

*** Test Cases ***
Test
    Set Message Colors
    Set Log Prefix  set_prefix=True
    ${log_to_console}=  Set Variable  True
    ${log_prefix}=  Set Variable  ${info_prefix}

#    ${result_value}=  Evaluate Xpath  ${VDU_SCF_PATH}
#    ...  .//managedObject[@class='com.nokia.srbts.mnl:TRBLCADM']/list/item/p[@name='faultNumber']/text()
#    Log  \nresult_value:\n${result_value}  console=${log_to_console}

    ${parameters_list}=  Create List
    ${parameters_dict}=  Create Dictionary
    ${item_list}=  Get Elements  source=${VDU_SCF_PATH}
    ...  xpath=//managedObject[@class='com.nokia.srbts.mnl:TRBLCADM']/list[@name="faultSnapshotTriggers"]/item
    FOR  ${item_element}  IN  @{item_list}
      ${element_list}=  Get Elements  source=${item_element}  xpath=.//*
      FOR  ${element}  IN  @{element_list}
        ${element_attribute}=  Get Element Attribute  source=${element}  name=name
        ${element_text}=  Get Element Text  source=${element}  xpath=.
        Set To Dictionary  ${parameters_dict}  ${element_attribute}=${element_text}
      END
      Append To List  ${parameters_list}  ${parameters_dict}
      ${parameters_dict}=  Create Dictionary
    END
    Log  \nparameters_list:\n${parameters_list}\n  console=${log_to_console}

    ${parameters_list}=  Create List
    ${parameters_dict}=  Create Dictionary
    ${item_list}=  Get Elements  source=${VDU_SCF_PATH}
    ...  xpath=//managedObject[@class='com.nokia.srbts.mnl:TRBLCADM']/list[@name="kpiAlarmTriggers"]/item
    FOR  ${item_element}  IN  @{item_list}
      ${element_list}=  Get Elements  source=${item_element}  xpath=.//*
      FOR  ${element}  IN  @{element_list}
        ${element_attribute}=  Get Element Attribute  source=${element}  name=name
#        Log  element_attribute: ${element_attribute}  console=${log_to_console}
        ${element_text}=  Get Element Text  source=${element}  xpath=.
#        Log  element_text: ${element_text}  console=${log_to_console}
        Set To Dictionary  ${parameters_dict}  ${element_attribute}=${element_text}
      END
      Append To List  ${parameters_list}  ${parameters_dict}
      ${parameters_dict}=  Create Dictionary
    END
    Log  \nparameters_list:\n${parameters_list}\n  console=${log_to_console}
