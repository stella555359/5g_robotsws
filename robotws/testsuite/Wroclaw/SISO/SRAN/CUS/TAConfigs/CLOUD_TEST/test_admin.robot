*** Settings ***
Documentation  Test file
...  Maintainer: slawomir.jastrzebski@nokia.com

#Library          ute_admin
Library    taf.sbts.oam.coam.admin   WITH NAME   admin

Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource    ../../resources/common_keywords.robot
Resource    ../../resources/variables.robot
#Resource    ../../resources/bts_actions.robot
#Resource    ../../resources/bts_verification.robot
#Resource    ../../resources/logging.robot
#Resource    ../../resources/pdu.robot
#Resource    ../../resources/wts.robot
#Resource    ../../resources/optical_switch.robot
Resource    ./variables.robot
#Resource    ./test_keywords.robot
#Resource    ../../../resources/nr_rat_reset.robot

Suite Setup      Test setup
Suite Teardown   Test teardown

*** Variables ***
${BTS_ADDRESS}    192.168.255.129
${BTS_PORT}       443
${USE_SSL}        True
${SCFC_FILE_PATH}=                  ${CURDIR}/config/SCFC.xml
${SCFC_FILE_PATH_1}=                ${CURDIR}/config/SCFC_1.xml
${CUSINI_FILE_PATH}=                ${CURDIR}/config/cus.ini
${CUSINI_FILE_PATH_1}=              ${CURDIR}/config/cus_1.ini
${EPCSIM_FILE_PATH}=                ${CURDIR}/config/epc.lua
${CA_SUPPORTED_BANDS}=              1:a:a+3:a:a|3:a:a+1:a:a
${allowed_alarms}=                  ${ALLOWED_ALARMS_ONAIR}
#${RAT_IMPACT}=                      NONE
#${RAT_IMPACT}=                      12,10
#${RAT_IMPACT}=                      9,10,11,12
${RAT_IMPACT}=                      LTE

*** Test Cases ***
Test Admin
#    ${scfc_file_path}=    Set Variable    ${SCFC_REFERENCE_FILE_PATH}

    Set Message Colors
    Set Log Prefix
    ${log_steps}=  Set Variable  True
    ${log_to_console}=  Set Variable  True

#    ${scfc_file_path}=  Set Variable  ${SCFC_FILE_PATH}
#    BTS SCFC And Admin Cells Count Should Match   scfc_file_path=${scfc_file_path}
#    ${scfc_file_path}=  Set Variable  ${SCFC_FILE_PATH_1}
#    BTS SCFC And Admin Cells Count Should Match   scfc_file_path=${scfc_file_path}

#    ${alarms}=  get_unexpected_historical_alarms
#    Log  \nAlarmy\n:${alarms}\n  console=${log_to_console}
#    sleep  60
#    ${alarms}=  get_unexpected_historical_alarms
#    Log  \nAlarmy\n:${alarms}\n  console=${log_to_console}
#    ${alarms}=  get_historic_alarms
#    Log  \nAlarmy\n:${alarms}\n  console=${log_to_console}


#    Verify Unexpected Active Alarms  allowed_alarms=${ALLOWED_ALARMS_FAULT_ID}  log_prefix=${info_prefix}
#    Sleep  60
#    Verify Unexpected Historical Alarms  allowed_alarms=${ALLOWED_ALARMS_FAULT_ID}  log_prefix=${info_prefix}

#    CUS BTS Rat Reset
#    ...  rat_type=NR
#    ...  get_kpi=True
#    ...  hw_configuration=${EMPTY}
#    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}

#    ${cells_info}=  admin.Get Cells Info  cell_type=lte
#    ${cells_info}=  admin.Get Cells Info  cell_type=nr

#    CUS Nr Rat Reset
#    ...  get_kpi=True
#    ...  hw_configuration=${EMPTY}
#    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}

#    Import Resource  ${CURDIR}/../../../resources/nr_rat_reset.robot

#    ${cell_ids}=  Set Variable  2,12,5,7
#    ${cell_dists}=  Create Selected Cells Distnames   cell_ids=${cell_ids}
#    Log  \nCell dists:${cell_dists}  console=${log_to_console}
#
#    ${nsa_dist_names}=  Find NR NSA Cells
#    Log  \nNSA dist names:${nsa_dist_names}  console=${log_to_console}
#
#    ${class_names}=  Create List  NRCEL  LNCEL  SMOD
#    ${all_dist_names}=  Get Dist Names For Given Class Name Objects  class_names=${class_names}
#    Log  \nAll class dists:${all_dist_names}  console=${log_to_console}
#
#    ${final_dist_names}=  Remove Dist Names From Given Class Name Objects
#    ...  dist_names=${cell_dists}   class_names=${class_names}
#    Log  \nRemaining class dist names:${final_dist_names}  console=${log_to_console}


#    ${impacted_objects}  ${not_impacted_objects}=  Gather Cells Affected By CB008880  rat_reset=NR
#    Log  \nImpacted objects:${impacted_objects}  console=${log_to_console}
#    Log  \nNot impacted objects:${not_impacted_objects}  console=${log_to_console}
#
#    ${impacted_objects}  ${not_impacted_objects}=  Get Objects Affected By Isolated Reset  rat_reset=NR
#    Log  \nImpacted objects:${impacted_objects}  console=${log_to_console}
#    Log  \nNot impacted objects:${not_impacted_objects}  console=${log_to_console}

#   ${status}  ${bb_message}=  Run Keyword And Ignore Error
#    ...  admin.Assert Any  class_name=BBMOD  parameters=productName=regex"(?i)ABI[OL]"
#    Log  \nBBMOD:\n${bb_message}  console=${log_to_console}
#
#
#   ${status}  ${bb_message}=  Run Keyword And Ignore Error
#    ...  admin.Assert Any  class_name=BBMOD  parameters=productName=regex"(?i)ABI[NL]"
#    Log  \nBBMOD:\n${bb_message}  console=${log_to_console}
#
#   ${status}  ${bb_message}=  Run Keyword And Ignore Error
#    ...  admin.Assert Any  class_name=BBMOD  parameters=productName=regex"(?i)ABI[NO]"
#    Log  \nBBMOD:\n${bb_message}  console=${log_to_console}
#
#
#   ${status}  ${bb_message}=  Run Keyword And Ignore Error
#    ...  admin.Assert Any  class_name=BBMOD  parameters=productName=regex"(?i)ABI[CL]"
#    Log  \nBBMOD:\n${bb_message}  console=${log_to_console}



#    ${bbmod_dist_names}=  Get Baseband Dist Names With Excluded Items  pattern=^ABI[CL]
#    Log  \nBBMOD dist names:\n${bbmod_dist_names}  console=${log_to_console}

#    Log  \n\n${start_prefix_green}Test Case: CUS Lte Rat Reset  console=${log_to_console}
##    Report Enb Hardware Configuration  configuration=${hw_configuration}
#    ${bts_enabled_rat_list}=  BTS Get Enabled Rat List
#
#    Log  ${dots_prefix_green}Hardware modules checking  console=${log_to_console}
#    BTS Verify Hardware  bts_rat_list=${bts_enabled_rat_list}  log_prefix=${info_prefix}
#    Admin BTS Should Be OnAir  log_prefix=${info_prefix}
#    Log  ${info_prefix}All cells are onAir now  console=${log_to_console}
#    Log  ${ok_prefix_green}Hardware modules checking  console=${log_to_console}
#
#    Log  ${dots_prefix_green}Perform BTS Parameter Recommissioning  console=${log_to_console}
#    BTS Perform Parameter Recommissioning And Check  dist_name=MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1
#    ...  parameter=actRatResetEnhancement  param_value=true  operation=update
#    Log  ${ok_prefix_green}Perform BTS Parameter Recommissioning  console=${log_to_console}
#
##    Sleep  20
#    Perform LTE RAT reset  act_rat_reset_enhancement=true  reset_type=soft  timeout=600
#    Log  ${dots_prefix_green}Hardware modules checking  console=${log_to_console}
#    BTS Verify Ims File  log_prefix=${info_prefix}
#    BTS Verify Hardware  bts_rat_list=${bts_enabled_rat_list}  log_prefix=${info_prefix}
#    Admin BTS Should Be OnAir  log_prefix=${info_prefix}
#    Log  ${info_prefix}All cells are onAir now  console=${log_to_console}
#    Log  ${ok_prefix_green}Hardware modules checking  console=${log_to_console}
#
#    Perform LTE RAT reset  act_rat_reset_enhancement=true  reset_type=hard  timeout=600
#    Log  ${dots_prefix_green}Hardware modules checking  console=${log_to_console}
#    BTS Verify Ims File  log_prefix=${info_prefix}
#    BTS Verify Hardware  bts_rat_list=${bts_enabled_rat_list}  log_prefix=${info_prefix}
#    Admin BTS Should Be OnAir  log_prefix=${info_prefix}
#    Log  ${info_prefix}All cells are onAir now  console=${log_to_console}
#    Log  ${ok_prefix_green}Hardware modules checking  console=${log_to_console}
#
#    Log  ${dots_prefix_green}Perform BTS Parameter Recommissioning  console=${log_to_console}
#    BTS Perform Parameter Recommissioning And Check  dist_name=MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1
#    ...  parameter=actRatResetEnhancement  param_value=false  operation=update
#    Log  ${ok_prefix_green}Perform BTS Parameter Recommissioning  console=${log_to_console}
#
#    Perform LTE RAT reset  act_rat_reset_enhancement=true  reset_type=soft  timeout=600
#    Log  ${dots_prefix_green}Hardware modules checking  console=${log_to_console}
#    BTS Verify Ims File  log_prefix=${info_prefix}
#    BTS Verify Hardware  bts_rat_list=${bts_enabled_rat_list}  log_prefix=${info_prefix}
#    Admin BTS Should Be OnAir  log_prefix=${info_prefix}
#    Log  ${info_prefix}All cells are onAir now  console=${log_to_console}
#    Log  ${ok_prefix_green}Hardware modules checking  console=${log_to_console}
#
#    Perform LTE RAT reset  act_rat_reset_enhancement=true  reset_type=hard  timeout=600
#    Log  ${dots_prefix_green}Hardware modules checking  console=${log_to_console}
#    BTS Verify Ims File  log_prefix=${info_prefix}
#    BTS Verify Hardware  bts_rat_list=${bts_enabled_rat_list}  log_prefix=${info_prefix}
#    Admin BTS Should Be OnAir  log_prefix=${info_prefix}
#    Log  ${info_prefix}All cells are onAir now  console=${log_to_console}
#    Log  ${ok_prefix_green}Hardware modules checking  console=${log_to_console}
#
#    Admin Check Inactive FaultId Alarms  6202  6150
#    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
#    Log  ${ok_prefix_green}Checking active alarms  console=${log_to_console}
#    Log  ${done_prefix_green}Test Case: CUS Rat Reset\n  console=${log_to_console}

#    Get Firmware Version  before_update
#    Log  \n${info_prefix}Firmware versions before software update:  console=True
#    ${firmware_version}=  Convert To String  ${FIRMWARE_BEFORE_UPDATE}
#    ${firmware_version}=  Remove String  ${firmware_version}  {  }
#    Log  ${info_prefix}${firmware_version}  console=True
#
#    Get Firmware Version  after_update
#    Log  \n${info_prefix}Firmware versions after software update:  console=True
#    ${firmware_version}=  Convert To String  ${FIRMWARE_AFTER_UPDATE}
#    ${firmware_version}=  Remove String  ${firmware_version}  {  }
#    Log  ${info_prefix}${firmware_version}  console=True
#
#    ${TARGET_SOFTWARE}=  Set Variable  SBTS24R1_ENB_9999_231024_000005
#    ${sw_info}=  Get Software Info
#    ${active_sw}=  Set Variable  ${sw_info['Active SW version']}
#    Log  ${info_prefix}Active software: ${active_sw}  console=${log_steps}
#    ${target_sw}=  Set Variable  ${TARGET_SOFTWARE}
#    Log  ${info_prefix}Target software: ${target_sw}  console=${log_steps}
#
#
#    Set Update Type  active_sw=${active_sw}  target_sw=${target_sw}
#    Run Keyword If  ${INTER_RELEASE_UPDATE}
#    ...  Log  ${info_prefix}Inter release update has been completed  console=${log_steps}
#    ...  ELSE
#    ...  Log  ${info_prefix}Intra release update has been completed  console=${log_steps}
#
#    ${kpi_name}=  Get Kpi Name For Update
#    Log  KPI name: ${kpi_name}  console=True


#    Set Update Type  SBTS23R2_ENB_0000_001395_000000  SBTS00_ENB_9999_231023_000005

#BTS SECTION

#    ${carel_list}=  Get Managed Objects  class_name=CAREL_A
#    Log to console  \nManaged Objects: ${manage_objects}
#    Should Not Be Empty    ${manage_objects}
#    ${carel_length}=  Get Length  ${carel_list}
#    Log to console  \nCAREL length: ${carel_length}\n

#    ${mrbts_state}=  Get Mrbts State
#    Log to console  \nMRBTS state: ${mrbts_state}

#    ${lnbts_id}=    Get Id For Current    LNBTS
#    Log to console    \n LNBTS ID:${lnbts_id}\n

#    ${bts_info}=    Get Bts Info
#    Log to console  \nBTS info: ${bts_info}

#    ${all_items}=    Get All Items By Class Name    SMOD
#    Log to console    \nGet All Items By Class Name:\n${all_items}\n
#
#    ${bts_id}=    Get Id For Current    BTS
#    Log to console    \n BTS ID number:${bts_id}\n
#
#    ${bts_params}=    Get Parameters For    BTS    ${bts_id}
#    Log to console    \nGet Parameters For BTS:\n${bts_params}\n
#
#    ${assert_bts}=    Assert    BTS    ${bts_id}    proceduralState=NotCommissioned    20
#    Log to console    \nAssert BTS proceduralState is:\n${assert_bts}\n
#
#    ${no_assert_bts}=   Assert No  BTS  proceduralState=OnAir  timeout=5
#    Log to console    \nNo assert BTS proceduralState is:\n${no_assert_bts}\n

#    ${all_bts_params}=    Get Parameters For All    BTS
#    Log to console    \nGet Parameters For All BTS:\n${all_bts_params}\n
#
#    ${every_bts}=    Assert Every    BTS    proceduralState=NotCommissioned    20
#    Log to console    \nAssert Every BTS proceduralState is:\n${every_bts}\n
#
#    ${bts_ids}=    Get Ids For All    BTS
#    Log to console    \nAll BTS Ids:\n${bts_ids}\n

#    ${smod_position}=    Get Smod Position
#    Log to console    \nSmod Position:${smod_position}\n
#
# Get SFP Cablinks for UTE
#    ${sfp_links}=    Get Sfp Links
#    Log to console    \nSFP links:${sfp_links['connected']}\n
#    ${cablink_number}=    Get Length    ${sfp_links['connected']}
#    Log to console    \nCablink number:${cablink_number}\n
#
#    :FOR  ${cablink_element}  IN  @{sfp_links['connected']}
#    \  Log to console    \nCablink element:${cablink_element['cablink']['distName']}\n

#CELL SECTION

#    ${cell_list}=    Get Cell List
#    Log to console    \nGet Cell List:\n${cell_list['cells']['lte']}\n
#
#    ${count_cells}=    Get Length    ${cell_list['cells']['lte']}
#    Log to console    \nCell counts:${count_cells}\n

#    ${all_items}=     Get All Items By Class Name    LNCEL
#     Log to console    \nGet All Items By Class Name LNCEL:\n${all_items}\n
#
#    ${all_lncel_ids}=    Get Ids For All    class_name=LNCEL
#    Log to console    \nGet All LNCEL IDs:\n${all_lncel_ids}\n

#    ${lncel_id}=    Get Cell Id By Configuration Id  rat=LTE  configuration_id=1
#    Log to console    \nCell Id By Configuration Id 1:\n${lncel_id}\n
#
#    ${lncel_params}=    Get Parameters For  class_name=LNCEL  id_num=${lncel_id}
#    Log to console    \nGet Parameters For LNCEL 1:\n${lncel_params}\n

#    ${lncel_info}=  Get Cell Specific Info  cell_id=${lncel_id}  timeout=10  detailed_output=False
#    Log to console    \nGet Info For LNCEL 1:\n${lncel_info}\n

#    ${lncel_id}=    Get Cell Id By Configuration Id  rat=LTE  configuration_id=2
#    Log to console    \nCell Id By Configuration Id 2:\n${lncel_id}\n
#
#    ${lncel_params}=    Get Parameters For  class_name=LNCEL  id_num=${lncel_id}
#    Log to console    \nGet Parameters For LNCEL 2:\n${lncel_params}\n
#
#    ${lncel_id}=    Get Cell Id By Configuration Id  rat=LTE  configuration_id=3
#    Log to console    \nCell Id By Configuration Id 3:\n${lncel_id}\n
#
#    ${lncel_params}=    Get Parameters For  class_name=LNCEL  id_num=${lncel_id}
#    Log to console    \nGet Parameters For LNCEL 3:\n${lncel_params}\n

#    ${all_lncell_params}=    Get Parameters For All    LNCEL
#    Log to console    \nGet Parameters For All LNCELL:\n${all_lncell_params}\n
#
#    ${assert_lncel}=    Assert    class_name=LNCEL    id=${lncel_id}    parameters=operationalState=regex"(?i)disabled"    timeout=20
#    Log to console    \nAssert LNCEL OperationalState is:\n${assert_lncel}\n

#    ${assert_lncel}=    Assert    class_name=LNCEL    id=${lncel_id}    parameters=blockingState=regex"(?i)unblocked|blocked"    timeout=20
#    Log to console    \nAssert LNCEL BlockingState is:\n${assert_lncel}\n

#    ${every_lncel}=    Assert Every    LNCEL    operationalState=Disabled,proceduralState=Validated   20
#    Log to console    \nAssert Every LNCEL proceduralState is:\n${every_lncel}\n

#RMOD SECTION

#    ${all_rmod_ids}=    Get Ids For All    RMOD
#    Log to console    \nGet All RMOD IDs:\n${all_rmod_ids}\n
#
#    ${rmods_params}=    Get Parameters For All    class_name=RMOD
#    Log to console    \nGet Parameters For All RMOD:\n${rmods_params}\n
#    ${rmod_params}=    Get Parameters For    RMOD    ${all_rmod_ids[0]}
#    Log to console    \nGet Parameters For RMOD (${all_rmod_ids[0]}):\n${rmod_params}\n
#
#    ${rmod_list}=  Get Managed Objects  class_name=RMOD_M

#    ${assert_rmod}=    Assert    class_name=RMOD    id=${all_rmod_ids[0]}
#     ...  parameters=operationalState=regex(?i)"enabled",serialNumber=L6114724474    timeout=20
#    Log to console    \nAssert RMOD (${all_rmod_ids[0]}) is:\n${assert_rmod}\n

#ALARM SECTION

#    Assert Alarm Active    parameters=faultId=6202    timeout=60
#    Assert Alarm Active    parameters=faultId=6150    timeout=60
#    ${lncel_distname}=  Get Cell Id By Configuration Id  rat=LTE  configuration_id=1
#    Block Cell  dist_name=${lncel_distname}  timeout=120
#    sleep  5
#    Assert Alarm Active  faultId=49, severity=Critical, faultName="Cell blocked", alarmingResource=${lncel_distname}

#    ${lncel_distname}=  Get Cell Id By Configuration Id  rat=LTE  configuration_id=4
#    Block Cell  dist_name=${lncel_distname}  timeout=120
#    sleep  5
#    Assert Alarm Active  faultId=49, severity=Critical, faultName="Cell blocked", alarmingResource=${lncel_distname}
#
#    ${nrcel_id}=    Get Cell Id By Configuration Id  rat=NR  configuration_id=3
#    Assert Alarm Active  faultId=7513, severity=Major, faultName="EN DSS De-activated on partner side", alarmingResource=${nrcel_id}

# TEST SECTION

#    Setup Infomodel    port=443    use_ssl=True
#    Connect Infomodel    timeout=180
#
#    ${out_lcr_id_list}=    SCFC Create LcrId List    ${SCFC_REFERENCE_FILE_PATH}
#    ${out_lncel_id_list}=    SCFC Create LncelId List    ${SCFC_REFERENCE_FILE_PATH}
#    ${out_lncel_ids_dic}=    Info Model Get EarfcnDl And DlChBw Parameters For LNCEL List    ${out_lncel_id_list}    *
#    Log    \n\nCells (LNCEL) and their EarfcnDl and DlChBw: ${out_lncel_ids_dic}\n    console=yes

#    Teardown Infomodel

*** Keywords ***

Test setup
#    Set Library Search Order    ute_admin_infomodel    ute_admin
#    Set Library Search Order    taf.sbts.oam.coam.admin  ute_admin_infomodel
    Set Library Search Order  ute_admin_infomodel  admin
    admin.Setup admin  bts_host=${BTS_ADDRESS}  bts_port=${BTS_PORT}  use_ssl=${USE_SSL}  update_interval=100

Test Teardown
    admin.Teardown admin

#New keywords
