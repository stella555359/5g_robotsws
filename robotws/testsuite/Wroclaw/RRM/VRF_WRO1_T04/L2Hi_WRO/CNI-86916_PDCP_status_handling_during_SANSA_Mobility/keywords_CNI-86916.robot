*** Settings ***
Library    keywords_CNI-86916.py
Resource    ../resources/logs_collection.robot

Documentation
...    This file contains general keywords used for testing Feature CNI-86916.

*** Keywords ***
Enable NSA HO
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_intra_gnb_ho_and_a3_meas.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_NSA_mobility.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_IntraMeNBMobility.json

Wait For X2 Setup
    Sleep    60s

Attach NSA Ue And Start Gnb Addition
    Execute Egate Command    cmd=ue_param id=${UE_DC_ID} ue_nr_capabilities=${UE_NR_CAPA}
    Attach Ue To Enb    ue_id=${UE_DC_ID}
    Start Gnb Addition Procedure    ue=${UE_DC_ID}    bearer=${SCG_BEARER_ID}    target_cells=1    dc_type=split_scg
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${SGNB_RECONFIG_COMPLETE}

Display Bearer Traffic NSA
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=${UE_DC_ID} id=2 dir=dl dc_cell_group=scg

Check First Missing Count From L1L2 bip log
     [Arguments]
     ...     ${merged_filename}=BIP_L1L2.pcap
     ...     ${BIP_LOG_PATH}=/home/ute/results/l1l2bip/
     ...     ${filter}=((pdcp-nr.seq-num) && (pdcp-nr.direction == 1)) || (pdcp-nr.fmc)
     ...     ${csv_log_name}=BIP_filtered_fmc_and_rnti.csv
    Setup wireshark for pdcp decoding in L1L2 bip
    Prepare BIP column for pdcp sn
    Set test variable  ${merged_filename_path}  ${BIP_LOG_PATH}${merged_filename}
    Convert BIP logs pcap to csv
    ...  pcap_path=${merged_filename_path}
    ...  filter=${filter}
    ...  dir_path=${BIP_LOG_PATH}
    ...  columns=@{BIP_columns_artime}
    ...  csv_log_name=${csv_log_name}
    Check If Next Tx Contains Fmc    bip_csv_filepath=${BIP_LOG_PATH}${csv_log_name}
