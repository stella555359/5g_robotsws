*** Settings ***
Documentation
...  author: Karol palac
...  contact: karol.palac@nokia.com

Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009262/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009262/resources/keywords.py


*** Variables ***
${resource_path_9262}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009262/resources


*** Keywords ***
[1]CB009262-SR-I_2CC_Carier_Aggregation_Successful_operation_of_feature_activation_and_deactivation_with_defined_CA_relation
    [Documentation]    The purpose of this test case is to verify if AVHA RU support intra-band TDD FR1 CA feature
    ...                activation and deactivation when gNB cells are configured in SA (PCell 400, SCell 410).
    Load scf for NR    ${resource_path_9262}    SCFs    scf_9262-I.xml
    Set test variable  ${test_name}  CB009262-I
    Setup attenuators
    @{lines_gNB_T215_AVHA}   Create List    9   10   11   12
    Set attenuation and check    lines=${lines_gNB_T215_AVHA}  value=20
    Prepare and start new DCAP       dcap_host=10.44.180.37  bts_mplane=10.44.137.26   nrCells=NRCELL_R-400 NRCELL_R-410
    Attach Ue     UE_2
    Sleep         5s
    ${PCI_UE1}=       ute_ue.Get Ue Info    UE_2   PCI
    Log to Console    UE attached PCI: ${PCI_UE1}
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_2    direction=dl    duration=300s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1200
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_2    direction=ul    duration=300s    throughput=200Mbits/sec
    ...                    protocol=udp    packet_size=1200
    Sleep    20s
    ${DL_tput}         Get Average Throughput       DT_DL_SA
    Log to Console     DL Throughput: ${DL_tput}
    ${UL_tput}=    Run keyword and ignore error         Get Average Throughput       DT_UL_SA
    Run keyword and ignore error    Log to Console     UL Throughput: ${UL_tput}
    Sleep    20s
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Run keyword and ignore error    Stop Data Transfer     DT_UL_SA
    Run keyword and ignore error    Stop Data Transfer     DT_DL_SA
    Verify JSON file from DCAP  expected_messages=${messages_9262_I}
    Verify PM Counters 9262-I

