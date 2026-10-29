*** Settings ***
Library     ta5g_commissioning

Documentation
...    This file contains general keywords used for activating mandatory parameters for testing.

*** Keywords ***
Disable 256qam Modulation
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/CB008717/delta_disable_actDl256Qam.json

Enable Latency Pm Counters
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_actLatencyPmCount.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_miNrPDCPCell.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_miNrPdcpLatNrpmqap.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_miNrHighRlcCell.json

Enable PMQAP Counters
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_sa_pmqap.json

Enable PMQAP Counters NSA
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_nsa_pmqap.json

Enable PMQAP Counters Both
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_both_pmqap.json

Enable PDCP Status Handling
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_enable_NRDRB-1-15_CNI-86916_PDCP_status_handling.json

Disable Uplane Ciphering
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Ciphering/delta_disable_uplane_ciphering.json

Enable X2 Measurments
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_enable_x2_measurments.json

Enable F1 Measurments
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_enable_f1_measurments.json

Enable Pdcp F1u And X2u Measurments
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_enable_PDCP_F1U_and_X2U_measurments.json

Enable Vonr And Rohc And Add Vonr Profiles
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_enable_VoNR.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_add_actEnhancedVoNR.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_add_VoNR_profiles.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_enable_rohc.json

Enable Vonr And Rohc
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_enable_VoNR.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_add_actEnhancedVoNR.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_enable_rohc.json

Enable Vonr And Rohc TDD FDD
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_enable_VoNR_TDD_FDD.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_add_actEnhancedVoNR_TDD_FDD.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_enable_rohc.json

Enable Vonr
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_enable_VoNR.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_add_actEnhancedVoNR.json

Enable Vonr For Second Cell
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_enable_VoNR_cell_2.json

Activate Intra Gnb Ho And A3 Meas
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_intra_gnb_ho_and_a3_meas.json

Activate Intra Gnb Ho And A3 Meas TDD FDD
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_intra_gnb_ho_and_a3_meas_TDD_FDD.json

Enable Tput Counters
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_tput_counter.json
    ssh.connect_to   hostname=192.168.255.129   username=toor4nsn   password=oZPS0POrRieRtu
    ssh.send command   reboot
    ssh.disconnect
    BuiltIn.Sleep    180s
    Wait for gNB Configured state

Disable Thresholds For Tput Counters
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_volThresDiscard_and_durationThresDiscard_set_to_0.json

Set Data Volume Threshold for DL and UL
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_volThresDiscardDL_set_to_100_and_volThresDiscardUL_set_to_10.json

Enable Carrier Aggregation With Blind Scell Activation
    ${cell_number}=    Check Cell List
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Carrier_Aggregation/delta_set_various_nrarfcn.json
    Sleep    180s
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Carrier_Aggregation/delta_add_NRREL_for_two_cells.json
    Run Keyword If    '${cell_number}'=='4'
    ...            Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Carrier_Aggregation/delta_enable_ca_Fr1Tdd_Nsa.json
    ...    ELSE    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Carrier_Aggregation/delta_enable_ca_Fr1Tdd_Nsa_for_two_cells.json

Enable 2CC Carrier Aggregation With Buffer Based Scell Activation
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Carrier_Aggregation/delta_add_NRREL_for_two_cells.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Carrier_Aggregation/delta_enable_ca_Fr1Tdd_Sa.json

Enable Split F1UX2U
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Split_Mode/delta_enable_F1UX2U.json

Enable Data Split Mode Over X2
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Split_Mode/delta_dlDataSplitMode_set_to_dlOverX2U.json

Enable Data Split Mode Over F1
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/Split_Mode/delta_dlDataSplitMode_set_to_dlOverF1U.json

Enable Pdcp And Rlc Counters Update At Qos Level
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_set_pdcpAndRlcCountersUpdateConf_QoS-Level.json

Enable Pdcp And Rlc Counters Update At NRPMQAP Level
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_set_pdcpAndRlcCountersUpdateConf_NRPMQAP-Level.json

Enable Inter Gnb Ho
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_xn_and_a5_activation.json