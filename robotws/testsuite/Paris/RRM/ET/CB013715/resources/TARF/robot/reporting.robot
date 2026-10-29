*** Settings ***
Documentation    Keywords related to test result reporting to ReP
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    ../python/reporting.py
Library    ../../../../resources/DSS/python/robot_extension.py     WITH NAME    robot_extension

Library    taf.sw.scout    WITH NAME    scout

Resource      testline-Keywords.robot
Resource      testcase-Keywords.robot
Resource      Test-Suite-Setup-Resources-Keywords.robot

*** Keywords ***

Online Reporting to ReP
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
    ...
    ...    *Example*
    ...    | online Reporting to ReP | [1]5GC000510-C_D_UL_open_loop_power_control |                 |
    ...    | online Reporting to ReP | [1]5GC000510-C_D_UL_open_loop_power_control | tcResult=passed |construct SW BUILD from
    ...
    ...     *Note*  please see the examples
    ...         Ulm/Common/Examples/reporting_example.robot
    ...         Ulm/Common/Examples/reporting_example.qc
    ...
    [Arguments]  ${tcName}  ${tsResult}=${None}  ${pmCounters}=${EMPTY}  ${resultDir}=${EMPTY}  ${featuresCovered}=${EMPTY}  ${isForDebugging}=No
    ...          ${qcFilePath}=${EMPTY}   ${gnb_id}=0   ${enb_id}=0   ${swPostFix}=${EMPTY}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${enbSwVersion}=   reporting.get_enb_sw_version_if_enb_is_present   ${enb_id}
    ${gnbSwVersion}=   reporting.get_gnb_sw_build_version   ${gnb_id}   ${resultDir}
    ${swBuild}=   reporting.construct_sw_build_from   ${gnbSwVersion}   ${enbSwVersion}   ${resultDir}
    ${testLine}=   reporting.construct_testline_from   ${resultDir}
    ${qcInfo}=   reporting.get_info_from_qc_file   ${resultDir}   ${qcFilePath}   ${gnbSwVersion}   ${tcName}   ${swPostFix}
    ${tc_execution_id}=  get variable value  ${SCOUT_EXT_SCF_ID}  0815
    report Results to ReP   tcName=${tcName}
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
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]

Set SCOUT TC ID for Reporting
    [Arguments]    ${node_id}=${0}    ${node_type}=gnb
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Set SCOUT TC ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb,enb,sran |

    set suite variable  ${use_internal_id}  FALSE
    ${check1}  get variable value  ${TEST_NAME}  called_in_suite_setup
    IF  '${check1}' != '''called_in_suite_setup'''
        IF  'ute:id:' in '''${TEST_TAGS}'''
            BuiltIn.Log to console  UTE:ID already defined
	    ELSE
            set suite variable  ${use_internal_id}  TRUE
        END
    ELSE
        BuiltIn.Log  KW called inside suite setup!  level=warn  console=TRUE
        set suite variable  ${use_internal_id}  TRUE
    END

    ${scout_tl_name}=  Create SCOUT Testline Name    node_id=${node_id}
    ...                                              node_type=${node_type}

    ${result}=     robot_extension.Run Keyword And Warn On Failure    reporting.Request Scout SCF ID    ${scout_tl_name}
    run keyword if    '${result[0]}'=='FAIL'    BuiltIn.log    reporting.Request Scout SCF ID ${result[0]}! reason is ${result[1]}
    ...                                                        level=ERROR    console=True
    ${internal_scf_id}=  Set Variable if  '${result[0]}'=='PASS'  ${result[1]}  08154711
    ${TC_ID}=            Set Variable    ute:id:${internal_scf_id}

    IF  '${use_internal_id}' == '''TRUE'''
        Set Tags  ${TC_ID}
    END

    [RETURN]  ${internal_scf_id}

Create SCOUT Testline Name
    [ARGUMENTS]   ${node_id}=${0}   ${node_type}=gnb
    [Documentation]
    ...     Create scout testline name
    ...     used inside "Set SCOUT TC ID for Reporting"
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb,enb,sran |
    ...     node_type only valid for former SyVe TLs
    ...
    ${is_ute_tl}  run keyword and return status  file should exist  /opt/ute/reservation.json
    IF  ${is_ute_tl}
        ${hostname}=    Evaluate  socket.gethostname()  socket
        ${scout_name}=  string.replace string  ${hostname}  -  _
    ELSE
        ${tl_name}=     testcase-Keywords.Get Testline Name based hostname
        ${node_id}=     Convert To Integer    ${node_id}
        ${scout_name}=  Rename SyVe Testline for SCOUT  ${tl_name}  ${node_id}  ${node_type}
    END
    BuiltIn.log to console  SCOUT_TL_NAME:${scout_name}
    [RETURN]  ${scout_name}

Rename SyVe Testline for SCOUT
    [ARGUMENTS]  ${tl_name}   ${node_id}=${0}    ${node_type}=gnb
    [Documentation]
    ...    rename TL for scout (necessary in case of SyVe TLs)
    ...     used inside "Set SCOUT TC ID for Reporting"

    ${node_type}    string.Convert To Lowercase     ${node_type}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE IF     "${node_type}"=="sran"                  Set Variable  SRAN
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb|SRAN
    ${str}=  Remove String    ${tl_name}    UTE5G
    ${node_id}=    Convert To Integer    ${node_id}
    ${str}=    Set Variable If    "${node_type_Name}"=="SRAN"    ${tl_name}    ${str}_${node_type_Name}${node_id+1}
    [RETURN]  ${str}

Request Scout SCF ID
    [Arguments]   ${scout_testline_name}
    [Documentation]
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    ...     used inside "Set SCOUT TC ID for Reporting"

    scout.setup_scout  scout_testline_name=${scout_testline_name}

    ${internal_scf_id}=   scout.request_scf   use_scout_internal_id=${use_internal_id}    timeout=60

    ${id}=  run keyword if   '${use_internal_id}' != '''TRUE'''
    ...        get internal id
    ...   ELSE
    ...        set variable  ${internal_scf_id}

    set suite variable  ${SCOUT_EXT_SCF_ID}  ${id}

    scout.teardown_scout_api
    BuiltIn.log to console  request_scf with use_scout_internal_id=${use_internal_id} PASSED
    [Return]   ${id}

Get internal id
    [Documentation]
    ...   internal helper KW to extract testcase id from TEST_TAGS

    ${matches}  get matches              ${TEST_TAGS}    ute:id:*
    @{id}=      split string from right  ${matches[0]}   :   1

    [Return]  ${id[1]}

