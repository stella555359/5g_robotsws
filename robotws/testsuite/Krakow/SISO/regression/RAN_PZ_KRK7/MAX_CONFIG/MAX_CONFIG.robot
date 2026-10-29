*** Settings ***
Documentation
...    author: Dominik Wieczorek
...    contact: Dominik Wieczorek (dominik.wieczorek@nokia.com)

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      taf/rfrl/bts/operations.py    WITH NAME    operations
Library      taf/rfrl/bts/commissioning.py    WITH NAME    commissioning
Library      testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py
Library      testsuite/Krakow/SISO/regression/RAN_PZ_KRK7/MAX_CONFIG/resources/keywords.py    WITH NAME    max_config

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Resource     testsuite/Krakow/resources/RAN_PZ_KRK7/keywords.robot


Suite Setup       Run Keywords    Increase Timeouts    venv_name=test_repo
...                        AND    common_setups_and_teardowns.Common Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions

*** Variables ***
${RP_CA}                            VRF_SiSo
${RP_LOCATION}                      VRF_KRK
${RP_ORGANIZATION}                  VRF_KRK_T07
@{CUSTOMERS_LIST}                   TEST

${SOURCE_SW}                        ${None}
${TARGET_SW}                        ${None}


@{ALLOWED_ALARMS}                   49    61524    61652    4654    4655    61649    4592
@{CUSTOM_ALARMS}                    49
@{FLAG_FOR_RELEASE}                 SBTS00    SBTS26R2    SBTS26R1    SBTS25R2

@{BBMODS_FOR_TEST}                  MRBTS-80108/EQM-1/APEQM-1/CABINET-1/BBMOD-3
...                                 MRBTS-80108/EQM-1/APEQM-1/CABINET-1/BBMOD-6

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}

&{NODE_BBMOD}                       testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}
...                                 modules_for_test=${BBMODS_FOR_TEST}


@{NODES}                            ${NODE1}
@{NODES_BBMOD}                      ${NODE_BBMOD}

${UPDATE_TEST_ITERATION}            3
${ACTIVATION_RESET_TEST_ITERATION}  5
${SCF_TEST_ITERATION}               1
${NR_RAT_RESET_TEST_ITERATION}      1
${BBMOD_RESET_TEST_ITERATION}       1
${RMOD_RESET_TEST_ITERATION}        1
${RMOD_LOCK_TEST_ITERATION}         1
${CELL_LOCK_TEST_ITERATION}         1


${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
${QC_ID_UPGRADE}                    221131
${QC_ID_ACTIVATION_RESET}           221130

${UE_CAPABILITIES}                   QUECTEL_UE
${UE_DEFAULT_ALIAS_NAME}             UE
${DEFAULT_DATA_TRANSFER_DURATION}    120s
${DEFAULT_SEGMENT_SIZE}              1320
${DEFAULT_PROTOCOL}                  tcp
${DEFAULT_DEVIATION}                 20%
${DEFAULT_TPUT_UL}                   100Mbits/sec
${DEFAULT_TPUT_DL}                   200Mbits/sec
${UE_TYPE}                           quectel

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]    96h
    [Tags]    uuf    upgrade

    Run Keyword If  '${QC_ID_UPGRADE}'!='${None}'    Set Tags    QC_${QC_ID_UPGRADE}
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_UPGRADE}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    [Tags]    uuf    activation_reset
    Run Keyword If  '${QC_ID_ACTIVATION_RESET}'!='${None}'    Set Tags    QC_${QC_ID_ACTIVATION_RESET}
    gnbbbu.Disconnect
    E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${ACTIVATION_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_ACTIVATION_RESET}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

MAX_CONFIG_TC03_template_commissioning
    [Tags]    scf    tc03
    [Timeout]    24h
    TEMPLATE COMMISSIONING    iterations=${SCF_TEST_ITERATION}

MAX_CONFIG_TC04_NR_RAT_reset
    [Tags]    rat_reset    tc04
    [Timeout]    24h
    NR RAT RESET    iterations=${NR_RAT_RESET_TEST_ITERATION}

MAX_CONFIG_TC05_BBMOD_reset
    [Tags]    bbmod_reset    tc05
    [Timeout]   24h
    @{BBMOD_ID_LIST}    Create List    3    6
    BBMOD RESET
    ...         iterations=${BBMOD_RESET_TEST_ITERATION}
    ...         bbmod_id_list=${BBMOD_ID_LIST}

MAX_CONFIG_TC06_RMOD_reset
    [Tags]    rmod_reset    tc06
    [Timeout]   24h
    RMOD RESET    iterations=${RMOD_RESET_TEST_ITERATION}

MAX_CONFIG_TC07_RMOD_lock_unlock
    [Tags]    rmod_lock    tc07
    [Timeout]   24h
    RMOD LOCK UNLOCK
    ...                 iterations=${RMOD_LOCK_TEST_ITERATION}
    ...                 rmods_to_lock_quantity=1

MAX_CONFIG_TC08_NR_cell_lock_unlock
    [Tags]    cell_lock    tc08
    [Timeout]   24h
    NRCELL LOCK UNLOCK
    ...                 iterations=${CELL_LOCK_TEST_ITERATION}
    ...                 nrcells_to_lock_quantity=1

MAX_CONFIG_TC09_L3_call
    [Tags]    tput    tc09
    [Timeout]    24h
    L3 CALL

*** Keywords ***
Increase Timeouts
    [Arguments]    ${venv_name}=test_repo
    add_timeout_to_function
    ...    filepath=/home/ute/.pyenv/versions/${venv_name}/lib/python3.10/site-packages/taf/rfrl/bts/devices/du/du_operations.py
    ...    function_name=get_bts_info
    ...    value=1500

    add_timeout_to_function
    ...    filepath=/home/ute/.pyenv/versions/${venv_name}/lib/python3.10/site-packages/taf/sbts/oam/coam/admin/facade.py
    ...    function_name=get_parameter_by_class
    ...    value=600

    add_timeout_to_function
    ...    filepath=/home/ute/.pyenv/versions/${venv_name}/lib/python3.10/site-packages/taf/sbts/oam/coam/admin/facade.py
    ...    function_name=get_bts_info
    ...    value=1500

    add_timeout_to_function
    ...    filepath=/home/ute/.pyenv/versions/${venv_name}/lib/python3.10/site-packages/taf/sbts/oam/coam/admin/facade.py
    ...    function_name=get_sw_version
    ...    value=300

    add_timeout_to_function
    ...    filepath=/home/ute/.pyenv/versions/${venv_name}/lib/python3.10/site-packages/taf/sbts/oam/coam/admin/facade.py
    ...    function_name=perform_object_recommissioning
    ...    value=1500

    add_timeout_to_function
    ...    filepath=/home/ute/.pyenv/versions/${venv_name}/lib/python3.10/site-packages/taf/sbts/oam/coam/admin/facade.py
    ...    function_name=get_bts_statuses
    ...    value=1500

    add_timeout_to_function
    ...    filepath=/home/ute/.pyenv/versions/${venv_name}/lib/python3.10/site-packages/taf/sbts/oam/coam/admin/facade.py
    ...    function_name=get_current_scf_file
    ...    value=1500


TEMPLATE COMMISSIONING
    [Arguments]    ${iterations}=${1}

    FOR    ${i}    IN RANGE    ${iterations}
        ${iteration} =    Evaluate    ${i} + 1
        Log To Console    iteration ${iteration}/${iterations}

        Add Custom Allowed Alarms If Defined
        gnb_alarm.Start watching alarms     allowed_alarms=${allowed_alarms}
        gnb_alarm.Watch Active Alarms and Collect Logs on Unexpected Alarm

        ${scf_dictionary} =    operations.Download BTS Configuration
        Sleep    10sec    wait for complete "operations.Download BTS Configuration"
        ${scf_path} =    Get From Dictionary    ${scf_dictionary}    BTS
        Sleep    10sec

        max_config.perform_commissioning    scf_file=${scf_path}

        Wait Until Keyword Succeeds     1800 sec     30 sec   gnbcell.Verify All Cells are OnAir

        Run Keywords
        ...           gnb_alarm.Stop watching alarms
        ...           AND
        ...           Remove Custom Allowed Alarms If Defined
    END

NR RAT RESET
    [Arguments]    ${iterations}=${1}

    FOR    ${i}    IN RANGE    ${iterations}
        ${iteration} =    Evaluate    ${i} + 1
        Log To Console    iteration ${iteration}/${iterations}

        Add Custom Allowed Alarms If Defined
        gnb_alarm.Start watching alarms     allowed_alarms=${allowed_alarms}
        gnb_alarm.Watch Active Alarms and Collect Logs on Unexpected Alarm

        reset_rat    rat_type=NR
        Wait Until Keyword Succeeds     1800 sec     30 sec   gnbcell.Verify All Cells are OnAir

        Run Keywords
        ...           gnb_alarm.Stop watching alarms
        ...           AND
        ...           Remove Custom Allowed Alarms If Defined
    END

BBMOD RESET
    [Arguments]    ${iterations}=${1}    ${bbmod_id_list}=${None}

    FOR    ${i}    IN RANGE    ${iterations}
        ${iteration} =    Evaluate    ${i} + 1
        Log To Console    iteration ${iteration}/${iterations}

        Add Custom Allowed Alarms If Defined
        gnb_alarm.Start watching alarms     allowed_alarms=${allowed_alarms}
        gnb_alarm.Watch Active Alarms and Collect Logs on Unexpected Alarm

        max_config.reset_random_bbmod    bbmod_id_list=${bbmod_id_list}
        Wait Until Keyword Succeeds     1800 sec     30 sec   gnbcell.Verify All Cells are OnAir

        Run Keywords
        ...           gnb_alarm.Stop watching alarms
        ...           AND
        ...           Remove Custom Allowed Alarms If Defined
    END

RMOD RESET
    [Arguments]    ${iterations}=${1}    ${rmod_id_list}=${None}

    FOR    ${i}    IN RANGE    ${iterations}
        ${iteration} =    Evaluate    ${i} + 1
        Log To Console    iteration ${iteration}/${iterations}

        Add Custom Allowed Alarms If Defined
        gnb_alarm.Start watching alarms     allowed_alarms=${allowed_alarms}
        gnb_alarm.Watch Active Alarms and Collect Logs on Unexpected Alarm

        max_config.reset_random_rmod    rmod_id_list=${rmod_id_list}
        Wait Until Keyword Succeeds     1800 sec     30 sec   gnbcell.Verify All Cells are OnAir

        Run Keywords
        ...           gnb_alarm.Stop watching alarms
        ...           AND
        ...           Remove Custom Allowed Alarms If Defined
    END

RMOD LOCK UNLOCK
    [Arguments]    ${iterations}=${1}    ${rmods_to_lock_quantity}=${1}

    FOR    ${i}    IN RANGE    ${iterations}
        ${iteration} =    Evaluate    ${i} + 1
        Log To Console    iteration ${iteration}/${iterations}

        Add Custom Allowed Alarms If Defined
        gnb_alarm.Start watching alarms     allowed_alarms=${allowed_alarms}
        gnb_alarm.Watch Active Alarms and Collect Logs on Unexpected Alarm

        max_config.Lock Random RMOD    quantity=${rmods_to_lock_quantity}
        max_config.Unlock All RMODS
        Wait Until Keyword Succeeds   20min    5min    gnbcell.Verify All Cells Are Onair

        Run Keywords
        ...           gnb_alarm.Stop watching alarms
        ...           AND
        ...           Remove Custom Allowed Alarms If Defined
    END

NRCELL LOCK UNLOCK
    [Arguments]    ${iterations}=${1}    ${nrcells_to_lock_quantity}=${1}

    FOR    ${i}    IN RANGE    ${iterations}
        ${iteration} =    Evaluate    ${i} + 1
        Log To Console    iteration ${iteration}/${iterations}

        Add Custom Allowed Alarms If Defined
        gnb_alarm.Start watching alarms     allowed_alarms=${allowed_alarms}
        gnb_alarm.Watch Active Alarms and Collect Logs on Unexpected Alarm

        max_config.lock_random_nrcell    quantity=${nrcells_to_lock_quantity}
        max_config.unlock_all_nrcells
        Wait Until Keyword Succeeds   5min    1min    gnbcell.Verify All Cells Are Onair

        Run Keywords
        ...           gnb_alarm.Stop watching alarms
        ...           AND
        ...           Remove Custom Allowed Alarms If Defined
    END

Prepare UE PC Connection
    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
    Sleep    5sec    wait for complete `ute_ue.Require UE`

L3 CALL
    Add Custom Allowed Alarms If Defined
    gnb_alarm.Start watching alarms     allowed_alarms=${allowed_alarms}
    gnb_alarm.Watch Active Alarms and Collect Logs on Unexpected Alarm

    Prepare UE PC Connection
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G    ue_type=${UE_TYPE}
    Sleep    10sec    wait for complete `Change Network Mode`
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    10sec    wait for complete `ute_ue.Attach UE`
    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=8



    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=8

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}

    Run Keywords    gnb_alarm.Stop watching alarms
    ...      AND    Remove Custom Allowed Alarms If Defined

Remove Dirs
    [Arguments]    @{directory_path}
    FOR    ${dir}    IN    @{directory_path}
        ${status}=    Run Keyword And Return Status    Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    force=True
    END

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions    collect_syslog=${False}
    Remove Dirs       directory_path=/home/ute/.ute-ca/cache/bts/

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions

Custom Postconditions
    [Arguments]     ${collect_syslog}=${True}
    ...             ${collect_snapshot_from_ru}=${True}

    gnbalarm.Wait Until Callback Logs Collection Finished
    gnbcell.Verify All Cells are OnAir
    interface.Common step trigger
    gnbbbu.Teardown All Browsers
    [Teardown]    Run Keywords
    ...           Collect Logs After Test Finished              collect_syslog=${collect_syslog}
    ...                                                         collect_snapshot_from_ru=${collect_snapshot_from_ru}
    ...           AND
    ...           Compress moler syslogs
    ...           AND
    ...           Restore Origin TAF Testline Configuration
