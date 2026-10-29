*** Settings ***
Documentation
...   author:  Wioleta Swies (wioleta.swies@nokia.com)
...   maintainers: Wioleta Swies
...   contact: Lubomir Krzeminski (lubomir.krzeminski@nokia.com)
...   contact: Adrianna Priotrkowska (adrianna.priotrkowska@nokia.com)
...   feature: CB012194 - FDD configurations with CPRI and OBSAI radio for ABIP/ABIQ #2
...
...   Introduction: CB011181 provides sets of FDD configuration blocks for CPRI and OBSAI RUs connected to ABIO/ABIN and ASOE.
...   Configuration blocks based on customer request and new RUs which has impact on customer's rollout.
...   The configuration block consists of BB cell set and RF cell set with a defined, proper fiber connections and cell allocation within SBTS.


Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/resources/robot/BtsConfiguration.robot
Resource    taf/rfrl/procedures/resources/robot/LogCollection.robot
#Resource    taf/rfrl/procedures/SISO/General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_Radio_Module_Lock_Unlock.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_power_reset.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_HWPTA_BTS_Template_Commissioning_Recommissioning.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_BTS_Site_Reset.robot
Resource    ./resources/keywords.robot
Resource    testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Library      ute_ue
Library      testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    sg7keywords
Library      testsuite/Krakow/SISO/regression/RAN_PZ_KRK7/CB011181/resources/CB011181_keywords.py    WITH NAME    CB011181_keywords

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup    Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
...                                                                 should_5G_neighbour_be_changed=${False}
...                                                                 increase_time_for_checking_bbmod=600
...                                                                 increase_timeout_for_update_sw=1800
...                                                                 increase_time_for_checking_radios=2100
...                                                                 increase_time_for_checking_cells=700
...                                                                 swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt

Suite Teardown    Common Suite Teardown

Test Setup       Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms


*** Variables ***
${UE_CAPABILITIES}                   QUECTEL_UE
${UE_TYPE}                           QUECTEL
${UE_DEFAULT_ALIAS_NAME}             UE
${DEFAULT_PACKET_SIZE}               1320
${DEFAULT_PROTOCOL}                  tcp
${DEFAULT_DEVIATION}                 25%
${expected_tput_NSA_DL}              300Mbits/sec
${expected_tput_NSA_UL}              90Mbits/sec
${expected_tput_SA_DL}               100Mbits/sec
${expected_tput_SA_UL}               35Mbits/sec
${DATA_TRANSFER_DEFAULT_DURATION}    120s
${PARALLEL_STREAM_DL}                4
${PARALLEL_STREAM_UL}                2

${ORIGIN_TAF_TL_CONFIG}              __init__.py
${LTE_DEFAULT_BAND}                  5
${NR5G_DEFAULT_BAND}                 7
${APN_SA_NAME}                       5gsakrk
${APN_NSA_NAME}                      5gkrk


*** Test Cases ***
CB011181_01_Manual_SiSo_CM_Recommissioning
    [Tags]    D4
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    BTS Reset Cause    AND
    ...                        Common Preconditions With Watching Alarms

    ${SCF_GNB_PATH}    sg7keywords.Get Default Scf Path    file_name=D4_NSA_SCF.xml
    ${MRBTS_ID}        sg7keywords.Get Mrbts Id
    Save current configuration                      file_name=initial_configuration.xml
    General_SiSo_HWPTA_BTS_Template_Commissioning_Recommissioning    scf_file_path=${SCF_GNB_PATH}
    ...                                                              online_change_param_name=actDlRbgRandomization
    ...                                                              online_change_param_value=enabled
    ...                                                              online_param_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-160
    ...                                                              reset_change_param_name=holdOverModeUsed
    ...                                                              reset_change_param_value=true
    ...                                                              reset_param_dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1


    Check data transfer via Quectel     throughput_DL=${expected_tput_NSA_DL}
    ...                                 throughput_UL=${expected_tput_NSA_UL}
    ...                                 prepare_config_for_NSA=${True}

CB011181_04_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Tags]    D4
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    BTS Reset Cause    AND
    ...                        Common Preconditions With Watching Alarms
    Reset Configuration on gNB
    Sleep    20s
    ${SCF_GNB_PATH}    sg7keywords.Get Default Scf Path    file_name=D4_NSA_SCF.xml
    Perform BTS Full Commissioning    scf_file=${SCF_GNB_PATH}
    ...                               timeout=400
    CB011181_keywords.Wait for Synchronization    60
    Wait For Onair On All Dus
    gnbcell.Wait For All Cells To Be Onair    timeout=600

    Check data transfer via Quectel     throughput_DL=${expected_tput_NSA_DL}
    ...                                 throughput_UL=${expected_tput_NSA_UL}
    ...                                 prepare_config_for_NSA=${True}

CB011181_20_Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]    D4
    Set TesT Variable    ${logs_path}    ${LOG_PATH}/${TEST_NAME}
    General_SiSo_Auto_Radio_Module_Lock_Unlock

    Check data transfer via Quectel     throughput_DL=${expected_tput_NSA_DL}
    ...                                 throughput_UL=${expected_tput_NSA_UL}
    ...                                 prepare_config_for_NSA=${True}

CB011181_09_Manual_SiSo_REC_Radio_Module_power_reset
    [Tags]    D4
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    No connection to unit
    ...                                                                         Transmission path failure    AND
    ...                        Common Preconditions With Watching Alarms
    Set test variable    @{mandatory_alarms}    10
    General SiSo Auto RF module power reset    mandatory_alarms=@{mandatory_alarms}

    Check data transfer via Quectel     throughput_DL=${expected_tput_NSA_DL}
    ...                                 throughput_UL=${expected_tput_NSA_UL}
    ...                                 prepare_config_for_NSA=${True}

CB011181_03_Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    D5
    [Setup]    Common Preconditions With Watching Alarms    custom_taf_tl_config=D5__init__.env
    Prepare Test Line Commissionings And Wait For OnAir    scf_name=D5_SA_SCF.xml

    General_SiSo_Auto_BTS_Site_Reset
    Check data transfer via Quectel    throughput_DL=${expected_tput_SA_DL}
    ...                                throughput_UL=${expected_tput_SA_UL}
    ...                                prepare_config_for_SA=${True}

#CB011181_05_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    [Tags]    D5
#    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    BTS Reset Cause    AND
#    ...                        Common Preconditions With Watching Alarms    custom_taf_tl_config=D5__init__.env
#    Set TesT Variable    ${logs_path}    ${LOG_PATH}/${TEST_NAME}
#    General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot

CB011181_13_General_SiSo_RAT_Block_Unblock_with_L3Call
    [Tags]    D5
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    RAT blocked    AND
    ...                        Common Preconditions With Watching Alarms    custom_taf_tl_config=D5__init__.env
    sg7keywords.Block RAT    NR
    CB011181_keywords.Wait for Synchronization    60
    sg7keywords.Unblock RAT    NR
    CB011181_keywords.Wait for Synchronization    60
    gnbcell.Wait For All Cells To Be Onair    timeout=300

    Check data transfer via Quectel    throughput_DL=${expected_tput_SA_DL}
    ...                                throughput_UL=${expected_tput_SA_UL}
    ...                                prepare_config_for_SA=${True}

CB011181_25_Robustness
    [Tags]    D5
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Transmission path failure    AND
    ...                        Common Preconditions With Watching Alarms    custom_taf_tl_config=D5__init__.env

    Set Test Variable    ${TEST_ITERATION}    10

    FOR    ${i}    IN RANGE    ${TEST_ITERATION}
        gnb_ru.Reset All Radio Units on gNB
        CB011181_keywords.Wait for Synchronization    10
        gnbcell.Wait For All Cells To Be Onair    timeout=1000

        Check data transfer via Quectel    throughput_DL=${expected_tput_SA_DL}
        ...                                throughput_UL=${expected_tput_SA_UL}
        ...                                prepare_config_for_SA=${True}
    END
