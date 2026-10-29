*** Settings ***
Documentation    Keywords related to test result reporting to ReP
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin   WITH NAME   admin
Library    python/reporting.py
Library    taf.sw.scout    WITH NAME    scout

Resource    testline.robot
Resource    connect.robot


*** Keywords ***

Online Reporting To ReP
    [Documentation]
    ...    This KW can be used to trigger the reporting of a test case result to Reporting Portal.
    ...
    ...    | tcName     | QC Test Instance name including the instance number (approval version could be omitted) |
    ...    | ..     | e.g. "[1]5GC000510-C_D_UL_open_loop_power_control" |
    ...    | tsResult   | optional argument, if tsResult is omitted robot global variable ${TEST STATUS} is used. |
    ...    |            | possible values: "passed"/"failed"/"PASS"/"FAIL"/"True"/"False" (not case insensitive)  |
    ...    | pmCounters | PM Counters under test |
    ...    | ..     | e.g. "[{'piid': 'M55319C00001', 'result': 'Passed', 'value': 30}, {'piid': 'M55320C00001', 'result': 'Passed', 'value' 30}]" |
    ...    | resultDir  | result directory if it is different from the current one (e.g. for the offline reporting) |
    ...    | isForDebugging | control to omit the communication to the ReP |
    ...    | ..     | possible values: "no", "yes", "true", or "false" (case insensitive) |
    ...    | qcFilePath | path to .qc file starting from "testsuite/.." |
    ...    | gnb_id     | Id/Number of gNB |
    ...    | enb_id     | Id/Number of eNB |
    ...    | swPostFix  | post-fix string for the SW Branch in .qc file, e.g. ASIL_Parity |
    ...    | kpi_results    | KPI under test (list of dictionaries) |
    ...    | ..             | e.g. "[{'target': '800', 'name': 'NR_5094', 'visible_to_db': 'Yes', 'value': '800', 'type': '',
    ...    | ..             |         'description': '5G SA PDCP SDU throughput in downlink', 'category': 'Customer', 'unit': 'Mbit/s'}, ...]" |
    ...
    ...    *Example*
    ...    | online Reporting to ReP | [1]5GC000510-C_D_UL_open_loop_power_control |                 |
    ...    | online Reporting to ReP | [1]5GC000510-C_D_UL_open_loop_power_control | tcResult=passed |
    ...
    ...     *Note*  please see the examples
    ...         Ulm/Common/Examples/reporting_example.robot
    ...         Ulm/Common/Examples/reporting_example.qc
    ...
    [Arguments]  ${tcName}  ${tsResult}=${None}  ${pmCounters}=${EMPTY}  ${resultDir}=${EMPTY}  ${featuresCovered}=${EMPTY}  ${isForDebugging}=No
    ...          ${qcFilePath}=${EMPTY}   ${gnb_id}=0   ${enb_id}=0   ${swPostFix}=${EMPTY}
    ...          ${kpi_results}=${EMPTY}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${enbSwVersion}=   Get ENB SW Version If ENB Is Present   ${enb_id}
    ${gnbSwVersion}=   Get GNB SW Build Version   ${gnb_id}   ${resultDir}
    ${swBuild}=   Construct SW Build From   ${gnbSwVersion}   ${enbSwVersion}   ${resultDir}
    ${testLine}=   Construct Testline From   ${resultDir}
    ${qcInfo}=   Get Info From QC File   ${resultDir}   ${qcFilePath}   ${gnbSwVersion}   ${tcName}   ${swPostFix}
    ${tc_execution_id}=  Get Variable Value  ${SCOUT_EXT_SCF_ID}  SCOUT_EXT_SCF_ID not set
    Report Results To ReP   tcName=${tcName}
    ...                     tc_execution_id=${tc_execution_id}
    ...                     tsResult=${tsResult}
    ...                     swBuild=${swBuild}
    ...                     testLine=${testLine}
    ...                     suitePath=${SUITE SOURCE}
    ...                     qcTestlabPath=${qcInfo}[0]
    ...                     qcTestSetName=${qcInfo}[1]
    ...                     pmCounters=${pmCounters}
    ...                     featuresCovered=${featuresCovered}
    ...                     isForDebugging=${isForDebugging}
    ...                     kpi_results=${kpi_results}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]

Set SCOUT TC ID For Reporting
    [Arguments]    ${node_id}=${0}    ${node_type}=gnb  ${scout_tl_name}=${None}
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Set SCOUT TC ID For Reporting    node_id=${0}    node_type=enb
    ...
    ...     | param node_id       | (default=0) Id/Number of Node (eNB or gNB) |
    ...     | param node_type     | (default=gnb) Node type; possible values: gnb,enb,sran,sbts |
    ...     | param scout_tl_name | default None | if not set scout_tl_name is derived from hostname |

    Set Suite Variable  ${USE_INTERNAL_ID}  FALSE
    ${check1}  Get Variable Value  ${TEST_NAME}  called_in_suite_setup
    IF  $check1 != 'called_in_suite_setup'
        IF  'ute:id:' in '''${TEST_TAGS}'''
            Log  UTE:ID already defined  console=${P_console}
	    ELSE
            Set Suite Variable  ${USE_INTERNAL_ID}  TRUE
        END
    ELSE
        Log  KW called inside suite setup!  level=warn  console=TRUE
        Set Suite Variable  ${USE_INTERNAL_ID}  TRUE
    END

    ${scout_tl_name_is_none}  Run Keyword And Return Status  Should Be Equal  ${scout_tl_name}  ${None}

    IF  ${scout_tl_name_is_none}
        ${scout_tl_name}=  Create SCOUT Testline Name    node_id=${node_id}
        ...                                              node_type=${node_type}
    END
    ${result}=           Run Keyword And Warn On Failure    Request Scout SCF ID    ${scout_tl_name}
    ...                                                                             node_id=${node_id}
    ...                                                                             node_type=${node_type}
    IF  $USE_INTERNAL_ID == 'FALSE' and $result[0] == 'PASS'
        ${id}=  Extract Tc Id From Test Tag
    ELSE
        ${id}=  Set Variable  ${result[1]}
    END
    Set Suite Variable  ${SCOUT_EXT_SCF_ID}  ${id}
    ${TC_ID}=            Set Variable  ute:id:${id}
    IF  $USE_INTERNAL_ID == 'TRUE'
        Set Tags  ${TC_ID}
    END
    RETURN  ${id}

Create SCOUT Testline Name
    [ARGUMENTS]   ${node_id}=${0}   ${node_type}=gnb
    [Documentation]
    ...     Create SCOUT Testline Name
    ...     used inside "Set SCOUT TC ID for Reporting"
    ...
    ...     | param node_id   | (default=0) Id/Number of Node (eNB or gNB) |
    ...     | param node_type | (default=gnb) Node type; possible values: gnb,enb,sran,sbts |
    ...     node_type only valid for former SyVe TLs
    ...
    ${is_ute_tl}  Run Keyword And Return Status  OperatingSystem.File Should Exist  /opt/ute/reservation.json
    IF  ${is_ute_tl}
        ${hostname}=    Evaluate  socket.gethostname()  socket
        ${scout_name}=  string.Replace String  ${hostname}  -  _
    ELSE
        ${tl_name}=     testline.Get Testline Name
        ${node_id}=     Convert To Integer    ${node_id}
        ${scout_name}=  Rename SyVe Testline For SCOUT  ${tl_name}  ${node_id}  ${node_type}
    END
    Log  SCOUT_TL_NAME:${scout_name}  console=${P_console}
    RETURN  ${scout_name}

Rename SyVe Testline For SCOUT
    [ARGUMENTS]  ${tl_name}   ${node_id}=${0}    ${node_type}=gnb
    [Documentation]
    ...    rename TL for scout (necessary in case of SyVe TLs)
    ...     used inside "Set SCOUT TC ID for Reporting"

    ${node_type}    string.Convert To Lowercase     ${node_type}

    IF   "${node_type}"=="gnb"
        ${node_type_Name}   Set Variable  gNB
    ELSE IF    "${node_type}"=="enb"
        ${node_type_Name}   Set Variable  eNB
    ELSE IF    "${node_type}"=="sran"
        ${node_type_Name}   Set Variable  SRAN
    ELSE IF    "${node_type}"=="sbts"
        ${node_type_Name}   Set Variable  sbts
    ELSE
        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb|SRAN|sbts
    END
    ${str}=  Remove String    ${tl_name}    UTE5G
    ${node_id}=    Convert To Integer    ${node_id}
    ${str}=    Set Variable If    "${node_type_Name}"=="SRAN"    ${tl_name}    ${str}_${node_type_Name}${node_id+1}
    RETURN  ${str}

Request Scout SCF ID
    [Arguments]   ${scout_testline_name}    ${node_id}=${0}    ${node_type}=gnb
    [Documentation]
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    ...     used inside "Set SCOUT TC ID for Reporting"

    ${oam_alias}     connect.Setup OAM HTTP Session    node_id=${node_id}   node_type=${node_type}
    ${link_status}   admin.Check Link Status           alias=${oam_alias}
    Log    Setting scout configuration ID: There are ${{ len(${link_status}) }} admin connections     console=${P_console}

    scout.Setup Scout  scout_testline_name=${scout_testline_name}
    Wait Until Keyword Succeeds  5x  10s  Check SCOUT Process Is Running
    ${id}=   scout.Request SCF   use_scout_internal_id=${USE_INTERNAL_ID}
    ...                          timeout=300
    ...                          admin_connect_timeout=300

    scout.Teardown Scout Api
    Log  request_scf with use_scout_internal_id=${USE_INTERNAL_ID}  console=${P_console}
    RETURN   ${id}

Check Scout Process Is Running
    [Documentation]
    ...   internal helper KW to check if scout process is up, expected status is "running"
    ${status}  scout.Get Testline Monitor Status
    Log  admin_cli_status_display: ${status['admin_cli_status_display']}  console=${P_console}
    Should Be Equal  ${status['admin_cli_status_display']}  running

Extract TC Id From Test Tag
    [Documentation]
    ...   internal helper KW to extract testcase id from TEST_TAGS

    ${matches}  Collections.Get Matches              ${TEST_TAGS}    ute:id:*
    @{id}=      String.Split String From Right  ${matches[0]}   :   1

    RETURN  ${id[1]}

