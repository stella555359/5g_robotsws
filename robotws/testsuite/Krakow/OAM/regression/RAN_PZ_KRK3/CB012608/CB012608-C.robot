*** Settings ***
Documentation
...    Maintainer: patry.wojcik@nokia.com
...    Description: Tests covering rollback with OAM KPI and L3 Call for ASOH
...    Team in charge: MN RAN RD VRF KRK 3

Library             taf/rfrl/csv4all/CSV4AllTestCases.py       WITH NAME    CSV4ALL
Library             taf.rfrl.utilities.logger.custom_logger    WITH NAME    logger
Library             taf.ue                                     WITH NAME    ue
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource            taf/rfrl/ue/robot/REAL_UE.robot
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags          CA_VRF_KRK

Suite Setup         Common Suite Setup With OnAir Test Line Preparation
...                         increase_timeout_for_update_sw=${1800}
...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
...                         prefix_tag=25R3_N_CB012455_1a
...                         should_LTE_neighbour_be_changed=${True}

Suite Teardown      Common Suite Teardown

Test Setup          Common Preconditions
Test Teardown       Common Postconditions

*** Variables ***
@{CUSTOMERS_LIST}                               Generic
${QC_DOMAIN}                                    MN_RAN
${QC_PROJECT}                                   RAN_VRF
${SHOULD_BE_REPORTED}                           False

${RP_CA}                                        VRF_OAM
${RP_LOCATION}                                  VRF_KRK
${RP_ORGANIZATION}                              VRF_KRK_T03

${ITERATIONS_UPGRADE}                           ${5}
${ITERATIONS_RESET}                             ${30}

${5G_SOURCE_SW}                                 ${None}
${5G_TARGET_SW}                                 ${None}

@{CUSTOM_ALARMS}                                7107        7319        7300        7308
@{CRITICAL_ALARMS}                              10

&{NODE1}                                        testline_object=${tl.gnbs[0]}
...                                             source_sw=${5G_SOURCE_SW}
...                                             target_sw=${5G_TARGET_SW}
...                                             custom_allowed_alarms=${CUSTOM_ALARMS}
@{NODES}                                        ${NODE1}
@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  7107  61673

*** Test Cases ***
CB012608-SR-C_E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Documentation]    Performs upgrade and rollback with L3CALL. It is mandatory that the 5G_SOURCE_SW is a current BTS
    ...   build when executing the test.
    Prepare Ue for L3 Call    alias=UE2    capabilities=COMMERCIAL_UE   reboot_ue=False
    Prepare Ue for L3 Call    alias=UE3    capabilities=COMMERCIAL_UE   reboot_ue=False
    CSV4ALL.E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=1
    ...                                     report=${SHOULD_BE_REPORTED}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     sw_build=${5G_TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${False}
    Attach UE3
    Start and Verify TCP DL and UL data transfer for UE    ue_alias=UE3    dl_tput=4200 Mbits/sec    ul_tput=550 Mbits/sec
    [Teardown]      Run Keywords
    ...             Detach UE3  AND
    ...             Common Postconditions

*** Keywords ***
Attach ${ue_alias}
    [Documentation]    KW perfroms UE attach with cell verification using taf.ue KWs
    ...    :param ue_alias: taf.ue UE alias
    logger.Log Info To Console    Attach ${ue_alias}
    ue.Attach Ue    ${ue_alias}

Detach ${ue_alias}
    [Documentation]    KW perfroms UE dettach using taf.ue KWs
    ue.Detach Ue    ${ue_alias}

Start and Verify TCP DL and UL data transfer for UE
    [Arguments]     ${ue_alias}=UE1
    ...             ${apn}=${None}
    ...             ${dl_tput}=4200 Mbits/sec
    ...             ${ul_tput}=530 Mbits/sec
    ...             ${data_transfer_time}=30s
    ...             ${omit}=5
    ...             ${deviation}=20%
    ...             ${protocol}=tcp
    ...             ${parallel_streams}=4
    ...             ${max_segment_size}=1310

    [Documentation]    The keyword executes TCP DL and UL data transmission for a specific time and checks if throughput
    ...                was within allowed deviation
    ...    :param ue_alias: taf.ue UE alias
    ...    :param dl_tput: DL throughput value of data transfer
    ...    :param ul_tput: UL throughput value of data transfer
    ...    :param data_transfer_time: for how data transfer will last
    ...    :param omit: it is a delay in seconds to start counting the tput ex. '20'
    ...                 1st 20 seconds of datatransfer will be omited.

    ${dl_dt_name}=            Set Variable    TCP_DL_DataTransfer_1
    ${ul_dt_name}=            Set Variable    TCP_UL_DataTransfer_1

    ue.Start Data Transfer    dt_name=${dl_dt_name}    ue_alias=${ue_alias}    apn=${apn}    direction=dl
    ...                       duration=${data_transfer_time}    protocol=${protocol}   max_segment_size=${max_segment_size}
    ...                       parallel_streams=${parallel_streams}    deviation=${deviation}    omit=${omit}
    logger.Log Info To Console    DL TCP data transfer started    log_hierarchy=2
    ue.Await Data Transfer Finish    ${dl_dt_name}
    ue.Stop Data Transfer    dt_name=${dl_dt_name}
    ue.Verify Average Throughput With Deviation    dt_name=${dl_dt_name}    tput=${dl_tput}    omit=${omit}
    ...                                            deviation=${deviation}
    logger.Log Info To Console    DL TCP data transfer OK    log_hierarchy=3

    ue.Start Data Transfer    dt_name=${ul_dt_name}    ue_alias=${ue_alias}    apn=${apn}    direction=ul
    ...                       duration=${data_transfer_time}    protocol=${protocol}    max_segment_size=${max_segment_size}
    ...                       parallel_streams=${parallel_streams}    deviation=${deviation}    omit=${omit}
    logger.Log Info To Console    UL TCP data transfer started    log_hierarchy=2
    ue.Await Data Transfer Finish    ${ul_dt_name}
    ue.Stop Data Transfer    dt_name=${ul_dt_name}
    ue.Verify Average Throughput With Deviation    dt_name=${ul_dt_name}    tput=${ul_tput}     omit=${omit}
    ...                                            deviation=${deviation}
    logger.Log Info To Console    UL TCP data transfer OK    log_hierarchy=3
