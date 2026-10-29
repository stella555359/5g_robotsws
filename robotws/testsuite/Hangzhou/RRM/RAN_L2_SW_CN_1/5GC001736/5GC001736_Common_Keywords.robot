*** Settings ***
# Library           ${CURDIR}/handle_csv1.py
Resource    ../CUDU_L2/common_setup_teardown.robot

*** Keywords ***
Tti Decode To Csv
    OperatingSystem.Run    mkdir ${test_log_directory}/snapShot_gnb
    OperatingSystem.Run    unzip -d ${test_log_directory}/snapShot_gnb ${test_log_directory}/snapShot_gnb.zip
    Sleep    5s
    OperatingSystem.Run    cp ${test_log_directory}/snapShot_gnb/${tti_dat_file_name} ${test_log_directory}
    OperatingSystem.Run    cp ${tti_decode_py_path}/* ${test_log_directory}
    OperatingSystem.Run    chmod -R 777 ${test_log_directory}
    ${success_msg}    Set Variable    Converting finished
    Process.Start Process    python3 ./L2TraceDecodeToCSV.py 5G_${sw_version_total} ${tti_dat_file_name}    shell=True    cwd=${test_log_directory}
    ...    stdout=${tempdir}/start_stdout.txt
    Wait Until Keyword Succeeds    2min    10s    Check Suscess Msg Exist    ${tempdir}${/}start_stdout.txt    ${success_msg}

Check A2A
    [Arguments]    ${case_name}
    ${ret}    Read Csv Columns    ${test_log_directory}/${tti_csv_file_name}    dataVolumeSent
    ${num}    Evaluate    len(${ret})-${ret}.count(0)
    ${check_num}    Evaluate    int(${num}*0.5*0.9)
    Check Log With Au2anlysis      ${ini_path}${/}${case_name}${/}Harq.ini     i      save_log_directory=${test_log_directory}


