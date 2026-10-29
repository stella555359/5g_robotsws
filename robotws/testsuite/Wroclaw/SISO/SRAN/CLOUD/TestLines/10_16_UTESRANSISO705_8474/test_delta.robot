*** Settings ***
Documentation  To be done
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    json
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/common_resources.robot
Resource    ../../../resources/Robot/common_kw.robot
Resource    ../../resources/variables.robot

*** Variables ***

${VDU_SCF_PATH}=       ${CURDIR}/SCF/SCFC_vDU_8474.xml
${VCU_SCF_PATH}=       ${CURDIR}/SCF/SCFC_vCU_8474.xml
${VDU_DELTA_SCF_PATH}   ${CURDIR}/SCF/Delta_SCFC_vDU_8474.xml

${DELTA_FILE_PATH}=  ${CURDIR}/SCF/delta_update_mix2.json

*** Test Cases ***
Test
    Set Message Colors
    Set Log Prefix  set_prefix=True
    ${log_to_console}=  Set Variable  True
    ${log_prefix}=  Set Variable  ${info_prefix}


    ${lbps_period_params}=  Create Dictionary  lbpsDayOfWeek=Sun  lbpsDuration=20  lbpsStartTimeHour=10
    ...  lbpsStartTimeMinute=44  lbpsSuspended=notSuspended
    ${lbps_period_list}=  Create List  ${lbps_period_params}
    ${updated_params_dict}=  Create Dictionary  lbpsPeriodList=${lbps_period_list}
    ${json_parameters_update_list}=  Create Single Dist Name Json String Old  mo_dn=MRBTS-8474/NRBTS-8474/NRPGRP-1
    ...  updated_params_dict=${updated_params_dict}  distname_operation=update  param_operation=update
    Log  \nJASON string: ${json_parameters_update_list[0]}  console=${log_to_console}

    ${lbps_period_params}=  Create Dictionary  lbpsDayOfWeek=Sun  lbpsDuration=20  lbpsStartTimeHour=10
    ...  lbpsStartTimeMinute=44  lbpsSuspended=notSuspended
    ${lbps_period_list}=  Create List  ${lbps_period_params}
    ${updated_params_dict}=  Create Dictionary  lbpsPeriodList=${lbps_period_list}
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${json_parameters_update_list}=  Create Single Dist Name Json String  mo_dn=MRBTS-8474/NRBTS-8474/NRPGRP-1
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    Log  \nJASON string: ${json_parameters_update_list[0]}  console=${log_to_console}


    ${updated_params_dict}=  Create Dictionary  antennaLabel=Pierwsza_antena
    ${json_parameters_add}=  Create Single Dist Name Json String Old  mo_dn=MRBTS-8474/EQM-1/APEQM-1/RMOD-1/ANTL-1
    ...  updated_params_dict=${updated_params_dict}  distname_operation=update  param_operation=create
    Log  \nJASON string: ${json_parameters_add[0]}  console=${log_to_console}

    ${updated_params_dict}=  Create Dictionary  antennaLabel=Pierwsza_antena
    ${updated_params_oper_dict}=  Create Dictionary  create=${updated_params_dict}
    ${json_parameters_add}=  Create Single Dist Name Json String  mo_dn=MRBTS-8474/EQM-1/APEQM-1/RMOD-1/ANTL-1
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    Log  \nJASON string: ${json_parameters_add[0]}  console=${log_to_console}


    ${updated_params_dict}=  Create Dictionary  antennaLabel=${EMPTY}
    ${json_parameters_delete}=  Create Single Dist Name Json String Old  mo_dn=MRBTS-8474/EQM-1/APEQM-1/RMOD-1/ANTL-1
    ...  updated_params_dict=${updated_params_dict}  distname_operation=update  param_operation=delete
    Log  \nJASON string: ${json_parameters_delete[0]}  console=${log_to_console}

    ${updated_params_dict}=  Create Dictionary  antennaLabel=${EMPTY}
    ${updated_params_oper_dict}=  Create Dictionary  delete=${updated_params_dict}
    ${json_parameters_delete}=  Create Single Dist Name Json String  mo_dn=MRBTS-8474/EQM-1/APEQM-1/RMOD-1/ANTL-1
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    Log  \nJASON string: ${json_parameters_delete[0]}  console=${log_to_console}


    ${json_parameters_mo_delete}=  Create Single Dist Name Json String Old  mo_dn=MRBTS-8474/MNL-1/CMD-1/SWRESETREQ-1
    ...  distname_operation=delete
    Log  \nJASON string: ${json_parameters_mo_delete[0]}  console=${log_to_console}

    ${updated_params_oper_dict}=  Create Dictionary  delete=&{EMPTY}
    ${json_parameters_mo_delete}=  Create Single Dist Name Json String  mo_dn=MRBTS-8474/MNL-1/CMD-1/SWRESETREQ-1
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=delete
    Log  \nJASON string: ${json_parameters_mo_delete[0]}  console=${log_to_console}


    ${updated_params_dict}=  Create Dictionary  swResetLevel=resetToTestLevel
    ${json_parameters_create}=  Create Single Dist Name Json String Old  mo_dn=MRBTS-8474/MNL-1/CMD-1/SWRESETREQ-1
    ...  updated_params_dict=${updated_params_dict}  distname_operation=create  param_operation=update
    Log  \nJASON string: ${json_parameters_create[0]}  console=${log_to_console}

    ${updated_params_dict}=  Create Dictionary  swResetLevel=resetToTestLevel
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${json_parameters_create}=  Create Single Dist Name Json String  mo_dn=MRBTS-8474/MNL-1/CMD-1/SWRESETREQ-1
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=create
    Log  \nJASON string: ${json_parameters_create[0]}  console=${log_to_console}


    ${updated_params_dict}=  Create Dictionary  actPimCancellation=true  pimCancellingEnabled=true
    ${json_parameters_update}=  Create Single Dist Name Json String Old  mo_dn=MRBTS-8474/EQM-1/APEQM-1/RMOD-1
    ...  updated_params_dict=${updated_params_dict}  distname_operation=update  param_operation=update
    Log  \nJASON string: ${json_parameters_update[0]}  console=${log_to_console}

    ${updated_params_dict}=  Create Dictionary  actPimCancellation=true  pimCancellingEnabled=true
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${json_parameters_update}=  Create Single Dist Name Json String  mo_dn=MRBTS-8474/EQM-1/APEQM-1/RMOD-1
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    Log  \nJASON string: ${json_parameters_update[0]}  console=${log_to_console}

    ${updated_params_dict}=  Create Dictionary  actPimCancellation=true  pimCancellingEnabled=true
    ${create_params_dict}=  Create Dictionary  moduleLocation=Rack_1
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}  create=${create_params_dict}
    ${json_parameters_update_create}=  Create Single Dist Name Json String  mo_dn=MRBTS-8474/EQM-1/APEQM-1/RMOD-1
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    Log  \nJASON string: ${json_parameters_update_create[0]}  console=${log_to_console}

    ${updated_params_dict}=  Create Dictionary  actPimCancellation=false  pimCancellingEnabled=false
    ${delete_params_dict}=  Create Dictionary  moduleLocation=${EMPTY}
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}  delete=${delete_params_dict}
    ${json_parameters_update_delete}=  Create Single Dist Name Json String  mo_dn=MRBTS-8474/EQM-1/APEQM-1/RMOD-1
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    Log  \nJASON string: ${json_parameters_update_delete[0]}  console=${log_to_console}

    Log  \nDelta Recommissioning ...\n  console=${log_to_console}

    ${json_parameters_list}=  Create List  ${json_parameters_create[1]}  ${json_parameters_update_create[1]}
    ${json_parameters}=  Create Json String  ${json_parameters_list}
    Log  \nJASON string NEW: ${json_parameters}\n  console=${log_to_console}

    ${rmod_sn_list}=  Create List  K9181046216  K9190632468

    ${json_parameters_list}=  Create List
    ${rmod_sn_count}=  Get Length  ${rmod_sn_list}
    FOR  ${number}  IN RANGE  1  ${rmod_sn_count+1}
      ${lbps_period_mo_dn}=  Set Variable  MRBTS-1/NRBTS-1/NRPGRP-${number}
      ${lbps_period_params}=  Create Dictionary  lbpsDayOfWeek=12  lbpsDuration=30  lbpsStartTimeHour=12
      ...  lbpsStartTimeMinute=12 lbpsSuspended=notSuspended
      ${lbps_period_list}=  Create List  ${lbps_period_params}
      ${updated_params_dict}=  Create Dictionary  lbpsPeriodList=${lbps_period_list}
      ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
      ${distname_json_parameters}=  Create Single Dist Name Json String  mo_dn=${lbps_period_mo_dn}
      ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
      Append To List  ${json_parameters_list}  ${distname_json_parameters[1]}
    END
    ${json_parameters}=  Create Json String  ${json_parameters_list}
    Log  json_parameters: ${json_parameters}  console=${log_to_console}

*** Keywords ***
Create Single Dist Name Json String Old
    [Arguments]  ${mo_dn}  ${updated_params_dict}=&{EMPTY}  ${distname_operation}=update  ${param_operation}=update

    ${json_parameters_list}=  Create List
    ${distname_parameters_list}=  Create List
    FOR  ${distname_parameter_name}  ${distname_parameter_value}  IN  &{updated_params_dict}
      &{distname_parameter_item}=  Run Keyword If  '${param_operation}'=='delete'
      ...  Create Dictionary  parameterName=${distname_parameter_name}  operation=${param_operation}
      ...  ELSE
      ...  Create Dictionary  parameterName=${distname_parameter_name}
      ...  value=${distname_parameter_value}  operation=${param_operation}
      Append To List  ${distname_parameters_list}  ${distname_parameter_item}
    END
    &{json_parameters}=  Run Keyword If  ${updated_params_dict}==&{EMPTY}
    ...  Create Dictionary  distName=${mo_dn}  operation=${distname_operation}
    ...  ELSE
    ...  Create Dictionary  distName=${mo_dn}  operation=${distname_operation}
    ...  parameters=${distname_parameters_list}

    Append To List  ${json_parameters_list}  ${json_parameters}
    ${json_parameters_format}=  Json.Dumps  ${json_parameters_list}
    [Return]  ${json_parameters_format}  ${json_parameters_list}

