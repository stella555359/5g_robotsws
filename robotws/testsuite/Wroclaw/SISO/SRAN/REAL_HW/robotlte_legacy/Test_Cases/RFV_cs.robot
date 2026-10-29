# robocop: off
*** Settings ***
Documentation
...  Author:
...  Maintainer:  piotr.korczynski@nokia.com

Library  Collections
Library  OperatingSystem
Library  Process
Library  robot.libraries.DateTime
Library  SSHLibrary
Library  String
#Library  ta_kiss_files

Library  ute_admin_infomodel
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ../rf_alarms_operations.py
Library  ../operations.py
*** Variables ***
${RF_VARIANT_OPTIMIZED}=  True
*** Keywords ***
Set Alarm Information Dictionary
  [Arguments]  ${fr_serial_number}=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}
  ...  ${act_category_alarms}=${ACT_CATEGORY_ALARMS}
  ${fr_under_test_and_related_serial_number_list}=  Get FR Under Test And Related FR Serial Number List
  ...  ${fr_serial_number}
  ${all_frs_except_fr_under_test_and_related}=  Subtract List From List
  ...  ${COMMISSIONED_FR_LIST}  ${fr_under_test_and_related_serial_number_list}
  ${all_frs_except_related}=  Subtract List From List
  ...  ${COMMISSIONED_FR_LIST}  ${FR_INFO['${fr_serial_number}']['related_fr_list']}

  ${im_alarms_fault_23_fr_under_test}=  Create Mandatory Alarms List FV  Info Model
  ...  scfc_file_path=${scfc_file_path}
  ...  fr_serial_number_list=${fr_serial_number}
  ...  fault_scheme=${FAULT_23_SCHEME}
  ...  act_category_alarms=${act_category_alarms}
  ${im_alarms_fault_10_fr_under_test_and_related}=  Create Mandatory Alarms List FV  Info Model
  ...  scfc_file_path=${scfc_file_path}
  ...  fr_serial_number_list=${all_frs_except_fr_under_test_and_related}
  ...  fault_scheme=${FAULT_10_SCHEME}
  ...  act_category_alarms=${act_category_alarms}
  ${im_alarms_fault_10_fr_related}=  Create Mandatory Alarms List FV  Info Model
  ...  scfc_file_path=${scfc_file_path}
  ...  fr_serial_number_list=${all_frs_except_related}
  ...  fault_scheme=${FAULT_10_SCHEME}
  ...  act_category_alarms=${act_category_alarms}
  ${im_alarms_fault_10_and_23_fr_under_test_and_related}=  Combine Lists
  ...  ${im_alarms_fault_23_fr_under_test}
  ...  ${im_alarms_fault_10_fr_under_test_and_related}

  ${enb_mng_alarms_fault_23_fr_under_test}=  Create Mandatory Alarms List FV  ${ENB_MANAGER}
  ...  scfc_file_path=${scfc_file_path}
  ...  fr_serial_number_list=${fr_serial_number}
  ...  fault_scheme=${FAULT_23_SCHEME}
  ...  act_category_alarms=${act_category_alarms}
  ${enb_mng_alarms_fault_10_fr_under_test_and_related}=  Create Mandatory Alarms List FV  ${ENB_MANAGER}
  ...  scfc_file_path=${scfc_file_path}
  ...  fr_serial_number_list=${all_frs_except_fr_under_test_and_related}
  ...  fault_scheme=${FAULT_10_SCHEME}
  ...  act_category_alarms=${act_category_alarms}
  ${enb_mng_alarms_fault_10_fr_related}=  Create Mandatory Alarms List FV  ${ENB_MANAGER}
  ...  scfc_file_path=${scfc_file_path}
  ...  fr_serial_number_list=${all_frs_except_related}
  ...  fault_scheme=${FAULT_10_SCHEME}
  ...  act_category_alarms=${act_category_alarms}

  ${enb_mng_alarms_fault_10_and_23_fr_under_test_and_related}=  Combine Lists
  ...  ${enb_mng_alarms_fault_23_fr_under_test}
  ...  ${enb_mng_alarms_fault_10_fr_under_test_and_related}


  ${alarms_fault_23_fr_under_test_length}=  Get Length  ${im_alarms_fault_23_fr_under_test}
  ${alarms_fault_10_fr_under_test_and_related_length}=  Get Length  ${im_alarms_fault_10_fr_under_test_and_related}
  ${alarms_fault_10_fr_related_length}=  Get Length  ${im_alarms_fault_10_fr_related}
  ${alarms_fault_10_and_23_fr_under_test_and_related_length}=  Get Length
  ...  ${im_alarms_fault_10_and_23_fr_under_test_and_related}

  ${alarms_fault_23_fr_under_test_dict}=  Create Dictionary
  ...  fr_list  ${fr_under_test_and_related_serial_number_list}
  ...  im_alarm_list  ${im_alarms_fault_10_and_23_fr_under_test_and_related}
  ...  enb_mng_alarm_list  ${enb_mng_alarms_fault_10_and_23_fr_under_test_and_related}
  ...  fault_10_count  ${alarms_fault_10_fr_under_test_and_related_length}
  ...  fault_23_count  ${alarms_fault_23_fr_under_test_length}
  ${alarms_fr_under_test_and_related_dict}=  Create Dictionary
  ...  fr_list  ${fr_under_test_and_related_serial_number_list}
  ...  im_alarm_list  ${im_alarms_fault_10_fr_under_test_and_related}
  ...  enb_mng_alarm_list  ${enb_mng_alarms_fault_10_fr_under_test_and_related}
  ...  fault_10_count  ${alarms_fault_10_fr_under_test_and_related_length}
  ...  fault_23_count  0
  ${alarms_related_fr_dict}=  Create Dictionary
  ...  fr_list  ${FR_INFO['${fr_serial_number}']['related_fr_list']}
  ...  im_alarm_list  ${im_alarms_fault_10_fr_related}
  ...  enb_mng_alarm_list  ${enb_mng_alarms_fault_10_fr_related}
  ...  fault_10_count  ${alarms_fault_10_fr_related_length}
  ...  fault_23_count  0

  ${ALARMS}=  Create Dictionary
  ...  fr_under_test_with_fault_23_and_related  ${alarms_fault_23_fr_under_test_dict}
  ...  fr_under_test_and_related  ${alarms_fr_under_test_and_related_dict}
  ...  fr_related  ${alarms_related_fr_dict}
  Set Test Variable  ${ALARMS}

Get FR Under Test And Related FR Serial Number List
  [Arguments]  ${fr_serial_number}=${FR_UNDER_TEST_SERIAL_NUMBER}
  ${fr_under_test_and_related}=  Copy List  ${FR_INFO['${fr_serial_number}']['related_fr_list']}
  Append To List  ${fr_under_test_and_related}  ${fr_serial_number}
  [Return]  ${fr_under_test_and_related}

Optimized RF Variant Preparation
  [Arguments]  ${alias}=${TC_ALIAS}
  Return From Keyword If  not ${RF_VARIANT_OPTIMIZED}
  Set Test Variable  ${RF_VARIANT_OPTIMIZED}  ${False}
  Log To Console  Optimized RF Variant Preparation will now prepare all tested FR SW
#  Log  ${config_path}  console=True
  Set Initial RF Variant Variables
  RF Variant Expand Allowed Allarms
  Set Test Variable  ${TEST_LOGS_DIR_PATH}  ${cfg.test_logs_path}/Optimized_RF_Variant_Preparation

Set Initial RF Variant Variables
  ${CELL_ID_LIST}=  Set Variable  ${cfg.RF_INFO['${FR_UNDER_TEST_SERIAL_NUMBER}']['LNCEL']['scf_cellid_primary']}
  Set Test Variable  ${CELL_ID_LIST}  ${CELL_ID_LIST}
  Set Init.py Variables
#  Set BTS SW Build And Release

  Set ActCategoryAlarms
  Set Fault Schemes
  Set FR Serial Number List
  Set BTS ID
  Set FR Information Dictionary
  Set Cell Information Dictionary

Set Init.py Variables
  ${tl_serial_number_list}=  Get Dictionary Keys  ${CFG.RF_INFO}
  Set Test Variable  ${TL_ALL_FR_LIST}  ${tl_serial_number_list}
#
#Set BTS SW Build And Release
#  ${active_sw}  ${passive_sw}=  Get SM Active And Passive SW Versions  timeout=60  log_to_console=no
#  ${active_sw}=  Convert SW Buildname To SW Filename  ${active_sw}
#  ${active_sw_split}=  Split String  ${active_sw}  separator=_
#  ${sw_release}=  Set Variable  ${active_sw_split[0]}
#  Set Test Variable  ${SW_RELEASE}  ${sw_release}
#  Set Test Variable  ${SW_UNDER_TEST}  ${active_sw}


Set SCFC Reference File Path
  Run Keyword If  "${SETUP_SCFC}"!="${EMPTY}"  Run Keywords
  ...  Set Test Variable  ${SCFC_REFERENCE_FILE_PATH}  ${SETUP_SCFC}  AND
  ...  Return From Keyword
  ${SCFC_REFERENCE_FILE_PATH}=  Get SCFC Reference File Path Based On Enb Build
  Set Test Variable  ${SCFC_REFERENCE_FILE_PATH}
  [Teardown]  Log To Console  Reference SCFC: ${SCFC_REFERENCE_FILE_PATH}

Set ActCategoryAlarms
  [Arguments]  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}
  ${value}=  SCFC Get Activate Category Alarms Value  ${scfc_file_path}
  Set Test Variable  ${ACT_CATEGORY_ALARMS}  ${value}

Set Fault Schemes
  [Arguments]  ${act_category_alarms}=${ACT_CATEGORY_ALARMS}
  ${FAULT_10_SCHEME}=  Evaluate  ${FAULT_10_SCHEME}
  Run Keyword If  "${act_category_alarms}" == "False"
  ...  Set To Dictionary  ${FAULT_10_SCHEME}  alarmDetail  Failure in optical interface
  Run Keyword If  "${act_category_alarms}" == "True"
  ...  Set To Dictionary  ${FAULT_10_SCHEME}  alarmDetail  No connection to unit
  ${FAULT_10_SCHEME}=  Convert To String  ${FAULT_10_SCHEME}
  Set Test Variable  ${FAULT_10_SCHEME}

Set FR Serial Number List
  [Arguments]  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}
  ${all_fr_ser_num_list}=  Get From Dictionary     ${cfg.NODES['${BTS_ID}']}  scf_hw_fr_list
  Set Test Variable  ${COMMISSIONED_FR_LIST}  ${all_fr_ser_num_list}
  ${all_fhs_ser_num_list}=  Get From Dictionary     ${cfg.NODES['${BTS_ID}']}  scf_hw_fhs_list
  Set Test Variable  ${ALL_FHS_SERIAL_NUMBER_LIST}  ${all_fhs_ser_num_list}

Set BTS ID
  [Arguments]  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}
  ${bts_id}=  SCFC Get BtsId  ${scfc_file_path}
  Set Test Variable  ${BTS_ID}  ${bts_id}

Set FR Information Dictionary
  [Arguments]  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}
  ...  ${fr_serial_number_list}=${COMMISSIONED_FR_LIST}  ${fhs_serial_number_list}=${ALL_FHS_SERIAL_NUMBER_LIST}
  ...  ${verbose}=True  ${alias}=${TC_ALIAS}
  ${fr_dictionary}=  Create Dictionary
  ${fhs_dictionary}=  Create Dictionary
  ${scfc_parsed}=  Parse XML  ${scfc_file_path}
  ${all_lcrid_list}=  SCFC Create LcrId List For FR Serial Numbers List
  ...  scfc_file_path=${scfc_parsed}
  ...  fr_serial_number_list=${fr_serial_number_list}
  ...  cell_type=All
  FOR  ${sn}  IN  @{fr_serial_number_list}
    ${lcrid_list}=  SCFC Create LcrId List For FR Serial Number
  ...  scfc_file_path=${scfc_parsed}
  ...  fr_serial_number=${sn}
  ...  cell_type=All
    ${lncel_id_list}=  SCFC Create LncelId List For LcrdId List  ${scfc_parsed}  ${lcrid_list}
    ${cell_count}=  Get Length  ${lcrid_list}
    ${fr_shared_2tx}=  Check If FR Has Shared 2TX Cells
  ...  ${sn}
  ...  all_lcr_id_list=${all_lcrid_list}
  ...  fr_lcr_id_list=${lcrid_list}
  ...  scfc_file_path=${scfc_parsed}
    ${related_frs}=  Set FR Serial Number List Related To Given FR  ${scfc_parsed}  ${sn}  ${lcrid_list}
    ${fr_variant}=  SCFC Get Product Name For FR Serial Number  ${scfc_parsed}  ${sn}
    ${s}  ${fr_ip}=  Run Keyword And Ignore Error  Info Model Get IP For FR Serial Number
  ...  ${sn}
  ...  timeout=0.1
  ...  alias=${alias}
    ${ip_already_set}=  Run Keyword And Return Status  Variable Should Exist  ${FR_INFO['${sn}']['ip']}
    ${fr_ip}=  Set Variable If  ${ip_already_set}  ${FR_INFO['${sn}']['ip']}
  ...  "${s}"=="FAIL"  unknown  ${fr_ip}
    ${s}  ${fr_sw}=  Run Keyword And Ignore Error  Info Model Get HW Active SW  ${sn}  alias=${alias}
    ${sw_already_set}=  Run Keyword And Return Status  Variable Should Exist  ${FR_INFO['${sn}']['sw']}
    ${fr_sw}=  Set Variable If  ${sw_already_set}  ${FR_INFO['${sn}']['sw']}
  ...  "${s}"=="FAIL"  unknown  ${fr_sw}
    ${s}  ${fr_release}=  Run Keyword And Ignore Error  Info Model Get RF Radio Module Release
  ...  ${sn}
  ...  alias=${alias}
    ${release_already_set}=  Run Keyword And Return Status  Variable Should Exist  ${FR_INFO['${sn}']['release']}
    ${fr_release}=  Set Variable If  ${release_already_set}  ${FR_INFO['${sn}']['release']}
  ...  "${s}"=="FAIL"  unknown  ${fr_release}
    ${fr_info}=  Create Dictionary
    Set To Dictionary  ${fr_info}  variant  ${fr_variant}
  ...  release  ${fr_release}
  ...  cell_list  ${lcrid_list}
  ...  lncel_id_list  ${lncel_id_list}
  ...  cell_count  ${cell_count}
  ...  cells_are_shared_2tx  ${fr_shared_2tx}
  ...  related_fr_list  ${related_frs}
  ...  sw  ${fr_sw}
  ...  ip  ${fr_ip}
    Set To Dictionary  ${fr_dictionary}  ${sn}  ${fr_info}
  END
  FOR  ${sn}  IN  @{fhs_serial_number_list}
    ${s}  ${fhs_sw}=  Run Keyword And Ignore Error  Info Model Get HW Active SW  ${sn}  alias=${alias}
    ${sw_already_set}=  Run Keyword And Return Status  Variable Should Exist  ${FR_INFO['${sn}']['sw']}
    ${fhs_sw}=  Set Variable If  ${sw_already_set}  ${FR_INFO['${sn}']['sw']}
  ...  "${s}"=="FAIL"  unknown  ${fhs_sw}
    ${empty_list}=  Create List
    ${fhs_info}=  Create Dictionary
    Set To Dictionary  ${fhs_info}  variant  MDEA
  ...  cell_list  ${empty_list}
  ...  lncel_id_list  ${empty_list}
  ...  cell_count  0
  ...  related_fr_list  ${COMMISSIONED_FR_LIST}
  ...  sw  ${fhs_sw}
    Set To Dictionary  ${fhs_dictionary}  ${sn}  ${fhs_info}
  END

  Run Keyword If  ${verbose}  Print FR Dictionary Nicely  ${fr_dictionary}
  ${unique_all_lcrid_list}=  Remove Duplicates  ${all_lcrid_list}
  ${cell_count}=  Get Length  ${unique_all_lcrid_list}
  Set Test Variable  ${FR_INFO}  ${fr_dictionary}
  Set Test Variable  ${FHS_INFO}  ${fhs_dictionary}
  Set Test Variable  ${ALL_CELLS_COUNT}  ${cell_count}



Set Cell Information Dictionary
  [Arguments]  ${lncel_id_list}=${CELL_ID_LIST}  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}
  ...  ${verbose}=True  ${alias}=${TC_ALIAS}
  ${cell_dictionary}=  Create Dictionary
  ${scfc_parsed}=  Parse XML  ${scfc_file_path}
  FOR  ${cell}  IN  @{lncel_id_list}
    ${cell}=  Get From Dictionary  ${cfg.NODES['${BTS_ID}']['LNCEL']['${cell}']}  scf_lcr_id
    ${cell}=  Convert To String  ${cell}
    ${lncel_id}=  SCFC Get LncelId For LcrId  ${scfc_parsed}  ${cell}
    ${cell_type}=  SCFC Get Cell Type  ${scfc_parsed}  ${cell}
    ${slave_lcr_id}=  SCFC Get IoT LcrId Related To Given LcrId  ${scfc_parsed}  ${cell}
    ${bw}  ${tx}  ${rx}=  Run Keyword If  "${cell_type}"=="legacy"
    ...  SCFC Get LncelId Bandwidth And Frequency  ${scfc_parsed}  ${lncel_id}
    ${cell_info}=  Create Dictionary
    Set To Dictionary  ${cell_info}  lncel_id  ${lncel_id}
    ...  cell_type  ${cell_type}
    ...  slave_lcr_id  ${slave_lcr_id}
    ...  bandwidth  ${bw}
    ...  tx_frequency  ${tx}
    ...  rx_frequency  ${rx}
    Set To Dictionary  ${cell_dictionary}  ${cell}  ${cell_info}
  END
  Set Test Variable  ${CELL_INFO}  ${cell_dictionary}



RF Variant Expand Allowed Allarms
  Run Keyword If  "${SW_RELEASE}" == "SBTS20A"
  ...  Append To List  ${GLO_ALLOWED_ALARMS}  @{SBTS20A_ALLOWED_ALARMS}
  @{ALLOWED_ALARMS}=  Remove Duplicates  ${GLO_ALLOWED_ALARMS}



Check If FR Has Shared 2TX Cells
  [Arguments]  ${fr_serial_number}  ${all_lcr_id_list}=${EMPTY}  ${fr_lcr_id_list}=${EMPTY}
  ...  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}
  ${cells_are_shared}=  Check If Cells Are Shared  ${fr_lcr_id_list}  ${all_lcr_id_list}
  ${cells_are_2tx}=  Check If Cells Are 2TX  ${fr_lcr_id_list}
  ${cells_are_shared_2tx}=  Evaluate  ${cells_are_shared} and ${cells_are_2tx}
  [Return]  ${cells_are_shared_2tx}o

Check If Cells Are Shared
  [Arguments]  ${fr_cells}  ${all_cells}
  ${boolean_shared_cell_list}=  Create List
  FOR  ${fr_cell}  IN  @{fr_cells}
    ${count_frs_sharing_cell}=  Count Values In List  ${all_cells}  ${fr_cell}
    ${cell_is_shared}=  Evaluate  ${count_frs_sharing_cell}>1
    Append To List  ${boolean_shared_cell_list}  ${cell_is_shared}
  END
  ${true_count}=  Count Values In List  ${boolean_shared_cell_list}  ${True}
  ${false_count}=  Count Values In List  ${boolean_shared_cell_list}  ${False}
  ${result}=  Set Variable If  ${true_count}>0 and ${false_count}==0  ${True}  ${False}
  ${result}=  Set Variable If  ${true_count}>0 and ${false_count}>0  Configuration not supported  ${result}
  [Return]  ${result}

Check If Cells Are 2TX
  [Arguments]  ${fr_cells}  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}
  ${boolean_2tx_cell_list}=  Create List
  FOR  ${fr_cell}  IN  @{fr_cells}
  ...  ${tx_count}=
  ...  Evaluate Xpath
  ...  ${scfc_file_path}
  ...  count(.//managedObject[p[@name='direction']='TX'][contains(@class, "CHANNEL")][contains(@distName, "LCELL-${fr_cell}/")])
    ${cell_is_2tx}=  Evaluate  ${tx_count}==2
    Append To List  ${boolean_2tx_cell_list}  ${cell_is_2tx}
  END
  ${true_count}=  Count Values In List  ${boolean_2tx_cell_list}  ${True}
  ${false_count}=  Count Values In List  ${boolean_2tx_cell_list}  ${False}
  ${result}=  Set Variable If  ${true_count}>0 and ${false_count}==0  ${True}  ${False}
  ${result}=  Set Variable If  ${true_count}>0 and ${false_count}>0  Configuration not supported  ${result}
  [Return]  ${result}


Set FR Serial Number List Related To Given FR
  [Arguments]  ${scfc_file_path}  ${serial_number}  ${lcr_id_list}
  ${fr_chain_list}=  SCFC Create HW Chain List For FR Serial Number
  ...  scfc_file_path=${scfc_file_path}
  ...  fr_serial_number=${serial_number}
  ...  hw=RMOD
  ${fr_chain_list_before_fr}=  FR Chain Get Elements Before FR (Excluded) List
  ...  fr_serial_number_signle_chain_list=${fr_chain_list}
  ...  fr_serial_number=${serial_number}
  ${frs_sharing_cells}=  Get FR Serial Number List That Handle Given LcrId List
  ...  scfc_file_path=${scfc_file_path}
  ...  lcr_id_list=${lcr_id_list}
  ${output}=  Combine Lists  ${fr_chain_list_before_fr}  ${frs_sharing_cells}
  ${output}=  Remove Duplicates  ${output}
  Remove Values From List  ${output}  ${serial_number}
  [Return]  ${output}

Get FR Serial Number List That Handle Given LcrId List
  [Arguments]  ${scfc_file_path}  ${lcr_id_list}
  ${output}=  Create List
  FOR  ${lcr_id}  IN  @{lcr_id_list}
    ${fr_serial_number_list}=  SCFC Create FR Serial Number List For LcrId  ${scfc_file_path}  ${lcr_id}
    ${output}=  Combine Lists  ${fr_serial_number_list}  ${output}
  END
  ${output}=  Remove Duplicates  ${output}
  [Return]  ${output}

Print FR Dictionary Nicely
  [Arguments]  ${dict}
  ${keys}=  Get Dictionary Keys  ${dict}
  ${print}=  Set Variable  ${EMPTY}
  FOR  ${key}  IN  @{keys}
    ${value}=  Get From Dictionary  ${dict}  ${key}
    ${fr_print}=  Print Dictionary Nicely  ${value}  console=no
    ${print}=  Catenate  SEPARATOR=${\n}  ${print}  ${key}:  ${fr_print}  ${\n}
  END
  Log To Console  Reading from reference SCFC file:
  Log To Console  ${print}

Print Dictionary Nicely
  [Arguments]  ${dict}  ${console}=yes
  ${keys}=  Get Dictionary Keys  ${dict}
  ${values}=  Get Dictionary Values  ${dict}
  ${print}=  Set Variable  ${EMPTY}
  FOR  ${key}  IN  @{keys}
    ${value}=  Get From Dictionary  ${dict}  ${key}
    ${value}=  Convert To String  ${value}
    ${value}=  Replace String Using Regexp  ${value}  u'(\\w+)'  \\g<1>
    ${print}=  Catenate  SEPARATOR=${\n}  ${print}  ${key}: ${value}
  END
  Log  ${print}  console=${console}
  [Return]  ${print}

Info Model Get RF Radio Module Release
  [Arguments]  ${serial_number}  ${alias}=default
  ${product_attribute}=  admin_im.Query Infomodel
  ...  query=get object //EQM_R-*//RMOD_R-* is [serialNumber=${serial_number}]
  ...  alias=${alias}
  [Return]  ${product_attribute.radioModuleHwReleaseCode}


Reset BTS And Wait Until FR Is Available
  [Arguments]  ${alias}=default
  BTS SRAN Power Reset  alias=${alias}
  Info Model FR State Check  availabilityStatus  Online  ${FR_UNDER_TEST_SERIAL_NUMBER}  RU_L
  ...  timeout=${FR_AVAILABILITY_TIMEOUT}
  ...  alias=${alias}

Info Model FR State Check
  [Arguments]  ${state}=proceduralState  ${value}=.*  ${fr_serial_number_list}=@{EMPTY}  ${view}=L
  ...  ${skip_if_sn_does_not_exist}=False  ${timeout}=1  ${verbose_time}=20  ${alias}=default
  [Documentation]  Keyword PASSes if provided RMODs in ${fr_serial_number_list} value of stateInfo.${state} equal to ${value}.
  ...  ${view} can be equal L (to check RMOD_L-*), RU_L (to check RMOD_L-*/RU_L-1) R (to check RMOD_R-*).
  ...  ${value} can be a regular expression.
  ...  ${fr_serial_number_list} can be a list, can be empty (then KW returns immediately),
  ...  or can be one serial number (string). If not defined, every RMOD will be checked.
  ...  ${verbose_time} - if keyword lasts more than specified time (seconds) it will print how long it took.
  Return From Keyword If  "${fr_serial_number_list}" == "@{EMPTY}"
  @{fr_serial_number_list}=  Convert Item To Single Element List  ${fr_serial_number_list}
  ${l_or_r}=  Set Variable If  "${view}" == "RU_L"  L  ${view}
  ${frs_in_bad_state}=  Create List
  ${start}=  DateTime.Get Current Date
  ${time_left}=  Set Variable  ${timeout}
  FOR  ${serial_number}  IN  @{fr_serial_number_list}
    ${rmod_ru_path}=  Set Variable If  "${view}" == "RU_L"  /RU_L-1  ${EMPTY}
    ${fr_exists}=  Run Keyword If  ${skip_if_sn_does_not_exist}  Run Keyword And Return Status
  ...  admin_im.Query Infomodel
  ...  query=//RMOD_${l_or_r}-*${rmod_ru_path} is [serialNumber=regex".*${serial_number[2:]}"]
  ...  timeout=0.1  alias=${alias}
    Continue For Loop If  ${skip_if_sn_does_not_exist} and not ${fr_exists}
  ${fr_in_good_state}=  Run Keyword And Return Status
  ...  admin_im.Query Infomodel Parallel
  ...  query1=//RMOD_${l_or_r}-*${rmod_ru_path} is [serialNumber=regex".*${serial_number[2:]}", stateInfo.${state}=regex"${value}"]
  ...  query2=//RMOD_L-* is [serialNumber=regex".*${serial_number[2:]}", stateInfo.${state}=regex"${value}"]
  ...  timeout=${time_left}
  ...  alias=${alias}
  ...  assertion_method=any
    Run Keyword If  not ${fr_in_good_state}  Append To List  ${frs_in_bad_state}  ${serial_number}
    ${stamp}=  DateTime.Get Current Date
    ${time_passed}=  DateTime.Subtract Date From Date  ${stamp}  ${start}
    ${time_left}=  Run Keyword If  ${time_passed} > ${timeout}
  ...  Set Variable  0.1
  ...  ELSE  Evaluate  ${timeout}-${time_passed}
  END
  ${stamp}=  DateTime.Get Current Date
  ${time_passed}=  DateTime.Subtract Date From Date  ${stamp}  ${start}
  Should Be True  not ${frs_in_bad_state}  ${frs_in_bad_state} are in bad state or Query Infomodel failed.
  Run Keyword If
  ...  ${timeout} > ${time_passed} > ${verbose_time}
  ...  Log To Console
  ...  The following radio list: ${fr_serial_number_list} reached state ${state}=${value} in ${time_passed} seconds.
  [Teardown]  Run Keyword If  "${KEYWORD_STATUS}"=="FAIL"  Log  ${frs_in_bad_state} did not reach state ${state}=${value} or Query Infomodel failed.

Set Overcurrent Variables
  [Arguments]  ${fr_serial_number}
  Set Test Variable  ${MHA_TYPE}  ${RU_DICT['${fr_serial_number}']['mha_pdu']['type']}
  Set Test Variable  ${MHA_IP}  ${RU_DICT['${fr_serial_number}']['mha_pdu']['ip_addr']}
  Set Test Variable  ${MHA_PORT}  ${RU_DICT['${fr_serial_number}']['mha_pdu']['port']}
  Set Test Variable  ${MHA_FEG}  ${RU_DICT['${fr_serial_number}']['mha_pdu']['feg']}
  Set Test Variable  ${MHA_LNA}  ${RU_DICT['${fr_serial_number}']['mha_pdu']['lna']}
  Set Test Variable  ${WITHOUT_MHA_FEG}  ${RU_DICT['${fr_serial_number}']['mha_pdu']['feg_without_mha']}
  Set Test Variable  ${WITHOUT_MHA_LNA}  ${RU_DICT['${fr_serial_number}']['mha_pdu']['lna_without_mha']}

Check IM Active
  [Arguments]  ${alias}
  ${status}=  is_infomodel_connected  alias=${alias}
  Should Be True  ${status}
  [Return]  ${status}


BTS Site Reset
  [Arguments]  ${verbose}=true  ${alias}=default
  Log  Performing BTS site reset.  console=${verbose}
  ${status}  ${output}=  Run Keyword And Ignore Error  Reset Site  alias=${alias}
  Run Keyword If  "${status}"=="FAIL"  Log  BTS is unavailable. It's probably already resetting...  console=true
  ${timeout_for_reset}=  Set Variable If  "${status}"=="FAIL"  0  120
  Wait For Admin Response After Reset  timeout_for_reset=${timeout_for_reset}  timeout_for_response=500  alias=${alias}

Wait For Admin Response After Reset
  [Arguments]  ${timeout_for_reset}=300  ${timeout_for_response}=400  ${alias}=default
  wait until keyword succeeds  ${timeout_for_response}  10  Verify FV Mrbts State  Commissioned  ${alias}

Info Model RMOD LED State Should Be
  [Arguments]  ${state}  ${fr_serial_number}  ${timeout}=5  ${alias}=default
  ${rmod_node}=  Info Model Get Rmod DistName For FR Serial Number  ${fr_serial_number}  alias=${alias}
  admin_im.Query Infomodel  query=${rmod_node}/RU_L-1/LED_L-1 is [ledState=${state}]
  ...  timeout=${timeout}  alias=${alias}

Verify FV Mrbts State
  [Arguments]  ${state}  ${alias}=default
  ${mrbts_state}=  Get MRBTS State  alias=${TC_ALIAS}
  ${return_status}=  Should Be True  '${mrbts_state}' == '${state}'
  [Teardown]  Log  \nMRBTS state = ${mrbts_state}  console=True

Info Model Cell List Availability Status Should Be
  [Arguments]  ${state}  ${lcr_id_list}  ${timeout}=5  ${alias}=default
  FOR  ${lcr_id}  IN  @{lcr_id_list}
  ...  admin_im.Query Infomodel
  ...  query=${INFO_MODEL_CELL_NODE_PATH}-${lcr_id} is [stateInfo.availabilityStatus=regex"(?i)${state}"]
  ...  timeout=${timeout}
  ...  alias=${alias}
  END

#Automated__SiSo__FR_Alarm_1932_CPRIN_repetition
#  Run Keyword If  not ${REPETITION}  Automated__SiSo__FR_Alarm_1932_CPRIN
#  Run Keyword If  not ${REPETITION}  Return From Keyword
#  FOR  ${repetition_index}  IN  @{REPETITION_LIST}
#    ${loop_log_path}=  TC Repetition Loop Start  ${REPETITION}  ${repetition_index}
#    Run Keyword And Continue On Failure  Automated__SiSo__FR_Alarm_1932_CPRIN  test_logs_path=${loop_log_path}
#    TC Repetition Loop Stop  ${REPETITION}  ${repetition_index}
#  END

Automated__SiSo__FR_Alarm_1932_CPRIN
  [Documentation]
  ...  Purpose of this test is checking if RET unit is correctly detected
  ...
  ...
  [Arguments]  ${test_logs_path}=${cfg.test_logs_path}
  Common Test Setup  tools_to_setup=IM_ADMIN
  Start Taf Syslog Session   ${bts}  ${bts}  additional
  Automated__SiSo__FR_Alarm_1932_CPRIN Procedure
  [Teardown]  Run Keywords
  ...  Common Test Teardown
  ...  AND  Stop Taf Syslog Session  ${bts}  ${bts}

Automated__SiSo__FR_Alarm_1932_CPRIN Procedure
  [Arguments]  ${out_rf_node}=${ACTIVE_FR_NODE}
  [Documentation]  KW has possibility to get timepout for waiting for active/inactive FID 1932 depending on FAN type.
  ...  If fan is external then timeout for FID 1932 will be longer than default. User Can set custom timeout in TS in TC section
  ...  when 'TIMEOUT_1932' not set, default default value is 90. In other case user sets own value.
  ${timeout_1932_exist}=  Run Keyword And Return Status  Should Not Be Empty  ${TIMEOUT_1932}
  ${fan_timeout}=  Set Variable If  ${timeout_1932_exist}  ${TIMEOUT_1932}  90
  Create CS Standard Radio Related Variables For RFV
  Fetch tcs.json File On FR  out_rf_node=${out_rf_node}
  Change Value Of Nrpm_fail On FR  out_rf_node=${out_rf_node}
  Perform RU Power Remove  ${FR_UNDER_TEST_SERIAL_NUMBER}  60 sec
  Run Keyword And Continue On Failure  Assert Any
  ...  class_name=RMOD
  ...  parameters=serialNumber=${FR_UNDER_TEST_SERIAL_NUMBER},operationalState=regex"(?i)Disabled"
  ...  timeout=210
  ...  alias=${TC_ALIAS}
  Perform RU Power Insert  ${FR_UNDER_TEST_SERIAL_NUMBER}  60 sec
  Run Keyword And Continue On Failure  Assert Any
  ...  class_name=RMOD
  ...  parameters=serialNumber=${FR_UNDER_TEST_SERIAL_NUMBER},operationalState=regex"(?i)Enabled"
  ...  timeout=210
  ...  alias=${TC_ALIAS}
  Mandatory And Allowed Alarms Should Be As Expected
  ...  mandatory=${ALARMS['fr_under_test_and_related']['im_alarm_list']}
  ...  btssm_mandatory=${ALARMS['fr_under_test_and_related']['enb_mng_alarm_list']}
  ...  btssm_alarms_file_name=${TC_ALIAS}_Start.xml
  ...  alias=${TC_ALIAS}
  Sleep  30s  Waiting for Fan states after RMOD insertion
  Verify FAN For Rmod
  ...  rmod_sn=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  bts_id=${BTS_ID}
  Stop RF FAN  ${FR_UNDER_TEST_SERIAL_NUMBER}  fan_1932
  Check fault 1932  timeout=${fan_timeout}
  Verify FAN For Rmod
  ...  rmod_sn=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  bts_id=${BTS_ID}
  ...  availability=not installed
  ...  operational=disabled
  ...  onair=${FALSE}
  Start RF FAN  ${FR_UNDER_TEST_SERIAL_NUMBER}  fan_1932
  ${inactve_1932}=  Run Keyword And Return Status  admin.Assert Alarm Inactive
  ...  faultId=1932
  ...  timeout=${fan_timeout}
  ...  connection=${BTS_ID}
  Run Keyword If  not ${inactve_1932}  Run Keywords
  ...  Log To Console  FaultID 1932 not cleared within ${fan_timeout}s, fail.
  ...  AND  Fail  FaultID 1932 not cleared within ${fan_timeout}s, fail.
  Verify FAN For Rmod
  ...  rmod_sn=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  bts_id=${BTS_ID}
  Perform RU Power Remove  ${FR_UNDER_TEST_SERIAL_NUMBER}  60 sec
  Run Keyword And Continue On Failure  Assert Any
  ...  class_name=RMOD
  ...  parameters=serialNumber=${FR_UNDER_TEST_SERIAL_NUMBER},operationalState=regex"(?i)Disabled"
  ...  timeout=210
  ...  alias=${TC_ALIAS}
  Perform RU Power Insert  ${FR_UNDER_TEST_SERIAL_NUMBER}  60 sec
  Run Keyword And Continue On Failure  Assert Any
  ...  class_name=RMOD
  ...  parameters=serialNumber=${FR_UNDER_TEST_SERIAL_NUMBER},operationalState=regex"(?i)Enabled"
  ...  timeout=210
  ...  alias=${TC_ALIAS}
  Mandatory And Allowed Alarms Should Be As Expected
  ...  mandatory=${ALARMS['fr_under_test_and_related']['im_alarm_list']}
  ...  btssm_mandatory=${ALARMS['fr_under_test_and_related']['enb_mng_alarm_list']}
  ...  btssm_alarms_file_name=${TC_ALIAS}_Stop.xml
  ...  alias=${TC_ALIAS}
  Sleep  10s  Waiting for states stabilization after Radio Unit power on/off
  Verify FID 4589  node=${BTS_ID}
  [Teardown]  Run Keywords
  ...  Perform RU Power Insert  ${FR_UNDER_TEST_SERIAL_NUMBER}  60 sec
  ...  AND  Start RF FAN  ${FR_UNDER_TEST_SERIAL_NUMBER}  fan_1932
  ...  AND  Run Keyword And Ignore Error  admin.Assert Alarm Inactive
  ...  faultId=1932
  ...  timeout=${fan_timeout}
  ...  connection=${BTS_ID}

#Automated__SiSo__FR_Alarm_1933_CPRIN_repetition
#  Run Keyword If  not ${REPETITION}  Automated__SiSo__FR_Alarm_1933_CPRIN
#  Run Keyword If  not ${REPETITION}  Return From Keyword
#  FOR  ${repetition_index}  IN  @{REPETITION_LIST}
#    ${loop_log_path}=  TC Repetition Loop Start  ${REPETITION}  ${repetition_index}
#    Run Keyword And Continue On Failure  Automated__SiSo__FR_Alarm_1933_CPRIN  test_logs_path=${loop_log_path}
#    TC Repetition Loop Stop  ${REPETITION}  ${repetition_index}
#  END

Automated__SiSo__FR_Alarm_1933_CPRIN
  [Documentation]
  ...  Purpose of this test is checking if RET unit is correctly detected
  ...
  ...
  [Arguments]  ${test_logs_path}=${cfg.test_logs_path}
  Common Test Setup
  Automated__SiSo__FR_Alarm_1933_CPRIN Procedure
  [Teardown]  Common Test Teardown


Automated__SiSo__FR_Alarm_1933_CPRIN Procedure
  Create CS Standard Radio Related Variables For RFV
  Fetch tcs.json File On FR
  Change Value Of Nrpm_fail On FR
  Perform RU Power Remove  ${FR_UNDER_TEST_SERIAL_NUMBER}  60 sec
  Perform RU Power Insert  ${FR_UNDER_TEST_SERIAL_NUMBER}  60 sec
  Mandatory And Allowed Alarms Should Be As Expected
  ...  mandatory=${ALARMS['fr_under_test_and_related']['im_alarm_list']}
  ...  btssm_mandatory=${ALARMS['fr_under_test_and_related']['enb_mng_alarm_list']}
  ...  btssm_alarms_file_name=${TC_ALIAS}_Start.xml
  ...  alias=${TC_ALIAS}
  Stop RF FAN  ${FR_UNDER_TEST_SERIAL_NUMBER}  fan_1932
  Check fault 1933
  Start RF FAN  ${FR_UNDER_TEST_SERIAL_NUMBER}  fan_1932
  Perform RU Power Remove  ${FR_UNDER_TEST_SERIAL_NUMBER}  60 sec
  Perform RU Power Insert  ${FR_UNDER_TEST_SERIAL_NUMBER}  60 sec
  Mandatory And Allowed Alarms Should Be As Expected
  ...  mandatory=${ALARMS['fr_under_test_and_related']['im_alarm_list']}
  ...  btssm_mandatory=${ALARMS['fr_under_test_and_related']['enb_mng_alarm_list']}
  ...  btssm_alarms_file_name=${TC_ALIAS}_Stop.xml
  ...  alias=${TC_ALIAS}
  [Teardown]  Perform RU Power Insert  ${FR_UNDER_TEST_SERIAL_NUMBER}  60 sec

Stop RF FAN
  [Arguments]  ${fr_serial_number}  ${fan_name}
  pdu.Setup Pdu
  ...  model=${RU_DICT['${fr_serial_number}']['fhsfan1933']['pdu']['type']}
  ...  host=${RU_DICT['${fr_serial_number}']['fhsfan1933']['pdu']['ip_addr']}
  ...  alias=pdu
  pdu.Power On
  ...  port=${RU_DICT['${fr_serial_number}']['fhsfan1933']['pdu']['port']}
  ...  pdu_device=pdu
  pdu.Teardown Pdu  pdu_device=pdu
  Log To Console  Fan stopped

Start RF FAN
  [Arguments]  ${fr_serial_number}  ${fan_name}
  pdu.Setup Pdu
  ...  model=${RU_DICT['${fr_serial_number}']['fhsfan1933']['pdu']['type']}
  ...  host=${RU_DICT['${fr_serial_number}']['fhsfan1933']['pdu']['ip_addr']}
  ...  alias=pdu
  pdu.Power Off
  ...  port=${RU_DICT['${fr_serial_number}']['fhsfan1933']['pdu']['port']}
  ...  pdu_device=pdu
  pdu.Teardown Pdu  pdu_device=pdu
  Log to Console  Fan started

Fetch tcs.json File On FR
  [Arguments]
  ...  ${enb_ip_addr}=192.168.255.1
  ...  ${rf_ip_address}=${FR_INFO['${FR_UNDER_TEST_SERIAL_NUMBER}']['ip']}
  ...  ${out_rf_node}=0x1018
  ...  ${rf_port}=2000
  [Documentation]  Keyword logs to RF module using telnet and generates tcs.json to edit.
  SSHLibrary.Open Connection  host=${enb_ip_addr}
  Run Keyword And Ignore Error  SSHLibrary.Login  toor4nsn  oZPS0POrRieRtu
  SSHLibrary.Write  lxc-attach -n ${out_rf_node} -- telnet ${rf_ip_address} ${rf_port}
  ${out_rf_cprin_telnet_prompt}=  SSHLibrary.Read Until  Escape character is '^]'.
  SSHLibrary.Write  / action create ConfigAccess /ca /module
  SSHLibrary.Read Until Regexp  .*done.*|.*Path.*
  SSHLibrary.Write  /ca action fetch DECODED "tcs.bin" "/ram/tcs.json"
  SSHLibrary.Read Until Regexp  .*done.*
  SSHLibrary.Close All Connections
  Log to console  Feching tcs.json completed


Change Value Of Nrpm_fail On FR
  [Arguments]
  ...  ${enb_ip_addr}=192.168.255.1
  ...  ${rf_ip_address}=${FR_INFO['${FR_UNDER_TEST_SERIAL_NUMBER}']['ip']}
  ...  ${no_nrpm_fails}=1
  ...  ${no_tblock_fails}=15.0
  ...  ${out_rf_node}=0x1018
  ...  ${rf_port}=2000
  ...  ${alias}=default
  [Documentation]  Changes Nrpm_fail to ${no_nrpm_fails} and stores changed file on radio.
  ...  For fault 1933 ${no_tblock_fails} is also changed.
  SSHLibrary.Open Connection  host=${enb_ip_addr}
  Run Keyword And Ignore Error  SSHLibrary.Login  toor4nsn  oZPS0POrRieRtu
  SSHLibrary.Write  rm /user/toor4nsn/.ssh/known_hosts
  SSHLibrary.Write  lxc-attach -n ${out_rf_node} -- ssh root@${rf_ip_address}
  #Alternatywa dla Check SSH Radio Prompt -> SSHLibrary.Write  lxc-attach -n ${out_rf_node} -- ssh root@${rf_ip_address} --  yes
  Sleep  5
  ${output}  SSHLibrary.Read
  Run Keyword If  """Are you sure you want to continue""" in """${output}"""  SSHLibrary.Write  yes
  Sleep  2
  SSHLibrary.Write  sed -i 's/.\"Nrpm_fail\":.*/\ "Nrpm_fail\": ${no_nrpm_fails},/g' /ram/tcs.json
  Run Keyword If
  ...  '${alias}'=='FR_Alarm_1933'
  ...  SSHLibrary.Write
  ...  sed -i 's/.\"Tblock\":.*/\ "Tblock\": ${no_tblock_fails},/g' "/ram/tcs.json"
  SSHLibrary.Write  exit
  Wait Until Keyword Succeeds  10  5  SSHLibrary.Read Until Regexp  root@f.*
  SSHLibrary.Write  lxc-attach -n ${out_rf_node} -- telnet ${rf_ip_address} ${rf_port}
  ${out_rf_cprin_telnet_prompt}=  SSHLibrary.Read Until  Escape character is '^]'.
  SSHLibrary.Write  /ca action store PERMANENT DECODED "tcs.bin" "/ram/tcs.json"
  SSHLibrary.Read Until Regexp  .*done.*
  SSHLibrary.Close Connection
  Log to console  Changed tcs.json successfully and uploaded on RFM

Check Fault 1932
  [Arguments]  ${timeout}
  [Documentation]  Temporary: Second alarm (1933) can be present due to
  ...  https://jira3.int.net.nokia.com/browse/CNI-31443
  ...  CNI-21710: Change fault 1932 from Customer to Additional R&D - alarm visible only in syslog
  ...  CNI-59481: Change fault 1932 from Additional R&D to Customer - alarm visible in Admin
  Log To Console  Waiting For Alarm 1932
  Assert Alarm Active  faultId=1932
  ...  timeout=${timeout}
  ...  alias=${TC_ALIAS}
  @{1932_allowed}=  Create List  No module fan detected  Fan Failure  Cooling fan broken
  ${fr_rmod_node_path}=  Info Model Get Rmod DistName For FR Serial Number
  ...  ${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  alias=${TC_ALIAS}
  Wait Until Keyword Succeeds  30  1  message should exist in syslog file
  ...  \\[Detector 1932.* ${fr_rmod_node_path}.*\\] active.*  alias=${TC_ALIAS}
  Mandatory And Allowed Alarms Should Be As Expected
  ...  mandatory=${ALARMS['fr_under_test_and_related']['im_alarm_list']}
  ...  btssm_mandatory=${ALARMS['fr_under_test_and_related']['enb_mng_alarm_list']}
  ...  btssm_alarms_file_name=${TC_ALIAS}.xml
  ...  allowed=${1932_allowed}
  ...  alias=${TC_ALIAS}
  Log To Console  Alarm 1932 raised in syslog, alarms verified

Check Fault 1933
  Log To Console  Waiting For Alarm 1933
  Assert Alarm Active  faultId=1933
  ...  timeout=50
  ...  alias=${TC_ALIAS}
  @{1933_allowed}=  Create List  Fan Failure  Cooling fan broken
  Mandatory And Allowed Alarms Should Be As Expected
  ...  mandatory=${ALARMS['fr_under_test_and_related']['im_alarm_list']}
  ...  btssm_mandatory=${ALARMS['fr_under_test_and_related']['enb_mng_alarm_list']}
  ...  btssm_alarms_file_name=${TC_ALIAS}.xml
  ...  allowed=${1933_allowed}
  ...  alias=${TC_ALIAS}
  Log To Console  Alarm 1933 raised, alarms verified

Create CS Standard Radio Related Variables For RFV
  [Arguments]
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${cfg.rmods_under_test[0]}
  Verify Unexpected And Historical Alarms
  ...  alias=${ru_bts_id}

  Set Test Variable  ${BTS_ID}  ${ru_bts_id}
  Set Test Variable  ${scfc_file_path}  ${CFG['NODES']['${ru_bts_id}']['scf_file_path']}
  Set Test Variable  ${SCFC_REFERENCE_FILE_PATH}  ${CFG['NODES']['${ru_bts_id}']['scf_file_path']}
  Set Test Variable  ${FR_UNDER_TEST_SERIAL_NUMBER}  ${cfg.rmods_under_test[0]}
  Set Test Variable  ${TC_ALIAS}  ${ru_bts_id}
  ${act_category_alarms}=  Get From Dictionary  ${cfg.NODES['${BTS_ID}']}  alarms_category
  Set Test Variable  ${ACT_CATEGORY_ALARMS}  ${act_category_alarms}
  Optimized RF Variant Preparation  alias=${ru_bts_id}
  Set Alarm Information Dictionary  ${FR_UNDER_TEST_SERIAL_NUMBER}  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
  Set Cell Information Dictionary
  ...  lncel_id_list=${cfg.RF_INFO['${FR_UNDER_TEST_SERIAL_NUMBER}']['LNCEL']['scf_cellid_primary']}
  ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
  ...  alias=${ru_bts_id}

Verify FAN For Rmod
  [Arguments]  ${rmod_sn}  ${bts_id}  ${availability}=${EMPTY}  ${operational}=${EMPTY}  ${onair}=${TRUE}
  [Documentation]
  ...  Description:
  ...  KW checks only one radio unit at a time.
  ...  Checking expected status FAN for specific RMOD. If RMOD doesn't have fan, unit is skipped.
  ...  KW checks "availabilityStatus" and "operationalState" depending on "onair" switch.
  ...  KW checks "administrativeState" and "usageState" as fixed values "unlocked" and "idle".
  ...  If "onair" switch is ${TRUE} (default value) then availabilitystatus is missing and operationalState is "enabled"
  ...  in other case availabilitystatus/operationalState must be provided by user.
  ...  |  **Author:**  daniel.bartkowiak@nokia.com
  ...  |  **Maintainer:**  daniel.bartkowiak@nokia.com
  ${status}  ${output}=  Run Keyword And Ignore Error
  ...  admin.Assert Any
  ...  class_name=RMOD
  ...  parameters=serialNumber=${rmod_sn}
  ...  connection=${bts_id}
  Run Keyword If  "${status}"=="FAIL"  Run Keywords
  ...  Log To Console  Radio Unit ${rmod_sn} not found on BTS-${bts_id}
  ...  AND  Fail  Radio Unit ${rmod_sn} not found on BTS-${bts_id}
  ${rmod}=  Fetch From Right  ${output[0]['id']}  /
  ${fan_info_dict}=  admin.Get Rmod Fan Info  timeout=120  connection=${bts_id}
  FOR  ${rmod_key}  IN  @{fan_info_dict}
    Continue For Loop If  "${rmod_key}"!="${rmod}"
    _Check FAN State
    ...  ${rmod_key}
    ...  ${fan_info_dict['${rmod_key}']}
    ...  ${bts_id}
    ...  ${availability}
    ...  ${operational}
    ...  ${onair}
    Return From Keyword
  END
  Run Keywords  Log To Console  Radio Unit ${rmod_sn} not found in fan dictionary
  ...  AND  Fail  Radio Unit ${rmod_sn} not found in fan dictionary

_Check FAN State
  [Arguments]  ${rmod_key}  ${fans}  ${bts_id}  ${availability}  ${operational}  ${onair}
  FOR  ${fan_key}  IN  @{fans}
    ${fan_dist}  Set Variable  ${rmod_key}/${fan_key}
    ${fanPresent_value}=  Evaluate Xpath
    ...  ${CFG['NODES']['${bts_id}']['scf_file_path']}
    ...  string(.//managedObject[contains(@class, "FAN_R") and contains(@distName, "${fan_dist}")]/p[@name="fanPresent"])
    Return From Keyword If  "${fanPresent_value}"=="${EMPTY}"
    Run Keyword If  ${onair}  Run Keywords
    ...  Variable Should Not Exist  ${fans['${fan_key}']['availabilityStatus']}
    ...  AND  Should Be Equal  ${fans['${fan_key}']['operationalState']}  enabled  ignore_case=${TRUE}
    ...  AND  Should Be Equal  ${fans['${fan_key}']['administrativeState']}  unlocked  ignore_case=${TRUE}
    ...  AND  Should Be Equal  ${fans['${fan_key}']['usageState']}  idle  ignore_case=${TRUE}
    ...  ELSE  Run Keywords
    ...  Should Be Equal  ${fans['${fan_key}']['availabilityStatus']}  ${availability}  ignore_case=${TRUE}
    ...  AND  Should Be Equal  ${fans['${fan_key}']['operationalState']}  ${operational}  ignore_case=${TRUE}
    ...  AND  Should Be Equal  ${fans['${fan_key}']['administrativeState']}  unlocked  ignore_case=${TRUE}
    ...  AND  Should Be Equal  ${fans['${fan_key}']['usageState']}  idle  ignore_case=${TRUE}
  END
  [Teardown]  Run Keyword If  "${KEYWORD_STATUS}"=="FAIL"
  ...  Log To Console  ${fan_dist} has wrong states: ${fans['${fan_key}']['availabilityStatus']}, ${fans['${fan_key}']['operationalState']}
