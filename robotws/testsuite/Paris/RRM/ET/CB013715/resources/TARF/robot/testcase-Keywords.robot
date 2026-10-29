*** Settings ***

Documentation     Keywords for TestCase

Library     OperatingSystem
Library     String

# Libraries SWENG
Library      ../../../../../../resources/SWENG/python/StringTool.py

# Libraries Features
Library      ../python/tools.py              WITH NAME          nps_TC_tools

*** Keywords ***

Create Test Suite Folder
    [Documentation]    create test suite folder
    [Arguments]    ${with_timestamp}=${FALSE}
    ${timeStamp}    get current date    result_format=%Y%m%d_%H%M%S
    ${SUITE_NAME}    Replace String    ${SUITE_NAME}    ${SPACE}    _
    ${testSuiteDir}    set variable if    '${with_timestamp}'=='${TRUE}'   ${LOG_PATH}/${SUITE_NAME}/${timeStamp}
    ...                                                                    ${LOG_PATH}
    Set Suite Variable    ${testSuiteDir}
    Run Keyword if    '${with_timestamp}'=='${TRUE}'     create directory    ${testSuiteDir}


Create Test Suite Log Directory
    [Documentation]
    ...    Creates global Logs directory for the running test suite.
    ...    Naming rule: ${LOG_PATH}/LogsSuiteTest
    ...    legacy: return should not be used
    ...
    ...    *Scope*  Internal
    ...
    Set Suite Variable   ${P_resultSuiteLogDir}   ${LOG_PATH}/LogsSuiteTest
    OperatingSystem.Create Directory   ${P_resultSuiteLogDir}
    [Return]   ${P_resultSuiteLogDir}

Get Test Suite Log Directory
    [Documentation]
    ...    Returns path for TestSuite log directory,
    ...    if Testsuite Log directory does not exist it will created automatically.
    ...
    ...    *Returns* Path for TestSuite log folder
    ...
    ${P_resultSuiteLogDir}   Get Variable Value   ${P_resultSuiteLogDir}
    Run Keyword If   '${P_resultSuiteLogDir}'=='None'
    ...    Create Test Suite Log Directory
    [Return]   ${P_resultSuiteLogDir}

Create Test Case Folder
    [Documentation]    create test case folder
    ${testCaseDir}    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${testCaseDir}    nps_TC_tools.filter_non_printable_and_remove_head    ${testCaseDir}
    ${testCaseDir}    Replace String    ${testCaseDir[0:30]}    ${SPACE}    _
    ${testCaseDir}    Replace String    ${testCaseDir}    .    _
    Dated log       Create Test Case Folder ${testSuiteDir}/${testCaseDir}
    Set Suite Variable    ${testCaseDir}    ${testSuiteDir}/${testCaseDir}
    Create Directory    ${testCaseDir}

Get testcase log directory
    [Documentation]    :Author: Ch SAMSON
    ...    Retuns path for Testcase log directory
    ...    If Testcase Log directory does not exist it will created automatically
    ...
    ...    :returns: Path for Testcase log
    ...
    ${P_resultTestDir}=    Get Variable Value    ${testCaseDir}
    Run Keyword If    '${P_resultTestDir}'=='None'
    ...    testcase-Keywords.Create Test Case Folder
    ${P_resultTestDir} =    Get Variable Value   ${testCaseDir}
    [Return]    ${P_resultTestDir}

Prepare Test Name
    [Documentation]    :Author: Ch SAMSON
    ...    Retuns formated test name
    ...
    ...    :returns: formated test name
    ...
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set test variable      ${TEST_NAME}
    [Return]    ${TEST_NAME}

Prepare Logs Directory Path
    [Arguments]    ${resultDir}=None   ${subdir}=${EMPTY}    ${with_timestamp}=${FALSE}
    [Documentation]
    ...    Creates directory for storing logs, based on current execution context.
    ...    An absolute path to created directory is returned.
    [Tags]    PRIVATE
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${subdir}    set variable if    '${with_timestamp}'=='${TRUE}'   ${subdir}_${timestamp}
    ...                                                              ${subdir}
    ${resultDir}=    Run Keyword If    '${resultDir}'=='None'    testcase-Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${resultDir}
    ${logs_dir}   set variable     ${resultDir}/${subdir}
    OperatingSystem.Create Directory    ${logs_dir}
    [Return]    ${logs_dir}

Get Testline Name
    StringTool.printLineWithTitle   title=Get Testline Name
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${mgs}=  StringTool.getHeaderLine    Testline Name:  ${testline_name}
    dated log     ${mgs}
    ${mgs}=   StringTool.getHeaderLine    Testline init file is   /home/ute/testline_configuration/${testline_name}/
    dated log     ${mgs}
    Set Suite Metadata    Testline Name    ${testline_name}
    Set global variable   ${testline_name}
    ${file_scout_config}    set variable    /home/ute/testline_init_results/agent_scout/results/config_files/scout.conf
    ${file_scout_config_exist}=    Run Keyword And Return Status    OperatingSystem.file_should_exist    ${file_scout_config}
    ${mgs}=   run Keyword If    ${file_scout_config_exist}     StringTool.getHeaderLine   scout.conf is   ${file_scout_config}
    ...             ELSE                                       StringTool.getHeaderLine   scout.conf is   WARNING!! scout.conf NOT PRESENT!!!
    dated log     ${mgs}
    IF     not ${file_scout_config_exist}
        BuiltIn.log     WARNING!! ${file_scout_config} NOT PRESENT!!!     level=WARN    console=yes
    END
    # add here some info about  UTE TL
    ${reserve_file}=    Set Variable     /opt/ute/reservation.json
    ${file_exist}=    Run Keyword And Return Status    OperatingSystem.file_should_exist    ${reserve_file}
    ${cmd}=   run Keyword if   "${file_exist}"=="True"    Catenate
    ...                                           python -c 'import json;print(json.load(open("${reserve_file}"))["topology"])'
    ${ret}    ${ret_cmd}=       run Keyword if   "${file_exist}"=="True"       OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${mgs}=     run Keyword if   "${file_exist}"=="True"      StringTool.getHeaderLine          Topology is   ${ret_cmd}
    run Keyword if   "${file_exist}"=="True"      Set Suite Metadata    Topo [reservation.json]    ${ret_cmd}
    run Keyword if   "${file_exist}"=="True"      dated log     ${mgs}
    ${cmd}=   run Keyword if   "${file_exist}"=="True"    Catenate
    ...                                           python -c 'import json;print(json.load(open("${reserve_file}"))["user"])'
    ${ret}    ${ret_cmd}=       run Keyword if   "${file_exist}"=="True"       OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${mgs}=   run Keyword if   "${file_exist}"=="True"    StringTool.getHeaderLine       user is   ${ret_cmd}
    run Keyword if   "${file_exist}"=="True"     dated log     ${mgs}
    ${cmd}=   run Keyword if   "${file_exist}"=="True"    Catenate
    ...                                           python -c 'import json;print(json.load(open("${reserve_file}"))["enb_build"])'
    ${ret}    ${ret_cmd}=       run Keyword if   "${file_exist}"=="True"       OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${mgs}=   run Keyword if   "${file_exist}"=="True"     StringTool.getHeaderLine       enb_build is   ${ret_cmd}
    run Keyword if   "${file_exist}"=="True"      dated log    ${mgs}
    StringTool.printLineWithTitle   title=-
    [return]    ${testline_name}

Get Testline Name based hostname
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    [return]    ${testline_name}
