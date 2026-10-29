*** Settings ***
Documentation     Keywords for Marvin
Library     taf.ul.marvin              WITH NAME    Marvin

*** Keywords ***
Prepare And Start Marvin
    ${skip_log_collection}    Get Variable Value    ${skip_log_collection}    ${False}
    ${skip_marvin}    Get Variable Value    ${skip_marvin}    ${False}
    IF    '_CUS' in '${NODE_NAME}' or 'CLOUD' in '${tl.tl_cloud_topology}' or ${skip_log_collection} or ${skip_marvin}
        Set Suite Variable     ${marvin_enabled}     ${False}
        RETURN
    END
    ${cmd}    Catenate    docker stop data_collector > /dev/null 2>&1;
    ...    docker rm data_collector > /dev/null 2>&1;
    ...    rm -rf /home/ute/marvin; mkdir /home/ute/marvin;
    ...    docker system prune -a -f --filter "until=168h"
    Run       ${cmd}
    TRY
        Marvin.Prepare And Start Marvin
        ...    common_templates=/home/ute/robotws/testsuite/QT/SRAN/resources/Marvin_templates
        ...    organization=QT
        ...    only_test_run=True
        ${is_data_collector_running}    is_data_collector_running
        IF    ${is_data_collector_running}
            Set Suite Variable     ${marvin_enabled}     ${True}
        ELSE
            Set Suite Variable     ${marvin_enabled}     ${False}
        END
    EXCEPT    AS    ${error}
        Log   Marvin could not be started: ${error}    WARN
        Set Suite Variable     ${marvin_enabled}     ${False}
    END

Stop Marvin
    ${marvin_enabled}    Get Variable Value    ${marvin_enabled}    ${False}
    IF    not ${marvin_enabled}    RETURN
    ${verdict}     Set Variable If     '${SUITE STATUS}'=='PASS'    Passed    Failed
    TRY
        Marvin.Stop Marvin    only_test_run=True
        ...                   wait_after_run=False
        ...                   verdict=${verdict}
    EXCEPT    AS    ${error}
        Log   Marvin could not be stopped: ${error}    WARN
    END


Generate Data File For Marvin
    ${bts_info}       coam.Get Bts Info    connection=coam_admin
    ${bts_id}         Set Variable    ${bts_info['mrbtsID']}
    ${sw_build}       Set Variable    ${bts_info['swInfo']['swVersion']}
    ${smods_info}     Set Variable    ${bts_info['systemModules']}
    ${bbmods_info}    Set Variable    ${bts_info['basebandModules']}
    ${rfs_info}       Set Variable    ${bts_info['radioModules']['rmod']}
    @{list_of_smods}         Create List
    @{list_of_bbmods}        Create List
    @{list_of_rmods}         Create List
    @{radio_technologies}    Create List
    FOR    ${smods}    IN    @{smods_info}
        FOR    ${smod_dict}    IN    ${smods}
            ${smod}    Fetch From Left    ${smod_dict['productName']}    ${SPACE}
            Append To List    ${list_of_smods}    ${smod}
        END
    END
    FOR    ${bbmods}    IN    @{bbmods_info}
        FOR    ${bbmod_dict}    IN    ${bbmods}
            ${bbmod}    Fetch From Left    ${bbmod_dict['productName']}    ${SPACE}
            Append To List    ${list_of_bbmods}    ${bbmod}
        END
    END
    FOR    ${item}    IN    @{rfs_info}
        Append To List    ${list_of_rmods}    ${ITEM['productName']}
    END
    ${cells_technology}    Set Variable    ${bts_info['cells']}
    FOR    ${technology}    IN    &{cells_technology}
        ${technology[1]_exists}    Run Keyword And Return Status    Should Not Be Empty    ${technology[1]}
        Run Keyword If    ${technology[1]_exists}    Create List With Radio Technology Parameters
        ...               ${radio_technologies}    technology=${technology[0]}    technology_1=${technology[1]}
    END
    &{dict_wih_parameters}    Create Dictionary
    ...    classical_cloud=${CONFIGURATION}
    ...    bts_id=${bts_id}
    ...    loadBuild=${loadBuild}
    ...    sw_build=${sw_build}
    ...    branch=${branch}
    ...    config_path=${config_path}
    ...    output_dir=${OUTPUT DIR}
    ...    list_of_smods=${list_of_smods}
    ...    list_of_bbmods=${list_of_bbmods}
    ...    list_of_rmods=${list_of_rmods}
    ...    radio_technologies=@{radio_technologies}
    ...    syslog_path_for_marvin=${syslog_path_for_marvin}
    ...    snapshot_path_for_marvin=${snapshot_path_for_marvin}
    Run    sudo rm ${OUTPUT_DIR}/marvin_data.py
    Create File    ${OUTPUT_DIR}/marvin_data.py    ${EMPTY}
    FOR    ${key}    ${value}      IN    &{dict_wih_parameters}
           ${value_type}    Evaluate    type($value)
           ${value}    Set Variable If    "${value_type}"=="<class 'str'>"    "${value}"    ${value}
           Append To File    ${OUTPUT_DIR}/marvin_data.py    ${key} = ${value}\n
    END

Create Test Case And Start Marvin
    [Arguments]    ${testcase_name}
    ${marvin_enabled}    Get Variable Value    ${marvin_enabled}    ${False}
    IF    not ${marvin_enabled}    RETURN
    TRY
        Marvin.Create Test Case And Start    ${testcase_name}
    EXCEPT    AS    ${error}
        Log   Marvin could not create test case and start: ${error}    WARN
    END

Stop Test Case Marvin
    ${marvin_enabled}    Get Variable Value    ${marvin_enabled}    ${False}
    IF    not ${marvin_enabled}    RETURN
    ${verdict}     Set Variable If     '${TEST STATUS}'=='PASS'    Passed    Failed
    TRY
        Marvin.Stop Test Case    verdict=${verdict}
    EXCEPT    AS    ${error}
        Log   Marvin could not stop test case: ${error}    WARN
    END