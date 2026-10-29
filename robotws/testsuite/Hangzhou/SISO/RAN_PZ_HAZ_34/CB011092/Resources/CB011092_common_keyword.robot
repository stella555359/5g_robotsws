*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Variables    ../TestData/11092_variables.py
Library     ../lib/CB011092.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/resources/cbrs_common_keywords.robot

Documentation
...    author: Jiangjing Lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
@{nr_cell_1}    ${1}
${version_target}    SBTS25R1_ENB_0000_000943_000000
${sw_url}    https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/


*** Keywords ***
Sas Server Prepare
    Download Sas Server
    ${cmd}    Set Variable    pip install -i https://artifactory-hz1.ext.net.nokia.com/artifactory/api/pypi/ta-lib-5g-virtual/simple -U pyOpenSSL
    ${rc}    ${output}    Run and Return RC and Output    ${cmd}
    Should Be Equal As Integers    ${rc}    0    msg=${output}
    delete_icmp_policy
    Run Keyword And Ignore Error    kill SAS server started by manual
    Activate feature CBRS By Coam    actCbrsEnhMeas=${True}
    Start SAS server    path=${sas_3}

Sas Server Stop
    save_sas_log    dstFile=${TS_CASE_LOG_PATH}/SAS_Sim.log
    Deactivate feature CBRS By Coam    actCbrsEnhMeas=${False}
    kill process for SAS server

CB011092_C_General_SiSo_E2E_system_setup_with_data_transfer_conducted_C10
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _C10.xml
    Commissioning SCF And Check On Air    ${SCF_upload}
    log to console    step 1: block and unblock all cells
    ${nr_cell_all}    Get All Nr Cells
    Get X2 link shutdown waiting time
    selenium login and disable screen lock
    Block cells and check status    block_list=${nr_cell_all}    check_alarm=${False}    gnb_type=${gNb_CuType}
    UnBlock cells and check status    block_list=${nr_cell_all}    check_alarm=${False}    gnb_type=${gNb_CuType}
    log to console    step 2: make call on cell1
    data_transfer_common    tput_self_define=${tput_11092}    cell_id=${nr_cell_1}    duration=${300}
    ...    target_avg_percent=0.95
    FOR    ${index}    IN RANGE    3
        log to console    +++++++++++++++++++++++++++++++++ supercell del & add ${index} +++++++++++++++++++++++++++++++
        log to console    step 3: remove supercell 3
        Delete supercell
        Wait until keyword succeeds    10min    10s    verify all cells should be onair
        ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
        Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
        log to console    step 4: add back supercell 3
        Add supercell for C10
        Wait until keyword succeeds    10min    10s    verify all cells should be onair
    END
    [Teardown]    run keyword and ignore error    selenium logout and close browser

E2E_TL_Activation_Reset_with_OAM_KPI_11092
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _trimode.xml
    Commissioning SCF And Check On Air    ${SCF_upload}
    E2E_TL_Activation_Reset_with_OAM_KPI_SG08

CB011092_C_General_SiSo_E2E_system_setup_with_data_transfer_conducted_C11
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _C11.xml
    Commissioning SCF And Check On Air    ${SCF_upload}
    log to console    step 1: block and unblock all cells
    ${nr_cell_all}    Get All Nr Cells
    Get X2 link shutdown waiting time
    selenium login and disable screen lock
    Block cells and check status    block_list=${nr_cell_all}    check_alarm=${False}    gnb_type=${gNb_CuType}
    UnBlock cells and check status    block_list=${nr_cell_all}    check_alarm=${False}    gnb_type=${gNb_CuType}
    log to console   step 2: power off RU
    power off and on rus
    power off and on rus
    Wait until keyword succeeds    10min    5s    verify all cells should be onair
    log to console    step 3: make call on cell1
    data_transfer_common    tput_self_define=${tput_11092}    cell_id=${nr_cell_1}    duration=${300}
    ...    target_avg_percent=0.92    min_percent=0.85
    [Teardown]    run keyword and ignore error    selenium logout and close browser

E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _C11.xml
    Commissioning SCF And Check On Air    ${SCF_upload}
    ${gnb_original_version}    coam.get_sw_version    timeout=60    connection=GNB_OAM
    log to console    current version is: ${gnb_original_version}
    log to console    target version is: ${version_target}
    ${result}    OperatingSystem.Run    command=ls -l /home/ute/${version_target}*.zip|wc -l
    Run keyword if    ${result}!=1    Download SW Build from artifactory    target_version=${version_target}    sw_url=${sw_url}   ute_path=/home/ute
    ${result}    OperatingSystem.Run    command=ls -l /home/ute/SBTS*_A54.zip|grep -v ${version_target}|wc -l
    Run keyword if    ${result}!=0    Delete upgrade file except target version
    ${package_path}    set variable    /home/ute/${version_target}_release_BTSSM_downloadable_A54.zip
    ${tmp}    Split String    ${gnb_original_version}    separator=_    max_split=1
    ${gnb_original_version_info}    set variable    ${tmp[-1]}
    ${tmp}    Split String    ${version_target}    separator=_    max_split=1
    ${target_version_info}    set variable    ${tmp[-1]}
    FOR    ${index}    IN RANGE    ${0}    ${1}
        log to console    upgrade to target version
        coam.update_software    sw_package=${package_path}    timeout=2400    connection=GNB_OAM
        check software version changed    compared_version=${target_version_info}
        should be equal    '${version_info}'    '${target_version_info}'
        Wait until keyword succeeds    10min    5s    verify all cells should be onair
        log to console    rollback to original version
        coam.rollback_software    connection=GNB_OAM
        check software version changed    compared_version=${gnb_original_version_info}
        should be equal    '${version_info}'    '${gnb_original_version_info}'
        Wait until keyword succeeds    10min    5s    verify all cells should be onair
    END

Delete upgrade file except target version
    ${files_first}    OperatingSystem.Run    command=ls -l /home/ute/SBTS*_A54.zip|grep -v ${target_version}|awk '{print $9}'
    @{files}    split string    ${files_first}    \n
    FOR    ${item}    IN    @{files}
        OperatingSystem.Run    command=sudo rm -rf ${item}
    END

check software version changed
    [Arguments]    ${compared_version}
    FOR    ${index}    IN RANGE    ${0}    ${60}
        ${version}    Wait Until Keyword Succeeds    5min  5s    coam.get_sw_version    timeout=60    connection=GNB_OAM
        ${tmp}    Split String    ${version}    separator=_    max_split=1
        ${version_info}    set variable    ${tmp[-1]}
        set test variable    ${version_info}
        Exit For Loop If  '${version_info}' == '${compared_version}'
        sleep    10s
    END

E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _C11.xml
    Commissioning SCF And Check On Air    ${SCF_upload}
    add flag 0x4F0214 in swconfig file and sign    flag_0x4F0214=${0}
    log to console    tl reset 10 times
    FOR    ${index}    IN RANGE    ${1}    ${1}
        coam.reset_site    connection=GNB_OAM
        sleep    5s
        Wait until keyword succeeds    10min    5s    verify all cells should be onair
    END
    delete flag 0x4F0214 in swconfig file and sign

CB011092_C_General_SiSo_E2E_system_setup_with_data_transfer_A6_C9_combination
    log to console    +++++++++++++Loading Supercell_trimode SCF+++++++++++++++++++++
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _trimode.xml
    Commissioning SCF And Check On Air    ${SCF_upload}
    log to console    +++++++++++++Loading NRFDD_NRTDD SCF+++++++++++++++++++++
    AlarmWatchdog.add_allow_alarms    fault_id=6832
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _NRFDD_NRTDD.xml
    Commissioning SCF And Check RU On Air    scf_file_path=${SCF_upload}
    Sas Server Prepare
    Wait until keyword succeeds    10min    10s    verify all cells should be onair
    Sas Server Stop
    log to console    +++++++++++++Loading A6_C9 SCF+++++++++++++++++++++
    Connect to gnb coam via ssl    connection=GNB_OAM
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _A6_C9.xml
    Commissioning SCF And Check RU On Air    scf_file_path=${SCF_upload}
    Sas Server Prepare
    log to console    make call on cell1
    data_transfer_common    tput_self_define=${tput_11092}    cell_id=${nr_cell_1}    duration=${300}   target_avg_percent=0.94
    #[Teardown]    Sas Server Stop

CB011092_C_General_SiSo_SuperCell_Reconfiguration_C9_add_one_subcell
    [Arguments]    ${connection}=GNB_OAM
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _C9.xml
    Commissioning SCF And Check On Air    ${SCF_upload}
    log to console    step 1: lock and unlock all RUs
    ${ru_id_list}    Get All RU Index
    FOR    ${ru_id}  IN  @{ru_id_list}
        coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_id}    connection=${connection}    timeout=60s
        sleep    2s
    END
    FOR    ${ru_id}  IN  @{ru_id_list}
        coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_id}    connection=${connection}    timeout=60s
        sleep    2s
    END
    Wait until keyword succeeds    10min    5s    verify all cells should be onair
    selenium login and disable screen lock
    log to console    step 2: add one supercell
    Add subcell for C9
    Wait until keyword succeeds    10min    10s    verify all cells should be onair
    [Teardown]    run keyword and ignore error    selenium logout and close browser

CB011092_A_General_SiSo_Online_Cell_Addition_Deletion_A8
    [Arguments]    ${connection}=GNB_OAM
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _A8.xml
    Commissioning SCF And Check On Air    ${SCF_upload}
    FOR    ${index}    IN RANGE    3
        log to console    +++++++++++++++++++++++++++++++++ cell delete and add ${index} +++++++++++++++++++++++++++++++
        Online Cell addition deletion
    END
    log to console    block and unblock all cells
    ${nr_cell_all}    Get All Nr Cells
    Get X2 link shutdown waiting time
    selenium login and disable screen lock
    Block cells and check status    block_list=${nr_cell_all}    check_alarm=${False}    gnb_type=${gNb_CuType}
    UnBlock cells and check status    block_list=${nr_cell_all}    check_alarm=${False}    gnb_type=${gNb_CuType}
    log to console    step2: lock and unlock all RUs
    ${ru_id_list}    Get All RU Index
    FOR    ${ru_id}  IN  @{ru_id_list}
        coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_id}    connection=${connection}    timeout=60s
        sleep    2s
    END
    FOR    ${ru_id}  IN  @{ru_id_list}
        coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_id}    connection=${connection}    timeout=60s
        sleep    2s
    END
    Wait until keyword succeeds    10min    5s    verify all cells should be onair
    log to console    step3: rf module power reset
    power off and on rus
    power off and on rus
    Wait until keyword succeeds    10min    5s    verify all cells should be onair
    [Teardown]    run keyword and ignore error    selenium logout and close browser

CB011092_A_General_SiSo_E2E_system_setup_with_data_transfer_A4_A5_combination
    [Arguments]    ${connection}=GNB_OAM
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _A4_A5.xml
    Commissioning SCF And Check On Air    ${SCF_upload}
    log to console    step1: cell delete and add
    Online Cell addition deletion
    Get X2 link shutdown waiting time
    selenium login and disable screen lock
    log to console    block and unblock all cells
    ${nr_cell_all}    Get All Nr Cells
    Block cells and check status    block_list=${nr_cell_all}    check_alarm=${False}    gnb_type=${gNb_CuType}
    UnBlock cells and check status    block_list=${nr_cell_all}    check_alarm=${False}    gnb_type=${gNb_CuType}
    log to console    step2: lock and unlock all RUs
        ${ru_id_list}    Get All RU Index
    FOR    ${ru_id}  IN  @{ru_id_list}
    coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_id}    connection=${connection}    timeout=60s
        sleep    2s
    END
    FOR    ${ru_id}  IN  @{ru_id_list}
        coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_id}    connection=${connection}    timeout=60s
        sleep    2s
    END
    Wait until keyword succeeds    10min    5s    verify all cells should be onair
    log to console    step3: make call on cell1
    data_transfer_common    tput_self_define=${tput_11092}    cell_id=${nr_cell_1}    duration=${300}
    [Teardown]    run keyword and ignore error    selenium logout and close browser

Delete supercell
    [Arguments]    ${cell_id}=${3}    ${index_cellgroup}=${2}
    log to console    delete nrcell ${cell_id} under MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}    timeout=15
    sleep    2s
    log to console    delete nrcellgroup ${index_cellgroup} under MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${index_cellgroup}    timeout=15
    sleep    2s
    log to console    delete refNrCellGroup for cellgroup ${index_cellgroup}
    selenium_coam.remove_element    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1    filter_param=Reference to cell group
    ...    node_index=${index_cellgroup}
    log to console    delete LCELNR ${cell_id} under MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}    timeout=15
    sleep    2s
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${180}

Add supercell for C10
    [Arguments]    ${cell_id}=${3}    ${index_cellgroup}=${2}    ${physCellId}=${1002}    ${ru_id}=${4}
    log to console    add nrcell3 and nrcellgroup2 under MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    include_subobject=${True}   id_value=${cell_id}    timeout=15
    sleep    10s
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-0
    ...    include_subobject=${True}   id_value=${index_cellgroup}    timeout=15
    sleep    10s
    log to console    add lcrld ${cell_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=Local cell resource ID    new_value=${cell_id}   abbr=lcrId
    log to console    modify physCellId to ${physCellId}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=Physical cell identifier    new_value=${physCellId}    abbr=physCellId
    log to console    add nrCellList ${cell_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${index_cellgroup}
    ...    filter_param=List of NR cells assigned to cell group    node_index=${0}    new_value=${cell_id}    abbr=nrCellList
    log to console    add refNrCellGroup ${index_cellgroup}
    selenium_coam.add_element    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1    filter_param=Reference to cell group
    ...    abbr=refNrCellGroup
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${index_cellgroup}    new_value=${index_cellgroup}    abbr=refNrCellGroup
    log to console    add LCELNR-${cell_id} under MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1. it is copy from LCELNR-1
    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    ...    include_subobject=${True}   id_value=${cell_id}    timeout=15
    sleep    10s
    log to console    modify antl port for channelgrpuo 1-2 under LCELNR-${cell_id}
    Modify ANTL For ChannelGroup    cell_id=${cell_id}    channelgroup_id=1    connect_ru_id=${ru_id}    ANTL_list=${antl_list_last_half}
    Modify ANTL For ChannelGroup    cell_id=${cell_id}    channelgroup_id=2    connect_ru_id=${ru_id}    ANTL_list=${antl_list_first_half}
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${180}

Add subcell for C9
    [Arguments]
    log to console    Modify 1supercell&3subcells to 1supercell&4subcells
    log to console    add channelgroup 4 under LCELNR-1
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1
    ...    include_subobject=${True}   id_value=${4}    timeout=15
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan
    log to console    modify ANTL for channelgroup 4
    Modify ANTL For ChannelGroup    channelgroup_id=4    connect_ru_id=1    ANTL_list=${antl_list_last_half}
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${180}

Modify ANTL For ChannelGroup
    [Arguments]     ${ANTL_list}    ${cell_id}=1    ${channelgroup_id}=1    ${connect_ru_id}=1
    ${modify_params}  create list
    FOR    ${index}    IN RANGE    1    9
        ${antl_index}    set variable    ${ANTL_list[${index}-1]}
        ${item}  create dictionary  filter_param=Distinguished Name of antenna line   p_name=antlDN
        ...    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${channelgroup_id}/CHANNEL-${index}
        ...    value=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${connect_ru_id}/ANTL-${antl_index}
        append to list    ${modify_params}    ${item}
    END
    Modify Parameters On Webem    modify_params=${modify_params}    is_activate=${False}

Load SCF A6_C9
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _A6_C9.xml
    Connect to gnb coam via ssl    connection=GNB_OAM
    Commissioning SCF And Check On Air    ${SCF_upload}
    COAM Teardown gnb connections    connection=GNB_OAM

add flag 0x4F0214 in swconfig file and sign
    [Arguments]    ${flag_0x4F0214}
    Connect to Common Unit Master    alias=ASIK Master
    csn.download file    remote_path=/ffs/run/swconfig.txt    local_path=/tmp/swconfig.txt   connection=ASIK Master
    add_or_modify_flag_in_swconfig    flag_0x4F0214=${flag_0x4F0214}    swconfig_path=/tmp/swconfig.txt
    csn.Upload File    local_path=/tmp/swconfig.txt    remote_path=/ffs/run/swconfig.txt    connection=ASIK Master
    csn.execute    crasign /ffs/run/swconfig.txt    connection=ASIK Master
    sleep    5s
    coam.reset_site    connection=GNB_OAM
    sleep    120s
    Wait until keyword succeeds    10min    5s    verify all cells should be onair

delete flag 0x4F0214 in swconfig file and sign
    Connect to Common Unit Master    alias=ASIK Master
    csn.download file    remote_path=/ffs/run/swconfig.txt    local_path=/tmp/swconfig.txt   connection=ASIK Master
    remove_flag_in_swconfig    swconfig_path=/tmp/swconfig.txt
    csn.Upload File    local_path=/tmp/swconfig.txt    remote_path=/ffs/run/swconfig.txt    connection=ASIK Master
    csn.execute    crasign /ffs/run/swconfig.txt    connection=ASIK Master
    sleep    5s
    coam.reset_site    connection=GNB_OAM
    sleep    120s
    Wait until keyword succeeds    10min    5s    verify all cells should be onair

Case Preparation CB0011092
    &{fault_7311}     Create Dictionary     faultId=${7311}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7311}
    set suite variable  ${ALLOWED_FAULT}
    &{fault_7311}     Create Dictionary     faultId=${7311}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_7311}
    set suite variable  ${ALLOWED_HISTORY_FAULT}
    AlarmWatchdog.add_allow_alarms    fault_id=7311
