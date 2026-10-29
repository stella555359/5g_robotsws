*** Settings ***
Library    ../lib/CB008941.py
Library     taf.rfrl.bts.commissioning
Variables    ./variables_8941.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

Documentation
...    author: Jiangjing Lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
@{cell_id_list}    ${1}
@{ue_list_0}    ${0}
@{group1}    ${0}    ${1}    ${2}    ${3}
@{group2}    ${0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}    ${11}

*** Keywords ***
Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF-AB-1
    [Arguments]    ${ru_index}=${1}    ${asik_alias}=ASIK Master
    # run on 1904
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1
    ${soap_log_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
    log to console    check endpointCapacitySharingGroup have 0-3
    ${group_list}    get_group_ids_from_soap    filepath=${soap_log_path}
    Should Be Equal    ${group_list}    ${group1}
    log to console    check group 0
    ${status}    check_group_info    filepath=${soap_log_path}    group_id=${0}    maxUplaneSectionHeadersPerSymbol=${18}
    ...    maxUplaneSectionHeadersPerSlot=${252}    Endpoints=${16}
    Should Be Equal    ${status}    ${True}
    log to console    check group 2
    ${status}    check_group_info    filepath=${soap_log_path}    group_id=${2}    maxUplaneSectionHeadersPerSymbol=${26}
    ...    maxUplaneSectionHeadersPerSlot=${78}    Endpoints=${16}
    Should Be Equal    ${status}    ${True}
    log to console    L3 call
    Sigspark_L3call    ue_index_list=${ue_list_0}    tput_expect=${peak_info}
    [Teardown]  run keywords  run keyword and ignore error    csn.disconnect   connection=RU_${ru_index}    AND
    ...    run keyword and ignore error    csn.Disconnect   connection=${asik_alias}

Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF-AA-1
    [Arguments]    ${ru_index}=${1}    ${asik_alias}=ASIK Master
    # run on 1131
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1
    ${soap_log_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
    log to console    check endpointCapacitySharingGroup have 0-11
    ${group_list}    get_group_ids_from_soap    filepath=${soap_log_path}
    Should Be Equal    ${group_list}    ${group2}
    log to console    check group 0
    ${status}    check_group_info    filepath=${soap_log_path}    group_id=${1}    maxUplaneSectionHeadersPerSymbol=${18}
    ...    maxUplaneSectionHeadersPerSlot=${252}    Endpoints=${16}
    Should Be Equal    ${status}    ${True}
    log to console    check group 2
    ${status}    check_group_info    filepath=${soap_log_path}    group_id=${3}    maxUplaneSectionHeadersPerSymbol=${26}
    ...    maxUplaneSectionHeadersPerSlot=${78}    Endpoints=${8}
    Should Be Equal    ${status}    ${True}
    log to console    L3 call
    Get UE From Init File and Make call    cell_list=${cell_id_list}    duration=100    4G_check=True
    [Teardown]  run keywords  run keyword and ignore error    csn.disconnect   connection=RU_${ru_index}    AND
    ...    run keyword and ignore error    csn.Disconnect   connection=${asik_alias}

Modify Swconfig File
    [Arguments]    ${swconfig_path}    ${asik_alias}=ASIK Master
    Connect to Common Unit Master    alias=${asik_alias}
    Upload Swconfig File    swconfig_path=${swconfig_path}
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=${asik_alias}

Upload Swconfig File
    [Arguments]    ${swconfig_path}    ${asik_alias}=ASIK Master
    ${swconfig_file_name}    Fetch from right    ${swconfig_path}    /
    log to console    upload swconfig file
    csn.Upload File    local_path=${swconfig_path}    remote_path=/ffs/run/swconfig.txt    connection=${asik_alias}
    sleep    1s
    log to console    rename uploaded new swconfig file
    csn.execute    mv /ffs/run/${swconfig_file_name} /ffs/run/swconfig.txt    connection=${asik_alias}
    sleep    1s
    log to console    crasign...
    csn.execute    crasign /ffs/run/swconfig.txt    connection=${asik_alias}
    sleep    1s
    log to console    craverify...
    csn.execute    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7    connection=${asik_alias}
    sleep    1s
    log to console    reboot testline...
    Connect to gnb coam via ssl
    coam.reset_site    connection=GNB_OAM
    sleep    120s
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Sigspark_L3call
      [Arguments]    ${ue_index_list}    ${tput_expect}    ${ue_type}=huawei_sigspark    ${duration}=300    ${protocol}=udp
      ...    ${attach_mode}=5G_NSA    ${gnb_index}=${0}    ${du_index}=0    ${iperf_type}=via_command
      ...    ${target_avg_percent}=0.95    ${min_percent}=0.85
      ${ue_cell_mapping}    create dictionary
      ${ue_tput_mapping}    create dictionary
      FOR    ${ue_index}    IN    @{ue_index_list}
          log to console    \n***Prepare for UE_${ue_index}***
          Wait Until Keyword Succeeds    5min    30s    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
          Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
          Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
          Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
          log to console    \n***Attach for UE_${ue_index}***
          power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}
          Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
          Connect to Common Unit Master
          ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt
          ...    alias=ASIK Master
          csn.Disconnect  connection=ASIK Master
          log to console    UE_${ue_index} attached to cell ${cell_id}
          set to dictionary    ${ue_cell_mapping}    ${ue_index}    ${cell_id}
          ${ue_mode}    Replace String    ${attach_mode}    5G_    ${EMPTY}
          log to console    \n***Start traffic for UE_${ue_index}***
          ${duration_call}    Evaluate    ${duration}+${600}*2
          ${dl_tp}    set variable    ${tput_expect['${cell_id}']['dl_tp']}
          ${ul_tp}    set variable    ${tput_expect['${cell_id}']['ul_tp']}
          power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${dl_tp}/sec
          ...    duration=${duration_call}    protocol=${protocol}    ue_mode=${ue_mode}
          power_ue.Start traffic    ue_type=Samsung    ue_index=${ue_index}    direction=ul    throughput=${ul_tp}
          ...    duration=${duration_call}    protocol=${protocol}    iperf_type=${iperf_type}
      END
      log to console    \n***Start Collect Throughput for UE***
      ${tput_log}    power_ue.Collect Tput    ue_type=Samsung    duration=${duration}
      FOR    ${ue_index}    IN    @{ue_index_list}
          ${cell_id}     Get From Dictionary    ${ue_cell_mapping}     ${ue_index}
          ${dl_exp}    set variable    ${tput_expect['${cell_id}']['dl_exp']}
          ${ul_exp}    set variable    ${tput_expect['${cell_id}']['ul_exp']}
          ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
          ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
          ${cell_id}    Create List    ${cell_id}
          log to console    \n***Check tput for UE_${ue_index}***
          power_ue.Check Bi Tput    ue_type=huawei    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
          ...    dltarget_throughput=${dl_exp}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
      END
      [Teardown]    run keyword and ignore error    UE detach and stop traffic    ue_index_list=${ue_index_list}    ue_type=${ue_type}

UE detach and stop traffic
    [Arguments]    ${ue_index_list}    ${ue_type}
    FOR    ${ue_index}    IN    @{ue_index_list}
          log to console    \n***Stop traffic and Detach for UE_${ue_index}***
          run keyword and ignore error  power_ue.Stop traffic   ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
          run keyword and ignore error  power_ue.Stop traffic   ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
          run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_type}    ue_index=${ue_index}
    END

L3call_Loki_based_DU_with_short_PUCCH_FDBF-AA-8
    # run on 1131
    log to console    import scf
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _shortpucch.xml
    Selenium Login And Disable Screen Lock
    Commissioning SCF And Check On Air    scf_path=${SCF_upload}
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    log to console    L3 call
    Get UE From Init File and Make call    cell_list=${cell_id_list}    duration=100    4G_check=True
    [Teardown]    Selenium Logout And Close Browser

L3call_Loki_based_DU_with_short_PUCCH_FDBF-AB-8
    # run on 1904
    log to console    import scf
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _shortpucch.xml
    Selenium Login And Disable Screen Lock
    Commissioning SCF And Check On Air    scf_path=${SCF_upload}
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    log to console    L3 call
    Sigspark_L3call    ue_index_list=${ue_list_0}    tput_expect=${peak_info}
    [Teardown]    Selenium Logout And Close Browser
