*** Settings ***
Documentation    Contains Bandwidth feature related keywords
Library     Collections
Library     taf.config.wts    WITH NAME    wts_conf
Library     ../../../AP_P1/Resources/Python/DeltaStore.py    WITH NAME    delta_store
Library     ../../../AP_P1/Resources/Python/AdminHelper.py    WITH NAME    admin_helper
Library     ../../../AP_P1/Resources/Python/ScfHelper.py    WITH NAME    scf_helper
Library     ../../../AP_P1/scripts/Runner/IphyUpdate.py    WITH NAME    iphy_update
Library     ../../../AP_P1/scripts/Runner/APGNBControl.py    WITH NAME    ap_gnb_interface
Resource    ../../../AP_P1/Resources/robot/gnb.robot
Resource    ../../../QT/resources/Variables/common_variables.robot
Resource    ../../../gNB_P1/External_L3_Call_Common_Keywords.robot

*** Variables ***
${wts_nrarfcn}           637200:637200
${gscn}                  7886
${20MHz_coresetindex}    4
${20MHz_size}            48
${30MHz_size}            72
${40MHz_size}            96
${50MHz_size}            120
${60MHz_size}            120
${70MHz_size}            120
${80MHz_size}            120
${90MHz_size}            120
${nrarfcn}               637200
${msg1_20MHz}            6
${WTS_DIR}               /opt/wts/latest/
${wts_cfg}               basic_setup.cfg
@{coreset_params}        cceToRegMapping    coresetId    cRbStart    duration    interleaverSize
...                      regBundleSize    size
${coreset_listname}      coresetDedicated
${L3call_testsuite}      ${CURDIR}/../../../QT/L3call_Parallel.robot
${Variables_BW_Run}      -v SKIP_WTS_CONFIG_DOWNLOAD:True -v CONDITIONAL_LOGGING:True
${PARAM_FAILURE_LOG}     True
@{High_Tput_VM_cmds}     net.core.wmem_max=20971520    net.core.wmem_default=20971520
...                      net.core.rmem_max=20971520    net.core.rmem_default=20971520
${Reduced_DL_Tput}       20
${Reduced_UL_Tput}       5
@{Restrict_DL_Tput}      20MHz
@{Restrict_UL_Tput}      30MHz   20MHz
&{dlDataDmrsFdm_40}      actDlDataDmrsFdm=true    dlDataDmrsFdmThres256QamMcs=27    dlDataDmrsFdmThres64QamMcs=28

*** Keywords ***
Suite Setup For Bandwidth
    Get Dist Names
    Run And Return Rc And Output    ls -ltr ${OUTPUT_DIR}/logs
    ${scf_file}    Download SCF file    local_dir_path=${OUTPUT_DIR}    file_name=orig_SCF.xml
    Set Global Variable    ${bw_scf_file}    ${scf_file}
    Run And Return Rc And Output    cp ${WTS_DIR}/${wts_cfg} ${WTS_DIR}/${wts_cfg}_orig
    Run And Return Rc And Output    cp ${WTS_DIR}/${wts_cfg} ${WTS_DIR}/${${TOPOLOGY}}[SUITE_WTS_CFG]
    Run Keyword And Ignore Error    Set VM System Values for High Tput

Suite Teardown For Bandwidth
    Wait for gNB To Be Ready
    Sleep    1m

Set VM System Values for High Tput
    FOR    ${cmd}    IN    @{High_tput_VM_cmds}
        Run And Return Rc And Output    sudo sysctl -w ${cmd}
    END
    Run And Return Rc And Output    sudo sysctl --all

Test Teardown For Bandwidth
    Run And Return Rc And Output    cp ${WTS_DIR}/${wts_cfg}_orig ${WTS_DIR}/${wts_cfg}
    Run And Return Rc And Output    cp ${WTS_DIR}/${wts_cfg}_orig ${WTS_DIR}/${${TOPOLOGY}}[SUITE_WTS_CFG]
    Run And Return Rc And Output    sudo pkill tcpdump
    Run Keyword If    "${PARAM_FAILURE_LOG}" == "True"    Collect Logs For Failure
    Recommission GNB With Scf    ${bw_scf_file}

Get Dist Names
    ${gnb_bts_id}    admin_helper.get bts id
    Set Global Variable    ${BTS_ID}    ${gnb_bts_id}
    Set Global Variable    ${NRBTS_DISTNAME}    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    Set Global Variable    ${NRCELL1_DISTNAME}    ${NRBTS_DISTNAME}/NRCELL-1
    Set Global Variable    ${NRCELL2_DISTNAME}    ${NRBTS_DISTNAME}/NRCELL-2
    Set Global Variable    ${coreset_distname}    ${NRBTS_DISTNAME}/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1

Reboot Airphone And Check Airphone is Ready
    Run And Return Rc And Output    ssh 192.168.200.1 uptime
    ap_gnb_interface.Reboot Ap
    ap_gnb_interface.wait_for_ap_to_go_down
    ap_gnb_interface.wait_for_ap_to_be_reachable
    Run Keyword And Ignore Error    ap_gnb_interface.check_adet_ready
    Run And Return Rc And Output    ssh 192.168.200.1 uptime

Update WTS cfg file for Bandwitdh
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_DIR}/${wts_cfg} ${WTS_DIR}/${wts_cfg}_orig
    wts_conf.load_wts_cfg    file_path=${WTS_DIR}/${wts_cfg}
    wts_conf.modify    command=set_cell id=1 gnb=2    modification=nr_arfcn=${wts_nrarfcn} gscn=${gscn}
    wts_conf.modify    command=set_cell id=2 gnb=2    modification=nr_arfcn=${wts_nrarfcn} gscn=${gscn}
    wts_conf.save_wts_cfg    file_path=${WTS_DIR}/${wts_cfg}
    Run    cp ${WTS_DIR}/${wts_cfg} ${WTS_DIR}/${${TOPOLOGY}}[SUITE_WTS_CFG]

Update Configuration for 20MHz
    Update WTS cfg file for Bandwitdh
    Update Iphy file for Bandwitdh
    Reboot Airphone And Check Airphone is Ready

Set Variables for Suite Run
    [Arguments]    ${chbw}
    ${UL_Tput}    Set Variable If    "${chbw}" in @{Restrict_UL_Tput}    -v HighTput_ul_rate:${Reduced_UL_Tput}    ${EMPTY}
	${DL_Tput}    Set Variable If    "${chbw}" in @{Restrict_DL_Tput}    -v HighTput_dl_rate:${Reduced_DL_Tput} -v HTp:False    ${EMPTY}
	${variable_values}    Catenate    ${Variables_BW_Run}    ${UL_Tput}    ${DL_Tput}    -v SAVE_WTS_PCAP_FLAG:False
	Set Test Variable    ${Variables_BW_Run}    ${variable_values}

Update Bandwidth related Params and Check L3 call
    [Arguments]    ${chbw}
    Set Test Variable    ${PARAM_FAILURE_LOG}     True
    Run And Return Rc And Output    mkdir -p ${OUTPUT_DIR}/logs_${chbw}
    Wait for gNB To Be Ready
    Run Keyword If    "${chbw}" == "20MHz"    Update Configuration for 20MHz
    Sleep    1m
    Update gNB SCF for Bandwidth    ${chbw}
    Sleep    1m
    Wait for gNB To Be Ready
    Set Variables for Suite Run    ${chbw}
    Run And Return Rc And Output    rm /opt/wts/latest/Sos*tgz
    Run And Return Rc And Output    ls -ltr /home/ute/logs/
    Run And Return Rc And Output    rm -rf /home/ute/logs/*
    Perform L3 call and check status    topology=${TOPOLOGY}    suite=${L3call_testsuite}    variable_section=${Variables_BW_Run}
    Set Test Variable    ${PARAM_FAILURE_LOG}     False
    Run And Return Rc And Output    ls -ltr ${OUTPUT_DIR}/logs
    Run And Return Rc And Output    mv ${OUTPUT_DIR}/logs ${OUTPUT_DIR}/logs_${chbw}
    Run And Return Rc And Output    rm ${OUTPUT_DIR}/logs/*tgz
    Run And Return Rc And Output    mv ${EXECDIR}/logs ${OUTPUT_DIR}/logs_${chbw}
    Run And Return Rc And Output    cp ${OUTPUT_DIR}/${TOPOLOGY}_L3_call.html ${OUTPUT_DIR}/logs_${chbw}/${TOPOLOGY}_L3_call_${chbw}.html
    Run And Return Rc And Output    cp ${OUTPUT_DIR}/${TOPOLOGY}_L3_call.xml ${OUTPUT_DIR}/logs_${chbw}/${TOPOLOGY}_L3_call_${chbw}.xml
    Run And Return Rc And Output    cp ${OUTPUT_DIR}/L3_debug.log ${OUTPUT_DIR}/logs_${chbw}/L3_debug_${chbw}.log
    Run And Return Rc And Output    rm /opt/wts/latest/Sos*tgz
    Run And Return Rc And Output    cp ${OUTPUT_DIR}/*Evidence*txt ${OUTPUT_DIR}/logs_${chbw}/
    Run And Return Rc And Output    ls -ltr ${OUTPUT_DIR}/logs_${chbw}/
    Run And Return Rc And Output    rm ${OUTPUT_DIR}/logs/Sos*tgz
    Run And Return Rc And Output    rm ${EXECDIR}/logs/Sos*tgz
    Run And Return Rc And Output    rm -rf ${EXECDIR}/logs/udpsyslog/
    Sleep   1m

Collect Logs For Failure
    Run And Return Rc And Output    chmod 777 ${WTS_DIR}/sosReport_ASIL/*
    ${cmd}    Set Variable    cd ${WTS_DIR}/ && ${WTS_DIR}/sosReport_ASIK_ASIL.sh -c -s -d > /dev/null 2>\&1
    Run And Return Rc And Output    ${cmd}
    Run And Return Rc And Output    mv /opt/wts/latest/SosReport*.tgz ${OUTPUT_DIR}/logs_${chbw}/
    Run And Return Rc And Output    ls ${OUTPUT_DIR}/logs_${chbw}/SosReport*.tgz
    File Should Exist    ${OUTPUT_DIR}/logs_${chbw}/SosReport*.tgz

Initialize Delta Store and Set Coresetparams
    [Arguments]    ${chbw}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    ${original_scf_path}    Download SCF file    local_dir_path=${OUTPUT_DIR}    file_name=SCF_orig_${chbw}.xml
    set test variable    ${original_scf_path}
    ${coresetDedicated_parameters}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}
    ...    ${coreset_params}    ${coreset_distname}    ${coreset_listname}
    Set To Dictionary    ${coresetDedicated_parameters}    size    ${${chbw}_size}
    Log To Console    ${coresetDedicated_parameters}
    delta_store.add_list_parameters_to_delta    dist_name=${coreset_distname}    list_name=coresetDedicated
    ...    &{coresetDedicated_parameters}
    [Return]    ${coresetDedicated_parameters}

Update gNB SCF Params for 20MHz Bandwidth
    [Arguments]    ${chbw}
    ${coresetDedicated_parameters}    Initialize Delta Store and Set Coresetparams    ${chbw}
    delta_store.update managed object and parameter to delta
    ...        dist_name=${NRCELL1_DISTNAME}    gscnOrSsPbchArfcn=${gscn}    nrarfcn=${nrarfcn}    chBw=${chbw}    msg1FrequencyStart=${msg1_20MHz}
    delta_store.update managed object and parameter to delta
    ...    dist_name=${NRCELL2_DISTNAME}    gscnOrSsPbchArfcn=${gscn}    nrarfcn=${nrarfcn}    chBw=${chbw}    msg1FrequencyStart=${msg1_20MHz}
    ${delta_store}    Collect Delta Store
    Log To Console    ${delta_store}
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

Update gNB SCF Params for 40MHz Bandwidth
    [Arguments]    ${chbw}
    ${coresetDedicated_parameters}    Initialize Delta Store and Set Coresetparams    ${chbw}
    delta_store.add_list_parameters_to_delta    dist_name=${NRCELL1_DISTNAME}    list_name=dlDataDmrsFdm
    ...    &{dlDataDmrsFdm_40}
    delta_store.add_list_parameters_to_delta    dist_name=${NRCELL2_DISTNAME}    list_name=dlDataDmrsFdm
    ...    &{dlDataDmrsFdm_40}
    delta_store.update managed object and parameter to delta
    ...        dist_name=${NRCELL1_DISTNAME}    chBw=${chbw}    actUl256Qam=true
    delta_store.update managed object and parameter to delta
    ...        dist_name=${NRCELL2_DISTNAME}    chBw=${chbw}    actUl256Qam=true
    ${delta_store}    Collect Delta Store
    Log To Console    ${delta_store}
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

Update gNB SCF for Bandwidth
    [Arguments]    ${chbw}
    Run Keyword If    "${chbw}" == "20MHz"    Update gNB SCF Params for 20MHz Bandwidth    ${chbw}
    ...    ELSE IF    "${chbw}" == "40MHz"    Update gNB SCF Params for 40MHz Bandwidth    ${chbw}
    ...    ELSE    Generic BW gNB SCF Params Updates    ${chbw}

Generic BW gNB SCF Params Updates
    [Arguments]    ${chbw}
    ${coresetDedicated_parameters}    Initialize Delta Store and Set Coresetparams    ${chbw}
    delta_store.update managed object and parameter to delta
    ...        dist_name=${NRCELL1_DISTNAME}    chBw=${chbw}
    delta_store.update managed object and parameter to delta
    ...        dist_name=${NRCELL2_DISTNAME}    chBw=${chbw}
    Run Keyword If    "${chbw}" == "70MHz"    delta_store.update managed object and parameter to delta
    ...        dist_name=${NRCELL1_DISTNAME}    chBw=70 MHz
    Run Keyword If    "${chbw}" == "70MHz"    delta_store.update managed object and parameter to delta
    ...        dist_name=${NRCELL2_DISTNAME}    chBw=70 MHz
    ${delta_store}    Collect Delta Store
    Log To Console    ${delta_store}
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

Update Iphy file for Bandwitdh
    iphy_update.set_iphy_file_to_be_updated    backup_folder=${OUTPUT_DIR}/iphy_backup
    iphy_update.modify_gscn    ${gscn}    old_gscn=7880
    iphy_update.copy_iphy_file_to_ap
