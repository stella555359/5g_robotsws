*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Prajwali Joshi
...             :co-author : Sandesh Jadhav
...             :contact  : prajwali.milind_joshi@nokia.com
...             :contact  : sandesh.jadhav@nokia.com

Library     taf.ul.ue.sim.env_setup
Library     OperatingSystem
Library     ta_uexgate
Library     ta_messaging
Library     ta_emss
Library     taf.ul.alarms_watchdog
Resource    resources/CB013544_KW.robot

Suite Setup      Run Keyword
...     Setup testline with yaml
Suite Teardown    Stop Default Logging For CUS And Compress Test Logs

*** Variables ***
${reconf}            ${True}
${Log_Path2}         /home/ute/logs/CB013344_C
${Log_Path1}         /home/ute/logs/CB013344_A
@{swconfig_flags}    ${SYSLOG_FlAG1}   ${SYSLOG_FlAG2}    ${SYSLOG_FlAG3}
${SYSLOG_FlAG1}=        0x1003F=2
${SYSLOG_FlAG2}=        0x10040=2
${SYSLOG_FlAG3}=        0x10041=5
${EGATE_PORT}=          20000
${EDAEMON_PORT}=        10000
${scfc}            ${CURDIR}/config/SCFC/Configuration_scf_MRBTS-1_TL001_20250819-1242.xml
${cus_yaml}        ${CURDIR}/config/YAML/coco.yaml

*** Test Cases ***
[1]TC03_StepWise_increase_and_decrease_of_adaptive_ACB_based_on_eNB_congestion
    [Tags]   QC_235244     QCD_MN_RAN      QCP_RAN_VRF
    [Setup]     Prepare For Test Case CB013544_A
     Log to Console    \n Starting for stepwise increase
     Start pcap collection in eth4      name=stepwise_increase
     Run UEx command   ue_attach   id=1-30   cell=1
     Log to Console    \n UEs Registration completed
     sleep   240s
     ${pcap_file_path}     Stop pcap collection in gNB 13544   ${stepwise_increase}    ${Log_Path}
     Checking for SIB2 in pcap        /home/ute/logs/stepwise_increase/stepwise_increase.pcap
     Log to Console    \n Checking for counters
     Wait For Next Raw Pm Interval
     ${pm_counter_filepath_13544}=    Get Next Unpacked Raw Pm Counters File
     ${M8038C46_13544_ON}=  Get Latest Pm Counter Value  counter_id=M8038C46  local_moid=${local_cell_id_1}    filepath=${pm_counter_filepath_13544}
     ${M8038C46_13544_1}=  Get Latest Pm Counter Value  counter_id=M8057C2  local_moid=${local_cell_id_2}    filepath=${pm_counter_filepath_13544}
     ${M8038C46_13544_2}=  Get Latest Pm Counter Value  counter_id=M8057C3  local_moid=${local_cell_id_2}    filepath=${pm_counter_filepath_13544}
     ${M8038C46_13544_3}=  Get Latest Pm Counter Value  counter_id=M8057C4  local_moid=${local_cell_id_2}    filepath=${pm_counter_filepath_13544}
     Check counter value is equal to max threshold  ${M8038C46_13544_ON}
     Check counter value is equal to max threshold     ${M8038C46_13544_1}
     Check counter value is non zero    ${M8038C46_13544_2}
     Check counter value is non zero    ${M8038C46_13544_3}
     Log to Console    \n Starting for stepwise decrease
     Start pcap collection in eth4      name=stepwise_decrease
     Run UEx command   ue_detach   id=1-30
     Log to Console    \n UEs are detached
     sleep   240s
     ${pcap_file_path}     Stop pcap collection in gNB 13544   ${stepwise_decrease}    ${Log_Path}
     Checking for SIB2 in pcap          /home/ute/logs/stepwise_decrease/stepwise_decrease.pcap
     Wait For Next Raw Pm Interval
     ${pm_counter_filepath_13544}=    Get Next Unpacked Raw Pm Counters File
     ${M8038C46_13544_ON}=  Get Latest Pm Counter Value  counter_id=M8038C46  local_moid=${local_cell_id_1}    filepath=${pm_counter_filepath_13544}
     ${M8038C46_13544_1}=  Get Latest Pm Counter Value  counter_id=M8057C2  local_moid=${local_cell_id_2}    filepath=${pm_counter_filepath_13544}
     ${M8038C46_13544_2}=  Get Latest Pm Counter Value  counter_id=M8057C3  local_moid=${local_cell_id_2}    filepath=${pm_counter_filepath_13544}
     ${M8038C46_13544_3}=  Get Latest Pm Counter Value  counter_id=M8057C4  local_moid=${local_cell_id_2}    filepath=${pm_counter_filepath_13544}
     Check counter value is less than max threshold    ${M8038C46_13544_ON}
     Check counter value is less than max threshold    ${M8038C46_13544_1}
     Check counter value is zero    ${M8038C46_13544_2}
     Check counter value is zero    ${M8038C46_13544_3}
     [Teardown]    Teardown for CB013544_A

[1]TC10_cellResHoBlockPlmnAcbMax_modified_when_max_PLMN_specific_step-wise_ACB_is_already_started_cellResHoBlockPlmnAcbMax_is_notReserved_and_Reserved
    [Tags]   QC_236085     QCD_MN_RAN      QCP_RAN_VRF
    [Setup]     Prepare For Test Case CB013544_C
    Start pcap collection in eth4      name=start_HO
    Run UEx command   ue_attach   id=1-2    cell=2    selected_plmn=555:12
    Log to Console    \n UEs are attached
    Run UEx command   trf_data_start  ue=1-2  protocol=tcp  dir=dl  Mbps=1  stats=true
    Calculate average tput for UE   1    1    dl    1
    Calculate average tput for UE   1    2    dl    1
    GNB Delta Commission          ${CURDIR}/config/SCFC/delta.json
    Run UEx command   ue_attach   id=3-30   cell=1
    sleep   240s
    Wait For Next Raw Pm Interval
    HO_Failure      1     1
    GNB Delta Commission          ${CURDIR}/config/SCFC/delta_not_reserved.json
    sleep    10s
    HO_Success      2      1
    ${pcap_file_path}     Stop pcap collection in gNB 13544   ${start_HO}    ${Log_Path}
    Checking for SIB2 in pcap         /home/ute/logs/start_HO/start_HO.pcap
    Wait For Next Raw Pm Interval
    ${pm_counter_filepath_13544}=    Get Next Unpacked Raw Pm Counters File
    ${M8038C46_13544_ON}=  Get Latest Pm Counter Value  counter_id=M8038C46  local_moid=${local_cell_id_1}    filepath=${pm_counter_filepath_13544}
    ${M8038C46_13544_1}=  Get Latest Pm Counter Value  counter_id=M8057C2  local_moid=${local_cell_id_2}    filepath=${pm_counter_filepath_13544}
    ${M8038C46_13544_2}=  Get Latest Pm Counter Value  counter_id=M8057C3  local_moid=${local_cell_id_2}    filepath=${pm_counter_filepath_13544}
    ${M8038C46_13544_3}=  Get Latest Pm Counter Value  counter_id=M8057C4  local_moid=${local_cell_id_2}    filepath=${pm_counter_filepath_13544}
    Check counter value is equal to max threshold  ${M8038C46_13544_ON}
    Check counter value is equal to max threshold     ${M8038C46_13544_1}
    Check counter value is non zero    ${M8038C46_13544_2}
    Check counter value is non zero    ${M8038C46_13544_3}
    [Teardown]   Teardown for CB013544_C
