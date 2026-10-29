*** Settings ***
Documentation
...   author: keli
...   contact: keli.weng@nokia-sbell.com
...   Description: this is one reference case template of AP test.
Resource          ../Resources/common_resource.robot
# Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
# Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/BTS_Operation.robot
# Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/Counter_Operation.robot
# Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/Log_Collection.robot
# Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/AT_Operation.robot
# Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/Airphone_Operation.robot
# Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/KPI_Operation.robot
# Library            ../../../../resources/RAN_PZ_HAZ_1/Module/Traffic_UEBox_Operation.py
# Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/Log_Analysis.robot
Resource           ../../../../resources/RAN_PZ_HAZ_1/CERTA_Module/Traffic_Module_For_ET.robot
# Resource           ../../Resources/RRM_Custom_Config.robot
# Resource          ../Resources/top50_resource.robot
# Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Setup        Run keywords    Common MultiBTS Suite Setup For RRM
...                AND    Update BSR Package
Suite Teardown      Common MutliBTS Suite Teardown For RRM
# Suite Setup       Common MultiBTS Suite Setup For RRM
# # Suite Setup       Common Suite Setup For RRM
# Test Setup        Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
# # Test Setup          Common Test Setup For RRM
# Test Teardown     Common MultiBTS Test Teardown For RRM
# # Test Teardown    Common Test Teardown For RRM
# Suite Teardown    Common MutliBTS Suite Teardown For RRM
# Suite Teardown    Common Suite Teardown For RRM

Force Tags        CRT/CIT/CDRT     #Tag Item
# ...   PY27
...      RAN_5G                    #Product [RAN_5G]
# ...      CLOUD_5G_I_MP_AP_LO   #TLtype, it is for auto trigger by ute cloud
...      SBTS00/SBTS21B           # it is for auto trigger by ute cloud with the release
# ...      STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]


Test Timeout    480 minutes

*** Variables ***
#reduce global parameter as possilbe and automatically got from gNB or __init__
${Aria2c_Command}    aria2c --file-allocation=none --all-proxy="" --continue
...   --max-connection-per-server=16 --split=16
${BRANCH}    SBTS00
&{fault_7311}                faultId=${7311}    #No Xn link available just for this half rack
&{fault_4681}                faultId=${4681}    #Sanity Check Error
&{fault_4701}                faultId=${4701}
&{fault_61618}             faultId=${61618}
&{fault_7529}            faultId=${7529}
&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_61616}           faultId=${61616}
&{fault_4459}            faultId=${4459}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_61616}
...    &{fault_4459}    &{fault_8000}    &{fault_7300}
@{special_alarm}    &{fault_7311}    &{fault_4681}    &{fault_4701}    &{fault_61618}
...    &{fault_61616}    &{fault_4459}    &{fault_8000}    &{fault_7300}    &{fault_61510}    &{fault_7529}
${allowed_alarm_list}    &{fault_7311}    &{fault_4459}    &{fault_8000}    &{fault_7300}
...    &{fault_61510}    &{fault_7529}
# ${APC_Index}    -1
${PA_MinValue}           ${0}
${PA_MaxValue}           ${93}
${DEBUG_MODE}            ${TRUE}
# ${REMOTE_MODE}           ${TRUE}
${usr_email}             tacase_auto@nokia-sbell.com
${traffic_file}          traffic_model.json
${apconfig_tag}          SA_TDD_2c_1gNBSim_255UE
${customer_tag}          None
${env_tag}               sa
${lua_path}              ${CURDIR}/APCFG/wts_${apconfig_tag}.lua
${loop_timeout}          1 hour
&{ap_info}               CLOUD_5G_I_MP_AP_LO=SA_TDD_2c_1gNBSim_255UE
...                      CLOUD_5G_I_LOO_AP_LOOO=SANSA_TMO_255UE
...                      CLOUD_5G_O_E_AP_LOOO=SA_TDD_1gNBSim_RJO
&{customer_info}         CLOUD_5G_I_MP_AP_LO=None
...                      CLOUD_5G_I_LOO_AP_LOOO=TMO
...                      CLOUD_5G_O_E_AP_LOOO=None
&{env_info}              CLOUD_5G_I_MP_AP_LO=sa
...                      CLOUD_5G_I_LOO_AP_LOOO=sansa
...                      CLOUD_5G_O_E_AP_LOOO=sa
&{Upgrade_Case_Info}      Case_Path=${CURDIR}${/}..${/}AP_Case${/}upgrade.robot
...                       Case_Tag=Upgrade
&{Feature_File_INFO}
...    Upgrade=&{Upgrade_Case_Info}
${Ignore_Cell_Id_For_Sib}    5    6    9    12
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
*** Test Cases ***
#test case name should be same with qc case name without space and special characters


Airphone Kpi Test For Traffic Model For SW1
    [Documentation]   Airphone Kpi Test For Traffic Model For SW1
    [Setup]    Prepare Case Environment
    Start Syslog Collection
    Start Emil Log Collection
    ${zip_path1}    Run Traffic With Airphone
    Set Suite Variable    ${zip_path1}    ${zip_path1}
    [Teardown]    Teardown Case Environment

Upgrade For Sw2
    [Documentation]   upgrade to -v SW2
    ...   author: keli
    [Setup]    Prepare Upgrade Environment
    Log To Console    Upgrade For Target Sw2
    Update File Except Sw2
    Log To Console    Start to run upgrade case
    # Run Feature Case    feature_name=Upgrade    test_name=Upgrade
    Start Syslog Collection
    ${latest_build_name}    Get SW VER From json file
    ${upgraded_flag}    Download And Upgrade To Remote GNBs   package=${latest_build_name}
    ...    scf_file_paths=gloden
    Pass Execution If    '${upgraded_flag}'=='${False}'
    ...    All remote Site sw already equal ${EXPECT_SW_VERSION},no need upgrade
    Check Unexpect Alarm For GNBs
    [Teardown]    Teardown Case Environment


Airphone Kpi Test For Traffic Model For SW2
    [Documentation]   Airphone Kpi Test For Traffic Model For SW2
    [Setup]    Prepare Case Environment
    Start Syslog Collection
    Start Emil Log Collection
    ${zip_path2}    Run Traffic With Airphone
    Set Suite Variable    ${zip_path2}    ${zip_path2}
    [Teardown]    Teardown Case Environment

Generate Benchmark Report
    [Documentation]   Generate KPI Benchmark Report
    ${status}    Run Keyword And Return Status    Variable Should Exist    ${zip_path1}
    Run Keyword If    not ${status}    Fail    zip_path1 does not exist!
    ${status}    Run Keyword And Return Status    Variable Should Exist    ${zip_path2}
    Run Keyword If    not ${status}    Fail    zip_path2 does not exist!
    KPI Operation    benchmark_report_generate    pmfile_zip_path1=${zip_path1}
    ...    pmfile_zip_path2=${zip_path2}
    ...    owner=${usr_email}


*** Keywords ***
Prepare Case Environment
    [Documentation]    Orchestrator: prepares directory, daemon, configs, tags, lua path and AP environment.
    Prepare Test Directory
    Start Airphone Daemon
    Load AP User Configuration
    Resolve All Config Tags    ${Testline_type}
    Set Lua Path Variable
    Setup AP Environment

Prepare Test Directory
    [Documentation]    Create per-test directory structure.
    _Create Test Directory

Start Airphone Daemon
    [Documentation]    Start airphone related daemon processes.
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Load AP User Configuration
    [Documentation]    Load AP configs and timeout from user config by email and set suite variables.
    Get AP Configs And Timeout From Ap User Config By Email

Load Customer Tag
    [Documentation]    Derive and set customer tag for current Testline type.
    Get Config Tag From Dict    ${customer_info}    ${Testline_type}    customer_tag    customer    ${False}

Load Environment Tag
    [Documentation]    Derive and set environment tag for current Testline type.
    Get Config Tag From Dict    ${env_info}    ${Testline_type}    env_tag    Use Tag

Resolve All Config Tags
    [Documentation]    Fetch and set apconfig/customer/env tags in one step to reduce duplicate keyword invocations.
    [Arguments]    ${testline_type}
    # apconfig tag
    ${ap_val}    Get Config Tag From Dict    ${ap_info}    ${testline_type}    apconfig_tag    Use Tag
    # customer tag (may legitimately be None)
    ${cust_val}    Get Config Tag From Dict    ${customer_info}    ${testline_type}    customer_tag    customer    ${False}
    # env tag
    ${env_val}    Get Config Tag From Dict    ${env_info}    ${testline_type}    env_tag    Use Tag
    Log To Console    Resolved Tags -> AP:${ap_val} | CUSTOMER:${cust_val} | ENV:${env_val}
    # Required tags validation
    Should Not Be Empty    ${apconfig_tag}    msg=AP tag not resolved. Check ap_info and Testline_type.
    Should Not Be Empty    ${env_tag}        msg=ENV tag not resolved. Check env_info and Testline_type.

Set Lua Path Variable
    [Documentation]    Compute and set lua file path for AP configuration.
    Get Lua Path
    File Should Exist    ${lua_path}

Setup AP Environment
    [Documentation]    Execute AP environment setup using resolved tags.
    Airphone Operation    operation=env_setup_${env_tag}
    ...    product_type=gnb
    ...    tag=${apconfig_tag}
    ...    customer=${customer_tag}

Teardown Case Environment
    [Documentation]    Orchestrator: collect logs, stop log collection & daemon, logout.
    Collect Airphone Logs
    Stop All Log Collections
    Capture Snapshot Logs
    Stop Airphone Daemon
    Logout From Coam

Collect Airphone Logs
    [Documentation]    Collect airphone logs; capture failures but continue.
    TRY
        Airphone Operation    operation=aplog
        ...                   product_type=gnb
        ...                   traffic_info_dic=${None}
        ...                   tag=${None}
        ...                   cmd=${None}
        ...                   pass_regexp=${None}
        ...                   timeout=100s
    EXCEPT    AS    ${err}
        Log    [LOG] Collect Airphone Logs failed: ${err}    WARN
    END

Stop All Log Collections
    [Documentation]    Stop syslog and emil log collection; capture failures but continue.
    TRY
        ${syslog_file}    Stop Syslog Collection
    EXCEPT    AS    ${err}
        Log    [LOG] Stop Syslog Collection failed: ${err}    WARN
    END
    ${emil_started}    Get Variable Value    ${EMIL_LOG_STARTED}    ${False}
    IF    ${emil_started}
        TRY
            ${emil_file}    Stop Emil Log Collection
        EXCEPT    AS    ${err}
            Log    [LOG] Stop Emil Log Collection failed: ${err}    WARN
        END
    ELSE
        Log    [LOG] Skip Stop Emil Log Collection: not started in this test.    INFO
    END

Capture Snapshot Logs
    [Documentation]    Start snapshot log capture; capture failure but continue.
    TRY
        Start Snapshot Log Collection
    EXCEPT    AS    ${err}
        Log    [LOG] Start Snapshot Log Collection failed: ${err}    WARN
    END

Stop Airphone Daemon
    [Documentation]    Stop airphone daemon processes.
    Airphone Operation    operation=edaemon_egate_teardown
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Logout From Coam
    [Documentation]    Logout admin users from Coam.
    Logout All Coam Admin

Prepare Upgrade Environment
    Get AP Configs And Timeout From Ap User Config By Email
    Resolve All Config Tags    ${Testline_type}
    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    ...    airphone_config_tag=${apconfig_tag}
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=${env_tag}


Update File Except Sw${i}
    ${sw}    Get Variable Value    ${SW${i}}    ${None}
    Set Suite Variable    ${SW${i}}    ${sw}
    Return From Keyword If    '${SW${i}}'=='${None}'
    Replace String In One File    file_path=${UTE_RESERVATION_JSON}
    ...    pattern=${Expect_Sw_Version}    replace_with=${SW${i}}
    Replace String In One File    file_path=${UTE_RESERVATION_CONTEXT_JSON}
    ...    pattern=${Expect_Sw_Version}    replace_with=${SW${i}}
    Set Suite Variable    ${EXPECT_SW_VERSION}    ${SW${i}}

# The following legacy tag getter keywords have been removed in favor of Resolve All Config Tags.
# If external reuse is needed in the future, prefer calling Resolve All Config Tags directly
# or using Get Config Tag From Dict with explicit arguments.

Get Config Tag From Dict
    [Documentation]    Generic utility to fetch a value from a dictionary by key, optionally fail if missing, set a Suite variable and also return it.
    ...    Arguments:
    ...    - dict: dictionary object to read
    ...    - key: key to lookup (e.g. ${Testline_type})
    ...    - suite_var_name: name (string) of the suite variable to store the value into
    ...    - log_label: prefix used in final log line (e.g. 'Use Tag' / 'customer')
    ...    - fail_if_missing: whether to fail when key not found (default True)
    [Arguments]    ${dict}    ${key}    ${suite_var_name}    ${log_label}=Tag    ${fail_if_missing}=True
    Log To Console    Get ${log_label} (${suite_var_name})
    ${status}    Run Keyword And Return Status    Get From Dictionary    ${dict}    ${key}
    IF    ${status}
        Log To Console    Key ${key} exists in the dict
        ${value}    Get From Dictionary    ${dict}    ${key}
    ELSE
        Log To Console    Key ${key} does not exist in the dict
        IF    ${fail_if_missing}
            Fail    Missing key ${key} for ${log_label}
        END
        ${value}    Set Variable    ${None}
    END
    Set Suite Variable    ${${suite_var_name}}    ${value}
    Log To Console    ${log_label}:${value}
    [Return]    ${value}

Get Lua Path
    [Documentation]   Print Lua file path
    Set Suite Variable    ${lua_path}    ${CURDIR}/APCFG/wts_${apconfig_tag}.lua
    Log To Console    Lua Path:${lua_path}

Get Ap User Config By Email
    [Arguments]    ${owner}=${usr_email}
    ${config}    get_content_from_json    ${CURDIR}/ap_user_config.json
    ${status}    Run Keyword And Return Status
    ...    Get From Dictionary    ${config}[users]    ${owner}
    ${apconfig}    Run Keyword If    '${status}'=='False'
    ...    Get From Dictionary    ${config}[users]    default
    ...    ELSE    Get From Dictionary    ${config}[users]    ${owner}
    [Return]    ${apconfig}

Get AP Configs And Timeout From Ap User Config By Email
    [Arguments]    ${owner}=${usr_email}
    ${apconfig}    Get Ap User Config By Email   ${owner}
    Log To Console    ${apconfig}
    ${timeout}    Convert To String    ${apconfig}[timeout]
    ${loop_timeout}    Set Variable    ${timeout} seconds
    Set Suite Variable    ${loop_timeout}    ${loop_timeout}
    Log To Console    Set and Use timeout:${loop_timeout}
    ${tl_ap_config}    Get From Dictionary    ${apconfig}    ${Testline_type}
    Set Suite Variable    ${traffic_file}    ${tl_ap_config}[traffic_model]
    Set Suite Variable    ${delta_file_tag}    ${tl_ap_config}[delta_commission]
    Set Suite Variable    ${apconfig_tag}      ${tl_ap_config}[AP_TAG]
    Log To Console    Set traffic file Path:${traffic_file}
    Log To Console    Set delta_commission file tag:${delta_file_tag}
    Log To Console    Set and Use AP_TAG:${apconfig_tag}


Update BSR Package
    [Documentation]   Update bsr package
    Run Keyword If    '${Testline_type}' != 'CLOUD_5G_O_E_AP_LOOO'    Return From Keyword
    Log To Console    Update bsr package
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run Upgrade With Package    ${dllink}    ${filename}

Run Upgrade With Package
    [Documentation]    Download the given BSR package and perform upgrade via coam. Parameters:
    ...    - artifact_url: base URL where the package is hosted (no trailing slash for package name)
    ...    - file_name: package filename to download and install
    ...    - dest_dir: target directory to store the package on host (default /home/ute)
    [Arguments]    ${artifact_url}    ${file_name}    ${dest_dir}=/home/ute
    Log To Console    BSR upgrade with package: ${file_name}
    Run    wget ${artifact_url}/${file_name} -P ${dest_dir}
    coam.setup admin
    ${ret}    coam.Update Software      ${dest_dir}/${file_name}
    coam.teardown admin

Start Snapshot Log Collection
    ${local_file_path}    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Log To Console    \nSnapshot log: ${local_file_path}

Start Syslog Collection
    [Arguments]    ${bts_index}=${0}
    [Documentation]   Collect syslog start
    Start Log Collection    syslog    ${bts_index}

Stop Syslog Collection
    [Arguments]    ${bts_index}=${0}
    [Documentation]   Collect syslog stop
    ${local_file_path}    Stop Log Collection    syslog    ${bts_index}
    Log To Console    \nSyslog log: ${local_file_path}
    [Return]    ${local_file_path}

Start Emil Log Collection
    [Arguments]    ${bts_index}=${0}
    [Documentation]   Collect email log start
    ...    NRCELL_R-1 could be changed if needed
    ${dcap_argument}   Create Dictionary   nrCells=NRCELL_R-1
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Start Log Collection    emil    ${bts_index}    ${dict_argument}
    Set Test Variable    ${EMIL_LOG_STARTED}    ${True}

Stop Emil Log Collection
    [Arguments]    ${bts_index}=${0}
    [Documentation]   Collect emil log stop
    ${local_file_path}    Stop Log Collection    emil    ${bts_index}
    Log To Console    \nEmil log: ${local_file_path}
    Set Test Variable    ${EMIL_LOG_STARTED}    ${False}
    [Return]    ${local_file_path}

Run Traffic With Airphone
    [Arguments]    ${need_generate_report}=False
    Log To Console      ${\n}============= Traffic with Airphone Start. =============${\n}
    Log To Console    loop_timeout: ${loop_timeout}
    Log To Console    Traffic model: ${CURDIR}/Traffic/${traffic_file}
    ${zip_path}    RRM Traffic With Airphone    traffic_module_config_path=${CURDIR}/Traffic/${traffic_file}
    ...    timeout=${loop_timeout}
    ...    lua_path=${lua_path}
    ...    email=${usr_email}
    ...    need_generate_report=${need_generate_report}
    Log To Console      ${\n}============= Traffic with Airphone end. =============${\n}
    [Return]    ${zip_path}

# ================= Generic / DRY helper keywords (added for optimization 2 & 3) =================

Start Log Collection
    [Documentation]    Generic starter for log collection. Sleeps a short period to allow stream stabilization.
    [Arguments]    ${type}    ${bts_index}=0    ${dict_argument}=${None}    ${stabilize_sleep}=20s
    Log Collection    start    ${type}    product_type=gnb    bts_index=${bts_index}    dict_argument=${dict_argument}
    Sleep    ${stabilize_sleep}

Stop Log Collection
    [Documentation]    Generic stop+download for log collection. Returns local file path.
    [Arguments]    ${type}    ${bts_index}=0
    ${local_file_path}    Log Collection    stop_and_download    ${type}    product_type=gnb    bts_index=${bts_index}
    [Return]    ${local_file_path}

#  upgrade package

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
    # Check need upgrade or not
    FOR    ${i}    IN RANGE    ${GNB_NUMBER}
        # Continue For Loop If    ${i}==${0}
        ${need_upgrad_flag}    Run Keyword If
        ...    '${BTS${i}_ACTIVE_SW_VERSION}'=='${EXPECT_SW_VERSION}'
        ...    Set Variable    ${False}
        ...    ELSE
        ...    Set Variable    ${True}
        Exit For Loop If    '${BTS${i}_ACTIVE_SW_VERSION}'!='${EXPECT_SW_VERSION}'
    END
    # Download Package
    ${package_path}    Run Keyword If    ${need_upgrad_flag}
    ...    Download Package
    ...    package=${package}
    ...    download_server_type=${download_server_type}
    ...    alias=${alias}
    ${need_relogin}    Set Variable    ${False}
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
    # FOR    ${i}    IN RANGE   ${GNB_NUMBER}
    #     Continue For Loop If    '${need_upgrad_flag}'=='${False}'
    #     Update SW Build When FID23    package_path=${package_path}    bts_index=${i}
    #     ${upgraded_flag}    Set Variable    ${True}
    # END
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
    Run Keyword If    "_AP_" in '${TESTLINE_TYPE}'    Reload AP Configuration For One GNB
    Wait One GNB Status     bts_index=${i}    wait_max_time=45 min
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

Reload AP Configuration For One GNB
    Log To Console    /*** Reload AP Configuration For One GNB ***/
    Airphone Operation    operation=edaemon_egate_teardown
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    sleep    2s
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_${env_tag}
    ...    product_type=gnb
    ...    tag=${apconfig_tag}
    ...    customer=${customer_tag}