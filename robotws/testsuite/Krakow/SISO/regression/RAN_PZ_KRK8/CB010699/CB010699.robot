*** Settings ***
Documentation
...   Test Suite for testing CB010699 feature
...   author: Natalia Czech, Aleksander Gospodarczyk, Bartosz Odziomek, Hubert Kowalczyk
...   contact: natalia.czech@nokia.com


Resource            testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB010699/resources/CB010699_keywords.robot


Suite Setup          Custom Suite Setup
Suite Teardown       Common Suite Teardown
Test Setup           Common Preconditions With Watching Alarms
Test Teardown        Common Postconditions With Watching Alarms



*** Variables ***
${zip_directory}                /home/ute/srcel/SRCEL
@{CUSTOM_ALLOWED_ALARMS}        No X2 link available
...                             BTS Reset Cause
...                             Sanity Check Error
${sw_config_path}               testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/UUF4ALL/resources/swconfig.txt


*** Test Cases ***
CB010699-A 1. Requesting system critical event logs collection and upload to target location
    Upload Swconfig On Classical Gnb    sw_config_path=${sw_config_path}
    ${alias}    connections.Get Default Admin Connection Alias
    coam_admin.collect_local_screl    target_file_name=/home/ute/srcel/SRCEL
    ...    include_pmfm_data=true
    ...    timeout=120
    ...    detailed_output=true
    ...    connection=${alias}
    Run    mkdir -p ${path_to_unzip}
    unpack_screll   ${zip_directory}
    get_files_list
    ${all_files}=    traverse directories    ${path_to_unzip}
    check files    ${all_files}    ${expected_files}
    log to console    ${all_files}
