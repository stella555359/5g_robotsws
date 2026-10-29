*** Settings ***
Documentation
...   contact: Magdalena Swierbutowicz

Library    ute_ue
Library    ute_tshark
Library    taf.config.scf
Library    taf.analyzer.pmcounter
Library    taf.collectors.core  WITH NAME  core
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Library    ta5g_pm_counters
Library    ute_fsmaccess
Resource   ../../resources/ca_IWK.robot
Resource   ../../resources/ca_INTER_RAT.robot
Library    nrpmqap_counter_checker/feature_keywords.py


*** Variables ***
${NSA_UE_CAPABILITY}            # LTE NSA UE capability
${NR_SA_UE_CAPABILITY}          # NR SA UE capability
${NR_CELL_NSA}                  # NR NSA global cell ID
${NR_CELL_SA}                   # NR SA global cell ID
${PATH_TO_NR_CELL}              # path to NR cell with qRxLevMin to change
${LTE_CELL_GLOBAL_ID}           # LTE anchor cell ID


*** Keywords ***
TC__CB008933_A_Support_NRPMQAP_profiles_initial_configuration
    Set Tags    CA-INTER_RAT    AUTHOR-magdalena.swierbutowicz@nokia.com    OWNER-mikolaj.kasian@nokia.com
    ...  MAINTAINER-igor.kleschenok@nokia.com    PHASE-CRT   SW-SBTS25R1    FEATURE-CB008933    GROUP_IN_CHARGE-WRO_2_Vrf

    Preconditions
    Step 1: Attach UE1 In NSA Mode
    Step 2: Start UL And DL Traffic For UE1
    Step 3: Trigger UE1 DC Release
    Step 4: Verify Tcpdump Logs
    Step 5: Verify Pm Counters Are Increased In Specific NRPMQAP For NSA
    Step 6: Register UE2 In SA Mode
    Step 7: Start UL And DL Traffic For UE2
    Step 8: Stop Traffic And Release UE2
    Step 9: Verify Pm Counters Are Increased In Specific NRPMQAP For SA


Preconditions
    Log  \n==== Preconditions ====  console=True

    ${global_nr_cell_id} =  Get NR Global Cell ID From NR Cell ID  ${NR_CELL_SA}
    Set Test Variable  ${NR_CELL_GLOBAL_ID}  ${global_nr_cell_id}
    Set Test Variable  ${WIRESHARK_NSA_RUNNING}  False
    Set Test Variable  ${WIRESHARK_SA_RUNNING}  False
    Change qRxLevMin Parameter  -22
    Require Ue  NSA_UE  ${NSA_UE_CAPABILITY}
    Require Ue  SA_UE  ${NR_SA_UE_CAPABILITY}
    Set Attenuation  GNB_CELL_22  0dB
    Set Attenuation  GNB_CELL_2  0dB
    Log  = Preconditions passed =  console=True


Change qRxLevMin Parameter
    [Arguments]  ${parameter_value}

    Perform Parameter Recommissioning  ${PATH_TO_NR_CELL}  qRxLevMin  update  ${parameter_value}  connection=gNB
    Wait Until Keyword Succeeds  1m  30s  _verify bts states for iwk test helper  alias=gNB


Step 1: Attach UE1 In NSA Mode
    Log  \n==== Step 1: Attach UE1 In NSA Mode ====  console=True

    ${waiting_time} =  ca_IWK.Count Measurement Period  ${GNB_OAM_IP}  5  delta=30
    Log To Console  Wait ${waiting_time}s till new period of counters is started
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started

    Set Test Variable  ${WIRESHARK_NSA_RUNNING}  True
    Start Wireshark Log Collection For IWK Test  options=-i any host ${GNB_OAM_IP} and not udp port 2152 -s 0 -W 1
    ...                                          replace_enb=False  replace_gnb=False  alias=tcpdump_NSA
    core.Set Suite Alias  alias=tcpdump_NSA

    Prepare UE For Data Transfer  NSA_UE  ${LTE_CELL_GLOBAL_ID}  connection=gNB  lte_cell=True


Step 2: Start UL And DL Traffic For UE1
    Log  \n==== Step 2: Start UL And DL Traffic For UE1 ====  console=True

    Log  Start DL data transfer in cell NR-${NR_CELL_NSA} on UE.  console=True
    Start Data Transfer  DT_DL  NSA_UE  dl  throughput=50 Mbits/sec  protocol=tcp  packet_size=1400
    ...  duration=60s  buffer=32M  apn=n26wro
    Log  Start UL data transfer in cell NR-${NR_CELL_NSA} on UE.  console=True
    Start Data Transfer  DT_UL  NSA_UE  ul  throughput=50 Mbits/sec  protocol=tcp  packet_size=1400
    ...  duration=60s  buffer=32M  apn=n26wro

    Sleep  15  reason=Wait for stabilize traffic


Step 3: Trigger UE1 DC Release
    Log  \n==== Step 3: Trigger UE1 DC Release ====  console=True

    Stop Data Transfer  DT_DL
    Stop Data Transfer  DT_UL
    Sleep  120  reason=Wait for Dual Connectivity Release by gNB due to user inactivity

    Detach Ue  NSA_UE  timeout=40
    Prepare UE For Data Transfer  NSA_UE  ${LTE_CELL_GLOBAL_ID}  connection=gNB  lte_cell=True
    Set Attenuation  GNB_CELL_22  40dB
    Sleep  15  reason=Wait for Dual Connectivity Release
    Set Attenuation  GNB_CELL_22  0dB
    Detach Ue  NSA_UE  timeout=40


Step 4: Verify Tcpdump Logs
    Log  \n==== Step 4: Verify Tcpdump Logs ====  console=True

    ${tcpdump_NSA_path} =  Stop Wireshark Log Collection For IWK Test
    ...  log_directory=${LOG_PATH}/pcap_logs/NSA  alias=tcpdump_NSA
    Set Test Variable  ${WIRESHARK_NSA_RUNNING}  False

    Setup Tshark  lo  alias=shark
    ${required_packet_number}  get_packets_count
    ...  packet_filter=(x2ap.SgNBReleaseRequired_element) && (x2ap.radioNetwork == 42)
    ...  pcap_file_path=${tcpdump_NSA_path}  alias=shark
    ${request_packet_number}  get_packets_count  packet_filter=(x2ap.SgNBReleaseRequest_element)
    ...  pcap_file_path=${tcpdump_NSA_path}  alias=shark
    Should Be True  ${required_packet_number} > 0  msg=SgNB Release Required is not sent
    Should Be True  ${request_packet_number} > 0  msg=SgNB Release Request is not sent

    [Teardown]  Teardown Tshark  alias=shark


Step 5: Verify Pm Counters Are Increased In Specific NRPMQAP For NSA
    Log  \n=== Step 5: Verify Pm Counters Are Increased In Specific NRPMQAP For NSA ===  console=True

    ${waiting_time} =  ca_IWK.Count Measurement Period  ${GNB_OAM_IP}  5  delta=60
    Log To Console  Wait ${waiting_time}s till new period of counters is started
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started

    ${pm_counter_file_nsa}=  Get Latest Unpacked Full Pm Counters File
    ${result}=  verify counters list increased

        ...    M55352C00001        3-22,42-60,64       >0            DL_PDCP_TIME_UE_TPUT_PMQAP
        ...    M55352C01001        3-22,42-60,64       >0            DL_PDCP_VOL_UE_TPUT_PMQAP

        ...    M55353C00001        3-22,42-60,64       >0            UL_RLC_VOL_UE_TPUT_PMQAP
        ...    M55353C01001        3-22,42-60,64       >0            UL_RLC_TIME_UE_TPUT_PMQAP

        ...    M55158C00009        4-23,45-64          >0            DL_RLC_SDU_PMQAP

        ...    M55356C00000        4-23,45-64          >0            ACC_UE_DL_DRB_DATA_PMQAP
        ...    M55356C00001        4-23,45-64          >0            ACC_UE_UL_DRB_DATA_PMQAP
        ...    M55356C00002        4-23,45-64          >0            MAX_UE_DL_DRB_DATA_PMQAP
        ...    M55356C00003        4-23,45-64          >0            MAX_UE_UL_DRB_DATA_PMQAP
        ...    M55363C00001        4-23,45-64          >0            DL_PRB_USED_DATA_PMQAP
        ...    M55363C00002        4-23,45-64          >0            UL_PRB_USED_DATA_PMQAP
        ...    M55363C00003        4-23,45-64          >0            DL_PRB_UTIL_SLOT_MAX_PMQAP
        ...    M55363C00004        4-23,45-64          >0            UL_PRB_UTIL_SLOT_MAX_PMQAP

        ...    M55160C00001        1-64                >0            AVE_NUMBER_OF_NSA_USERS_PMQAP
        ...    M55160C00002        1-64               ==300          AVE_NUM_NSA_USERS_DENOM_PMQAP
        ...    M55160C00003        1-64                >0            PEAK_NUMBER_OF_NSA_USERS_PMQAP

        ...    M55162C00001        1-64                >0            NX2CC_RAB_REL_ATT_MENB_PMQAP
        ...    M55162C00002        1-64                >0            NX2CC_RAB_REL_NORM_MENB_PMQAP
        ...    M55162C00004        1-64                >0            NX2CC_RAB_REL_ATT_SGNB_PMQAP
        ...    M55162C00005        1-64                >0            NX2CC_RAB_REL_NORM_SGNB_PMQAP
        ...    M55162C00007        1-64                >0            NX2CC_RAB_SETUP_ATT_PMQAP
        ...    M55162C00008        1-64                >0            NX2CC_RAB_SETUP_ACK_PMQAP
        ...    M55162C00009        1-64                >0            NX2CC_RAB_SETUP_SN_PMQAP

        ...    pm_counter_file=${pm_counter_file_nsa}
        ...    cell_id=${NR_CELL_NSA}

    Run Keyword If  not ${result}
        ...    Fail    msg=*HTML*<p style="color:red; font-size:16px; font-weight: bold;">Counters verification failed. Please check table </p>


Step 6: Register UE2 In SA Mode
    Log  \n==== Step 6: Register UE2 In SA Mode ====  console=True

    ${waiting_time} =  ca_IWK.Count Measurement Period  ${GNB_OAM_IP}  5  delta=60
    Log To Console  Wait ${waiting_time}s till new period of counters is started
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started

    Set Test Variable  ${WIRESHARK_SA_RUNNING}  True
    Start Wireshark Log Collection For IWK Test  options=-i any host ${GNB_OAM_IP} and not udp port 2152 -s 0 -W 1
    ...                                          replace_enb=False  replace_gnb=False  alias=tcpdump_SA
    core.Set Suite Alias  alias=tcpdump_SA

    Prepare UE For Data Transfer  SA_UE  ${NR_CELL_GLOBAL_ID}  connection=gNB


Step 7: Start UL And DL Traffic For UE2
    Log  \n=== Step 7: Start UL And DL Traffic For UE2 ===  console=True

    Log  Start NR DL data transfer in cell NR-${NR_CELL_SA} on UE.  console=True
    Start Data Transfer  DT_DL_SA  SA_UE  dl  throughput=50 Mbits/sec  protocol=tcp  packet_size=1400
    ...  duration=100s  buffer=32M
    Log  Start NR UL data transfer in cell NR-${NR_CELL_SA} on UE.  console=True
    Start Data Transfer  DT_UL_SA  SA_UE  ul  throughput=50 Mbits/sec  protocol=tcp  packet_size=1400
    ...  duration=100s  buffer=32M
    Sleep  60  reason=Wait for the counter values to increase

    Stop Wireshark Log Collection For IWK Test  log_directory=${LOG_PATH}/pcap_logs/SA  alias=tcpdump_SA
    Set Test Variable  ${WIRESHARK_SA_RUNNING}  False


Step 8: Stop Traffic And Release UE2
    Log  \n=== Step 8: Stop Traffic And Release UE2 ===  console=True

    Stop Data Transfer  DT_DL_SA
    Stop Data Transfer  DT_UL_SA

    Detach Ue  SA_UE  timeout=40


Step 9: Verify Pm Counters Are Increased In Specific NRPMQAP For SA
    Log  \n=== Step 9: Verify Pm Counters Are Increased In Specific NRPMQAP For SA ===  console=True

    ${waiting_time} =  ca_IWK.Count Measurement Period  ${GNB_OAM_IP}  5  delta=90
    Log To Console  Wait ${waiting_time}s till new period of counters is started
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started.

    ${pm_counter_file}=  Get Latest Unpacked Full Pm Counters File
    ${result}=  verify counters list increased

        ...    M55352C00001        3-22,42-60,64       >0            DL_PDCP_TIME_UE_TPUT_PMQAP
        ...    M55352C01001        3-22,42-60,64       >0            DL_PDCP_VOL_UE_TPUT_PMQAP

        ...    M55353C00001        3-22,42-60,64       >0            UL_RLC_VOL_UE_TPUT_PMQAP
        ...    M55353C01001        3-22,42-60,64       >0            UL_RLC_TIME_UE_TPUT_PMQAP

        ...    M55158C00009        4-23,45-64          >0            DL_RLC_SDU_PMQAP

        ...    M55356C00000        4-23,45-64          >0            ACC_UE_DL_DRB_DATA_PMQAP
        ...    M55356C00001        4-23,45-64          >0            ACC_UE_UL_DRB_DATA_PMQAP
        ...    M55356C00002        4-23,45-64          >0            MAX_UE_DL_DRB_DATA_PMQAP
        ...    M55356C00003        4-23,45-64          >0            MAX_UE_UL_DRB_DATA_PMQAP
        ...    M55363C00001        4-23,45-64          >0            DL_PRB_USED_DATA_PMQAP
        ...    M55363C00002        4-23,45-64          >0            UL_PRB_USED_DATA_PMQAP
        ...    M55363C00003        4-23,45-64          >0            DL_PRB_UTIL_SLOT_MAX_PMQAP
        ...    M55363C00004        4-23,45-64          >0            UL_PRB_UTIL_SLOT_MAX_PMQAP

        ...    M55161C00001        1-64                >0            AVE_NUMBER_OF_SA_RRC_PMQAP
        ...    M55161C00002        1-64               ==300          AVE_NUMB_OF_SA_RRC_DENOM_PMQAP
        ...    M55161C00003        1-64                >0            PEAK_NUMB_OF_SA_RRC_USER_PMQAP

        ...    M55163C00001        1-64                >0            NG_FLOW_SETUP_ATT_TOT_PMQAP
        ...    M55163C00002        1-64                >0            NG_FLOW_SETUP_SUCC_PMQAP
        ...    M55163C00003        1-64                >0            NG_FLOW_REL_PMQAP
        ...    M55163C00004        1-64                >0            NG_FLOW_REL_NORMAL_PMQAP

        ...    M55193C00001        1-64                >0            NG_FLOW_REL_NORMAL_PMQAP

        ...    pm_counter_file=${pm_counter_file}
        ...    cell_id=${NR_CELL_SA}

    Run Keyword If  not ${result}
        ...    Fail    msg=*HTML*<p style="color:red; font-size:16px; font-weight: bold;">Counters verification failed. Please check table </p>


TC Setup
    IWK Test Setup  start_wireshark=False  local_enb_connection=False  single_bts=True


TC Teardown
    Log  \n=== TC Teardown ===  console=True

    Change qRxLevMin Parameter  -60
    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Run Keyword If  ${WIRESHARK_SA_RUNNING}  Stop Wireshark Log Collection For IWK Test
    ...  log_directory=${LOG_PATH}/pcap_logs/SA  alias=tcpdump_SA
    Run Keyword If  ${WIRESHARK_NSA_RUNNING}  Stop Wireshark Log Collection For IWK Test
    ...  log_directory=${LOG_PATH}/pcap_logs/NSA  alias=tcpdump_NSA
    Detach Ue  NSA_UE
    Detach Ue  SA_UE
    IWK Test Teardown  stop_wireshark=False  delta_exists=False  local_enb_connection=False  single_bts=True
