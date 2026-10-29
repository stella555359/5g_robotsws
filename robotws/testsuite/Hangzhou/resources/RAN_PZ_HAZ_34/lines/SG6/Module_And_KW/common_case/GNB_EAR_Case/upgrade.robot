*** Settings ***
Documentation
...   author: winnie he
...   contact: winnie.he@nokia-sbell.com
...   this is a robot case about 5GC000740.
Resource          ../../common_resource.robot
Force Tags        SRAN_Upgrade
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown    Common MutliBTS Suite Teardown For RRM
Test Setup        Common MultiBTS Test Setup For RRM
Test Teardown     Common MultiBTS Test Teardown For RRM
*** Variables ***
${Aria2c_Command}    aria2c --file-allocation=none --all-proxy="" --continue
...   --max-connection-per-server=16 --split=16
${BRANCH}    SBTS00
&{fault_7311}                faultId=${7311}    #No Xn link available just for this half rack
&{fault_4681}                faultId=${4681}    #Sanity Check Error
&{fault_4701}                faultId=${4701}
&{fault_61618}             faultId=${61618}
@{special_alarm}    &{fault_7311}    &{fault_4681}    &{fault_4701}    &{fault_61618}
${allowed_alarm_list}    &{fault_7311}
# ${GNB_NUMBER}    ${1}
*** Test Cases ***
Upgrade SRAN Local
    [Documentation]    Author: He Winnie
    ...    Upgrade the local site.
    # [Tags]    SCF_GLODEN    Upgrade
    [Tags]    SCF_GLODEN
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Start Multi Bts Log
    # Check Unexpect Alarm Within List    allowed_alarm_list=${special_alarm}
    # ...    common_allowed_alarm_list=${uuf_allowed_previous}
    ${exist_23_alarm}    Exists FID23 Alarm
    Pass Execution If
    ...    '${BTS0_ACTIVE_SW_VERSION}'=='${EXPECT_SW_VERSION}' and 'False'=='${exist_23_alarm}'
    ...    Local Site SW${BTS0_ACTIVE_SW_VERSION} Already Equal ${EXPECT_SW_VERSION},no need upgrade
    ${latest_build_name}    Get SW VER From json file
    Download And Upgrade To Target   package=${latest_build_name}
    ...    scf_file_path=gloden
    Update SW Build With Check FID23
    Sleep    5m    reason=wait for alarm show
    Check Unexpect Alarm For GNBs

Upgrade SRAN All GNB
    [Documentation]    Author: He Winnie
    ...    Upgrade the remote 5G site first, then upgrade local site
    ...    If local upgrade fail, should fail all other case
    [Tags]    SCF_GLODEN    Upgrade
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Get RFS Status By Topology
    Start Multi Bts Log
    ${latest_build_name}    Get SW VER From json file
    ${upgraded_flag}    Download And Upgrade To Remote GNBs   package=${latest_build_name}
    ...    scf_file_paths=gloden
    Pass Execution If    '${upgraded_flag}'=='${False}'
    ...    All remote Site sw already equal ${EXPECT_SW_VERSION},no need upgrade
    Check Unexpect Alarm For GNBs

Upgrade If Checked FID23
    [Documentation]    Author: He Winnie
    # [Tags]    SCF_10_5_UTESRAN001T2298_LTE4549    Upgrade
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Get RFS Status By Topology
    Start Multi Bts Log
    # Reload Configuration For One GNB   bts_index=${0}
    # Run Keyword And Ignore Error    Wait One GNB Status    bts_index=0    expect_status=OnAir
    # ...    wait_max_time=${CONFIGURAED_MAX_DURATION}
    # Sleep    300s    resson=Wait 5min to check the Alarms
    Update SW Build With Check FID23
    Wait One GNB Status    bts_index=0    expect_status=OnAir
    ...    wait_max_time=${CONFIGURAED_MAX_DURATION}
    Check Unexpect Alarm For GNBs
    [Teardown]    Common MultiBTS Test Teardown For RRM

Clear Configuration And Upgrade For Local
    [Documentation]    Author: He Winnie
    ...    use for clear configuration and upgrade for local site
    # [Tags]    Clear_scf    SCF_GLODEN
    [Tags]    SCF_GLODEN
    [Setup]    Common MultiBTS Test Setup For RRM
    Get RFS Status By Topology
    Start Multi Bts Log
    ${recommission_scf_file_path}    Get SCF File After Upgrade
    ${back_scf_pach}    COAM_Admin.BackupSCF    connection=COAM_0
    ${latest_build_name}    Get SW VER From json file
    BTS Operation    operation=downgrade    product_type=gnb    bts_index=0
    ...    indicated_sw_version=${latest_build_name}
    ...    oam_ip=192.168.255.129
    Verify One GNB Status    connection=COAM_0
    # Sleep    5m    reason=wait for alarm show
    # Run Keyword If    'RFS' in '${TL_Type}'    Check Unexpect Alarm For GNBs
    # ...    ELSE    Check Unexpect Alarm For One GNB    bts_index=${0}

Clear Configuration And Upgrade In Remote
    [Documentation]    Author: He Winnie
    ...    use for clear configuration and upgrade for local site
    [Tags]    SCF_GLODEN
    [Setup]    Run Keywords
    ...    Set Suite Variable    ${GNB_NUMBER}    1
    ...    AND
    ...    Common MultiBTS Test Setup For RRM
    ...    other_method=Return From Keyword
    Get RFS Status By Topology
    ${exist_23_alarm}    Exists FID23 Alarm
    Pass Execution If
    ...    '${BTS0_ACTIVE_SW_VERSION}'=='${EXPECT_SW_VERSION}' and 'False'=='${exist_23_alarm}'
    ...    Local Site SW${BTS0_ACTIVE_SW_VERSION} Already Equal  ${EXPECT_SW_VERSION},no need upgrade
    Clear Configuration For One GNB    bts_index=${0}
    ${latest_build_name}    Get SW VER From json file
    ${recommission_scf_file_path}    Get SCF File After Upgrade
    ${upgrade_state}    ${msg}    Run Keyword And Ignore Error
    ...    Download And Upgrade To Target
    ...    package=${latest_build_name}
    ...    scf_file_path=${recommission_scf_file_path}
    ${onair_state}    ${value}    Run Keyword And Ignore Error    Verify One GNB Status    connection=COAM_0
    Run Keyword If    '${onair_state}'=='FAIL'    Update SW Build When FID23    package_path=${PACKAGE_PATH}
    Verify One GNB Status    connection=COAM_0

Clear Configuration And Upgrade For All GNBs
    [Documentation]    Author: He Winnie
    ...    use for clear configuration and upgrade for remote site
    [Tags]    Clear_scf    SCF_GLODEN
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Connect All VM
    Start Multi Bts Log
    FOR    ${bts_index}    IN RANGE    ${GNB_NUMBER}
        Pass Execution If
        ...    '${BTS${bts_index}_ACTIVE_SW_VERSION}'=='${EXPECT_SW_VERSION}'
        ...    Local Site SW${BTS${bts_index}_ACTIVE_SW_VERSION} Already Equal ${EXPECT_SW_VERSION},no need upgrade
        BTS Operation    operation=downgrade    product_type=gnb    bts_index=${bts_index}
        ...    indicated_sw_version=${EXPECT_SW_VERSION}
    END
    [Teardown]    Run Keywords    Remote Teardown    AND    Common MultiBTS Test Teardown For RRM

Clear Configuration And Upgrade For Remote
    [Documentation]    Author: He Winnie
    ...    use for clear configuration and upgrade for remote site
    [Tags]    Clear_scf    SCF_GLODEN
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Get RFS Status By Topology
    Connect All VM
    Sync Reservation File
    Start Multi Bts Log
    Run Case In Remote Vms
    Sleep    5m    reason=wait for alarm show
    Check Unexpect Alarm For GNBs
    [Teardown]    Run Keywords    Remote Teardown    AND    Common MultiBTS Test Teardown For RRM

Rollback For Local
    [Documentation]    Author: He Winnie
    ...    rollback for local enb and wait for onair
    [Tags]    Rollback
    Start Multi Bts Log
    Rollback For One GNB    bts_index=${0}
    Wait One GNB Status     bts_index=${0}
Rollback For Remote GNBs
    [Documentation]    Author: He Winnie
    ...    rollback for all gnbs expect local enb and wait for onair
    [Tags]    Rollback
    Start Multi Bts Log
    Rollback For Remote GNBs
    Wait All GNB Status

# --------- upgrade by GUI ----------
# Upgrade SRAN Local By GUI
#     [Documentation]    Author: He Winnie
#     ...    use for skip agent, validate the scf, download package, upgrade, check alarm
#     # todo
#     Log
*** Keywords ***
Get RFS Status By Topology
    ${already_set_rfs}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${Topology_RFS}    ${TESTLINE_TYPE}
    ${RFS}    Run Keyword If    ${already_set_rfs}    Set Variable
    ...    ${Topology_RFS}[${TESTLINE_TYPE}]
    ...    ELSE
    ...    Set Variable    ${False}
    Set Suite Variable    ${RFS}    ${RFS}

Remote Teardown
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        Continue For Loop If    ${i}==${0}
        Run Keyword And Ignore Error    Download Remote VM Run Log    i=${i}
    END

Download Remote VM Run Log
    [Arguments]    ${i}=${1}    ${remote_path}=/home/ute/test_results
    csn.download_file    remote_path=${remote_path}/log.html    local_path=${TEST_LOG_DIRECTORY}${/}BTS${i}_LOG.html
    ...    connection=BTS${i}_VM

Get SCF File After Upgrade
    ${local_bts_index}    Get BTS Index By S1 Ip
    ${Expect_Release}    Get Release By Sw Version    sw=${EXPECT_SW_VERSION}
    ${recommission_scf_file_path}    Get Load Scf Path    BTS${local_bts_index}
    ...    ${Expect_Release}
    [Return]    ${recommission_scf_file_path}

Check Sw Version
    [Documentation]    Author: He Winnie
    [Arguments]    ${except_sw}
    ${active_sw_version}    Get Active Bts Sw Version
    ${is_equal}    Evaluate    '${except_sw}'=='${active_sw_version}'
    [Return]    ${is_equal}

Download And Upgrade To Target
    [Documentation]    Author: He Winnie
    [Arguments]    ${package}    ${download_server_type}=${None}   ${alias}=Ctrl_VM
    ...    ${scf_file_path}=${None}
    Log To Console    ${scf_file_path}
    ${package_path}    Download Package    package=${package}    download_server_type=${download_server_type}    alias=${alias}
    Set Test Variable    ${PACKAGE_PATH}    ${package_path}
    Upgrade For One GNB     bts_index=${0}    package_path=${package_path}
    Commission For One GNB And Wait Onair In Upgrade    bts_index=${0}    scf_file_paths=${scf_file_paths}
    Sleep    180s    reason=wait for all alarm able or disable
    [Return]    ${package_path}

Download And Upgrade From Console Mode
    [Documentation]    Author: He Winnie
    [Arguments]    ${package}    ${download_server_type}=${None}   ${alias}=Ctrl_VM
    ...    ${scf_file_path}=${None}
    ${package_path}    Download Package    package=${package}    download_server_type=${download_server_type}    alias=${alias}
    Set Test Variable    ${PACKAGE_PATH}    ${package_path}
    # BTS Operation    operation=downgrade    product_type=gnb    bts_index=0
    # ...    sw_path=${package_path}
    COAM_Admin.Upgrade From Console Mode
    ...    package_path=${package_path}
    ...    scf_path=${scf_file_path}
    Sleep    180s    reason=wait for all alarm able or disable
    [Return]    ${package_path}

Download And Upgrade To Remote GNBs
    [Documentation]    Author: He Winnie
    [Arguments]    ${package}    ${download_server_type}=${None}   ${alias}=Ctrl_VM
    ...    ${scf_file_paths}=${None}
    # ${package_path}    Download Package    package=${package}    download_server_type=${download_server_type}    alias=${alias}
    ${upgraded_flag}    Set Variable    ${False}
    ${need_upgrad_flag}    Set Variable    ${False}
    FOR    ${i}    IN RANGE    ${GNB_NUMBER}
        # Continue For Loop If    ${i}==${0}
        ${need_upgrad_flag}    Run Keyword If
        ...    '${BTS${i}_ACTIVE_SW_VERSION}'=='${EXPECT_SW_VERSION}'
        ...    Set Variable    ${False}
        ...    ELSE
        ...    Set Variable    ${True}
        Exit For Loop If    '${BTS${i}_ACTIVE_SW_VERSION}'!='${EXPECT_SW_VERSION}'
    END
    ${package_path}    Run Keyword If    ${need_upgrad_flag}
    ...    Download Package
    ...    package=${package}
    ...    download_server_type=${download_server_type}
    ...    alias=${alias}
    ${need_relogin}    Set Variable    ${RFS}
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        # Continue For Loop If    ${i}==${0}
        Run Keyword If    '${BTS${i}_ACTIVE_SW_VERSION}'=='${EXPECT_SW_VERSION}'
        ...    Log To Console
        ...    Site ${BTS${i}_INFO.IP} SW ${BTS${i}_ACTIVE_SW_VERSION} Already Equal ${EXPECT_SW_VERSION},no need upgrade
        Continue For Loop If   '${BTS${i}_ACTIVE_SW_VERSION}'=='${EXPECT_SW_VERSION}'
        Upgrade For One GNB    bts_index=${i}    package_path=${package_path}
        ...    need_relogin=${need_relogin}
        ${upgraded_flag}    Set Variable    ${True}
    END
    Run Keyword If    '${need_relogin}'=='${False}' and '${need_upgrad_flag}'=='${True}'
    ...    Relogin All BTS
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        # Continue For Loop If    ${i}==${0} or '${BTS${i}_ACTIVE_SW_VERSION}'=='${EXPECT_SW_VERSION}'
        Continue For Loop If    '${BTS${i}_ACTIVE_SW_VERSION}'=='${EXPECT_SW_VERSION}'
        Commission For One GNB And Wait Onair In Upgrade    bts_index=${i}    scf_file_paths=${scf_file_paths}
    END
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        Continue For Loop If    '${need_upgrad_flag}'=='${False}'
        Update SW Build When FID23    package_path=${package_path}    bts_index=${i}
        ${upgraded_flag}    Set Variable    ${True}
    END
    Run Keyword if    ${upgraded_flag}
    ...    Sleep    300s    reason=wait for all alarm able or disable
    [Return]    ${True}

Check Sw Version Equal Except
    [Arguments]    ${i}
    Run Keyword And Ignore Error    _Get One Gnb Active Sw Version    bts_index=${i}
    Should Be True    '${EXPECT_SW_VERSION}'=='${BTS${i}_ACTIVE_SW_VERSION}'

Commission For One GNB And Wait Onair In Upgrade
    [Arguments]    ${bts_index}    ${scf_file_paths}=${None}
    ${i}    Set Variable    ${bts_index}
    ${active_release}    Get Release By Sw Version    sw=${BTS${i}_ACTIVE_SW_VERSION}
    ${except_release}    Get Release By Sw Version    sw=${EXPECT_SW_VERSION}
    ${different_release}    Evaluate   '${except_release}'!='${active_release}'
    Wait Until Keyword Succeeds    5x    1min    Check Sw Version Equal Except    i=${i}
    ${no_gloden_scf}    Evaluate    '${scf_file_paths}'!='${None}' and '${scf_file_paths}'!='gloden'
    Run Keyword if    ${no_gloden_scf} and ${different_release}
    ...    Commission Full SCF For One GNB    bts_index=${i}    scf_file_path=${scf_file_paths}[i]
    Run Keyword if    '${scf_file_paths}'=='gloden' and ${different_release}
    ...    Commission Full SCF For One GNB    bts_index=${i}
    Wait One GNB Status     bts_index=${i}
    ${upgraded_flag}    Set Variable    ${True}
    [Return]    ${upgraded_flag}

Upgrade For One GNB
    [Arguments]    ${bts_index}    ${package_path}    ${need_relogin}=${TRUE}
    Log To Console    /*** Start to Upgrade BTS${bts_index}, package is ${package_path} ***/
    Relogin One BTS    i=${bts_index}
    ${status}    ${tcpdump_log_name}    Run Keyword And Ignore Error    Run Keyword If    '${bts_index}'=='${1}'
    ...    Start tcpdump by command For Local VM    bts_index=${bts_index}    append_str=host 10.108.233.237
    ${is_pass}    Run Keyword And Return Status
    ...    COAM_Admin.UpdateSW One GNB    SW_Buid_path=${package_path}
    ...    connection=COAM_${bts_index}
    Run Keyword And Ignore Error    Run Keyword If    '${bts_index}'=='${1}'
    ...    Stop tcpdump And download by command For Local VM    log_name=${tcpdump_log_name}    bts_index=${bts_index}
    Run Keyword If    '${is_pass}'=='${False}'    Fail    Reason=Upgrade fail for BTS ${bts_index}
    Return From Keyword If    '${need_relogin}'=='${FALSE}'
    Sleep    900s
    Relogin One BTS    i=${bts_index}

Relogin One BTS
    [Arguments]    ${i}=${0}
    COAM_Admin.Logout    connection=COAM_${i}
    Login Coam Admin    bts_index=${i}

Relogin All BTS
    Sleep    900s
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        Relogin One BTS    i=${i}
    END

Check Unexpect Alarm For One GNB
    [Arguments]    ${bts_index}
    ${combined_allow_fault_alarms}    Get All Allow Faults
    ...    tl_allowed_faults_file_path=${testline_configuration_path}${/}${TestLine_Name}${/}${tl_allow_faults_file_name}
    ...    ALLOWED_FAULT=${special_alarm}
    Check Unexpect Alarm Within List    allowed_alarm_list=${combined_allow_fault_alarms}
    ...    common_allowed_alarm_list=${uuf_allowed_current}    connection=COAM_${bts_index}

Check Unexpect Alarm For GNBs
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        Check Unexpect Alarm For One GNB    bts_index=${i}
    END

Clear Configuration For One GNB
    [Arguments]    ${bts_index}    ${timeout}=900
    Log To Console    /*** Start to reset configuration of BTS${bts_index} ***/
    coam.reset_configuration    connection=COAM_${bts_index}    timeout=${timeout}
    Sleep    5m    reason=wait for rru check

Clear Configuration For Remote GNBs
    [Arguments]    ${timeout}=900
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        Continue For Loop If    ${i}==${0}
        Clear Configuration For One GNB    bts_index=${i}    timeout=${timeout}
    END

Get All GNBs Recommission SCFs
    ${recommission_scf_file_paths}    Create List
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        ${recommission_scf_file_path}    Join Path    ${TEST_LOG_DIRECTORY}
        ...    back_${i}_commission.xml
        Append To List    ${recommission_scf_file_paths}    ${recommission_scf_file_path}
    END
    [Return]    ${recommission_scf_file_paths}

Reload Configuration For One GNB
    [Arguments]    ${bts_index}    ${scf_file_path}=${None}
    Log To Console    /*** Reload scf for BTS${bts_index} ***/
    Run Keyword If    '${scf_file_path}'!='${None}'
    ...    Commission Full SCF For One GNB     bts_index=${bts_index}
    ...    scf_file_path=${TEST_LOG_DIRECTORY}${/}back_${bts_index}_commission.xml
    ...    ELSE    Commission Full SCF For One GNB     bts_index=${bts_index}

Rollback For One GNB
    [Arguments]    ${bts_index}    ${timeout}=900
    Log To Console    /*** rollback for BTS${bts_index} ***/
    coam.rollback_software    connection=COAM_${bts_index}    timeout=${timeout}
    Sleep    300s

Rollback For Remote GNBs
    [Arguments]    ${timeout}=900
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        Continue For Loop If    ${i}==${0}
        coam.rollback_software    connection=COAM_${i}    timeout=${timeout}
    END
    Sleep    300s

Sync Reservation File
    ${vm_count}    Get Length    ${tl.test_pcs}
    FOR    ${i}    IN RANGE    ${vm_count}
        Continue For Loop If    ${i}==${0}
        csn.upload_file    local_path=${UTE_RESERVATION_CONTEXT_JSON}
        ...    remote_path=${UTE_RESERVATION_CONTEXT_JSON}    connection=BTS${i}_VM
        csn.upload_file    local_path=${UTE_RESERVATION_JSON}
        ...    remote_path=${UTE_RESERVATION_JSON}    connection=BTS${i}_VM
    END

Run Case In Remote Vms
    [Arguments]    ${timeout}=60 min
    Connect All VM
    FOR    ${i}    IN RANGE    ${vm_count}
        Run Case In One Remote Vm    connection=BTS${i}_VM
    END
    FOR    ${i}    IN RANGE    ${vm_count}
        Run Keyword If    ${i}==${0}
        ...    Wait Until Keyword Succeeds    ${timeout}    3 min
        ...    Check Case In One Remote Vm    connection=BTS${i}_VM
        ...    output_file_path=${TEST_LOG_DIRECTORY}/output.txt
        ...    ELSE
        ...    Wait Until Keyword Succeeds    ${timeout}    3 min
        ...    Check Case In One Remote Vm    connection=BTS${i}_VM
    END
    FOR    ${i}    IN RANGE    ${vm_count}
        Run Keyword If    '${BTS${i}_VM_Case_status}'=='${False}'
        ...    Fail    Reason=Upgrade fail for BTS ${i}
    END
    [Teardown]    Disconnect All VM

Run Case In One Remote Vm
    [Arguments]    ${test_name}=Clear Configuration And Upgrade In Remote   ${connection}=BTS1_VM
    ...    ${case_path}=${Upgrade_Case_Info['Case_Path']}
    Log to Console    Start to Run robot file ${test_name} On Remote Vm
    ${execute_command}    Run Keyword If    '${connection}'=='BTS0_VM'
    ...    Catenate    robot -L TRACE -b debug.log
    ...    -V ${testline_configuration_path}${/}${TESTLINE_NAME}${/}
    ...    -d ${TEST_LOG_DIRECTORY}
    ...    -t '${test_name}'
    ...    -l Upgrade.html
    ...    ${case_path}
    ...    > ${TEST_LOG_DIRECTORY}/output.txt  2>&1 &
    ...    ELSE
    ...    Catenate    nohup robot -L TRACE -b debug.log
    ...    -V ${testline_configuration_path}${/}${TESTLINE_NAME}${/}
    ...    -d test_results
    ...    -t '${test_name}'
    ...    ${case_path}
    ...    > test_results/output.txt  2>&1 &
    ${ret}    Run Keyword If    '${connection}'!='BTS0_VM'
    ...    csn.execute    command=rm -rf test_results/output.txt    connection=${connection}
    ...    ELSE
    ...    csn.execute    command=rm ${TEST_LOG_DIRECTORY}/output.txt    connection=${connection}
    ${ret}    Run Keyword If    '${connection}'!='BTS0_VM'
    ...    csn.execute    command=ps -ef|grep robot | awk '{print $2}' |xargs kill -9    connection=${connection}
    Sleep    2s
    ${ret}    Run Keyword If    '${connection}'!='BTS0_VM'
    ...    csn.execute    command=rm -rf test_results    connection=${connection}
    ${ret}    Run Keyword If    '${connection}'!='BTS0_VM'
    ...    csn.execute    command=mkdir test_results    connection=${connection}
    Log To Console    ${execute_command}
    ${ret}    Run Keyword If    '${connection}'!='BTS0_VM'
    ...    csn.send_command    command=${execute_command}    connection=${connection}
    ...    ELSE
    ...    OperatingSystem.Run    command=${execute_command}
    Log to Console    ${ret}

Check Case In One Remote Vm
    [Arguments]    ${connection}    ${output_file_path}=test_results/output.txt
    ${ret}    csn.execute    command=cat ${output_file_path}    connection=${connection}
    ${pass_matches}    Get Regexp Matches    ${ret}    1 passed
    ${fail_matches}    Get Regexp Matches    ${ret}    0 passed
    ${is_pass}    Run Keyword And Return Status
    ...    Should Not Be Empty    ${pass_matches}
    ${is_fail}    Run Keyword And Return Status
    ...    Should Not Be Empty    ${fail_matches}
    Should Be True    ${is_pass} or ${is_fail}
    Set Suite Variable    ${${connection}_Case_status}    ${is_pass}
    [Return]    ${is_pass}

Update SW Build When FID23
    [Arguments]    ${package_path}    ${bts_index}=${0}
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                This kw is used for update sw build again after FID 23 is appeared
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Update SW Build When FID23 |  |
    ...    | Update SW Build When FID23 | connection=coam_conn |  |
    ...
    @{alarms}    coam.get_active_alarms    connection=COAM_${bts_index}
    FOR    ${alarm}    IN    @{alarms}
        Run Keyword If    ${alarm['faultId']}==${23}
        ...    Run Keywords
        ...    Upgrade For One GNB
        ...    bts_index=${bts_index}    package_path=${package_path}
        ...    AND
        ...    Wait One GNB Status     bts_index=${bts_index}
        Exit For Loop If    ${alarm['faultId']}==${23}
    END

Exists FID23 Alarm
    [Arguments]    ${bts_index}=${0}
    ${exist_23_alarm}    Set Variable    ${True}
    @{alarms}    coam.get_active_alarms    connection=COAM_${bts_index}
    FOR    ${alarm}    IN    @{alarms}
        Return From Keyword If    ${alarm['faultId']}==${23}
    END
    ${exist_23_alarm}    Set Variable    ${False}
    [Return]    ${exist_23_alarm}

