*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library           taf.sbts.oam.coam.admin  WITH NAME  admin
Library           ute_ue
Library           ute_tshark
Library           taf.collectors.syscomdump
Library           taf.ul.parser.pcap
Library           ../../resources/LuaHandling.py
Resource          ../../resources/ca_IWK.robot


*** Variables ***
${LTE_CELL_ID}                                 # ID of DSS LTE cell which will be tested
${PHYS_LTE_CELL_ID}                            # Physical ID of tested LTE cells (needed for syscomdump filters)
${NR_ID}                                       # NRBTS ID
${LTE_ID}                                      # MRBTS ID
${NR_CELL_ID}                                  # ID of DSS NR cell which will be tested
${NR_CALL_CELL_ID}                             # ID of NR DSS cell used for data transfer visible on UE
${SYSCOMDUMP_FILTER}      ${NONE}              # Filetr used during collecting syscomdump, e.g. -i any msg_id=='0x761b'. Default value: ${NONE}
${LTE_MSISDN}                                  # Number for volte call to dial (autoresponder)
${BLANKED_PUCCH}                               # Value for blankedPucch
${NR_EXPECTED_DL_TPUT_MBPS}                    # [Mbit/sec] Value of expected throughput in NR DSS cell and LTE anchor cell
${LTE_EXPECTED_DL_TPUT_MBPS}                   # [Mbit/sec] Value of expected throughput in LTE DSS cell
${LTE_UE_ALIAS}                                # Alias of the LTE UE
${NR_UE_ALIAS}                                 # Alias of the NR UE


*** Keywords ***
TC__CB005738_CB007738_DL_LTE_GBR_data_transfers_with_concurrent_NR_and_LTE_non_GBR_connections_20MHz


    Set Tags    CA-INTER_RAT    AUTHOR-przemyslaw.szmaj@nokia.com    OWNER-kamila.gmerek@nokia.com
    ...         MAINTAINER-oleksandr.kulieshov@nokia.com    PHASE-CRT   SW-SBTS22R2    FEATURE-CB007738
    ...         FEATURE-CB005738    GROUP_IN_CHARGE-RAN_Pz_WRO_3


    Preconditions
    Step 1: Start DL NR Call
    Step 2: Start DL LTE Call
    Step 3: Collect Syscomdump Without VoLTE
    Step 4: Analyze Syscomdump Without VoLTE
    Step 5: Start Syslog Collection
    Step 6: Start Voice Call
    Step 7: Collect Syscomdump With VoLTE
    Step 8: Analyze Syscomdump With VoLTE
    Step 9: Wait For CRM Message In Syslog
    Step 10: Stop DL LTE Call and NR Call
    Step 11: Stop Voice Call
    Step 12: Analyze Time Difference Of CRM Prints


Preconditions
    Log  ==== Preconditions ====  console=True
    Set Test Variable  ${VOICE_CALL_ONGOING}  False
    Set Test Variables For CB005860 Test Single BTS    alias=${CONNECTIVITY}
    Check Preconditions For CB005860 Test  superfast_active=True  blanked_pucch=${BLANKED_PUCCH}
    Set Test Variable  ${VOICE_CALL_ONGOING}  False
    Require UE  LTE_UE  ${LTE_UE_ALIAS}
    Require UE  NR_UE  ${NR_UE_ALIAS}
    Set BTS And Cell ID CRM String

    Log  = Preconditions passed =  console=True


Step 1: Start DL NR Call
    Log  \n==== Step 1: Start DL NR Call ====  console=True
    Prepare UE For Data Transfer  NR_UE  ${NR_CALL_CELL_ID}
    Start Data Transfer  NR_DT  NR_UE  dl  throughput=100 Mbits/sec  protocol=udp  packet_size=1400  duration=600s  buffer=32M  apn=${APN}


Step 2: Start DL LTE Call
    Log  \n==== Step 2: Start DL LTE Call ====  console=True
    Prepare UE For Data Transfer  LTE_UE  ${LTE_CELL_ID}
    Start Data Transfer  LTE_DT  LTE_UE  dl  throughput=100 Mbits/sec  protocol=udp  packet_size=1400  duration=600s  buffer=32M  apn=${APN}
    Log  \n==== Waiting to stabilize T-puts ====  console=True
    Sleep  30s  Reason=Wait for T-puts to stabilize


Step 3: Collect Syscomdump Without VoLTE
    Log  \n==== Step 3: Collect Syscomdump Without VoLTE ====  console=True
    Start Collecting Syscomdump  ${SYSCOMDUMP_FILTER}
    Sleep  10s  Reason=Wait for packets to be collected
    [Teardown]  Stop Collecting Syscomdump And Set Path  WITHOUT_VOLTE


Step 4: Analyze Syscomdump Without VoLTE
    Log  \n==== Step 4: Analyze Syscomdump Without VoLTE ====  console=True
    Check For Call Without VoLTE  ${SYSCOMDUMP_PATH_WITHOUT_VOLTE}


Step 5: Start Syslog Collection
    Log  \n==== Step 5: Start Syslog Collection ====  console=True

    ${savepoint} =  syslog.Capture savepoint    alias=master
    Sleep  10s  Reason=Wait for packets to be collected
    syslog.Collect from savepoint  savepoint=${savepoint}  destination_file=${LOG_PATH}/udp_logs_VOLTE  alias=master
    Log To Console  Syslog for VoLTE log analysis started.


Step 6: Start Voice Call
    Log  \n==== Step 6: Start Voice Call ====  console=True
    Set Test Variable  ${VOICE_CALL_ONGOING}  True
    Start Voice Call  VOLTE  LTE_UE  ${LTE_MSISDN}    1200s    100s
    Log  VoLTE voice call started!  console=True



Step 7: Collect Syscomdump With VoLTE
    Log  \n==== Step 7: Start Collect Syscomdump With VoLTE ====  console=True
    Start Collecting Syscomdump  ${SYSCOMDUMP_FILTER}
    Sleep  10s  Reason=Wait for packets to be collected
    [Teardown]  Stop Collecting Syscomdump And Set Path  WITH_VOLTE


Step 8: Analyze Syscomdump With VoLTE
    Log  \n==== Step 8: Analyze Syscomdump With VoLTE ====  console=True
    Check For Call With VoLTE  ${SYSCOMDUMP_PATH_WITH_VOLTE}


Step 9: Wait For CRM Message In Syslog
    Log  \n==== Step 9: Wait For CRM Message In Syslog ====  console=True
    Sleep  60s  Reason=Wait for CRM Message In Syslog
    ${release} =  Get Sw Release Name  connection=default
    ${release_matches_regex} =  Should Match Regexp  ${release}  SBTS(2[5-9]|[3-4]|[0-9])R\\d+$
    ${syslog_msg} =  Run Keyword If  ${release_matches_regex}    Run Keyword And Continue On Failure
    ...  Wait For Message In Syslog File
    ...  regexp=CRMexe.*CRM\\/${DSS_STRING}\\/(Init|A|Initial)\\s(\\[([0-9]+|,|:|\\s)+\\]){15,30}
    ...                                               timeout=30s
    ...                                               alias=master
    ...              ELSE                           Run Keyword And Continue On Failure  Wait For Message In Syslog File
    ...  regexp=CRMexe.*CRM\\/${DSS_STRING}\\/(Init|Alloc|Initial)\\s(\\[([0-9]+|,|:|\\s)+\\]){15,30}
    ...                                               timeout=30s
    ...                                               alias=master
    Set Test Variable  ${SYSLOG_MSG}  ${syslog_msg}


Step 10: Stop DL LTE Call and NR Call
    Log  \n==== Step 11: Stop DL LTE Call and NR Call ====  console=True
    ${lte_tput} =  Get Average Throughput  LTE_DT
    Log  === Tput LTE: ${lte_tput} ===  console=True
    ${nr_tput} =  Get Average Throughput  NR_DT
    Log  === Tput NR: ${nr_tput} ===  console=True
    Run Keyword And Continue On Failure
    ...  Verify Average Throughput With Deviation  NR_DT  ${NR_EXPECTED_DL_TPUT_MBPS} Mbits/sec  7%  60
    Run Keyword And Continue On Failure
    ...  Verify Average Throughput With Deviation  LTE_DT  ${LTE_EXPECTED_DL_TPUT_MBPS} Mbits/sec  7%  15

    Stop Datatransfer  NR_DT
    Stop Datatransfer  LTE_DT


Step 11: Stop Voice Call
    Log  \n==== Step 12: Stop Voice Call ====  console=True
    Stop Voice Call  VOLTE
    Set Test Variable  ${VOICE_CALL_ONGOING}  False
    Log  VoLTE voice call ended!  console=True


Step 12: Analyze Time Difference Of CRM Prints
    Log  \n==== Step 13: Analyze Time Difference Of CRM Prints ====  console=True
    ${percent} =  Analyze Time Difference Of CRM Prints  ${SYSLOG_MSG}
    Should Be True  ${percent} >= 1  msg=Percent of prints with time difference less or equal to 10ms is less than 1%.


Stop Collecting Syscomdump And Set Path
    [Arguments]  ${name}
    ${syscomdump_path} =  Stop Collecting Syscomdump
    Set Test Variable  ${SYSCOMDUMP_PATH_${name}}  ${syscomdump_path}


Set BTS And Cell ID CRM String
    ${_}  ${scf_crm} =  Save And Parse SCF  SCF_CRM

    ${nrbts_dist_name} =  Get DistName Attribute From SCF  ${scf_crm}  NRBTS  NRBTS
    ${nrbts_id} =  Fetch From Right  ${nrbts_dist_name}  -

    ${lnbts_dist_name} =  Get DistName Attribute From SCF  ${scf_crm}  LNBTS  LNBTS
    ${lnbts_id} =  Fetch From Right  ${lnbts_dist_name}  -

    ${enb_hex} =  Convert To Hex  ${lnbts_id}
    ${gnb_hex} =  Convert To Hex  ${nrbts_id}
    ${lte_lcr_id} =  Get Parameter Value From SCF  ${PARSED_SCF_ENB}  LNCEL  LNCEL-${LTE_CELL_ID}  /p[@name='lcrId']
    ...  dist_name_substring=True
    ${nr_lcr_id} =  Get Parameter Value From SCF  ${PARSED_SCF_GNB}  NRCELL  NRCELL-${NR_CELL_ID}  /p[@name='lcrId']
    ...  dist_name_substring=True
    ${lte_lcr_id_hex} =  Convert To Hex  ${lte_lcr_id}
    ${nr_lcr_id_hex} =  Convert To Hex  ${nr_lcr_id}
    ${dss_string} =  Set Variable  e${enb_hex}c${lte_lcr_id_hex}g${gnb_hex}c${nr_lcr_id_hex}
    Set Test Variable  ${DSS_STRING}  ${dss_string}


Check For Call With VoLTE
    [Arguments]  ${pcap_file}
    Log  Check For Call With VoLTE  console=True

    ${filter} =  Set Variable
    ...  xp_common_EndpointIdentifier_t.eNBCellId==${PHYS_LTE_CELL_ID} && xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad < 80
    ${packets_count} =  Get Packets Count  packet_filter=${filter}  pcap_file_path=${pcap_file}
    ${all_packets_count} =  Get Packets Count
    ...  packet_filter=xp_common_EndpointIdentifier_t.eNBCellId == ${PHYS_LTE_CELL_ID}  pcap_file_path=${pcap_file}
    ${percent} =  Evaluate  ${packets_count} / ${all_packets_count} * 100
    Run Keyword And Continue On Failure  Should Be True  ${percent} < 1
    ...  msg=The numbers of packets with xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad < 80 exceeded 1% for tested cell.

    ${filter} =  Catenate
    ...  xp_common_EndpointIdentifier_t.eNBCellId ==${PHYS_LTE_CELL_ID} && xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad > 100 &&
    ...  !(xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad == 255)
    Check Packets Count  ${filter}  ${pcap_file}  condition=== 0
    ...  msg=There were some packets with xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad > 100 for tested cell.

    ${filter} =  Set Variable
    ...  xp_common_EndpointIdentifier_t.eNBCellId==${PHYS_LTE_CELL_ID} && xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad==255
    ${packets_count} =  Get Packets Count  packet_filter=${filter}  pcap_file_path=${pcap_file}
    ${all_packets_count} =  Get Packets Count
    ...  packet_filter=xp_common_EndpointIdentifier_t.eNBCellId ==${PHYS_LTE_CELL_ID}  pcap_file_path=${pcap_file}
    ${percent} =  Evaluate  ${packets_count} / ${all_packets_count} * 100
    Run Keyword And Continue On Failure  Should Be True  ${percent} < 1
    ...  msg=The numbers of packets with xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad == 255 exceeded 1% for tested cell.
    Log  Condition:Percent of packets < 1\nNumber of packets: ${packets_count}  console=True

    ${filter} =  Catenate
    ...  xp_common_EndpointIdentifier_t.eNBCellId ==${PHYS_LTE_CELL_ID} && (xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad >= 90 ||
    ...  xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad <= 100)
    Check Packets Count  ${filter}  ${pcap_file}  condition=> 0
    ...  msg=There were none packets xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad in range <90;100> for tested cell.

    ${filter} =  Catenate
    ...  xp_common_EndpointIdentifier_t.eNBCellId ==${PHYS_LTE_CELL_ID} && xp_dss_EnDssUlQosLoadMeasurement.measuredGbrLoad &&
    ...  xp_dss_EnDssUlQosLoadMeasurement.measuredGbrLoad > 0
    Check Packets Count  ${filter}  ${pcap_file}  condition= >= 20
    ...  msg=There were less than 20 packets with xp_dss_EnDssUlQosLoadMeasurement.measuredGbrLoad > 0 for tested cell.

    ${filter} =  Catenate
    ...  xp_common_EndpointIdentifier_t.eNBCellId ==${PHYS_LTE_CELL_ID} && xp_dss_EnDssDlQosLoadMeasurement.measuredGbrLoad &&
    ...  xp_dss_EnDssDlQosLoadMeasurement.measuredGbrLoad > 0
    Check Packets Count  ${filter}  ${pcap_file}  condition= >= 20
    ...  msg=There were less than 20 packets with xp_dss_EnDssDlQosLoadMeasurement.measuredGbrLoad > 0 for tested cell.


Check For Call Without VoLTE
    [Arguments]  ${pcap_file}
    Log  Check For Call Without VoLTE  console=True

    ${filter} =  Set Variable
    ...  xp_common_EndpointIdentifier_t.eNBCellId==${PHYS_LTE_CELL_ID} && xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad < 80
    ${packets_count} =  Get Packets Count  packet_filter=${filter}  pcap_file_path=${pcap_file}
    ${all_packets_count} =  Get Packets Count
    ...  packet_filter=xp_common_EndpointIdentifier_t.eNBCellId ==${PHYS_LTE_CELL_ID}  pcap_file_path=${pcap_file}
    ${all_packets_count} =  Get Packets Count
    ...  packet_filter=xp_common_EndpointIdentifier_t.eNBCellId ==${PHYS_LTE_CELL_ID}  pcap_file_path=${pcap_file}
    ${percent} =  Evaluate  ${packets_count} / ${all_packets_count} * 100
    Run Keyword And Continue On Failure  Should Be True  ${percent} < 1
    ...  msg=The numbers of packets with xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad < 80 exceeded 1% for tested cell.

    ${filter} =  Catenate
    ...  xp_common_EndpointIdentifier_t.eNBCellId ==${PHYS_LTE_CELL_ID} && xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad > 100 &&
    ...  !(xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad == 255)
    Check Packets Count  ${filter}  ${pcap_file}  condition=== 0
    ...  msg=There were some packets with xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad > 100 for tested cell.

    ${filter} =  Set Variable
    ...  xp_common_EndpointIdentifier_t.eNBCellId==${PHYS_LTE_CELL_ID} && xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad==255
    ${packets_count} =  Get Packets Count  packet_filter=${filter}  pcap_file_path=${pcap_file}
    ${all_packets_count} =  Get Packets Count
    ...  packet_filter=xp_common_EndpointIdentifier_t.eNBCellId == ${PHYS_LTE_CELL_ID}  pcap_file_path=${pcap_file}
    ${percent} =  Evaluate  ${packets_count} / ${all_packets_count} * 100
    Run Keyword And Continue On Failure  Should Be True  ${percent} < 1
    ...  msg=The numbers of packets with xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad == 255 exceeded 1% for tested cell.
    Log  Condition:Percent of packets < 1\nNumber of packets: ${packets_count}  console=True

    ${filter} =  Catenate
    ...  xp_common_EndpointIdentifier_t.eNBCellId ==${PHYS_LTE_CELL_ID} && (xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad >= 90 ||
    ...  xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad <= 100)
    Check Packets Count  ${filter}  ${pcap_file}  condition=> 0
    ...  msg=There were none packets xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad in range <90;100> for tested cell.

    ${filter} =  Catenate
    ...  xp_common_EndpointIdentifier_t.eNBCellId ==${PHYS_LTE_CELL_ID} && xp_dss_EnDssUlQosLoadMeasurement.measuredGbrLoad &&
    ...  xp_dss_EnDssUlQosLoadMeasurement.measuredGbrLoad > 0
    ${packets_count} =  Get Packets Count  packet_filter=${filter}  pcap_file_path=${pcap_file}
    ${all_packets_count} =  Get Packets Count
    ...  packet_filter=xp_common_EndpointIdentifier_t.eNBCellId == ${PHYS_LTE_CELL_ID}  pcap_file_path=${pcap_file}
    ${percent} =  Evaluate  ${packets_count} / ${all_packets_count} * 100
    Run Keyword And Continue On Failure  Should Be True  ${percent} < 1
    ...  msg=The numbers of packets with xp_dss_EnDssUlQosLoadMeasurement.measuredGbrLoad > 0 exceeded 1% for tested cell.

    ${filter} =  Catenate
    ...  xp_common_EndpointIdentifier_t.eNBCellId ==${PHYS_LTE_CELL_ID} && xp_dss_EnDssUlQosLoadMeasurement.measuredGbrLoad &&
    ...  xp_dss_EnDssUlQosLoadMeasurement.measuredGbrLoad == 0
    Check Packets Count  ${filter}  ${pcap_file}  condition=> 0
    ...  msg=There were none packets with xp_dss_EnDssUlQosLoadMeasurement.measuredGbrLoad == 0 for tested cell.

    ${filter} =  Catenate
    ...  xp_common_EndpointIdentifier_t.eNBCellId == ${PHYS_LTE_CELL_ID} && xp_dss_EnDssDlQosLoadMeasurement.measuredGbrLoad &&
    ...  xp_dss_EnDssDlQosLoadMeasurement.measuredGbrLoad > 0
    ${packets_count} =  Get Packets Count  packet_filter=${filter}  pcap_file_path=${pcap_file}
    ${all_packets_count} =  Get Packets Count
    ...  packet_filter=xp_common_EndpointIdentifier_t.eNBCellId ==${PHYS_LTE_CELL_ID}  pcap_file_path=${pcap_file}
    ${percent} =  Evaluate  ${packets_count} / ${all_packets_count} * 100
    Run Keyword And Continue On Failure  Should Be True  ${percent} < 1
    ...  msg=The numbers of packets with xp_dss_EnDssDlQosLoadMeasurement.measuredGbrLoad > 0 exceeded 1% for tested cell.

    ${filter} =  Catenate
    ...  xp_common_EndpointIdentifier_t.eNBCellId ==${PHYS_LTE_CELL_ID} && xp_dss_EnDssDlQosLoadMeasurement.measuredGbrLoad &&
    ...  xp_dss_EnDssDlQosLoadMeasurement.measuredGbrLoad == 0
    Check Packets Count  ${filter}  ${pcap_file}  condition=> 0
    ...  msg=There were none packets with xp_dss_EnDssDlQosLoadMeasurement.measuredGbrLoad == 0 for tested cell.


Check Packets Count
    [Arguments]  ${filter}  ${pcap_file}  ${condition}  ${msg}
    ${packets_count} =  Get Packets Count  ${filter}  ${pcap_file}
    Run Keyword And Continue On Failure  Should Be True  ${packets_count} ${condition}
    ...  msg=${msg}
    Log  Condition:Number of packets ${condition}\nNumber of packets: ${packets_count}  console=True


TC Setup
    Inter RAT Test Setup
    Setup Tshark  interface=eth0


TC Teardown
    [Timeout]  1 hour
    Log  TC Teardown  console=True
    Stop Datatransfer  NR_DT
    Stop Datatransfer  LTE_DT
    Run Keyword If  ${VOICE_CALL_ONGOING}
    ...  Stop Voice Call  VOLTE
    Detach Ue  NR_UE  timeout=60
    Detach Ue  LTE_UE
    Teardown Tshark  interface=eth0
    Inter RAT Test Teardown
