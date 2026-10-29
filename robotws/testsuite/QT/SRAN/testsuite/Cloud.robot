*** Settings ***
Force Tags    PY39    RF50
Documentation
Suite Setup       AIC Test suite setup
Suite Teardown    Run Keyword And Ignore Error  AiC Test suite Teardown
Library           taf.ul.vdu.helm    WITH NAME    helm
Library           taf.transport.ssh.interface.ssh    WITH NAME    ssh
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library           taf.gnb.oam.coam.cu             WITH NAME    coam_cu
Library           taf.sbts.oam.coam.admin          WITH NAME    coam
Library           OperatingSystem
Library           Collections
Library           String
Library           json
Library           ${CURDIR}/../resources/python/QTListener.py
Library           ${CURDIR}/../resources/python/TestCaseRequirement.py
Resource          ${CURDIR}/../resources/robot/AIC_common_keywords.robot
Resource          ${CURDIR}/../resources/robot/common.robot
Resource          ${CURDIR}/../resources/robot/common_variables.robot
Resource          ${CURDIR}/../resources/robot/classical_keywords.robot
Resource          ${CURDIR}/../resources/robot/common_l3call.robot
Resource          ${CURDIR}/../resources/robot/allowed_alarms.robot
Resource          ${CURDIR}/../resources/robot/additional_check.robot
Test Timeout      2 hour

*** Test Cases ***
AIC undeployment
    [Tags]   SW_DEPL   CellOnAir   UNDEPL  rannic_update    ONAIR_CALL_5G    ONAIR_CALL_4G
    Undeploy AIC
    Check And Recover RanNicConfig CR

AIC deployment
    [Tags]   SW_DEPL   CellOnAir   DEPL    SW_UPGRADE_NO_COMMISSION    ONAIR_CALL_5G    ONAIR_CALL_4G    CNF_LCM_ONAIR_CALL_5G
    [Setup]  Requires TC    AIC undeployment
    Deploy AIC
    BuiltIn.Set Suite Variable    ${skip_cloud_pkg_preparation}    ${True}
    [Teardown]    Run Keyword If Test Passed    Clean tmp after test

Check Access To WebEm
    [Tags]  webem    5G
    [Setup]  Requires TC    AIC deployment
    ${msg}    Catenate    Webem functionality is skipped on LTE product due to taf selenium library is not support
    ...    on lte cloud yet(https://jiradc.ext.net.nokia.com/browse/TAF-4782)
    PASS EXECUTION IF    ${is_LTE}    ${msg}
    Pass Execution if CCR Fallback Occurs     WebEM check
    Selenium Login And Version Check On WebEM    ${par_prefix}

Check deployed AIC version
    [Tags]  SW_DEPL   CellOnAir    SW_UPGRADE_NO_COMMISSION    ONAIR_CALL_5G    ONAIR_CALL_4G    CNF_LCM_ONAIR_CALL_5G
    [Setup]  Requires TC    AIC deployment
    Pass Execution If    '${AF_PATH}'=='null'  Skip sw version check as AF_PATH is not given!!!
    ${cnf_lcm_deploy}    Get Variable Value    ${cnf_lcm_deploy}    ${False}
    IF    ${cnf_lcm_deploy}
        Check AIC Version In CR
    ELSE
        Check AIC version with helm
    END

Check AIC container status
    [Tags]    SW_DEPL    container   CellOnAir    SW_UPGRADE_NO_COMMISSION    ONAIR_CALL_5G    ONAIR_CALL_4G    CNF_LCM_ONAIR_CALL_5G
    [Setup]    Requires TC    AIC deployment
    Check Containers status after deployment
    [Teardown]    Run Keyword If Test Failed
    ...   Get describe log

Check RF State
    [Tags]  CellOnAir    SW_UPGRADE_NO_COMMISSION    CellOnAir_before_commission    ONAIR_CALL_5G    CNF_LCM_ONAIR_CALL_5G
    [Setup]    Requires TC    AIC deployment
    Pass Execution if CCR Fallback Occurs     RF
    ${timeout}    set variable if    '${is_TDD}' == 'True'    40    20
    ${RF_check}     Run keyword and return status    Verify RF status on WebEm    loop_check=5
    IF    ${vDU_build_flag} and not ${RF_check}
        Verify RF status on WebEm    loop_check=${timeout}
    ELSE
        Should be true    ${RF_check}
    END
    [Teardown]

Verify E1 interface
    [Tags]    CellOnAir    SW_UPGRADE_NO_COMMISSION    5G    CellOnAir_before_commission    ONAIR_CALL_5G    CNF_LCM_ONAIR_CALL_5G
    [Setup]    Requires TC    AIC deployment
    Pass Execution if CCR Fallback Occurs     E1
    ${e1_loop_check}    Set Variable If    ${vCU_build_flag}    20    1
    Verify E1 Status on OAM_CU   oam_ip=${CU_WEBUI_IP}    loop_check=${e1_loop_check}
    [Teardown]

Verify F1 interface
    [Tags]   CellOnAir    SW_UPGRADE_NO_COMMISSION    5G    CellOnAir_before_commission    ONAIR_CALL_5G    CNF_LCM_ONAIR_CALL_5G
    [Setup]    Requires TC    AIC deployment
    Pass Execution if CCR Fallback Occurs     F1
    Wait Until Keyword Succeeds    10min    30s    Verify vDU_OAM F1 Setup
    [Teardown]

Verify NG connection
    [Tags]     CellOnAir    SA    5G    SW_UPGRADE_NO_COMMISSION     CellOnAir_before_commission    ONAIR_CALL_5G
    ...        CNF_LCM_ONAIR_CALL_5G
    [Setup]    Requires TC   AIC deployment
    Pass Execution if CCR Fallback Occurs     NG
    Verify CU_OAM NG Setup    loop_check=11
    [Teardown]

Verify X2 connection to MeNB
    [Tags]   CellOnAir    NSA    5G    SW_UPGRADE_NO_COMMISSION    CellOnAir_before_commission    ONAIR_CALL_5G
    ...      CNF_LCM_ONAIR_CALL_5G
    [Setup]    Requires TC    Verify F1 interface
    Pass Execution if CCR Fallback Occurs     X2
    Verify CU_OAM X2 Setup    loop_check=20

Verify gNB Cell setup
    [Tags]     CellOnAir    SW_UPGRADE_NO_COMMISSION    CellOnAir_before_commission    ONAIR_CALL_5G    CNF_LCM_ONAIR_CALL_5G
    [Setup]     Requires Tc    AIC deployment
    Pass Execution if CCR Fallback Occurs     Cell setup
    ${cell_check_loop}    Set Variable If    ${is_LTE}    20    11
    Check Cell setup for vDU    ${cell_check_loop}
    [Teardown]

AIC deployment with hanging resource cleanup
    [Tags]    RE_DEPL    Clean_DEPL    Clean_DEPL_to_OnAir_4G    Clean_DEPL_to_OnAir_5G    Clean_DEPL_to_CALL_4G
    ...       Clean_DEPL_to_CALL_5G    Clean_DEPL_to_L3call    Clean_DEPL_to_OnAir
    [Setup]    Requires TC    Verify gNB Cell setup
    ${skip_cloud_pkg_preparation}    Get Variable Value    ${skip_cloud_pkg_preparation}    ${False}
    Undeploy AIC    hanging_resource_cleanup=${True}
    Deploy AIC   skip_cloud_pkg_preparation=${skip_cloud_pkg_preparation}    clean_deploy=${True}
    [Teardown]    Run Keyword If Test Passed    Clean tmp after test

Check re-deployed AIC version
    [Tags]    sw_version    RE_DEPL     Clean_DEPL    Clean_DEPL_to_OnAir_4G    Clean_DEPL_to_OnAir_5G
    ...       Clean_DEPL_to_CALL_4G    Clean_DEPL_to_CALL_5G    Clean_DEPL_to_L3call    Clean_DEPL_to_OnAir
    [Setup]  Requires TC    AIC deployment with hanging resource cleanup
    Pass Execution If    '${AF_PATH}'=='null'  Skip sw version check as AF_PATH is not given!!!
    ${cnf_lcm_deploy}    Get Variable Value    ${cnf_lcm_deploy}    ${False}
    IF    ${cnf_lcm_deploy}
        Check AIC Version In CR
    ELSE
        Check AIC version with helm
    END

Check AIC container status after re-deployment
    [Tags]    RE_DEPL    Clean_DEPL    Clean_DEPL_to_OnAir_4G    Clean_DEPL_to_OnAir_5G    Clean_DEPL_to_CALL_4G
    ...       Clean_DEPL_to_CALL_5G    Clean_DEPL_to_L3call    Clean_DEPL_to_OnAir
    [Setup]    Requires TC    AIC deployment with hanging resource cleanup
    Check Containers status after deployment
    [Teardown]    Run Keyword If Test Failed
    ...   Get describe log

AIC Commission via REST API
    [Tags]    COMMISSION    scf    CellOnAir    Clean_DEPL_to_OnAir_4G    Clean_DEPL_to_OnAir_5G    ONAIR_CALL_5G    ONAIR_CALL_4G
    ...       Clean_DEPL_to_CALL_4G    Clean_DEPL_to_CALL_5G    Clean_DEPL_to_L3call    Clean_DEPL_to_OnAir
    ...       CNF_LCM_ONAIR_CALL_5G
    [Setup]    Run Keywords        Requires TC    AIC deployment with hanging resource cleanup
    ...        AND     Requires TC    AIC deployment
    ...        AND     Requires TC    Verify gNB Cell setup
    [Timeout]    35 min
    ${aic_redep_status}=    get test case status by name    AIC deployment with hanging resource cleanup
    IF  '${aic_redep_status}' != 'NA' and '${gnss_sync_in_rinline2}' == 'False'
        Check And Recover mri status on FHGW  mri=1
    ELSE IF  '${aic_redep_status}' != 'NA' and '${gnss_sync_in_rinline2}' == 'True'
        ${mri_result}    Check mri status on FHGW for Sync In Rinline2    mri=nil (nil)
        IF    not ${mri_result[0]}
            Log    MRI status is ${mri_result[1]}, but expected result is nil!!!    WARN
        END
    END
    ${scf_from_template_exist}    Set Variable    False
    ${template_scf_variables}=     Run Keyword If    ${vDU_build_flag}
    ...    Run Keyword And Return Status    Variable Should Exist    ${tl.du_scf_variables}
    ...    ELSE IF    ${vCU_build_flag}
    ...    Run Keyword And Return Status    Variable Should Exist    ${tl.cu_scf_variables}
    Set Suite Variable            ${template_scf_variables}
    TRY
        Run Keyword If         ${template_scf_variables}    Generate SCF Via Template
    EXCEPT    AS    ${error}
        Log    !!!SCF generation failed due to ${error}!!! Test will be continued with scf in qt_config repo    WARN
    END
    Set SCF Directory
    ${nidd_ver}    Get Variable Value    ${nidd_ver}    ${EMPTY}
    Run Keyword If    '${nidd_ver}'=='${EMPTY}'    Get NIDD from Vendor XML
    Check If Directory On Repo Exists And Get Latest SCF
    ${scf_path}     Set Variable If    ${template_scf_variables} and '${scf_from_template_exist}'=='True'     ${output_scf_file}
    ...                               '${is_tl_dir_on_repo}'=='False'    none
    ...                                ${scf_dir}/${nidd_ver}_${testline_name}.xml
    Run Keyword If                    '${scf_path}'=='none' and ${template_scf_variables} and not ${scf_from_template_exist}
    ...                                Fail    SCF generated from template failed and No SCF available in qt_config repo, pls check!
    ...    ELSE IF                    '${scf_path}'=='none'    Fail    No SCF available in qt_config repo, pls check!
    ${condition}    Catenate          '${is_scf_with_nidd_on_repo}'=='False' and '${is_tl_dir_on_repo}'=='True'
    ...                                and '${scf_from_template_exist}'=='False'
    ...                                or ('${nidd_ver}'=='None' and '${template_scf_variables}'=='False')
    ${scf_path}     Set Variable If    ${condition}    ${scf_dir}/${latest_scf_on_repo}    ${scf_path}
    Set Suite Variable    ${scf_path}
    Load And Active SCF
    ...   ${${par_prefix}_WEBUI_IP}    ${scf_path}
    IF    '${gnss_sync_in_rinline2}' == 'False'
        Check And Recover mri status on FHGW  mri=2 3
    ELSE IF    '${gnss_sync_in_rinline2}' == 'True'
        ${mri_result}    Check mri status on FHGW for Sync In Rinline2    mri=3    loop_check=25
        Should Be True    ${mri_result[0]}    Expected mri status is 3 but actual result is ${mri_result[1]}
    END
    Run keyword If    '${vCU_build_flag}'=='True'
    ...   Wait Until Keyword Succeeds    2min    30s    Check SCF Activation Status in log
    Run keyword If    '${vCU_build_flag}'=='True'
    ...   Run Keyword and Ignore Error    Enable vCU C-Plane debug log
    Run keyword If    '${vDU_build_flag}' == 'True' and '${is_TDD}' == 'True'  Get eCpriMaerPortConfList
    Run Keyword If    '${not_allowed_list}'=='False'
    ...                Run Keywords
    ...                Log To Console   \n - Not allowed alarm appeared: ${not_allowed_alarms} \n
    ...                AND    FAIL
    [Teardown]    Run Keyword If Test Failed
    ...           Run Keyword and Ignore Error   Get Pod status

Check RF State after commission
    [Tags]  CellOnAir    RF     COMMISSION    Clean_DEPL_to_OnAir_4G    Clean_DEPL_to_OnAir_5G    Clean_DEPL_to_L3call
    ...     Clean_DEPL_to_CALL_4G    Clean_DEPL_to_CALL_5G    ONAIR_CALL_4G    ONAIR_CALL_5G    Clean_DEPL_to_OnAir
    ...     CNF_LCM_ONAIR_CALL_5G
    [Setup]    Requires TC    AIC Commission via REST API
    ${timeout}    set variable if    '${is_TDD}' == 'True'    40    20
    ${RF_check}     Run keyword and return status    Verify RF status on WebEm    loop_check=1
    IF    ${vDU_build_flag} and not ${RF_check}
        Verify RF status on WebEm    loop_check=${timeout}
    ELSE
        Should be true    ${RF_check}
    END
    [Teardown]

Verify E1 interface after commission
    [Tags]    CellOnAir   COMMISSION     e1    5G    Clean_DEPL_to_OnAir_5G    Clean_DEPL_to_CALL_5G    ONAIR_CALL_5G
    ...       Clean_DEPL_to_L3call    Clean_DEPL_to_OnAir    CNF_LCM_ONAIR_CALL_5G
    [Setup]    Requires TC    AIC Commission via REST API
    ${e1_loop_check}    Set Variable If    ${vCU_build_flag}    20    1
    Verify E1 Status on OAM_CU   oam_ip=${CU_WEBUI_IP}    loop_check=${e1_loop_check}
    [Teardown]

Verify F1 interface after commission
    [Tags]   CellOnAir    f1    COMMISSION    5G    Clean_DEPL_to_OnAir_5G    Clean_DEPL_to_CALL_5G    ONAIR_CALL_5G
    ...      Clean_DEPL_to_L3call    Clean_DEPL_to_OnAir    CNF_LCM_ONAIR_CALL_5G
    [Setup]    Requires TC    AIC Commission via REST API
    Wait Until Keyword Succeeds    10min    30s    Verify vDU_OAM F1 Setup
    [Teardown]

Verify NG connection after commission
    [Tags]     CellOnAir    SA     COMMISSION    ng    5G    Clean_DEPL_to_OnAir_5G    Clean_DEPL_to_CALL_5G   ONAIR_CALL_5G
    ...        Clean_DEPL_to_L3call    Clean_DEPL_to_OnAir    CNF_LCM_ONAIR_CALL_5G
    [Setup]    Requires TC   AIC Commission via REST API
    Verify CU_OAM NG Setup    loop_check=11
    [Teardown]

Verify X2 connection to MeNB after commission
    [Tags]   CellOnAir    x2    COMMISSION     NSA    5G    Clean_DEPL_to_OnAir_5G    Clean_DEPL_to_CALL_5G    ONAIR_CALL_5G
    ...      Clean_DEPL_to_L3call    Clean_DEPL_to_OnAir    CNF_LCM_ONAIR_CALL_5G
    [Setup]    Requires TC    Verify F1 interface
    Verify CU_OAM X2 Setup    loop_check=20

Verify gNB Cell setup after commission
    [Tags]     CellOnAir    cell    COMMISSION    Clean_DEPL_to_OnAir_4G    Clean_DEPL_to_OnAir_5G    Clean_DEPL_to_L3call
    ...        Clean_DEPL_to_CALL_4G    Clean_DEPL_to_CALL_5G    ONAIR_CALL_4G    ONAIR_CALL_5G   Clean_DEPL_to_OnAir
    [Setup]     Requires Tc    AIC deployment with hanging resource cleanup
    ${cell_check_loop}    Set Variable If    ${is_LTE}    20    11
    Check Cell setup for vDU    ${cell_check_loop}
    [Teardown]

Check Cell onair
    [Tags]   CellOnAir    cell    COMMISSION    rfpower    TELECOM    CALL_4G    CALL_5G    SW_UPGRADE_NO_COMMISSION
    ...      Clean_DEPL_to_OnAir_4G    Clean_DEPL_to_OnAir_5G    Clean_DEPL_to_CALL_4G    Clean_DEPL_to_CALL_5G
    ...      ONAIR_CALL_4G    ONAIR_CALL_5G    Clean_DEPL_to_L3call    CNF_LCM_ONAIR_CALL_5G
    [Setup]    Run Keywords    Requires TC    Verify gNB Cell setup
    ...    AND    Requires TC    Verify gNB Cell setup after commission
    IF    not ${gnss_sync_in_rinline2}
        ${res_bool}    Run Keyword And Return Status  Check GNSSEMOD-1 state in FHGW
        Run Keyword If  '${res_bool}' == 'False'  Log To Console  -->GNSSEMOD-1 status check failed, please manually check!  WARN
    END
    IF    ${is_FDD} and not ${is_LTE}
        ${cell_power_status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1m    10s    Check RF Power for FDD
        IF    '${cell_power_status}' == 'False'
            Run Keyword If    ${vDU_build_flag}    Set Suite Variable    ${FHGW_SNAPSHOT}    ${True}
            Fail
        END
    ELSE
        Wait Until Keyword Succeeds    3m    60s    Check RF Power On DU
    END

Snapshot Collection
    [Tags]  CellOnAir    Snapshot_Alarm    snapshot    Clean_DEPL_to_OnAir_4G    Clean_DEPL_to_OnAir_5G    Clean_DEPL_to_OnAir
    ...     ONAIR_CALL_5G    ONAIR_CALL_4G    Clean_DEPL_to_CALL_4G    Clean_DEPL_to_CALL_5G    Clean_DEPL_to_L3call
    ...     CNF_LCM_ONAIR_CALL_5G
    [Setup]     Requires Tc    AIC deployment
    ${skip_log_collection}    Get Variable Value    ${skip_log_collection}    False
    IF    not ${skip_log_collection}
        Run Keyword If    ${vCU_build_flag}
        ...               Save Cloud Snapshot    vCUorvDU=vCU    name=onair_
        ...       ELSE    Save Cloud Snapshot    vCUorvDU=vDU    name=onair_
    ELSE
        Log to Console    Test skipped due to skip_log_collection is True!
    END

Check Alarms After Cell Onair
    [Tags]    CellOnAir    Snapshot_Alarm    Clean_DEPL_to_OnAir_4G    Clean_DEPL_to_OnAir_5G    Clean_DEPL_to_OnAir
    ...       Clean_DEPL_to_CALL_4G    Clean_DEPL_to_CALL_5G    ONAIR_CALL_5G    ONAIR_CALL_4G    Clean_DEPL_to_L3call
    ...       CNF_LCM_ONAIR_CALL_5G
    [Setup]     Requires Tc    AIC deployment
    Run Keyword If   '${vCU_build_flag}'=='True'
    ...               Check Unexpected Active And Historical Alarms on Cloud   vCUorvDU=vCU
    ...               ELSE
    ...               Check Unexpected Active And Historical Alarms On Cloud   vCUorvDU=vDU
    [Teardown]    Run Keywords
    ...    Run Keyword and ignore error    coam_cu.disconnect
    ...    AND  Run Keyword and ignore error    vdu.disconnect   vdu_connection=du_admin

L3 Call 4G
    [Tags]       ATT_DT    CALL_4G    ONAIR_CALL_4G    Clean_DEPL_to_CALL_4G    4G    Clean_DEPL_to_L3call
    [Setup]      Run Keywords    Requires TC    Check Cell onair
    ...          AND             Requires Tc    Check Alarms After Cell Onair
    [Timeout]    25 min
    L3 call      AIC     _4G
    [Teardown]   Run Keywords
    ...          Teardown After L3Call
    ...    AND   Run Keyword If Test Failed    Run Keyword and Ignore Error    Get Pod status

L3 Call 5G
    [Tags]       ATT_DT    CALL_5G    ONAIR_CALL_5G    Clean_DEPL_to_CALL_5G    Clean_DEPL_to_L3call    5G
    ...          CNF_LCM_ONAIR_CALL_5G
    [Setup]      Run Keywords    Requires TC    Check Cell onair
    ...          AND             Requires Tc    Check Alarms After Cell Onair
    [Timeout]    25 min
    L3 call      AIC    _5G
    [Teardown]   Run Keywords
    ...          Teardown After L3Call
    ...    AND   Run Keyword If Test Failed    Run Keyword and Ignore Error    Get Pod status

Check Active And Historical Alarms
    [Tags]      ONAIR_CALL_5G    ONAIR_CALL_4G    ATT_DT    alarm    CALL_5G    CALL_4G    Clean_DEPL_to_CALL_4G    Clean_DEPL_to_CALL_5G
    ...         Clean_DEPL_to_L3call    CNF_LCM_ONAIR_CALL_5G
    [Setup]     Run Keywords    Requires Tc    AIC deployment
    ...         AND    Requires Tc    AIC deployment with hanging resource cleanup
    ...         AND    Requires Tc    Check Alarms After Cell Onair
    ${webui_connection}=  Run Keyword And Return Status  Run Keyword If  ${vDU_build_flag}
    ...  Connect To vDU  host_ip=${DU_WEBUI_IP}  loop_check=${4}
    ...  ELSE IF  ${vCU_build_flag}    Connect To vCU
    ...  host_ip=${CU_WEBUI_IP}    loop_check=${4}
    Should Be True  ${webui_connection}    ${par_prefix} WebEM connection failed!!!
    Set Test Variable  ${webui_connection}
    Run Keyword And Continue On Failure  Run Keyword If   '${vCU_build_flag}'=='True'
    ...               Check Unexpected Active And Historical Alarms on Cloud   vCUorvDU=vCU
    ...               ELSE
    ...               Check Unexpected Active And Historical Alarms On Cloud   vCUorvDU=vDU
    [Teardown]    Run Keywords
    ...    Run Keyword and ignore error    coam_cu.disconnect
    ...    AND  Run Keyword and ignore error    vdu.disconnect   vdu_connection=du_admin

Additional Site Reset
    [Tags]     RESET    5G
    [Setup]  Run Keywords  Requires TC  Check deployed AIC version
    ...  AND  Requires TC  Check AIC container status
    ...  AND  Requires TC  Check re-deployed AIC version
    ...  AND  Requires TC  Check AIC container status after re-deployment
    ...  AND  Requires TC  Check RF State
    ...  AND  Requires TC  Verify E1 interface
    ...  AND  Requires TC  Verify F1 interface
    ...  AND  Requires TC  Verify NG connection
    ...  AND  Requires TC  Verify X2 connection to MeNB
    ...  AND  Requires TC  Check Cell onair
    ...  AND  Requires TC  Snapshot Collection
    ...  AND  Requires TC  Check Alarms After Cell Onair
    ...  AND  Requires TC  Check Active And Historical Alarms
   ${reset_prefix}=  Set Variable If  ${vDU_build_flag}  CU  DU
    Log To Console  --> Additional ${reset_prefix} Reset started
    Run Keyword If  ${vDU_build_flag}  Check Cell Setup after CU reset
    ...  ELSE  Check Cell Setup after DU reset

Check Alarm After Site Reset
    [Tags]    RESET    5G
    [Setup]   Requires TC    Additional Site Reset
    ${is_additional_case_tested}    Get Variable Value    ${additional_case_status}    False
    IF    ${is_additional_case_tested}
        Run Keyword If   '${vCU_build_flag}'=='True'
        ...               Check Unexpected Active And Historical Alarms on Cloud   vCUorvDU=vCU
        ...               ELSE
        ...               Check Unexpected Active And Historical Alarms On Cloud   vCUorvDU=vDU
    ELSE
        Log    Check alarm case will not be tested due to additional site reset case skipped    WARN
    END
    [Teardown]    Run Keywords
    ...    Run Keyword and ignore error    coam_cu.disconnect
    ...    AND  Run Keyword and ignore error    vdu.disconnect   vdu_connection=du_admin

Check Crash Info In Log
    [Tags]    CRASH_INFO    CellOnAir    CALL_5G    Clean_DEPL_to_CALL_4G    ONAIR_CALL_5G    ONAIR_CALL_4G
    ...       Clean_DEPL_to_L3call    Clean_DEPL_to_CALL_5G    Clean_DEPL_to_OnAir    CNF_LCM_ONAIR_CALL_5G
    Crash Info Check In Cloud Syslog