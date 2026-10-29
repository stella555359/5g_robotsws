
*** Setting ***
Documentation
...    author: Cuicui Wang
...    contact: cuicui.wang@nokia-sbell.com
...    Purpose: This file inculde commom suite setup/teardown, test setup/teardowm, suggestion feature team use them
...
...    Clarification: In common setup and teardown keyword, it include catch syslog function, so please confirm:
...    1. In KVM, manually catch syslog should be successfully with btslog tool
...    2. Catch syslog depend on __init__.py, so please confirm config __init__.py as template:
...       https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1264886687
...    3. If there is gnbs=[_cbts] and enbs=[_lteenb] in __init__.py, both gNB and eNB syslog will be catched, so please
...    confirm 1 in both gNB and eNB KVM.

Library           Collections
Library           OperatingSystem
Library           String
Library           Process
Library           taf.ul.sc.tl_config.TestLineConfiguration
#Library           ${CURDIR}/DevNJ_CM_lib
Library           ./DevNJ_get_tl_configuration.py    WITH NAME    Get_TL_Configuration
Library           ./DevNJ_download_build_from_LS.py  WITH NAME    Download_Obj
Library           ./DevNJ_sbts_keywords.py
Library           ./DevNJ_btslog.py
Library           ./DevNJ_ResourceUsage.py
Resource          ./DevNJ_asicli.robot
Resource          ./DevNJ_epcsim_setup.robot
Resource          ./DevNJ_upgrade.robot
Resource          ./DevNJ_testline.robot
Resource          taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SCF_TEMPLATE_PATH}    ${CURDIR}${/}configuration_file
${FLAG}    ${True}
${tl_type}  ${tl.tl_cloud_topology}
#${config_dir}  ${OUTPUT DIR}/config/gnb1/
${WTS_DIR}        /opt/iphy/latest    # can not change because it is hardcode in TA lib
${BTS_STARTUP_RETRY}    1
@{PARAMS_IN_SCF}    @{EMPTY}
@{PARAMS_IN_SWCONFIG}    @{EMPTY}
${ENB_BUILD}    null
${Test_Setup_Status}  ${False}


*** Keywords ***
Common Suite Setup For Sbts
    [Arguments]    ${subtype}=null    ${bts_type}=all

    Log To Console    \n=====Start: Common Suite Setup For Sbts=====
    Common Env Setup
    Run Keyword If  ${FLAG}==${True}  Prepare Sbts To Onair Status    ${subtype}
    Setup Sbts Btslog Collector    bts_type=${bts_type}
    Log To Console    \n=====End: Common Suite Setup For Sbts=====

Common Suite Teardown For Sbts
    [Arguments]    ${bts_type}=all
    Log To Console    \n=====Start: Common Suite Teardown For Sbts=====
    Run Keyword If  ${FLAG}==${True}  Run Keyword And Ignore Error  Recover Swconfig File
    Teardown Sbts Btslog Collector    bts_type=${bts_type}
    Log To Console    \n=====End: Common Suite Teardown For Sbts=====

Common Test Setup For Sbts
    [Arguments]    ${forbidden_fault_id_list}=${None}
    ...  ${allowed_fault_id_list}=${None}
    ...  ${required_fault_id_list}=${None}
    ...  ${hanging_resource_flag}=${True}
    ...  ${cell_status_check_number}=${1}
    ...  ${bts_type}=all
    [Documentation]  Cuicui Wang: Common Test Setup For Sbts
    ...    This Keyword is common for 5G and 4G, but have a limitation

    Set Test Variable  ${Test_Setup_Status}  ${False}
    Log To Console    \n=====Start: Common Test Setup For Sbts=====
    Create Test Log Directory For Sbts
    Start Collecting Sbts Btslog    bts_type=${bts_type}
    ${expected_status}  Create Dictionary  availabilityStatus=Online
    Wait Until Keyword Succeeds  ${cell_status_check_number}x  10  Check Sbts Cell Status  expected_status_dict=${expected_status}
    Check Sbts Active Alarm
    ...  forbidden_fault_id_list=${forbidden_fault_id_list}
    ...  allowed_fault_id_list=${allowed_fault_id_list}
    ...  required_fault_id_list=${required_fault_id_list}
    Start Get Resources Usage  check_hanging_resouce_flag=${hanging_resource_flag}
    Set Test Variable  ${Test_Setup_Status}  ${True}
    Log To Console    \n=====Common Test Setup For Sbts successfully, set Test_Setup_Status=${Test_Setup_Status}=====
    Log To Console    \n=====End: Common Test Setup For Sbts=====

Common Test Teardown For Sbts
    [Arguments]    ${hanging_resource_flag}=${True}    ${bts_type}=all
    [Documentation]  Cuicui Wang: Common Test Teardown For Sbts
    ...    This Keyword is common for 5G and 4G, but have a limitation

    Stop Collecting Sbts Btslog  log_dir=${TEST_LOG_DIR}    bts_type=${bts_type}
    ${expected_status}  Create Dictionary  availabilityStatus=Online
    Check Sbts Cell Status  expected_status_dict=${expected_status}
    Run Keyword And Ignore Error  End Get Resources Usage  check_hanging_resouce_flag=${hanging_resource_flag}
    Log To Console    \n=====Start: Common step trigger=====
    interface.Common Step Trigger
    Log To Console    \n=====End: Common step trigger=====
    [Teardown]  Run Keyword And Ignore Error  Run Keyword If  ${Test_Setup_Status}==${True}  Run Keyword If Test Failed  Collect Sbts Snapshot
    ...  target_file_name=${TEST_LOG_DIR}/${TEST NAME}.zip
    ...  timeout=900

Common Env Setup
    ${time}    Get Time
    Log To Console    \n=====Current Time is ${time}=====
    Log To Console    \n=====CURDIR=${CURDIR}=====
    Log Variables
    Run Keyword And Ignore Error    Execute Cmd On Pc    df -h ${OUTPUT_DIR}
    Create Suite Log Directory For Sbts
    Log To Console    \n=====Setup EPCsim=====
    Run Keyword If  ${FLAG}==${True}  Setup EPCSim
    #Run Keyword If  'DAS' not in '${tl_type}' and 'CDD' not in '${tl_type}'  Run Keywords
    #...  Log To Console    \nPerpare CLI  AND
    #...  Install ASI CLI For UTE Cloud


Prepare Sbts To Onair Status
    [Arguments]    ${subtype}
    [Documentation]  Cuicui Wang: This Keyword Is To Bringup SBTS.
    ...    | 1 | Get Testline info |
    ...    | 2 | change swconfig file defined in @{PARAMS_IN_SWCONFIG} |
    ...    | 3 | full commissioning SCFC with @{PARAMS_IN_SCF} and upgrade build if needed |
    ...    | 4 | Wait BTS onair |

    ${onair_status}    Set Variable    ${False}
    Waiting For Sbts Connection
    Log To Console    \n=====start bts for 1st time=====
    ${mrbtsid}  ${PARAMS_IN_SCF_TOTAL}  ${sbts_commission_path}  ${asir_commission_path}   Get GNB ASIR And Testline Info
    ...     ${subtype}
    Get Change Swconfig Base On Release
    Log To Console  scf_change_list=${PARAMS_IN_SCF_TOTAL}

    ${asir_status}    Check RadioModule Status    'radioModules'
    Run keyword If  'CDD' in '${tl_type}'
    ...    Modify Scf And Perfom SBTS ASIR Full Commission    ${mrbtsid}
    ...    ${PARAMS_IN_SCF_TOTAL}
    ...    ${sbts_commission_path}
    ...    ${asir_commission_path}
    ...    ELSE IF  '${asir_status}'=='Online'  Run Keyword  Modify Scf And Perfom SBTS ASIR Full Commission    ${mrbtsid}
    ...    ${PARAMS_IN_SCF_TOTAL}
    ...    ${sbts_commission_path}
    ...    ${asir_commission_path}
    ...    ELSE  Run Keyword  Modify Scf Upgrade Build And Perfom SBTS ASIR Full Commission   ${mrbtsid}  ${PARAMS_IN_SCF_TOTAL}
    ...    ${sbts_commission_path}  ${asir_commission_path}

    #Log To Console With Time Prefix    \n=====Wait SBTS SSH connected=====
    Waiting For Sbts Connection
    Wait Until Keyword Succeeds  15 min  30s  Check Sbts Site Status  expect_status=OnAir
    ${expected_status}  Create Dictionary  availabilityStatus=Online
    Wait Until Keyword Succeeds  15 min  30s  Check Sbts Cell Status  expected_status_dict=${expected_status}
    #Log To Console With Time Prefix    \n=====SBTS is already onair=====


Modify Scf And Perfom SBTS ASIR Full Commission
    [Arguments]     ${mrbtsid}  ${para}  ${sbts_commission_path}  ${asir_commission_path}
    [Documentation]  Cuicui Wang: Modify And Perform Full Commission
    ...    | Input Parameters | Man. | Description |
    ...    | mrbtsid | Y | BTS ID |
    ...    | para | Y | List of parameter need to modify |
    ...    | sbts_commission_path | Y | sbts commission path |
    ...    | asir_commission_path | Y | asir commission path |

#	Run Keyword If  'DAS' not in '${tl_type}' and 'CDD' not in '${tl_type}'
#    ...  Get_TL_Configuration.Change Hub Commission Targetbtsid       ${asir_commission_path}    ${mrbtsid}
#    Get_TL_Configuration.Change GNB Commission Btsid Nrbtsid     ${gnb_commission_path}    ${mrbtsid}
    ${scf_for_startup}    Modify Scf And Perform Full Commission    ${sbts_commission_path}   ${para}
    #Log To Console With Time Prefix    \n=====Wait SBTS SSH connected=====
    Waiting For Sbts Connection
    Log To Console  \n=====Wait for BaseBandModulesStatus Online=====
    Wait Until Keyword Succeeds     15x   1min    COAM_Admin_CheckUnitsStatusNormal      'basebandModules'
    Log To Console  \n=====Wait for RadioModulesStatus Online=====
    Wait Until Keyword Succeeds     15x   1min    COAM_Admin_CheckUnitsStatusNormal      'radioModules'

    Run Keyword If  'DAS' not in '${tl_type}' and 'CDD' not in '${tl_type}'
    ...    Wait Until Keyword Succeeds  6x  60s    Run keywords
    #...          Log To Console With Time Prefix  \n=====Perform ASIR Commission=====
    ...          Run Keyword And Continue On Failure  Perform ASIR Commission In Suite Setup   ${asir_commission_path}
    ...          AND  Sleep  30s
    [Return]    ${scf_for_startup}

Modify Scf Upgrade Build And Perfom SBTS ASIR Full Commission
    [Arguments]     ${mrbtsid}  ${para}  ${sbts_commission_path}  ${asir_commission_path}
    [Documentation]  Cuicui Wang: Modify Perform Full Commission And Upgrade Build
    ...    | Input Parameters | Man. | Description |
    ...    | mrbtsid | Y | BTS ID |
    ...    | para | Y | List of parameter need to modify |
    ...    | sbts_commission_path | Y | sbts commission path |
    ...    | asir_commission_path | Y | asir commission path |

    Log To Console  \n=====Start Download SW Build From Load Server=====
    ${sw_build_path}  Download_Obj.Download Sw Build From Loadserver   ${ENB_BUILD}
    Log To Console  \n=====Download SW Build From Load Server Finished=====
#	Run Keyword If  'DAS' not in '${tl_type}'
#    ...  Get_TL_Configuration.Change Hub Commission Targetbtsid       ${asir_commission_path}    ${mrbtsid}
#    Get_TL_Configuration.Change GNB Commission Btsid Nrbtsid     ${gnb_commission_path}    ${mrbtsid}
    ${scf_for_startup}    Modify Scf And Perform Full Commission    ${sbts_commission_path}   ${para}
    #Log To Console With Time Prefix    Wait SBTS SSH connected
    Waiting For Sbts Connection
    Log To Console  Wait for BaseBandModulesStatus Online
    Wait Until Keyword Succeeds     15x   1min    COAM_Admin_CheckUnitsStatusNormal      'basebandModules'
    Sleep  30s
    # Upgrade Build Via Coam
    COAM_Admin_UpdateSW     ${sw_build_path}
    #Log To Console With Time Prefix    wait SBTS SSH connected
    Waiting For Sbts Connection
    Log To Console  Wait for RadioModulesStatus Online
    Wait Until Keyword Succeeds     15x   1min    COAM_Admin_CheckUnitsStatusNormal      'radioModules'

    Run Keyword If  'DAS' not in '${tl_type}'
    ...    Wait Until Keyword Succeeds  6x  60s    Run keywords
    #...          Log To Console With Time Prefix  \n=====Perform ASIR Commission after upgrade load=====
    ...          Run Keyword And Continue On Failure  Perform ASIR Commission In Suite Setup   ${asir_commission_path}
    ...          AND  Sleep  30s

Perform ASIR Commission In Suite Setup
    [Documentation]    This keyword performs asir commission file
    [Arguments]
    ...            ${asir_commission}
    ...            ${asicli_dir}=/opt/asir
    ...            ${ip_address}=192.168.255.129
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    cd ${asicli_dir}; ${asicli_dir}/commission.sh -ne ${ip_address} -pw Nemuadmin:nemuuser -fullfile \"${asir_commission}\"
    Should Be Equal As Integers	${rc}    0
    Log To Console    ${output}
    Should Contain    ${output}    cli finished successfully

Create Suite Log Directory For Sbts
    ${SUITE_LOG_DIRECTORY} =    Catenate    SEPARATOR=${/}    ${OUTPUT_DIR}    ${SUITE NAME}
    ${SUITE_LOG_DIRECTORY}    Replace String    ${SUITE_LOG_DIRECTORY}/    ${SPACE}    _
    Remove Directory    ${SUITE_LOG_DIRECTORY}    True
    Create Directory    ${SUITE_LOG_DIRECTORY}
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}
    Set Suite Variable    ${SAVE LOG DIRECTORY}    ${SUITE_LOG_DIRECTORY}
    Log To Console    \n=====LOG_DIR=${SAVE LOG DIRECTORY}=====

Create Test Log Directory For Sbts
    ${TEST_LOG_DIR}  Catenate    SEPARATOR=${/}  ${OUTPUT_DIR}  ${SUITE NAME}  ${TEST NAME}
    ${TEST_LOG_DIR}  Replace String    ${TEST_LOG_DIR}/    ${SPACE}    _
    Remove Directory    ${TEST_LOG_DIR}    True
    Create Directory    ${TEST_LOG_DIR}
    Set Suite Variable    ${TEST_LOG_DIR}
    Log To Console    \n=====LOG_DIR=${TEST_LOG_DIR}=====
