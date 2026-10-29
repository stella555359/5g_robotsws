*** Settings ***
Documentation   Automated Reporter is designed to fetch alternate execution ID from Scout
...             and report it with other execution data to Reporting Portal
...
...             Usage:
...                 1. Fill data.json file in reporter_data directory with your test execution data.
...                 2. Run this script: robot -d <log_path> <path_to_automated_reporter.robot>

Library    Collections
Library    OperatingSystem
Library    taf.sw.scout    WITH NAME    scout
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/manual/automated_reporter.py


*** Variables ***
${DATA_FILE_PATH}                                 ${CURDIR}/reporter_data/
${USE_SCOUT_INTERNAL_ID}                          True
${QC_DOMAIN}                                      MN_RAN
${QC_PROJECT}                                     RAN_ST
${CA}                                             RAN_PZ_WRO_2


*** Test Cases ***
Automated RePo Reporter
    ${file_list}=   List Files In Directory    ${DATA_FILE_PATH}
    FOR   ${file_name}   IN   @{file_list}
          ${dictionary}=   Load Dictionary From JSON File    ${file_name}
          Report Separate Test Case from JSON    ${dictionary}
    END

*** Keywords ***
Report Separate Test Case from JSON
    [Arguments]   ${dictionary}
    FOR   ${test_case}   IN   @{dictionary['test_cases']}
           Report To RePo With Execution ID   ${test_case['scout_testline_name']}   ${test_case['testline_name']}
           ...                                ${test_case['result']}   ${test_case['tc_name']}   ${CA}
           ...                                ${test_case['build']}   ${QC_DOMAIN}
           ...                                ${QC_PROJECT}   ${test_case['qc_id']}
    END

Load Dictionary From JSON File
    [Arguments]   ${file_name}
    ${DATA_VALUES_RAW}   Get File   ${DATA_FILE_PATH}${file_name}
    ${DATA_VALUES}=   evaluate   json.loads('''${DATA_VALUES_RAW}''')   json
    [Return]   ${DATA_VALUES}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=${USE_SCOUT_INTERNAL_ID}
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Report To RePo With Execution ID
    [Arguments]   ${scout_testline_name}   ${testline_name}   ${result}   ${tc_name}
    ...           ${ca}   ${build}   ${qc_domain}   ${qc_project}   ${qc_id}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    Report To RePo   ${tc_name}   ${result}   ${ca}   ${testline_name}   ${build}
    ...              ${qc_domain}   ${qc_project}   ${qc_id}   ${external_scf_id}
