*** Settings ***
Documentation
...    Author: Przemyslaw Kusa, przemyslaw.kusa@nokia.com
...    Maintainer: Przemyslaw Kusa, przemyslaw.kusa@nokia.com

Resource    ./resources/keywords.robot

Suite Setup       Suite Setup Custom
Test Setup        Test Setup Custom
Test Teardown     Common Postconditions
Suite Teardown    Suite Teardown Custom

*** Test Cases ***
[1][1.0] CB013483-B-SR Verifying synchronization behavior of ITSAR related parameters on ASIR after software upgrade and rollbacks - Robustness Test
    Check If Yaft Is Necessary
    Check Non-ITSAR Values
    Create UUF_SW Directory
    Update SW    sw_version=${FIRST_SW}    path=${SW_PATH}    expected_sw=${FIRST_SW}
    Check ITSAR Values
    Rollback SW    expected_sw=${25R1_BUILD}
    ASIR Perform Recomissioning    delta=${wrong_itsar_params}
    ...    delta_file_name=ASIR_delta_25R1.xml
    ...    download_dir=${OUTPUT_DIR}/${TEST_NAME}
    Rollback SW    expected_sw=${FIRST_SW}
    Check Values After Rollback

[1][1.0] CB013483-B-SR Successful setting of Mobile Country Code for India Deployment
    Check MCC And Upload SCF With MCC 404 On BTS And MCC 1 With ITSAR Params On ASIR
    Check If PasswdHistoryLength Is Set To 3
    Check If MCC Is Set To 404

[1][1.0] CB013483-B-SR Error while setting the Mobile Country Code for India Deployment
    Check MCC And Upload SCF With MCC 404 On BTS And MCC 1 On ASIR
    Check If AllowASiLocalUserDefaultPassword Is Set To True And MCC Is Set To 1
    ASIR Perform Recomissioning    delta=${wrong_itsar_params}
    ...    delta_file_name=ASIR_delta.xml
    ...    download_dir=${OUTPUT_DIR}/${TEST_NAME}
    Check If MCC Is Set To 404
    ${output}    ASIR Commissioning   scf_path=${OUTPUT_DIR}/${TEST_NAME}/ASIR_delta.xml
    Should Contain    ${output}    For Indian deployment

[1][1.0] CB013483-B-SR Error while setting parameters related to ITSAR for India Deployment
    Check MCC And Upload SCF With MCC 404 On BTS And MCC 404 On ASIR
    Check If AllowASiLocalUserDefaultPassword Is Set To False And MCC Is Set To 404
    Check If MCC Is Set To 404 With Wrong ITSAR Params
    ${output}    ASIR Commissioning   scf_path=${OUTPUT_DIR}/${TEST_NAME}/ASIR_delta.xml
    Should Contain    ${output}    For Indian deployment

[1][1.0] CB013483-B-SR ITSAR compliancy for WebEM session timeout
    Check And Verify SW Version
    Check MCC And Upload SCF With MCC 404 On BTS And MCC 404 On ASIR
    Check If WebEMSessionLogoutTimer Is Set to 120 Seconds
    Check If WebEMSessionLogoutTimer Is Successfully Set On India Deployment
    Check MCC And Upload SCF With MCC 1 On BTS And MCC 1 On ASIR
    Check If WebEMSessionLogoutTimer Is Set to 120 Seconds
    Check If Parameter Is Successfully Set On Non-India Deployment    param=webEMSessionLogoutTimer

[1][1.0] CB013483-B-SR Setting parameters not compliant to ITSAR regulation for non-India Deployment
    Check MCC And Upload SCF With MCC 1 On BTS And MCC 1 On ASIR
    Check If MCC Is Set To 1 And Perform ASIR Commissioning
    ASIR Perform Recomissioning    delta=${wrong_itsar_params}
    ...    delta_file_name=ASIR_delta.xml
    ...    download_dir=${OUTPUT_DIR}/${TEST_NAME}
    Check If Parameter Is Successfully Set On Non-India Deployment    param=are
