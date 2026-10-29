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
&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_61616}           faultId=${61616}
&{fault_4459}            faultId=${4459}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_61616}
...    &{fault_4459}    &{fault_8000}    &{fault_7300}
# ${APC_Index}    -1
${PA_MinValue}           ${0}
${PA_MaxValue}           ${93}
${DEBUG_MODE}            ${TRUE}
# ${REMOTE_MODE}           ${TRUE}
${usr_email}             tacase_auto@nokia-sbell.com
${traffic_file}          traffic_model_pre.json
${delta_file_tag}        SA_TDD_2c_1gNBSim_255UE
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
    Log To Console    load delta planA
    Delta plan update    A
    ${zip_path1}    Run Traffic With Airphone
    Set Suite Variable    ${zip_path1}    ${zip_path1}
    [Teardown]    Teardown Case Environment


Airphone Kpi Test For Traffic Model With Delta_Commission
    [Documentation]   Airphone Kpi Test For Traffic Model For SW2
    [Setup]    Prepare Case Environment
    Log To Console    load delta planB
    Delta plan update    B
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

Resolve All Config Tags
    [Documentation]    Fetch and set apconfig/customer/env tags in one step to reduce duplicate keyword invocations.
    [Arguments]    ${testline_type}
    ${ap_val}    Get Config Tag From Dict    ${ap_info}    ${testline_type}    apconfig_tag    Use Tag
    ${cust_val}    Get Config Tag From Dict    ${customer_info}    ${testline_type}    customer_tag    customer    ${False}
    ${env_val}    Get Config Tag From Dict    ${env_info}    ${testline_type}    env_tag    Use Tag
    Log To Console    Resolved Tags -> AP:${ap_val} | CUSTOMER:${cust_val} | ENV:${env_val}
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

Update File Except Sw${i}
    ${sw}    Get Variable Value    ${SW${i}}    ${None}
    Set Suite Variable    ${SW${i}}    ${sw}
    Return From Keyword If    '${SW${i}}'=='${None}'
    Replace String In One File    file_path=${UTE_RESERVATION_JSON}
    ...    pattern=${Expect_Sw_Version}    replace_with=${SW${i}}
    Replace String In One File    file_path=${UTE_RESERVATION_CONTEXT_JSON}
    ...    pattern=${Expect_Sw_Version}    replace_with=${SW${i}}

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

Delta plan update
    [Arguments]    ${delta_tag}=B
    ${out}   Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...    delta_file_path=${CURDIR}/APCFG/ap_${delta_file_tag}_delta_${delta_tag}.json
    Log To Console    paramter update result: ${out}

Start Snapshot Log Collection
    ${local_file_path}    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Log To Console    \nSnapshot log: ${local_file_path}

Update BSR Package
    [Documentation]   Update bsr package
    Run Keyword If    '${Testline_type}' != 'CLOUD_5G_O_E_AP_LOOO'    Return From Keyword
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run     wget ${dllink}/${filename} -P /home/ute
    coam.setup admin
    ${ret}     coam.Update Software      /home/ute/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    coam.teardown admin

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

# ================= Generic / DRY helper keywords (added) =================

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

Prepare Upgrade Environment
    Get AP Configs And Timeout From Ap User Config By Email
    Resolve All Config Tags    ${Testline_type}
    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    ...    airphone_config_tag=${apconfig_tag}
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=${env_tag}

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