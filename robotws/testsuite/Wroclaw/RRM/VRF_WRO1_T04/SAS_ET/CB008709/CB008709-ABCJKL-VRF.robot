*** Settings ***
Documentation
...   author: Adrianna Pienkowska, Jacek Kozmic, Agata Sidlo
...   contact: adrianna.pienkowska@nokia.com, jacek.kozmic@nokia.com, agata.sidlo@nokia.com
...   description: Krakow Verification Engineering team testcases for CB008709 feature

Resource  testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Robot/common_slice_aware_scheduler.robot
Resource  resources/ET_common_keywords.robot
Resource  ../resources/common_configuration.robot
Library  testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/validate_target_share.py  WITH NAME  ts_v
Library  testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/dynamic_sas_delta.py
Library  testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/validation_bip.py  WITH NAME  validate__
Library  resources/ET_common_keywords.py

Variables        resources/variables.py

Suite Setup      Suite Setup Slicing
Test Teardown    Run Keywords    Send Configuration ID To Scout
    ...    AND    Test Teardown Slicing

*** Test Cases ***
CB008709-A-EC201_003_Slice_aware_uplink_scheduler_for_the_special_case_of_single_RG_per_UE_with_empty_RG_in_the_cell_TDD_SA_NSA
    [Setup]    Test Setup Slicing
    ...    tc=CB008709-A-EC201_003
    suite__.Set Running Testcases               A-EC201_003
    dynamic_sas_delta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR_TC}
    ...    sas_configuration_data=${SAS_DELTA_A_EC2_3}
    ...    test_delta=${DELTA_A_EC2}
    gnb__.Wait For All Radio Modules To Be Online
    logs__.Start Syscom Collection
    wts__.Wait For Environment Prepared For Wts Ready State
    ...    wts_config_filename=${TC003_A_WTS_CONFIG_VRF}
    ...    allow_first_reboot=${False}
    ...    wts_dir_path=/opt/iphy/latest
    ...    timeout=${60}
    ...    sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}

    logs__.Start Syslog Capture
    logs__.Start Bip Capture
    Perform 5G SA Attach
    ...    ue_ids=(1, 2)
    ...    slices=(7, 2)
    ...    cell=${CELL_1_ID}
    wts__.Modify Pdu Session    qos_to_add=${2}    ue_id=${2}
    wts__.Modify Pdu Session    qos_to_add=${3}    ue_id=${2}
    Start SA Traffic
    ...    ue_ids=(1, 2, 2, 2)
    ...    mbps=(120, 10, 10, 10)
    ...    qfi=(1, 1, 2, 3)
    Setup X2 Link And Wait For Mib Reception
    Perform 5G NSA Attach
    ...    ue_ids=(101, 102, 103, 104)
    ...    spids=(7, 71, 11, 100)
    ...    cell=${CELL_1_ID}
    ...    plmn=('311:489', '311:489', '313:491', '313:491')
    Start NSA Traffic
    ...    ue_ids=(101, 102, 103, 104)
    ...    mbps=(5, 10, 17, 40)
    logs__.Stop Syscom Collection
    logs__.Stop Bip Capture
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval

    Validate Target Shares    sas_delta=${SAS_DELTA_A_EC2_3}    tputs=(100, 100, 0, 100, 100)    cell=${CELL_1_ID}
    ${syscom_logs}    logs__.Get Logs From Logs Dict    SYSCOM    1
    validate__.Check Cellsetupreq Has Proper Values    ${syscom_logs}    ${SAS_DELTA_A_EC2_3}    ${CELL_1_ID}    ${1}
    validate__.Validate Resource Groups For Ues
    ...    pcap_file_path=${syscom_logs}
    ...    rgs_for_sa_ues=(5, (1, 1, 1))
    ...    rgs_for_nsa_ues=(1, 2, 2, 4)
    ...    direction=ul
    ...    cell_id=${CELL_1_ID}

    suite__.Set Tc Status To Passed             A-EC201_003

CB008709-B-B102_006_Slice_aware_downlink_scheduler_TDD
    [Setup]    Test Setup Slicing
    ...    tc=CB008709-B-B102
    suite__.Set Running Testcases               B-B102_006
    dynamic_sas_delta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR_TC}
    ...    sas_configuration_data=${SAS_DELTA_B_B1}
    ...    test_delta=${DELTA_B_B1}
    gnb__.Wait For All Radio Modules To Be Online
    logs__.Start Syscom Collection
    wts__.Wait For Environment Prepared For Wts Ready State
    ...    wts_config_filename=${TC006_B_WTS_CONFIG_VRF}
    ...    allow_first_reboot=${False}
    ...    wts_dir_path=/opt/iphy/latest
    ...    timeout=${60}
    ...    sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}

    logs__.Start Syslog Capture
    logs__.Start Bip Capture
    Perform 5G SA Attach
    ...    ue_ids=(1, 2, 3, 4)
    ...    slices=(1, 2, 3, 4)
    ...    cell=${CELL_1_ID}
    Start SA Traffic
    ...    ue_ids=(1, 2, 3, 4)
    ...    mbps=(600, 600, 600, 600)
    ...    direction=dl
    Setup X2 Link And Wait For Mib Reception
    Perform 5G NSA Attach
    ...    ue_ids=(101, 102, 103, 104)
    ...    spids=(7, 40, 2, 99)
    ...    cell=${CELL_1_ID}
    ...    plmn=('311:489', '312:490', '313:491', '314:492')
    Start NSA Traffic
    ...    ue_ids=(101, 102, 103, 104)
    ...    mbps=(600, 600, 600, 600)
    ...    direction=dl
    logs__.Stop Syscom Collection
    logs__.Stop Bip Capture
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval

    Validate Target Shares    sas_delta=${SAS_DELTA_B_B1}    traffic_dir=dl
    ${syscom_logs}    logs__.Get Logs From Logs Dict    SYSCOM    1
    validate__.Check Cellsetupreq Has Proper Values    ${syscom_logs}    ${SAS_DELTA_B_B1}    ${CELL_1_ID}
    validate__.Validate Resource Groups For Ues
    ...    pcap_file_path=${syscom_logs}
    ...    rgs_for_sa_ues=(1, 2, 3, 4)
    ...    rgs_for_nsa_ues=(5, 6, 7, 8)
    ...    direction=dl
    ...    cell_id=${CELL_1_ID}

    suite__.Set Tc Status To Passed             B-B102_006

CB008709-B-EC201_012_Slice_aware_downlink_scheduler_with_empty_RG_in_the_cell_TDD_low_buffer_RGs_TDD
    [Setup]    Test Setup Slicing
    ...    tc=CB008709-B-EC201
    suite__.Set Running Testcases               B-EC201_012
    dynamic_sas_delta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR_TC}
    ...    sas_configuration_data=${SAS_DELTA_B_EC2}
    ...    test_delta=${DELTA_B_EC2}
    gnb__.Wait For All Radio Modules To Be Online
    logs__.Start Syscom Collection
    wts__.Wait For Environment Prepared For Wts Ready State
    ...    wts_config_filename=${TC012_B_WTS_CONFIG_VRF}
    ...    allow_first_reboot=${False}
    ...    wts_dir_path=/opt/iphy/latest
    ...    timeout=${60}
    ...    sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}

    logs__.Start Syslog Capture
    logs__.Start Bip Capture
    Perform 5G SA Attach
    ...    ue_ids=(1, 2, 3)
    ...    slices=(1, 2, 3)
    ...    cell=${CELL_1_ID}
    Start SA Traffic
    ...    ue_ids=(1, 2, 3)
    ...    mbps=(1500, 211, 41)
    ...    direction=dl
    logs__.Stop Syscom Collection
    logs__.Stop Bip Capture
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval

    Validate Target Shares    sas_delta=${SAS_DELTA_B_EC2}    traffic_dir=dl    tputs=(100, 50, 10, 0)
    suite__.Set Tc Status To Passed             B-EC201_012

CB008709-C-EC201_014_Slice_aware_uplink_and_downlink_scheduler_interworking_FDD
    [Setup]    Test Setup Slicing
    ...    tc=CB008709-C-EC2
    suite__.Set Running Testcases               C-EC201_014
    dynamic_sas_delta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR_TC}
    ...    sas_configuration_data=${SAS_DELTA_C_EC2_3}
    ...    test_delta=${DELTA_C_EC2}
    gnb__.Wait For All Radio Modules To Be Online
    logs__.Start Syscom Collection
    wts__.Wait For Environment Prepared For Wts Ready State
    ...    wts_config_filename=${TC014_C_WTS_CONFIG_VRF}
    ...    allow_first_reboot=${False}
    ...    wts_dir_path=/opt/iphy/latest
    ...    timeout=${60}
    ...    sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}
    Wait To Avoid Catching Unwanted Initial Messages
    logs__.Start Syslog Capture
    logs__.Start Bip Capture
    Perform 5G SA Attach
    ...    ue_ids=(51, 52, 53)
    ...    slices=((4, 1), (2, 3, 4), 5)
    ...    pdus=((1, 2), (3, 4, 5), 6)
    ...    cell=${CELL_1_ID}
    common_wts.Modify Pdu Session    ue_id=51    pdu_id=2    qos_to_add=3
    common_wts.Modify Pdu Session    ue_id=52    pdu_id=5    qos_to_add=2
    Start SA Traffic
    ...    ue_ids=(51, 51, 51, 52, 52)
    ...    mbps=(22, 38, 90, 4, 11)
    ...    qfi=(1, 1, 2, 1, 2)
    ...    pdu=(1, 2, 2, 5, 5)
    Start SA Traffic
    ...    ue_ids=(51, 51, 52, 52, 52, 53)
    ...    mbps=(165, 34, 330, 245, 155, 403)
    ...    qfi=(1, 2, 1, 1, 2, 1)
    ...    pdu=(2, 2, 3, 5, 5, 6)
    ...    direction=dl

    Setup X2 Link And Wait For Mib Reception
    Perform 5G NSA Attach
    ...    ue_ids=(151, 152)
    ...    spids=(34, 130)
    ...    cell=${CELL_1_ID}
    ...    plmn=('311:489', '313:491')
    Start NSA Traffic
    ...    ue_ids=(151, 152)
    ...    mbps=(215, 2)
    Start NSA Traffic
    ...    ue_ids=(151, 152)
    ...    mbps=(60, 2)
    ...    direction=dl

    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    logs__.Stop Syscom Collection
    logs__.Stop Bip Capture

    Run Keyword And Ignore Error    Validate Target Shares    sas_delta=${SAS_DELTA_C_EC2_3}    tputs=(100, 14, 100, 0)
    Validate Target Shares    sas_delta=${SAS_DELTA_C_EC2_3}    tputs=(100, 8, 100, 100)    traffic_dir=dl
    ${syscom_logs}    logs__.Get Logs From Logs Dict    SYSCOM    1
    validate__.Check Cellsetupreq Has Proper Values    ${syscom_logs}    ${SAS_DELTA_C_EC2_3}    ${CELL_1_ID}
    validate__.Validate Resource Groups For Ues
    ...    pcap_file_path=${syscom_logs}
    ...    rgs_for_sa_ues=((3, 1, 1), (1, 2, 3, 3), 4)
    ...    rgs_for_nsa_ues=(3, 2)
    ...    direction=ul
    ...    cell_id=${CELL_1_ID}
    validate__.Validate Resource Groups For Ues
    ...    pcap_file_path=${syscom_logs}
    ...    rgs_for_sa_ues=((3, 1, 1), (1, 2, 3, 3), 4)
    ...    rgs_for_nsa_ues=(3, 2)
    ...    direction=dl
    ...    cell_id=${CELL_1_ID}
    suite__.Set Tc Status To Passed             C-EC201_014

CB008709-C-Robustness_035_UE_with_tput_alternating_between_two_RGs
    [Setup]    Test Setup Slicing
    ...    tc=CB008709-C-ROBUSTNESS
    ...    cell_technology=TDD
    suite__.Set Running Testcases               C-Robustness_035
    dynamic_sas_delta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR_TC}
    ...    sas_configuration_data=${SAS_DELTA_C_ROBUSTNESS}
    ...    test_delta=${DELTA_C_ROBUSTNESS}
    gnb__.Wait For All Radio Modules To Be Online
    logs__.Start Syscom Collection
    wts__.Wait For Environment Prepared For Wts Ready State
    ...    wts_config_filename=${TC035_C_WTS_CONFIG_VRF}
    ...    allow_first_reboot=${False}
    ...    wts_dir_path=/opt/iphy/latest
    ...    timeout=${60}
    ...    sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}

    logs__.Start Syslog Capture
    logs__.Start Bip Capture
    Perform 5G SA Attach
    ...    ue_ids=(1, )
    ...    slices=(3, )
    ...    cell=${CELL_1_ID}
    Start SA Traffic
    ...    ue_ids=(1, )
    ...    mbps=(175, )
    ...    qfi=(1, )
    Start SA Traffic
    ...    ue_ids=(1, )
    ...    mbps=(1100, )
    ...    qfi=(1, )
    ...    direction=dl
    Setup X2 Link And Wait For Mib Reception
    Perform 5G NSA Attach
    ...    ue_ids=(101, )
    ...    spids=(101, )
    ...    cell=${CELL_1_ID}
    ...    plmn=313:491
    Start NSA Traffic
    ...    ue_ids=(101, )
    ...    mbps=(60, )
    Start NSA Traffic
    ...    ue_ids=(101, )
    ...    mbps=(375, )
    ...    direction=dl
    Perform 5G SA Attach
    ...    ue_ids=(2, )
    ...    slices=((2, 3), )
    ...    pdus=((2, 3), )
    ...    cell=${CELL_1_ID}
    Alternate Traffic Between Pdus    ue_id=2    tput=50    pdus=(2, 3)    qfis=(1, 1)    duration=600
    logs__.Stop Syscom Collection
    logs__.Stop Bip Capture

    Validate Target Shares    sas_delta=${SAS_DELTA_C_ROBUSTNESS}    tputs=(100, 100)
    Validate Target Shares    sas_delta=${SAS_DELTA_C_ROBUSTNESS}    tputs=(100, 100)    traffic_dir=dl
    suite__.Set Tc Status To Passed             C-Robustness_035

CB008709-L-B101_032_Slice_aware_downlink_scheduler_TDD_SANSA_with_mixed_resources
    [Setup]    Test Setup Slicing
    ...    tc=CB008709-L-B101_032
    suite__.Set Running Testcases               L-B101_032
    dynamic_sas_delta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR_TC}
    ...    sas_configuration_data=${SAS_DELTA_L_032}
    ...    test_delta=${DELTA_L_B1}
    gnb__.Wait For All Radio Modules To Be Online
    logs__.Start Syscom Collection
    wts__.Wait For Environment Prepared For Wts Ready State
    ...    wts_config_filename=${TC032_L_WTS_CONFIG_VRF}
    ...    allow_first_reboot=${False}
    ...    wts_dir_path=/opt/iphy/latest
    ...    timeout=${60}
    ...    sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}

    logs__.Start Syslog Capture
    logs__.Start Bip Capture
    Perform 5G SA Attach
    ...    ue_ids=(1, 2, 3, 4, 5, 6)
    ...    slices=(1, 2, 3, 4, 5, 6)
    ...    cell=${CELL_1_ID}
    Start SA Traffic
    ...    ue_ids=(1, 2, 3, 4, 5, 6)
    ...    mbps=(175, 175, 350, 350, 350, 350)
    ...    direction=dl
    Setup X2 Link And Wait For Mib Reception
    Perform 5G NSA Attach
    ...    ue_ids=(101, 102, 103, 104, 105, 106)
    ...    spids=(3, 15, 20, 100, 255, 256)
    ...    cell=${CELL_1_ID}
    ...    plmn=('311:489', '312:490', '313:491', '314:492', '315:493', '316:494')
    Start NSA Traffic
    ...    ue_ids=(101, 102, 103, 104, 105, 106)
    ...    mbps=(175, 175, 175, 350, 350, 350)
    ...    direction=dl
    logs__.Stop Syscom Collection
    logs__.Stop Bip Capture
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval

    Validate Target Shares    sas_delta=${SAS_DELTA_L_032}    traffic_dir=dl
    suite__.Set Tc Status To Passed             L-B101_032

CB008709-K-B102_024_UL_SAS_online_deactivation_and_reactivation_FDD
    [Setup]    Test Setup Slicing
    ...    tc=CB008709-K-B102
    suite__.Set Running Testcases               K-B102_024
    dynamic_sas_delta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR_TC}
    ...    sas_configuration_data=${SAS_DELTA_K_B102}
    ...    test_delta=${DELTA_K_B102}
    gnb__.Wait For All Radio Modules To Be Online
    wts__.Wait For Environment Prepared For Wts Ready State
    ...    wts_config_filename=${WTS_K_B102_CONF}
    ...    allow_first_reboot=${False}
    ...    wts_dir_path=/opt/iphy/latest
    ...    timeout=${60}
    ...    sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}

    Perform 5G SA Attach
    ...    ue_ids=(51, 52)
    ...    slices=(1, 2)
    ...    cell=${CELL_1_ID}
    Start SA Traffic
    ...    ue_ids=(51, 52)
    ...    mbps=(300, 300)
    ...    direction=ul
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    Validate Target Shares    sas_delta=${SAS_DELTA_K_B102}    traffic_dir=ul

    dynamic_sas_delta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR_TC}
    ...    test_delta=${DELTA_K_B102_CHANGE}
    dynamic_sas_delta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR_TC}
    ...    test_delta=${DELTA_K_B102_CHANGE_2}
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    Validate Target Shares    sas_delta=${SAS_DELTA_K_B102}    traffic_dir=ul
    suite__.Set Tc Status To Passed             K-B102_024

CB008709-K-B103_025_UL_SAS_online_quotas_modification_TDD
    [Setup]    Test Setup Slicing
    ...    tc=CB008709-K-B103
    suite__.Set Running Testcases               K-B103_025
    dynamic_sas_delta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR_TC}
    ...    test_delta=${DELTA_K_B103}
    gnb__.Wait For All Radio Modules To Be Online
    wts__.Wait For Environment Prepared For Wts Ready State
    ...    wts_config_filename=${WTS_K_B103_CONF}
    ...    allow_first_reboot=${False}
    ...    wts_dir_path=/opt/iphy/latest
    ...    timeout=${60}
    ...    sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}
    Perform 5G SA Attach
    ...    ue_ids=(1, 2)
    ...    slices=(1, 2)
    ...    cell=${CELL_1_ID}
    Start SA Traffic
    ...    ue_ids=(1, 2)
    ...    mbps=(300, 300)
    ...    direction=ul
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    dynamic_sas_delta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR_TC}
    ...    test_delta=${DELTA_K_B103_CHANGE}
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    Validate Target Shares    sas_delta=${SAS_DELTA_K_B103}    tputs=(300, 300, 0, 0)    traffic_dir=ul
    suite__.Set Tc Status To Passed             K-B103_025

CB008709-K-B201_028_Slice_aware_downlink_scheduler_with_RG_configuration_change_via_online_modification_TDD_SA+NSA_with_CB008746
    [Setup]    Test Setup Slicing
    ...    tc=CB008709-K-B201
    suite__.Set Running Testcases               K-B201_028
    dynamic_sas_delta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR_TC}
    ...    test_delta=${DELTA_K_B201}
    gnb__.Wait For All Radio Modules To Be Online
    wts__.Wait For Environment Prepared For Wts Ready State
    ...    wts_config_filename=${WTS_K_B201_CONF}
    ...    allow_first_reboot=${False}
    ...    wts_dir_path=/opt/iphy/latest
    ...    timeout=${60}
    ...    sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}
    Perform 5G SA Attach
    ...    ue_ids=(1, 2)
    ...    slices=(1, 2)
    ...    cell=${CELL_1_ID}
    Start SA Traffic
    ...    ue_ids=(1, 2)
    ...    mbps=(216, 234)
    ...    direction=dl
    Setup X2 Link And Wait For Mib Reception
    Perform 5G NSA Attach
    ...    ue_ids=(101, 102)
    ...    spids=(1, 54)
    ...    cell=${CELL_1_ID}
    ...    plmn=('311:489', '312:490')
    Start NSA Traffic
    ...    ue_ids=(101, 102)
    ...    mbps=(216, 234)
    ...    direction=dl
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    Validate Target Shares    sas_delta=${SAS_DELTA_K_B201}    traffic_dir=dl   tputs=(216, 234, 0, 0)
    dynamic_sas_delta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR_TC}
    ...    test_delta=${DELTA_K_B201_FIRST_CHANGE}
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    Validate Target Shares    sas_delta=${SAS_DELTA_K_B201_FIRST_CHANGE}   traffic_dir=dl   tputs=(450, 0, 0, 0)
    ...                       rg_ids=(1, 3, 4, 5)    should_use_all_resources=${False}    check_prb_util_max=${False}
    dynamic_sas_delta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR_TC}
    ...    test_delta=${DELTA_K_B201_SECOND_CHANGE}
    Stop Traffic
    ...    ue_ids=(1, 2, 101, 102)
    Start SA Traffic
    ...    ue_ids=(1, 2)
    ...    mbps=(120, 120)
    ...    direction=dl
    Start NSA Traffic
    ...    ue_ids=(101, 102)
    ...    mbps=(120, 120)
    ...    direction=dl
    Perform 5G NSA Attach
    ...    ue_ids=(103, )
    ...    spids=(77, )
    ...    cell=${CELL_1_ID}
    ...    plmn=('311:489', )
    Start NSA Traffic
    ...    ue_ids=(103, )
    ...    mbps=(423, )
    ...    direction=dl
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    Validate Target Shares
    ...    sas_delta=${SAS_DELTA_K_B201_SECOND_CHANGE}
    ...    traffic_dir=dl   tputs=(216, 0, 0, 0, 423)
    ...    rg_ids=(1, 3, 4, 5, 6)
    ...    custom_expected_ts=${CUSTOM_RG_TS_028}
    suite__.Set Tc Status To Passed             K-B201_028

CB008709-J-EC301_022_Slice_aware_uplink_scheduler_interacts_with_handover_for_non-configured_RG_in_target_cell
    [Setup]    Test Setup Slicing
    ...    tc=CB008709-J-EC301
    ...    cell_technology=FDD
    suite__.Set Running Testcases               J-EC301_022
    dynamic_sas_delta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR_TC}
    ...    test_delta=${DELTA_J_EC301}
    gnb__.Reset Units And Wait For Radio Head Online
    logs__.Start Syslog Capture
    wts__.Wait For Environment Prepared For Wts Ready State
    ...    wts_config_filename=${WTS_J_EC301_CONF}
    ...    wts_dir_path=/opt/iphy/latest
    ...    allow_first_reboot=${False}
    logs__.Start Syscom Collection
    Perform 5G SA Attach
    ...    ue_ids=(51, 52, 53, 72, 71)
    ...    slices=(2, 4, 3, 2, 5)
    ...    cell=(${CELL_1_ID}, ${CELL_1_ID}, ${CELL_1_ID}, ${CELL_2_ID}, ${CELL_2_ID})
    wts__.Modify Pdu Session
    ...    qos_to_add=3
    ...    ue_id=71
    Start SA Traffic
    ...    ue_ids=(51, 52, 53, 72, 71, 71)
    ...    mbps=(40, 120, 175, 150, 25, 35)
    ...    qfi=(1, 1, 1, 1, 1, 2)
    ...    first_trf_id=(1, 1, 1, 1, 1, 2)
    logs__.Stop Syscom Collection
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    Validate Target Shares    sas_delta=${SAS_DELTA_J_EC301}    traffic_dir=ul    tputs=(0, 100, 100, 100)    cell=3
    Validate Target Shares    sas_delta=${SAS_DELTA_J_EC301}    traffic_dir=ul    tputs=(100, 100, 0)     cell=4
    wts__.Check Ue Thput Stats
    ...    ues_ids=51, 52, 53, 72, 71
    ...    type=pusch
    wts__.Trigger Inter Gnb Handover With Cfra
    ...    ue_id=52
    ...    phycell_id=${CELL_2_PCI}
    ...    pass_regexp=${HO_REGEX}
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    Validate Target Shares    sas_delta=${SAS_DELTA_J_EC301}    traffic_dir=ul    tputs=(0, 100, 100, 0)    cell=3
    Validate Target Shares    sas_delta=${SAS_DELTA_J_EC301}    traffic_dir=ul    tputs=(100, 100, 100)     cell=4
    wts__.Check Ue Thput Stats
    ...    ues_ids=51, 52, 53, 72, 71
    ...    type=pusch
    wts__.Trigger Inter Gnb Handover With Cfra
    ...    ue_id=52
    ...    phycell_id=${CELL_1_PCI}
    ...    pass_regexp=${HO_REGEX}
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    Validate Target Shares    sas_delta=${SAS_DELTA_J_EC301}    traffic_dir=ul    tputs=(0, 100, 100, 100)    cell=3
    Validate Target Shares    sas_delta=${SAS_DELTA_J_EC301}    traffic_dir=ul    tputs=(100, 100, 0)     cell=4
    wts__.Check Ue Thput Stats
    ...    ues_ids=51, 52, 53, 72, 71
    ...    type=pusch
    suite__.Set Tc Status To Passed             J-EC301_022
