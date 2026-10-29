*** Settings ***
Documentation    Suite description

Library     ./resources/CB008924_keywords.py
Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK4.CB008924.resources.cells_block_unblock.CellKeywords
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_BTS_Site_Reset.robot
Resource    ./resources/General_SiSo_Auto_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ./resources/Manual_SiSo_CM_Recommissioning.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/attenuation.py
Resource    ./resources/General_SiSo_E2E_system_setup_with_data_transfer.robot

Test Timeout  24 hours

Suite Setup         Common Suite Setup With Commissioning
Suite Teardown      Common Suite Teardown
Test Setup          Run Keyword And Ignore Error     Common Preconditions
Test Teardown       Run Keyword And Ignore Error     Common Postconditions

*** Variables ***
${RUs}   ${tl.gnbs[0].dus[0].rus}
@{mandatory_log_list}
...  BTS.*${RUs[0].serial_number}_RMOD_L.*startup  BTS.*${RUs[0].serial_number}_RMOD_L.*fault_history  BTS.*${RUs[0].serial_number}_RMOD_L.*SOAP
...  BTS.*${RUs[1].serial_number}_RMOD_L.*runtime  BTS.*${RUs[1].serial_number}_RMOD_L.*startup  BTS.*${RUs[1].serial_number}_RMOD_L.*fault_history
...  BTS.*${RUs[1].serial_number}_RMOD_L.*SOAP
...  BTS.*${RUs[2].serial_number}_RMOD_L.*runtime  BTS.*${RUs[2].serial_number}_RMOD_L.*startup  BTS.*${RUs[2].serial_number}_RMOD_L.*fault_history
...  BTS.*${RUs[2].serial_number}_RMOD_L.*SOAP
...  BTS.*${RUs[3].serial_number}_RMOD_L.*runtime  BTS.*${RUs[3].serial_number}_RMOD_L.*startup  BTS.*${RUs[3].serial_number}_RMOD_L.*fault_history
...  BTS.*${RUs[3].serial_number}_RMOD_L.*SOAP
...  BTS.*${RUs[4].serial_number}_RMOD_L.*runtime  BTS.*${RUs[4].serial_number}_RMOD_L.*startup  BTS.*${RUs[4].serial_number}_RMOD_L.*fault_history
...  BTS.*${RUs[4].serial_number}_RMOD_L.*SOAP

${duration}             120
${data_size_dl}         260M
${data_size_ul}         150M
${parallel_streams}     4
${protocol}             tcp
${deviation}            10%
${maximum_segment_size}  1200

*** Test Cases ***
CB008924-Manual_SiSo_SM_BTS_Site_Reset
    General_SiSo_Auto_BTS_Site_Reset

CB008924-General_SiSo_Cell_block_and_unblock
     Block Unblock All Cells

CB008924-General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    General SiSo Auto Collect RFSW logs from RU into BTS Snapshot  ${mandatory_log_list}

CB008924-Manual_SiSo_CM_Recommissioning
   Perform commissioning on gNB to onAir state
   set_cell_attenuation
   ...  attenuation_ports=${attenuator_ports}
   ...  values_in_db=${NR_2_attenuation_list}
   prepare_ue_network_type  5gsakrk  NR
   Manual SiSo CM Recommissioning    duration=${duration}        data_size_dl=${data_size_dl}    data_size_ul=${data_size_ul}
   ...                               parallel_streams=${parallel_streams}  protocol=${protocol}        deviation=${deviation}
   ...                               maximum_segment_size=${maximum_segment_size}

CB008924-General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    set_cell_attenuation
    ...  attenuation_ports=${attenuator_ports}
    ...  values_in_db=${GSM_attenuation_list}
    General_SiSo_E2E_system_setup_with_data_transfer
    ...  repeat_measurement_tput=${1}
    ...  duration=60        data_size_dl=20K              data_size_ul=25K
    ...  parallel_streams=1  capabilities=REAL_MEDIATEK_UE  protocol=tcp  deviation=20%
    ...  server_buffer_dl=15K   client_buffer_dl=15K
    ...  maximum_segment_size=${maximum_segment_size}  apn=5gkrk2  rat=GSM
    set_cell_attenuation
    ...  attenuation_ports=${attenuator_ports}
    ...  values_in_db=${WCDMA_attenuation_list}
    General_SiSo_E2E_system_setup_with_data_transfer
    ...  repeat_measurement_tput=${1}
    ...  duration=60        data_size_dl=200K              data_size_ul=200K
    ...  parallel_streams=2  capabilities=REAL_MEDIATEK_UE  protocol=tcp  deviation=10%
    ...  maximum_segment_size=${maximum_segment_size}  apn=5gkrk2  rat=WCDMA
    set_cell_attenuation
    ...  attenuation_ports=${attenuator_ports}
    ...  values_in_db=${LTE_305_attenuation_list}
    General_SiSo_E2E_system_setup_with_data_transfer
    ...  repeat_measurement_tput=${1}
    ...  duration=60        data_size_dl=35M              data_size_ul=10M
    ...  parallel_streams=4  capabilities=REAL_MEDIATEK_UE  protocol=tcp  deviation=10%
    ...  maximum_segment_size=${maximum_segment_size}  apn=5gkrk2  rat=LTE
    set_cell_attenuation
    ...  attenuation_ports=${attenuator_ports}
    ...  values_in_db=${NR_2_attenuation_list}
    General_SiSo_E2E_system_setup_with_data_transfer
    ...  repeat_measurement_tput=${1}
    ...  duration=60        data_size_dl=260M              data_size_ul=150M
    ...  parallel_streams=4  capabilities=REAL_MEDIATEK_UE  protocol=tcp  deviation=10%
    ...  apn=5gsakrk  rat=NR
