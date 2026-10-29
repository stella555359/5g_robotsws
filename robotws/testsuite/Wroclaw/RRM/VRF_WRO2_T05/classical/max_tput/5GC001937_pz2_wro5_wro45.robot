*** Settings ***
Documentation  Test suite for reporting of max TCP and UDP data throughputs to Reporting Portal as KPIs.
Library         ute_ue
Library    taf.sw.reporting_portal
Library    taf.rfrl.common_resources.python.report_to_rep
Library    ../../../resources/attenuator_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/max_tput/resources/counters_kw.py
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/max_tput/resources/kyewords_maxtput.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot

Force Tags      CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  RAN_5G_FDD_CD  RAN_5G_FDD_MP_CUSTOMER  RAN_5G_MP  CDRT  SBTS22R4
...             RAN_5GSC_CRT    CLOUD_5G_CLASSICAL_ASIK_ABIL_FULLRACK_TMO_5   SBTS00   SBTS22R3   PY36  STATE_SW_UPLOADED

Suite Setup     Run keywords
...             Connect to Coam    AND
...             Prepare and check TL   AND
...             Disconnect coam    AND
...             Reserve UE SA   AND
#...             Run Change Mode Script   ue_mode=SA   AND
...             logs.Upload GnbMirroring Script To ASIK   AND
...             Setup attenuators

# Test Teardown   Run Keyword
# ...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
# ...         Run Keyword and Ignore Error  Detach UE SA

Suite Teardown   Run Keywords
#...             Run Change Mode Script   ue_mode=SA   AND
...             Detach UE SA


*** Variables ***
${tput_DL_bandwith}     1500 Mbits/sec
${tput_UL_bandwith}     190 Mbits/sec
${tput_deviation}       10%
${tput_duration}        300s
${Packet_Size}          1420
${Packet_Size_TCP}      1420
${LOG_PATH}             /home/ute/tput/robotws/
${resource_path_wro4}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/max_tput/resources
${atten_vendor}              JFW

*** Test Cases ***

# [1]Bi-Directional_Throughput_noDss_NsaSa_TputSaUDP_AehcS1_DL4x4CL_UL2x2CL_Bw100Mhz
#    Connect to Coam
#    Load scf for NR    ${resource_path_wro4}    SCFs    100_22R2.xml
#    Disconnect coam
#    Set attenuator AEHC S1
#   Attach and run test UDP
#    [Teardown]  Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
#   Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
#    ...         logs_dir=${LOG_PATH}/data_transfer  ue_alias=UE_3
#    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=udp  deviation=${tput_deviation}
#
# [1]Bi-Directional_Throughput_noDss_NsaSa_TputSaTCP_AehcS1_DL4x4CL_UL2x2CL_Bw100Mhz
#    Set attenuator AEHC S1
#   Attach and run test TCP
#     [Teardown]  Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
#    Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
#    ...         logs_dir=${LOG_PATH}/data_transfer   ue_alias=UE_3
#    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=tcp  deviation=${tput_deviation}
#
# [1]Bi-Directional_Throughput_noDss_NsaSa_TputSaTCP_AehcS2_DL4x4CL_UL2x2CL_Bw100Mhz
#    Set attenuator AEHC S2
#    Attach and run test TCP
#    [Teardown]  Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
#    Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
#    ...         logs_dir=${LOG_PATH}/data_transfer   ue_alias=UE_3
#    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=tcp  deviation=${tput_deviation}
#
# [1]Bi-Directional_Throughput_noDss_NsaSa_TputSaTCP_AehcS3_DL4x4CL_UL2x2CL_Bw100Mhz
#    Set attenuator AEHC S3
#    Attach and run test TCP
#    [Teardown]  Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
#    Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
#    ...         logs_dir=${LOG_PATH}/data_transfer   ue_alias=UE_3
#    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=tcp  deviation=${tput_deviation}
#
[1]Bi-Directional_Throughput_noDss_NsaSa_TputSaUDP_AehcS1_DL4x4CL_UL2x2CL_Bw100+40Mhz
    Set Suite Variable    ${tput_DL_bandwith}     2080 Mbits/sec
    Set Suite Variable    ${tput_UL_bandwith}     190Mbits/sec
    Connect to Coam
    Load scf for NR    ${resource_path_wro4}    SCFs    100_40_22R2.xml
    Disconnect coam
    Set attenuator AEHC S1
    Attach and run test UDP
    [Teardown]  Run Keywords
    ...  Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
    ...  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...  logs_dir=${LOG_PATH}/data_transfer  ue_alias=UE_3
    ...  tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=udp  deviation=${tput_deviation}


[1]Bi-Directional_Throughput_noDss_NsaSa_TputSaTCP_AehcS1_DL4x4CL_UL2x2CL_Bw100+40Mhz
    Set attenuator AEHC S1
    Attach and run test TCP
    [Teardown]  Run Keywords
    ...  Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
    ...  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...  logs_dir=${LOG_PATH}/data_transfer  ue_alias=UE_3
    ...  tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=udp  deviation=${tput_deviation}


[1]Bi-Directional_Throughput_noDss_NsaSa_TputSaTCP_AehcS2_DL4x4CL_UL2x2CL_Bw100+40Mhz
    Set attenuator AEHC S2
    Attach and run test TCP
    [Teardown]  Run Keywords
    ...  Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
    ...  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...  logs_dir=${LOG_PATH}/data_transfer  ue_alias=UE_3
    ...  tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=udp  deviation=${tput_deviation}


[1]Bi-Directional_Throughput_noDss_NsaSa_TputSaTCP_AehcS3_DL4x4CL_UL2x2CL_Bw100+40Mhz
    Set attenuator AEHC S3
    Attach and run test TCP
    [Teardown]  Run Keywords
    ...  Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
    ...  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...  logs_dir=${LOG_PATH}/data_transfer  ue_alias=UE_3
    ...  tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=udp  deviation=${tput_deviation}


# [1]Bi-Directional_Throughput_noDss_NsaSa_TputSaUDP_AehcS3_DL4x4CL_UL2x2CL_Bw15+40Mhz
#    Set Suite Variable    ${tput_DL_bandwith}     720 Mbits/sec
#    Set Suite Variable    ${tput_UL_bandwith}     50Mbits/sec
#    Connect to Coam
#    Load scf for NR    ${resource_path_wro4}    SCFs    15_40_22R2.xml
#    Disconnect coam
#    Set attenuator AHLOA AEHC 5G S1
#    Attach and run test UDP
#    [Teardown]  Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
#    Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
#    ...         logs_dir=${LOG_PATH}/data_transfer  ue_alias=UE_3
#    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=udp  deviation=${tput_deviation}
#
# [1]Bi-Directional_Throughput_noDss_NsaSa_TputSaTCP_AehcS1_DL4x4CL_UL2x2CL_Bw15+40Mhz
#    Set attenuator AHLOA AEHC 5G S1
#    Attach and run test TCP
#    [Teardown]  Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
#    Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
#    ...         logs_dir=${LOG_PATH}/data_transfer   ue_alias=UE_3
#    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=tcp  deviation=${tput_deviation}
#
# [1]Bi-Directional_Throughput_noDss_NsaSa_TputSaTCP_AehcS2_DL4x4CL_UL2x2CL_Bw15+40Mhz
#    Set attenuator AHLOA AEHC 5G S1
#    Attach and run test TCP
#    [Teardown]  Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
#    Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
#    ...         logs_dir=${LOG_PATH}/data_transfer   ue_alias=UE_3
#    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=tcp  deviation=${tput_deviation}
#
# [1]Bi-Directional_Throughput_noDss_NsaSa_TputSaTCP_AehcS3_DL4x4CL_UL2x2CL_Bw15+40Mhz
#    Set attenuator AHLOA AEHC 5G S1
#    Attach and run test TCP
##    [Teardown]  Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
#    Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
#    ...         logs_dir=${LOG_PATH}/data_transfer   ue_alias=UE_3
#    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=tcp  deviation=${tput_deviation}#
#
#[1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaUDP_AehcS1_DL4x4CL_UL2x2CL_Bw60Mhz
#    Set Suite Variable    ${tput_DL_bandwith}     1000 Mbits/sec
#    Set Suite Variable    ${tput_UL_bandwith}     50 Mbits/sec
#    Set attenuator AEHC S1
#    Set Suite Variable    ${tput_duration}     900s
#    Detach UE SA
#    sleep  10s
#    Attach UE SA
#    Start ULDL UDP   UE_3
#    sleep  900s
#    Collect Counters   n_last=20
#    @{counter_ids}      Create list  M51301C0  M51301C1
#    ${counters_count}=  Get Length  ${counter_ids}
#    ${pi_dict}=  get_pi_value
#    ...  pi_list=@{counter_ids}
#    ...  pi_dir=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/collector
#    ...  pi_file_pattern=*PM*
#    ${result}=  check counters values  ${pi_dict}
#    should be true  ${result}
#    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
#    ...         logs_dir=${LOG_PATH}/data_transfer  ue_alias=UE_3
#    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=udp  deviation=${tput_deviation}
#
#[1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaTCP_AehcS1_DL4x4CL_UL2x2CL_Bw60Mhz
#    Set attenuator AHLOA AEHC S1
#    Attach and run test TCP
#    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
#    ...         logs_dir=${LOG_PATH}/data_transfer   ue_alias=UE_3
#    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=tcp  deviation=${tput_deviation}
#
#[1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaTCP_AehcS2_DL4x4CL_UL2x2CL_Bw60Mhz
#    Set attenuator AHLOA AEHC S1
#    Attach and run test TCP
#   [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
#    ...         logs_dir=${LOG_PATH}/data_transfer   ue_alias=UE_3
#    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=tcp  deviation=${tput_deviation}
#
#[1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaTCP_AehcS3_DL4x4CL_UL2x2CL_Bw60Mhz
#    Set attenuator AHLOA AEHC S3
#    Attach and run test TCP
#    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
#    ...         logs_dir=${LOG_PATH}/data_transfer   ue_alias=UE_3
#    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=tcp  deviation=${tput_deviation}
#

*** Keywords ***

Attach and run test TCP
    Detach UE SA
    sleep  10s
    Attach UE SA
    sleep  10s
    Start ULDL TCP   UE_3
    sleep  5s
    #Collect Logs During Data Transfer   direction=BOTH
    #Download Logs From GNB    sub_dir=data_transfer
    #ute_ue.Await Data Transfer Finish                 DT_UL
    #ute_ue.Await Data Transfer Finish                 DT_DL
    sleep  200s

Attach and run test UDP
    Detach UE SA
    sleep  10s
    Attach UE SA
    sleep  10s
    Start ULDL UDP   UE_3
    sleep  5s
    #Collect Logs During Data Transfer   direction=BOTH
    #Download Logs From GNB    sub_dir=data_transfer
    #ute_ue.Await Data Transfer Finish                 DT_UL
    #ute_ue.Await Data Transfer Finish                 DT_DL
    sleep  200s

Reserve UE SA
    ute_ue.Require Ue    UE_3    capabilities=REAL_ANDROID_UE_SA

Attach UE SA
    ute_ue.Attach Ue   UE_3

Detach UE SA
    ute_ue.Detach Ue  UE_3

Reserve UE NSA
    ute_ue.Require Ue    UE_2    capabilities=REAL_ANDROID_UE_NSA

Attach UE NSA
    ute_ue.Attach Ue   UE_2

Detach UE NSA
    ute_ue.Detach Ue  UE_2

Start ULDL UDP
    [Arguments]   ${ue_id}
    ute_ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_id}  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp	   packet_size=${Packet_Size}
    ute_ue.Start Data Transfer  dt_name=DT_UL  ue_alias=${ue_id}  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    ute_ue.Check Data Transfer Is Alive               DT_UL
    ute_ue.Check Data Transfer Is Alive               DT_DL

Start ULDL TCP
    [Arguments]   ${ue_id}
    ute_ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_id}  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=tcp	   max_segment_size=${Packet_Size_TCP}
    ute_ue.Start Data Transfer  dt_name=DT_UL  ue_alias=${ue_id}  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=tcp    max_segment_size=${Packet_Size_TCP}
    Sleep                10s
    ute_ue.Check Data Transfer Is Alive               DT_UL
    ute_ue.Check Data Transfer Is Alive               DT_DL
