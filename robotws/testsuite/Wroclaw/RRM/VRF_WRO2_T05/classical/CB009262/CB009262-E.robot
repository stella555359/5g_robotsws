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
[1]CB009262-SR-E_5GC000545_C_Dynamic_transform_precoder_switching_successfully_in_SA_mode_with_AVHA_RU
    [Documentation]    The purpose of this test case is to verify if AVHA RU support intra-band TDD FR1 CA feature
    ...                activation and deactivation when gNB cells are configured in SA (PCell 400, SCell 410).
    Set test variable  ${test_name}  CB009262-E
    Setup attenuators
    @{lines_gNB_T215_AVHA}   Create List    9   10   11   12
    Set attenuation and check    lines=${lines_gNB_T215_AVHA}  value=0
    coam.perform parameter recommissioning    dist_name=MRBTS-50714/NRBTS-50714/NRCELL-400/NRHOIF-1
    ...    parameter=a3MeasEnabled    operation=update    value=none   timeout=120    connection=cOAM
    coam.lock    dist_name=MRBTS-50714/NRBTS-50714/NRCELL-410    timeout=60    connection=cOAM    detailed_output=True
    Attach Ue     UE_2
    Sleep         5s
    ${PCI_UE1}=       ute_ue.Get Ue Info    UE_2   PCI
    Log to Console    UE attached PCI: ${PCI_UE1}
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_2    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Start New L1L2 Logs    ip=192.168.255.129
    Prepare and start new DCAP       dcap_host=10.44.180.37  bts_mplane=10.44.137.26   nrCells=NRCELL_R-400
    Sleep    5s
    Trigger Transform Precoder
    Sleep    20s
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Stop New L1L2 Logs And Download PCAP    ip=192.168.255.129
    Run keyword and ignore error    Check Data Transfer Is Alive    DT_UL_SA
    Run keyword and ignore error    Stop Data Transfer     DT_UL_SA
    Check Transform Precoder on from PCAP
    Verify JSON file from DCAP  expected_messages=${messages_9262_E}
    [Teardown]    coam.unlock    dist_name=MRBTS-50714/NRBTS-50714/NRCELL-410    timeout=60    connection=cOAM
