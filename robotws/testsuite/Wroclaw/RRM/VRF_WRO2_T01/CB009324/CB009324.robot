*** Settings ***
Documentation
...  author: Mikolaj Guszpit
...  contact:       mikolaj.guszpit@nokia.com
...  maintainer:    mikolaj.guszpit@nokia.com
...  Description:   Test Cases for CB009324 feature: This sector will be filled in the future.
...  Topology:  CLOUD_5G_CLASSICAL_ANDROID_ATT_ASIML_2xABIO_ABIP_AHFIB_3xAHLOA_2xAEHC ->T161

Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB009324/resources/tests_9324.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/multi_ue.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot

Suite Setup  Prepare TL for CB009234

Test Setup  run keywords
...     get ues  ${ues}  REAL_UE              AND
...     Start syslog capture

Test Teardown  run keywords
...     Stop syslog capture                   AND
...     Add Scout Data Info To Testcase       AND
...     Collect snapshot if test failed


*** Variables ***
@{ues}  ue1

*** Test Cases ***
[1]CB009324#A-US1_03_CAonLTE-ON,OFF_Traffic_shaping_FT_ON_OFF_FDD_full_buffer_dlDataSplit_0_FSTSCH_ETHIF.sir_2000000
    [1]CB009324#A-US1_03_CAonLTE-ON,OFF_Traffic_shaping_FT_ON_OFF_FDD_full_buffer_dlDataSplit_0_FSTSCH_ETHIF.sir_2000000

[1]CB009324#A-US3_09_CAonLTE_Traffic_shaping_at_gNB_DL_data_over_X2-U_FDD_PDCP_Fast.Retransmissions_small_DL_data_packet_size
    [1]CB009324#A-US3_09_CAonLTE_Traffic_shaping_at_gNB_DL_data_over_X2-U_FDD_PDCP_Fast.Retransmissions_small_DL_data_packet_size

[1]CB009324#A_05_CAonLTE_Traffic_shaping_at_gNB_DL_data_over_X2-U_TDD_small_DL_data_packet_size
    [1]CB009324#A_05_CAonLTE_Traffic_shaping_at_gNB_DL_data_over_X2-U_TDD_small_DL_data_packet_size

[1]CB009324#A_05_avg_tput_comparation
    [1]CB009324#A_05_avg_tput_comparation