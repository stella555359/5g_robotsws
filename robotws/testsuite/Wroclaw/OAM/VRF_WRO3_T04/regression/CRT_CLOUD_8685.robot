*** Settings ***
Documentation    Suite for testing 9857 on Cloud
...              Authors:    Patryk Tatarek
...              Contact:    patryk.tatarek@nokia.com

Resource        ../features/CB013411/TestCases/CB013411_F.robot
Resource        ../../cloud_common_resources/logs/logs.robot
Resource        ../cloud_common_resources/dcap/dcap.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot

Library         String
Library         SSHLibrary
Library         Collections
Library         OperatingSystem

Suite Teardown   Suite Teardown

*** Test Cases ***

[1]CB013411_CB007128_Counters_verification_NetAct_WebEM_vDU
    [Tags]     vDU
    CB013411-Counters_verification_WebEM_vDU

[1]CB013411_CB007128_Spoof_prevention_IPv4_vDU
    [Tags]     vDU
    CB013411-SyVe_Spoof_Prevention_vDU

[1]CB013411_CB007128_Stateful_packet_filtering_IPv4_vDU
    [Tags]     vDU
    CB013411-SyVe_Stateful_Packet_Filtering_IPv4_vDU

[1]CB013411-C_CB008325-5G_CB007128_Stateless_packet_filtering_IPv4_vDU
    [Tags]     vDU
    CB013411-SyVe_Stateless_Packet_Filtering_vDU

[1]CB013411_CB008817-A_IPSec_defect_handling_between_the_vDU_and_RU
    [Tags]     vDU
    CB013411-A_IPSec_defect_handling_between_the_DU_and_RU_vDU

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...                             team_name=PZ3WRO4
    ...                             input_logs_dir=${None}
    ...                             remote_host_vDU=${LMP_VDU_IP}
    ...                             remote_host_vCU=${LMP_VCU_IP}
    ...                             mandatory_log_types=__snapshot_vDU__,__snapshot_vCU__
    ...                             collect_NOP=${True}

