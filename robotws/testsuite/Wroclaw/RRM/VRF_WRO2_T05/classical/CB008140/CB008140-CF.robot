*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com
...  Description: This feature introduces Carrier Aggregation between FDD carrier as PCell and up to 2 SCells,
...               FR1 TDD or FDD carriers.

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources/keywords.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py

*** Variables ***
${resource_path_8140-CD}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources
${labpcip}=                 10.44.72.183
${tes_emil}=                ${CURDIR}/resources/2640_emil.robot

*** Keywords ***
[1]CB008140-CF#B2A2_[F+F+T+T]_SCell_re-activation_for_inter-gNB_4CC_DL_CA_due_to_recovery_of_Xp-U_state_to_available
    [Documentation]  This user scenario describes SCell re-activation for inter-gNB 4CC DL CA due to Xp-U link recovery
    ...              to 'available' state 4CC (FDD-CPRI + FDD-CPRI + TDD-eCPRI + TDD-eCPRI)
#    Load scf for second NR    ${resource_path_8140-CD}    SCFs    scf_8140-CD-external.xml
#    coam.perform_delta_recommissioning    delta_file=${resource_path_8140-CD}/delta_8140-CD-mainGNB.json
#    ...    connection=cOAM
    Download Xn and F1 plugins
    Setup attenuators for T186
    Set initial attenuation for 8140-CD
    Set test variable  ${test_name}  CB008140-CF
    Start Tshark UDP monitoring
    Prepare and start new DCAP   bts_mplane=10.44.137.51   nrCells=NRCELL_R-1
    Attach UE    UE_1
    Sleep  5s
    Start New L1L2 Logs
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=330s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=330s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Sleep  20s
    ${before_delay_on_DL}         Get Average Throughput       DT_DL_SA
    ${before_delay_on_UL}         Get Average Throughput       DT_UL_SA
    Log to Console                ${before_delay_on_DL}
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Stop New L1L2 Logs And Download PCAP
    Prepare and start delay with RUDE tool
    Log to Console   Prepare and start delay with RUDE tool
    Sleep   35s
    ${delay_on_DL}         Get Average Throughput       DT_DL_SA
    ${delay_on_UL}         Get Average Throughput       DT_UL_SA
    Log to Console         ${delay_on_DL}
    Run keyword and ignore error    Stop Data Transfer     DT_UL_SA
    Run keyword and ignore error    Stop Data Transfer     DT_DL_SA
    Detach Ue     UE_1
    Set delay on RUDE      delay_value=5
    Attach UE     UE_1
    Sleep         5s
    Start Data Transfer    dt_name=DT_DL_SA2    ue_alias=UE_1    direction=dl    duration=300s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA2    ue_alias=UE_1    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Sleep                  100s
    ${delay_off_DL}        Get Average Throughput       DT_DL_SA2
    Log to Console         ${delay_off_DL}
    ${delay_off_UL}        Get Average Throughput       DT_UL_SA2
    Should be true         ${delay_off_DL}>=${delay_on_DL}
    Should be true         ${before_delay_on_DL}>=${delay_on_DL}
    Run keyword and ignore error    Stop Data Transfer     DT_UL_SA2
    Run keyword and ignore error    Stop Data Transfer     DT_DL_SA2
    Stop Tshark monitoring and download logs
    Verify CSI-RS for Channel Acquisition
    Log to Console    >CSI-RS Chanel Acquisition successful.<
    Verify JSON file from DCAP  expected_messages=${messages_8140_CF}
    Verify PM Counter 8140-CF
    Log to Console    >PM Counters gotten successfully.<
    [Teardown]    Run keyword
    ...    Run keyword and ignore error    Set delay on RUDE      delay_value=0
