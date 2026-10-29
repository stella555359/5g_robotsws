*** Settings ***
Documentation  Test file
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    XML    use_lxml=true
Library    OperatingSystem
Library    BuiltIn
Library    Process
Library    String
Library    ute_wtssim
#Library    ute_syslog
Library    ute_fsmaccess
Library    ute_tshark
Library    ute_admin_infomodel
Library    taf.sbts.oam.coam.admin   WITH NAME   admin
Library    taf.hw.pdu

Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot

Resource    ../../resources/common_keywords.robot
Resource    ./variables.robot

*** Variables ***
${SCFC_FILE_PATH}=                  ${CURDIR}/config/SCFC.xml
${SCFC_FILE_PATH_1}=                ${CURDIR}/config/SCFC_1.xml
${CUSINI_FILE_PATH}=                ${CURDIR}/config/cus.ini
${CUSINI_FILE_PATH_1}=              ${CURDIR}/config/cus_1.ini
${EPCSIM_FILE_PATH}=                ${CONFIG_DIR}/epc.lua
${CONFIGURATION_NAME}=              TEST
@{LCR_ID_CELL_BLOCK_LIST}=          ALL
${BASIC_CALL}=                      True
#${RAT_IMPACT}=                      True

*** Test Cases ***
Test100
    Set Message Colors
    Set Log Prefix
    ${log_to_console}=  Set Variable  True

    ${cfg}=  Create Dictionary
    ${local_host_parameters}=  Get Host Parameters From Init File  host_index=1
    ${remote_host_parameters}=  Get Host Parameters From Init File  host_index=2
    Set To Dictionary  dictionary=${cfg}  tl_local_host=${local_host_parameters['ip_addr']}  tl_remote_host=${remote_host_parameters['ip_addr']}
    Log  ${info_prefix}Local host IP address: ${local_host_parameters['ip_addr']}  console=${log_to_console}
    Log  ${info_prefix}Remote host IP address: ${remote_host_parameters['ip_addr']}  console=${log_to_console}

#    Log  ${tl}   console=True

#    ${scfc_file_path}=  Set Variable  ${SCFC_FILE_PATH}
#    ${cus_file_path}=  Set Variable  ${CUSINI_FILE_PATH}
#
#    ${scfc_rmods_sn_list}=  SCFC Get Radio Modules Serial Numbers  scfc_file_path=${scfc_file_path}
#    Log  \nAll serial numbers:\n${scfc_rmods_sn_list}\n  console=True
#
#    ${ctrls_list}=  CUS Get Section Names List  cusini_file_path=${cus_file_path}  section=ctrl
#    ${cus_rmods_sn_list}=  CUS Create Rmods Serial Number List
#    ...  cusini_file_path=${cus_file_path}  ctrls_list=${ctrls_list}
#    Should Not Be Empty  item=${cus_rmods_sn_list}
#    Log  \nCUS serial numbers:\n${cus_rmods_sn_list}\n  console=True
#
#    Remove Values From List  ${scfc_rmods_sn_list}  @{cus_rmods_sn_list}
#    Log  \nRH serial numbers:\n${scfc_rmods_sn_list}\n  console=True
#
#    ${all_rmods_sn_list}=  Combine Lists  ${cus_rmods_sn_list}  ${scfc_rmods_sn_list}
#    Log  \nAll serial numbers:\n${all_rmods_sn_list}\n  console=True
#
#    ${rmods_count}=  Get Length  item=${all_rmods_sn_list}
#    Log  \nAll serial numbers count: ${rmods_count}\n  console=True
#    ${rmod_number}=  Evaluate  0

#    ${scfc_file_path}=  Set Variable  ${SCFC_FILE_PATH}
#    BTS SCFC And Admin Cells Count Should Match   scfc_file_path=${scfc_file_path}
#    ${scfc_file_path}=  Set Variable  ${SCFC_FILE_PATH_1}
#    BTS SCFC And Admin Cells Count Should Match   scfc_file_path=${scfc_file_path}

#    Import Resource  path=/home/ute/cusbranch/robotws/testsuite/Wroclaw/SISO/SRAN/resources/lte_rat_reset.robot
#    Import Resource  ${CURDIR}/../../../resources/lte_rat_reset.robot

#    ${lcr_id_list}=  SCFC Create LcrId List  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    Log  \nlcr_id_list: ${lcr_id_list}\n  console=True
#    ${mplane_only_sector_numbers_list}=  CUS Get Mplane Only Sector List  cusini_file_path=${CUSINI_FILE_PATH}
#    Log  \n${mplane_only_sector_numbers_list}\n  console=True
#    Remove Values From List  ${lcr_id_list}  @{mplane_only_sector_numbers_list}
#    Log  \n${lcr_id_list}\n  console=True


#    ${scfc_file_path}=  Set Variable  ${SCFC_FILE_PATH_1}
#    ${nrcell_id_list}=  SCFC Create Nrcell Id List  ${scfc_file_path}
#    Log  \nNr id list: ${nrcell_id_list}\n  console=True

#    ${scfc_file_path}=  Set Variable  ${SCFC_FILE_PATH_1}
#    ${lcr_id}=  Set Variable  11
#    ${nrcell_id}=  SCFC Get NrcellId For eNB LcrId After Dss Sharing Activation  ${scfc_file_path}  ${lcr_id}
#    Log  \nNrcell id: ${nrcell_id}\n  console=True
#
#    ${scfc_file_path}=  Set Variable  ${SCFC_REFERENCE_FILE_PATH}
#    ${lcr_id}=  Set Variable  11
#    ${nrcell_id}=  SCFC Get NrcellId For eNB LcrId After Dss Sharing Activation  ${scfc_file_path}  ${lcr_id}
#    Log  \nNrcell id: ${nrcell_id}\n  console=True
#    Run Keyword If  '${nrcell_id}'=='${EMPTY}'
#    ...  Log  \nNrcell id: EMPTY\n  console=True

#    Set Update Type  SBTS23R2_ENB_0000_001395_000000  SBTS00_ENB_9999_231023_000005
#
#    Get Firmware Version  before_update
#    Log  \n${info_prefix}Firmware versions before software update:  console=True
#    ${firmware_version}=  Convert To String  ${FIRMWARE_BEFORE_UPDATE}
#    ${firmware_version}=  Remove String  ${firmware_version}  {  }
##    Log  ${info_prefix}${firmware_version}  console=True
#    Log  ${below_info_prefix}${firmware_version}  console=True
#    Log  \n  console=True

#    ${downgrade_uboot}=  Downgrade Uboot
#    FOR  ${index}  IN RANGE  1
#      Log  \nIndex: ${index}  console=True
#      Log  \nDowngrade Uboot: ${downgrade_uboot}  console=True
#      Exit For Loop If  '${downgrade_uboot}' == 'False'
#      Log  \nDowngrade Uboot: ${downgrade_uboot}  console=True
#    END
#
#    Get Firmware Version  after_update
#    Log  \n${info_prefix}Firmware versions after software update:  console=True
#    ${firmware_version}=  Convert To String  ${FIRMWARE_AFTER_UPDATE}
#    ${firmware_version}=  Remove String  ${firmware_version}  {  }
#    Log  ${info_prefix}${firmware_version}  console=True
#    Log  \n  console=True

#Test 1
#    ${tl_show}=    Set Variable    ${tl}
#    Log    \nPDU ENB parameters: ${tl_show}    console=True

# taf.pdu
#    ${pdu_parameters_list}=    Get Enb Pdu Parameters    1
#    Log    \nPDU ENB parameters list:\n ${pdu_parameters_list}    console=True
#    ${taf_pdu}=    Set Variable    ${tl.enbs[0].system_module.common_units[0].pdu_port.pdu}
#    Log    \nTAF PDU parameters: ${taf_pdu}    console=True
#    ${setup_result}=    Setup PDU    ${taf_pdu}
#    Log    \nSetup PDU result: ${setup_result}    console=True
#    ${port_status}=    Get Port Status     port=${pdu_parameters_list[2]}
#    Log    \nPort Pdu: ${pdu_parameters_list[2]}, Port status: ${port_status}\n    console=True

# ute_pdu to taf.pdu
#    ${pdu_parameters_list}=    Get Enb Pdu Parameters    1
#    Log    \nPDU ENB parameters list:\n ${pdu_parameters_list}    console=True
#    Log    \nUTE PDU parameters: ${tl.fsm[1].pdu}    console=True
#    ${taf_pdu}=    taf_pdu_from_ute_config_pdu    ${tl.fsm[1].pdu}
#    Log    \nConverted UTE PDU parameters:\n ${taf_pdu}    console=True
#    ${setup_result}=    Setup PDU    ${taf_pdu}
#    Log    \nSetup PDU result:\n ${setup_result}    console=True
#    ${port_status}=    Get Port Status     port=${pdu_parameters_list[2]}
#    Log    \nPort Pdu: ${pdu_parameters_list[2]}, Port status: ${port_status}\n    console=True

