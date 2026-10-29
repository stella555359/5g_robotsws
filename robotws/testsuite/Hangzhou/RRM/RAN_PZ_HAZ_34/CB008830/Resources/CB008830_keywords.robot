*** Settings ***
Documentation    8830 DMRS
Resource     CB008830_variables.robot
Variables    commissionings/HGZ/${testline_name}/__init_8830__.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/vonr.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/TestData/Parameters_modify_lib.py    WITH NAME    param_modify_lib
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/online_nidd_process.py    WITH NAME    nidd_modify
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/string_list.py
Library    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008830/Resources//CB008830_common_keywords.py

*** Variables ***
&{fault_4383}    faultId=${4383}    #alarm_ID 7101, Internal BTS processes autonomous reset as recovery action
&{fault_61524}    faultId=${61524}    source=SMOD_R-1    #faultId:SSH_ENABLED  source:RU1
&{fault_61652}    faultId=${61652}    source=SMOD_R-1    #faultId:R&D_SERVICE_PORT_ENABLED  source:RU1
&{fault_61074}    faultId=${61074}    #CRL Update Failure
&{fault_4654}    faultId=${4654}    source=SMOD_R-1     #Ethernet port security is disabled
&{fault_4655}    faultId=${4655}    #Service account root access is enabled
&{fault_61649}    faultId=${61649}    source=SMOD       #LMP access via port 443
@{ALLOWED_FAULT_LIST}    &{fault_61524}    &{fault_61652}     &{fault_4654}    &{fault_4655}    &{fault_61649}    &{fault_61074}

*** Keywords ***
Import NIDD variables for 8830
    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    Connect to gnb coam via ssl
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    set suite variable    ${NR_CELL_ID_MAPPING}
    ${PCELL_physCellId}    set variable    ${NR_CELL_ID_MAPPING[${PCELL_ID}]['physicalCellId']}
    set suite variable    ${PCELL_physCellId}
    ${is_tl_delta_file_exists}    Run keyword and return status    File should exist    ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    Run keyword if    ${is_tl_delta_file_exists}
    ...    Import variables  ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_rest_api_8830.py
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections


8830 Suite preparation
    [Documentation]  Author:  Tony Tang
    ...    ${cell_chbw_config} need to adpative which cell and paramters to modify in suite setup phase,
    [Arguments]    ${enb_default_scf_file}=${None}    ${cell_chbw_config}=1CC_T100M
    ...    ${swconfig_modify}=${None}    ${scf_modify_parameters}=${PARAMS_TO_MODIFY_SCF}
    ...    ${pa_values_mapping}=${INIT_PA_T1}    ${frame_structure}=1070

    Import NIDD variables for 8830
    run keyword if    '${cell_chbw_config}'!='${None}'    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_${cell_chbw_config}.py

    ${MODIFY_SCF_DEFAULT}    set variable if    '${frame_structure}' == '1070'    ${MODIFY_SCF_DEFAULT_1070}    ${MODIFY_SCF_DEFAULT_1070}

    Set suite variable    ${PARAMS_TO_DELETE}    ${DELETE_SCF_DEFAULT}
    Set suite variable    ${PARAMS_TO_ADD}       ${ADD_SCF_DEFAULT}
    Set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_DEFAULT}

    CA Suite preparation    prepare_ue=${True}    NSA_SA=${NSA_SA}    enb_default_scf_file=${enb_default_scf_file}
    ...    swconfig_modify=${swconfig_modify}
    ...    prepare_ue=${True}
    ...    scf_modify_parameters=${scf_modify_parameters}
    ...    pa_values_mapping=${pa_values_mapping}

8830 Case setup
    [Documentation]    Author: Tony Tang
    [Arguments]    ${dict_params_to_modify}=${None}    ${is_log_required}=${IS_LOG_CAPTURED_CASE_LEVEL}
    Common case setup    is_log_required=${is_log_required}    NSA_SA=${NSA_SA}
    run keyword if    ${dict_params_to_modify}!=${None}    Modify NIDD by rest api and wait onair
    ...    parameters=${dict_params_to_modify}

Captrue bip logs and Check DMRS TYPE2 Enabled
    [Documentation]    Author: Tang Tony
    ...    Description: Captrue bip logs and Check DMRS TYPE2 Enabled
    ...    capture_time: start capture, and wait for some time, then stop
    ...    filter: default value is dldata_pdschsendreq&&3gpp.subcellid == 1&& 3gpp.rnti!=65535
    ...    asil_interface: default is nac_eth2
    ...    target_file_name: l1l2bip_log_dmrs_1st_enabled
    [Arguments]    ${capture_time}=1 sec
    ...    ${target_file_name}=l1l2bip_log_dmrs_1st_enabled
    Connect to Common Unit Master
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}
    Sleep    ${capture_time}
    ${bip_log}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}

    Check DMRS TYPE2 in bip log    bip_log=${bip_log[0]}

Check DMRS TYPE2 in bip log
    [Documentation]    Author: Tony Tang
    ...                Description:check dldata_pdschsendreq have DMRS TYPE2 exist or not in bip log
    [Arguments]  ${bip_log}
    ${display_filter}    set variable if    '${PROGRAM}'>='25R2'
    ...    dldata_pdschsendreql1sw&&3gpp.rnti!=65535&&DlData_PdschGrantL1sw.pdschScramblingSeqInit==${PCELL_physCellId}
    ...    dldata_pdschsendreq&&3gpp.rnti!=65535&&DlData_PdschGrant.pdschScramblingSeqInit==${PCELL_physCellId}
    ${field_name}    set variable if    '${PROGRAM}'>='25R2'    DlData_PdschGrantL1sw.dlDmrsConfigType
    ...     DlData_PdschGrant.dlDmrsConfigType
    pcap.setup    infile=${bip_log}
    ...    display_filter=${display_filter}
    sleep    2s
    ${result}    pcap.get_field_value_by_name    field_name=${field_name}    attribute_name=show
    ${dmrs_type_2}   remove duplicates    ${result}
    ${dmrs_type_2_str}    convert to string    ${dmrs_type_2}
    Should Be Equal    ${dmrs_type_2_str}    ['2']

Captrue bip logs and Check DMRS TYPE2 Disabled
    [Documentation]    Author: Tang Tony
    ...    Description: Captrue bip logs and Check DMRS TYPE2 Disabled
    ...    capture_time: start capture, and wait for some time, then stop
    ...    filter: default value is dldata_pdschsendreq
    ...    asil_interface: default is nac_eth2
    ...    target_file_name: default is l1l2bip_log_dmrs_1st_disabled
    [Arguments]    ${capture_time}=1 sec
    ...    ${target_file_name}=l1l2bip_log_dmrs_1st_disabled
    Connect to Common Unit Master
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}
    Sleep    ${capture_time}
    ${bip_log}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}

    Check DMRS TYPE2 not in bip log    bip_log=${bip_log[0]}

Check DMRS TYPE2 not in bip log
    [Documentation]    Author: Tony Tang
    ...                Description:check check dldata_pdschsendreq have DMRS TYPE2 exist or not in bip log
    [Arguments]  ${bip_log}
    ${display_filter}    set variable if    '${PROGRAM}'>='25R2'
    ...    dldata_pdschsendreql1sw&&3gpp.rnti!=65535&&DlData_PdschGrantL1sw.pdschScramblingSeqInit==${PCELL_physCellId}
    ...    dldata_pdschsendreq&&3gpp.rnti!=65535&&DlData_PdschGrant.pdschScramblingSeqInit==${PCELL_physCellId}
    ${field_name}    set variable if    '${PROGRAM}'>='25R2'    DlData_PdschGrantL1sw.dlDmrsConfigType
    ...     DlData_PdschGrant.dlDmrsConfigType
    pcap.setup    infile=${bip_log}
    ...    display_filter=${display_filter}
    sleep    2s
    ${result}    pcap.get_field_value_by_name   field_name=${field_name}
                                    ...    attribute_name=show
    ${dmrs_type_1}   remove duplicates    ${result}
    ${dmrs_type_1_str}    convert to string    ${dmrs_type_1}
    Should Be Equal    ${dmrs_type_1_str}    ['1']

Common Tput check
    [Arguments]    ${ue_type}=${UE_TYPE}    ${duration}=120s    ${cell_index}=1   ${ignore_time}=30s
    ...    ${exp_ul}=-1    ${exp_dl}=-1    ${customized_log_name}=customized_log_name
    ${tput_log_path}    power_ue.Collect Tput     ue_type=${ue_type}    duration=${duration}
    ...    ignore_time=${ignore_time}   filter=L2Lo

    run keyword and continue on failure     Check tput via power UE optimized     cell_index=${cell_index}    direction=both
    ...    tput_log_path=${tput_log_path}   connection=GNB_OAM
    ...    exp_ul=${exp_ul}   exp_dl=${exp_dl}    target_avg_percent=0.95
    ...    min_percent=0.85    customized_log_name=${customized_log_name}

Attach UE with traffic when CB008830 enabled
    [Arguments]    ${tcpdump_collector_name}    ${dmrs_type}=2
     ...    ${duration}=180s    ${ignore_time}=1min   ${exp_ul}=-1    ${exp_dl}=-1    ${customized_log_name}=customized_log_name
    run keyword and continue on failure    Start capture F1AP log    tcpdump_collector_name=${tcpdump_collector_name}
    ...    options=-i any sctp
    Retry commercial ue attach if failed    prepare_ue_needed=${False}    4G_check=${False}
    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name}
    Check DMRS TYPE In RRC Message    log_file=${ute_log_path}    dmrs_type=${dmrs_type}

    run keyword and continue on failure    Start data transfer based on direction    data_transfer_direction=both    protocol=udp
    ...    dl_tput=${DL_TPUT_HR_IPERF}     ul_tput=${UL_TPUT_IPERF}   duration=3000s
    Common Tput check    duration=${duration}    ignore_time=${ignore_time}   exp_ul=${exp_ul}
    ...    exp_dl=${exp_dl}    customized_log_name=${customized_log_name}

add or delete 5QI via npc dynamic rule
    [Arguments]     ${imsi}    ${rule}
    ${return_code}    ${return_result}    dynamic rule submit    imsi=${imsi}    rule=${rule}
    run keyword if    '${return_result}' == 'Success'    run keywords
    ...    log    ${rule} operate Success!
    ...    AND    log to console    ${rule} operate Success!
    ...    ELSE    run keywords
    ...    log    ${rule} operate Failed!
    ...    AND    log to console    ${rule} operate Failed!
    ...    AND    fail    msg=need to check on SRN CHINA web page

Setup HR DRB 5QI8 IWK CB008830
    [Arguments]    ${tcpdump_collector_name}=HR_5QI8_DRB_setup    ${rule}=${ADD_5QI8_Rule}    ${imsi}=${tl.ues[0].imsi}
    ...    ${duration}=120s    ${ignore_time}=30s    ${exp_ul}=-1    ${exp_dl}=-1    ${customized_log_name}=customized_log_name
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_collector_name}    options=-i any sctp
    UE Setup or Release High Reliability 5QI8 DRB    rule=${rule}    imsi=${imsi}
    ${log_path}   Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name}
    Check high Reliability DRB IWK CBOO8830   display_filter=nr-rrc.rrcReconfiguration_element && nr-rrc.mcs_Table
    ...    log_file=${log_path}
    Common Tput check    duration=${duration}    ignore_time=${ignore_time}    exp_ul=${exp_ul}
    ...    exp_dl=${exp_dl}    customized_log_name=${customized_log_name}

UE Setup or Release High Reliability 5QI8 DRB
    [Documentation]    Author: chjing
    ...    ${rule}=ADD_5QI8_Rule means setup 5QI8 DRB   DEL_5QI8_Rule means delete 5QI8 DRB
    [Arguments]    ${imsi}=${tl.ues[0].imsi}    ${rule}=${ADD_5QI8_Rule}
    comment    Setup 5QI 8 drb for HR via dynamic rule tool
    run keyword and continue on failure     add or delete 5QI via npc dynamic rule    imsi=${imsi}   rule=${rule}
    sleep    20s    reason=wait for 5QI8 added

Check high Reliability DRB IWK CBOO8830
    [Documentation]    Author: chjing
    ...    mcs_table=1:qam64LowSE, mcs_table=0:256QAM
    [Arguments]    ${display_filter}=nr-rrc.rrcReconfiguration_element    ${log_file}=HR_5QI8_DRB    ${dmrs_type}=1
    ...    ${mcs_table}=1
    ${all_packets}    Load pcap file with filter    log_path_pcap=${log_file}    filter=${display_filter}
    ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.pdsch_Config//*//nr-rrc.mcs_Table
    ${nr_rrc_dl_mcs_Table}  pcap.get_field_value_by_xpath    xpath=${xpath}      attribute_name=show
    Should Be Equal    ${nr_rrc_dl_mcs_Table[0]}    ${mcs_table}   msg=dowwnlink mcs-table is wrongly configured

    ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.pusch_Config//*//nr-rrc.mcs_Table
    ${nr_rrc_ul_mcs_Table}  pcap.get_field_value_by_xpath    xpath=${xpath}      attribute_name=show
    Should Be Equal    ${nr_rrc_ul_mcs_Table[0]}    ${mcs_table}    msg=uplink mcs-table is wrongly configured
    Check DMRS TYPE In RRC Message    display_filter=${display_filter}    log_file=${log_file}    dmrs_type=${dmrs_type}

Check DMRS TYPE In RRC Message
    [Documentation]    dmrs_type=2 means DMRS TYPE 2 is configured. If DMRS is configured but no DMRS-TYPE IE, DMRS TYPE 1 is in use.
    [Arguments]    ${display_filter}=nr-rrc.rrcReconfiguration_element    ${log_file}=${tcpdump_log_name}    ${dmrs_type}=2
    ${all_packets}    Load pcap file with filter    log_path_pcap=${log_file}    filter=${display_filter}
    ${xpath}  catenate    SEPARATOR=${EMPTY}     //nr-rrc.dmrs_Type
    ${nr_rrc_dmrs_Type}  pcap.get_field_value_by_xpath    xpath=${xpath}      attribute_name=show
    Run keyword if  ${dmrs_type} == 2    Should Be Equal    ${nr_rrc_dmrs_Type[0]}    0
    ...    ELSE     Should be Empty    ${nr_rrc_dmrs_Type}

Delete HR DRB 5QI8 after VoNR call setup
    [Arguments]    ${tcpdump_collector_name}=HR_5QI8_DRB_release_VoNR_keep   ${rule}=${DEL_5QI8_Rule}    ${imsi}=${tl.ues[0].imsi}
    ...    ${dmrs_type}=1     ${duration}=120s    ${ignore_time}=30s    ${exp_ul}=-1    ${exp_dl}=-1
    ...    ${customized_log_name}=customized_log_name
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_collector_name}    options=-i any sctp
    UE Setup or Release High Reliability 5QI8 DRB   rule=${rule}    imsi=${imsi}
    ${HR_5QI8_DRB_release_with_VoNR}   Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name}
    Check DMRS TYPE In RRC Message    log_file=${HR_5QI8_DRB_release_with_VoNR}    dmrs_type=${dmrs_type}
    Common Tput check    duration=${duration}    ignore_time=${ignore_time}   exp_ul=${exp_ul}
    ...    exp_dl=${exp_dl}    customized_log_name=${customized_log_name}


Delete HR DRB 5QI8 and Check CB008830
    [Arguments]    ${tcpdump_collector_name}=HR_5QI8_DRB_release   ${rule}=${DEL_5QI8_Rule}    ${imsi}=${tl.ues[0].imsi}
    ...    ${dmrs_type}=2    ${duration}=120s    ${ignore_time}=30s    ${exp_ul}=-1    ${exp_dl}=-1
    ...    ${customized_log_name}=customized_log_name
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_collector_name}    options=-i any sctp
    UE Setup or Release High Reliability 5QI8 DRB    rule=${rule}    imsi=${imsi}
    ${HR_5QI8_DRB_release}   Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name}
    Check DMRS TYPE In RRC Message    log_file=${HR_5QI8_DRB_release}    dmrs_type=${dmrs_type}
    Common Tput check    duration=${duration}    ignore_time=${ignore_time}   exp_ul=${exp_ul}
    ...    exp_dl=${exp_dl}    customized_log_name=${customized_log_name}

HR 5QI8 DRB IWK CBOO8830 after VoNR call release
    [Arguments]    ${tcpdump_collector_name}=tcpdump_VoNR_release   ${mcs_table}=1
    ...    ${duration}=120s    ${ignore_time}=30s    ${exp_ul}=-1    ${exp_dl}=-1    ${customized_log_name}=customized_log_name
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_collector_name}    options=-i any sctp
    hang up voice call
    sleep    20s
    ${VONR_call_release}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name}
    Check high Reliability DRB IWK CBOO8830    log_file=${VONR_call_release}    mcs_table=${mcs_table}
    Common Tput check    duration=${duration}    ignore_time=${ignore_time}   exp_ul=${exp_ul}
    ...    exp_dl=${exp_dl}    customized_log_name=${customized_log_name}

VoNR IWK High Reliability And CBOO8830
    [Arguments]    ${tcpdump_collector_name}=tcpdump_VoNR_HR    ${mcs_table}=0
    ...    ${duration}=120s    ${ignore_time}=30s    ${exp_ul}=-1    ${exp_dl}=-1    ${customized_log_name}=customized_log_name
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_collector_name}    options=-i any sctp
    run keyword and continue on failure    Make a VoNR call    ue_index=${0}    try_voice_call_duration=50
    ...    vonr_num=9988    hung_up_voice_call=${False}
    sleep    20s
    ${VONR_IWK_HR_CB008830}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name}
    Check VoNR IWK High Reliability And CBOO8830    log_file=${VONR_IWK_HR_CB008830}    mcs_table=${mcs_table}
    Common Tput check    duration=${duration}    ignore_time=${ignore_time}   exp_ul=${exp_ul}
    ...    exp_dl=${exp_dl}    customized_log_name=${customized_log_name}

Setup HR DRB 5QI8 IWK CB008830 after VoNR call setup
    [Arguments]  ${tcpdump_collector_name}=tcpdump_setup_HR_after_VoNR    ${mcs_table}=0    ${imsi}=${tl.ues[0].imsi}
    ...    ${rule}=${ADD_5QI8_Rule}    ${duration}=120s    ${ignore_time}=30s    ${exp_ul}=-1    ${exp_dl}=-1
    ...    ${customized_log_name}=customized_log_name
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_collector_name}    options=-i any sctp
    UE Setup or Release High Reliability 5QI8 DRB    rule=${rule}    imsi=${imsi}
    sleep    30s
    ${HR_drb_setup_after_VoNR}   Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name}
    Check VoNR IWK High Reliability And CBOO8830    log_file=${HR_drb_setup_after_VoNR}    mcs_table=${mcs_table}
    Common Tput check    duration=${duration}    ignore_time=${ignore_time}   exp_ul=${exp_ul}
    ...    exp_dl=${exp_dl}    customized_log_name=${customized_log_name}

Check VoNR IWK CBOO8830 after HR DRB release
    [Documentation]   Author: chjing
    [Arguments]    ${display_filter}=nr-rrc.rrcReconfiguration_element    ${log_file}=VoNR_setup_log   ${dmrs_type}=1
    ${all_packets}    Load pcap file with filter    log_path_pcap=${log_file}    filter=${display_filter}
    ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.mcs_Table
    ${no_mcs_Table_after_HR_release}  pcap.get_field_value_by_xpath    xpath=${xpath}      attribute_name=show
    Should be Empty    ${no_mcs_Table_after_HR_release}     msg=mcs-table changed after HR drb release
    Check DMRS TYPE In RRC Message    display_filter=${display_filter}    log_file=${log_file}    dmrs_type=${dmrs_type}

Check VoNR IWK High Reliability And CBOO8830
    [Documentation]   Author: chjing
    ...    mcs-table=0: 256QAM, mcs-table=0: 256QAM, mcs-table=3: empty
    ...    dmrs_type=0: dmrs type 2, dmrs_type=1: empty
    [Arguments]    ${display_filter}=nr-rrc.rrcReconfiguration_element    ${log_file}=VONR_IWK_HR_CB008830   ${dmrs_type}=1
    ...    ${mcs_table}=0
    ${all_packets}    Load pcap file with filter    log_path_pcap=${log_file}    filter=${display_filter}
    ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.pdsch_Config//*//nr-rrc.mcs_Table
    ${nr_rrc_mcs_Table}  pcap.get_field_value_by_xpath    xpath=${xpath}      attribute_name=show
    Run keyword if   ${mcs_table} == 3    Should be Empty    ${nr_rrc_mcs_Table}
    ...    ELSE    Should Be Equal    ${nr_rrc_mcs_Table[0]}    ${mcs_table}
    Check DMRS TYPE In RRC Message    display_filter=${display_filter}    log_file=${log_file}    dmrs_type=${dmrs_type}
