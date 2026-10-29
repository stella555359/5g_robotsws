*** Settings ***
Documentation
...   author: Rafal Kawa
...   contact: rafal.kawa@nokia.com
...   description: Test suite covers basic functionalities of Feature CB008072

Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library     testsuite/Krakow/RRM/RAN_PZ/features/FRCB008072/resources/PuschKeywords.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Test Timeout  24 hours

Suite Setup       Run Keywords
...               enter_home_button
...               AND  fade_attenuator  ${port_id}  ${port_id2}  start_value=1  end_value=${attenuation_min}
...               interval=1000
...               AND  Common Suite Setup With Commissioning    prefix_tag=SA
...               AND  prepare_ue_for_5g_attach  mode_5g=SA  subnet=${subnet_sa}
...               AND  Set Suite Variables
Suite Teardown    Run Keywords
...               logout_from_licence_keeper
...               AND  Common Suite Teardown

Test Setup        Run Keywords
...               Common Preconditions
...               AND  fade_attenuator  ${port_id}  ${port_id2}  start_value=1  end_value=${attenuation_min}
...               interval=1000
...               AND  clear_uepc_log_dir
...               AND  get_qcat_licence
Test Teardown     Run Keywords
...               enter_home_button
...               AND  Run Keyword And Ignore Error     release_qcat_licence
...               AND  Verify NRCell and Alarms
...               AND  Common Postconditions

*** Variables ***
#UE params:
${chipset_ue}            sdx60
${subnet_sa}             10.83.241
#Throughput params:
${DL_256QAM}             188 Mbits/sec
${UL_256QAM}             110 Mbits/sec
${UL_64QAM}              82 Mbits/sec
${max_bler}              10
${deviation}             5%
${tput_time}             120
${log_collecting_time}   100
${tput_warm-up_time}     22
#Attenuator params:
#Port identifiers
${port_id}               3
${port_id2}              4
#Fade settings
${attenuation_max}       61
${attenuation_min}       20
${at_interval}           1500

*** Test Cases ***
CB008072_AB_2_Activation_and_deactivation_for_PUSCH_mapping_type_A_SA
    Verify NRCell and Alarms
    Perform delta commissioning  curdir_path=${CURDIR}  test_tag=AB_2
    Verify NRCell and Alarms
    ue.Require Ue    UE    capabilities=REAL_UE
    ue.Reboot UE     UE    60
    ue.Attach Ue     UE
    start_udp_bidir_data_transfer  duration=${tput_time}s  dl_tput=${DL_256QAM}  ul_tput=${UL_64QAM}
    collect_qxdm_log  duration=${log_collecting_time}  dmc_name=qtraces  log_name=AB2
    Check Data Transfer
    Wait for Data Transfer Finish
    ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DL_256QAM}   deviation=${deviation}
    ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${UL_64QAM}   deviation=${deviation}
    convert_qxdm_log_and_upload_it_to_proxy_pc
    verify_bler_based_on_qtraces  max_allowed_bler=${max_bler}  chipset_version=${chipset_ue}  remove_logs=${True}
    ${UL_typeA} =  get_average_tput_values  dt_name=DT_UL
    ${DL_typeA} =  get_average_tput_values  dt_name=DT_DL
    perform delta commissioning  curdir_path=${CURDIR}  test_tag=puschMappingTypeB
    Verify NRCell and Alarms
    ue.Reboot UE     UE    60
    ue.Attach Ue     UE
    start_udp_bidir_data_transfer  duration=${tput_time}s  dl_tput=${DL_256QAM}  ul_tput=${UL_64QAM}
    ...  dt_name_dl=DT_DL2  dt_name_ul=DT_UL2
    collect_qxdm_log  duration=${log_collecting_time}  dmc_name=qtraces  log_name=AB2_step2
    Check Data Transfer  dt_name_dl=DT_DL2  dt_name_ul=DT_UL2
    Wait for Data Transfer Finish  dt_name_dl=DT_DL2  dt_name_ul=DT_UL2
    ue.Verify Average Throughput With Deviation   dt_name=DT_DL2   tput=${DL_256QAM}   deviation=${deviation}
    ue.Verify Average Throughput With Deviation   dt_name=DT_UL2   tput=${UL_64QAM}   deviation=${deviation}
    convert_qxdm_log_and_upload_it_to_proxy_pc
    verify_bler_based_on_qtraces  max_allowed_bler=${max_bler}  chipset_version=${chipset_ue}  remove_logs=${True}
    ${UL_typeB} =  get_average_tput_values  dt_name=DT_UL2
    ${DL_typeB} =  get_average_tput_values  dt_name=DT_DL2
    compare average throughput  ${UL_typeA}  ${UL_typeB}  UL
    compare average throughput  ${DL_typeA}  ${DL_typeB}  DL
    verify_product_variant_planned

CB008072_AB_9
    Verify NRCell and Alarms
    Perform delta commissioning  curdir_path=${CURDIR}  test_tag=AB_9
    Verify NRCell and Alarms
    ue.Require Ue    UE    capabilities=REAL_UE
    ue.Reboot UE     UE    60
    ue.Attach Ue     UE
    start_udp_bidir_data_transfer  duration=${at_tput_time}s  dl_tput=${DL_256QAM}  ul_tput=${UL_64QAM}
    Check Data Transfer
    simulate_mobility_of_ue  ${port_id}  ${port_id2}  ${attenuation_min}  ${attenuation_max}  ${at_interval}  ${at_time}
    Wait for Data Transfer Finish
    ${UL_typeA} =  get_average_tput_values  dt_name=DT_UL
    ${DL_typeA} =  get_average_tput_values  dt_name=DT_DL
    Perform delta commissioning  curdir_path=${CURDIR}  test_tag=puschMappingTypeB
    Verify NRCell and Alarms
    ue.Reboot UE     UE    60
    ue.Attach Ue     UE
    start_udp_bidir_data_transfer  duration=${at_tput_time}s  dl_tput=${DL_256QAM}  ul_tput=${UL_64QAM}
    ...  dt_name_dl=DT_DL2  dt_name_ul=DT_UL2
    Check Data Transfer  dt_name_dl=DT_DL2  dt_name_ul=DT_UL2
    simulate_mobility_of_ue  ${port_id}  ${port_id2}  ${attenuation_min}  ${attenuation_max}  ${at_interval}  ${at_time}
    Wait for Data Transfer Finish  dt_name_dl=DT_DL2  dt_name_ul=DT_UL2
    ${UL_typeB} =  get_average_tput_values  dt_name=DT_UL2
    ${DL_typeB} =  get_average_tput_values  dt_name=DT_DL2
    compare average throughput  ${UL_typeA}  ${UL_typeB}  UL
    compare average throughput  ${DL_typeA}  ${DL_typeB}  DL

CB008072_A_IWK1_20
    Verify NRCell and Alarms
    Perform delta commissioning  curdir_path=${CURDIR}  test_tag=A_IWK1_20
    Verify NRCell and Alarms
    ue.Require Ue    UE    capabilities=REAL_UE
    ue.Reboot UE     UE    60
    ue.Attach Ue     UE
    start_udp_bidir_data_transfer  duration=${at_tput_time}s  dl_tput=${DL_256QAM}  ul_tput=${UL_256QAM}
    collect_qxdm_log  duration=${at_log_collecting_time}  dmc_name=nr5g_rrc  log_name=A_IWK1_20
    Check Data Transfer
    simulate_mobility_of_ue  ${port_id}  ${port_id2}  ${attenuation_min}  ${attenuation_max}  ${at_interval}  ${at_time}
    Wait for Data Transfer Finish
    convert_qxdm_log_and_upload_it_to_proxy_pc
    verify_rrc_msg  mode_5g=SA
    ${UL_typeA} =  get_average_tput_values  dt_name=DT_UL
    ${DL_typeA} =  get_average_tput_values  dt_name=DT_DL
    perform delta commissioning  curdir_path=${CURDIR}  test_tag=puschMappingTypeB
    Verify NRCell and Alarms
    ue.Reboot UE     UE    60
    ue.Attach Ue     UE
    start_udp_bidir_data_transfer  duration=${at_tput_time}s  dl_tput=${DL_256QAM}  ul_tput=${UL_256QAM}
    ...  dt_name_dl=DT_DL2  dt_name_ul=DT_UL2
    collect_qxdm_log  duration=${at_log_collecting_time}  dmc_name=nr5g_rrc  log_name=A_IWK1_20_step2
    Check Data Transfer  dt_name_dl=DT_DL2  dt_name_ul=DT_UL2
    simulate_mobility_of_ue  ${port_id}  ${port_id2}  ${attenuation_min}  ${attenuation_max}  ${at_interval}  ${at_time}
    Wait for Data Transfer Finish  dt_name_dl=DT_DL2  dt_name_ul=DT_UL2
    convert_qxdm_log_and_upload_it_to_proxy_pc
    verify_rrc_msg  mode_5g=SA
    ${UL_typeB} =  get_average_tput_values  dt_name=DT_UL2
    ${DL_typeB} =  get_average_tput_values  dt_name=DT_DL2
    compare average throughput  ${UL_typeA}  ${UL_typeB}  UL
    compare average throughput  ${DL_typeA}  ${DL_typeB}  DL

CB008072_A_IWK1_22
    Verify NRCell and Alarms
    Perform delta commissioning  curdir_path=${CURDIR}  test_tag=A_IWK1_22
    Verify NRCell and Alarms
    ue.Require Ue    UE    capabilities=REAL_UE
    ue.Reboot UE     UE    60
    ue.Attach Ue     UE
    start_udp_bidir_data_transfer  duration=${at_tput_time}s  dl_tput=${DL_256QAM}  ul_tput=${UL_256QAM}
    collect_qxdm_log  duration=${at_log_collecting_time}  dmc_name=nr5g_rrc  log_name=A_IWK1_22
    Check Data Transfer
    simulate_mobility_of_ue  ${port_id}  ${port_id2}  ${attenuation_min}  ${attenuation_max}  ${at_interval}  ${at_time}
    Wait for Data Transfer Finish
    convert_qxdm_log_and_upload_it_to_proxy_pc
    verify_rrc_msg  mode_5g=SA
    ${UL_typeA} =  get_average_tput_values  dt_name=DT_UL
    ${DL_typeA} =  get_average_tput_values  dt_name=DT_DL
    perform delta commissioning  curdir_path=${CURDIR}  test_tag=puschMappingTypeB
    Verify NRCell and Alarms
    ue.Reboot UE     UE    60
    ue.Attach Ue     UE
    start_udp_bidir_data_transfer  duration=${at_tput_time}s  dl_tput=${DL_256QAM}  ul_tput=${UL_256QAM}
    ...  dt_name_dl=DT_DL2  dt_name_ul=DT_UL2
    collect_qxdm_log  duration=${at_log_collecting_time}  dmc_name=nr5g_rrc  log_name=A_IWK1_22_step2
    Check Data Transfer  dt_name_dl=DT_DL2  dt_name_ul=DT_UL2
    simulate_mobility_of_ue  ${port_id}  ${port_id2}  ${attenuation_min}  ${attenuation_max}  ${at_interval}  ${at_time}
    Wait for Data Transfer Finish  dt_name_dl=DT_DL2  dt_name_ul=DT_UL2
    convert_qxdm_log_and_upload_it_to_proxy_pc
    verify_rrc_msg  mode_5g=SA
    ${UL_typeB} =  get_average_tput_values  dt_name=DT_UL2
    ${DL_typeB} =  get_average_tput_values  dt_name=DT_DL2
    compare average throughput  ${UL_typeA}  ${UL_typeB}  UL
    compare average throughput  ${DL_typeA}  ${DL_typeB}  DL

*** Keywords ***
Verify NRCell and Alarms
    verify_nr_cell_setup  cell_id=18002
    Verify gNB is onAir
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}

Check Data Transfer
    [Arguments]    ${dt_name_dl}=DT_DL  ${dt_name_ul}=DT_UL
    ue.Check Data Transfer is Alive     dt_name=${dt_name_dl}
    ue.Check Data Transfer is Alive     dt_name=${dt_name_ul}

Wait for Data Transfer Finish
    [Arguments]    ${dt_name_dl}=DT_DL  ${dt_name_ul}=DT_UL
    ue.Await Data Transfer Finish       dt_name=${dt_name_dl}
    ue.Await Data Transfer Finish       dt_name=${dt_name_ul}

Set Suite Variables
    ${at_time} =  Evaluate  (${attenuation_max} - ${attenuation_min}) * (${at_interval} / ${1000})
    ${at_tput_time} =  Evaluate  (${at_time} * ${2} + ${tput_warm-up_time})
    ${at_tput_time} =  Convert To Integer  ${at_tput_time}
    ${at_log_collecting_time} =  Evaluate  (${at_tput_time} - ${tput_warm-up_time})
    Set Global Variable  ${at_time}
    Set Global Variable  ${at_tput_time}
    Set Global Variable  ${at_log_collecting_time}
