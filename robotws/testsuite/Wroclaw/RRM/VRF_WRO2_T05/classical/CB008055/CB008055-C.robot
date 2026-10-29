*** Settings ***
Documentation
...  author: Karol palac
...  contact: karol.palac@nokia.com

Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008055/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008055/resources/keywords.py


*** Variables ***
${resource_path_8055}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008055/resources


*** Keywords ***
[1]CB008055-C#B3_Buffer_based_SCell_activation_for_5CC_6CC_FDD_DL_CA_and_2CC_FDD_UL_CA_configuration
    [Documentation]    This test case verifies the successful SCell activation based on buffer size meeting the
    ...    activation condition. DL only SCells are successfully activated based on DL buffer size meeting the
    ...    activation condition. FDD SCell configured with UL CA is successfully activated based on DL buffer size
    ...    or UL buffer size meeting the activation condition.
    Load scf for NR    ${resource_path_8055}    SCFs    scf_8055-C.xml
    Set test variable  ${test_name}  CB008055-CB3
    Setup attenuators
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=0
    Prepare and start new DCAP   dcap_host=10.44.180.37  bts_mplane=10.44.137.26   nrCells=NRCELL_R-800 NRCELL_R-100
    Attach Ue     UE_3
    Sleep         10s
    ${PCI_UE3}=       ute_ue.Get Ue Info    UE_3   PCI
    Log to Console    UE attached PCI now: ${PCI_UE3}
    keywords.Deattenuate scells
    Start Data Transfer    dt_name=SMALL_DL_SA    ue_alias=UE_3    direction=dl    duration=500s    throughput=200Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Start Data Transfer    dt_name=BIG_UL_SA    ue_alias=UE_3    direction=ul    duration=500s    throughput=200Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Sleep    10s
    ${DL_tput}         Get Average Throughput       SMALL_DL_SA
    Log to Console     DL Throughput Small: ${DL_tput}
    ${UL_tput}         Get Average Throughput       BIG_UL_SA
    Log to Console     UL Throughput Big: ${UL_tput}
    Run keyword and ignore error    Stop Data Transfer     BIG_UL_SA
    Start Data Transfer    dt_name=BIG_DL_SA    ue_alias=UE_3    direction=dl    duration=500s    throughput=1700Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Start Data Transfer    dt_name=SMALL_UL_SA    ue_alias=UE_3    direction=ul    duration=500s    throughput=20Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Sleep    30s
    ${DL_tput}         Get Average Throughput       SMALL_DL_SA
    Log to Console     DL Throughput Big: ${DL_tput}
    ${UL_tput}         Get Average Throughput       BIG_UL_SA
    Log to Console     UL Throughput Small: ${UL_tput}
    Run keyword and ignore error    Stop Data Transfer     BIG_DL_SA
    Sleep    20s
    Run keyword and ignore error    Stop Data Transfer     SMALL_DL_SA
    Run keyword and ignore error    Stop Data Transfer     SMALL_UL_SA
    Start Data Transfer    dt_name=BIG_DL_SA_FINAL    ue_alias=UE_3    direction=dl    duration=500s    throughput=1700Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Start Data Transfer    dt_name=BIG_UL_SA_FINAL    ue_alias=UE_3    direction=ul    duration=500s    throughput=350Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Sleep    30s
    ${DL_tput}         Get Average Throughput       BIG_DL_SA_FINAL
    Log to Console     DL Throughput Final: ${DL_tput}
    ${UL_tput}         Get Average Throughput       BIG_UL_SA_FINAL
    Log to Console     UL Throughput Final: ${UL_tput}
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Run keyword and ignore error    Stop Data Transfer     BIG_DL_SA_FINAL
    Run keyword and ignore error    Stop Data Transfer     BIG_UL_SA_FINAL
    Verify JSON file from DCAP  expected_messages=${messages_8055_C}
    Verify PM Counters 8055-C
