# *** Settings ***
# Suite Setup       5822 Coam Suite Setup
# Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
# Test Setup        CB005822 Case Setup
# Test Teardown     CB005822 Case Teardown
# Force Tags    RAN_5G   RAN_5G_TDD   STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_AQHA_AHPH_2xAHPF   SBTS00   CRT_UTE
# ...    PY39
# Library            OperatingSystem
# Library            Collections
# Library            BuiltIn
# Library            String
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB005822/Resources/CB005822_B_Common_Keywords.robot
# Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB005822/Resources/CB005822_Common_Keywords.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# 
# Documentation
# ...   author: yulu
# ...   contact: lu.1.yu@nokia-sbell.com
# ...   squad group: SG_02
# 
# 
# *** Variables ***
# ${puschreceiverRespHarqU_msg}      \"uldata_puschreceiverespharqu\"
# ${command_template_puschreceiverRespHarqU_msg}      {tshark_path} -r {pcap_file} -Y ${puschreceiverRespHarqU_msg} -T pdml
# 
# ${UL_THROUGHPUT}    100M
# ${DL_THROUGHPUT}    1400M
# ${UL_EXPECT_30M}    50
# ${DL_EXPECT_30M}    340
# 
# ${UL_EXPECT_ATTEN}    0.65
# ${DL_EXPECT_ATTEN}    90
# 
# 
# *** Test Cases ***
# [1]CB005822_B_15_AQHA_L3call_with_1118_ul256QAM
#     Clear the cache and reconnect
#     Check actUl256Qam Value on webEM
#     Run Keyword And Ignore Error    Restart CPE 5G19-A before start traffic    pc_index=${2}
#     Sleep    5min
#     Run Keyword And Ignore Error     UE Attach and collect biplog   throughput_ul=${UL_THROUGHPUT}
#     ...                           throughput_dl=${DL_THROUGHPUT}
#     ...                           target_throughput_ul=${UL_EXPECT_30M}
#     ...                           target_throughput_dl=${DL_EXPECT_30M}
#     Run Keyword And Ignore Error     Check bip log is QAM256
#     Run keyword and ignore error    ssh.Reset cache
# 
# [1]CB005822_C_01_AQHA_L3call_with_545_DFT-s-OFDM
#    Clear the cache and reconnect
#    COAM Update several parameters via rest api    parameters_to_update_via_api=${SET_ACTULDFTSOFDM_TRUE}    timeout=${600}
#    Run Keyword And Ignore Error    Restart CPE 5G19-A before start traffic    pc_index=${2}
#    Sleep    5min
#    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
#    Set test variable    ${ue_type}
#    ${Original_Value}    Get value from Attenuator    port_num=${4}
#    Set Test variable    ${Original_Value}
#    power_ue.Prepare UE      ue_type=${ue_type}
#    UE Attach and Start traffic for 5822
#    UE Check Tput and Curve for 5822    target_throughput_ul=${UL_EXPECT_30M}
#    ...                                 target_throughput_dl=${DL_EXPECT_30M}
#    Connect to Common Unit Master
#    Start Bip Logs Capture for 5822
#    Modidy Attenuator by step      target_value=${60}      port_num=${4}
#    UE Check Tput and Curve for 5822    target_throughput_ul=${UL_EXPECT_ATTEN}
#    ...                                 target_throughput_dl=${DL_EXPECT_ATTEN}
#    Modidy Attenuator by decrease steps      target_value=${Original_Value}      port_num=${4}
#    UE Check Tput and Curve for 5822    target_throughput_ul=${UL_EXPECT_30M}
#    ...                                 target_throughput_dl=${DL_EXPECT_30M}
#    UE Dettach and Stop traffic for 5822
#    Sleep    5s
#    ${bip_log_path}    Stop Bip Logs Capture and Download Logs for 5822      log_path=${OUTPUT_DIR}
#    ${packets}=      Load BIP with Luashark for 5822      bip_file=${bip_log_path}
#    ...      command_template=${command_template_puschreceiverRespHarqU_msg}
#    ...      alias=${None}
#    Run Keyword And Continue On Failure    Verify DTX and CRC in HarqU message      package=${packets}
#    COAM Update several parameters via rest api    parameters_to_update_via_api=${SET_ACTULDFTSOFDM_FALSE}    timeout=${600}
#    Run keyword and ignore error    ssh.Reset cache
# 
# [1]CB005822_B_08_AQHA_L3call_with_frame_1116_3ms_and_PRACH_format_0_structure
#     ${version}     get software version for 5822
#     Load Case SCF and Commission SCF for 5822       scf_file=commissionings/HGZ/7_5_UTE5G402T980/${version}_1116_3ms_NSA_SA.xml
#     Clear the cache and reconnect
#     Check Actual Value on webEM
#     Run Keyword And Ignore Error    Restart CPE 5G19-A before start traffic    pc_index=${2}
#     Sleep    5min
#     Run Keyword And Ignore Error     UE Attach and Start Traffic for Other   throughput_ul=${UL_THROUGHPUT}
#     ...                           throughput_dl=${DL_THROUGHPUT}
#     ...                           target_throughput_ul=${UL_EXPECT_30M}
#     ...                           target_throughput_dl=${DL_EXPECT_30M}
#     Run keyword and ignore error    ssh.Reset cache
