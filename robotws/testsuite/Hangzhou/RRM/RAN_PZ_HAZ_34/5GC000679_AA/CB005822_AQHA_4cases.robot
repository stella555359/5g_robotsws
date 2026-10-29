# *** Settings ***
# Suite Setup       5822 Coam Suite Setup
# Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
# Test Setup        CB005822 Case Setup
# Test Teardown     CB005822 Case Teardown
# Force Tags    RAN_5G   RAN_5G_TDD   STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_AQHA_AHPH_2xAHPF   SBTS00   CRT_UTE
# ...    PY36
# Library            OperatingSystem
# Library            Collections
# Library            BuiltIn
# Library            String
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000679_AA/Resources/CB005822_CXD_Common_Keywords.robot
# Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB005822/Resources/CB005822_Common_Keywords.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# 
# Documentation
# ...   author: chen xiaodong
# ...   contact: xiaodong.d.chen@nokia-sbell.com
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
# [1]CB005822_B_03_AQHA_L3call_with_dual_carrier_80M+80M_NSA
#     ${version}     get software version for 5822
#     Load Case SCF and Commission SCF for 5822       scf_file=commissionings/HGZ/7_5_UTE5G402T796/${version}_80M_80M_NSA.xml
#     UE Attach and Start Traffic   throughput_ul=${UL_THROUGHPUT_80M}
#     ...                           throughput_dl=${DL_THROUGHPUT_80M}
#     ...                           target_throughput_ul=${UL_EXPECT_80M}
#     ...                           target_throughput_dl=${DL_EXPECT_80M}
# 
# [1]CB005822_B_08_AQHA_L3call_with_frame_1116_3ms_and_PRACH_format_0_structure
#     ${version}     get software version for 5822
#     Load Case SCF and Commission SCF for 5822       scf_file=commissionings/HGZ/7_5_UTE5G402T796/${version}_1116_3ms_NSA_SA.xml
#     Clear the cache and reconnect
#     Check Actual Value on webEM
#     UE Attach and Start Traffic   throughput_ul=${UL_THROUGHPUT}
#     ...                           throughput_dl=${DL_THROUGHPUT}
#     ...                           target_throughput_ul=${UL_EXPECT_30M}
#     ...                           target_throughput_dl=${DL_EXPECT_30M}
#     Run keyword and ignore error    ssh.Reset cache
# 
# [1]CB005822_C_02_AQHA_L3call_with_1086_SRS_based_BM
#     ${version}     get software version for 5822
#     Load Case SCF and Commission SCF for 5822       scf_file=commissionings/HGZ/7_5_UTE5G402T796/${version}_1086_100M.xml
#     Clear the cache and reconnect
#     UE call and check ue attach log
#     Check L2L1 Bip log
#     Check CRPT file
#     Run keyword and ignore error    ssh.Reset cache
# 
# [1]CB005822_C_03_AQHA_L3call_with_8247_SRS_based_DL_beamforming
#     ${version}     get software version for 5822
#     Load Case SCF and Commission SCF for 5822       scf_file=commissionings/HGZ/7_5_UTE5G402T796/${version}_8247_100M.xml
#     Clear the cache and reconnect
#     UE Call and Check PDSCH by Bip log
#     Run keyword and ignore error    ssh.Reset cache
