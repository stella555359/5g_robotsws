*** Settings ***
Documentation
...  author: Jakub Migdalek
...  contact: jakub.migdalek@nokia.com
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000545/resources/keywords_545.robot

*** Variables ***
${tput_DL_bandwith}     35Mbits/sec
${tput_UL_bandwith}     15MBits/sec
${tput_deviation}       10%
${tput_duration}        450s
${Packet_Size}          1200
${start_cnt}            1
${stop_cnt}             42
${resource_path_545-B}        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000545/resources



*** Keywords ***
[1]Transform_Precoder_activation_64QAM_SA_UE
    [Documentation]  This user scenario describes gNB behavior when a RRC Connected UE,
    ...  which supports Transform Precoding, is re-configured between use of Transform Precoder
    ...  (DFT-S-OFDM) and CP-OFDM for DCI 0_1 transmissions. UE starts connection with CP OFDM,
    ...  send data in UL using 64QAM modulation. It means that MCS index must be from range 17-27 -
    ...  only 64QAM MCS table (38.214 Table 6.1.4.1-1) is supported with DFT-S-OFDM. Test is performed in SA mode
    ...  and 10MHz cell bandwidth..
	#Enabled Transform Precoder
    #Load scf for NR    ${resource_path_545-B}    SCFs    scf_545_tp.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_1}   value=90
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_3}   value=0
    Log to console  Attenuate set as 0
    # Prepare and start DCAP
    Run Keyword And Continue On Failure    Detach Ue  UE_2
    sleep  5s
    # Pcap collection
    Attach Ue   UE_2
    sleep  5s
    # Pcap log downlad
    ${UE_IP}    ute_ue.Get Ue Info   UE_2  IP
    ${CELL_ID}    ute_ue.Get Ue Info   UE_2  PCI
    Log to console   ${UE_IP}
    Log to console   ${CELL_ID}
	Starting UL UDP SA  30MBits/sec    200s
    ${start_tput_date}= 	Get Current Date   result_format=epoch
	Log to console  Starting Uplink
	Start New L1L2 Logs  suffix=_off
	Log to console  Gathering L1L2 log
    sleep  5s
    Stop New L1L2 Logs And Download PCAP  suffix=_off
    Log to console  Decreasing radio conditions
    Start New L1L2 Logs  suffix=_on
    Decreasing Radio Conditions To Activate Transform Precoder At First Cell  start_tput_date=${start_tput_date}
    Log to console   Bad conditions
	Log to console  Gathering L1L2 log
    sleep  5s
    Stop New L1L2 Logs And Download PCAP  suffix=_on
    # Stop DCAP trace and download logs
    Await Data Transfer Finish     DT_UL_SA
    Get Average Throughput         DT_UL_SA
    Log to console  Checking Transform Precoder on Into L1L2 log
    Check Transform Precoder on Into L1L2 log
    Log to console  Checking Transform Precoder off Into L1L2 log
    Check Transform Precoder off Into L1L2 log
    Log to console  Checking DCI Transform Precoder disabled
    Check DCI 0_1 for Transform Precoder disabled
    Log to console  Checking DCI Transform Precoder enabled
    Check DCI 0_1 for Transform Precoder enabled
    #
#
[1]Successul_SA_UE_handover_between_Transform_Precoder_capable_and_non-capable_cells
    [Documentation]  This user scenario describes gNB behavior when a RRC Connected UE,
    ...  which supports Transform Precoding, is successfully re-configured between use of Transform Precoder
    ...  (DFT-S-OFDM) and CP-OFDM for DCI 0_1 transmissions.
	...  When being handover from cell where feature is not supported to cell where the feature is active.
#	#Disabled Transform Precoder For First Cell, Enabled for second cell
    #Load scf for NR    ${resource_path_545-B}    SCFs    scf_545_ho.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_1}   value=0
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_3}   value=90
    Set attenuation and check  lines=${lines_LTE_185}   value=90
    # Prepare and start DCAP
    Log to console  Attenuate set as 0 on first cell
    Run Keyword And Continue On Failure    Detach Ue  UE_2
    # Set Transform Precoder feature 545 at PCI 258   False
    sleep  5s
    Pcap collection
    Attach Ue   UE_2
    sleep  5s
    Pcap log downlad
    ${UE_IP}    ute_ue.Get Ue Info   UE_2  IP
    ${CELL_ID}    ute_ue.Get Ue Info   UE_2  PCI
    Log to console   ${UE_IP}
    Log to console   ${CELL_ID}
	Starting UL UDP SA  150MBits/sec    230s
    ${start_tput_date}= 	Get Current Date   result_format=epoch
	Log to console  Starting Uplink
	Start New L1L2 Logs  suffix=_on
	Log to console  Gathering L1L2 log
    Log to console  Decreasing radio conditions at first cell and handover
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_3}   value=0
    sleep  3s
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_1}   value=4
    sleep  3s
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_1}   value=5
    Sleep  3s
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_1}   value=15
    Sleep  3s
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_1}   value=25
    sleep  3s
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_1}   value=30
    Sleep  3s
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_1}   value=40
    sleep  3s
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_1}   value=65
    Sleep  3s
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_1}   value=90
    ${CELL_ID_before_HO}    ute_ue.Get Ue Info   UE_2  PCI
    Log to console   ${CELL_ID_before_HO}
    Decreasing Radio Conditions To Activate Transform Precoder At Third Cell  start_tput_date=${start_tput_date}
    Log to console  Bad conditions
    Stop syslog collection
    sleep  45s
	Log to console  Downloading L1L2 log
	Stop New L1L2 Logs And Download PCAP    suffix=_on
    # Stop DCAP trace and download logs
    Get Average Throughput       DT_UL_SA
    Log to console  Checking if handover success
    Should Not Be Equal As Strings  ${CELL_ID}   ${CELL_ID_before_HO}
    Check intra-gnb-Handover success
    Log to console  Checking Transform Precoder Into L1L2 log
    Check Transform Precoder on Into L1L2 log
    # Set Transform Precoder feature 545 at PCI 258   True


[1]Dynamic Transform Precoder Switching_NSA_UE_DCI_0_1_ 20MHz_SRB3_TCP_Open_Loop_MIMO
    [Documentation]  This user scenario describes gNB behavior when a RRC Connected UE,
    ...  which supports Transform Precoding, is re-configured between use of Transform Precoder
    ...  (DFT-S-OFDM) and CP-OFDM for DCI 0_1 transmissions. UE starts connection with CP OFDM,
    ...  send data in UL using 64QAM modulation. It means that MCS index must be from range 17-27 -
    ...  only 64QAM MCS table (38.214 Table 6.1.4.1-1) is supported with DFT-S-OFDM. Test is performed in SA mode
    ...  and 10MHz cell bandwidth..
    Set chbw for PCI 158   chBwDl=20MHz   chBwUl=20MHz
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_1}   value=90
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_2}   value=0
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_3}   value=90
    Set attenuation and check  lines=${lines_LTE_185}   value=0
    Log to console  Attenuate set as 0
    # Prepare and start DCAP
    # Run Keyword And Continue On Failure    Detach Ue  UE_3
    sleep  5s
    # Pcap collection
    Attach Ue   UE_3
    sleep  5s
    # Pcap log downlad
    ${UE_IP}    ute_ue.Get Ue Info   UE_3  IP
    ${CELL_ID}    ute_ue.Get Ue Info   UE_3  PCI
    Log to console   ${UE_IP}
    Log to console   ${CELL_ID}
	Start Data Transfer  dt_name=DT_UL_SA  ue_alias=UE_3  direction=ul  duration=200s
    ...                  throughput=30MBits/sec    packet_size=1300
    ${start_tput_date}= 	Get Current Date   result_format=epoch
    sleep  15s
	Log to console  Starting Uplink
    Start New L1L2 Logs  suffix=_on
	Log to console  Gathering L1L2 log
    Log to console  Decreasing radio conditions
    Decreasing Radio Conditions To Activate Transform Precoder At Cell    start_tput_date=${start_tput_date}
    Log to console   Bad conditions
    Stop New L1L2 Logs And Download PCAP  suffix=_on
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_2}   value=0
    sleep  5
	Start New L1L2 Logs  suffix=_off
	Log to console  Gathering L1L2 log
    sleep  5s
    Stop New L1L2 Logs And Download PCAP  suffix=_off
    # Stop DCAP trace and download logs
    Await Data Transfer Finish     DT_UL_SA
    Get Average Throughput         DT_UL_SA
    Log to console  Checking Transform Precoder on Into L1L2 log
    Check Transform Precoder on Into L1L2 log
    Log to console  Checking Transform Precoder off Into L1L2 log
    Check Transform Precoder off Into L1L2 log
    Log to console  Checking DCI Transform Precoder disabled
    Check DCI 0_1 for Transform Precoder disabled 20MHz
    Log to console  Checking DCI Transform Precoder enabled
    Check DCI 0_1 for Transform Precoder enabled 20MHz
    [Teardown]  Set chbw for PCI 158   chBwDl=15MHz   chBwUl=15MHz
