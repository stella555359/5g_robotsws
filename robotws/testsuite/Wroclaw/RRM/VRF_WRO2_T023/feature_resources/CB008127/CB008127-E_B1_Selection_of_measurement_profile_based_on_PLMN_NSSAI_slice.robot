*** Settings ***
Documentation
...  contact: Szymon Startek

Library     ute_ue
Library     ute_tshark


*** Variables ***
${NR_UE_CAPABILITY}                                         # Capability for UE used in test.
${CELL_ID_FOR_CALL}                                         # Global cell ID of NR cell used for call
${NR_DL_THROUGHPUT}                       50                # Throughput in Mbit/s generated on NR_UE during reestablishment procedure


*** Keywords ***
TC__CB008127-E_B1_Selection_of_measurement_profile_based_on_PLMN_NSSAI_slice
    Set Tags    CA-INTER_RAT    AUTHOR-krzysztof.mirecki@nokia.com    OWNER-krzysztof.mirecki@nokia.com
    ...         MAINTAINER-szymon.startek@nokia.com    PHASE-CRT   SW-SBTS24R1    FEATURE-CB008127   GROUP_IN_CHARGE-Pz_2_WRO_2

    Preconditions
    Step1: Start Wireshark Log And Attach UE
    Step2: Start Data Transfer
    Step3: Stop Data Transfer
    Step4: Tcpdump Verification


Preconditions
    ${nrbts_id}  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}
    Require UE  NR_UE  capabilities=${NR_UE_CAPABILITY}


Step1: Start Wireshark Log And Attach UE
    Log  \n*** Step1: Start Wireshark Log And Attach UE ***  console=True
    Set Test Variable  ${STARTED_TCPDUMP}  True
    Start Wireshark Log Collection For IWK Test  options=-i any port 38412 or port 38472 or port 29211
    ...                                          replace_enb=False  replace_gnb=False
    Prepare UE For Data Transfer  NR_UE  ${CELL_ID_FOR_CALL}  connection=gNB


Step2: Start Data Transfer
    Log  \n*** Step2: Start Data Transfer ***  console=True
    Start Data Transfer  NR_DL  NR_UE  dl  throughput=${NR_DL_THROUGHPUT} Mbits/sec  packet_size=1350  duration=100s  buffer=32M
    Sleep  5  reason=Wait to stabilize throughput
    Log  \n*** Throughput already stabilized ***  console=True


Step3: Stop Data Transfer
    Log  \n*** Step3: Stop Data Transfer ***  console=True
    ${tcpdump_path}  Stop Wireshark Log Collection For IWK Test
    Set Test Variable  ${STARTED_TCPDUMP}  False
    Set Test Variable  ${TCPDUMP_PATH}  ${tcpdump_path}
    Stop Data Transfer  NR_DL
    Detach UE  NR_UE
    Log  \n*** Stop Data Transfer and detach UE ***  console=True


Step4: Tcpdump Verification
    Log  \n*** Step4: Tcpdump Verification ***  console=True
    ${filter1}  Catenate  ((((((((((((nr-rrc.hysteresis == 6)) &&
    ...  (nr-rrc.eventId == 2)) && (nr-rrc.timeToTrigger == 7)) && (nr-rrc.eventId == 4)) &&
    ...  (nr-rrc.timeToTrigger == 6)) && (nr-rrc.hysteresis == 10)) && (nr-rrc.measTriggerQuantity.rsrp == 60))
    ...  && (nr-rrc.measTriggerQuantity.rsrp == 65)) && (nr-rrc.eventId == 1)) && (nr-rrc.hysteresis == 4))
    ...  && (nr-rrc.timeToTrigger == 11)) && (nr-rrc.measTriggerQuantity.rsrp == 67)
    ${filter2}  Catenate  ((((((((((nr-rrc.timeToTrigger == 3) && (nr-rrc.hysteresis == 8)) && (nr-rrc.measTriggerQuantity.rsrp == 65))
    ...  && (nr-rrc.measTriggerQuantity.rsrp == 60))) && (nr-rrc.eventId == 4)) && (nr-rrc.eventId == 2)) && (nr-rrc.hysteresis == 12))
    ...  && (nr-rrc.timeToTrigger == 12)) && (nr-rrc.measTriggerQuantityOffset.rsrp == 0)) && (f1ap.procedureCode == 7)
    Setup Tshark  interface=any  alias=tshark
    ${init_context_setup_request}  Get Packets Count
    ...  packet_filter=(((((ngap)&&(ngap.sD==d1:43:a5))&&(ngap.procedureCode==14))&&(ngap.sST==01))&&(e212.guami.mcc=="001"))&&(e212.guami.mnc=="01")
    ...  pcap_file_path=${TCPDUMP_PATH}  alias=tshark
    Should be True  ${init_context_setup_request}>${0}
    ...  msg=InitialContextSetupRequest was not performed correctly. Please check object NRMEASPR_MA_SA-1 and values for NSSAI and PLMN.
    Log To Console
    ...  Number of filtered packets:${init_context_setup_request}, which means InitialContextSetupRequest with proper NSSAI and PLMN was performed
    ${a2_a3_a5_intra_freq_measurements}  Get Packets Count
    ...  packet_filter=${filter1}
    ...  pcap_file_path=${TCPDUMP_PATH}  alias=tshark
    Should be True  ${a2_a3_a5_intra_freq_measurements}>${0}  msg=Proper configuration for intra freq events a2,a3,a5 is not present
    Log To Console
    ...  Number of filtered packets:${a2_a3_a5_intra_freq_measurements}, which means proper a2,a3,a5 intra-frequency configs are avaliable
    ${a3_a5_intra_freq_measurement_configs}  Get Packets Count
    ...  packet_filter=${filter2}
    ...  pcap_file_path=${TCPDUMP_PATH}  alias=tshark
    Should be True  ${a3_a5_intra_freq_measurement_configs}>${0}
    ...  msg=Proper configuration for inter freq events a3 and a5 is not present
    Log To Console
    ...  Number of filtered packets:${a3_a5_intra_freq_measurement_configs}, which means proper a3 and a5 inter-frequency configs are avaliable
    [Teardown]  Teardown Tshark  alias=tshark


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True  start_wireshark=False


TC Teardown
    Log  \n=== TC Teardown ===  console=True
    Run Keyword And Ignore Error  Stop Data Transfer  NR_DL
    Detach UE  NR_UE
    Run Keyword If  ${STARTED_TCPDUMP}  Stop Wireshark Log Collection For IWK Test
    IWK Test Teardown  local_enb_connection=False  single_bts=True  stop_wireshark=False
