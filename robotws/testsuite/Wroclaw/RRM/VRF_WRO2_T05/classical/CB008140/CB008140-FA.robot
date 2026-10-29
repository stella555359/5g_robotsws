*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com
...  Description: This feature introduces Carrier Aggregation between FDD carrier as PCell and up to 3 SCells,
...               FR1 TDD or FDD carriers.

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources/keywords.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py

*** Variables ***
${resource_path_8140-FA}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources
${labpcip}=                 10.44.72.183
${tes_emil}=                ${CURDIR}/resources/2640_emil.robot

*** Keywords ***
[1]CB008140-FA#B1A10_[F+F+F+T]_Partial_SCell_addition_success_for_one_SA_more_than_one_SCell_candidate_to_be_added
    [Documentation]  This user scenario describes partial SCell addition success case where FDD and TDD SCells are not
    ...              admitted ? partial SCell candidates are admitted in ext-gNB-CU. A1 measurement based SCell addition
    ...              method is used for 4CC F+F+F+T CA setup.
    Load scf for second NR    ${resource_path_8140-FA}    SCFs    scf_8140-FA-external.xml
#    Load scf for NR    ${resource_path_8140-FA}    SCFs    scf_8140-CD-main.xml
#    coam.perform_delta_recommissioning    delta_file=${resource_path_8140-CD}/delta_8140-CD-mainGNB.json
#    ...    connection=cOAM
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    Download Xn and F1 plugins
    Setup attenuators for T186
    Set initial attenuation for 8140-CD
    Set test variable  ${test_name}  CB008140-FA
    Prepare and start new DCAP   bts_mplane=10.44.137.51   nrCells=NRCELL_R-1
    Start Tshark monitoring
    Attach UE    UE_1
    Sleep  5s
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=300s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start New L1L2 Logs
    Sleep     10s
    Stop Data Transfer           DT_UL_SA
    Stop Data Transfer           DT_DL_SA
    Get Average Throughput       DT_DL_SA
    Stop Tshark monitoring and download logs    filename=${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}.pcap
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Stop New L1L2 Logs And Download PCAP
    Verify JSON file from DCAP  expected_messages=${messages_8140_FA}
    Verify Tshark messages    pcap_path=${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}.pcap    filters=${filters_8140_FA}
    Verify PM Counters 8140-FA Prime GNB
    Verify PM Counters 8140-FA External GNB
    Log to Console    >PM Counters gotten successfully.<
    [Teardown]    delta.roll_delta_back    initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...           delta_scf_filename=delta_8140-CD-mainGNB.json
