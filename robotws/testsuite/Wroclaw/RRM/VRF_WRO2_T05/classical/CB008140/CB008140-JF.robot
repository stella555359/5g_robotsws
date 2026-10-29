*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com
...  Description: This feature introduces inter-gNB Carrier Aggregation up to 4 SCells,
...               FR1 TDD or FDD carriers.

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources/keywords.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py

*** Variables ***
${resource_path_8140-JD}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources
${labpcip}=                 10.44.72.183
${tes_emil}=                ${CURDIR}/resources/2640_emil.robot

*** Keywords ***
[1]CB008140-JF#PM1_for_measuring_RLC_PDUs_Volume_sent_over_CA_Procedure_2a
    [Documentation]  This User Scenario is for defining the PM counters to measure the data
    ...              volume transferred from PCell and SCell for CA. PM counter group is changed for NRDRB-10.
    Set global variable bts id
    Download Xn and F1 plugins
    Setup attenuators for T186
    Setup attenuator for 154 TL
    Set initial attenuation for 8140-CD
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AEHC_1}     value=40
    Set test variable  ${test_name}  CB008140-JF
    change_weight_for_iGNB_CA        ${bts_id}    nradjgnb_id=5    weight=1
    change_weight_for_iGNB_CA        ${bts_id}    nradjgnb_id=4    weight=100
    Change pmcounter group           ${bts_id}    drb_group=14             value=3
    Sleep                            10s
    Start Tshark monitoring
    Start Tshark monitoring          hostname=10.42.234.104   alias=gnb2
    Start syslog collection
    ####################### UE_1
    Attach UE              UE_1
    Sleep                  6s
    ${PCI_UE1}=            ute_ue.Get Ue Info    UE_1   PCI
    Log to Console         UE1: ${PCI_UE1}
    Start Data Transfer    dt_name=DT_DL_SA1    ue_alias=UE_1    direction=dl    duration=300s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA1    ue_alias=UE_1    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AEHC_1}     value=0
    Sleep                  30s
    Run keyword and ignore error    Stop data transfer                 DT_UL_SA1
    Run keyword and ignore error    Stop data transfer                 DT_DL_SA1
    Detach UE              UE_1
    Sleep                  5s
    Change pmcounter group             ${bts_id}    drb_group=14             value=17
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AEHC_1}     value=40
    Sleep                  5s
    Attach UE              UE_1
    Sleep                  6s
    ${PCI_UE1}=            ute_ue.Get Ue Info    UE_1   PCI
    Log to Console         UE1: ${PCI_UE1}
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AEHC_1}     value=0
    Start Data Transfer    dt_name=DT_DL_SA2    ue_alias=UE_1    direction=dl    duration=300s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA2    ue_alias=UE_1    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Sleep                  30s
    Run keyword and ignore error    Stop data transfer                 DT_UL_SA2
    Run keyword and ignore error    Stop data transfer                 DT_DL_SA2
    Stop syslog collection
    Verify registration to FDD PCell
    Stop Tshark monitoring and download logs    filename=${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}.pcap
    Stop Tshark monitoring and download logs    filename=${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}_186.pcap  alias=gnb2
    #################### Log verification gNB-main
    check_ca_establishment             ${OUTPUT_DIR}/PCAPs/Tshark_${TEST_NAME}.pcap        3   3   3
    #################### PM counters verification
    Verify PM counters 8140-JF prime gnb
    Verify PM counters 8140-JF ext gnb    hostname=10.42.234.104
    [Teardown]    delta.roll_delta_back    initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...           delta_scf_filename=delta_8140-JA-mainGNB.json
