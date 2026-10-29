*** Settings ***
Documentation
...   author: Wioleta Swies, Jakub Bialon
...   contact: wioleta.swies@nokia.com, jakub.bialon@nokia.com
...   CB008271

Library      BuiltIn
Library      taf.sbts.oam.coam.admin   WITH NAME   adminCli
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations
Library      taf.rfrl.bts.devices.asir.generic_asir.GenericAsirHub   WITH NAME   asirAdmin
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations   WITH NAME   gnb_asir
Resource     taf/rfrl/bts/robot/enb.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library     testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py   WITH NAME   keywords


Suite Setup      Common Suite Setup With OnAir Test Line Preparation
...              should_LTE_neighbour_be_changed=${False}
...              should_5G_neighbour_be_changed=${False}
...              increase_time_for_checking_bbmod=600
...              increase_timeout_for_update_sw=1800
...              increase_time_for_checking_radios=2100
...              increase_time_for_checking_cells=700
...              swconfig_from_path=testsuite/Krakow/OAM/regression/RAN_PZ_KRK7/CB008271-A/resources/swconfig.txt

Suite Teardown    Common Suite Teardown
Test Setup       Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms


*** Variables ***
# -----------------------------UE-----------------------------
${capabilities}                         REAL_UE
${alias}                                UE
${bts_type}                             GNB
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${ENABLE_RACH_OBSERVER}                 False
${deviation_ul}                         90%
${deviation_dl}                         90%
${duration}                             120s
${interval}                             1
${linux_congestion}                     reno
${parallel_streams_dl}                  2
${parallel_streams_ul}                  2
${reboot_ue}                            False
${size_packet_dl}                       1320B
${size_packet_ul}                       1380B
${timeout_reboot_ue}                    100
${tput_dl}                              400 Mbits/sec
${tput_ul}                              100 Mbits/sec
${qci}                                  None
${protocol}                             tcp
${buffer_client_dl}                     None
${buffer_server_dl}                     None
${buffer_client_ul}                     None
${buffer_server_ul}                     None
${GNB_SCF_NAME}                         GNB0_SCF.xml

@{allowed_faults_asir}=                 61648    10    4480    4493
@{alarms_allowed_during_preparation}    Create List    Failure detected on assigned antennas


*** Test Cases ***
[1]CB008271-SR-B_TC07_US11_ABIO_ASIRMOD_Reset_NRTDD_3x100M_LTETDD_6x20M_SANSA
    ${start_time}=    keywords.Get Current Time
    ${expected_status_HUBMOD}  Create Dictionary  localState=unblocked  operationalState=enabled
    @{hub_ids}=    gnb_asir.Get All Hub Ids
    FOR    ${id}    IN    @{hub_ids}
           gnb_asir.Reset Hub    hub_id=${id}    timeout=${0}
    END
    Sleep    30s
    Wait Until Keyword Succeeds    900 sec    5 sec   gnb_asir.Verify Status Of All Hubmods    expected_statuses=${expected_status_HUBMOD}
    Wait Until Keyword Succeeds    100 sec    5 sec   Verify All Radio Module Status
    Wait Until Keyword Succeeds    900 sec    5 sec   Verify Setup Of All Cells
    Wait Until Keyword Succeeds    100 sec    5 sec   Verify gNB is onAir
    ${allowed_faults_asir}=    Create List    61648    10    4480
    keywords.Verify Alarm Appear In Alarm History On Asir    allowed_fault_ids=${allowed_faults_asir}    start_time=${start_time}

[1]CB008271-SR-B_TC04_US11_ABIO_UEcall_NRTDD_3x100M_4T4R_LTETDD_6x20M_2T2R_SANSA
    Verify L3 Call Traffic

[1]CB008271-SR-B_TC26_US13_ABIO_ASIRMOD_Lock_unlock_NSA
    ${start_time}=    keywords.Get Current Time
    Lock ASIR
    Verify Hubmod Lock Status
    Unlock ASIR
    Wait Until Keyword Succeeds    600 sec    5 sec   Verify All Radio Module Status
    Wait Until Keyword Succeeds    600 sec    5 sec   Verify Setup Of All Cells
    Wait Until Keyword Succeeds    900 sec    5 sec   Verify gNB is onAir
    ${allowed_faults_asir}=    Create List    1931
    keywords.Verify Alarm Appear In Alarm History On Asir    allowed_fault_ids=${allowed_faults_asir}    start_time=${start_time}

[1]CB008271-SR-B_TC19_US13_ABIO_Cells_Setup_NRTDD_3x100M_2T2R_LTEFDD_16x20M_2T2R_NSA
    ${SCF_GNB_PATH}    keywords.Get Default Scf Path    file_name=16_20_2T2R.xml
    ${SCF_ASIR_PATH}    keywords.Get Default Scf Path    file_name=16_20_2T2R_asir.xml
    Perform Bts Full Commissioning    scf_file=${SCF_GNB_PATH}
    ...                               timeout=400
    Perform Full Commissioning On Gnb Asir Hub     scf_path=${SCF_ASIR_PATH}
    Sleep    60s
    Wait For Onair On All Dus
    Wait Until Keyword Succeeds    600 sec    5 sec   Verify Setup Of All Cells
    Reset gNB
    Wait Until Keyword Succeeds    600 sec    5 sec   Verify All Radio Module Status
    Wait Until Keyword Succeeds    600 sec    5 sec   Verify Setup Of All Cells
    Wait Until Keyword Succeeds    900 sec    5 sec   Verify gNB is onAir


*** Keywords ***
Verify L3 Call Traffic
    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 Call Data Transfer DL&UL    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...    protocol=${protocol}    deviation_dl=${deviation_dl}    deviation_ul=${deviation_ul}
    ...    parallel_streams_dl=${parallel_streams_dl}    parallel_streams_ul=${parallel_streams_ul}
    ...    size_packet_dl=${size_packet_dl}    size_packet_ul=${size_packet_ul}    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}    buffer_client_ul=${buffer_client_ul}    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}    qci_dl=${qci}    qci_ul=${qci}    linux_congestion_dl=${linux_congestion}
    ...    linux_congestion_ul=${linux_congestion}

Lock ASIR
    @{hub_ids}=    Get All Hub Ids
    adminCli.Connect to      name=coam
    FOR    ${i}    IN   @{hub_ids}
           adminCli.lock
           ...        dist_name=MRBTS-77143/EQM-1/APEQM-1/ASIRMOD-${i}
           ...        connection=coam
           ...        timeout=60
    END
    adminCli.teardown          connection=coam

Unlock ASIR
    @{hub_ids}=    Get All Hub Ids
    adminCli.Connect to      name=coam
    FOR    ${i}    IN   @{hub_ids}
           adminCli.unlock
           ...        dist_name=MRBTS-77143/EQM-1/APEQM-1/ASIRMOD-${i}
           ...        connection=coam
           ...        timeout=60
    END
    adminCli.teardown          connection=coam
