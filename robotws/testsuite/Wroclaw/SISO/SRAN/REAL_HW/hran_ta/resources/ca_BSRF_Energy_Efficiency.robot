*** Settings ***
Documentation    Maintainer: mateusz.kawka@nokia.com
...  Resource for Energy Efficiency

Library    ca_BSRF_excel_operation.py  WITH NAME  excel
Library    Collections
Library    String
Library    DateTime
Resource   ca_BSRF_general.robot

*** Variables ***
&{custom_beam_pattern_id_dict}  AEQQ=${976}

*** Keywords ***

Get Average SBTS Counter Value
    [Arguments]  ${counter_name}  ${sbts_counters}
    [Documentation]
    ...  KW unzips API dictionary with SBTS counters
    ...  calculates average value
    ...  and sends counters to Excel file.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${counters_path}    Set Variable If
    ...    ${NEW_COUNTERS_PATH}
    ...    ${sbts_counters['BTS']['MRBTS-${BTS_ID}']['SBTS_Energy_Consumption']}
    ...    ${sbts_counters['BTS']['BTS']['MRBTS-${BTS_ID}']['SBTS_Energy_Consumption']}

    ${sm_counter_dict}  Get From Dictionary    ${counters_path}  ${counter_name}
    ${sm_counter_values_to_excel}  Get Dictionary Values  ${sm_counter_dict}
    ${sm_counter_values}  Get Slice From List  ${sm_counter_values_to_excel}  -${INTERVAL_AMOUNT}
    Run Keyword If  len(${sm_counter_values})!=${${INTERVAL_AMOUNT}}  Run Keywords
    ...  Log To Console  Too less counters gathered, please check logs !${\n}
    ...  AND  Run Keyword And Continue On Failure
    ...  Fail  Too less counters gathered, please check logs and excel report: ${PATH_TO_REPORT_FILE}/${REPORT_NAME} !

    excel.Append To Specified Cell Excel File
    ...  path_to_file=${PATH_TO_REPORT_FILE}/${REPORT_NAME}
    ...  cell_value=SBTS
    ...  start_row=${1}  end_row=${1}  start_column=${1}  end_column=${3}
    ...  bold=True
    ...  sheet_name=${COUNTERS_SHEET_NAME}

    Run Keyword If  '${counter_name}'=='M40002C0'
    ...  excel.Append Column With Data To Excel File
    ...  ${PATH_TO_REPORT_FILE}/${REPORT_NAME}  ${sm_counter_values_to_excel}  A2  ${counter_name}  ${COUNTERS_SHEET_NAME}
    ...  ELSE IF  '${counter_name}'=='M40002C1'
    ...  excel.Append Column With Data To Excel File
    ...  ${PATH_TO_REPORT_FILE}/${REPORT_NAME}  ${sm_counter_values_to_excel}  B2  ${counter_name}  ${COUNTERS_SHEET_NAME}
    ...  ELSE IF  '${counter_name}'=='M40002C2'
    ...  excel.Append Column With Data To Excel File
    ...  ${PATH_TO_REPORT_FILE}/${REPORT_NAME}  ${sm_counter_values_to_excel}  C2  ${counter_name}  ${COUNTERS_SHEET_NAME}

    ${average_counter_per_h}  Evaluate  round((sum(${sm_counter_values})/len(${sm_counter_values}))*${INTERVAL_AMOUNT}, 2)

    [Return]  ${average_counter_per_h}

Collect Counters And Send To Excel
    [Arguments]  ${type}  ${counters}  ${alias}=default
    [Documentation]
    ...  KW collects requested PM counters and sends them to Excel file.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${excel_column}  excel.Get First Empty Column Excel File
        ...  path_to_file=${PATH_TO_REPORT_FILE}/${REPORT_NAME}
        ...  int_or_letter=letter
        ...  sheet_name=${COUNTERS_SHEET_NAME}

    ${counters_list}  Split string  ${counters}  ,

    ${pm_counter}  admin.Get Pm Counters  ${counters}  timeout=100s  alias=${alias}

    ${counters_dict}  Run Keyword If  '${type}'=='RFM'
    ...  Send RFM Counters To Excel File  ${pm_counter}
    ...  ELSE IF  '${type}'=='SM'
    ...  Send SM Counters To Excel File  ${pm_counter}  alias=${alias}

Send RFM Counters To Excel File
    [Arguments]  ${counters_dict}
    [Documentation]
    ...  KW unzips API dictionary with RM counters and sends counters to Excel file.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${rmod_keys}    Set Variable If
    ...    ${NEW_COUNTERS_PATH}
    ...    ${counters_dict['BTS']['MRBTS-${BTS_ID}']['EQM-1']['APEQM-1']}
    ...    ${counters_dict['BTS']['BTS']['MRBTS-${BTS_ID}']}

     ${rmods_keys_list}  Get Dictionary Keys  ${rmod_keys}

    ${dict_of_rmod_counters}
    ...  Evaluate  (__import__('collections').OrderedDict(sorted(${rmod_keys}.items())))

    FOR  ${key}  ${value}  IN ZIP  ${dict_of_rmod_counters.keys()}  ${dict_of_rmod_counters.values()}
        ${counters_dict}  Get From Dictionary  ${value}  SBTS_RFM_Energy_Monitoring
        ${counters_dict}  Evaluate  (__import__('collections').OrderedDict(sorted(${counters_dict}.items())))
        Send Counters to Excel File  ${counters_dict}  ${RFM_COUNTERS}  ${key}
    END

    ${start_column}  Set Variable  ${4}
    ${end_column}  Set Variable  ${start_column+5}
    FOR  ${rm}  IN  @{rmods_keys_list}
        excel.Append To Specified Cell Excel File
        ...  path_to_file=${PATH_TO_REPORT_FILE}/${REPORT_NAME}
        ...  cell_value=${rm}
        ...  start_row=${1}  end_row=${1}  start_column=${start_column}  end_column=${end_column}
        ...  bold=True
        ...  sheet_name=${COUNTERS_SHEET_NAME}
        ${start_column}  Set Variable  ${start_column+6}
        ${end_column}  Set Variable  ${end_column+6}
    END

    Set Test Variable  ${LAST_COLUMN}  ${end_column-5}

Send SM Counters To Excel File
    [Arguments]  ${counters_dict}  ${alias}=default
    [Documentation]
    ...  KW unzips API dictionary with SM counters and sends counters to Excel file.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${smods}  admin.Get Parameters For All  SMOD  alias=${alias}

    ${not_as_counter}  Set Variable  ${0}
    FOR  ${smod}  IN  @{smods}
        ${not_as_counter}  Set Variable If  'AirScale' not in '${smod['productName']}'  ${not_as_counter+1}  ${not_as_counter}
    END

    ${smod_keys}  Set Variable If
    ...    ${NEW_COUNTERS_PATH}
    ...    ${counters_dict['BTS']['MRBTS-${BTS_ID}']['EQM-1']['APEQM-1']}
    ...    ${counters_dict['BTS']['SMOD']}

    ${smods_keys_list}  Get Dictionary Keys  ${smod_keys}

    Run Keyword If  ${NEW_COUNTERS_PATH}
    ...    Send SM Counters For New Path  ${smod_keys}
    ...    ELSE  Send SM Counters For Old Path  ${smod_keys}

    ${start_column}  Set Variable  ${LAST_COLUMN}
    ${end_column}  Set Variable  ${start_column+5}
    FOR  ${sm}  IN  @{smods_keys_list}
        excel.Append To Specified Cell Excel File
        ...  path_to_file=${PATH_TO_REPORT_FILE}/${REPORT_NAME}
        ...  cell_value=${sm}
        ...  start_row=${1}  end_row=${1}  start_column=${start_column}  end_column=${end_column}
        ...  bold=True
        ...  sheet_name=${COUNTERS_SHEET_NAME}
        ${start_column}  Set Variable  ${start_column+6}
        ${end_column}  Set Variable  ${end_column+6}
    END

Send SM Counters For Old Path
    [Arguments]    ${smod_keys}

    ${dict_of_smod_counters}
    ...  Evaluate  (__import__('collections').OrderedDict(sorted(${smod_keys}.items())))

    FOR  ${key}  ${value}  IN ZIP  ${dict_of_smod_counters.keys()}  ${dict_of_smod_counters.values()}
        ${cabinets}  Get Dictionary Keys  ${value}
        ${counters_dict}  Get From Dictionary  ${value}  ${cabinets}[0]
        ${counters_dict}  Get From Dictionary  ${counters_dict}  SBTS_SM_Energy_Monitoring
        ${counters_dict}  Evaluate  (__import__('collections').OrderedDict(sorted(${counters_dict}.items())))
        Send Counters to Excel File  ${counters_dict}  ${SM_COUNTERS}  ${key}
    END

Send SM Counters For New Path
    [Arguments]    ${cabinet_keys}

    FOR  ${cabinet}  ${smod}  IN ZIP  ${cabinet_keys.keys()}  ${cabinet_keys.values()}
        ${dict_of_smod_counters}
        ...  Evaluate  (__import__('collections').OrderedDict(sorted(${smod}.items())))
        Iterator For SM Counter For New Path  ${dict_of_smod_counters}
    END

Iterator For SM Counter For New Path
    [Arguments]    ${dict}

    FOR    ${smod}  ${counters}    IN ZIP  ${dict.keys()}  ${dict.values()}
        ${counters_dict}  Get From Dictionary  ${counters}  SBTS_SM_Energy_Monitoring
        ${counters_dict}  Evaluate  (__import__('collections').OrderedDict(sorted(${counters_dict}.items())))
        Send Counters to Excel File  ${counters_dict}  ${SM_COUNTERS}  ${smod}
    END

Send Counters to Excel File
    [Arguments]  ${counters_dict}  ${counters_list}  ${module}
    [Documentation]
    ...  KW sends counters to Excel file based on counters dictionary from API
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${keys}  Get Dictionary Keys  ${counters_dict}

    ${excel_column}  excel.Get First Empty Column Excel File
        ...  path_to_file=${PATH_TO_REPORT_FILE}/${REPORT_NAME}
        ...  int_or_letter=letter
        ...  sheet_name=${COUNTERS_SHEET_NAME}

    Log to console  Sending counters to ${REPORT_NAME}: ${counters_list} for ${module}

    FOR  ${counter}  ${values}  IN ZIP  ${counters_dict.keys()}  ${counters_dict.values()}
        ${mV_values}  Get Dictionary Values  ${values}
        excel.Append Column With Data To Excel File
        ...  path_to_file=${PATH_TO_REPORT_FILE}/${REPORT_NAME}
        ...  list_of_data=${mV_values}
        ...  start_cell=${excel_column}2
        ...  header=${counter}
        ...  sheet_name=${COUNTERS_SHEET_NAME}
        ${excel_column}  Get First Empty Column Excel File
        ...  path_to_file=${PATH_TO_REPORT_FILE}/${REPORT_NAME}
        ...  int_or_letter=letter
        ...  sheet_name=${COUNTERS_SHEET_NAME}
    END


Parameters Recommissioning For Power Meter
    [Arguments]  ${param_actPowerMeter}  ${param_mtBts}  ${alias}=default
    [Documentation]
    ...  KW performs recommissioning for EEM feature.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    admin.Create Delta
    admin.Append Parameter Update To Delta   ${object_variable_actPowerMeter}  actPowerMeter  ${param_actPowerMeter}
    admin.Append Parameter Update To Delta   ${object_variable_mtBtsEnergyMonitoring}  mtBtsEnergyMonitoring  ${param_mtBts}
    admin.Append Parameter Update To Delta   ${object_variable_mtBtsEnergyMonitoring}  mtSBTSSmEnergyMonitoring  ${param_mtBts}
    admin.Append Parameter Update To Delta   ${object_variable_mtBtsEnergyMonitoring}  mtSBTSRfmEnergyMonitoring  ${param_mtBts}

    Log To Console  Updating actPowerMeter parameter to ${param_actPowerMeter} ...
    Run Keyword If  '${param_mtBts}'=='disabled'  Run Keywords
    ...  Log to Console  Updating mtBtsEnergyMonitoring parameter to disabled
    ...  AND  Log to Console  Updating mtSBTSSmEnergyMonitoring parameter to disabled
    ...  AND  Log to Console  Updating mtSBTSRfmEnergyMonitoring parameter to disabled
    ...  ELSE  Run Keywords
    ...  Log to console  Updating mtBtsEnergyMonitoring parameter to ${INTERVAL} minutes ...
    ...  AND  Log to console  Updating mtSBTSSmEnergyMonitoring parameter to ${INTERVAL} minutes ...
    ...  AND  Log to console  Updating mtSBTSRfmEnergyMonitoring parameter to ${INTERVAL} minutes ...

     ${delta}  admin.Get Delta
     admin.Perform Delta Recommissioning  ${delta}  skip_parameter_relation_errors=True  alias=${alias}
     admin.Remove Delta


Check Interval
    [Arguments]  ${int}
    [Documentation]
    ...  KW checks if given by user interval for PM counters gathering is correct.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    @{available_intervals}=  Create List  15  30  60  360  720  1440
    ${interval_status}=  Run Keyword And Return Status  List Should Contain Value  ${available_intervals}  ${int}
    Set Test Variable  ${interval_status_teardown}  ${interval_status}
    Run Keyword If  ${interval_status}==False  Fail  Given interval ${int} does't meet condition. Allowed values 15 30 60 360 720 1440.
    ...  ELSE  Log To Console  Given interval ${int} is correct.


Start Downlink NR TM1.1
    [Arguments]  ${power_backoff}
    [Documentation]
    ...  KW starts TM1.1 for all NR cells.
    ...  If TM cannot be started, error is added to global list and will be send to excel file.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${nrcel_ids}  admin.Get Ids For All  NRCEL
    FOR  ${cell}  IN  @{nrcel_ids}
        ${cell_id}  Evaluate  '${cell}'.rsplit('/', 1)[1]
        Log To Console  Starting NR TM1.1 for cell ${cell_id} ...
        ${cell_info}  admin.Get Cell Specific Info  ${cell}
        ${cell_technology}  Set Variable  ${cell_info['technology']}
        ${beam_pattern_id}  Set Beam_Pattern_ID  ${cell_info}
        ${beam_pattern_id_list}  Create List  ${beam_pattern_id}
        ${start_tm_status}  Run Keyword And Return Status  admin.Start 5G Downlink Test
        ...  dist_name=${cell}
        ...  test_model=TM1_1
        ...  beam_pattern_id=${beam_pattern_id_list}
        ...  polarization=P_both
        ...  power_backoff=${power_backoff}
        ...  ru_mode=NR_Only
        ...  phys_cell_id=1
        ...  codebook_2_antports=0
        ...  i11_codebook_4_antports=0
        ...  i2_codebook_4_antports=0
        ...  i13_codebook_4_antports=0
        ...  mimo_rank=1
        ...  p_max=34.9
        ...  connection=${node}
        Run Keyword If    '${start_tm_status}'!='False'
        ...  Log To Console  NR TM1.1 for cell ${cell_id} started succesfull !
        ...  ELSE  Run Keywords
        ...  Append To List  ${ERRORS_LIST}  NR TM1.1 for ${cell_id} cannot be started !
        ...  AND  Run Keyword And Continue On Failure  Fail  NR TM1.1 for ${cell_id} cannot be started !
    END

Stop Downlink NR TM1.1
    [Documentation]
    ...  KW stops TM1.1 for all NR cells.
    ...  If TM cannot be stopped, error is added to global list and will be send to excel file.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com
    ${nrcel_ids}  admin.Get Ids For All  NRCEL
    FOR  ${cell}  IN  @{nrcel_ids}
        ${cell_id}  Evaluate  '${cell}'.rsplit('/', 1)[1]
        Log To Console  Stopping NR TM1.1 for cell ${cell_id} ...
        ${stop_tm_status}  Run Keyword And Return Status  admin.Stop 5G Downlink Test  ${cell}  timeout=120
        Run Keyword If    '${stop_tm_status}'=='False'  Run Keywords
        ...  Append To List  ${ERRORS_LIST}  NR TM1.1 for ${cell} cannot be stopped !
        ...  AND  Run Keyword And Continue On Failure  Fail  NR TM1.1 for ${cell} cannot be stopped !
        ...  ELSE
        ...  Log To Console  NR TM1.1 for ${cell_id} was stopped successful !
    END

Start Downlink LTE TM1.1
    [Documentation]
    ...  KW starts TM1.1 for all LTE cells ( excl. IoT cells )
    ...  If TM cannot be started, error is added to global list and will be send to excel file.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${lncel_ids}  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}
    FOR  ${cell}  IN  @{lncel_ids}
        ${cell_parameters}  admin.Get Cell Specific Info  ${cell}  connection=${node}
        Continue For Loop If  'IoT' in '${cell_parameters['technology']}'
        ${cell_id}  Evaluate  '${cell}'.rsplit('/', 1)[1]
        Log To Console  Starting LTE TM1.1 for cell ${cell_id} ...
        ${tdd_params_list}  Create List  tddFrameConf  tddSpecSubfConf
        ${tdd_params_resp}  IF  '${cell_parameters['technology']}'=='TDD'
        ...  admin.Get Parameter By Distname
        ...  dist_name=${cell_parameters['id']['configuration']}/LNCEL_TDD-0
        ...  parameter_list=${tdd_params_list}
        ...  connection=${node}
        ${start_tm_status}  IF  '${cell_parameters['technology']}'=='FDD'
        ...  Run Keyword And Return Status  admin.Start Downlink Test
        ...  dist_name=${cell}
        ...  test_model=E_TM1_1
        ...  earfcn=${cell_parameters['earfcnDownlink']}
        ...  connection=${node}
        ...  ELSE
        ...  Run Keyword And Return Status  admin.Start Downlink Test
        ...  dist_name=${cell}
        ...  test_model=E_TM1_1
        ...  earfcn=${cell_parameters['earfcn']}
        ...  tdd_frame_conf=${tdd_params_resp[0]['parameters']['tddFrameConf']}
        ...  tdd_spec_sub_conf=${tdd_params_resp[0]['parameters']['tddSpecSubfConf']}
        ...  connection=${node}
        Run Keyword If    '${start_tm_status}'!='False'
        ...  Log To Console  LTE TM1.1 for cell ${cell_id} started succesfull !
        ...  ELSE  Run Keywords
        ...  Append To List  ${ERRORS_LIST}  LTE TM1.1 for ${cell_id} cannot be started !
        ...  AND  Run Keyword And Continue On Failure  Fail  LTE TM1.1 for ${cell_id} cannot be started !
    END

Stop Downlink LTE TM1.1
    [Documentation]
    ...  KW stops TM1.1 for all LTE cells ( excl. IoT cells )
    ...  If TM cannot be stopped, error is added to global list and will be send to excel file.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${lncel_ids}  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}
    FOR  ${cell}  IN  @{lncel_ids}
        ${cell_parameters}  admin.Get Parameters For  LNCEL  ${cell}
        Continue For Loop If  'IoT' in '${cell_parameters['technology']}'
        ${cell_id}  Evaluate  '${cell}'.rsplit('/', 1)[1]
        Log To Console  Stopping LTE TM1.1 for cell ${cell_id} ...
        ${stop_tm_status}  Run Keyword And Return Status  admin.Stop Downlink Test
        ...  dist_name=${cell}
        ...  timeout=120
        Run Keyword If    '${stop_tm_status}'=='False'  Run Keywords
        ...  Append To List  ${ERRORS_LIST}  LTE TM1.1 for ${cell} cannot be stopped !
        ...  AND  Run Keyword And Continue On Failure  Fail  LTE TM1.1 for ${cell} cannot be stopped !
        ...  ELSE
        ...  Log To Console  LTE TM1.1 for ${cell_id} was stopped successful !
    END

Set Beam_Pattern_Id
    [Arguments]  ${cell_info}
    [Documentation]
    ...  KW returns proper beam_pattern_id, which is mandatory for start TM.
    ...  Beam_pattern_id depends on RU, for mMIMO RUs is custom and have to be added to custom_beam_pattern_id_dict
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    Return From Keyword If  '${cell_info['technology']}'=='FDD'  ${1}

    ${carriers_list}  Set Variable  ${cell_info['carrierList']}

    FOR  ${ant}  IN  @{carriers_list}
        Continue For Loop If  '${ant['direction']}'!='TX'
        ${rmod_id}  Evaluate  '${ant['antennaLineId']['internal']}'.rsplit('/',1)[0]
        ${rmod_info}  admin.Get Parameters For  RMOD  ${rmod_id}
        ${rmod_product_name}  Set Variable  ${rmod_info['productName']}
        Exit For Loop
    END

    ${beam_pattern_status}  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${custom_beam_pattern_id_dict}  ${rmod_product_name}

    Return From Keyword If  '${beam_pattern_status}'=='True'
    ...  ${custom_beam_pattern_id_dict['${rmod_product_name}']}
    Return From Keyword  ${1}

Send Main KPI To Excel
    [Arguments]  ${kpi_value}  ${name}
    [Documentation]
    ...  KW sends main KPI value to Excel file.
    ...  If TC fails, keyword will add comment with erors list to Excel cell .
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${summary_list}  Create List  ${name}  ${kpi_value}
    Append Next Row To Excel File  ${PATH_TO_REPORT_FILE}/${REPORT_NAME}  list_of_data=${summary_list}

    ${last_row}  excel.Get Last Row For Column  ${PATH_TO_REPORT_FILE}/${REPORT_NAME}  B
    Run Keyword If  '${KEYWORD STATUS}'!='PASS'
    #...  excel.Add Comment To Cell  ${PATH_TO_REPORT_FILE}/${REPORT_NAME}  B${last_row}  ${ERRORS_LIST}
    #...  ELSE
    ...  excel.Add Comment To Cell  ${PATH_TO_REPORT_FILE}/${REPORT_NAME}  B${last_row}  ${ERRORS_LIST}

    Log To Console  KPI was sent to ${PATH_TO_REPORT_FILE}/${REPORT_NAME} !

Calculate ETSI
    [Arguments]  ${etsi_type}
    [Documentation]
    ...  KW creates excel formula for ETSI calculation and send it to Excel file.
    ...  In case of one of Low,Medium,Busy is 0, KW add comment to Excel cell with information.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${summary_list}  Create List  ${etsi_type}

    ${etsi_dict}  Get Cells For ETSI Calculation
    ${load_values}  Get Dictionary Values  ${etsi_dict}

    ${last_row}  excel.Get Last Row For Column  ${PATH_TO_REPORT_FILE}/${REPORT_NAME}  B

    Run Keyword If  None in ${load_values}  Run Keywords
    ...  Append To List  ${summary_list}  ${0}
    ...  AND  excel.Append Next Row To Excel File  ${PATH_TO_REPORT_FILE}/${REPORT_NAME}  list_of_data=${summary_list}
    ...  AND  excel.Add Comment To Cell  ${PATH_TO_REPORT_FILE}/${REPORT_NAME}  B${last_row+1}
    ...  One of KPI: Low,Medium,Busy doesn't exists in .xlsx file !
    ...  AND  Fail  One of KPI: Low,Medium,Busy doesn't exists in .xlsx file !

    ${values_list}  Create List
    FOR  ${load}  ${cell}  IN ZIP  ${etsi_dict.keys()}  ${etsi_dict.values()}
        ${cell_with_value}  Replace String  ${cell}  A  B
        ${cell_value}  excel.Get Cell Value  ${PATH_TO_REPORT_FILE}/${REPORT_NAME}  ${cell_with_value}
        Append To List  ${values_list}  ${cell_value}
        Set To Dictionary  ${etsi_dict}  ${load}  ${cell_with_value}
    END

    ${low_value_cell}     Get From Dictionary  ${etsi_dict}  Low
    ${medium_value_cell}  Get From Dictionary  ${etsi_dict}  Medium
    ${busy_value_cell}    Get From Dictionary  ${etsi_dict}  Busy

    ${formula}  Run Keyword If  '${etsi_type}'=='ETSI avg (wighted)'
    ...  Evaluate  '=${low_value_cell}*${6}+${medium_value_cell}*${10}+${busy_value_cell}*${8}'
    ...  ELSE
    ...  Evaluate  '=(${low_value_cell}*${6}+${medium_value_cell}*${10}+${busy_value_cell}*${8})/(${6}+${8}+${10})'

    Append To List  ${summary_list}  ${formula}
    excel.Append Next Row To Excel File  ${PATH_TO_REPORT_FILE}/${REPORT_NAME}  list_of_data=${summary_list}

    ${last_row}  excel.Get Last Row For Column  ${PATH_TO_REPORT_FILE}/${REPORT_NAME}  B
    Run Keyword If  0 in ${values_list}
    ...  excel.Add Comment To Cell  ${PATH_TO_REPORT_FILE}/${REPORT_NAME}  B${last_row}
    ...  At least one main KPI value is 0, ETSI calculation cannot be correct !


Get Cells For ETSI Calculation
    [Documentation]
    ...  KW creates dictionary with keys: Low, Medium and Busy.
    ...  Values are Excel cells e.g. B3
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${etsi_dict}  Create Dictionary
    ${cells_list}  Create List
    ${low_cell}  Find Cell By Value
    ...  path_to_file=${PATH_TO_REPORT_FILE}/${REPORT_NAME}
    ...  value=Low
    Set To Dictionary  ${etsi_dict}  Low  ${low_cell}

    ${medium_cell}  Find Cell By Value
    ...  path_to_file=${PATH_TO_REPORT_FILE}/${REPORT_NAME}
    ...  value=Medium
    Set To Dictionary  ${etsi_dict}  Medium  ${medium_cell}

    ${busy_cell}  Find Cell By Value
    ...  path_to_file=${PATH_TO_REPORT_FILE}/${REPORT_NAME}
    ...  value=Busy
    Set To Dictionary  ${etsi_dict}  Busy  ${busy_cell}

    [Return]  ${etsi_dict}


Lock/Unlock AdministrativeState For Cells
    [Arguments]  ${operation}  ${alias}=default
    [Documentation]
    ...  KW locks all LTE and NR cells in BTS
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    admin.Create Delta

    ${ln_operation}  Evaluate  '${operation}'.lower()

    ${lncel_list}  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}  alias=${alias}
    FOR  ${lncel}  IN  @{lncel_list}
        ${lncel_id}  Evaluate  '${lncel}'.rsplit('-',1)[1]
        admin.Append Parameter Update To Delta
        ...  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${lncel_id}  administrativeState  ${ln_operation}
    END

    ${nrcel_list}  admin.Get Ids For All  NRCEL  alias=${alias}
    FOR  ${nrcel}  IN  @{nrcel_list}
        ${nrcel_id}  Evaluate  '${nrcel}'.rsplit('-',1)[1]
        admin.Append Parameter Update To Delta
        ...  MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcel_id}  administrativeState  ${operation}
    END

    ${delta}  admin.Get Delta
    admin.Perform Delta Recommissioning  ${delta}  skip_parameter_relation_errors=True  alias=${alias}
    admin.Remove Delta

Check Real Time Measurements
    [Arguments]  ${real_time_condition}

    ${list_of_measurements}  admin.Get Measurements

    ${eem_rmod_list}  Create List
    ${eem_smod_list}  Create List
    FOR  ${key}  IN  @{list_of_measurements}
        ${string_key}  Convert To String  ${key}
        Continue For Loop If  'ENERGY_EFFICIENCY' not in "${string_key}"
        Run Keyword If  'RMOD' in "${string_key}"
        ...  Append To List  ${eem_rmod_list}  ${key}
        ...  ELSE IF  'SMOD' in "${string_key}"
        ...  Append To List  ${eem_smod_list}  ${key}
    END

    ${status_list}  Create List
    FOR  ${measure}  IN  @{eem_rmod_list}
        ${measures}  Get Dictionary Values  ${measure}
        Run Keyword If  "Not supported" in "${measures}[0]" or "Not enabled" in "${measures}[0]"
        ...  Run Keywords
        ...  Append To List  ${status_list}  ${FALSE}
        ...  AND
        ...  Continue For Loop
        ${measured_values}  Get Dictionary Values  ${measures}[0]
        ${measured_values}  Evaluate  list(map(lambda x: x.replace('-', '0'), ${measured_values}))
        ${status}  Evaluate  all(float(x) > 0 for x in ${measured_values})
        Append To List  ${status_list}  ${status}
    END

    ${rmods_list}    admin.Get Parameters For All  RMOD
    ${rmods_number}  Set Variable  ${0}
    FOR  ${rmod}  IN  @{rmods_list}
        ${rmods_number}  Set Variable If  'U' in '${rmod['productName']}'  ${rmods_number}  ${rmods_number+1}
    END

    ${exp_unsupported_rmods}   Evaluate  (${rmods_number}-${RMODS})
    ${collected_unsupp_rmods}  Evaluate  ${status_list}.count(False)
    ${collected_supp_rmods}    Evaluate  ${status_list}.count(True)
    ${rmods_occur}  Get Length  ${status_list}
    ${get_status}  Run Keyword If  '${real_time_condition}'=='True'
    ...  Run Keyword And Return Status  Run Keywords
    ...  Should Be Equal  ${exp_unsupported_rmods}  ${collected_unsupp_rmods}
    ...  AND  Should Be Equal  ${rmods_occur}  ${rmods_number}
    ...  AND  Should Not Be Empty  ${eem_smod_list}
    ...  ELSE IF  '${real_time_condition}'=='False'
    ...  Run Keyword And Return Status  Run Keywords
    ...  Should Be Equal  ${rmods_occur}  ${collected_unsupp_rmods}
    ...  AND  Should Be Equal  ${rmods_occur}  ${rmods_number}
    ...  AND  Should Not Be Empty  ${eem_smod_list}

    ${eem_list}  Combine Lists  ${eem_smod_list}  ${eem_rmod_list}

    Set Test Variable  ${COLLECTED_SUPP_RMODS}  ${collected_supp_rmods}
    Set Test Variable  ${COLLECTED_UNSUPP_RMODS}  ${collected_unsupp_rmods}
    Set Test Variable  ${LIST_OF_MEASUREMENTS}  ${eem_list}

    Should Be True  ${get_status}

Check Number of RMODS
    [Arguments]  ${rmods}

    ${rmods_list}=   admin.Get Ids For All  RMOD
    ${rmods_number}=  Get Length  ${rmods_list}
    ${rmods_status}=  Evaluate  ${rmods}<=${rmods_number}
    Run Keyword If  ${rmods_status}==False  Fail  Given number of RMODs: ${rmods} is incorrect, please check it !
    ...  ELSE  Log To Console  Given number of RMODs: ${rmods} is correct.
