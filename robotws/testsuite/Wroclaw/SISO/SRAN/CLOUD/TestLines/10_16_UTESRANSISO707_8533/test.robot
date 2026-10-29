*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    String
Library    json
Library    DateTime
Library    taf.hw.pdu
Library    taf.hw.optical_switch    WITH NAME    optical_switch
Library    taf.selenium.gnb.oam.coam.vdu  WITH NAME  svdu
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Resource    ../../TestCases/TEST/Cloud_TEST_Start_Stop_NR_TestModels.robot
#Resource    ../../TestCases/PM/Cloud_PM_Radio_Module_Thermal_Counters_Monitoring.robot

#Resource    ../../resources/Robot/common_resources.robot
Resource    ../../resources/Robot/setup_teardown.robot
#Resource    ../../resources/tl_init.robot
#Resource    ../../resources/pdu.robot
#Resource    ../../resources/optical_switch.robot
#Resource    ../../resources/scfc.robot
#Resource    ../../resources/aic_test_cases.robot
#Resource    ../../resources/logs.robot
#Resource    ../../resources/vdu_vcu_operations.robot
Resource    ../../resources/Robot/svdu_operations.robot
#Resource    ../../resources/vdu_oam_operations.robot
Resource    ../../resources/Robot/ru_operations.robot
#Resource    ../../../resources/Robot/common_kw.robot
#Resource    ../../resources/call.robot
Resource    ../../resources/variables.robot
Resource    ../../../resources/Robot/common_kw.robot

*** Variables ***
${VDU_SCF_PATH}=       ${CURDIR}/SCF/SCFC_vDU.xml
${VCU_SCF_PATH}=       ${CURDIR}/SCF/SCFC_vCU.xml
${DELTA_FILE_PATH}=    ${CURDIR}/SCF/SCFC_vDU_delta.json

#@{RMOD_SN_LIST}=  LR231902254  LR231902254
@{RMOD_SN_LIST}=  LR231902254  1M190413180  1M230816495
#@{RMOD_SN_LIST}=  SELECT  K9181046216  K9190632468
#@{RMOD_SN_LIST}=  RANDOM  2
#@{RMOD_SN_LIST}=  ALL

*** Test Cases ***
Test
    Set Message Colors
    Set Log Prefix  set_prefix=True
    ${log_to_console}=  Set Variable  True
    ${log_prefix}=  Set Variable  ${info_prefix}

    ${client_id}=  Set Variable  01:D6:EF:CD:B0:B6:32
    ${client_id}=  Remove String  ${client_id}  :
    ${byte_string}=  Evaluate  bytes.fromhex('${client_id}')
    Log  \nbyte_string: ${byte_string}\n  console=True

    ${client_id}=  Set Variable  ff:28:23:2c:3f:00:02:00:00:6f:2a:34:37:35:36:35:36:41:2e:31:30:31:2f:42:4c:32:32:32:30:4e:34:30:33:53
    ${client_id}=  Remove String  ${client_id}  :
    ${byte_string}=  Evaluate  bytes.fromhex('${client_id}')
    Log  \nbyte_string: ${byte_string}\n  console=True

#    ${rmod_ip_addr_list}=  Get Radio Modules Ip Address List
#    Log  \nRmod IPs: ${rmod_ip_addr_list}\n  console=True
#    ${rmod_ip_addr_list}=  radio.Get Ip For All Radio Modules  cloud_server_ip=10.44.192.22
#    Log  \nRmod IPs: ${rmod_ip_addr_list}\n  console=True

#    TC__Cloud_PM_MicroDTX_Activation_Verification
#    ...  scfc_file_path=${VDU_SCF_PATH}  rmod_sn_list=${RMOD_SN_LIST}

#    vDU Rest Login
#    vdu.Perform Parameter Recommissioning  dist_name=MRBTS-8533/MNL-1/MNLENT-1/FEATCADM-1  parameter=actKpiAlarms
#    ...  operation=update  value=true
#    vdu.Perform Parameter Recommissioning  dist_name=MRBTS-8533/MNL-1/MNLENT-1/PMMNL-1  parameter=mtSBTSRMODTemperature
#    ...  operation=update  value=30min  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}

#    ${trigger_time}=  Set Variable  1
#    ${parameters_dict}=  Create Dictionary  faultID=4584  formulaDescription=Custom temperature fault
#    ...  timeToTrigger=${trigger_time}  triggeringFormula=SBTS_RM_MAX_TEMPERATURE > 0
#    ${parameters_list}=  Create List  ${parameters_dict}
#    vdu.Perform Parameter Recommissioning  dist_name=MRBTS-8533/MNL-1/MNLENT-1/TRBLCADM-1  parameter=kpiAlarmTriggers
#    ...  operation=update  value=${parameters_list}  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}

#    vdu.Perform Parameter Recommissioning  dist_name=MRBTS-8533/MNL-1/MNLENT-1/TRBLCADM-1  parameter=actDefaultFaultSnapTriggers
#    ...  operation=update  value=true  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}

#    ${parameters_dict}=  Create Dictionary  faultNumber=4584  snapshotCoverageLevel=Full  triggerType=onFaultDetection
#    ${parameters_list}=  Create List  ${parameters_dict}
#    vdu.Perform Parameter Recommissioning  dist_name=MRBTS-8533/MNL-1/MNLENT-1/TRBLCADM-1  parameter=faultSnapshotTriggers
#    ...  operation=update  value=${parameters_list}  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}

#    vDU Rest Logout

*** Keywords ***
Get counter
    vDU Rest Login
    ${rmod_dn}  ${rmod_runtime_dn}=  vDU RMOD Get Dist Names Based On Serial Number  rmod_sn=LR231902254
    ${M40008C1_counters}=  vdu.Get Counter Values  counter_id=M40008C1  dimension_dn=${rmod_dn}
    TRY
      ${diff_time}=  Subtract Date From Date  date1=${M40008C1_counters[-1]['start_time']}  date2=${None}
    EXCEPT  *IndexError: list index out of range  type=GLOB
      Run Keyword And Continue On Failure
      ...  Fail  msg=Counter was not collected, it should have been !
      Return From Keyword  ${None}
    EXCEPT  ValueError: Unsupported input*  type=GLOB
      Log  Previous counter time was not collected
    ELSE
      ${M40008C1_counter}=  Set Variable  ${M40008C1_counters[-1]['value']}
    END
    ${M40008C1_counter}=  Set Variable  ${M40008C1_counters[-1]['value']}
    Log  M40008C1_counter: ${M40008C1_counter}  console=True
    vDU Rest Logout

