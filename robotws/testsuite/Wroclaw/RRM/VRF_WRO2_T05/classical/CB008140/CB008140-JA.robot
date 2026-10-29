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
${resource_path_delta}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/config/default
${resource_path_8140-JA}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources
${labpcip}=                 10.44.72.183
${tes_emil}=                ${CURDIR}/resources/2640_emil.robot

*** Keywords ***
[1]CB008140-JA#B1A3_NG-C_link_locked_with_4UEs_with_2CC&3CC
    [Documentation]  This user scenario describes the behavior of the gNB when NG-C link is locked
    ...              (for the NG-C interface), 4UEs are used. UEs 4,3,1 should be attached do PCI 304,
    ...              while UE 2 should be attached to PCI 561.
    ...              UE4: PCell 1 + Scells 145 and 311
    ...              UE3: Pcell 1 + Scells 60 and 561
    ...              UE1: Pcell 1 + Scell 50
    ...              UE2: Pcell 561 + Scell 311
    Set global variable bts id
    Prepare and check neightbour TL  7_16_UTE5GCLOUDT154
    ...    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources  SCFs/7-16-UTE5GCLOUD410  scf_8140-JA-gNB3.xml
    Load scf for second NR    ${resource_path_8140-JA}    SCFs    scf_8140-JA-gNB2.xml
#    Load scf for second NR    ${resource_path_8140-JA}    SCFs    scf_8140-JA-gNB3.xml    10.44.137.48
#    Load scf for NR           ${resource_path_8140-JA}    SCFs    scf_8140-JA-gNB1.xml
    ${stream_name}    Get stream name
    ${stream_name}=   Set Variable If  '${stream_name}' == 'TRUNK'  default    ${stream_name}
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    coam.perform_delta_recommissioning    delta_file=${resource_path_delta}/delta_8140-JA-mainGNB.json
    ...    connection=cOAM
	Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    Setup attenuators for T186
    Download Xn and F1 plugins
    Setup attenuator for 154 TL
    Set initial attenuation for 8140-JA
    Set test variable  ${test_name}  CB008140-JA
    change_weight_for_iGNB_CA        ${bts_id}    nradjgnb_id=4,5    weight=1
    Sleep                            10s
    Start Tshark monitoring
    Start Tshark monitoring          hostname=10.44.137.49   alias=gnb2
    Start Tshark monitoring          hostname=10.44.137.48   alias=gnb3
    Start syslog collection
    ####################### UE_4
    Attach UE              UE_4
    Sleep                  6s
    ${PCI_UE4}=            ute_ue.Get Ue Info    UE_4   PCI
    Log to Console         UE4: ${PCI_UE4}
    Start Data Transfer    dt_name=DT_DL_SA4    ue_alias=UE_4    direction=dl    duration=420s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA4    ue_alias=UE_4    direction=ul    duration=420s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    change weight for iGNB CA    ${bts_id}    nradjgnb_id=4    weight=50
    Sleep                  10s
    ####################### UE_3
    Set initial attenuation for 8140-CD
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AEHC_1}     value=35
    Sleep                  3s
    Attach_UE              UE_3
    Sleep                  6s
    ${PCI_UE3}=            ute_ue.Get Ue Info    UE_3   PCI
    Log to Console         UE3: ${PCI_UE3}
    Start Data Transfer    dt_name=DT_DL_SA3    ue_alias=UE_3    direction=dl    duration=420s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA3    ue_alias=UE_3    direction=ul    duration=420s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    change weight for iGNB CA    ${bts_id}    nradjgnb_id=4    weight=1
    Change weight for iGNB CA    ${bts_id}    nradjgnb_id=5    weight=100
    Sleep                  10s
    ####################### UE_1
    Setup initial attenuation for 154 TL   lines=${lines_gNB_154_on}   value=0
    Attach_UE              UE_1
    Sleep                  6s
    ${PCI_UE2}=            ute_ue.Get Ue Info    UE_1   PCI
    Log to Console         UE2: ${PCI_UE2}
    Start data transfer    dt_name=DT_DL_SA2    ue_alias=UE_1    direction=dl    duration=420s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start data transfer    dt_name=DT_UL_SA2    ue_alias=UE_1    direction=ul    duration=420s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=10
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AEHC_1}     value=0
    Sleep                  8s
    ####################### UE_2
    Attach_UE              UE_2
    Sleep                  6s
    ${PCI_UE1}=            ute_ue.Get Ue Info    UE_2   PCI
    Log to console         UE1: ${PCI_UE1}
    Start data transfer    dt_name=DT_DL_SA1    ue_alias=UE_2    direction=dl    duration=300s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start data transfer    dt_name=DT_UL_SA1    ue_alias=UE_2    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    Connect to Coam
    coam.Lock NG link      dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/SERVEDAMF-1    connection=cOAM
    Sleep                  25s
    Stop syslog collection
    Log to Console         NG link locked
    Run keyword and ignore error    Stop data transfer                 DT_UL_SA4
    Run keyword and ignore error    Stop data transfer                 DT_DL_SA4
    Run keyword and ignore error    Stop data transfer                 DT_UL_SA2
    Run keyword and ignore error    Stop data transfer                 DT_DL_SA2
    Run keyword and ignore error    Stop data transfer                 DT_UL_SA3
    Run keyword and ignore error    Stop data transfer                 DT_DL_SA3
    Run keyword and ignore error    Stop data transfer                 DT_UL_SA1
    Run keyword and ignore error    Stop data transfer                 DT_DL_SA1
    Verify registration to FDD PCell
    Stop Tshark monitoring and download logs    filename=${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}.pcap
    Stop Tshark monitoring and download logs    filename=${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}_186.pcap   alias=gnb2
    Stop Tshark monitoring and download logs    filename=${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}_154.pcap  alias=gnb3
    #################### Log verification gNB-main
    ${reset_mesgs}               search_syslog_for_UE_bulk_release  ${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    Should be true               ${reset_mesgs}
    check_ca_establishment       ${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}.pcap        3   3   3
    check_reset_xnap_messages    ${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}.pcap        2
    ###################### Log verification gNB-ext2
    check_reset_xnap_messages    ${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}_186.pcap    1
    ###################### Log verification gNB-ext3
    check_reset_xnap_messages    ${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}_154.pcap    1
    ##################### PM counters verification
    Verify PM counters 8140-JA prime gnb
    Verify PM counters 8140-JA ext gnb
    Verify PM counters 8140-JA ext gnb    hostname=10.44.137.48
    [Teardown]  Run keyword
    ...         coam.Unlock NG link  dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/SERVEDAMF-1    connection=cOAM
