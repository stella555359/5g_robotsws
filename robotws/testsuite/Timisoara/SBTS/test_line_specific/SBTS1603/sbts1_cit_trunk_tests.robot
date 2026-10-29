*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_LW_1ASIB_2ABIA_ABIN_3AHEGB_3AHPMDA_3AHHB  STATE_COMMISSIONED
Library           XML  use_lxml=True
Suite Setup      Set Library Search Order  ute_admin   taf.gnb.oam.coam.admin
Resource    ../../CIT/test_resources/CM_CABLE_SPEED_CHANGE.robot
Resource    ../../CIT/test_resources/CM_Cell_Addition_LTE.robot
Resource    ../../CIT/test_resources/CM_Cell_Removal_LTE.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Configuration_reset.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Planned_commissioning.robot
Resource    ../../CIT/test_resources/CM__Recommissioning_delta_commissioning_with_reset.robot
Resource    ../../CIT/test_resources/CM__Recommissioning_delta_commissioning_without_reset.robot
Resource    ../../FM/test_resources/FM__RF_hot_remove_hot_insert.robot
Resource    ../../FM/test_resources/FM__Recovery_whole_multiple_Link_Break.robot
Resource    ../../CIT/test_resources/LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.robot
Resource    ../../CIT/test_resources/LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.robot
Resource    ../../CIT/test_resources/LOGS__Snapshot.robot
Resource    ../../CIT/test_resources/PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../CIT/test_resources/PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../CIT/test_resources/PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../CIT/test_resources/STATE__GSM_BCF_lock_unlock_from_BSC.robot
Resource    ../../CIT/test_resources/STATE__GSM_BCF_reset_from_BSC.robot
Resource    ../../CIT/test_resources/STATE__GSM_BTS_lock_unlock_from_BSC.robot
Resource    ../../CIT/test_resources/STATE__GSM_TRX_block_unblock_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__GSM_TRX_lock_unlock_from_BSC.robot
Resource    ../../CIT/test_resources/STATE__LTE_RAT_reset__parameter_change__ADMIN.robot
Resource    ../../CIT/test_resources/STATE__LTE_RAT_reset_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__LTE_S1_Lock_Unlock.robot
Resource    ../../CIT/test_resources/STATE__LTE_cell_block_unblock_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__LTE_cell_lock_unlock_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__Radio_module_reset_from_admin.robot
Resource    ../../CIT/test_resources/STATE__S1_lock_reset_unlock.robot
Resource    ../../CIT/test_resources/STATE__Site_power_reset.robot
Resource    ../../CIT/test_resources/STATE__Site_reset.robot
Resource    ../../CIT/test_resources/STATE__WCDMA_RAT_reset__parameter_change__ADMIN.robot
Resource    ../../CIT/test_resources/STATE__WCDMA_RAT_reset_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__WCDMA_cell_block_unblock.robot
Resource    ../../CIT/test_resources/STATE__WCDMA_cell_lock_unlock_from_RNC.robot
Resource    ../../CIT/test_resources/STATE__sbts_block_unblock.robot
Resource    ../../CIT/test_resources/SWM__Local_Software_Activation.robot
Resource    ../../CIT/test_resources/SWM__Local_Software_Download.robot
Resource    ../../CIT/test_resources/SWM__Local_Software_Download_Cancel.robot
Resource    ../../CIT/test_resources/SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
Resource    ../../CIT/test_resources/SWM__SCF_validation_errors_check.robot
Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../CIT/test_resources/SWM__SW_update_for_RMOD_with_fault_23.robot
Resource    ../../CIT/test_resources/SWM__Upload_swconfig.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211130_000009

*** Test Cases ***

[1]Automated__SWM__Local_Software_Download
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T1
    ...    AND    Set Test Variable    ${SW Download Timeout}    3600
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}       
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    SWM__Local_Software_Download.TC Setup
    ...    AND    Modify Resource Search Order    SWM__Local_Software_Download
	#[Tags]    STOPONFAIL
	${command}  Catenate  cat ../testline_init_results/node1/logs/INFO_log.txt | grep BTSSM-based | tail -1 |
    ...  awk -F 'from ' '{print $2}' | awk -F '.zip' '{print $1}'
    ${package}=  Run Keyword If  ${SMOD2_exists}
    ...  run   ${command}
    ...  ELSE   run
	...  cat ../testline_init_results/logs/INFO_log.txt | grep BTSSM-based | tail -1 | awk -F 'from ' '{print $2}' | awk -F '.zip' '{print $1}'
    Log to console  Download SW packages ${package}_testpackage_T1.zip
    run  mkdir ${Target SW dir}
    run  sudo chmod 777 ${Target SW dir} -R
    # run  wget ${package}_testpackage_T1.zip -P ${Target SW dir}
    run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable_testpackage_T1.zip -P ${Target SW dir}
    # Run Keyword If  ${SMOD2_exists}  run
#    ...  ssh ute@${PC_IP2} "mkdir ${Target SW dir}; sudo chmod 777 ${Target SW dir} -R; wget ${package}_testpackage_T1.zip -P ${Target SW dir}"
    [Timeout]    45 minutes
    TC__SWM__Local_Software_Download
    [Teardown]    Run Keywords    SWM__Local_Software_Download.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__SWM__Local_Software_Activation
    [Timeout]    ${Test_Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T1
    ...    AND    Set Test Variable    ${SW Activation Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    420
    ...    AND    Set Test Variable    ${Ping regain timeout}    600
    ...    AND    Set Test Variable    ${BTS_OnAir_Timeout}    15
    ...    AND    Set Test Variable    ${Test_Timeout}    30
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}       
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    SWM__Local_Software_Activation.TC Setup
    ...    AND    Modify Resource Search Order    SWM__Local_Software_Activation
	
    TC__SWM__Local_Software_Activation
    [Teardown]    Run Keywords    SWM__Local_Software_Activation.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__SWM__SW_update_for_RMOD_with_fault_23
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    240
    ...    AND    Set Test Variable    ${Ping regain timeout}    600
    ...    AND    Set Test Variable    ${Test Timeout}    90
    ...    AND    Set Test Variable    ${EXPECTED_BTS_STATUS}    OnAir
    ...    AND    Set Test Variable    ${onAir Check Number}    60
    ...    AND    Set Test Variable    ${RM_DETECTION_TIMEOUT}    15 min
    ...    AND    Set Test Variable    ${NUMBER_OF_RMODS_TO_TURN_OFF}    1
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}       
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    SWM__SW_update_for_RMOD_with_fault_23.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SW_update_for_RMOD_with_fault_23
#    ${command}  Catenate  cat ../testline_init_results/node1/logs/INFO_log.txt | grep BTSSM-based | tail -1 |
#    ...  awk -F 'from ' '{print $2}' | awk -F '.zip' '{print $1}'
#    ${package}=  Run Keyword If  ${SMOD2_exists}
#    ...  run   ${command}
#    ...  ELSE   run
#    ...  cat ../testline_init_results/logs/INFO_log.txt | grep BTSSM-based | tail -1 | awk -F 'from ' '{print $2}' | awk -F '.zip' '{print $1}'
#    Log to console  Download SW packages ${package}.zip
    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
#    Run  wget ${package}.zip -P ${Target SW dir}
    Run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable.zip -P ${Target SW dir}
    [Timeout]    60 minutes
    TC__SWM__SW_update_for_RMOD_with_fault_23
    [Teardown]    Run Keywords    SWM__SW_update_for_RMOD_with_fault_23.TC Teardown
    ...    AND    Restore Resource Search Order



[1]Automated__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MEASUREMENT_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1603/counters/SBTS19A_Counters_2019-07-01_limited.xlsx
    ...    AND    Set Test Variable    ${ABBREVIATION_DICT_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1603/counters/LTE_Abbreviations.xlsx
    ...    AND    Set Test Variable    ${TO_FILTRATE_KEYS}    Product_types,Category,Document_state
    ...    AND    Set Test Variable    ${TO_FILTRATE_VALUES}    Flexi_SBTS|Flexi_AirScale,Customer,Published
	...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}       
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Setup
    ...    AND    Modify Resource Search Order    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    TC__PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Teardown]    Run Keywords    PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MEASUREMENT_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1603/counters/TRS_few_groups.xlsm
    ...    AND    Set Test Variable    ${ABBREVIATION_DICT_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1603/counters/TNL_Abbreviations.xlsx
    ...    AND    Set Test Variable    ${TO_FILTRATE_KEYS}    Product_types,Category,Document_state
    ...    AND    Set Test Variable    ${TO_FILTRATE_VALUES}    Flexi_SBTS|Flexi_AirScale,Customer,Published
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}       
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Setup
    ...    AND    Modify Resource Search Order    PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    TC__PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Teardown]    Run Keywords    PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MEASUREMENT_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1603/counters/WCDMA_few_groups.xlsm
    ...    AND    Set Test Variable    ${ABBREVIATION_DICT_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1603/counters/WCDMA_Abbreviations.xlsx
    ...    AND    Set Test Variable    ${WCDMA_TRS_COUNTERS}    M51\\d{2}C\\d+
    ...    AND    Set Test Variable    ${TO_FILTRATE_KEYS}    Product_types,Category,Document_state
    ...    AND    Set Test Variable    ${TO_FILTRATE_VALUES}    Flexi_SBTS|Flexi_AirScale,Customer,Published
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}       
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Setup
    ...    AND    Modify Resource Search Order    PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    TC__PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Teardown]    Run Keywords    PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
#    [Tags]    STOPONFAIL    
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PASSIVE_SW_STATE}    commissioned
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${CONNECTION_RESET_ON_DEMAND}    ${FALSE}
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    600
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}       
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    TC__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Teardown]    Run Keywords    SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__SWM__Local_Software_Download_Cancel
    [Timeout]    14400
   [Setup]    Run Keywords    Set Test Variable    ${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1603/commissioning/SCF_01_TRUNK.xml
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW_T2
    ...    AND    Set Test Variable    ${SLEEP_BEFORE_CANCEL}    90
    ...    AND    Set Test Variable    ${DOWNLOAD_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RM_DETECTION_TIMEOUT}    15 min
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}       
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    
    ...    AND    SWM__Local_Software_Download_Cancel.TC Setup
    ...    AND    Modify Resource Search Order    SWM__Local_Software_Download_Cancel
#	${package}=  Run Keyword If  ${SMOD2_exists}  run
#    ...  cat ../testline_init_results/node1/logs/INFO_log.txt | grep BTSSM-based | tail -1 | awk -F 'from ' '{print $2}'
#	...  ELSE   run  cat ../testline_init_results/logs/INFO_log.txt | grep BTSSM-based | tail -1 | awk -F 'from ' '{print $2}'
#    Log to console  Download SW packages ${package}
    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
#    Run  wget ${package} -P ${Target SW dir}
    Run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable_testpackage_T2.zip -P ${Target SW dir}
    [Timeout]    45 minutes
    TC__SWM__Local_Software_Download_Cancel
    [Teardown]    Run Keywords    SWM__Local_Software_Download_Cancel.TC Teardown
    ...    AND    Restore Resource Search Order
