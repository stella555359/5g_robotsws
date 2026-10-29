*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Variables    ../TestData/11091_variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/resources/cbrs_common_keywords.robot

Documentation
...    author: Jiangjing Lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${version_target}    SBTS00_ENB_9999_250423_000021
${sw_url}    https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/
@{nr_cell_3}    ${3}
${UTESASip}    ${tl.test_pc.default_ssh_connection_details.addr}
${conf_path}    ${CURDIR}/conf
${CB011091_E1_E3.conf}    ${conf_path}/CB011091_E1_E3.conf

*** Keywords ***
E2E_TL_Activation_Reset_with_OAM_KPI_CB011091
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _E1.xml
    Commissioning SCF And Check All RU On Air    ${SCF_upload}
    Run Keyword And Ignore Error    Set primarySasServer value    value=${UTESASip}:4433
    Activate feature CBRS By Coam
    start SAS server    path=${sas_3}
    E2E_TL_Activation_Reset_with_OAM_KPI_SG08   Max_loop=${1}

CB011091_G_General_SiSo_SuperCell_Reconfiguration_G2_to_1supercell_per_6subcell
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _G2.xml
    Commissioning SCF And Check All RU On Air    ${SCF_upload}
    Run Keyword And Ignore Error    Set primarySasServer value    value=${UTESASip}:4433
    start SAS server    path=${sas_3}
    selenium login and disable screen lock
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Wait Until Keyword Succeeds   3x   10s    Deactivate feature CBRS By Coam
    log to console    modify 2*1supercell_3subcell to 3*1supercel_2subcell
    modify 2*1supercell_3subcell to 3*1supercel_2subcell
    Run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=GNB_OAM
    Check All RU Onair
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    log to console    modify 3*1supercel_2subcell to 1supercel_6subcelll
    modify 3*1supercel_2subcell to 1supercel_6subcelll
    Run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=GNB_OAM
    Check All RU Onair
    sleep    120s
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Wait Until Keyword Succeeds   3x   10s    Activate feature CBRS By Coam
    Wait Until Keyword Succeeds    10 min    10 sec    Verify all cells should be onair
    [Teardown]    run keywords    Run keyword and ignore error    Selenium Logout And Close Browser    AND
    ...    Run keyword and ignore error    COAM Teardown gnb connections


modify 2*1supercell_3subcell to 3*1supercel_2subcell
    log to console    delete channel group 3 under LCELNR-1
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3
    ...    timeout=15
    sleep    2s
    log to console    delete channel group 3 under LCELNR-2
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-3
    ...    timeout=15
    sleep    2s
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan
    sleep    5s
    log to console    add nrcell3 and nrcellgroup2
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    include_subobject=${True}   id_value=3    timeout=15
    sleep    10s
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-0
    ...    include_subobject=${True}   id_value=2    timeout=15
    log to console    add lcrld 3
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-3
    ...    filter_param=Local cell resource ID    new_value=3   abbr=lcrId
    log to console    modify physCellId to 190
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-3
    ...    filter_param=Physical cell identifier    new_value=${190}    abbr=physCellId
    log to console    add nrCellList 3
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-2
    ...    filter_param=List of NR cells assigned to cell group    node_index=${0}    new_value=3    abbr=nrCellList
    log to console    add refNrCellGroup 1
    selenium_coam.add_element    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1    filter_param=Reference to cell group
    ...    abbr=refNrCellGroup
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${2}    new_value=2    abbr=refNrCellGroup
    log to console    add LCELNR-2 under MRBTS-958/MNL-1/MNLENT-1/CELLMAPPING-1. it is copy from LCELNR-1
    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    ...    include_subobject=${True}   id_value=3    timeout=15
    log to console    modify antl port for channelgrpuo 1-2 under LCELNR-3
    Wait Until Keyword Succeeds   3x   10s    Modify ANTL For ChannelGroup    cell_id=3    channelgroup_id=1    connect_ru_id=5
    ...    ANTL_list=${antl_list_first_half}
    Wait Until Keyword Succeeds   3x   10s    Modify ANTL For ChannelGroup    cell_id=3    channelgroup_id=2    connect_ru_id=6
    ...    ANTL_list=${antl_list_first_half}
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${180}
    sleep    10s


modify 3*1supercel_2subcell to 1supercel_6subcelll
    log to console    delete supercell2 and supercell3
    FOR    ${index}    IN RANGE    2    4
        ${index_cellgroup}    Evaluate    ${index}-${1}
        log to console    delete nrcell ${index} under MRBTS-958/NRBTS-5958
        selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${index}    timeout=15
        sleep    2s
        log to console    delete nrcellgrouip ${index_cellgroup} under MRBTS-958/NRBTS-5958
        selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${index_cellgroup}    timeout=15
        sleep    2s
        log to console    delete  LCELNR ${index} under MRBTS-958/MNL-1/MNLENT-1/CELLMAPPING-1
        selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${index}    timeout=15
        sleep    2s
    END
    log to console    delete refNrCellGroup for cellgroup 2
    selenium_coam.remove_element    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1    filter_param=Reference to cell group
    ...    node_index=2
    sleep    2s
    log to console    delete refNrCellGroup for cellgroup 1
    selenium_coam.remove_element    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1    filter_param=Reference to cell group
    ...    node_index=1
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan
    log to console    modify 1supercell_2subcells to 1supercell_6subcells
    Modify 1supercell_2subcells to 1supercell_6subcells


Modify 1supercell_2subcells to 1supercell_6subcells
    [Arguments]    ${cell_id}=1
    log to console    Modify 1supercell_2subcells to 1supercell_6subcells
    log to console    add channelgroup 3-6 under LCELNR-1
    FOR    ${index}    IN RANGE    3    7
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1
        ...    include_subobject=${True}   id_value=${index}    timeout=15
    END
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan
    log to console    modify ANTL for channelgroup 3-6
    Wait Until Keyword Succeeds   3x   10s    Modify ANTL For ChannelGroup    channelgroup_id=3    connect_ru_id=3
    ...    ANTL_list=${antl_list_first_half}
    Wait Until Keyword Succeeds   3x   10s    Modify ANTL For ChannelGroup    channelgroup_id=4    connect_ru_id=4
    ...    ANTL_list=${antl_list_first_half}
    Wait Until Keyword Succeeds   3x   10s    Modify ANTL For ChannelGroup    channelgroup_id=5    connect_ru_id=5
    ...    ANTL_list=${antl_list_first_half}
    Wait Until Keyword Succeeds   3x   10s    Modify ANTL For ChannelGroup    channelgroup_id=6    connect_ru_id=6
    ...    ANTL_list=${antl_list_first_half}
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${180}
    sleep    10s


CB011091_E_General_SiSo_E2E_system_setup_with_data_transfer_E2_E3_combination
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _E2_E3.xml
    Commissioning SCF And Check All RU On Air    ${SCF_upload}
    Run Keyword And Ignore Error    Set primarySasServer value    value=${UTESASip}:4433
    Activate feature CBRS By Coam
    start SAS server    config_name=${CB011091_E1_E3.conf}    path=${sas_3}
#    log to console    rf module power reset
#    power off and on ru1
#    power off and on ru1
    Wait until keyword succeeds    10min    5s    verify all cells should be onair
    ${grant_info_cell1}    Get Grant Parameters By Coam    NRCBSDID=1
    ${grant_info_cell4}    Get Grant Parameters By Coam    cellID=4    NRCBSDID=1
    ${chBw_cell1}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=1
	${chBw_cell4}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=4
    Should be True    '${grant_info_cell4}[grantId]'=='3590000000_3610000000'
    Should be True    '${grant_info_cell4}[grantChannelType]'=='PAL'
    Should be True    '${grant_info_cell1}[grantChannelType]'=='GAA'
    Should be True    '${chBw_cell1}'=='20MHz'
    Should be True    '${chBw_cell4}'=='20MHz'
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Set Test Variable    ${cell_type}
    Set Test Variable    ${cell_list_nr}
    Set Test Variable    ${cell_list_lte}
    ${lnbtsID}    run keyword if    '${cell_type}' != 'nr_only'    Get lnbts ID via online SCF
    set test variable    ${lnbtsID}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${SCF_upload}
    set test variable    ${mrbtsID}
    set test variable    ${nrbtsID}
    log to console    ++++++++++++++++++++++++++++++++++++ ALl Rat Reset Start++++++++++++++++++++++++++++++++++++
    FOR    ${index}    IN RANGE    5
        log to console    ++++++++++++++++++++++++++++++++++++ ALl Rat Reset ${index}++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Reset all rats
        log to console    ---------------------------------------------------------------------------------------
        Reset rat SG08
        sleep    20
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 All SMODs BBMODs RMODs and Cells onair
        log to console    ---------------------------------------------------------------------------------------
        All SMODs BBMODs RMODs and Cells should be onair
        Sleep    10
        csn.reset_cache
    END
    log to console    +++++++++++++++++++++++++++++++++++++ Cell del & add Start +++++++++++++++++++++++++++++++++++++
    FOR    ${index}    IN RANGE    3
        log to console    ++++++++++++++++++++++++++++++++++ Cell del & add ${index} +++++++++++++++++++++++++++++++++
        Online Cell deletion    deletion_cell=${4}  deletion_cellgrp=${3}
        Sleep    300s
        ${grant_info_cell1}    Get Grant Parameters By Coam    cellID=1    NRCBSDID=1
	    ${chBw_cell1}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=1
        Should be True    '${grant_info_cell1}[grantId]'=='3590000000_3610000000'
        Should be True    '${grant_info_cell1}[grantChannelType]'=='PAL'
        Should be True    '${chBw_cell1}'=='20MHz'
        verify all cells should be onair
        csn.reset_cache
        sleep    10s
        Online Cell addition    file_path=${SCF_upload}    addition_cell=4    addition_cellgrp=3
        Sleep    300s
        ${grant_info_cell1}    Get Grant Parameters By Coam    NRCBSDID=1
        ${grant_info_cell4}    Get Grant Parameters By Coam    cellID=4    NRCBSDID=1
        ${chBw_cell1}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=1
	    ${chBw_cell4}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=4
        Should be True    '${grant_info_cell4}[grantId]'=='3590000000_3610000000'
        Should be True    '${grant_info_cell4}[grantChannelType]'=='PAL'
        Should be True    '${chBw_cell4}'=='20MHz'
        Should be True    '${grant_info_cell1}[grantChannelType]'=='GAA'
        Should be True    '${chBw_cell1}'=='20MHz'
        Wait until keyword succeeds    8min    30s    verify all cells should be onair
    END
    log to console    ++++++++++++++++++++++++++++++++++ Radio reset Loop Start +++++++++++++++++++++++++++++++
    FOR    ${index}    IN RANGE    3
        log to console    +++++++++++++++++++++++++++++++++Radio reset Loop ${index} ++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        Reset all RMOD via coam
        Sleep    30s
        Wait until keyword succeeds    8min    30s    verify all cells should be onair
        Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
        csn.reset_cache
    END
    log to console    ++++++++++++++++++++++++++++++ Radio lock and unlock ++++++++++++++++++++++++++++++
    ${ru_id_list}    Get All RU Index
    FOR    ${ru_id}  IN  @{ru_id_list}
        coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_id}    connection=GNB_OAM    timeout=60s
        sleep    2s
    END
    FOR    ${ru_id}  IN  @{ru_id_list}
        coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_id}    connection=GNB_OAM    timeout=60s
        sleep    2s
    END
    Wait until keyword succeeds    10min    5s    verify all cells should be onair
    log to console    ++++++++++++++++++++ block and unblock all cells ${index} +++++++++++++++++++++++++++++
    ${nr_cell_all}    Get All Nr Cells
    Get X2 link shutdown waiting time
    selenium login and disable screen lock
    Block cells and check status    block_list=${nr_cell_all}    check_alarm=${False}    gnb_type=${gNb_CuType}
    UnBlock cells and check status    block_list=${nr_cell_all}    check_alarm=${False}    gnb_type=${gNb_CuType}

    log to console    +++++++++++++++++++++++++++++ Cell Lcok_Unlcok+++++++++++++++++++++++++
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 1 lock cells
    log to console    ---------------------------------------------------------------------------------------
    Connect to gnb coam via ssl
    Lock cells and check status via coam
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 2 unlock cells
    log to console    ---------------------------------------------------------------------------------------
    Unlock cells and check status via coam
    csn.reset_cache
    log to console    ++++++++++++++++++++++++++++++++++++ All RAT blcok ++++++++++++++++++++++++++++++++++++
    AlarmWatchdog.add_allow_alarms    fault_id=4614
    Connect to gnb coam via ssl
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 1 Block all rats
    log to console    ---------------------------------------------------------------------------------------
    Block rat SG08
    sleep    10
    Check status after block all rats
    sleep    30
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 2 unBlock all rats
    log to console    ---------------------------------------------------------------------------------------
    UnBlock rat SG08
    sleep    10
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 3 All SMODs BBMODs RMODs and Cells onair
    log to console    ---------------------------------------------------------------------------------------
    All SMODs BBMODs RMODs and Cells should be onair
    Sleep    30
    csn.reset_cache
    AlarmWatchdog.remove_allow_alarms    fault_id=4616
    log to console    make call on cell 3
    data_transfer_common    tput_self_define=${tput_11091}    cell_id=${nr_cell_3}    duration=${300}
    [Teardown]    Run keyword and ignore error    Selenium Logout And Close Browser


CB011091_E_General_SiSo_Commissioning_BTS_Template_Commissioning_E1_1*AZQG_3*AWHQU
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _E1.xml
    Commissioning SCF And Check All RU On Air    ${SCF_upload}
    Run Keyword And Ignore Error    Set primarySasServer value    value=${UTESASip}:4433
    Activate feature CBRS By Coam
    start SAS server    path=${sas_3}
    log to console    rf module reset
    Reset all RMOD via coam
    Wait until keyword succeeds    10min    5s    verify all cells should be onair
    log to console    block and unblock all cells
    ${nr_cell_all}    Get All Nr Cells
    Get X2 link shutdown waiting time
    selenium login and disable screen lock
    Block cells and check status    block_list=${nr_cell_all}    check_alarm=${False}    gnb_type=${gNb_CuType}
    UnBlock cells and check status    block_list=${nr_cell_all}    check_alarm=${False}    gnb_type=${gNb_CuType}
    [Teardown]    Run keyword and ignore error    Selenium Logout And Close Browser


E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _E1.xml
    Commissioning SCF And Check All RU On Air    ${SCF_upload}
    Run Keyword And Ignore Error    Set primarySasServer value    value=${UTESASip}:4433
    Activate feature CBRS By Coam
    start SAS server    path=${sas_3}
    log to console    tl reset 10 times
    FOR    ${index}    IN RANGE    ${0}    ${1}
        coam.reset_site    connection=GNB_OAM
        sleep    5s
        Wait until keyword succeeds    10min    5s    verify all cells should be onair
    END


CB011091E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _E1.xml
    Commissioning SCF And Check All RU On Air    ${SCF_upload}
    Activate feature CBRS By Coam
    start SAS server    path=${sas_3}
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


Reset All RU
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ${ru_id_list}    Get All RU Index
    COAM Navigate to login page via webUI   download_dir=${TS_CASE_LOG_PATH}
    FOR    ${ru_index}  IN  @{ru_id_list}
        ${ru_index}  Convert To Integer    ${ru_index}
        selenium_coam.reset_ru  ru_index=${ru_index}
    END
    [Teardown]  COAM selenium logout


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


power off and on ru1
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    FOR    ${index}    IN RANGE    0    ${1}
        ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.__class__.__name__}
        ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.addr}
        ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.port_no}
        ${ru_index}    evaluate    ${index}+1
        log to console    for ru ${ru_index}, model is ${model}, pb ip is ${address}, pb port is ${port}
        pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_${ru_index}
        ${port_status}    pdu.Get Port Status    port=${port}    pdu_device=pdu_ru_${ru_index}
        log to console    port status of ru ${ru_index} is ${port_status}
        run keyword if    '${port_status}'=='on'    pdu.power off    port=${port}    pdu_device=pdu_ru_${ru_index}
        sleep    5s
        run keyword if    '${port_status}'=='off'    pdu.power on    port=${port}    pdu_device=pdu_ru_${ru_index}
        sleep    5s
    END


Check All RU Onair
    [Arguments]   ${connection}=GNB_OAM
    Wait Until Keyword Succeeds  15min  5s  Check if bts is pingable
    FOR    ${i}    IN RANGE    0    30
        ${ru_status}    Run Keyword And Return Status    Check All RU status   connection=${connection}
        exit for loop if    ${ru_status}
        sleep    15s
    END
    should be true    ${ru_status}


Check All RU status
    [Arguments]    ${connection}=GNB_OAM    ${ru_sn}=all    ${timeout}=900
    Log to console    Check RU status from GNB
    ${sw_version}     coam.get_sw_version    connection=${connection}    timeout=${timeout}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}    timeout=${timeout}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    ${ru_item}    Set variable    ${0}
    Should be true    ${count_RUs}>=${1}    msg=Check RU status failed as total RU number is less than 1
    FOR  ${ru}  IN  @{list_RUs}
        Run keyword if    '${ru_sn}'!='all' and '${ru_sn}'!='${ru['serialNumber']}'    continue for loop
        ${ru_item}=    evaluate    ${ru_item}+1
        Run keyword and continue on failure
        ...    Should be equal as strings    ${ru['status']['administrativeState']}    ${unlocked}
        ...    msg=Current RU administrativeState is not in Unlocked status
        Run keyword and continue on failure
        ...    Should be equal as strings    ${ru['status']['operationalState']}    ${enabled}
        ...  msg=Current RU operationalState is not in Enabled status
        Run keyword and continue on failure
        ...    Should be equal as strings    ${ru['status']['proceduralStatus']}    configured
        ...  msg=Current RU proceduralStatus is not in configured status
    END
    should be true    ${ru_item}>${0}    msg=Check RU status failed as no RU found !!!


Commissioning SCF And Check All RU On Air
    [Arguments]  ${scf_file_path}
    Log to console    +++Commissioning SCF And Check RU On Air+++
    Log to console    SCF Path:${scf_file_path}
    COAM Commission with scf file  scf_file_path=${scf_file_path}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    sleep    300s
    Check All RU Onair


CBRS Test Teardown For CB011091
    [Arguments]    ${actCbrsEnhMeas}=${False}
    log to console    \n***CBRS Test Teardown***
    save_sas_log    dstFile=${TS_CASE_LOG_PATH}/SAS_Sim.log
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
    robot_common_operations.CommonCaseTeardown
    set suite variable    ${test_teardown_fail}    ${False}
    Deactivate feature CBRS By Coam    actCbrsEnhMeas=${actCbrsEnhMeas}
    kill process for SAS server
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5 min    5 sec    Verify all cbrs cells should be disabled
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    run keyword if test failed     run keywords
    ...    Capture RU logs    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM    AND
    ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM    AND
    ...    Save Coam im snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown


Verify all cbrs cells should be disabled
    [Arguments]    ${connection}=GNB_OAM
    ${cells}    Get Nr And Lte Cells For RU    ru_index=7
    ${cell_not_CBRS}    set variable    ${cells['nr']}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cells_info}   coam.get_cells_info   timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        ${cell_id}    set variable    ${cell['globalCellId']}
        Run keyword if    ${cell_id} not in ${cell_not_CBRS}    Should be equal as strings    ${cell['status']['operationalState']}    ${disabled}
        ...    ELSE    Should be equal as strings    ${cell['status']['operationalState']}    ${enabled}
    END
