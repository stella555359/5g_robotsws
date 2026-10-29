*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_NLWG_10423_2ASIL_2ABIA_1ABIO_1ABIQ_1ABIN_1ABIP_2FXDB_1FRGU_1FRME_2FXED_3AHEGB  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG05/PM/PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG05/PM/PM__LTE_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG05/PM/PM__LTE_measurement_interval_change_from_longer_to_shorter.robot
Resource    ../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG05/PM/PM__TNL_measurement_interval_change_from_longer_to_shorter.robot
Resource    ../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG05/PM/PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list.robot
Resource    ../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG05/PM/PM__Reporting_interval_reconfiguration_to_longer_than_currently_used_30_min.robot
Resource    ../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG05/PM/PM__WCDMA_measurement_interval_change-counters_collection_disabling.robot
Resource    ../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG05/PM/PM__RP918_AVERAGE_VALUE_OF_VSWR_counter_M40001.robot


Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1423
${SKIP_RU_POWER_CHECK}    ${TRUE}
${COMMISSIONING_PATH}=  SEPARATOR=
    ...  /home/ute/testline_configuration/10_18_UTESRANCLOUD1423/node1/
    ...  BTS_CLOUD_SRAN_NLWG_10423_2ASIL_2ABIA_1ABIO_1ABIQ_1ABIN_1ABIP_2FXDB_1FRGU_1FRME_2FXED_3AHEGB_SBTS00.xml


${PM__WBTS_counters_MEASUREMENT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5051_Newton2/counters/
    ...  SBTS_WBTS19_selected_groups_0207.csv

${PM__WBTS_counters_ABBREVIATION_DICT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5051_Newton2/counters/
    ...  WCDMA_Abbreviations.csv

${PM__LTE_counter_MEASUREMENT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5007_Kopytko/counters/
    ...   SBTS19A__LTE_Counters_2019-07-01.csv

${PM__LTE_counter_ABBREVIATION_DICT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5007_Kopytko/counters/
    ...   LTE_Abbreviations.csv

${PM__TRS_counters_MEASUREMENT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5009_Rossi/counters/
    ...  TRS_NIDD_2019-03-28.csv

${PM__SBTS19A_counters_MEASUREMENT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5054_Curie2/counters/
    ...   SBTS19A_Counters_2019-07-01_limited.csv

${PM__LTE_counters_ABBREVIATION_DICT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5054_Curie2/counters/
    ...   LTE_Abbreviations.csv

${PM__TNL_counters_MEASUREMENT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5054_Curie2/counters/
    ...  TNL_NIDD_target_TRUNK.csv

${PM__WCDMA_counters_MEASUREMENT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5009_Rossi/counters/
    ...  WCDMA_FULL_NIDD_2019-03-12.csv


${PM__TNL_counters_ABBREVIATION_DICT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5054_Curie2/counters/
    ...  TNL_Abbreviations.csv

${PM__WBTS_M5015_counters_MEASUREMENT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5054_Curie2/counters/
    ...   WBTS_M5015_CountersWithoutMetaData_2020-08-07.csv

${PM__WCDMA_counters_ABBREVIATION_DICT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5054_Curie2/counters/
    ...   WCDMA_Abbreviations.csv

${PM__WBTS19_counters_MEASUREMENT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5054_Curie2/counters/
    ...   SBTS_WBTS19_selected_groups_0207.csv

${LTE_MEASUREMENT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5021_Libra/counters/
    ...  SBTS19A__LTE_Counters_2019-07-01.csv

${LTE_M804x_MEASUREMENT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5021_Libra/counters/M8046_M8047_M8048_2021-02-05.csv

${LTE_ABBREVIATION_DICT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5021_Libra/counters/LTE_Abbreviations.csv



*** Test Cases ***
[1]Automated__PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]     QC_768418
    [Setup]    Run Keywords    Set Test Variable    ${MEASUREMENT_PATH}    ${PM__TNL_counters_MEASUREMENT_PATH}
    ...    AND    Set Test Variable    ${ABBREVIATION_DICT_PATH}    ${PM__TNL_counters_ABBREVIATION_DICT_PATH}
    ...    AND    Set Test Variable    ${TO_FILTRATE_KEYS}    Product_types,Category,Document_state
    ...    AND    Set Test Variable    ${TO_FILTRATE_VALUES}    Flexi_SBTS|Flexi_AirScale,Customer,Published
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    ...    AND    PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Setup
    ...    AND    Modify Resource Search Order    PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    ...    AND    Set Library Search Order    PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Timeout]    14400
    TC__PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Teardown]    Run Keywords    PM__TNL_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Teardown
    ...    AND    Restore Resource Search Order



[1]Automated__PM__LTE_measurement_interval_change_from_longer_to_shorter
    [Tags]     QC_768416
    [Setup]    Run Keywords    Set Test Variable    ${PMRNL_PARAMETER_INTERVAL}    mtCellAvailability=15min,mtCellThruput=30min
    ...    AND    Set Test Variable    ${skip_parameter_relation_errors}    True
    ...    AND    PM__LTE_measurement_interval_change_from_longer_to_shorter.TC Setup
    ...    AND    Modify Resource Search Order    PM__LTE_measurement_interval_change_from_longer_to_shorter
    ...    AND    Set Library Search Order    PM__LTE_measurement_interval_change_from_longer_to_shorter
    [Timeout]    14400
    TC__PM__LTE_measurement_interval_change_from_longer_to_shorter
    [Teardown]    Run Keywords    PM__LTE_measurement_interval_change_from_longer_to_shorter.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Tags]     QC_768419
    [Setup]    Run Keywords    Set Test Variable    ${MEASUREMENT_PATH}    ${PM__WBTS19_counters_MEASUREMENT_PATH}
    ...    AND    Set Test Variable    ${ABBREVIATION_DICT_PATH}    ${PM__WCDMA_counters_ABBREVIATION_DICT_PATH}
    ...    AND    Set Test Variable    ${WCDMA_TRS_COUNTERS}    M51\\d{2}C\\d+
    ...    AND    Set Test Variable    ${TO_FILTRATE_KEYS}    Product_types,Category,Document_state
    ...    AND    Set Test Variable    ${TO_FILTRATE_VALUES}    Flexi_SBTS,Customer,Published
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    ...    AND    PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Setup
    ...    AND    Modify Resource Search Order    PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    ...    AND    Set Library Search Order    PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Timeout]    14400
    TC__PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list
    [Teardown]    Run Keywords    PM__WBTS_counters_are_available_on_ram_disk_versus_NIDD_counter_list.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__PM__WCDMA_measurement_interval_change-counters_collection_disabling
    [Tags]     QC_768420
    [Setup]    Run Keywords    Set Test Variable    @{WNPMRNL_DICTIONARY}
    ...    AND    Set Test Variable    ${WNPMRNL_PARAMETER}    mtFrameProtWBTS
    ...    AND    PM__WCDMA_measurement_interval_change-counters_collection_disabling.TC Setup
    ...    AND    Modify Resource Search Order    PM__WCDMA_measurement_interval_change-counters_collection_disabling
    ...    AND    Set Library Search Order    PM__WCDMA_measurement_interval_change-counters_collection_disabling
    [Timeout]    14400
    TC__PM__WCDMA_measurement_interval_change-counters_collection_disabling
    [Teardown]    Run Keywords    PM__WCDMA_measurement_interval_change-counters_collection_disabling.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...  cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a


