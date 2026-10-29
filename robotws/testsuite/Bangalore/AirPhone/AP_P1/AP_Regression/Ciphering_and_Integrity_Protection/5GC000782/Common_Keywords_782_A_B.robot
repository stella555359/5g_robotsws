*** Settings ***
Documentation     This resource file contains 5GC000782-A-B feature related common keywords
Library         ../../../Resources/Python/DeltaStore.py    WITH NAME    delta_store

Resource        ../../../Resources/robot/ute_setup.robot
Resource        ../../../Resources/robot/wts.robot
Resource        ../../../Resources/robot/log.robot
Resource        ../../../Resources/Variables/Common_Variables.robot
Resource        ../../../Resources/robot/suite_common_keywords.robot
Resource        ../../../Resources/robot/tshark.robot

*** Variables ***
${UE_ID_1}                             1
${UE_ID_2}                             2
${BEARER_ID}                           2
${WTS_CFG_PATH}                        ${CURDIR}/cfg
${SLEEP_WAIT_TIME}                     5s

*** Keywords ***
Suite Setup
    [Arguments]    ${feature_folder}
    Suite Common Keywords    feature_folder=${feature_folder}
    ReachOnAir

Suite Teardown
    Common Suite Teardown Keywords
    Revert ciphering algorithm to default values
    Wait for gNB To Be Ready

ReachOnAir
    Wait for gNB To Be Ready
    Prepare Environment Based On Run Type     cfg_type=custom

CleanUp
    Teardown All Aliases For Wts

Test Setup
   [Arguments]    ${config_scenario}
   Create Test Case Folder
   Start WTS And Extablish X2 Link
   Execute Delta Commissioning    ${config_scenario}
   Wait for gNB To Be Ready
   Start pcap collection in gNB and WTS

Test Teardown
    run keyword and ignore error    UE Detach   ${UE_ID_1}
    run keyword and ignore error    UE Detach   ${UE_ID_2}
    Common Test Teardown

Attach UE and Perform Sgnb Addition
    UE Attach   ue_id=${UE_ID_1}    profile_id=${PROFILE_ID}
    SGNB Addition For Bearer   ue_id=${UE_ID_1}    target_gnb=${GNB_ID}
    ...                        target_cells=${CELL_ID}   bearer=${BEARER_ID}
    Wait until all packets are captured in pcap
    Stop pcap collection in gNB and WTS

Start UL and DL Data Transfer And Verify Throughput on Default Bearer
   Start Data Transfer And Verify Throughput    bearer=${BEARER_ID}    ue_id=${UE_ID}
   Stop All Data Transfer    ${UE_ID}    bearer=${BEARER_ID}

Attach UE and Sgnb Addition fails
    UE Attach   ue_id=${UE_ID_2}    profile_id=${PROFILE_ID}
    SGNB Addition For Bearer   ue_id=${UE_ID_2}    target_gnb=${GNB_ID}    target_cells=${CELL_ID}   bearer=${BEARER_ID}
    ...                        pass_regexp=encryption-and-or-integrity-protection-algorithms-not-supported
    Wait until all packets are captured in pcap
    Stop pcap collection in gNB and WTS

Wait until all packets are captured in pcap
    Sleep   ${SLEEP_WAIT_TIME}

Verify ciphering messages in pcap
    [Arguments]    ${wireshark_filter}=None
    ${pcap_file}=   log_store.get_gnb_pcap
    PCAP File Should have Messages Defined in Filter File    pcap_file=${pcap_file}
    ...    wireshark_filter_file=${wireshark_filter}

Revert ciphering algorithm to default values
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.add_list_parameters_to_delta    dist_name=${NRBTS_DISTNAME}    list_name=cipherPrefL    nea0=1
    ...    nea1_128=3    nea2_128=4    nea3_128=2
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}