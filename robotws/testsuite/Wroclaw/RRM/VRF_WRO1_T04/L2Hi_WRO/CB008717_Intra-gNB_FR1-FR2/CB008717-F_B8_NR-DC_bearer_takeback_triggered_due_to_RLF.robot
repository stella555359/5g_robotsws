*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

*** Variables ***
${TRAFFIC_DURATION_SEC_F_B8}=   30s
${server_cmd_options_tcp}=    -p 7070 -i 1 -B 10.0.2.1
${client_cmd_options_dl_tcp}=    -c 1.2.4.2 -p 7070 -M 1360 -i 1 -t 3600 -B 10.0.2.1 -w 50M
${iperf_service}=    iperf_service
${iperf_ue_service}=    iperf_ue_1_dl

*** Keywords ***
CB008717-F_B8_NR-DC_bearer_takeback_triggered_due_to_radio_link_failure_detected_by_gNB-DU_in_SCG-with_PDCP_data_retransmission
    Prepare Harq Errors And Register Nrdc Ue With DL And Ul Udp Traffic With A4
    Check Data Traffic After PSCell Addition
    Start L1l2bip Mirroring
    Trigger RLF For Scg And Except Bearer Takeback
    Check Data Traffic Before PSCell Addition
    Stop L1l2bip Mirroring
    Deactivate RLF testmode
    Send A4 Measurement
    Check Data Traffic After PSCell Addition
    #Check First Missing Count From L1L2 bip log

Start Dl Tcp Traffic
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150

Check First Missing Count From L1L2 bip log
     [Arguments]
     ...     ${merged_filename}=BIP_L1L2.pcap
     ...     ${BIP_LOG_PATH}=/home/ute/MN/UTE/robotws/results/l1l2bip/
     ...     ${filter}=((pdcp-nr.seq-num) && (pdcp-nr.direction == 1)) || (pdcp-nr.fmc)
    Setup wireshark for pdcp decoding in L1L2 bip
    Prepare BIP column for pdcp sn
    Set test variable  ${merged_filename_path}  ${BIP_LOG_PATH}${merged_filename}
    Convert BIP logs pcap to csv
    ...  pcap_path=${merged_filename_path}
    ...  filter=${filter}
    ...  dir_path=${BIP_LOG_PATH}
    ...  columns=@{BIP_columns_artime}
    ...  csv_log_name=BIP_filtered_fmc_and_rnti.csv
    Check If Next Tx Contains Fmc    bip_csv_fielpath=${BIP_LOG_PATH}

Prepare Testmode For Harq Errors
    Execute Egate Command    cmd=rlf_testmode_nr profile_id=6 num_stop_csi_report=1000 num_stop_dlharq_tx=2000

Trigger RLF For Scg And Except Bearer Takeback
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=rlf action=activate profile_id=6 cell_group=SCG

Deactivate RLF testmode
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=rlf action=deactivate profile_id=6 cell_group=SCG

Prepare Harq Errors And Register Nrdc Ue With DL And Ul Udp Traffic With A4
    Prepare Testmode For Harq Errors
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2
    Register Ue With Default Pdu Session
    Start Dl Tcp Traffic
    Check Data Traffic Before PSCell Addition
    Send A4 Measurement
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2

Check Data Traffic On Mcg
    Sleep    ${TRAFFIC_DURATION_SEC_F_B8}
    Verify Ue Throughput    ue_id=1    type=pdsch cell_group=MCG   expected_tput=22
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pdsch
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pdsch scell=1
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pusch

Check Data Traffic On Scg
    Verify Ue Throughput    ue_id=1    type=pdsch cell_group=SCG scell=1   expected_tput=80
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pdsch
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pdsch scell=1
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pusch

Check Data Traffic Before PSCell Addition
    Check Data Traffic On Mcg

Check Data Traffic After PSCell Addition
    Check Data Traffic On Mcg
    Check Data Traffic On Scg
