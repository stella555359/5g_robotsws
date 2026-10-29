*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Mariusz Waczynski (mariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

*** Variables ***
${TRAFFIC_DURATION_SEC_I_B3}=   5m

*** Keywords ***
CB008717-I_B3_Initial_DL_Traffic_Routing_post_SCG_Addition_with_prior_DL_data_transmission
    Register Ue With Default Pdu Session
    Start Udp Traffic 150Mbps In DL
    Send A4 Measurement
    Recieved Data Packets Should Be Zero on Scg
    Increase DL Data Traffic To 450Mbps
    Check Data Traffic On Mcg And Scg Leg

Recieved Data Packets Should Be Zero on Scg
    Sleep    10s    Waiting for new packets
    Run Keyword And Continue On Failure    Check Number Of Received Packets    ue_id=1
    ...    pdu_id=1    qfi_id=1    packet_number=0
    ...    direction=dl    optional_params=dc_cell_group=scg

Check Data Traffic On Mcg And Scg Leg
    Sleep    ${TRAFFIC_DURATION_SEC_I_B3}
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pdsch
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pdsch scell=1
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=dl dc_cell_group=mcg
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=dl dc_cell_group=scg
    Execute Egate Command And Wait For Data    cmd=uec_stats id=1 enb=2 cell=1 type=cell_data_pdcp format=long
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
    ...    pdu_id=1    qfi_id=1
    ...    expected_throughput=450    unit=mbps    margin=0.2    direction=dl
    Run Keyword And Continue On Failure    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1
    ...    qfi_id=1    packet_loss=0
    ...    margin=0.0    direction=dl

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