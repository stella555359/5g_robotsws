*** Settings ***
Documentation    CA Feature CB009198 Automation.
...              Author: jun.8.chen@nokia-sbell.com
Suite Setup    9198_Suite_Setup
Test Teardown    9198_Case_Teardown
Suite Teardown    robot_common_operations.Common Suite Teardown
Force Tags    5G_RRM    SG_06    master_classicalbts_all
...    PY39
Resource    Resources/CB009198_common_keywords.robot
Variables    Resources/TestData.py
Variables    Resources/TestCaseVariables.py


*** Test Cases ***
#[1]CB009198_A_B1_DFT-s-OFDM_for_PUSCH_Feature_Activation
#    [Tags]    SA    CB009198    20M    CRT_TRUNK
#    [Setup]    9198_Case_Setup    mode=SA
#    Initial PA Value Setting For Required RU    gnb_id=${RUNNING_GNB_ID}
#    ...                                         all_ru_need_to_modify=${False}
#    ...                                         pa_off_value=26
#    Procedures.Update actUlDftSOfdm And puschMappingType    actUlDftSOfdm_value=false
#    Procedures.Basic Attach L3 Call Test    mode=SA
#    ...                                     gnb_index=${RUNNING_GNB_ID}
#    ...                                     dl_data_transfer=500M
#    ...                                     ul_data_transfer=50M
#    ...                                     check_pcell_tput_type=not_peak
#    ...                                     wireshark_check_point=${False}
#    Procedures.Stop Traffic And Detach
#    Procedures.Update actUlDftSOfdm And puschMappingType    actUlDftSOfdm_value=true
#    Procedures.Basic Attach L3 Call Test    mode=SA
#    ...                                     gnb_index=${RUNNING_GNB_ID}
#    ...                                     dl_data_transfer=500M
#    ...                                     ul_data_transfer=50M
#    ...                                     check_pcell_tput_type=not_peak
#    ...                                     wireshark_check_point=${False}

#[1]CB009198_B_B1_Interaction_between_256QAM_and_FR1_DFT-s-OFDM_for_TDD_PUSCH
#    [Tags]    SA    CB009198    40M    CRT_TRUNK
#    [Setup]    9198_Case_Setup    mode=SA
#    Procedures.Basic Attach L3 Call Test    mode=SA
#    ...                                     gnb_index=${RUNNING_GNB_ID}
#    ...                                     dl_data_transfer=800M
#    ...                                     ul_data_transfer=100M
#    ...                                     check_pcell_tput_type=not_peak
#    ...                                     check_ul_pcell_tput_type=not_peak
##    ...                                     is_vonr_call_needed=${True}

#[1]CB009198_B_B2_Interaction_between_256QAM_and_FR1_DFT-s-OFDM_for_TDD_PUSCH_NSA
#    [Tags]    NSA    CB009198    60M    CRT_TRUNK
#    [Setup]    9198_Case_Setup    mode=NSA
#    Procedures.Basic Attach L3 Call Test    mode=NSA
#    ...                                     gnb_index=${RUNNING_GNB_ID}
#    ...                                     dl_data_transfer=1000M
#    ...                                     ul_data_transfer=100M
#    ...                                     check_pcell_tput_type=not_peak
#    ...                                     check_ul_pcell_tput_type=not_peak

#[1]CB009198_B_B3_PUSCH_mapping_type_A_co-existence_with_DFT-s-OFDM_with_PTRS_fo_ ABIL_TDD
#    [Tags]    SA    CB009198    80M    CRT_TRUNK
#    [Setup]    9198_Case_Setup    mode=SA
#    Procedures.Update actUlDftSOfdm And puschMappingType    type_value=TypeA
#    Procedures.Basic Attach L3 Call Test    mode=SA
#    ...                                     gnb_index=${RUNNING_GNB_ID}
#    ...                                     dl_data_transfer=1300M
#    ...                                     ul_data_transfer=150M
#    ...                                     check_pcell_tput_type=not_peak
#    ...                                     check_ul_pcell_tput_type=not_peak
#    ...                                     mappingtype=typeA
#    ...                                     whether_check_ptrs=${True}

[1]CB009198_B_B4_PUSCH_mapping_type_A_co-existence_with_DFT-s-OFDM_fo_ ABIL_TDD_no_PTRS
    [Tags]    SA    CB009198    100M    CRT_TRUNK
    [Setup]    9198_Case_Setup
    Procedures.Basic Attach L3 Call Test    mode=SA
    ...                                     gnb_index=${RUNNING_GNB_ID}
    ...                                     dl_data_transfer=1500M
    ...                                     ul_data_transfer=200M
    ...                                     check_pcell_tput_type=not_peak
    ...                                     check_ul_pcell_tput_type=not_peak
    ...                                     mappingtype=typeA
    ...                                     whether_check_ptrs=${True}
    ...                                     ptrs=no_ptrs
    ...                                     is_vonr_call_needed=${False}
    Start To Check L1L2 Error Info From Syslog
