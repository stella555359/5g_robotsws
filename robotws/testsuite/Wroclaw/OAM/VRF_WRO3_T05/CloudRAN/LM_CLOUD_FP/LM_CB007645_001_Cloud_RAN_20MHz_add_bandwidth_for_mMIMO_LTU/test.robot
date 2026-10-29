*** Settings ***
Documentation  To be done
...  Author: bartlomiej.tulacz@nokia.com
...  Maintainer: bartlomiej.tulacz@nokia.com
...  copy and paste f 10_16_UTESRANSISO700

Library    BuiltIn

Resource    ../../Resources/common_keywords.robot
Resource    ../../Resources/common_logging.robot
Resource    ../../Resources/common_netact.robot

Suite Setup       Run Keywords    Suite Precondition  AND
...                               Setup NMS  srnclab1014  AND
...                               Get and Set NMS Parameters  AND
...                               NMS Node and Web Setup    setup_cls=True
Suite Teardown    Run Keywords    Suite Postcondition  AND
...                               NMS Node and Web Teardown

*** Variables ***
${VDU_SCFC_PATH}  ${CURDIR}/SCF/vDu/vDu.xml
${VCU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vCu.xml
@{RMOD_ID_LIST}=       1
@{modules_list}        SWEM for Cloud RAN CM
@{license_list}         U4000098.XML
@{lic_serial_number}    9991136339425

*** Test Cases ***

Test Precondition
    [Documentation]    This step delete test licenses and starts CM upload
    Log  \nDeleting licenses from CLS    console=True
    ${list_length}=    Get Length    ${license_list}
    FOR    ${i}    IN RANGE    ${list_length}
        Delete License    license_serialnumber=${lic_serial_number[${i}]}    license_filename=${license_list[${i}]}
    END
    CM upload

Report And 41003 Check
    [Documentation]    This step generate SWEM report and check if alarm 41003 is visble
    Log  \nSWEM Report and alarm check    console=True
    SWEM Reports Generation    @{modules_list}
    Wait Until Keyword Succeeds    5x    1min    Check if 41003 Alarm
    Check 41003 Alarm Content
    Log  Done    console=True

License Upload And Check
    [Documentation]    This step uploads test licenses and check if 41003 is no longer visible
    Log    \nLicenses upload.    console=True
    FOR    ${lic_file}    IN    @{license_list}
        Copy File    ${CURDIR}/licenses/${lic_file}    ${SUITE_LOGS_DIR_PATH}{/}Lic_To_Upload${/}${lic_file}
        Set Test Variable    ${License_template}    ${SUITE_LOGS_DIR_PATH}{/}Lic_To_Upload${/}${lic_file}
        Upload License    ${License_template}
    END
    Log    Licenses uploaded!    console=True
    SWEM Reports Generation    @{modules_list}
    Wait Until Keyword Succeeds    5x    1min    Check if no Alarms
    Log    Test passed!    console=True

*** Keywords ***
CM upload
    [Documentation]  Cm upload of Hardcoded MRBTS objects
    Log  Start CM upload    console=True
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-8515    parameters=None    verbose=True
    ...    schedule=None    ignore_errors=False    timeout=7200
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-85151    parameters=None    verbose=True
    ...    schedule=None    ignore_errors=False    timeout=7200
    Log  Done CM upload    console=True

Check if 41003 Alarm
    ${out}=  Get Alarms  PLMN-PLMN/MRBTS-85151
    ${out2}=    Get From Dictionary    ${out[0]}    specificProblem
    ${out2}=    Convert To String    ${out2}
    Should Be Equal    ${out2}    41003    4153    4298    16
    Log    ${out2} Is visible in NMS    console=True

Check if no Alarms
    ${out}=  Get Alarms  PLMN-PLMN/MRBTS-85151
    Should Be Empty    ${out}
    Log    No Alarms Found    console=True

Check 41003 Alarm Content
    ${out}=  Get Alarms  PLMN-PLMN/MRBTS-85151
    ${out2}=    Get From Dictionary    ${out[0]}    additionalText1
    Log    ${out2}    console=True
    Should Contain    ${out2}    66352: 2/0
