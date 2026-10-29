# *** Settings ***
# Documentation
# ...  author: Yang Di
# ...  contact: di.yang@nokia-sbell.com
# 
# Force Tags    SBTS00    SBTS22R3    RAN_5G
# ...    PY36
# ...           RAN_5G_TDD    STATE_SW_UPLOADED
# 
# Suite Setup    Run keywords
# ...            robot_common_operations.Common Suite Setup  AND
# ...            CI_interface.Common Suite Setup  AND
# ...            Download MCShark To UTE
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# Library         taf.ue
# Library         OperatingSystem
# Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/bip.robot
# Resource        testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000570/resources/keywords.robot
# Resource        ../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Test Setup          Run keywords
# ...                 robot_common_operations.Common Case Setup    AND
# ...                 Get Realease Name  AND
# ...                 Set TESTNAME without spaces  AND
# ...                 Get BTS id and set as suite variable  
# 
# 
# Test Teardown       Run keywords
# ...                 robot_common_operations.Common Case Teardown    AND
# ...                 keywords.Test teardown  AND
# ...                 coam.teardown
# 
# *** Test Cases ***
# [1]5GC000570_B_Configuring_3gpp_flow_control_for_each_bearer_I&V
#     [Documentation]   Purpose of this test is to check procedure to configure Nokia proprietary flow control for each bearer
#     [Tags]  3GPP    SBTS00    SBTS22R3   CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEUD_ENB    CRT_UTE 
#     Configuring_3gpp_Case_Steps
# 
# [1]5GC000570G_A_Max_expected_UDP_Downlink_data_throughput_splitted_over_F1U_and_X2U_interfaces_received_by_UE_I&V
#     [Documentation]   Purpose of this test is check successful max expected UDP Downlink data throughput
#     ...               received over splitted X2U and F1U interfaces. For parameters configuration:
#     ...               2x2 MIMO, 64QAM, 1/4 slot ratio, semi static, 2 OFDM symbols, SSBurstSetPeriod=20ms
#     ...               calculated Max Downlink throughput is 601 Mbit/s (http://5gtables.eecloud.dynamic.nsn-net.net/nrTput.php)
#     ...               The test checks splitting 600Mbit/s traffic throuh 30 minutes
#     [Tags]  DL  Split    SBTS00    SBTS22R3    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEUD_ENB    CRT_UTE
#     Set Data Split Mode            dl_split=dlOverF1UX2U
#     Attach UE And Check QoS
#     keywords.Start traffic    direction=dl  protocol=udp  duration=1800  tput=600
#     Verify traffic in each PM counter time period
#     Verify traffic in whole time period
# 
# [1]5GC000570G_A_Max expected UDP Downlink data throughput sent over X2U interface received by UE_I&V
#     [Documentation]   This test case describes successful max expected UDP Downlink data throughput received over X2U interface
#     ...               The test checks if max traffic is only on x2u interface throuh 30 minutes
#     [Tags]  DL  X2    SBTS00    SBTS22R3    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEUD_ENB    CRT_UTE
#     Set Data Split Mode             dl_split=dlOverX2U
#     Attach UE And Check QoS
#     keywords.Start traffic    direction=dl  protocol=udp  duration=1800  tput=${max_dl_lte}
#     Verify traffic in each PM counter time period
#     Verify traffic in whole time period
# 
# [1]5GC000570G_B_Max_expected_UDP_Uplink_data_throughput_splitted_over_F1U_and_X2U_interfaces_I&V
#     [Documentation]   Purpose of this test is check successful max expected UDP Uplink data throughput
#     ...               sent over splitted X2U and F1U interfaces. For parameters configuration:
#     ...               2x2 MIMO, 64QAM, 1/4 slot ratio, semi static, 2 OFDM symbols, SSBurstSetPeriod=20ms
#     ...               calculated Max Downlink throughput is 140 Mbit/s (http://5gtables.eecloud.dynamic.nsn-net.net/nrTput.php)
#     ...               The test checks splitting 70Mbit/s traffic throuh 30 minutes - one uplink layer on UE - half traffic
#     [Tags]  UL  Split    SBTS00    SBTS22R3    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEUD_ENB    CRT_UTE
#     Set Data Split Mode      ul_split=ulOverLteNr_PrimaryPathOverNr   ul_threshold=b0   ul_split_not_capable_ue=ulPrimaryPathOverNr
#     Attach UE And Check QoS
#     keywords.Start traffic    direction=ul  protocol=udp  duration=1800  tput=70
#     Verify traffic in each PM counter time period
#     Verify traffic in whole time period
# 
# [1]5GC000570G_B_Max expected UDP Uplink data throughput sent over X2U interface_I&V
#     [Documentation]   This test case describes a successful max expected UDP Uplink data throughput sent over X2U  interface
#     ...               The test checks if max traffic is only on x2u interface throuh 30 minutes
#     [Tags]  UL  X2    SBTS00    SBTS22R3    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEUD_ENB    CRT_UTE
#     Max_Uplink_sent_Case_Steps
# 
