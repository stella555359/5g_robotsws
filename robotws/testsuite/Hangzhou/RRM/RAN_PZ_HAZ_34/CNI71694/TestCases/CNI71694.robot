*** Settings ***
Variables     ./../TestData/CNI71694_msg_check.py
Resource    ./../../CB007873/Resources/CB007873_keywords.robot
Documentation    Suite description
...   author: Ren Biyao
...   contact: biyao.ren@nokia-sbell.com
...   squad group: MMW_SG1
...   Feature CNI71694
Force Tags      5G_RRM    PY36    RF50
Suite Setup     CNI Suite preparation
Suite Teardown  run keyword and ignore error    CNI Suite teardown

*** Variables ***
${PERCENT}                           0.95      # Percent of peak TPUT
${TPUT_DURATION}                     5m
${IS_UTE_ENV}                        ${False}


*** Test Cases ***
CNI-71694_01_F-T_CA_aware_PSCell_selection_with_NSA_CA_UE
    [Tags]    CIT_23R2    CIT_TRUNK    CIT_22R3    CDRT_22R2    CIT_22R4    CDRT_22R3
    [Documentation]    Author: Ren Biyao
    ...    The purpose of this test case is to verify that SgNB shall determine PSCell considering CNI-71694 CA-aware \
    ...    PSCell selection settings for PSCell candidates.
    ...    This feature works for NSA.
    ...    FDD 20M  TDD 10M
    [Setup]    Common case setup    NSA_SA=NSA
    log to console    \nPART1: Disnable CNI71694 and expect pscell is TDD cell
    connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${DEACTIVE_CNI71694_RESTAPI}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Start capture F1AP log    tcpdump_collector_name=cni_disable   options=-i any sctp
    Start X2 log capture from eNB    log_name=nsa_x2_debug_cni_disable

    run keyword and continue on failure   Retry commercial ue attach if failed
    ...    prepare_ue_needed=${False}    4G_check=${True}    ue_index=${0}
    ${cni_disable}    Stop tcpdump log collection    tcpdump_collector_name=cni_disable
    Stop X2 log capture from eNB    log_name=nsa_x2_debug_cni_disable

    run keyword and continue on failure    run keywords
    ...    Check msg item in tcpdump   tcpdump_log=${cni_disable}   msg_file=${CURDIR}/../TestData/msg_candidatelist.txt   filter=x2ap   AND
    ...    Check PScell ID    tcpdump_log=${cni_disable}    expected_cellid=${TDD_CELLS[0]['nrCellId']}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}

    log to console    \nPART2: Enable CNI71694 and expect pscell is FDD cell and scell is TDD cell.
    connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${ACTIVE_CNI71694_RESTAPI}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Start capture F1AP log    tcpdump_collector_name=cni_enable   options=-i any sctp
    Start X2 log capture from eNB    log_name=nsa_x2_debug_cni_enable
    run keyword and continue on failure   Retry commercial ue attach if failed
    ...    prepare_ue_needed=${False}    4G_check=${True}    ue_index=${0}
    ${cni_enable}    Stop tcpdump log collection    tcpdump_collector_name=cni_enable
    Stop X2 log capture from eNB    log_name=nsa_x2_debug_cni_enable
    Prepare and start aasyslog
    set test variable     ${DL_TPUT}     1800M
    set test variable     ${UL_TPUT}     100M
    Start data transfer based on direction    dl_tput=${DL_TPUT}     ul_tput=${UL_TPUT}
    ...    duration=3000s   data_transfer_direction=both    protocol=udp
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${TPUT_DURATION}    ignore_time=1min    filter=L2Lo
    ${exp_ul}    Set variable if    '${testline_name}'=='7_5_UTE5G402T255'    102,-1    73,-1
    ${exp_dl}    Set variable if    '${testline_name}'=='7_5_UTE5G402T255'    217,1497    205,1433
    run keyword and continue on failure     Check tput via power UE
    ...    cell_id=${PCELL_ID},${SCELL_ID}    exp_ul=${exp_ul}    exp_dl=${exp_dl}
    ...    log=${tput_log}    target_avg_percent=0.95    min_percent=0.8    customized_log_name=${None}
    Run keyword and ignore error    Stop data transfer and detach UE    data_transfer_direction=both    ue_index=${0}
    #        check msg in the pcap of enable CNI
    run keyword and continue on failure    run keywords
    ...    Check msg item in tcpdump   tcpdump_log=${cni_enable}   msg_file=${CURDIR}/../TestData/msg_candidatelist.txt   filter=x2ap   AND
    ...    Check PScell ID    tcpdump_log=${cni_enable}    expected_cellid=${FDD_CELLS[0]['nrCellId']}         AND
    ...    Check Scell ID     tcpdump_log=${cni_enable}    expected_cellid=${TDD_CELLS[0]['nrCellId']}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}

    log to console    \nPART3: delete sCellAdditionMethod of PScell
    connect to gnb coam via ssl
    delete sCellAdditionMethod under PScell
    Start capture F1AP log    tcpdump_collector_name=cni_delete_scelladd   options=-i any sctp
    Start X2 log capture from eNB    log_name=nsa_x2_debug_cni_delete_scelladd
    run keyword and continue on failure   Retry commercial ue attach if failed
    ...    prepare_ue_needed=${False}    4G_check=${True}    ue_index=${0}
    ${cni_delete_scelladd}    Stop tcpdump log collection    tcpdump_collector_name=cni_delete_scelladd
    Stop X2 log capture from eNB    log_name=nsa_x2_debug_cni_delete_scelladd

    run keyword and continue on failure    run keywords
    ...    Check msg item in tcpdump   tcpdump_log=${cni_delete_scelladd}   msg_file=${CURDIR}/../TestData/msg_candidatelist.txt   filter=x2ap   AND
    ...    Check PScell ID    tcpdump_log=${cni_delete_scelladd}    expected_cellid=${TDD_CELLS[0]['nrCellId']}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}
    run keyword and ignore error    delete sCellOperationalMode under PScell
#    ${is_sdx65}     run keyword and return status    List should contain value    ${tl.ues[0].capabilities}    sdx65
#    run keyword if    ${is_sdx65}    Enable CNI71694 and expect pscell is TDD cell and scell is FDD cell
    Enable CNI71694 and expect pscell is TDD cell and scell is FDD cell

    run keyword if     '${program}' != '23R3' and '${program}' != '23R4' and '${program}' != '24R1'
    ...    Enable CB008830 and expect pscell is TDD cell and scell is FDD cell


    [Teardown]    run keyword and ignore error    run keywords
    ...           connect to gnb coam via ssl                                             AND
    ...           Common case teardown    detach_ue=${True}                               AND
    ...           coam teardown gnb connections                                           AND
    ...           Stop trace capturing    log_prefix=nsa_x2_debug    connection_alias=ENB

CNI-71694_07_CA_aware_PSCell_selection_for_FR1_cells_during_intra-Fre_intra-gNB_HO
    [Tags]
    [Documentation]     Author: Ren Biyao
    ...    The purpose of this test case is to verify that SgNB shall determine PSCell considering CNI-71694 CA-aware \
    ...    PSCell selection settings for PSCell candidates.
    ...    This feature works for NSA.
    [Setup]    HO configuration
    log to console    \nPART1: Disnable CNI71694 and expect pscell is TDD cell
    connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${DEACTIVE_CNI71694_RESTAPI}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Start capture F1AP log    tcpdump_collector_name=cni_disable   options=-i any sctp
    run keyword and continue on failure   Retry commercial ue attach if failed
    ...    prepare_ue_needed=${False}    4G_check=${True}    ue_index=${0}
    ${cni_disable}    Stop tcpdump log collection    tcpdump_collector_name=cni_disable

    run keyword and continue on failure    Verify msgs type and detail IEs in sequence in tcpdump log
    ...    msg_checkpoint=${TC01_DISABLE_CNI}    log_path_pcap=${cni_disable}    detail_ie_filters=${None}    filter=x2ap||f1ap
    run keyword and continue on failure    Check PScell ID    tcpdump_log=${cni_disable}    expected_cellid=${TDD_CELLS[0]['nrCellId']}
    Prepare and start aasyslog
    set test variable     ${DL_TPUT}    1800M
    set test variable     ${UL_TPUT}     100M
    Start data transfer based on direction    dl_tput=${DL_TPUT}     ul_tput=${UL_TPUT}
    ...    duration=3000s   data_transfer_direction=both    protocol=udp
    log to console    \nPART2: Enable CNI71694 and expect pscell HO from TDD cell to F+T
    connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${ACTIVE_CNI71694_RESTAPI}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    sleep    3s
    log to console    \nStart to trigger handover scenario...

    Start capture F1AP log    tcpdump_collector_name=cni_enable_ho   options=-i any sctp
    Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_INTER_FREQ_TO_TRIGGER_HO}
    sleep    20s    msg=Wait for UE handover
    Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_AFT_INTER_HO}
    ${T_2_FT}    Stop tcpdump log collection    tcpdump_collector_name=cni_enable_ho
    sleep    15s    msg=Wait for tput stable

    run keyword and continue on failure
    ...    Check Tput info for each cell
    ...    dl_cell_id=${PCELL_ID},${SCELL_ID}     exp_dl=100,200    ul_cell_id=${PCELL_ID},${SCELL_ID}     exp_ul=50,0
    ...    nr_cell_id_mapping=${NR_CELL_ID_MAPPING}
    Run keyword and ignore error    Stop data transfer and detach UE    data_transfer_direction=both    ue_index=${0}

*** Keywords ***
CNI Suite preparation
    import NIDD variables
    set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_DEFAULT_20M_100M_1116_FLEXIBLECAMODE_ALIGNBWP}
    CA Suite preparation    prepare_ue=${True}    NSA_SA=NSA    enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}
    Block adjacent gNB RUs
    import variables      ${CURDIR}/../TestData/CNI71694_modify_param.py
    Enable or disable B1 on enb side      parameters_to_update_via_api=${ENABLE_B1_MEAS}
    set suite variable     ${is_log_required}                ${False}
    set suite variable     ${IS_LOG_CAPTURED_CASE_LEVEL}     ${False}

CNI Suite teardown
    Enable or disable B1 on enb side      parameters_to_update_via_api=${DISABLE_B1_MEAS}
    Initialize PA ports of adjacent gNB RUs
    Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_F_T}
    CA Suite teardown
    run keyword and ignore error    Close all connection
    run keyword and ignore error    coam teardown gnb connections

Enable or disable B1 on enb side
     [Arguments]     ${parameters_to_update_via_api}
     Connect to gnb coam via ssl
    ...    connection=enblte_0
    ...    bts_host=${tl.enbs[${0}].airscale.common_units[0].lmp_connection.addr}
     ${update_status}    COAM Update several parameters via rest api    connection=enblte_0
     ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
     Should be true    '${update_status}'=='PASS'
     [Teardown]     run keyword and ignore error     coam.teardown    connection=enblte_0

Check Scell ID
    [Arguments]    ${tcpdump_log}     ${expected_cellid}=${TDD_CELLS[0]['nrCellId']}
    connect to gnb coam via ssl
    ${SCell_physCellId}   Get SCF single Value from current xml file
     ...   parameter=physCellId   list_name=${None}   dist_name=NRBTS-${tl.gnbs[${0}].global_bts_id}/NRCELL-${expected_cellid}   p_index=${0}
     ...   alias=GNB_OAM    config_type=configurationAndRuntimeObjects
    ${pdml_list}    Load pcap file with filter     log_path_pcap=${tcpdump_log}     filter=x2ap
    ${scell_pci}    pcap.get_field_value_by_xpath
    ...      xpath=.//nr-rrc.sCellConfigCommon_element/nr-rrc.physCellId
    ...      attribute_name=show
    ${scell_pci}    Remove Duplicates    ${scell_pci}
    List should contain value     ${scell_pci}    ${SCell_physCellId}    msg=\nscellid is ${scell_pci}, not as expected ${SCell_physCellId}.
    [Teardown]    run keyword and ignore error    coam teardown gnb connections

Check PScell ID
    [Arguments]    ${tcpdump_log}    ${expected_cellid}=${FDD_CELLS[0]['nrCellId']}
    connect to gnb coam via ssl
    ${PSCell_physCellId}   Get SCF single Value from current xml file
     ...   parameter=physCellId   list_name=${None}   dist_name=NRBTS-${tl.gnbs[${0}].global_bts_id}/NRCELL-${expected_cellid}   p_index=${0}
     ...   alias=GNB_OAM    config_type=configurationAndRuntimeObjects
    ${pdml_list}    Load pcap file with filter     log_path_pcap=${tcpdump_log}     filter=x2ap
    ${pcell_pci}    pcap.get_field_value_by_xpath
    ...      xpath=.//nr-rrc.spCellConfig_element//*//nr-rrc.spCellConfigCommon_element/nr-rrc.physCellId
    ...      attribute_name=show
    ${pcell_pci}    Remove Duplicates    ${pcell_pci}
    List should contain value    ${pcell_pci}    ${PSCell_physCellId}    msg=\npscellid is ${pcell_pci}, not as expected${PSCell_physCellId}.
    [Teardown]    run keyword and ignore error    coam teardown gnb connections

delete sCellAdditionMethod under PScell
    [Arguments]     ${disct_nrrel}=${DN_CA_REL}    ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window

    selenium_coam.delete_parameter  dist_name=${disct_nrrel}
    ...    filter_param=Secondary cell addition method
    ...    abbr=sCellAdditionMethod
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep    8s
    [Teardown]     Run Keyword And Ignore Error   COAM selenium logout

delete sCellOperationalMode under PScell
    [Documentation]    author: Wang Yixiang
    ...     delete sCellAdditionMethod under PScell to solve PDL issue
    [Arguments]     ${disct_nrrel}=${DN_CA_REL}    ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window

    selenium_coam.delete_parameter  dist_name=${disct_nrrel}
    ...    filter_param=Secondary cell operational mode
    ...    abbr=sCellOperationalMode
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep    8s
    [Teardown]     Run Keyword And Ignore Error   COAM selenium logout

HO configuration
    set suite variable    ${PARAMS_TO_DELETE}    ${DELETE_SCF_BEFORE_HO}
    set suite variable    ${PARAMS_TO_ADD}       ${ADD_SCF_HO}
    set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_MO}
    COAM Create log directory
    ${template_for_ho}    scfpro.SCFProcess    scf_template_path=${SCF_DEFAULT_FILE_PATH}    scf_process_folder=${TS_CASE_LOG_PATH}
    ...    list_para_to_delete=${PARAMS_TO_DELETE}    list_para_to_modify=${PARAMS_TO_MODIFY}    list_para_to_add=${PARAMS_TO_ADD}
    Common case setup
    ...    NSA_SA=NSA    is_log_required=${False}
    ...    scf_modify_parameters=${MODIFY_SCF_DEFAULT_20M_100M_1116_FLEXIBLECAMODE}
    ...    scf_template_path=${template_for_ho}

Enable CNI71694 and expect pscell is TDD cell and scell is FDD cell
    log to console    \nPART_EXT: Enable CNI71694 and expect pscell is TDD cell and scell is FDD cell.
    connect to gnb coam via ssl
    run keyword and continue on failure
    ...    COAM Update several parameters via rest api    parameters_to_update_via_api=${REST_API_CA_SUPPORTLIST}    timeout=${300}
    COAM add several MOs via rest api     objects_to_add_via_api=${REST_API_ADD_T_NRREL_F['object_to_add']}    timeout=${300}

    Start capture F1AP log    tcpdump_collector_name=TplusF   options=-i any sctp
    run keyword and continue on failure   Retry commercial ue attach if failed
    ...    prepare_ue_needed=${False}    4G_check=${True}    ue_index=${0}
    ${TplusF}    Stop tcpdump log collection    tcpdump_collector_name=TplusF
    run keyword and continue on failure    run keywords
    ...    Check msg item in tcpdump   tcpdump_log=${TplusF}   msg_file=${CURDIR}/../TestData/msg_candidatelist.txt   filter=x2ap   AND
    ...    Check PScell ID    tcpdump_log=${TplusF}    expected_cellid=${TDD_CELLS[0]['nrCellId']}         AND
    ...    Check Scell ID     tcpdump_log=${TplusF}    expected_cellid=${FDD_CELLS[0]['nrCellId']}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}

Enable CB008830 and expect pscell is TDD cell and scell is FDD cell
    log to console    \nPART_EXT: Enable CB008830 and expect pscell is TDD cell and scell is FDD cell.
    connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${ONLINE_ENABLE_CB008830_API}    timeout=${300}

    Start capture F1AP log    tcpdump_collector_name=TDmrsType2plusF   options=-i any sctp
    run keyword and continue on failure   Retry commercial ue attach if failed
    ...    prepare_ue_needed=${False}    4G_check=${True}    ue_index=${0}
    ${TDmrsType2plusF}    Stop tcpdump log collection    tcpdump_collector_name=TDmrsType2plusF
    set test variable     ${DL_TPUT_DMRS2}     2000M
    set test variable     ${UL_TPUT_DMRS2}     150M
    Start data transfer based on direction    dl_tput=${DL_TPUT_DMRS2}     ul_tput=${UL_TPUT_DMRS2}
    ...    duration=3000s   data_transfer_direction=both    protocol=udp
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${TPUT_DURATION}    ignore_time=1min    filter=L2Lo
    run keyword and continue on failure     Check tput via power UE
    ...    cell_id=${TDD_CELLS[0]['nrCellId']},${FDD_CELLS[0]['nrCellId']}    exp_ul=75,-1    exp_dl=1588,220
    ...    log=${tput_log}    target_avg_percent=0.95    min_percent=0.8    customized_log_name=cni_enable_dmrstype2
    Run keyword and ignore error    Stop data transfer and detach UE    data_transfer_direction=both    ue_index=${0}
    run keyword and continue on failure    run keywords
    ...    Check msg item in tcpdump   tcpdump_log=${TDmrsType2plusF}   msg_file=${CURDIR}/../TestData/msg_candidatelist.txt   filter=x2ap   AND
    ...    Check PScell ID    tcpdump_log=${TDmrsType2plusF}    expected_cellid=${TDD_CELLS[0]['nrCellId']}         AND
    ...    Check Scell ID     tcpdump_log=${TDmrsType2plusF}    expected_cellid=${FDD_CELLS[0]['nrCellId']}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}
