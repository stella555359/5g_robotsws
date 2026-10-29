*** Settings ***
Documentation
...   author: Wioleta Swies, Jakub Bialon, Michal Chrzanowski
...   contact: wioleta.swies@nokia.com, jakub.bialon@nokia.com, michal.a.chrzawnowski@nokia.com
...   CB007524-5G-A

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/enb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/resources/robot/BtsConfiguration.robot
Resource    testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Library     BuiltIn
Library     testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py   WITH NAME   keywords_SG07
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations
Library     taf.rfrl.bts.devices.asir.generic_asir.GenericAsirHub   WITH NAME   asirAdmin
Library     taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations   WITH NAME   gnb_asir

Library     ute_ue

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup      Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
...                                                                   should_5G_neighbour_be_changed=${False}
...                                                                   increase_time_for_checking_bbmod=600
...                                                                   increase_timeout_for_update_sw=1800
...                                                                   increase_time_for_checking_radios=2100
...                                                                   increase_time_for_checking_cells=700
...                                                                   list_of_additional_allowed_alarms=@{ADDITIONAL_ALLOWED_ALRAMS}
...                                                                   swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt

Suite Teardown    Common Suite Teardown
Test Setup       Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms

*** Variables ***
#--------------------------UE--------------------------
${UE_CAPABILITIES}    QUECTEL_UE
${UE_DEFAULT_ALIAS_NAME}    UE
${DATA_TRANSFER_DEFAULT_DURATION}    100s
${DEFAULT_PACKET_SIZE}    1380
${DEFAULT_PROTOCOL}    tcp
${DEFAULT_DEVIATION}    20%
${linux_congestion}    reno

@{ADDITIONAL_ALLOWED_ALRAMS}   Create List    Failure detected on assigned antennas

*** Test Cases ***
[1]CB007524-5G-A_TC40_2CPRI_3sHUB_6cell_100MHz_50MHz_4T4R_IQC_SA
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Cell blocked    AND
    ...                        Common Preconditions With Watching Alarms
    @{impact_cell}    Create List    155    255    555    355    655
    keywords_SG07.Block Cells    cell_list=${impact_cell}

    # Data transfer values
    Set Test Variable    ${expected_tput_NR_DL}    650Mbits/sec
    Set Test Variable    ${expected_tput_NR_UL}    90Mbits/sec

    Check data transfer with Quectel    throughput_DL=${expected_tput_NR_DL}
    ...                                 throughput_UL=${expected_tput_NR_UL}
    ...                                 parallel_streams_UL=8
    ...                                 linux_congestion=${linux_congestion}

    [Teardown]   Run Keywords    keywords_SG07.Unblock Cells    cell_list=${impact_cell}    AND
    ...                          Wait Until Keyword Succeeds    600 sec    5 sec   Verify Setup Of All Cells
    ...                          AND    Common Postconditions With Watching Alarms

[1]CB007524-5G-A_TC02_2CPRI_3sHUB_6cell_100MHz_2T2R_woIQC_SA_Site_reset_by_Web_EM
    ${cell_list}=   gnbcell.Get All Cells Id
    Reset gNB
    gnbcell.Wait For All Cells To Be Onair   cells_list=${cell_list}
    gnbcell.Wait For Setup Of All Cells   verify_bts_status=True
    ...                                   availability_status=online
    ...                                   operational_state=enabled
    ...                                   administrative_state=unlocked
    ...                                   blocking_state=unblocked
    ...                                   procedural_status=configured
    ...                                   usage_state=active
    ...                                   barring_status=unbarred
    ...                                   timeout=300
    ...                                   interval=10
    ...                                   exptected_cell_amount=${6}

[1]CB007524-5G-A_TC05_2CPRI_3sHUB_6cell_100MHz_2T2R_woIQC_SA_sHUB_reset_by_ASiR_Web_EM
    ${start_time}=    keywords_SG07.Get Current Time
    ${expected_status_HUBMOD}  Create Dictionary  localState=unblocked  operationalState=enabled
    @{hub_ids}=    gnb_asir.Get All Hub Ids
    FOR    ${i}    IN RANGE   @{hub_ids}
           gnb_asir.Reset Hub
    END
    Wait Until Keyword Succeeds    900 sec    5 sec   gnb_asir.Verify Status Of All Hubmods    expected_statuses=${expected_status_HUBMOD}
    Wait Until Keyword Succeeds    100 sec    5 sec   Verify All Radio Module Status
    Wait Until Keyword Succeeds    900 sec    5 sec   Verify Setup Of All Cells
    Wait Until Keyword Succeeds    100 sec    5 sec   Verify gNB is onAir
    ${allowed_faults_asir}=    Create List    61648    10    4480
    keywords_SG07.Verify Alarm Appear In Alarm History On Asir    allowed_fault_ids=${allowed_faults_asir}    start_time=${start_time}

[1]CB007524-5G-A_TC35_2CPRI_1sHUB_1cell_100MHz_4T4R_woIQC_SA
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Cell blocked    AND
    ...                        Common Preconditions With Watching Alarms
    @{impact_cell}    Create List    455    255    555    355    655
    keywords_SG07.Block Cells    cell_list=${impact_cell}
    # Data transfer values
    Set Test Variable    ${expected_tput_NR_DL}    1400Mbits/sec
    Set Test Variable    ${expected_tput_NR_UL}    150Mbits/sec

    Check data transfer with Quectel    throughput_DL=${expected_tput_NR_DL}
    ...                                 throughput_UL=${expected_tput_NR_UL}
    ...                                 parallel_streams_UL=8
    ...                                 parallel_streams_DL=2
    ...                                 linux_congestion=${linux_congestion}

    [Teardown]   Run Keywords    keywords_SG07.Unblock Cells    cell_list=${impact_cell}    AND
    ...                          Wait Until Keyword Succeeds    600 sec    5 sec   Verify Setup Of All Cells
    ...                          AND    Common Postconditions With Watching Alarms
