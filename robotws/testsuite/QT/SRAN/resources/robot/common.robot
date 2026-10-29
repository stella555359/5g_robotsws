*** Settings ***
Documentation    common resource file for testing
Library     BuiltIn
Library     OperatingSystem
Library     Collections
Library     String
Library     XML
Library     Process
Library     robot.libraries.DateTime
Library     taf.transport.ssh          WITH NAME    ssh
Library     taf.fdsw.rc                WITH NAME    taf_fdsw
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Library     taf.gnb.oam.coam.cu        WITH NAME    coam_cu
Library     taf.hw.pdu                 WITH NAME    pdu
Library     taf.selenium.sbts          WITH NAME    sbts
Library     taf.selenium.sbts_fsm3     WITH NAME    sbts_fsm3
Library     taf.ul.oam_kpi_calculations.utilities
Library     taf.ul.oam_kpi_calculations                            WITH NAME    kpi
Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Library     ${CURDIR}/../python/TLHelper.py    ${tl}               WITH NAME    tl_helper
Library     ${CURDIR}/../python/setup.py
Library     ${CURDIR}/../python/common.py
Library     ${CURDIR}/../python/pdu_lib.py
Library     ${CURDIR}/../python/nidd_check.py
Library     ${CURDIR}/../python/scf_generator.py
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    ${CURDIR}/../robot/marvin_keywords.robot

*** Variables ***
${check_log}    ${EMPTY}

*** Keywords ***
QT Setup
    Set Color For Logs
    Log To Console      ============================== [ SUITE SETUP ] ===============================\n
    Log To Console      \t\t - - - Setting variables for test - - -
    Cleanup And Set Directory
    Set Stream Variables
    Set Testline Configuration Variables
    Get the SA flag
    Set ADB Variables
    Log Testline Information
    IF    ${vCU_build_flag}!=${True} and ${vDU_build_flag}!=${True}
        Start logs collection on SBTS
        Prepare And Start Marvin
    END
    IF    ${vDU_build_flag} and '${tcp_dump_interfaces}'!='None'
        ${tcpdump_status}=    Run Keyword and return status    Start vDU Tcpdump Collection
        IF    ${tcpdump_status}
            Set Suite Variable    ${vdu_tcpdump_started}    True
        ELSE
            Set Suite Variable    ${vdu_tcpdump_started}    False
        END
    ELSE
        Set Suite Variable    ${vdu_tcpdump_started}    False
    END
    Run Keyword If    '${moxa_ip_addr}'!='None' and '${moxa_port}'!='None'    Run Keyword And Ignore Error    Start Collecting Logs From Moxa
    IF    'cus' in @{UEs}
        Run Keyword And Ignore Error    Kill Uexgate Processes
        Setup WTS
    END
    ${RDC_RMODS}    Setup RDC
    Set Suite Variable    ${RDC_RMODS}
    Log To Console      \n============================ [ SUITE SETUP DONE ] ============================
    Log To Console      ------------------------------------------------------------------------------

QT Teardown
    [Timeout]           35 min
    [Arguments]         ${snapshot_only}=False
    ${common_ts}        Get Variable Value    ${is_common_ts}    ${False}
    ${skip_log_collection}    Get Variable Value    ${skip_log_collection}    ${False}
    ${connection_status}    Run Keyword and return status       coam.connect_to
    ...                   bts_host=192.168.255.129
    ...                   update_interval=1000
    ...                   name=coam_admin
    ${connection_status}    Run Keyword If    '${connection_status}'=='False'
    ...                   Run Keyword and return status    coam.connect_to
    ...                   bts_host=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}
    ...                   update_interval=1000
    ...                   name=coam_admin
    ...                   ELSE    Set Variable    ${connection_status}
    ${sw_d}=    Run Keyword if     ${connection_status}     coam.get_sw_version    connection=coam_admin
    Set Suite Variable    ${sw_d}
    IF    ${snapshot_only}!=${True}
        Log To Console      \n============================ [ SUITE TEARDOWN ] ==============================
        IF    not ${skip_log_collection}
            Stop BTSlogs Collection And Get Logs    target_path=${OUTPUT_DIR}
            Save SCF For Classical    connection_status=${connection_status}
            Collect RU Logs
        END
    END
    Run Keyword If    '${moxa_ip_addr}'!='None' and '${moxa_port}'!='None'
    ...               Run Keyword And Ignore Error    Stop Collecting Logs From Moxa
    Run Keyword If    '${snapshot_only}'=='True'    Save Snapshot For Classical
    ...               connection_status=${connection_status}
    Run Keyword If    ${Logs_eNB_NSA}==${True} and '${snapshot_only}'=='False'
    ...               Run Keyword If Any Tests Failed    Save Snapshot For Classical
    ...                                                  name=_eNb_NSA    connection_status=False    bts_lmp_ip=${LMP_IP}
    Run Keyword If    ${snapshot_only}!=${True}     Get And Check Swconfig Readme And Alarms Status
    IF    not ${skip_log_collection}
        ${t0_snapshot_status}=    get test case status by name    Check Alarms In IMS File After L3Call
        ${t1_alarm_status}=    get test case status by name    Check Alarms In IMS File After Installation T1 Package
        ${t1_cell_status}=    get test case status by name   Verify Cell Setup T1
        ${t1_test_status}=    Evaluate     '${t1_alarm_status}'=='FAIL' or '${t1_cell_status}'=='FAIL'
        ${t2_alarm_status}=    get test case status by name    Check Alarms In IMS File After Installation T2 Package
        ${t2_cell_status}=    get test case status by name   Verify Cell Setup T2
        ${t2_test_status}=    Evaluate     '${t2_alarm_status}'=='FAIL' or '${t2_cell_status}'=='FAIL'
        ${snapshot_condition}=    Evaluate
        ...   (${t1_test_status} or ${t2_test_status}) or not '${t0_snapshot_status}'=='PASS'
        ${get_snapshot}    Get Variable Value    ${get_snapshot}    False
        Run Keyword If    '${snapshot_only}'=='False' and '${snapshot_condition}'=='True' and '${get_snapshot}'=='False'
        ...                 Run Keyword If Any Tests Failed    Run Keywords
        ...                 Save Snapshot For Classical    connection_status=${connection_status}
        ...           AND   Check Error in Snapshot     ${snapshot_path}
        IF    '${snapshot_only}'=='False' and '${get_snapshot}'=='True'
            Save Snapshot For Classical    connection_status=${connection_status}
            Run Keyword If    '''${RDC_RMODS}''' != '''None'''    RDC Snapshot
        END
        ${fatal_err}    Run Keyword and return Status    Should Contain    ${fatal_err_list}    True
        Run Keyword If      ${fatal_err}    Fatal Error    msg=${fatal_err_msg_list}
    END
    Run Keyword If    '''${RDC_RMODS}''' != '''None'''    RDC Server Off    rmods=${RDC_RMODS}
    Move Logs To Additional Execution Logs    ${snapshot_only}
    Run Keyword If    ${snapshot_only}!=${True}
    ...    Log To Console      \n========================== [ SUITE TEARDOWN DONE ] ===========================\n
    Run Keyword And Ignore Error    Remove cus log on vm
    [Teardown]    Run Keywords    Run keyword if    ${connection_status}
    ...           Run Keyword And Ignore Error    Generate Data File For Marvin
    ...           AND                               coam.teardown    connection=coam_admin
    ...           AND             Run Keyword if    '${snapshot_only}'=='False'    Disconnect Infomodel
    ...           AND             Run Keyword if    '${snapshot_only}'=='False'    Teardown Infomodel
    ...           AND             Stop And Fix Check
    ...           AND             L3Call Stop And Fix Check

Move Logs To Additional Execution Logs
    [Arguments]    ${snapshot_only}=${False}
    ${additional_logs}    Set Variable    ${OUTPUT DIR}/Additional_Execution_Logs
    Run Keyword If       'cus' in @{UEs} and '${snapshot_only}'=='False'
    ...   Teardown WTS  subdirectory=${additional_logs}
    @{Move_files_list}    Create List    al.*    ute_ue.*    admin*
    FOR   ${file}    IN    @{Move_files_list}
        TRY
            IF    '${file}' == 'admin*'
                ${file_path}    Get Environment Variable    name=PWD
            ELSE
                ${file_path}    Set Variable    ${OUTPUT_DIR}
            END
            Move Files    ${file_path}/${file}     ${additional_logs}
        EXCEPT    AS    ${error}
            Log To Console  --> !!!Warning!!! Move additional file ${file} failed due to ${error}
        END
   END

Cleanup And Set Directory
    Run                 command=cd /tmp && rm -rf rust_mozprofile*
    Run                 command=cd /tmp && rm -rf tmp*
    Run                 command=ps -ef | grep admin | grep -v grep | awk '{print "kill "$2}' | sh
    Create Directory    ${OUTPUT DIR}/Additional_Execution_Logs

Get And Check Swconfig Readme And Alarms Status
    ${swconfig_status}    Run Keyword And Return Status    Upload Swconfig To Rotta
    Run Keyword If        '${swconfig_status}'=='${False}'    Log To Console    \n\t\t> > > Problem occured with Upload Swconfig < < < [ !!! ]\n
    ${readme_status}      Run Keyword And Return Status    Upload Readme Logs
    Run Keyword If        '${readme_status}'=='${False}'    Log To Console    \n\t\t> > > Problem occured with Upload Readme Logs < < < [ !!! ]\n
    ${alarms_status}    Run Keyword And Return Status    Log Active Alarms Classical
    Run Keyword If      '${alarms_status}'=='${False}'    Log To Console    \n\t\t> > > Problem occured with Log Active Alarms < < < [ !!! ]\n

Teardown Connections
    [Arguments]    ${connection_status}
    Run Keyword If    ${connection_status}    coam.teardown    connection=coam_admin

Save Snapshot For Teardown
    [Arguments]    ${connection_status}
    ${snapshot_condition}    Get Snapshot Condition
    ${get_snapshot}          Get Variable Value    ${get_snapshot}    False
    Run Keyword If    ${dualcore}==${True}    Run Keyword If Any Tests Failed    Save Snapshot For Classical    name=_slave    connection_status=False
    Run Keyword If    ${Logs_eNB_NSA}==${True}    Run Keyword If Any Tests Failed    Save Snapshot For Classical
    ...               name=_eNb_NSA    connection_status=True    bts_lmp_ip=${LMP_IP}
    Run Keyword If    '${snapshot_condition}'=='True' and '${get_snapshot}'=='False'
    ...               Run Keyword If Any Tests Failed    Save Snapshot For Classical    connection_status=${connection_status}
    Run Keyword If    '${get_snapshot}'=='True'    Save Snapshot For Classical    connection_status=${connection_status}

Get Snapshot Condition
    ${t0_snapshot_status}    get test case status by name    Check Alarms In IMS File After L3Call
    ${t1_alarm_status}       get test case status by name    Check Alarms In IMS File After Installation T1 Package
    ${t1_cell_status}        get test case status by name    Verify Cell Setup T1
    ${t1_test_status}        Evaluate    '${t1_alarm_status}'=='FAIL' or '${t1_cell_status}'=='FAIL'
    ${t2_alarm_status}       get test case status by name    Check Alarms In IMS File After Installation T2 Package
    ${t2_cell_status}        get test case status by name    Verify Cell Setup T2
    ${t2_test_status}        Evaluate    '${t2_alarm_status}'=='FAIL' or '${t2_cell_status}'=='FAIL'
    ${snapshot_condition}    Evaluate    (${t1_test_status} or ${t2_test_status}) or not '${t0_snapshot_status}'=='PASS'
    Return    ${snapshot_condition}

Save Snapshot Only
    ${connection_status}    Check Connection Status
    Save Snapshot For Classical    connection_status=${connection_status}
    Run Keyword If    ${dualcore}==${True}    Save Snapshot For Classical    name=_slave    connection_status=False
    [Teardown]    Run Keyword If    ${connection_status}    coam.teardown    connection=coam_admin

Check Connection Status
    ${connection_status}    Run Keyword And Return Status    coam.connect_to
    ...                     bts_host=192.168.255.129
    ...                     update_interval=1000
    ...                     name=coam_admin
    ${connection_status}    Run Keyword If    '${connection_status}'=='False'
    ...                     Run Keyword and return status    coam.connect_to
    ...                     bts_host=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}
    ...                     update_interval=1000
    ...                     name=coam_admin
    ...                     ELSE    Set Variable    ${connection_status}
    [Return]    ${connection_status}

Log Testline Information
    Log To Console      \t- TestLine: ${tl.tl_cloud_topology}
    Log To Console      \t- Build: ${loadBuild}
    IF    '${deployment}' != '' and '${deployment}' != 'not_set'    Log To Console      \t- Deployment: ${deployment}
    IF     ${vCU_build_flag} or ${vDU_build_flag}
        IF    not ${is_LTE}
            Log To Console      \t- vCU OAM: https://${CU_WEBUI_IP}
        END
        Log To Console      \t- vDU OAM: https://${DU_WEBUI_IP}
        IF    not ${is_LTE}
            Log To Console      \t- CU k8s info: ${CU_k8s_addr}/${CU_k8s_user}/${CU_k8s_pwd} : ${CU_tenant}
        END
        Log To Console      \t- DU k8s info: ${DU_k8s_addr}/${DU_k8s_user}/${DU_k8s_pwd} : ${DU_tenant}
        IF    ${FHGW_Exist}
            Log To Console      \t- FHGW info: ${FHGW_IP}/${FHGW_USERNAME}/${FHGW_PASSWORD}
        END
    ELSE
        Log To Console      \t- OAM: https://${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}\n
    END

Start logs collection on SBTS
    ${skip_log_collection}    Get Variable Value    ${skip_log_collection}    ${False}
    IF    not ${skip_log_collection}
        Run Keyword And Ignore Error    Start BTSlogs Collection
        IF    '${bbmod_type}'=='ABIP' and '${dmesg_flag}'=='True'
            Run Keyword And Ignore Error    Connect to gNB and start collecting logs on ABIP
        END
        Run Keyword If    '${moxa_ip_addr}'!='None' and '${moxa_port}'!='None'
        ...                        Run Keyword And Ignore Error    Start Collecting Logs From Moxa
    END
    Setup And Connect IM

Set UE Type
    @{UEs}      Create List
    Set Suite Variable    ${UEs}
    ${ue_num}         Get Length    ${tl.ues}
    Run Keyword If    '${ue_num}'=='0'    Run Keywords
    ...               Append To List      ${UEs}    None
    ...       AND     Log To Console           \t- UE: No UE defined in testline object.
    ...       ELSE    Get Ue Type From Init    ${ue_num}

Get Ue Type From Init
    [Arguments]    ${ue_num}
    Create UEs Dictionaries
    FOR    ${index}    IN RANGE    ${ue_num}
        Append To List       ${UEs}    ${tl.ues[${index}].ue_type}
        FOR    ${technology}    IN    @{tl.ues[${index}].capabilities}
            Set To Dictionary    ${UEs${technology}[:3]}    ${index}    ${tl.ues[${index}].ue_type}
            Log To Console       \t- UE ${technology}[1:3]: ${tl.ues[${index}].ue_type}
        END
    END

Create UEs Dictionaries
    &{UEs_2G}    Create Dictionary
    &{UEs_3G}    Create Dictionary
    &{UEs_4G}    Create Dictionary
    &{UEs_5G}    Create Dictionary
    Set Suite Variable    &{UEs_2G}
    Set Suite Variable    &{UEs_3G}
    Set Suite Variable    &{UEs_4G}
    Set Suite Variable    &{UEs_5G}

Set Netboot On SMOD
    Connect to Common Unit    alias=master
    ssh.send_command    command=uboot_env set netboot=netboot_first
    ...                 connection=master
    ssh.send_command    command=uboot_env get
    ...                 connection=master
    ${output}           ssh.read_output
    ...                 connection=master

Set Jenkins Variables
    [Documentation]     Sets global variables from Jenkins env.
    [Arguments]         ${envs}
    FOR    ${ELEMENT}   IN   @{envs}
        ${var}          Get Variable From Environment    var=${ELEMENT}
        ${var_name}     Set Variable   ${ELEMENT}
        Builtin.Set Global Variable    ${${var_name}}    ${var}
    END

Get Variable From Environment
    [Documentation]     Gets environment variable {var}, returns {default} if the var is not found.
    [Arguments]         ${var}    ${default}=${EMPTY}
    ${vars}             Get Environment Variables
    ${value}            Evaluate    $vars.get("${var}", "${default}")
    RETURN            ${value}

Set Stream Variables
    [Documentation]     Sets stream variables.
    ${MODULE_VERSION}   Get Load Id    ${AF_PATH}
    ${SBTS}             Evaluate    "ENB" in "${streamVersion}"
    ${STREAM_NUMBER}    Set Variable If    ${SBTS}    ${release}    ${streamVersion}
    ${is_Master}        Evaluate   'master' in '${STREAM}'
    ${vCU_build_flag}   set variable if    'CNF' in '${STREAM}'    True    False
    ${vDU_build_flag}   set variable if
    ...   'vDU' in '${STREAM}'    True
    ...   'VDU' in '${STREAM}'    True
    ...   False
    ${nidd_basebuild}    Get Variable Value    ${nidd_basebuild}    ${None}
    BuiltIn.Set Global Variable    ${nidd_basebuild}
    BuiltIn.Set Global Variable    ${vCU_build_flag}
    BuiltIn.Set Global Variable    ${vDU_build_flag}
    BuiltIn.Set Global Variable    ${is_Master}
    BuiltIn.Set Global Variable    ${SBTS}
    BuiltIn.Set Global Variable    ${MODULE_VERSION}
    BuiltIn.Set Global Variable    ${STREAM_NUMBER}
    BuiltIn.Set Global Variable    ${STREAM_PREFIX}    ${STREAM.split('_')[0].lower()}

Set Testline Configuration Variables
    [Documentation]     Sets variables from testline_configuration repository.
    Set EPC Variables
    Set GNB or ENB Flag
    IF    not ${vCU_build_flag} and not ${vDU_build_flag}
        Set Bbmod And Smod Information
        Get Sync Source Type
    END
    Set UE Type
    Set GNB or ENB Flag
    Set Configuration
    ${REAL_ENB}                    Get Variable Value    ${tl.custom['real_enb']}    ${True}
    BuiltIn.Set Global Variable    ${REAL_ENB}
    ${pdu_model}                   Get Variable Value    ${tl.attenuation['pdu_model']}    None
    BuiltIn.Set Global Variable    ${pdu_model}
    ${dualcore}                    Run Keyword And Return Status    Should Contain    ${NODE_NAME}    ASIM_ASIM
    BuiltIn.Set Global Variable    ${dualcore}
    ${airscale_fsmf}                Run Keyword And Return Status    Should Contain    ${NODE_NAME}    ASIB_FSMF
    BuiltIn.Set Global Variable    ${airscale_fsmf}
    ${dmesg_flag}                  Get Variable Value    ${tl.custom['dmseg_logs']}    None
    BuiltIn.Set Global Variable    ${dmesg_flag}
    ${moxa_ip_addr}                Get Variable Value    ${tl.custom['moxa_ip_addr']}    None
    BuiltIn.Set Global Variable    ${moxa_ip_addr}
    ${moxa_port}                   Get Variable Value    ${tl.custom['moxa_port']}    None
    BuiltIn.Set Global Variable    ${moxa_port}
    ${is_MRAT}                     Get Variable Value    ${tl.custom['is_MRAT']}    ${False}
    BuiltIn.Set Global Variable    ${is_MRAT}
    ${tcp_dump_interfaces}         Get Variable Value    ${tcp_dump_interfaces}    None
    BuiltIn.Set Suite Variable     ${tcp_dump_interfaces}
    Get The WMP Flag
    Get The IPV6 Flag

Get Sync Source Type
    TRY
        @{sync_source_list}    Create List
        ${sync_info}    coam.get_synchronization_information   connection=coam_admin
        FOR    ${source}    IN    @{sync_info['syncSourceInfo']}
            Append To List    ${sync_source_list}    prio${source['syncInputPrio']} - ${source['syncInputType'].strip()}
        END
        ${sync_source_info}    Evaluate   ', '.join(@{sync_source_list})
        Log To Console    \t- Sync Source: ${sync_source_info}
    EXCEPT    AS    ${error}
        Log    sync source check failed due to ${error}    WARN
    END

Set Bbmod And Smod Information
    WA for coam connect
    Run Keyword And Ignore Error    Get BBmod And Smod Type
    Run Keyword And Ignore Error    Get Horizontal And Vertical Position
    Run Keyword If    'ASO' not in '${smod_type}'    Run Keyword And Ignore Error    Get Horizontal And Vertical Position    module=basebandModules

Set EPC Variables
    ${EPC_HOST}                    Get Variable Value    ${tl.core.default_ssh_connection_details.addr}       not_set
    BuiltIn.Set Global Variable    ${EPC_HOST}
    ${EPC_USERNAME}                Get Variable Value    ${tl.core.default_ssh_connection_details.username}   not_set
    BuiltIn.Set Global Variable    ${EPC_USERNAME}
    ${EPC_PASSWORD}                Get Variable Value    ${tl.core.default_ssh_connection_details.password}   not_set
    BuiltIn.Set Global Variable    ${EPC_PASSWORD}

Set Configuration
    ${is_cloud}                    Run Keyword If    'gnb' in '${gnb_or_enb}'    tl_helper.Is Cloud
    ...                            ELSE IF    'enb' in '${gnb_or_enb}'    Set Variable   ${False}
    ...                            ELSE        Set Variable   ${True}
    ${CONFIGURATION}               Set Variable If    '${is_cloud}' == 'True'    Cloud    Classical
    BuiltIn.Set Global Variable    ${CONFIGURATION}

Set GNB or ENB Flag
    ${gnb_exists}                  Run Keyword And Return Status    Variable Should Exist
    ...                            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${gnb_or_enb}                  Set Variable If    ${gnb_exists}    gnb    enb
    BuiltIn.Set Global Variable    ${gnb_or_enb}

Set ADB Variables
    ${UE_serial_nr}     Get Variable Value    ${tl.ues[0].serial_number}    not_set
    ${device_model}     Get Variable Value    ${device_model}    ${UE_serial_nr}
    BuiltIn.Set Global Variable    ${device_model}
    BuiltIn.Set Global Variable    ${APOFF}            settings put global airplane_mode_on 0
    BuiltIn.Set Global Variable    ${APON}             settings put global airplane_mode_on 1
    BuiltIn.Set Global Variable    ${APBCAST}          am broadcast -a android.intent.action.AIRPLANE_MODE
    BuiltIn.Set Global Variable    ${APOFF_noroot}     adb -s ${device_model} shell "${APOFF}"
    BuiltIn.Set Global Variable    ${APON_noroot}      adb -s ${device_model} shell "${APON}"
    BuiltIn.Set Global Variable    ${APBCAST_noroot}   adb -s ${device_model} shell "${APBCAST}"
    BuiltIn.Set Global Variable    ${APOFF_root}       adb -s ${device_model} shell -t "su -c ${APOFF}"
    BuiltIn.Set Global Variable    ${APON_root}        adb -s ${device_model} shell -t "su -c ${APON}"
    BuiltIn.Set Global Variable    ${APBCAST_root}     adb -s ${device_model} shell -t "su -c ${APBCAST}"

Get The WMP Flag
    [Documentation]     This keyword should be used to get the WMP_flag.
    ${WMP_flag}         Run Keyword And Return Status    testline_info.Get Real Enbs    tl=${tl}
    BuiltIn.Set Global Variable    ${WMP_flag}

Get The IPV6 Flag
    [Documentation]     This keyword should be used to get the IPv6_Flag.
    ${IPv6_Flag}        Run Keyword And Return Status
    ...                 Should Contain    ${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}  :
    BuiltIn.Set Global Variable    ${IPv6_Flag}

Set SCF Directory
    [Documentation]     Sets SCF directory path.
    ${scf_dir}          Set Variable If    'ENB_900' in '${loadBuild}'
    ...    /home/ute/${QT_CONFIG_BRANCHES}/SBTS00/${NODE_NAME}
    ...    'ENB_950' in '${loadBuild}'    /home/ute/${QT_CONFIG_BRANCHES}/SBTS00/${NODE_NAME}
    ...    /home/ute/${QT_CONFIG_BRANCHES}/${STREAM_NUMBER}/${NODE_NAME}
    BuiltIn.Set Suite Variable     ${scf_dir}

Generate SCF Via Template
    [Documentation]     Generate SCF from template via scf_generator.py
    ${scf_suffix}             Get Variable Value    ${tl.custom['scf_suffix']}    None
    ${scf_suffix}             Set Variable If     '${scf_suffix}'!='None'    _${scf_suffix}    ${EMPTY}
    ${configs_path}           Set Variable    /home/ute/robotws/testsuite/QT/SRAN/configs
    ${json_template_path}     Set Variable    ${configs_path}/scf_templates/${STREAM_NUMBER}/${cellConfiguration}${scf_suffix}.xml.j2
    ${json_template_exist}    Run Keyword And Return Status    File Should Exist    ${json_template_path}
    ${json_template_path}     Set Variable If    '${json_template_exist}'=='False'
    ...                                           ${configs_path}/scf_templates/${cellConfiguration}${scf_suffix}.xml.j2
    ...                                           ${json_template_path}
    ${output_scf_file}        Set Variable    /tmp/tmp_SCF_${node_name_short}_${cellConfiguration}${scf_suffix}.xml
    Log To Console            \n WARN: SCF file will be generate by template
    Log To Console            --> INFO: path to json template: ${json_template_path}
    Run Keyword If    ${vCU_build_flag}
    ...    scf_generator.generate_scf    ${json_template_path}    ${tl.cu_scf_variables}    ${output_scf_file}
    ...    ELSE IF    ${vDU_build_flag}
    ...    scf_generator.generate_scf    ${json_template_path}    ${tl.du_scf_variables}    ${output_scf_file}
    ...    ELSE       scf_generator.generate_scf    ${json_template_path}    ${tl.scf_variables}    ${output_scf_file}
    ${scf_from_template_exist}    Run Keyword And Return Status    File Should Exist    ${output_scf_file}
    BuiltIn.Set Suite Variable    ${scf_from_template_exist}
    BuiltIn.Set Suite Variable    ${json_template_path}
    BuiltIn.Set Suite Variable    ${output_scf_file}

Set Variables for QT SWconfig
    ${cpri}             Set Variable If       'eCPRI' in '${cellConfiguration}'            eCPRI            CPRI
    ${tdd/fdd}          Set Variable If       'TDD' in '${cellConfiguration}'              TDD              FDD
    ${du_suffix}        Set Variable If       'ASO' in '${smod_type}'                      _${smod_type}    _${smod_type}_${bbmod_type}
    BuiltIn.Set Suite Variable    ${cpri}
    BuiltIn.Set Suite Variable    ${tdd/fdd}
    BuiltIn.Set Suite Variable    ${du_suffix}
    ${swconfig_dir}          Set Variable If    'ENB_9000' in '${loadBuild}'
    ...    /home/ute/${QT_CONFIG_BRANCHES}/SBTS_PSINT
    ...    'ENB_9001' in '${loadBuild}'    /home/ute/${QT_CONFIG_BRANCHES}/SBTS_PSINT2
    ...    'ENB_9501' in '${loadBuild}'    /home/ute/${QT_CONFIG_BRANCHES}/NIDD_INT1
    ...    /home/ute/${QT_CONFIG_BRANCHES}/${branch}
    BuiltIn.Set Suite Variable     ${swconfig_dir}

Get BBmod And Smod Type
    Run Keyword And Ignore Error    Connect to Common Unit    alias=smod
    ${smod_type}       get_board_name    board=master    hw_config=${hw_config}    connection=smod
    BuiltIn.Set Global Variable    ${smod_type}
    Run Keyword If     'ASO' not in '${smod_type}'    Set BBmod Type
    ...       ELSE     BuiltIn.Set Global Variable    ${bbmod_type}    None
    ${is_ASOG_A101}     is_ASOG_A101
    BuiltIn.Set Global Variable    ${is_ASOG_A101}

Set BBmod Type
    ${bbmod_type}      get_board_name    board=slave    hw_config=${hw_config}    connection=smod
    BuiltIn.Set Global Variable    ${bbmod_type}

Validate SCF and Log Status
    [Arguments]        ${scf}=${scf_path}
    Validate SCF and Log Status Classical    ${scf}
    ${scf_from_template_exist}    Get Variable Value    ${scf_from_template_exist}    False
    TRY
        Run    cp ${scf} ${OUTPUT_DIR}/Full_Commissioning/scf_used_for_commissioning_${tl.tl_cloud_topology}.xml
        Run Keyword If    '${scf_from_template_exist}'=='True'
        ...                Run    cp ${json_template_path} ${OUTPUT_DIR}/Full_Commissioning/${cellConfiguration}.xml.j2
    EXCEPT    AS    ${error}
        Log    Failed to copy scf template due to ${error}!    WARN
    END

Validate SCF and Log Status Classical
    [Arguments]        ${scf}=${scf_path}
    TRY
        ${scf_validation_result}    coam.validate_scf    ${scf}    connection=coam_admin
    EXCEPT    AS    ${error}
        Log    Failed to validate scf file, due to ${error}!, second attempt...     WARN
        WA for coam connect
        ${scf_validation_result}    coam.validate_scf    ${scf}    connection=coam_admin
    END
    Log to console     \n--> Validation status: ${scf_validation_result['niddValidationResult']['status']}

Check active SW version on cOAM
    [Arguments]        ${check_times}=5
    ...                ${T1orT2}=None
    ...                ${log}=${True}
    ...                ${AF_PATH}=${AF_PATH}
    ${check_sw_package}      Get Variable Value    ${check_sw_package}    ${AF_PATH}
    ${T0_install}=    Get Test Case Status By Name    Install Package
    Wait Until Keyword Succeeds     ${check_times}x  30s   Check sw_version not empty
    Verify Prefix For T0_T1_T2 Build    check_sw_package=${check_sw_package}    T0_install=${T0_install}    T1orT2=${T1orT2}   log=${log}

Verify Prefix For T0_T1_T2 Build
    [Arguments]    ${check_sw_package}    ${T0_install}    ${T1orT2}    ${log}
    ${strip_prefix}                  sw_version_parse_coam    ${sw_version}
    ${strip_prefix_without_T1_T2}    Replace String Using Regexp    ${strip_prefix}    T1|T2    ${EMPTY}
    ${check_sw_package}              Replace String    ${check_sw_package}    _release_BTSSM_downloadable_testpackage_T    T
    ${sw_check}                      Run Keyword if    '${T0_install}'=='NA' and '${log}'!='False'    Run Keyword And Return Status
    ...                              Should Contain     ${check_sw_package}     ${strip_prefix_without_T1_T2.strip()}
    ...    ELSE                      Run Keyword And Return Status    Should Contain     ${check_sw_package}     ${strip_prefix}
    ${T1_or_T2_sw_check}             Run Keyword if   ${sw_check} and '${T1orT2}'!='None'
    ...                              Run Keyword And Return Status    Should Contain     ${strip_prefix}     ${T1orT2}
    ${sw_check}                      Set Variable If    '${T1_or_T2_sw_check}'!='None'    ${T1_or_T2_sw_check}    ${sw_check}
    Run Keyword If                   ${sw_check}!=${True}    Run Keywords
    ...                              Set Global Variable    ${sw_message}    Active SW version is incorrect: ${sw_version}
    ...      AND                     FAIL    msg=${sw_message}

Check sw_version not empty
    ${sw_version}      coam.get_sw_version    timeout=30    connection=coam_admin
    Should not be empty    ${sw_version}
    Set Suite variable     ${sw_version}

Check permissions for files
    [Documentation]      This keyword is used to check permission for passive and active partition.
    ${connection}     Run Keyword And Return Status    ssh.connect_to
    ...               hostname=192.168.255.129
    ...               username=toor4nsn
    ...               password=oZPS0POrRieRtu
    ...               alias=gnb
    Run Keyword If    ${connection}   Run Keyword
    ...    Permission checks   permission=755
    ...    ELSE    Log    Connection failed, permission not checked!    WARN
    [Teardown]        Run Keyword if    ${connection}    ssh.disconnect    connection=gnb

Verify X2/NG and Cell Setup
    Log to console    \n Wait for cell setup...
    Run Keyword If    '${deployment}' == 'SA'
    ...               Wait Until Keyword Succeeds     8min  30s    Check NG link
    ...    ELSE       Run Keyword If    '${REAL_ENB}'=='False'      Run Keywords    Setup Wtsemu for X2 connection
    ...                                                                          AND    BuiltIn.Sleep    15s
    ...                                                                          AND    Start and check X2 connection
    ...       ELSE    Wait Until Keyword Succeeds    8min  30s    Check X2 link
    Wait Until Keyword Succeeds    3min  30s    Verify Cells Setup
    Log to console    \n Wait for cell setup DONE

Permission checks
    [Documentation]    This keyword is used to check permission for selected files
    [Arguments]  ${permission}
    ${check_file_list}  Create List  /ffs/run/etc/keys.d/certs  /ffs/run/etc/keys.d  /ffs/run/etc
    ...  /ffs/stb/etc/keys.d  /ffs/stb/etc
    FOR  ${file}  IN   @{check_file_list}
        ${output}=  check_file_permission  file=${file}   permission=${permission}  alias=gnb
        Should Be True  ${output}
    END

Check MRAT RF number
    [Arguments]        ${bts_host}=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ${output}          coam.get frm    timeout=30    connection=coam_admin
    TRY
        ${output}    coam.get frm    timeout=30    connection=coam_admin
    EXCEPT    AS    ${error}
        Log    Failed to get radio modules info, due to ${error}!, second attempt...     WARN
        WA for coam connect    bts_host=${bts_host}
        ${output}    coam.get frm    timeout=30    connection=coam_admin
    END
    Log Many           ${output}
    Should Not Be Empty    ${output}
    ${status}    Run Keyword And Return Status    Get Length RF Number    ${output}
    Run Keyword If    '${status}'=='${False}'    ${rf_number}    Evaluate    1
    BuiltIn.Set Global Variable    ${rf_number}
    Check MRAT RF Cells   output=${output}

Check MRAT RF Cells
    [Arguments]    ${output}
    @{GSM_CELL_LIST}    Create List
    @{WCDMA_CELL_LIST}  Create List
    @{LTE_CELL_LIST}    Create List
    @{5G_CELL_LIST}     Create List
    Set suite Variable   @{GSM_CELL_LIST}
    Set suite Variable   @{WCDMA_CELL_LIST}
    Set suite Variable   @{LTE_CELL_LIST}
    Set suite Variable   @{5G_CELL_LIST}
    FOR    ${elem}   IN    @{output}
        ${RF_index}=   Fetch From Right  ${elem['id']['configuration']}   /RMOD-
        ${carrierlist_length}=  Get Length   ${elem['carrierList']}
        Run Keyword If   ${carrierlist_length}>1    check MRAT subcell   ${elem['carrierList']}
        ...   ELSE    run keywords   Set Test Variable    ${5G_RF}       ${RF_index}
        ...   AND    Append To List       ${5G_CELL_LIST}        ${5G_RF}
        ...   AND    Set test Variable     @{5G_CELL_LIST}
        ${LTE_CELL_LIST_updated}   Remove Duplicates  ${LTE_CELL_LIST}
        ${5G_CELL_LIST_updated}   Remove Duplicates   ${5G_CELL_LIST}
        ${LTE_RF_LIST}   cut_rf_index   ${LTE_CELL_LIST_updated}
        ${LTE_CELL_length}=   get length  ${LTE_CELL_LIST_updated}
        ${5G_RF_LIST}   get_rf_list   ${5G_CELL_LIST_updated}
        ${5G_CELL_length}=   get length  ${5G_CELL_LIST_updated}
        ${WCDMA_CELL_LIST_updated}   Remove Duplicates  ${WCDMA_CELL_LIST}
        ${GSM_CELL_LIST_updated}   Remove Duplicates   ${GSM_CELL_LIST}
        ${WCDMA_RF_LIST}   cut_rf_index   ${WCDMA_CELL_LIST_updated}
        ${WCDMA_CELL_length}=   get length  ${WCDMA_CELL_LIST_updated}
        ${GSM_RF_LIST}   get_rf_list   ${GSM_CELL_LIST_updated}
        ${GSM_CELL_length}=   get length  ${GSM_CELL_LIST_updated}
        Set suite Variable     ${LTE_CELL_length}
        Set suite Variable     ${5G_CELL_length}
        Set suite Variable     @{LTE_RF_LIST}
        Set suite Variable     @{5G_RF_LIST}
        Set suite Variable     ${WCDMA_CELL_length}
        Set suite Variable     ${GSM_CELL_length}
        Set suite Variable     @{WCDMA_RF_LIST}
        Set suite Variable     @{GSM_RF_LIST}
    END
    ${LTE_CELL_length}      Set Variable If    ${LTE_CELL_length}>1      1    ${LTE_CELL_length}
    ${WCDMA_CELL_length}    Set Variable If    ${WCDMA_CELL_length}>1    1    ${WCDMA_CELL_length}
    ${GSM_CELL_length}      Set Variable If    ${GSM_CELL_length}>1      1    ${GSM_CELL_length}
    Set suite Variable      ${LTE_CELL_length}
    Set suite Variable      ${WCDMA_CELL_length}
    Set suite Variable      ${GSM_CELL_length}

check MRAT subcell
    [Arguments]    ${list}
    FOR    ${elem}   IN    @{list}
        ${output_1}=   set variable    ${elem['id']['configuration']}
        @{output}     Split String From Right   ${output_1}  separator=/  max_split=1
        ${RF_tmp}=    set variable  ${output[0]}
        set suite variable  ${RF_tmp}
        ${cell_type}   set variable if   'LNCEL' in '''${RF_tmp}'''     LTE
        ...   'NRCELL' in '''${RF_tmp}'''     5G
        ...   'WNCEL' in '''${RF_tmp}'''     WCDMA
        ...   'GNCEL' in '''${RF_tmp}'''     GSM
        set test variable  ${${cell_type}_RF}   RF${RF_tmp}
        Append To List  ${${cell_type}_CELL_LIST}   ${${cell_type}_RF}
        Set test Variable     @{LTE_CELL_LIST}
        Set test Variable     @{5G_CELL_LIST}
        Set test Variable     @{WCDMA_CELL_LIST}
        Set test Variable     @{GSM_CELL_LIST}
    END

Check RF Number
    [Arguments]        ${bts_host}=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}
    TRY
        ${output}    coam.get frm    timeout=30    connection=coam_admin
    EXCEPT    AS    ${error}
        Log    Failed to get radio modules info, due to ${error}!, second attempt...     WARN
        WA for coam connect    bts_host=${bts_host}
        ${output}    coam.get frm    timeout=30    connection=coam_admin
    END
    Log Many           ${output}
    Should Not Be Empty    ${output}
    ${status}    Run Keyword And Return Status    Get Length RF Number    ${output}
    Run Keyword If    '${status}'=='${False}'    ${rf_number}    Evaluate    1
    BuiltIn.Set Global Variable    ${rf_number}
    Check LTE And 5G RF    output=${output}

Check LTE And 5G RF
    [Arguments]    ${output}
    ${is_AEHC_OLD_BRANCH}=  Get Variable Value  ${tl.custom['AEHC_OLD_BRANCH']}    ${False}
    Set Test Variable    ${is_AEHC_OLD_BRANCH}
    @{LTE_RF_LIST}    Create List
    @{5G_RF_LIST}     Create List
    FOR    ${elem}   IN    @{output}
        ${LTE}    Run Keyword And Return Status    Should contain    ${elem['carrierList'][0]['id']['configuration']}    LNCEL
		${5G}     Run Keyword And Return Status    Should contain    ${elem['carrierList'][0]['id']['configuration']}    NRCELL
		${RF} =  Fetch From Right   ${elem['id']['configuration']}  /RMOD-
        Run Keyword If    ${LTE}    Run Keywords    Log To Console       \n RF${RF} => LTE
		...        AND                              Set Test Variable    ${LTE_RF}            RF${RF}
		...        AND                              Append To List       ${LTE_RF_LIST}       ${LTE_RF}
		...       ELSE IF    ${5G}            Run Keywords    Log To Console       \n RF${RF} => 5G
		...        AND                              Set Test Variable    ${5G_RF}             RF${RF}
		...        AND                              Append To List       ${5G_RF_LIST}        ${5G_RF}
		...      ELSE                Run Keywords    Log To Console       \n RF${RF} => 5G
		...        AND                              Set Test Variable    ${5G_RF}             RF${RF}
		...        AND                              Append To List       ${5G_RF_LIST}        ${5G_RF}
        Set Suite Variable     @{LTE_RF_LIST}
        Set Suite Variable     @{5G_RF_LIST}
        ${LTE_CELL_length}=   get length  ${LTE_RF_LIST}
        ${5G_CELL_length}=   get length  ${5G_RF_LIST}
        Set test Variable     ${LTE_CELL_length}
        Set test Variable     ${5G_CELL_length}
    END
    Run Keyword If   ${is_AEHC_OLD_BRANCH}   Run Keywords
    ...   Log To Console       \n RF${RF} => LTE
    ...   AND   Set Test Variable    ${LTE_RF}            RF${RF}
    ...   AND   Append To List       ${LTE_RF_LIST}       ${LTE_RF}
    ...   AND   Set test Variable     ${LTE_CELL_length}  1

Get Length RF Number
    [Arguments]        ${output}
    ${rf_number}       Get Length    ${output}
    BuiltIn.Set Test Variable        ${rf_number}

Reset port on PDU
    [Arguments]        ${PDU_IP}    ${PDU_PORT}    ${alias}=pdu    ${model}=ATEN    ${version}=${None}
    Log To Console     \n Reset ongoing for PDU ${PDU_IP}, port ${PDU_PORT}
    pdu.setup_pdu      host=${PDU_IP}
    ...                model=${model}
    ...                alias=${alias}
    ...                version=${version}
    Run Keyword If    '${site}'=='TSR'    Run Keywords
    ...                Log To Console     \n Note: Reversed pdu action is performed on TSR site!!!
    ...                AND     pdu.power_on    port=${PDU_PORT}   pdu_device=${alias}
    ...                AND     BuiltIn.Sleep    10s
    ...                AND     pdu.power_off    port=${PDU_PORT}    pdu_device=${alias}
    ...                ELSE    Run Keywords     pdu.power_off       port=${PDU_PORT}    pdu_device=${alias}
    ...                AND     BuiltIn.Sleep    10s
    ...                AND     pdu.power_on     port=${PDU_PORT}    pdu_device=${alias}
    BuiltIn.Sleep      10s
    #check if port is opened(TSR is off, WRO is on):
    ${port_status}     pdu.get_port_status    port=${PDU_PORT}
    ...                                       pdu_device=${alias}
    Run Keyword If    '${site}'=='TSR'
    ...                Should Contain     ${port_status}    off
    ...                ELSE    Should Contain     ${port_status}    on
    [Teardown]   pdu.teardown_pdu    pdu_device=${alias}

Power Off PDU Port
    [Arguments]        ${PDU_IP}    ${PDU_PORT}    ${alias}=atenpdu    ${model}=ATEN    ${version}=${None}
    Log To Console     \n Power Off PDU ${PDU_IP}, port ${PDU_PORT}
    pdu.setup_pdu      host=${PDU_IP}
    ...                model=${model}
    ...                alias=${alias}
    ...                version=${version}
    pdu.power_off      port=${PDU_PORT}
    ...                pdu_device=${alias}
    BuiltIn.Sleep              10s
    # check if port is Off:
    ${port_status}     pdu.get_port_status    port=${PDU_PORT}
    ...                                       pdu_device=${alias}
    Should Contain     ${port_status}    off
    [Teardown]   pdu.teardown_pdu    pdu_device=${alias}

Power On PDU Port
    [Arguments]        ${PDU_IP}    ${PDU_PORT}    ${alias}=atenpdu    ${model}=ATEN    ${version}=${None}
    Log To Console     \n Power On PDU ${PDU_IP}, port ${PDU_PORT}
    pdu.setup_pdu      host=${PDU_IP}
    ...                model=${model}
    ...                alias=${alias}
    ...                version=${version}
    pdu.power_on      port=${PDU_PORT}
    ...                pdu_device=${alias}
    BuiltIn.Sleep              10s
    # check if port is On:
    ${port_status}     pdu.get_port_status    port=${PDU_PORT}
    ...                                       pdu_device=${alias}
    Should Contain     ${port_status}    on
    [Teardown]   pdu.teardown_pdu    pdu_device=${alias}

Get Cells info
    TRY
        ${cell_info}       coam.get_subcells_info    connection=coam_admin
    EXCEPT    AS    ${error}
		Log    Failed to get subcells info, due to ${error}!, second attempt...     WARN
        WA for coam connect
        ${cell_info}       coam.get_subcells_info    connection=coam_admin
    END
    BuiltIn.Set Global Variable    ${cell_info}

Verify CU_OAM Cell Setup
    ${output}           coam.get_cells_info    timeout=30    connection=coam_admin
    ${out_str}          Convert To String     ${output}
    Should Contain      ${out_str}    'availabilityStatus': u'Online'       ignore_case=True
    Should Contain      ${out_str}    u'proceduralStatus': u'configured'    ignore_case=True
    Should Not Contain  ${out_str}    u'proceduralStatus': u'offline'       ignore_case=True
    Should Contain      ${out_str}    u'operationalState': u'enabled'       ignore_case=True
    Should Not Contain  ${out_str}    u'operationalState': u'disabled'      ignore_case=True

Get timestamp
    [Documentation]     Author: Ding Binmei HGZ_SG4
    ...                 Description: Get timestamp. Example return value is: 20181019073816
    @{time}             Get time    year month day hour min sec
    ${time_stamp}       Set variable    ${EMPTY}
    FOR    ${item}    IN    @{time}
        ${time_stamp}   Catenate    SEPARATOR=${EMPTY}    ${time_stamp}    ${item}
    END
    RETURN            ${time_stamp}

Install New Package By Yaft And Perform Commissioning
    [Documentation]     Author: Emilia Sadowska
    ...                 Description: Install new package by yaft then perform commissioning
    Download Yaft
    Log To Console      \n Set Swconfig For Yaft...
    Set Swconfig For Yaft
    Log To Console      Install gNB SW By Yaft...
    Install gNB SW By Yaft
    Log To Console      Perform Commissioning...
    Perform Commissioning With NIDD Check For Classical
    Log To Console      Check RF Status...
    ${rf_status}        Run Keyword And Return Status
    ...                 Wait Until Keyword Succeeds    10min  30s    Check RF Status     connection=admin
    Run Keyword If      '${rf_status}'=='False'        Run Keyword
    ...                 Check If FID23 Is Visible And If Yes Perform SW Update On RU
    Log To Console      Wait For Onair... \n
    ${onair}    Run Keyword And Return Status    Wait Until Keyword Succeeds    10min   30s    Verify BTS Setup    connection=admin
    Run Keyword If    '${onair}'=='True'    Log To Console      \n OnAir Reached!  \n
    ...       ELSE     Fail    msg=\n bts did not reach OnAir! \n
    [Teardown]    Run    sudo rm -rf /home/ute/YAFT*

Install By Yaft
    [Arguments]       ${path}=${AF_PATH}
    Log To Console    \n \n Start Yaft...\n
    Wait Until Keyword Succeeds    2min   30s    Connect To Uncommissioned Common Unit
    ssh.Execute     ls -lrt /ffs | grep run | awk '{print $11}'   connection=master    timeout=60s
    Connect To Host
    ${load_res}    install_loadimage_by_yaft   /home/ute/YAFT
    ...                                        ${LMP_IP}
    ...                                        ${path}
    Run Keyword If    '${load_res}' == 'False'    Run Keywords
    ...           Wait Until Keyword Succeeds     10min    10sec    Connect To Uncommissioned Common Unit
    ...    AND    install_loadimage_by_yaft     /home/ute/YAFT
    ...                                         ${LMP_IP}
    ...                                         ${path}
    ${pdu_reboot}       Run Keyword And Return Status    reboot_pdu_port    ip=${smod_pdu_host}    port=${smod_pdu_port}
    Run Keyword If      '${pdu_reboot}'=='${False}'    Log To Console    \n\t\t> > > PDU reboot failed < < < [ !!! ]\n
    ...                                        ELSE    Log To Console    \n\t\t> > > PDU reboot succeeded < < < \n
    Wait Until Keyword Succeeds    5min   30s    coam.connect_to      bts_host=${LMP_IP}    update_interval=1000   name=admin
    Wait Until Keyword Succeeds    10min  30s    Check Smod State     connection=admin
    Run Keyword If    'ASO' not in '${smod_type}'    Wait Until Keyword Succeeds    10min  30s    Check BBmod State    connection=admin
    Log To Console    \n Yaft Finished Successfully \n

Download Yaft
    [Arguments]   ${dir}=/home/ute/yaft
    ${status}     Run Keyword And Return Status
    ...           OperatingSystem.Directory Should Exist    path=${dir}
    ${com}    Set Variable    git clone https://ca_btsauto:btsauto_p4ss@gerrit.ext.net.nokia.com/gerrit/MN/RPSW/LFS/build/yaft/ ${dir}
    Run Keyword If    '${status}'!='${True}'    Run Keywords
    ...                Run      ${com}
    ...        AND     BuiltIn.Sleep    10s
    ...        AND     OperatingSystem.Directory Should Exist    path=${dir}
    ...                                         msg=There is no yaft directory in /home/ute/!

Set Swconfig For Yaft
    Set Variables for QT SWconfig
    Run    sudo rm /home/ute/YAFT/libyaft/swconfig.txt
    ${swconfig}         Set Variable     swconfig${du_suffix}_${tdd/fdd}_${cpri}.txt
    ${swconfig_path}    Set Variable    /home/ute/${QT_CONFIG_BRANCHES}/${branch}/${swconfig}
    Run    sudo cp ${swconfig_path} /home/ute/YAFT/libyaft/swconfig.txt
    Run    sudo chmod 777 /home/ute/YAFT/libyaft/swconfig.txt
    ${swconfig_flag}   Get Variable Value    ${tl.custom['swconfig_flag']}    \n
    Run    sudo echo "${swconfig_flag}" >> /home/ute/YAFT/libyaft/swconfig.txt
    Run    sudo echo "0x30000F=1" >> /home/ute/YAFT/libyaft/swconfig.txt
    Run    sudo echo "0x1A0020=1" >> /home/ute/YAFT/libyaft/swconfig.txt

Get SCF File
    [Arguments]       ${bts_host}=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}
    TRY
        coam.get_current_scf_file    local_dir_path=${OUTPUT_DIR}
        ...                          file_name=scf_before_yaft.xml
        ...                          connection=coam_admin
    EXCEPT    AS    ${error}
        Log    Failed to get current scf file, due to ${error}!, second attempt...     WARN
        WA for coam connect    bts_host=${bts_host}
        coam.get_current_scf_file    local_dir_path=${OUTPUT_DIR}
        ...                          file_name=scf_before_yaft.xml
        ...                          connection=coam_admin
    END

Connect to gNB And Mount Partitions
    Wait Until Keyword Succeeds    5min    30s    ssh.connect_to
    ...                 hostname=192.168.255.129
    ...                 username=toor4nsn
    ...                 password=oZPS0POrRieRtu
    ...                 alias=gnb

    ${cmd}              Catenate    systemctl start /ffs/fs1; systemctl start /ffs/fs2;
    ...                             mount -o remount,rw,async /ffs/fs1;mount -o remount,rw,async
    ...                             /ffs/fs2; ls /ffs/
    ssh.execute         command=${cmd}    connection=gnb    timeout=60s
    Should Contain      ${cmd}      fs1
    Should Contain      ${cmd}      fs2
    ${cmd2}             Catenate    systemctl stop etc-keys.d-board.mount; systemctl start etc-keys.d-board.mount;
    ...                             systemctl stop etc-keys.d-bcerts.mount; systemctl start etc-keys.d-bcerts.mount
    ssh.execute         command=${cmd2}    connection=gnb    timeout=60s

    ${cmd3}             Catenate    systemctl stop crypto-agent.service; systemctl start crypto-agent.service;
    ...                             systemctl stop crypto-agent-check.service;
    ...                             systemctl start crypto-agent-check.service
    ssh.execute         command=${cmd3}    connection=gnb    timeout=60s
    Run                 sudo systemctl stop dnsmasq
    ssh.disconnect      connection=gnb

Install gNB SW By Yaft
    [Arguments]         ${smod_pdu_host}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    ...                 ${smod_pdu_port}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    Run                 pip install --upgrade pip
    Run                 pip install paramiko --upgrade
    ${yaft_script}      Catenate     cd /home/ute/YAFT/; sudo sshpass -p 'oZPS0POrRieRtu' python3 yaft.py
    ...                 -i 192.168.255.129 -z ${AF_PATH} --ask_for_password
    ${install_by_yaft}  Run    ${yaft_script}
    ${flashing}    Run Keyword And Return Status    Should Contain      ${install_by_yaft}    Flashing done
    Run Keyword If    '${flashing}'=='True'    Log To Console    \n\t\t\t> > > Flashing done! < < < \n
    ...       ELSE      Fail    msg=\n\t\t\t> > > Flashing fail! < < < \n
    ${pdu_reboot}       Run Keyword And Return Status    reboot_pdu_port    ip=${smod_pdu_host}    port=${smod_pdu_port}
    Run Keyword If      '${pdu_reboot}'=='${False}'    Log To Console    \n\t\t> > > PDU reboot failed < < < \n
    ...                                        ELSE    Log To Console    \n\t\t> > > PDU reboot succeeded < < < \n
    Wait Until Keyword Succeeds    5min   30s    coam.connect_to      bts_host=${LMP_IP}    update_interval=1000   name=admin
    Wait Until Keyword Succeeds    10min  30s    Check Smod State     connection=admin
    Run Keyword If      'ASO' not in '${smod_type}'    Wait Until Keyword Succeeds    10min  30s    Check BBmod State    connection=admin

Set SMOD Type
    @{smod_types}        Create List    ASIA   ASIB   ASIK   ASOE   ASOD   ASIL   ASIM
    FOR    ${ELEMENT}   IN    @{smod_types}
        Run Keyword If    '${ELEMENT}' in '${cellConfiguration}'    Set Suite Variable    ${smod}    ${ELEMENT}
    END
    Set Test Variable    ${smod_type}    ${smod}

Set BBMOD Type For YAFT
    @{bbmod_types}        Create List    ABIL    ABIO    ABIP
    FOR    ${ELEMENT}   IN    @{bbmod_types}
        Run Keyword If    '${ELEMENT}' in '${hw_config}'    Set Suite Variable    ${bbmod}    ${ELEMENT}
    END
    Set Test Variable    ${bbmod_types}    ${bbmod}

Get the SA flag
    [Documentation]   This keyword should be used to get the SA_Flag.
    ...    author: gaofan.shi
    ${enbs}    testline_info.has_enb    ${tl}
    Run Keyword If    '${enbs}'=='False'    Set Suite Variable    ${SA_Flag}    True
    ...    ELSE    Set Suite Variable    ${SA_Flag}    False
    LOG    ${SA_Flag}

Get test timestamp
    [Documentation]   This keyword should be used to get the UE type.
	...    author: tong,weichao
    ${timestamp}=    Get timestamp
    set suite variable    ${timestamp}

Get NIDD Sub Version AP
    @{nidd_sub_ver}    Split String    ${nidd_ver_ap}    ,
    ${nidd_sub_ver_status}    Run Keyword And Return Status    Should contain     ${nidd_sub_ver}    NIDD
    Run Keyword If    ${nidd_sub_ver_status}!=${True}    Set Variable    ${nidd_sub_ver}    Error
    Set Suite Variable    ${nidd_sub_ver}
    Log To Console    NIDD sub versions should be at: ${nidd_sub_ver}

Get NIDD from Vendor XML
    ${vCU_build_flag}     Get Variable Value    ${vCU_build_flag}    ${False}
    ${vDU_build_flag}     Get Variable Value    ${vDU_build_flag}    ${False}
    Run Keyword If    ${vCU_build_flag} or ${vDU_build_flag}
    ...    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=vendor
    ...    ELSE    Connect To Common Unit          alias=vendor
    ${nidd_ver}    Run Keyword If    ${vCU_build_flag} or ${vDU_build_flag}
    ...    get_nidd_version_from_vendor_xml    alias=vendor    loadBuild=${loadBuild}    tenant=${${par_prefix}_tenant}
    ...    ELSE        get_nidd_version_from_vendor_xml    alias=vendor    loadBuild=${loadBuild}
    Set Suite Variable    ${nidd_ver}
    Log To Console    NIDD should be at: ${nidd_ver}
    [Teardown]        ssh.disconnect    connection=vendor

Get NIDD Version From SCF
    get_scf_file_from_testline    scf_location=${OUTPUTDIR}/scf.xml
    ${nidd_scf}    get_nidd_version_from_scf_file    scf_location=${OUTPUTDIR}/scf.xml
    Set Suite Variable    ${nidd_scf}
    Log To Console    NIDD is at: ${nidd_scf}

Check If Directory On Repo Exists And Get Latest SCF
    ${testline_name}    Set Variable    ${node_name_short}
    Set Suite Variable    ${testline_name}
    ${is_tl_dir_on_repo}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${scf_dir}
    Set Suite Variable    ${is_tl_dir_on_repo}
    ${scf_on_repo}    Run Keyword If   ${is_tl_dir_on_repo}   Run    ls -t -1 ${scf_dir} | grep .xml$
    ${split_scf_repo}    Run Keyword If   ${is_tl_dir_on_repo}    Split String    ${scf_on_repo}
    Run Keyword If   ${is_tl_dir_on_repo}    Sort List    ${split_scf_repo}
    ${latest_scf_on_repo}    Set Variable If    ${is_tl_dir_on_repo}    ${split_scf_repo[-1]}    ${False}
    Set Suite Variable    ${latest_scf_on_repo}
    ${is_scf_with_nidd_on_repo}=    Run Keyword If   ${is_tl_dir_on_repo}
    ...    Run Keyword And Return Status   List Should Contain Value
    ...    ${split_scf_repo}    ${nidd_ver}_${testline_name}.xml
    ...    ELSE    Set Variable    ${False}
    Set Suite Variable    ${is_scf_with_nidd_on_repo}

Perform Commissioning With NIDD Check For Classical
    [Arguments]    ${skip_change_sync_type}=False
    Run Keyword And Ignore Error    Create Directory    ${OUTPUT DIR}/Full_Commissioning
    ${nidd_ver}    Get Variable Value    ${nidd_ver}    ${EMPTY}
    Run Keyword If    '${nidd_ver}'=='${EMPTY}'    Get NIDD from Vendor XML
    ${scf_from_template_exist}    Set Variable    False
    ${template_scf_variables}     Run Keyword And Return Status    Variable Should Exist    ${tl.scf_variables}
    Set Suite Variable            ${template_scf_variables}
    TRY
        Run Keyword If         ${template_scf_variables}    Generate SCF Via Template
    EXCEPT    AS    ${error}
        Log    !!!SCF generation failed due to ${error}!!! Test will be continued with scf in qt_config repo    WARN
    END
    Set SCF Directory
    Run Keyword And Ignore Error    Check If Directory On Repo Exists And Get Latest SCF
    ${is_tl_dir_on_repo}           Get Variable Value    ${is_tl_dir_on_repo}           False
    Set Suite Variable             ${is_tl_dir_on_repo}
    ${is_scf_with_nidd_on_repo}    Get Variable Value    ${is_scf_with_nidd_on_repo}    False
    ${latest_scf_on_repo}          Get Variable Value    ${latest_scf_on_repo}          False
    ${custom_scf}                  Run Keyword And Return Status    File Should Exist    /tmp/scf.xml
    Run Keyword If                 ${is_tl_dir_on_repo} and ${is_scf_with_nidd_on_repo}==${False} and 'ENB_9990' in '${loadBuild}'
    ...                            Get SCF For CD If NIDD check failed
    ${cd_scf_last}                 Get Variable Value    ${cd_scf_last}    False
    ${branch}    Get Variable Value    ${branch}    DEFAULT
    ${use_scf_template}    Evaluate    '${scf_from_template_exist}'=='True' and 'SBTS23R3' not in '${branch}'
    ${scf_path}    Set Variable If    '${custom_config}'=='${True}' and ${custom_scf}    /tmp/scf.xml
    ...     ${template_scf_variables} and ${use_scf_template}     ${output_scf_file}
    ...    '${cd_scf_last}'!='False' and 'ENB_9990' in '${loadBuild}'    ${scf_dir}/${cd_scf_last}
    ...    '${is_tl_dir_on_repo}'=='True' and '${is_scf_with_nidd_on_repo}'=='True'   ${scf_dir}/${nidd_ver}_${testline_name}.xml
    ...    ('${is_scf_with_nidd_on_repo}'=='False' and '${is_tl_dir_on_repo}'=='True') or '${nidd_ver}'=='None'
    ...    ${scf_dir}/${latest_scf_on_repo}
    ${scf_path_exist}     Run Keyword And Return Status    File Should Exist    ${scf_path}
    ${scf_path_exist}    Set Variable If
    ...    not ${is_scf_with_nidd_on_repo} and '${cd_scf_last}'=='False' and 'ENB_9990' in '${loadBuild}' and not ${use_scf_template}
    ...      ${False}    ${scf_path_exist}
    Run Keyword If    '${scf_path_exist}'=='False' and not ${use_scf_template}    Run Keywords
    ...               Log    Scf not found in repo, scf file from site will be saved and used for commission!!!    level=WARN
    ...    AND        Save SCF For Classical
    ...    ELSE IF    '${is_scf_with_nidd_on_repo}'=='False' and '${is_tl_dir_on_repo}'=='True' and not ${use_scf_template}
    ...    Log         ${nidd_ver}_${testline_name}.xml doesn't exist in repo, latest scf file ${latest_scf_on_repo} will be used!!!
    ...                level=WARN
    ...    ELSE IF    '${nidd_ver}'=='None' and not ${use_scf_template}
    ...                Log    Unable to get NIDD version, latest scf file ${latest_scf_on_repo} will be used!!!    level=WARN
    ${scf_path}    Set Variable IF    ${scf_path_exist}    ${scf_path}
    ...                               ${OUTPUT_DIR}/scf_from_webui_${tl.tl_cloud_topology}.xml
    Set Suite Variable    ${scf_path}
    ${WORKSPACE}    Get Variable Value     ${WORKSPACE}    None
    ${is_PSINT}    Evaluate    ('ENB_9000' in '${loadBuild}' or 'ENB_9001' in '${loadBuild}') and 'NIDD_DOWNGRADE' not in '${WORKSPACE}'
    IF    not ${skip_change_sync_type} and ${is_PSINT} and '${tl.tl_cloud_topology}' in $change_sync_testlines
        Change Synchronization Type
    END
    Log To Console    \n --> INFO: path to SCF: ${scf_path}
    ${status}         Run Keyword And Return Status    Validate SCF and Log Status    ${scf_path}
    FOR    ${index}    IN RANGE    10
        TRY
            coam.perform_commissioning     scf_file=${scf_path}    skip_parameter_relation_errors=False
            ...                            timeout=660    connection=coam_admin
            BREAK
        EXCEPT  AS  ${error}
            IF    'Configuration data activation has failed because GNSS SW update is ongoing' in """${error.replace('"', '')}"""
                Log to Console    ==> GNSS SW update is ongoing, wait one minute and try SCF comission for ${index+2} time...
                IF    '4340' not in @{CLASSICAL_ALLOWED_ACITVE_ALARMS}
                    Append To List    ${CLASSICAL_ALLOWED_ACITVE_ALARMS}    4340
                    Append To List    ${CLASSICAL_ALLOWED_HISTORICAL_ALARMS}    4340
                END
                BuiltIn.Sleep    60s
                CONTINUE
            ELSE
               Fail    SCF comission failed due to ${error}
            END
        END
    END
    ${scf_status}=   Run Keyword And Return Status   Save SCF For Classical
    ${scf_validation_result}=  Run Keyword If    ${scf_status}
    ...    Validate Scf Online    scf_file=${OUTPUT_DIR}/scf_from_webui_${tl.tl_cloud_topology}.xml
    ...    connection=coam_admin
    Run Keyword If    ${scf_status}   Run Keywords
    ...    Should Be True    '${scf_validation_result['requestMessage']['niddValidationResult']['status']}'=='OK'
    ...    AND   Should Be True    '${scf_validation_result['requestMessage']['pdlValidationResult']['status']}'=='OK'
    ...    ELSE   Log    Save SCF failed and validation skipped !!!    WARN
    IF    not ${skip_change_sync_type} and ${is_PSINT} and '${tl.tl_cloud_topology}' in $change_sync_testlines
        Check Synchronization Type
    END

Change Synchronization Type
    [Documentation]    Author: Emilia Sadowska
    ...                Description: Change current synchronization type to check if both are working: GPS and TOP.
    ...                If TOP will be current sync then after commissioning it will be changed to GPS and vice versa.
    ...                Change is done by updating scf with target sync type and priority.
    Log To Console    \n --> INFO: path to base SCF: ${scf_path}
    ${scf_name}    Fetch From Right    ${scf_path}    /
    ${scf_name}    Fetch From Left     ${scf_name}    .
    TRY
        ${bts_info}    coam.Get Bts Info    connection=coam_admin
    EXCEPT    AS    ${error}
        Log    Failed to get bts info, due to ${error}!, second attempt...     WARN
        WA for coam connect    bts_host=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}
        ${bts_info}    coam.Get Bts Info    connection=coam_admin
    END
    ${bts_sync_status}    coam.Get Synchronization Information    connection=coam_admin
    FOR    ${sync}    IN    @{bts_sync_status['syncSourceInfo']}
            Set Test Variable    ${bts_sync_${sync['syncInputPrio']}}    ${sync['syncInputType']}
    END
    Log To Console     \n --> INFO: Synchronization type is: ${bts_sync_1}
    ${scf_xml}         Parse Xml    ${scf_path}
    ${distName}        Set Variable    MRBTS-${bts_info['mrbtsID']}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ${sync_type}       Get Element Text    ${scf_xml}    .//managedObject[@distName="${distName}"]/list/item[1]/p[@name="syncInputType"]
    Log To Console     \n --> INFO: Current synchronization type is: ${sync_type}
    ${sync_prio}       Get Element Text    ${scf_xml}    .//managedObject[@distName="${distName}"]/list/item[1]/p[@name="syncInputPrio"]
    Log To Console     \n --> INFO: Current synchronization priority is: ${sync_prio}
    ${topp_status}     Run Keyword And Return Status    Element Should Exist    ${scf_xml}
    ...                .//managedObject[@distName="MRBTS-${bts_info['mrbtsID']}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1"]
    ${topf_status}     Run Keyword And Return Status    Element Should Exist    ${scf_xml}
    ...                .//managedObject[@distName="MRBTS-${bts_info['mrbtsID']}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPF-1"]
    Run Keyword If     ${topp_status}==${False}    Should Be True    ${topf_status}
    ${top}             Set Variable If    ${topp_status}    TOPP    TOPF
    ${target_sync}     Set Variable If    'GNSS' in '${bts_sync_1}'    ${top}    1pps/ToD from external GNSS receiver
    ${status}          Run Keyword And Return Status
    ...                Element Should Exist    source=${scf_xml}    xpath=.//managedObject[@distName="${distName}"]/list/item[2]
    Run Keyword If     ${status}    xml.Remove Element    source=${scf_xml}    xpath=.//managedObject[@distName="${distName}"]/list/item[2]
    Set Element Text   source=${scf_xml}    text=1
    ...                xpath=.//managedObject[@distName="${distName}"]/list/item[1]/p[@name="syncInputPrio"]
    Set Element Text   source=${scf_xml}    text=${target_sync}
    ...                xpath=.//managedObject[@distName="${distName}"]/list/item[1]/p[@name="syncInputType"]
    Save Xml              ${scf_xml}     path=${OUTPUT_DIR}/${scf_name}_new_sync.xml
    Set Suite Variable    ${scf_path}    ${OUTPUT_DIR}/${scf_name}_new_sync.xml
    Log To Console        \n --> INFO: Synchronization type will be changed to: ${target_sync}

Check Synchronization Type
    [Documentation]    Author: Emilia Sadowska
    ...                Description: Check current synchronization type on bts. Sync should be different than before commisioning
    ...                and there should be no other type of sync with priority: 2.
    TRY
        ${bts_info}    coam.Get Bts Info    connection=coam_admin
    EXCEPT    AS    ${error}
        Log    Failed to get bts info, due to ${error}!, second attempt...     WARN
        WA for coam connect    bts_host=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}
        ${bts_info}    coam.Get Bts Info    connection=coam_admin
    END
    ${bts_sync_status}    coam.Get Synchronization Information    connection=coam_admin
    FOR    ${sync}    IN    @{bts_sync_status['syncSourceInfo']}
            Set Test Variable    ${bts_sync_after_scf_${sync['syncInputPrio']}}    ${sync['syncInputType']}
    END
    Log To Console    \n --> INFO: Synchronization type is: ${bts_sync_after_scf_1}
    Should Be True    '${bts_sync_after_scf_1}'!='${bts_sync_1}'
    Variable Should Not Exist    ${bts_sync_after_scf_2}

Get SCF For CD If NIDD check failed
    [Documentation]      Set last scf for CD if there is no scf with nidd
    ${nidd_ver}          Remove String Using Regexp    ${nidd_ver}    _    SBTS    NIDD    R
    ${scf_on_repo}       Run    ls -t -1 ${scf_dir} | grep .xml$
    ${split_scf_repo}    Split String    ${scf_on_repo}
    &{scf_dictionary}    Create Dictionary
    FOR    ${scf}    IN    @{split_scf_repo}
        ${scf_nidd_ver}      Remove String Using Regexp    ${scf}    _    SBTS    NIDD    ${testline_name}.xml    R
        Set To Dictionary    ${scf_dictionary}             ${scf_nidd_ver}    ${scf}
    END
    ${keys}    Get Dictionary Keys    ${scf_dictionary}
    Reverse List     ${keys}
    ${cd_scf_last}    Set Variable    False
    FOR    ${item}    IN    @{keys}
        ${status}         Run Keyword And Return Status    Should Be True    ${item} < ${nidd_ver}
        ${scf_file}       Get From Dictionary    ${scf_dictionary}    ${item}
        ${cd_scf_last}    Set Variable If    ${status}==${True}    ${scf_file}    ${cd_scf_last}
        Exit for loop if    ${status}
    END
    Set Global Variable    ${cd_scf_last}

Check If FID23 Is Visible On RU
    [Arguments]          ${host}=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}
    Wait Until Keyword Succeeds    1min  15s    coam.connect_to    bts_host=${host}   update_interval=1000   name=coam
    ${active_alarms}     coam.get_active_alarms     connection=coam
    FOR   ${alarm}   IN   @{active_alarms}
       ${dict_fault_id}      Get From Dictionary       ${alarm}   faultId
       ${fault_23_status}    Run Keyword And Return Status
       ...   Should Be Equal   '23'   '${dict_fault_id}'
       IF    ${fault_23_status}
           RETURN    ${True}
       END
    END
    RETURN    ${False}
    [Teardown]    ssh.reset_cache

Retry SBTS Package Installation If BTS is Busy
    [Arguments]         ${T1orT2}=None    ${sw_package}=${AF_PATH}
    FOR    ${index}    IN RANGE    10
        TRY
            Install Package On COAM    sw_package=${sw_package}    T1orT2=${T1orT2}
            BREAK
        EXCEPT    AS    ${error}
            ${match_str}    Get Regexp Matches
            ...    ${error}     BTS is busy|radio SW upgrade installation failed
            ${retry_installation}    Run Keyword And Return Status    Should Not Be Empty    ${match_str}
            IF    ${retry_installation}
                Log to console
                ...   --> SW installation failed due to ${match_str}, Sleep 5 minutes and try SBTS package installation for ${index+2} time...
                BuiltIn.Sleep    5m
                CONTINUE
            ELSE
                Fail    SW installation failed due to ${error}!!!
            END
        END
    END

Reboot UE With Wihajster
    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                     cpc_username=${cpc_username}
    ...                     cpc_password=${cpc_password}
    Wait Until Keyword Succeeds    90    1s    Reboot UE With Wihajster And Wait For Status Change
    [Teardown]    ssh.disconnect    connection=controlPC

Reboot UE With Wihajster And Wait For Status Change
    Log To Console    \n UE power up with wihajster
    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                     cpc_username=${cpc_username}
    ...                     cpc_password=${cpc_password}
    ssh.send_command    sh ./wihajster.sh    connection=controlPC
    Wait Until Keyword Succeeds    15    5     Run Keyword And Expect Error    *    ADB devices
    Wait Until Keyword Succeeds    90    10    ADB devices
    [Teardown]    ssh.disconnect    connection=controlPC

Update Wihajster Script On Raspberry
    ${sshpass_pc}    Set Variable    sshpass -p ${tl.ues[0].ssh_connection_details.password}
    ${path_info}    Set Variable
    ...    ${tl.ues[0].ssh_connection_details.username}@${tl.ues[0].ssh_connection_details.addr}:/home/${tl.ues[0].ssh_connection_details.username}/
    Run    ${sshpass_pc} scp ${CURDIR}/../python/Wihajster.py ${path_info}
    ${scp_ret_code}  Run    echo $?
    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                     cpc_username=${cpc_username}
    ...                     cpc_password=${cpc_password}
    ssh.send_command    scp /home/${tl.ues[0].ssh_connection_details.username}/Wihajster.py pi@raspberrypi.local:/home/pi/    connection=controlPC
    ${scp_ret_code_pi}   ssh.execute    echo $?    connection=controlPC    timeout=20s
    [Teardown]    ssh.disconnect    connection=controlPC

AIC_TDD_teardown
    Run Keyword If    '${is_TDD}'=='True'    Run Keywords
    ...    ssh.Connect to    hostname=${DU_k8s_addr}    username=${DU_k8s_user}    password=${DU_k8s_pwd}    alias=RM_alias
    ...    AND    Log To Console      \nTo avoid Timing issue linuxptp-daemon pod will be restart
    ...    AND    ssh.execute
    ...    command=kubectl get pods -n openshift-ptp | grep linuxptp-daemon| awk '{print $1}' | xargs kubectl delete pods -n openshift-ptp
    ...    connection=RM_alias
    ...    timeout=60s
    ...    AND    Wait Until Keyword Succeeds    5min  30s    Check if linuxptp-daemon pod is running
    Run Keyword And Ignore Error    ssh.disconnect    connection=RM_alias

WA for coam connect
    [Documentation]    Switch to LMP ip if there is network issue on oam ip
    [Arguments]        ${bts_host}=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}    ${time}=1min    ${log}=${True}
    ...    ${alias}=coam_admin
    ${connect_status}    Run Keyword and Return Status    Wait Until Keyword Succeeds    ${time}    15s    coam.connect to
    ...                                                                                                    bts_host=${bts_host}
    ...                                                                                                    update_interval=500
    ...                                                                                                    name=${alias}
    Run Keyword If    ${connect_status}!=${True}    Run Keywords
    ...               Check Ping result    ${bts_host}
    ...        AND    Run Keyword If    ${log}    Log    Ping ip ${bts_host} succeed but setup web connection failed, pls check!    WARN
    ...        AND    Wait Until Keyword Succeeds    1min    15s    coam.connect To
    ...                                                             bts_host=192.168.255.129
    ...                                                             update_interval=1000
    ...                                                             name=${alias}

Check Ping result
    [Documentation]   Check ping result of given ip
    [Arguments]    ${ip}
    ${rc}=    Run and return rc    ping ${ip} -c 10 -w 60
    Should be True    ${rc}==0     Given ip ${ip} is not reachable!

sha256 check
    [Timeout]       3 min
    [Documentation]    Compare md5sum for two files
    ...                author: Yin Jie
    [Arguments]        ${target_file_path}    ${remote_file_path}    ${connection}
    ${sha256sum}=    ssh.execute    command=sha256sum ${target_file_path}    connection=${connection}    timeout=20s
    ${sha256sum}=    split string    ${sha256sum}   ${SPACE}
    Log to console    sha256sum of ${target_file_path} is ${sha256sum[0]}
    ${file_exists}    Run Keyword and return status    File should exist    ${remote_file_path}.sha256
    ${expected_sha256sum}=    Run Keyword If    ${file_exists}    Run    command=cat ${remote_file_path}.sha256
    ${expected_sha256sum}=    Run Keyword If    ${file_exists}
    ...    split string    ${expected_sha256sum}    ${SPACE}
    Run Keyword If    ${file_exists}
    ...    Log to console     sha256sum of ${remote_file_path} is ${expected_sha256sum[0]}
    ...    ELSE    Log to console     sha256 file doesn't exit, skip md5sum check!
    ${result}    Run Keyword If    ${file_exists}
    ...    Run Keyword And Return Status    Should Be Equal    ${sha256sum[0]}    ${expected_sha256sum[0]}
    ...    ELSE    Set Variable    ${True}
    RETURN    ${result}

Remove cus log on vm
    [Documentation]   remove cus log under /home/cus/logs/uex
    ${rc}=    Run and return rc    if [ -d /home/cus/logs/uex ]; then rm -rf /home/cus/logs/uex/*; fi
    Should be True    ${rc}==0     can't remove cus log under /home/cus/logs/uex/, please del it manually.

Set Color For Logs
    ${red}            Evaluate    ${RED}
    ${green}          Evaluate    ${GREEN}
    ${byellow}        Evaluate    ${BYELLOW}
    ${rm_color}       Evaluate    ${COLOR_OFF}
    Set Suite Variable    ${red}
    Set Suite Variable    ${green}
    Set Suite Variable    ${byellow}
    Set Suite Variable    ${rm_color}

Report KPI
    [Documentation]    Report KPI allows calculate OAM KPI based on IMS snapshot. For more information, please visit:
    ...                https://wrgitlab.ext.net.nokia.com/TAF/taf.ul.oam_kpi_calculations
    ...                https://taf-ul-oam-kpi-calculations.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html
    [Arguments]    ${kpi_name}=kpi4_T0    ${target_dir}=${OUTPUT_DIR}    ${kpi_list}=kpi4
    TRY
        coam.Collect IM Snapshot        target_file_name=${target_dir}/${tl.tl_cloud_topology}_${kpi_name}.ims
        ...                             connection=coam_admin
    EXCEPT    AS    ${error}
        Log    Failed to Collect IM Snapshot, due to ${error}!, second attempt...     WARN
        WA for coam connect
        coam.Collect IM Snapshot    target_file_name=${target_dir}/${tl.tl_cloud_topology}_${kpi_name}.ims
        ...                         connection=coam_admin
    END
    ${ims_sesion_file_path}         get_last_disconnected_ims_log    log_dir=${OUTPUT_DIR}/../../
    ${all_ims}    Create List       ${ims_sesion_file_path}
    ...                             ${target_dir}/${tl.tl_cloud_topology}_${kpi_name}.ims
    ${ims_file_path}                Set Variable If    '${ims_sesion_file_path}'=='None'
    ...                             ${target_dir}/${tl.tl_cloud_topology}_${kpi_name}.ims    ${all_ims}
    ${results}    Calculate Kpis    kpi_names=${kpi_list}    ims_file_path=${all_ims}
    kpi.Save Results To File        file_path=${target_dir}/${kpi_name}.json
    kpi.Clear Results

Log SFP info
    [Documentation]      Gets info about SFP.
    [Arguments]    ${ip_addr}
    ${rm_color}      Evaluate    ${COLOR_OFF}
    ${date}    Get Current Date    result_format=datetime
    coam.Setup admin    bts_host=${ip_addr}    bts_port=443    use_ssl=true    timeout=240
    ${sfp_message}=    Set Variable     \n\t  - SFP types:
    ${sfp_list_admin}=    coam.get parameters for all    SFP
    ${vendorPartNumber_list}    Create List
    FOR    ${sfp}    IN    @{sfp_list_admin}
        Append To List    ${vendorPartNumber_list}    ${sfp.vendorPartNumber}
    END
    ${vendorPartNumber_list}    Remove Duplicates    ${vendorPartNumber_list}
    ${SFPtype_list}    Create List
    Run Keyword IF    '${ip_addr}'=='192.168.255.129'    Log To Console      \t- SFP types on gNB:
    ...               ELSE
    ...               Log To Console      \t- SFP types on eNB:
    FOR    ${sfp_type}    IN    @{vendorPartNumber_list}
        ${mappedSFP}    SFP mapping    ${sfp_type}
        SFP lifecycle    sfp_type=${sfp_type}
        Set Color For Console Log Text   sfp_type=${sfp_type}
        Run Keyword IF    '${sfp_lifecycle}'!='${NONE}'
        ...               Log To Console    \t\t ${sfp_type}, WARN! SFP Lifecycle: ${COLOR}${sfp_lifecycle}${rm_color}
        ...               ELSE
        ...               Log To Console    \t\t ${sfp_type},
        Run Keyword If    '${sfp_type}'=='FOSA' or '${sfp_type}'=='FOSB' or '${sfp_type}'=='FOSG'    FAIL
        ${catenate}    Catenate    '${sfp_type}'=='FOSO' or '${sfp_type}'=='FOSP' or '${sfp_type}'=='FOUC' or '${sfp_type}'=='FOUA'
        ...                     or '${sfp_type}'=='FOUB'
        Run Keyword If     ${catenate}             FAIL    SFP ${sfp_type} is out-dated, pls replace it to new SFP module!
        Run Keyword If    '${sfp_type}'=='FOSH' and '${date.year}'=='${2023}' and '${date.month}'>'${2}'                              FAIL
        ${catenate2}   Catenate    '${sfp_type}'=='FOTA' and '${date.year}'=='${2023}' and '${date.month}'>'${11}' or
        ...                        '${sfp_type}'=='FOTB' and '${date.year}'=='${2023}' and '${date.month}'>'${11}'
        Run Keyword If     ${catenate2}            FAIL    SFP ${sfp_type} is out-dated, pls replace it to new SFP module!
    END
    [Teardown]    coam.teardown

SFP mapping
    [Documentation]      Assigning SFP vendor number to SFP type.
    [Arguments]    ${sfp_type}
    ${sfp_type}    Set Variable If
    ...    '${sfp_type}'=='FTLF8526P3BNL-NN'   FOSH
    ...    '${sfp_type}'=='RTXM228-610'        FOSH
    ...    '${sfp_type}'=='JSH-62S1DA1-001'    FOSH
    ...    '${sfp_type}'=='RTXM228-610-C20'    FOSH
    ...    '${sfp_type}'=='MTRS-6A11-01'       FOSH
    ...    '${sfp_type}'=='MTRS-1E21-01'       FOSO
    ...    '${sfp_type}'=='MTRS-1E21-04'       FOSO
    ...    '${sfp_type}'=='FTLX1370W3BTL-NN'   FOSO
    ...    '${sfp_type}'=='RTXM228-702-C39'    FOSO
    ...    '${sfp_type}'=='RTXM228-702'        FOSO
    ...    '${sfp_type}'=='MTRS-1E81-01'       FOUB
    ...    '${sfp_type}'=='MTRS-1A11-01'       FOUC
    ...    '${sfp_type}'=='RTXM228-554-C20'    FOUC
    ...    '${sfp_type}'=='LTF8502-BH-NK2'     FOUC
    ...    '${sfp_type}'=='AFBR-709JAMZ-NK1'   FOUC
    ...    '${sfp_type}'=='LTF8502-BH1'        FOUC
    ...    '${sfp_type}'=='RTXM228-553-C4'     FOTA
    ...    '${sfp_type}'=='RTXM228-553-C41'    FOTA
    ...    '${sfp_type}'=='RTXM228-553-C40'    FOTA
    ...    '${sfp_type}'=='FTLX8573D3BTL-NS'   FOTA
    ...    '${sfp_type}'=='RTXM228-402-C40'    FOTB
    ...    '${sfp_type}'=='RTXM320-571-C39'    FOCX    ${sfp_type}
    ${sfp_type}    Set Variable If
    ...    '${sfp_type}'=='MTRS-1A11-03'       AOME
    ...    '${sfp_type}'=='RTXM228-554-C20A'   AOME
    ...    '${sfp_type}'=='LTF8502-BH-NK1'     AOME
    ...    '${sfp_type}'=='FTLF8536W4BTV-NS'   AOMC
    ...    '${sfp_type}'=='FTLF8536W4BTV-NN'   AOMC
    ...    '${sfp_type}'=='RTXM330-541-C39'    AOMC
    ...    '${sfp_type}'=='RTXM330-541-C39A'   AOMC
    ...    '${sfp_type}'=='MTRS-1E21-05'       AOSI
    ...    '${sfp_type}'=='RTXM228-702-C39A'   AOSI
    ...    '${sfp_type}'=='LTF1303-AW2'        AOSI
    ...    '${sfp_type}'=='RTXM330-201-C39'    AOSD
    ...    '${sfp_type}'=='RTXM330-201-C39A'   AOSD
    ...    '${sfp_type}'=='RTXM330-201-C39B'   AOSD
    ...    '${sfp_type}'=='RTXM330-201-C39C'   AOSD
    ...    '${sfp_type}'=='FTLF1436W4BTV-NN'   AOSD
    ...    '${sfp_type}'=='MTRS-1E31-02'       AOSK
    ...    '${sfp_type}'=='MTRS-1E81-02'       AOSM
    ...    '${sfp_type}'=='RTXM228-434-C39A'   AOSM
    ...    '${sfp_type}'=='MTRS-1E31-01'       FOSP    ${sfp_type}
    Set Suite Variable    ${sfp_type}
    RETURN    ${sfp_type}

SFP lifecycle
    [Documentation]      Assigning SFP type to lifecycle.
    [Arguments]    ${sfp_type}
    ${sfp_lifecycle}    Set Variable If
    ...    '${sfp_type}'=='FOSA'   End Of Life
    ...    '${sfp_type}'=='FOSB'   End Of Life
    ...    '${sfp_type}'=='FOSG'   End Of Life
    ...    '${sfp_type}'=='FOSH'   EOO 3/23
    ...    '${sfp_type}'=='FOSO'   Ramped down 7/21 replace: AOSI
    ...    '${sfp_type}'=='FOSP'   Ramped down 7/21 replace: AOSK
    ...    '${sfp_type}'=='FOUC'   Ramped down 7/21 replace: AOME
    ...    '${sfp_type}'=='FOUA'   Ramped down 7/21 replace: AOSL
    ...    '${sfp_type}'=='FOUB'   Ramped down 7/21 replace: AOSM
    ...    '${sfp_type}'=='FOTA'   EOD 12/23
    ...    '${sfp_type}'=='FOTB'   EOD 12/23     ${NONE}
    Set Suite Variable    ${sfp_lifecycle}
    RETURN    ${sfp_lifecycle}

Set Color For Console Log Text
    [Documentation]      Assigning color red/yellow for console log text.
    [Arguments]    ${sfp_type}
    ${font_color}    Set Variable If
    ...    '${sfp_type}'=='FOSA'   "\\033[1;31m"
    ...    '${sfp_type}'=='FOSB'   "\\033[1;31m"
    ...    '${sfp_type}'=='FOSG'   "\\033[1;31m"
    ...    '${sfp_type}'=='FOSH'   "\\033[33m"
    ...    '${sfp_type}'=='FOSO'   "\\033[1;31m"
    ...    '${sfp_type}'=='FOSP'   "\\033[1;31m"
    ...    '${sfp_type}'=='FOUC'   "\\033[1;31m"
    ...    '${sfp_type}'=='FOUA'   "\\033[1;31m"
    ...    '${sfp_type}'=='FOUB'   "\\033[1;31m"
    ...    '${sfp_type}'=='FOTA'   "\\033[33m"
    ...    '${sfp_type}'=='FOTB'   "\\033[33m"     "\\033[30m"
    ${COLOR}=  Evaluate  ${font_color}
    Set Suite Variable    ${COLOR}
    RETURN    ${COLOR}

Check PA reachable
    [Documentation]   Check PA reachable
    ${pasetup}    Run Keyword If    '${site}'=='WRO'
    ...    Run Keyword And Return Status    Check WRO PA status
    Should be true    ${pasetup}    PA is not reachable!

Check WRO PA status
    [Documentation]   Check WRO PA reachable
    @{PaList}=    Create List
    ${keys}    Get Dictionary Keys    ${tl.attenuation}
    FOR  ${key}  IN  @{keys}
         Run Keyword If    'ip' in '${key}' and 'pdu' not in '${key}'     Append To List    ${PaList}    ${tl.attenuation['${key}']}
    END
    @{PaIp}       Remove Duplicates    ${PaList}
    ${pa_type}    Get Variable Value    ${tl.attenuation['attenuator_type']}    default
    ${pdu_port}    Get Variable Value    ${tl.attenuation['pdu_attenuator_port']}     ${tl.attenuation['pdu_attenuator_rf1_port']}
    ${pdu_model}    Get Variable Value    ${tl.attenuation['pdu_model']}    None
    Set Test Variable     ${pdu_model}
    FOR  ${ip}  IN  @{PaIp}
        Check Attenuator Status    ip=${ip}    pdu_port=${pdu_port}    model=${pdu_model}
    END
    ${Pas}    Get Variable Value    ${tl.attenuators}
    ${PA_exists}=    Run Keyword And Return Status    Should Not Contain    ${Pas}    ${None}
    Run Keyword If     ${PA_exists}    Check PA Setup Status    ${Pas}
    ${pa_type}         Get Variable Value    ${tl.attenuation['attenuator_type']}    default
    ${attens_check}    Run Keyword And Return Status    Variable Should Exist    ${tl.attenuators}
    Run Keyword If     ${attens_check}         Check Attenuator Status In Env Health Checker
    ...  ELSE          Log To Console     \n PA is not set in WRO TL!

Check Attenuator Status In Env Health Checker
    ${is_rf3}=    Run Keyword And Return Status    Variable Should Exist    ${tl.attenuation['attenuation_index']['rf3']}
    Run Keyword If    '${is_rf3}'=='False' and '${pdu_model}'!='None'
    ...   Check Attenuator Status    ${tl.attenuators[0].ip_addr}    ${tl.attenuation['pdu_attenuator_ip']}
    ...   ${tl.attenuation['pdu_attenuator_port']}    ${pdu_model}
    ...   ELSE IF   ${is_rf3} and '${pdu_model}'!='None'    Run Keywords
    ...   Set Test Variable    ${atten_rf1_index}     ${tl.attenuation['attenuation_index']['rf1']}
    ...   AND    Set Test Variable    ${atten_rf2_index}     ${tl.attenuation['attenuation_index']['rf2']}
    ...   AND    Set Test Variable    ${atten_rf3_index}     ${tl.attenuation['attenuation_index']['rf3']}
    ...   AND    Check Attenuator Status For 3RF

Check PA Setup Status
    [Documentation]   Check PA Setup Status
    [Arguments]  ${PAs}
    FOR  ${PA}  IN  @{PAs}
        ${Status}      Run Keyword And Return Status    att.setup_attenuator    attenuator=${PA}
        ${PaStatus}    Evaluate    ${Status} & ${True}
    END
    Should be true    ${PaStatus}

Create List With Radio Technology Parameters
    [Arguments]    ${radio_technologies}    ${technology}    ${technology_1}
    FOR    ${item}    IN    ${technology_1}
        FOR    ${parameters}    IN    ${item[0]}
            ${cellDepType_exist}    Run Keyword And Return Status    Variable Should Exist    ${parameters['cellDepType']}
            ${technology_exist}     Run Keyword And Return Status    Variable Should Exist    ${parameters['technology']}
            ${technologies}    Set Variable If    ${cellDepType_exist} and ${technology_exist}
            ...                                   ${parameters['cellDepType']}, ${parameters['technology']}
            ...                                   not ${cellDepType_exist} and ${technology_exist}    ${parameters['technology']}
            ...                                   not ${technology_exist} and ${cellDepType_exist}    ${parameters['cellDepType']}
            ...                                   None
        END
    END
    Run Keyword If    '${technologies}'!='None'    Append To List    ${radio_technologies}    ${technology}: ${technologies}

L3Call Stop And Fix Check
    ${is_L3call_exception_raised}    Run Keyword And Return Status    Variable Should Exist    ${L3call_exception}
    IF    ${is_L3call_exception_raised}
        ${is_data_after_test_file_exist}    Run Keyword And Return Status
        ...    File Should Exist    ${OUTPUT_DIR}/data_after_test.txt
        IF    not ${is_data_after_test_file_exist}
            Create File        ${OUTPUT_DIR}/data_after_test.txt    ${EMPTY}
        END
        ${skip_internal_retest_regex_patterns_str}=    Evaluate    "|".join(${skip_internal_retest_regex_patterns})
        ${match}    Get Regexp Matches	    ${L3call_exception}    ${skip_internal_retest_regex_patterns_str}
        ${len}    Evaluate    len(${match})
        IF    ${len} > 0
            ${skip_internal_retest_reason}     Set Variable   ${match[0]}
            Append To file
            ...    ${OUTPUT_DIR}/data_after_test.txt    skip_internal_retest=true\nskip_internal_retest_reason=${match[0]}
        ELSE
            Append To file
            ...    ${OUTPUT_DIR}/data_after_test.txt    skip_internal_retest=false
        END
    END