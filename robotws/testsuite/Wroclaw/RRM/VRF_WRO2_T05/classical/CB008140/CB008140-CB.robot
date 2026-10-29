*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com
...  Description: This user scenario describes the successful addition of a new DRB in the ext-gNB for a UE context
...               already in IgNB-CA mode

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/logs.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/kw_2640.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008533/resources/kw_8533.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001390/resources/kw_1390.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py
Library         testsuite/Wroclaw/RRM/resources/logs.py

*** Variables ***
${resource_path_8140-CD}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources


*** Keywords ***
[1]CB008140-CB#B1_[F+F+T]_Successful_addition_of_a_new_DRB_in_the_ext-gNB_after_the_setup_of_a_new_PDU
    [Documentation]    PCell: FDD PCI 101, SCells: TDD PCI 163,263 and FDD PCI 60.
#    Load scf for second NR    ${resource_path_8140-CD}    SCFs    scf_8140-CD-external.xml
#    coam.perform_delta_recommissioning    delta_file=${resource_path_8140-CD}/delta_8140-CD-mainGNB.json
#    ...    connection=cOAM
    Setup attenuators for T186
    Set attenuation for CA first gNB
    Set attenuation for CA second gNB
    Prepare and start new DCAP   bts_mplane=10.44.137.51   nrCells=NRCELL_R-1
    Attach UE  UE_1
    Start New L1L2 Logs
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=300s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Sleep    30s
    Run keyword and ignore error    Stop Data Transfer           DT_DL_SA
    Run keyword and ignore error    Get Average Throughput       DT_DL_SA
    Run keyword and ignore error    Stop Data Transfer           DT_UL_SA
    Run keyword and ignore error    Get Average Throughput       DT_UL_SA
    Stop New L1L2 Logs And Download PCAP
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Verify PM Counters 8140-CB
    Verify PM Counter 8140-CB External GNB
    Verify JSON file from DCAP  expected_messages=${messages_8140_CB}
#    [Teardown]    delta.roll_delta_back    initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
#    ...           delta_scf_filename=delta_8140-CD-mainGNB.json
