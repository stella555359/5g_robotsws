*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com
...  Description: This feature introduces inter-gNB Carrier Aggregation up to 4 SCells,
...               FR1 TDD or FDD carriers.

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/xn_link_management/xn_link.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py

*** Variables ***
${resource_path_8140-JD}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources
${labpcip}=                 10.44.72.183
${tes_emil}=                ${CURDIR}/resources/2640_emil.robot

*** Keywords ***
[1]CB008140-JD#B3_Xn-_link_used_for_inter-gNB_CA_locked_by_operator
    [Documentation]  This user scenario describes the behavior of the gNB when NG-C link is locked
    ...              (for the NG-C interface), 4UEs are used. UEs attach to the exact same cells as in 8140-JA.
    Set global variable bts id
    Download Xn and F1 plugins
    Setup attenuators for T186
    Setup attenuator for 154 TL
    Set initial attenuation for 8140-JA
    Set test variable  ${test_name}  CB008140-JD-Lock
    change_weight_for_iGNB_CA        ${bts_id}    nradjgnb_id=4,5    weight=1
    Sleep                            10s
    Start Tshark monitoring
    Start Tshark monitoring          hostname=10.42.234.104   alias=gnb2
    Start Tshark monitoring          hostname=10.42.181.25    alias=gnb3
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
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AEHC_1}     value=40
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
    ####################### UE_2
    Setup initial attenuation for 154 TL   lines=${lines_gNB_154_on}   value=0
    Attach_UE              UE_2
    Sleep                  6s
    ${PCI_UE2}=            ute_ue.Get Ue Info    UE_2   PCI
    Log to Console         UE2: ${PCI_UE2}
    Start data transfer    dt_name=DT_DL_SA2    ue_alias=UE_2    direction=dl    duration=420s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start data transfer    dt_name=DT_UL_SA2    ue_alias=UE_2    direction=ul    duration=420s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=25
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AEHC_1}     value=0
    Sleep                  8s
    ####################### UE_1
    Attach_UE              UE_1
    Sleep                  6s
    ${PCI_UE1}=            ute_ue.Get Ue Info    UE_1   PCI
    Log to console         UE1: ${PCI_UE1}
    Start data transfer    dt_name=DT_DL_SA1    ue_alias=UE_1    direction=dl    duration=300s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start data transfer    dt_name=DT_UL_SA1    ue_alias=UE_1    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    Change XnLink  Locked
    Sleep                  10s
    Stop syslog collection
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
    Stop Tshark monitoring and download logs    filename=${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}_186.pcap  alias=gnb2
    Stop Tshark monitoring and download logs    filename=${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}_154.pcap  alias=gnb3
    #################### Log verification gNB-main
    ${reset_mesgs}               search_syslog_for_UE_bulk_release  ${OUTPUT DIR}/${SUITE NAME}/${test_name}.log    3
    Should be true               ${reset_mesgs}
    check_ca_establishment       ${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}.pcap        3   3   3
    check_reset_xnap_messages    ${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}.pcap        2
    ###################### Log verification gNB-ext2
    check_reset_xnap_messages    ${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}_186.pcap    1
    ###################### Log verification gNB-ext3
    check_reset_xnap_messages    ${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}_154.pcap    1
    #################### PM counters verification
    Verify PM counters 8140-JD prime gnb
    Verify PM counters 8140-JD ext gnb    hostname=10.42.234.104
    [Teardown]  Run keyword
    ...         Change XnLink  Unlocked

[1]CB008140-JD#B4_Unlock_of_Xn-C_link
    [Documentation]  This user scenario describes unlock of Xn-C link between gNBs configured
    ...              for inter-gNB CA.
    Set global variable bts id
    Download Xn and F1 plugins
    Setup attenuators for T186
    Setup attenuator for 154 TL
    Set initial attenuation for 8140-JA
    Start Tshark monitoring
    Start Tshark monitoring          hostname=10.42.234.104   alias=gnb2
    Change XnLink  Locked
    Sleep                  10s
    Change XnLink  Unlocked
    Set test variable  ${test_name}  CB008140-JD-Unlock
    change_weight_for_iGNB_CA        ${bts_id}    nradjgnb_id=4,5    weight=1
    Sleep                            10s
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
    ####################### UE_2
    Setup initial attenuation for 154 TL   lines=${lines_gNB_154_on}   value=0
    Attach_UE              UE_2
    Sleep                  6s
    ${PCI_UE2}=            ute_ue.Get Ue Info    UE_2   PCI
    Log to Console         UE2: ${PCI_UE2}
    Start data transfer    dt_name=DT_DL_SA2    ue_alias=UE_2    direction=dl    duration=420s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start data transfer    dt_name=DT_UL_SA2    ue_alias=UE_2    direction=ul    duration=420s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=25
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AEHC_1}     value=0
    Sleep                  8s
    ####################### UE_1
    Attach_UE              UE_1
    Sleep                  6s
    ${PCI_UE1}=            ute_ue.Get Ue Info    UE_1   PCI
    Log to console         UE1: ${PCI_UE1}
    Start data transfer    dt_name=DT_DL_SA1    ue_alias=UE_1    direction=dl    duration=300s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start data transfer    dt_name=DT_UL_SA1    ue_alias=UE_1    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    Stop syslog collection
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
    Stop Tshark monitoring and download logs    filename=${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}_186.pcap  alias=gnb2
    #################### Log verification gNB-main
    check_ca_establishment       ${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}.pcap        3   3   3
    check_reset_xnap_messages    ${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}.pcap        2
    ###################### Log verification gNB-ext2
    check_reset_xnap_messages    ${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}_186.pcap    1
    ###################### Log verification gNB-ext3
    check_reset_xnap_messages    ${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}_154.pcap    1
    [Teardown]  Run keyword
    ...         Change XnLink  Unlocked
