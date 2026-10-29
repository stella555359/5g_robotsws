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
# [1]CB005822_C_02_AQHA_L3call_with_1086_SRS_based_BM
#     ${version}     get software version for 5822
#     Load Case SCF and Commission SCF for 5822       scf_file=commissionings/HGZ/7_5_UTE5G402T980/${version}_1086_100M.xml
#     Clear the cache and reconnect
#     Run Keyword And Ignore Error    Restart CPE 5G19-A before start traffic    pc_index=${2}
#     Sleep    5min
#     Run Keyword And Ignore Error     UE call and check ue attach log
#     Run Keyword And Ignore Error     Check L2L1 Bip log
#     Run Keyword And Ignore Error     Check CRPT file
#     Run keyword and ignore error    ssh.Reset cache
# 
# [1]CB005822_C_03_AQHA_L3call_with_8247_SRS_based_DL_beamforming
#     ${version}     get software version for 5822
#     Load Case SCF and Commission SCF for 5822       scf_file=commissionings/HGZ/7_5_UTE5G402T980/${version}_8247_100M.xml
#     Clear the cache and reconnect
#     Run Keyword And Ignore Error    Restart CPE 5G19-A before start traffic    pc_index=${2}
#     Sleep    5min
#     Run Keyword And Ignore Error     UE Call and Check PDSCH by Bip log
#     Run keyword and ignore error    ssh.Reset cache
