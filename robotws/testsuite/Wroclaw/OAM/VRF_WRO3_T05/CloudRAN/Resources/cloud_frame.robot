*** Settings ***
Documentation    Common VRF_WRO_3_5 keywords and settings

Library    DateTime
Library    Collections
Library    String
Library    OperatingSystem
Library    random

Library    taf.gnb.oam.coam.cu    WITH NAME    vcu_admin
Library    taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library    taf.config.scf    WITH NAME    scf
Library    taf.nms.netact    WITH NAME    nms
Library    taf.sw.reporting_portal    WITH NAME    reporting_portal
Library    ./SyslogParserLibrary.py
Library    ./UPUEOnlineStatusChecker.py
Library    ./ilo_keywords.py
Variables  ./ilo_ip_addresses.yaml
Library    ./time_calculate.py

Resource    ../../../cloud_common_resources/alarms/watchdog.robot
Resource    ../../../cloud_common_resources/alarms/alarms.robot
Resource    ../../../cloud_common_resources/pods_and_containers/pods.robot
Resource    ../../../cloud_common_resources/commissioning/commissioning.robot
Resource    ../../../cloud_common_resources/connections/connections.robot
Resource    ../../../cloud_common_resources/kpi/kpi.robot
Resource    ../../../cloud_common_resources/logs/logs.robot
Resource    ../../../cloud_common_resources/parameters/parameters.robot
Resource    ../../../cloud_common_resources/mantaray/mantaray.robot
Resource    taf/rfrl/cbts/robot/webem_operations.robot

Resource   ./common_vdu.robot
Resource   ./common_vcu.robot
Resource   ./common_variables.robot
Resource   ./common_keywords.robot
Resource   ./common_logging.robot
Resource   ./CellStatus.robot
Resource   ./syslog_download_from_vdu_vcu.robot
Resource   ./Alarm_Injection.robot
Resource   ./Diagnostic_Check_KWs.robot
Resource   ./PM_keywords.robot

*** Keywords ***
Suite Setup
    [Documentation]  Description:    Mandatory KW in [Suite Setup] - preparing test suite parameters & environment for test execution.
    ...              Input:          Type of hardware to initalize - [vCU, vDU, vCU+vDU]
    ...              Output:         None
    ...              Author:         karol.sadowski@nokia.com
    [Arguments]      ${hw_type}=vCU+vDU
    ...              ${default_init_path}=None
    Prompt To Console    Common Suite Setup
    Load Default Init If Not Present    ${default_init_path}
    Create Logs Directory
    Synchronize VM time with ntp server
    IF    '${hw_type}' == 'vCU' or '${hw_type}' == 'vCU+vDU'
       Log To Console    Download initial SCF before suite from vCU...
       Download SCF    scf_path=${LOGS_DIR}/vCU_SCF_before_suite.xml    hw_type=vCU    include_runtime_data=${False}
    END
    IF    '${hw_type}' == 'vDU' or '${hw_type}' == 'vCU+vDU'
       Log To Console    Download initial SCF before suite from vDU...
       Download SCF    scf_path=${LOGS_DIR}/vDU_SCF_before_suite.xml    hw_type=vDU    include_runtime_data=${False}
    END
    Set SW Version    hw_type=${hw_type}

Suite Teardown
    [Documentation]  Description:    Mandatory KW in [Suite Teardown] - post suite execution common actions
    ...              Input:          None
    ...              Output:         None
    ...              Author:         karol.sadowski@nokia.com
    Prompt To Console    Common Suite Teardown
    #TODO: Add copy logs on rotta
#    ${file_name}=    Fetch From Right    ${LOGS_DIR}    /
#    Run    tar -czf /tmp/logs/${file_name}.tar.gz -C ${LOGS_DIR}

TC Setup
    [Documentation]    Description:    Keyword to setup the environment for the test case. Creates test directories,
    ...                                creates connections to vCU and vDU, checks the state of vCU, vDU and RMODs and cells.
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${hw_type}=vCU+vDU
    ...                ${watchdog_enabled}=${False}    #enable watchdog alarm detection

    Prompt To Console    Common Test Setup
    Create Test Results Dir
    Set Test Variable    ${TC_HW_TYPE}    ${hw_type}
    Set Test Variable    ${WATCHDOG_ENABLED}    ${watchdog_enabled}
    IF    '${hw_type}' == 'vCU' or '${hw_type}' == 'vCU+vDU'
        Log To Console    Check vCU state and cell status...
        ${vCU_connection}=   Connect To ADMIN    hw_type=vCU    alias=vCU_TC_connection
        Set Test Variable    ${VCU_CONNECTION}    ${vCU_connection}
        Check vCU state    connection=${VCU_CONNECTION}
        Check Cell States On vCU
        Run Keyword If    ${WATCHDOG_ENABLED}    Log To Console    Enabling Watchdog alarm detection on vCU...
        Run Keyword If    ${WATCHDOG_ENABLED}    Start Watchdog    hw_type=vCU    log_dir=${TEST_RESULTS_DIR}
    END
    IF    '${hw_type}' == 'vDU' or '${hw_type}' == 'vCU+vDU'
        Log To Console    Check vDU state and cell status...
        ${vDU_connection}=   Connect To ADMIN    hw_type=vDU    alias=vDU_TC_connection
        Set Test Variable    ${VDU_CONNECTION}    ${vDU_connection}
        Check vDU And RMOD states    connection=${VDU_CONNECTION}
        Check Cell States On vDU    connection=${VDU_CONNECTION}
        Run Keyword If    ${WATCHDOG_ENABLED}    Log To Console    Enabling Watchdog alarm detection on vDU...
        Run Keyword If    ${WATCHDOG_ENABLED}    Start Watchdog    hw_type=vDU    log_dir=${TEST_RESULTS_DIR}
    END
    Prompt To Console    Starting test case
    Prompt To Console    ${TEST NAME}    type=box

TC Teardown
    [Documentation]    Description:    Keyword to teardown the environment after the test case. Closes vCU and vDU connections,
    ...                                can collect snapshot and container logs if arguments assigned.
    ...                Input:          None
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${skip_logs_collection}=${False}        #skip additional log collection in TC Teardown
    ...                ${skip_recovery_after_fail}=${False}    #skip SCF reupload after fail in test

    Prompt To Console    Common Test Teardown
    Run Keyword If    not ${skip_logs_collection}    Collect Logs
    Run Keyword If    ${FHGW_OBJ}    reporting_portal.Add To Test Data    data={'fhgw_build': '${SW_INFO}[FHGW][sw_version]'}
    reporting_portal.Set Sw Build        sw_build=${SW_INFO}[vDU][sw_version]
    reporting_portal.Add To Test Data    data={'cu_build': '${SW_INFO}[vCU][sw_version]'}
    reporting_portal.Add To Test Data    data={'cu_caas_build': '${SW_INFO}[vCU][ocp_version]'}
    reporting_portal.Add To Test Data    data={'du_caas_build': '${SW_INFO}[vDU][ocp_version]'}
    IF    ('${TC_HW_TYPE}' == 'vCU' or '${TC_HW_TYPE}' == 'vCU+vDU') and ${WATCHDOG_ENABLED}
        Log To Console    Check if Disallowed Alarm was Detected on vCU...
        Run Keyword And Continue On Failure    Check if Disallowed Alarm was Detected during Watchdog    hw_type=vCU
        Stop Watchdog    hw_type=vCU
    END
    IF    ('${TC_HW_TYPE}' == 'vDU' or '${TC_HW_TYPE}' == 'vCU+vDU') and ${WATCHDOG_ENABLED}
        Log To Console     Check if Disallowed Alarm was Detected on vDU...
        Run Keyword And Continue On Failure    Check if Disallowed Alarm was Detected during Watchdog    hw_type=vDU
        Stop Watchdog    hw_type=vDU
    END
    IF    '${TEST STATUS}'=='FAIL' and not ${skip_recovery_after_fail}
        Log To Console    Test case failed! TL recovery started.
        IF    '${TC_HW_TYPE}' == 'vCU' or '${TC_HW_TYPE}' == 'vCU+vDU'
            Log To Console    Restoring vCU configuration...
            Perform SCF Commissioning    hw_type=vCU    scf_path=${LOGS_DIR}/vCU_SCF_before_suite.xml
        END
        IF    '${TC_HW_TYPE}' == 'vDU' or '${TC_HW_TYPE}' == 'vCU+vDU'
            Log To Console    Restoring vDU configuration...
            Perform SCF Commissioning    hw_type=vDU    scf_path=${LOGS_DIR}/vDU_SCF_before_suite.xml
        END
        Wait Until Keyword Succeeds  10m  15s    Check vCU state    connection=${VCU_CONNECTION}
        Wait Until Keyword Succeeds  10m  15s    Check vDU And RMOD states    connection=${VDU_CONNECTION}
        Wait Until Keyword Succeeds  10m  15s    Check Cell States On vDU    connection=${VDU_CONNECTION}
        Log To Console    TL recovery finished
    END
    Run Keyword And Ignore Error    Disconnect from ADMIN    connection=${VCU_CONNECTION}    hw_type=vCU
    Run Keyword And Ignore Error    Disconnect from ADMIN    connection=${VDU_CONNECTION}    hw_type=vDU

Collect Logs
    [Documentation]    Description:    Collects environment logs, including snapshots from vCU and vDU,
    ...                                and optionally from FHGW if defined.
    ...                Input:          None
    ...                Author:         lukasz.lechowicz@nokia.com
    [Arguments]        ${results_directory}=${TEST_RESULTS_DIR}
    Log To Console    Collecting vCU Snapshot
    OperatingSystem.Create Directory  ${results_directory}/vCU/
    OperatingSystem.Create Directory  ${results_directory}/vDU/
    Run Keyword And Continue On Failure    vcu_admin.Get Local Snapshot
    ...    directory=${results_directory}/vCU/    connection=${VCU_CONNECTION}    compressed=${True}
    Log To Console    Collecting vDU Snapshot
    Run Keyword And Continue On Failure    vdu_admin.Get Local Snapshot
    ...    directory=${results_directory}/vDU/    vdu_connection=${VDU_CONNECTION}   compressed_or_not=${True}
    IF    ${FHGW_OBJ}
        Log To Console    Collecting FHGW Snapshot
        Collect FHGW Snapshot    local_dir=${results_directory}
    END

Load Default Init If Not Present
    [Documentation]    Description:    Checks if tl variable is avaliable and if not, imports default init file.
    ...                Input:          path to init file
    ...                Author:         karol.sadowski@nokia.com
    [Tags]             robot:no-dry-run
    [Arguments]        ${default_init_path}
    ${is_init_loaded}=    Run Keyword And Return Status    Variable Should Exist    ${tl}
    Run Keyword If    '${is_init_loaded}'=='False' and '${default_init_path}'!='None'
    ...                Import Variables    ${default_init_path}
    ...   ELSE IF     '${is_init_loaded}'=='False' and '${default_init_path}'=='None'
    ...                Fail    msg=Make sure that the path to the init file is correct!
    ...   ELSE         Log To Console    Init file already provided!
    Import Resource    taf/rfrl/cbts/utilities/init_variables.robot

Check vCU state
    [Documentation]    Description:    Checks the condition of vCU - operational state, AMF link status,
    ...                                F1 link status to vDU
    ...                Input:          vcu_connection object
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${connection}=${vcu_connection}

    FOR    ${iteration_check}    IN RANGE    ${1}    ${4}
        ${vcu_state}=    Wait Until Keyword Succeeds  2m  5s    vcu_admin.Get Cu State    connection=${connection}
        IF    '${vcu_state["operational_state"]}' != 'None'
            Exit For Loop
        ELSE
            Sleep    30s
        END
    END
    Log    vCU operational state is "${vcu_state["operational_state"]}"    console=${True}
    Should Be Equal As Strings    ${vcu_state["operational_state"].lower()}    enabled
    ${amfs}=    Get From Dictionary    ${vcu_state}    amfs
    ${is_any_amf_active}=    Set Variable    ${False}
    FOR    ${amf}    IN    @{amfs}
        IF   '${amf["ng_link_status"].lower()}' == 'active'
            ${is_any_amf_active}=    Set Variable    ${True}
        END
        Log    AMF ${amf["name"]} link status is "${amf["ng_link_status"]}"    console=${True}
    END
    Should Be True    ${is_any_amf_active}    msg=Connection to AMF is not active
    ${vdu_summary}=    vcu_admin.Get Du State    connection=${connection}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${vdu_summary["f1_link_status"]["unavailable"]}    0
    ...    Some F1 links are unavailable!
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${vdu_summary['administrative_state']["locked"]}    0
    ...    Some vDUs are locked!

Check vDU And RMOD states
    [Documentation]    Description:    Checks the condition of vDU - operational state, F1-C link status,
    ...                                availability of connected RMODs.
    ...                Input:          vdu_connection object
    ...                                path to vDU SCF file
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${connection}=${vdu_connection}

    ${vdu_state}=    vdu_admin.Get Vdu State Data    vdu_connection=${connection}
    ${vdu_rmods_summary}=    vdu_admin.Get Rmods Summary    vdu_connection=${connection}
    Log    F1-C link status is "${vdu_state["f1_c_link_status_du"]}"    console=${True}
    Should Be Equal As Strings    ${vdu_state["f1_c_link_status_du"].lower()}    available
    Log    vDU operational state is "${vdu_state["operational_state"]}"    console=${True}
    Should Be Equal As Strings    ${vdu_state["operational_state"].lower()}    onair
    Should Be Equal As Numbers    ${vdu_rmods_summary['administrative_state']['locked']}     0
    Should Be Equal As Numbers    ${vdu_rmods_summary['operational_state']['disabled']}      0
    Should Be Equal As Numbers    ${vdu_rmods_summary['availability_status']['degraded']}    0
    Should Be Equal As Numbers    ${vdu_rmods_summary['availability_status']['off_line']}    0
    ${online_rmods}=    Set Variable    ${vdu_rmods_summary['availability_status']['on_line']}
    Log    Detected ${online_rmods} RMODs online    console=${True}

Check Cell States On vDU
    [Documentation]    Description:    Checks the condition of cells on vDU - operational state, administrative state, availability status.
    ...                                Number of online cells is compared to the total number of cells from scf.
    ...                Input:          vdu_connection object
    ...                                path to vDU SCF file
    ...                Author:         damian.kotula@nokia.com
    [Arguments]    ${connection}=${vdu_connection}

    ${vdu_cells_summary}=    vdu_admin.Get Vdu Cells Summary    vdu_connection=${connection}
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}    0
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['administrative_state']['locked']}    0
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}    0
    ${online_cells}=    Set Variable    ${vdu_cells_summary['availability_status']['on_line']}
    Log    Detected ${online_cells} Cells online on vDU    console=${True}

Check Cell States On vCU
    [Documentation]    Description:    Checks the condition of cells on vCU - operational state and administrative state.
    ...                                Number of online cells is compared to the total number of cells from scf.
    ...                Input:          vcu_connection object
    ...                                path to vCU SCF file
    ...                Author:         damian.kotula@nokia.com
    [Arguments]    ${connection}=${vcu_connection}
    ${vcu_cells_summary}=    vcu_admin.Get Cells Summary    connection=${connection}
    Should Be Equal As Numbers    ${vcu_cells_summary['basic_cells_summary']['operational_state']['disabled']}    0
    Should Be Equal As Numbers    ${vcu_cells_summary['basic_cells_summary']['administrative_state']['locked']}    0
    Should Be Equal As Numbers    ${vcu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}    0
    ${online_cells}=    Set Variable    ${vcu_cells_summary['basic_cells_summary']['operational_state']['enabled']}
    Log To Console    Detected ${online_cells} Cells online on vCU

Modify Resource Search Order
    [Documentation]    Adjust Robot's library search order for the Robot-based (as opposed to JSON-based)
    ...    test sets. The KW adds a new entry at the end of the search order list (to retain search order defined
    ...    in TC Setup). To be used in [Setup] section as follows (presented here in a convenient tabular form):
    ...    [Setup] | Run Keywords | res_name.TC Setup | AND | Modify Resource Search Order | res_name
    ...    in pair with `Restore Resource Search Order` in [Teardown]:
    ...    [Teardown] | Run Keywords | res_name.TC Teardown | AND | Restore Resource Search Order
    ...    Non-existing resurces (`dummy_resource_name`) are ignored.
    [Tags]  robot:no-dry-run
    [Arguments]    ${resource_name}
    ${dummy_search_order}=    Create List    dummy_resource_name
    ${search_order}=   Set Library Search Order
    ${ORIGINAL_SEARCH_ORDER}=    Set Variable If    len(${search_order})    ${search_order}    ${dummy_search_order}
    Set Test Variable    ${ORIGINAL_SEARCH_ORDER}
    Set Library Search Order    ${resource_name}    @{search_order}

Restore Resource Search Order
    [Documentation]    To be used in pair with `Modify Resource Search Order`
    [Tags]  robot:no-dry-run
    ${search_order}=    Create List    @{ORIGINAL_SEARCH_ORDER}
    Remove Values From List    ${search_order}    dummy_resource_name
    Set Library Search Order   @{search_order}

Synchronize VM time with ntp server
    [Documentation]    Sync VM Time with same ntp server used on cBTS.
    Log To Console    Synchronize VM time with ntp server...
    Run    sudo service ntp stop
    ${output}=    Run    sudo ntpdate 10.42.248.70
    Run    sudo service ntp start
    Log To Console     ${output}

Create Logs Directory
    [Documentation]  Description:    Creates a directory for logs and sets a suite variable.
    ...              Input:          text to display, line width, and display type (line, box)
    ...              Output:         None
    ...              Author:         karol.sadowski@nokia.com
    #TODO: Check if extradisk folder available on VM
    ${logs_timestamp}=    DateTime.Get Current Date    result_format=%Y-%m-%d_%H-%M-%S    exclude_millis=True
    ${logs_path}=    OperatingSystem.Join Path    ${OUTPUT DIR}    ${logs_timestamp}_${SUITE NAME}
    Create Directory    ${logs_path}
    Set Suite Variable    ${LOGS_DIR}    ${logs_path}
    Log To Console   'LOGS DIR' created: ${LOGS_DIR}

Create Test Results Dir
    [Documentation]  Description:    Creates a directory under LOGS_DIR for test results and sets a test variable.
    ...              Input:          text to display, line width, and display type (line, box)
    ...              Output:         None
    ...              Author:         karol.sadowski@nokia.com
    ${test_results_path}=    OperatingSystem.Join Path    ${LOGS_DIR}    ${TEST NAME}
    Create Directory    ${test_results_path}
    Set Test Variable    ${TEST_RESULTS_DIR}    ${test_results_path}
    Log To Console   'TEST RESULTS DIR' created: ${TEST_RESULTS_DIR}

Prompt To Console
    [Documentation]  Description:    Prints a message to the console with given format.
    ...              Input:          text to display, line width, and display type (line, box)
    ...              Output:         <print to console>
    ...              Author:         karol.sadowski@nokia.com
    [Arguments]      ${message}    ${width}=78    ${type}=line
        IF    '${type}'=='line'
            ${print_string}=    Format String	{:*^${width}}	   ***${SPACE}${message}${SPACE}***
            Log To Console    ${\n}${\n}${print_string}
        ELSE IF    '${type}'=='box'
            ${msg_len}=    Get Length    ${message}
            ${width}=    Run Keyword If    ${msg_len}>${width}    Evaluate    ${msg_len}+6
            ...    ELSE     Set Variable     ${width}
            ${separator}=    Evaluate    '='*${width}
            ${row_len}=    Evaluate    ${width}-4
            ${print_string}=    Format String	{:${SPACE}^${row_len}}	   ${SPACE}${message}${SPACE}
            Log To Console    ${separator}
            Log To Console    = ${print_string} =
            Log To Console    ${separator}
        ELSE
            Log To Console    ${message}
        END

Set SW Version
    [Documentation]  Description:    Set global suite variable SW version for vCU, vDU, vCU+vDU or FHGW
    ...              Input:          Type of hardware to initalize - [vCU, vDU, vCU+vDU, FHGW]
    ...              Output:         Dict: {vCU: {} , vDU: {}, FHGW: {}} with dict values {sw_version, release, is_trunk, ocp_version} for vCU
    ...                              {sw_version, release, is_trunk, ocp_version, rannic_version, nokia_sync_version} for vDU
    ...                              and {sw_version, release} for FHGW
    ...              Author:         karol.sadowski@nokia.com
    [Arguments]      ${hw_type}

    &{vCU_info}=    Create Dictionary    sw_version=-    release=-    is_trunk=-    ocp_version=-
    &{vDU_info}=    Create Dictionary    sw_version=-    release=-    is_trunk=-    ocp_version=-    rannic_version=-    nokia_sync_version=-
    &{FHGW_info}=   Create Dictionary    sw_version=-    release=-

    IF    '${hw_type}'=='vCU' or '${hw_type}'=='vCU+vDU'
        ${sw_version}    ${release}    ${is_trunk}=    Get Software Version    hw_type=vCU
        ${ocp_version}=    Get OCP Version   hw_type=vCU
        Set To Dictionary    ${vCU_info}    sw_version=${sw_version}    release=${release}    is_trunk=${is_trunk}    ocp_version=${ocp_version}
    END
    IF    '${hw_type}'=='vDU' or '${hw_type}'=='vCU+vDU'
        ${sw_version}    ${release}    ${is_trunk}=    Get Software Version    hw_type=vDU
        ${ocp_version}=    Get OCP Version   hw_type=vDU
        ${rannic_version}=    Get Rannic Version    vDU
        ${nokia_sync_version}=    Get Nokia Sync Version    vDU
        Set To Dictionary    ${vDU_info}    sw_version=${sw_version}    release=${release}    is_trunk=${is_trunk}    ocp_version=${ocp_version}
        ...    rannic_version=${rannic_version}    nokia_sync_version=${nokia_sync_version}

        IF    ${FHGW_OBJ}
            ${sw_version}    ${release}=    Get Software Version    hw_type=FHGW
            Set To Dictionary    ${FHGW_info}    sw_version=${sw_version}    release=${release}
        END
    END


    ${sw_info}=    Create Dictionary    vCU=${vCU_info}    vDU=${vDU_info}    FHGW=${FHGW_info}
    Set Suite Variable    ${sw_info}    ${SW_INFO}

    Prompt To Console    SW Version    width=62
    Log To Console    *    format=*^62
    Log To Console    ${SPACE*4}vCU:    format=.<27   no_newline=True
    Log To Console    ${SW_INFO}[vCU][sw_version]     format=${SPACE}<20
    Log To Console    ${SPACE*4}release:    format=.<27    no_newline=True
    Log To Console    ${SW_INFO}[vCU][release]     format=${SPACE}<20
    Log To Console    ${SPACE*4}OCP version:    format=.<27   no_newline=True
    Log To Console    ${SW_INFO}[vCU][ocp_version]     format=${SPACE}<20
    Log To Console    -    format=-^62
    Log To Console    ${SPACE*4}vDU:    format=.<27   no_newline=True
    Log To Console    ${SW_INFO}[vDU][sw_version]     format=${SPACE}<20
    Log To Console    ${SPACE*4}release:    format=.<27    no_newline=True
    Log To Console    ${SW_INFO}[vDU][release]     format=${SPACE}<20
    Log To Console    ${SPACE*4}OCP version:    format=.<27   no_newline=True
    Log To Console    ${SW_INFO}[vDU][ocp_version]     format=${SPACE}<20
    Log To Console    ${SPACE*4}Rannic version:    format=.<27   no_newline=True
    Log To Console    ${SW_INFO}[vDU][rannic_version]     format=${SPACE}<20
    Log To Console    ${SPACE*4}Nokia-sync version:    format=.<27   no_newline=True
    Log To Console    ${SW_INFO}[vDU][nokia_sync_version]     format=${SPACE}<20
    Log To Console    -    format=-^62
    IF    ${FHGW_OBJ}
        Log To Console    ${SPACE*4}FHGW:    format=.<27   no_newline=True
        Log To Console    ${SW_INFO}[FHGW][sw_version]     format=${SPACE}<20
        Log To Console    ${SPACE*4}release:    format=.<27    no_newline=True
        Log To Console    ${SW_INFO}[FHGW][release]     format=${SPACE}<20
    ELSE
        Log To Console    ${SPACE*4}NO FHGW is defined in __init__.py file    format=${SPACE}<20
    END
    Log To Console    *    format=*^50

Map Nesc Rotta Network Drive
    [Documentation]  Description:    Mounts external NescRotta server to given folder
    ...              Input:          local_path - path where NescRotta will be mounted
    ...              Output:         None
    ...              Author:         karol.sadowski@nokia.com
    [Arguments]      ${password}=Wro5pass!    ${username}=lopm    ${network_path}=//nescrotta.nesc.nokia.net/rotta
    ...              ${local_path}=/home/ute/NescRotta    ${domain}=NSN-INTRA
    ${catenate_cmd}=    Catenate    SEPARATOR=

    ...    sudo mkdir -p '${local_path}';sudo mount -t cifs -o noperm,auto,rw,vers=3.0,
    ...    username='${username}',password='${password}',domain='${domain}',users,nounix ${network_path} ${local_path}
    ${rc}    ${output}=    Run And Return Rc And Output    ${catenate_cmd}
    Run Keyword If    ${rc}==${0}    Log To Console      NescRotta Mapped into: ${local_path}
    ...    ELSE     Log To Console      NescRotta not mounted, error: ${rc}\n${output}

Copy Logs To NescRotta
    [Documentation]  Description:    Copy given directory to NescRotta server
    ...              Input:          local_path - path where NescRotta will be mounted
    ...                              QC_project & QC_location - QC values related with output dir
    ...                              logs_path - location of logs to copy
    ...              Output:         None
    ...              Author:         karol.sadowski@nokia.com
    [Arguments]      ${logs_dir}=${LOGS_DIR}    ${local_path}=/home/ute/NescRotta
    ...    ${QC_project}=RAN_VRF    ${QC_location}=VRF_WRO3/VRF_WRO3_T05/CRT/CBRS

    ${rotta_available}=    Run Keyword and Return Status    OperatingSystem.Directory Should Exist    ${local_path}
    Run Keyword If    ${rotta_available}==False
    ...               Map Nesc Rotta Network Drive
    ${release}=       Fetch From Right    ${SOFTWARE_VERSION}    SBTS
    ${logs_dir}=      Set Variable If    ${IS_TRUNK}==False
    ...               /home/ute/NescRotta/MN_RAN/${QC_project}/${release}/Regression/${QC_location}/
    ...               ${IS_TRUNK}==True
    ...               /home/ute/NescRotta/MN_RAN/${QC_project}/Trunk/${QC_location}/
    ${source_dir}=    Get Regexp Matches    ${SUITE_LOGS_DIR_PATH}    ^(.*?)//?$    1
    Copy Directory    ${source_dir}[0]    ${logs_dir}
    Log to console    Copied logs from: ${SUITE_LOGS_DIR_PATH} ${\n}into: ${logs_dir}

Create Results File
    [Documentation]  Description:    Creates txt file with test results and SW versions in TEST_RESULTS_DIR.
    ...              Input:          test_results - list with results to print in Test Results section of file.
    ...                              average_results - list with averages to print in Average Result(s) section of file.
    ...                              target_values - list with targets to print in Target Value(s) section of file.
    ...              Output:         None
    ...              Author:         damian.kotula@nokia.com
    [Arguments]    ${test_results}     ${average_results}    ${target_values}
    Create File     ${TEST_RESULTS_DIR}/results.txt     content=${TEST_NAME}\n
    ${results_file}    Set Variable      ${TEST_RESULTS_DIR}/results.txt
    Append To File    ${results_file}    \nSW Builds:\n
    Append To File    ${results_file}    vCU: ${SW_INFO}[vCU][sw_version]\n
    Append To File    ${results_file}    vCU OCP version: ${SW_INFO}[vCU][ocp_version]\n
    Append To File    ${results_file}    vDU: ${SW_INFO}[vDU][sw_version]\n
    Append To File    ${results_file}    vDU OCP version: ${SW_INFO}[vDU][ocp_version]\n
    Append To File    ${results_file}    FHGW: ${SW_INFO}[FHGW][sw_version]\n
    Append To File    ${results_file}    RAN NIC build: ${SW_INFO}[vDU][rannic_version]\n
    Append To File    ${results_file}    Nokia Sync build: ${SW_INFO}[vDU][nokia_sync_version]\n
    Append To File    ${results_file}    \nTest Results:\n
    FOR    ${result}    IN    @{test_results}
        Append To File    ${results_file}    ${result}\n
    END
    Append To File    ${results_file}    \nAverage Result(s):\n
    FOR    ${average}    IN    @{average_results}
        Append To File    ${results_file}    ${average}\n
    END
    Append To File    ${results_file}    \nTarget Value(s):\n
    FOR    ${target_value}    IN    @{target_values}
        Append To File    ${results_file}    ${target_value}\n
    END

Report KPI result to QC
    [Documentation]  Description:    Creates txt file with test results and SW versions in TEST_RESULTS_DIR.
    ...              Input:          name - KPI name i.e. KPI_16a
    ...                              value - current KPI value
    ...                              target - KPI target value
    ...                              unit - value unit, default s
    ...              Output:         None
    ...              Author:         karol.sadowski@nokia.com
    [Arguments]    ${name}    ${value}    ${target}    ${unit}=s
    ${rounded_value}=    Evaluate    round(float(${value}),1)
    reporting_portal.Report Kpi Results
    ...    target=${target}
    ...    name=${name}
    ...    visible_to_db=False
    ...    value=${rounded_value}
    ...    kpi_type=OAMKPI
    ...    description=OAMKPI
    ...    category=OAMPKI
    ...    unit=${unit}

Round KPI Value
    [Documentation]  Description:    Rounds KPI value to 1st decimal place.
    ...              Input:          value to round
    ...              Output:         rounded value
    ...              Author:         karol.sadowski@nokia.com
    [Arguments]    ${kpi}
    ${rounded_kpi}=    Evaluate    round(float(${kpi}),1)
    [Return]    ${rounded_kpi}
