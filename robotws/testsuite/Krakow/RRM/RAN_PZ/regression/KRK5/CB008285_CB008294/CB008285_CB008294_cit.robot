*** Settings ***
Documentation
...   Test suite for regression testing of CB008285 and CB008294
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource     taf/rfrl/bts/robot/common/gnb_cell.robot
Resource     ./resources/common_resources.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library      taf.ue                                                                     WITH NAME    ue
Library     ./resources/resources.py                                                    WITH NAME    local_resources
Variables    ./resources/common_variables.py
Variables    ./resources/call_procedure/call_tmp_vars.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               increase_timeout_for_update_sw=3600
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown


*** Variables ***
@{CellIDs}         NRCELL-251
@{All_cells}       251    252    253    254    255    256    257    258    259    260
${capabilities}    REAL_UE

*** Test Cases ***
################# CIT ################
CB008285_A_016_single_UE_TCP_Data_Transfer_FR2_Cell_L3_call_100M_64QAM_for_SA_mode_with_32_SSB_beam_2_CELLGROUP
    [Setup]    Actions before test
    Perform Full Commissioning and Wait for onAir    prefix_tag=${None}
    Call To Selected Cells      cell_list=${CellIDs}        deviation=5%        duration=120s      tc_name=CB008285_A_016
    [Teardown]    Actions after test


CB008285_A_011_5GC00742_successful_activate_FR2_Cell_for_SA_mode_with_mismatch_configuration_for_OSI_with_32_SSB_beam_2_CELLGROUP
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[A_011]
    Perform Full Commissioning and Wait for onAir    prefix_tag=${None}
    Enable OSI and create mismatch
    Wait Until Keyword Succeeds    300 sec    10 sec
    ...    Verify Alarm is Active on gNB    fault_name=Incorrect cell parameter configuration    fault_id=7516
    @{All_cells}=    gnbcell.Get All Cells Id
    FOR  ${cell}  IN  @{All_cells}
         Run Keyword If    '${cell}'=='251'
         ...    Run keyword    Verify Cell Statuses    cell_id=${cell}    availability_status=degraded
         ...    ELSE    Run keyword    Verify gNB Cell is onAir    cell_id=${cell}
    END
    Call To Selected Cells      cell_list=${CellIDs}        deviation=20%        duration=120s      tc_name=CB008285_A_011
    Disable OSI and remove mismatch
    Wait Until Keyword Succeeds    480 sec    30 sec
    ...    Verify Alarm is not Active on gNB    fault_name=Incorrect cell parameter configuration    fault_id=7516
    Wait Until Keyword Succeeds    300 sec    10 sec
    ...    gnbcell.Verify All Cells are OnAir
    [Teardown]    Actions after test


CB008285_B_013_CB006530_Successful_New_NIDD_Parameters_added_and_delete_in_FEATCADM_For_Proper_Role_based_User_modification
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[B_013]
    Perform Full Commissioning and Wait for onAir    prefix_tag=CB008285_B_013
    ${error}=    Run Keyword And Expect Error    *    Change sCellOnlyFr2Sa params
    Verify error slogan    reported_error=${error}
    Remove prevent list
    Change sCellOnlyFr2Sa params
    [Teardown]    Actions after test


CB008285-B_044_5GC000532_Codebook_based_2X2_MIMO_PUSCH_transmission_with_2DMRS_RANK2_counter_using_PRACH_B4
    [Setup]    Actions before test
    Perform Full Commissioning and Wait for onAir    prefix_tag=CB008285_B_044
    Check time to next PM period    time_buffer=${420}
    ${capture_file}=    Set Variable    F1AP.pcap
    ${additional_logs_dir}=    Create directory for additional logs
    Start_collect_backhaul_pcap    capture_file=${capture_file}    filter=sctp
    Call To Selected Cells      cell_list=${CellIDs}    deviation=15%        duration=120s      tc_name=CB008285_B_044
    Stop_collect_backhaul_pcap    capture_file=${capture_file}    log_dir=${additional_logs_dir}
    logger.log_info_to_console    Waiting for 15min PM period is finished
    gnb_counter.Wait for next PM period
    BuiltIn.Sleep    60s
    ${counters}=    Verify counters    test_case=CB008285_B_044
    Verify PMI    counters=${counters}
    [Teardown]    Actions after test


CB008294_A_B3_006_FR2_CA_for_SA_GNB-8CCDL_4CCUL_maxScell7DL3UL_contiguous_set_maxNumScellsDlFr2Sa_3_4_5_6_7_with_maxNumScellUL_3
    [Setup]    Actions before test
    Perform Full Commissioning and Wait for onAir    prefix_tag=CB008294_A_B3_006
    Call To Selected Cells      cell_list=${CellIDs}        deviation=13%        duration=60s      tc_name=CB008294_A_B3_006_1_1

    Act CA
    Check time to next PM period    time_buffer=${600}
    Call To Selected Cells      cell_list=${CellIDs}        deviation=5%        duration=120s      tc_name=CB008294_A_B3_006_7_3
    logger.log_info_to_console    Waiting for 15min PM period is finished
    gnb_counter.Wait for next PM period
    BuiltIn.Sleep    60s
    Verify counters    test_case=CB008294_A_B3_006_7_3

    Act CA 4CC DL 4CC UL
    Check time to next PM period    time_buffer=${600}
    Call To Selected Cells      cell_list=${CellIDs}        deviation=5%        duration=120s      tc_name=CB008294_A_B3_006_4_4
    logger.log_info_to_console    Waiting for 15min PM period is finished
    gnb_counter.Wait for next PM period
    BuiltIn.Sleep    60s
    Verify counters    test_case=CB008294_A_B3_006_4_4

    Act CA 8CC DL 4CC UL
    Check time to next PM period    time_buffer=${600}
    Call To Selected Cells      cell_list=${CellIDs}        deviation=5%        duration=120s      tc_name=CB008294_A_B3_006_8_4
    logger.log_info_to_console    Waiting for 15min PM period is finished
    gnb_counter.Wait for next PM period
    BuiltIn.Sleep    60s
    Verify counters    test_case=CB008294_A_B3_006_8_4
    [Teardown]    Actions after test


CB008285_B_007_5GC000733_Paging_for_SI_Modification_Multiple_Beam_with_CB006020_Enabled
    [Setup]    Actions before test        alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[CB008285_B_007]
    Perform Full Commissioning and Wait for onAir    prefix_tag=CB008285_B_007
    Trigger SI Modification Paging    cell=NRCELL-251
    Find pattern in syslog    pattern=handleSiModPagingInd SI Mod Ind Received    syslog_dir=/tmp/btslog2
    [Teardown]    Actions after test
