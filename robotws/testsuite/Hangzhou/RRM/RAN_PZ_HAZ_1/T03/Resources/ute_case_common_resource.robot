*** Settings ***
Documentation    Author: winnie
...              Contact: winnie@nokia-sbell.com
Resource          common_resource.robot
Library           taf.pdu    WITH NAME    pdu
Library           taf.sbts.oam.coam.admin    WITH NAME    admin
*** Keywords ***
Compare Release And Choose Suitable Upgrade
    ${active_release}    Get Release    sw=${ACTIVE_SW_VERSION}
    ${expect_release}    Get Release    sw=${EXPECT_SW_VERSION}
    # Run Keyword If    '${active_release}'!='${expect_release}' and '${expect_release}'!='SBTS00'
    # ...    Run Keywords
    # ...    Set To Dictionary    ${Upgrade_Case_Info}    Case_Tag=Clear_scf    AND
    # ...    Set To Dictionary    ${Feature_File_INFO}    Upgrade=${Upgrade_Case_Info}

Recover All Site To Gloden Scf
    # only use in the suite teardown
    Login All Coam Admin
    ${TEST TAGS}    Create List    SCF_${TESTLINE_NAME}
    Set Suite Variable    ${TEST TAGS}
    Commission Golden SCF For All GNB
    [Teardown]    Run Keywords    Logout All Coam Admin    AND
    ...    Remove From List    ${TEST TAGS}    ${0}

TL Suite Teardown
    Run Keyword And Ignore Error    Disconnect FCT
    ${status}    ${ret}    Run Keyword And Ignore Error    Recover All Site To Gloden Scf
    Run Keyword If    '${status}'=='FAIL'    Log To Console    Recover All Site To Gloden Scf failed
    Run Keyword If    '${status}'=='FAIL'    Collect Coam Snapshot For All GNB
    Run Keyword And Ignore Error    Upgrade ute-ca
    # Run Keyword And Ignore Error    Run keyword If    ${MoveLog_to_Logserver}
    # ...    Move All Test Result To Log Server

Run Feature Case
    [Arguments]    ${feature_name}=${TEST NAME}    ${test_name}=${TEST NAME}
    Log to Console    Start to Run robot file ${test_name}
    ${Cases_INFO}    Get Case File Info    case_name=${feature_name}
    Connect To VM
    Run One Case    cases_info=${Cases_INFO}    feature_name=${feature_name}
    ...    test_name=${test_name}
    [Teardown]    Disconnect VM

Run One Case
    [Arguments]    ${cases_info}    ${feature_name}    ${test_name}=${TEST NAME}
    ${case_path}    Set Variable    ${cases_info}[Case_Path]
    ${tag_status}    ${value}    Run Keyword And Ignore Error    Dictionary Should Contain Key
    ...    ${cases_info}    Case_Tag
    ${execute_command}    Run Keyword If    '${tag_status}'=='PASS'
    ...    Catenate     robot -L TRACE -b debug.log
    ...    -V ${testline_configuration_path}${/}${TESTLINE_NAME}${/}
    ...    -d ${TEST_LOG_DIRECTORY}
    ...    -l ${feature_name}.html
    ...    -i ${cases_info}[Case_Tag]
    ...    ${case_path}
    ...    ELSE IF    '${test_name}'=='${None}'
    ...    Catenate    robot -L TRACE -b debug.log
    ...    -V ${testline_configuration_path}${/}${TESTLINE_NAME}${/}
    ...    -d ${TEST_LOG_DIRECTORY}
    ...    -l ${feature_name}.html
    ...    ${case_path}
    ...    ELSE
    ...    Catenate     robot -L TRACE -b debug.log
    ...    -V ${testline_configuration_path}${/}${TESTLINE_NAME}${/}
    ...    -d ${TEST_LOG_DIRECTORY}
    ...    -l ${feature_name}.html
    ...    -t "${test_name}"
    ...    ${case_path}
    ${ret}    OperatingSystem.Run    command=/home/ute/test_repo/bin/python -m ${execute_command}
    ${matches}    Get Regexp Matches    ${ret}    \\d+ failed
    Should Not Be Empty    ${matches}
    ${failed_num}    Split String    ${matches}[0]    ${SPACE}
    Should Be Equal    ${failed_num}[0]    0

Get Case File Info
    [Arguments]    ${case_name}=${TEST NAME}
    ${Cases_INFO}    Set Variable    ${Feature_File_INFO}[${case_name}]
    [Return]    ${Cases_INFO}

Send All Report Portal Result
    Connect To VM
    ${feature_names}    Get Dictionary Keys    ${Feature_File_INFO}
    FOR    ${feature_name}    IN    @{feature_names}
        Log To Console    Start send report portal of ${feature_name}
        ${ret}    Send One Report Portal Result    robotfile_path=${Feature_File_INFO}[${feature_name}][Case_Path]
        ...    feature_log_path=${SUITE_LOG_DIRECTORY}    feature_name=${feature_name}
    END

Send One Report Portal Result
    [Arguments]    ${robotfile_path}    ${feature_log_path}    ${feature_name}
    ${ret}    csn.execute    command=cd ${feature_log_path};ls    connection=VM
    ${feature_dirs}    Split String    ${ret}
    ${feature_dir}    Get Matches    ${feature_dirs}    regexp=${feature_name}_\\d+
    ${exist_feature_dir}    Run Keyword And Return Status    Should Not Be Empty     ${feature_dir}
    Return From Keyword If    ${exist_feature_dir}==${False}    ${False}
    Log to Console    Output xml path is ${feature_dir}[0]${/}output.xml
    ${output_xml_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist
    ...    ${feature_log_path}${/}${feature_dir}[0]${/}output.xml
    Return From Keyword If    ${output_xml_exist}==${False}    ${False}
    ${sw}    Convert Trunk Sw Version To SBTS00    ${ACTIVE_SW_VERSION}
    ${command}    Catenate    ute_reporting_portal send -ie
    ...    -ro ${feature_log_path}${/}${feature_dir}[0]${/}output.xml
    ...    -tl ${TESTLINE_NAME}
    ...    --info "${TL_Type}"
    ...    -v --file_path "${robotfile_path}"
    ...    --sw_version "${sw}"
    ...    -l "${TL_Type}"
    ...    -ca RAN_PZ_HAZ_1
    ${ret}    OperatingSystem.Run     command=${command}    connection=VM
    Should Contain    ${ret}    Report was successfully sent to Reporting Portal
    ${ret_hash}    Get Regexp Matches    ${ret}
    ...    pattern=https://rep-portal.wroclaw.nsn-rdnet.net/reports/test-runs/\\?file_hash=[0-9a-zA-Z]+
    Log To Console    return url is ${ret_hash}[0]

Restart PA By APC
    pdu.setup_pdu    model=${tl.pdus[${APC_Index}].vendor}    host=${tl.pdus[${APC_Index}].addr}
    ...    alias=apc
    pdu.power_off    port=${tl.pdus[${APC_Index}].pdu_ports[1].port_no}    pdu_device=apc
    pdu.power_on     port=${tl.pdus[${APC_Index}].pdu_ports[1].port_no}    pdu_device=apc
    sleep    1min    reason=wait for pa restart

Clean Btslog For Remote Vm
    Connect All VM
    FOR    ${i}    IN RANGE    ${vm_count}
        Continue For Loop If    ${i}==${0}
        ${ret}    csn.execute    command=rm -rf /home/ute/remote_bts*
        ...    connection=BTS${i}_VM
    END
    [Teardown]    Run Keyword And Ignore Error    Disconnect All VM

Upgrade ute-ca
    Connect All VM
    # ${ret}    csn.execute    command=dpkg -s ute-ca | grep Version
    # ...    connection=BTS0_VM
    # ${version}    Get Regexp Matches    ${ret}    Version:\s*([\d\.]+)
    # Log To Console    ute-ca version: ${version}[0]
    FOR    ${i}    IN RANGE    ${vm_count}
        Continue For Loop If    ${i}==${0}
        ${ret}    csn.execute    command=export PYENV_VIRTUALENV_DISABLE_PROMPT=1
        ...    connection=BTS${i}_VM
        ${ret}    csn.execute    command=sudo apt update; echo yes | sudo apt install ute-ca; echo yes
        ...    connection=BTS${i}_VM
        ${ret}    csn.execute    command=sudo systemctl start ute-ca.service
        ...    connection=BTS${i}_VM
        Log To Console     start ute ca
        ${ret}    csn.send_command    command=systemctl status ute-ca
        ...    connection=BTS${i}_VM
    END
    [Teardown]    Run Keyword And Ignore Error    Disconnect All VM
    [Timeout]    30 min

ReInstall Vm
    [Arguments]    ${by_index}=${True}
    csn.connect_to    hostname=${Init_Enviroment.IP}
    ...    username=${Init_Enviroment.USERNAME}
    ...    password=${Init_Enviroment.PASSWORD}
    ...    alias=KVM
    Connect All VM
    FOR    ${i}    IN RANGE    ${vm_count}
        Continue For Loop If    ${i}==${0}
        ${install_script}    Run Keyword If    ${by_index}
        ...    Set Variable    ${Init_Enviroment.Reinstall_Script_Path}/10-5-UTESRAN00${i+1}__autoinstall.sh
        ...    ELSE    Set Variable    ${Init_Enviroment.Reinstall_Script_Path}/10-5-UTESRAN001T${BTS${i}_INFO.MRBTSID}__autoinstall.sh
        ${ret}    Run Keyword And Ignore Error    csn.execute
        ...    command=. ${install_script} --kvm-image ${UTE_Image_Version}
        ...    connection=KVM
        Log To Console    ${ret}
    END
    Run Keyword And Ignore Error    Disconnect All VM
    Wait Until Keyword Succeeds    2x    10min     Connect All VM
    FOR    ${i}    IN RANGE    ${vm_count}
        Continue For Loop If    ${i}==${0}
        ${ret}    csn.execute    command=pip install --upgrade pip
        ...    connection=BTS${i}_VM
        ${ret}    csn.execute    command=pip install -r ${Init_Enviroment.VM_Required_File}
        ...    connection=BTS${i}_VM
        Log To Console    ${ret}
    END
    Log To Console     start to config ute ca
    Run Keyword And Ignore Error    Disconnect All VM
    Upgrade ute-ca
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    csn.disconnect     connection=KVM
    ...    AND
    ...    Run Keyword And Ignore Error    Disconnect All VM

Get QC ID From Tags
    ${len}    Set Variable    ${0}
    Log to console     ${TEST TAGS}
    FOR    ${tag}    IN    @{TEST TAGS}
        ${matches}    Get Regexp Matches    ${tag}    QC_\\d+
        ${len}    Get Length    ${matches}
        Continue For Loop If    '${len}'=='${0}'
        ${id}    Get Regexp Matches    ${matches}[0]    \\d+
        ${len}    Get Length    ${id}
        Exit For Loop If    '${len}'!='${0}'
    END
    ${qc_id}    Set Variable If    '${len}'>'${0}'    ${id}[0]
    ...    ${EMPTY}
    [Return]    ${qc_id}

TL Test Teardown
    [Arguments]    ${testcase_name}=${TEST NAME}
    ...    ${append_qc_send}=${False}
    Run Keyword And Ignore Error    gnb_tool.stop_and_fix
    ${stats}    ${execution_id}   Run Keyword And Ignore Error    Get UTE Execution Id
    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
    ${UTE_EXECUTION_INDEX}    Evaluate   ${UTE_EXECUTION_INDEX}+1
    Set Suite Variable    ${UTE_EXECUTION_INDEX}    ${UTE_EXECUTION_INDEX}
    Run Keyword And Ignore Error    _Get All Gnb Active Sw Version
    Set Suite Variable    ${ACTIVE_SW_VERSION}
    ...    ${BTS0_ACTIVE_SW_VERSION}
    Run Keyword If    '${stats}'=='PASS' and ${append_qc_send}==${False}    Run Keywords
    ...    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}    AND
    ...    Return From Keyword
    Run Keyword If Test Failed    Return From Keyword
    ${fix_sw}    Fix SBTS Trunk Sw Version    ${ACTIVE_SW_VERSION}
    ${qc_id_exist}    Run Keyword And Return Status    List Should Contain Value    ${TEST TAGS}    QCD_MN_RAN
    ${qc_path}    Run Keyword If    ${qc_id_exist}
    ...    Get QC ID From Tags
    ...    ELSE
    ...    Set Variable    ${CURDIR}${/}..${/}UTE_Case${/}${TESTLINE_NAME}.qc
    Run Keyword And Ignore Error    Send ReP With Scf Id    qc_id=${qc_path}
    ...    sw=${fix_sw}    bts_id=${TESTLINE_NAME}
    ...    case_name=${testcase_name}
    ...    testline=${TESTLINE_NAME}

Start Scout Cli
    OperatingSystem.Run     source /home/ute/.pyenv/versions/3.10.12/envs/agent_scout_env/bin/activate
    ${cmd}    catenate
    ...    pip install -U --trusted-host
    ...    artifactory-espoo1.int.net.nokia.com -i
    ...    https://artifactory-espoo1.int.net.nokia.com/artifactory/api/pypi/pypi-scout-local/simple
    ...    scout-cli
    OperatingSystem.Run    ${cmd}
    ${cmd}    catenate    scout-cli testline start --testline-ip 192.168.255.129 --config
    ...    /home/ute/testline_init_results/agent_scout/results/config_files/scout.conf
    OperatingSystem.Run    ${cmd}
