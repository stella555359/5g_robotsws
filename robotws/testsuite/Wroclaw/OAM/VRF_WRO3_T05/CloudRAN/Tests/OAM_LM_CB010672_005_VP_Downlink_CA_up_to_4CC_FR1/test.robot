*** Settings ***
Documentation  To be done
...  Author: szymon.romanowski@nokia.com
...  Maintainer: szymon.romanowski@nokia.com
...  Scout ID: 11_16_UTE5GCLOUDMRBTS8515

Library    BuiltIn

Resource    ../../Resources/common_keywords.robot
Resource    ../../Resources/common_logging.robot
Resource    ../../Resources/common_netact.robot

Suite Setup       Run Keywords    Suite Precondition  AND
...                               Setup NMS  srnclab3022  AND
...                               Get and Set NMS Parameters  AND
...                               NMS Node and Web Setup    setup_cls=True
Suite Teardown    Run Keywords    Suite Postcondition  AND
...                               NMS Node and Web Teardown

*** Variables ***
${VDU_SCFC_PATH}        ${CURDIR}/SCF/vDu/vDu.xml
${VCU_SCFC_PATH}        ${CURDIR}/SCF/vCu/vCu.xml
@{RMOD_ID_LIST}=        1
@{modules_list}         SWEM for Cloud RAN CM
@{modules_list_PM}      SWEM for Cloud RAN PM
@{license_list}         V0100754.XML    V0100755.XML    V0100753.XML
@{lic_serial_number}    0011014079569    0011037063057    0011105018257

*** Test Cases ***
Test Precondition
    [Documentation]    This step delete test licenses and starts CM upload
    Log  \nSTEP 1: Test Precondition - License delete, CM upload    console=True
    License delete
    CM upload

Report And 41003 Check
    [Documentation]    This step generate SWEM report and check if alarm 41003 is visble
    Log  \nSTEP 2: SWEM Report and check alarm 41003    console=True
    SWEM Reports Generation    @{modules_list}
    SWEM PM Reports Generation    @{modules_list_PM}
    Wait Until Keyword Succeeds    5x    1min    Check if 41003 Alarm
    Check 41003 Alarm Content
    Log  Done    console=True

License Upload And Check
    [Documentation]    This step uploads test licenses and check if 41003 is no longer visible
    Log  \nSTEP 3: License Upload And Check if no Alarms    console=True
    License upload
    SWEM Reports Generation    @{modules_list}
    SWEM PM Reports Generation    @{modules_list_PM}
    Wait Until Keyword Succeeds    5x    1min    Check if no Alarms
    Log    Test passed!    console=True

*** Keywords ***
License delete
    [Documentation]  Deletes licenses from lab's CLS
    Log  \nDeleting licenses from CLS    console=True
    ${list_length}=    Get Length    ${license_list}
    FOR    ${i}    IN RANGE    ${list_length}
        Delete License    license_serialnumber=${lic_serial_number[${i}]}    license_filename=${license_list[${i}]}
    END

License upload
    Log    \nLicenses upload.    console=True
    FOR    ${lic_file}    IN    @{license_list}
        Copy File    ${CURDIR}/licenses/${lic_file}    ${SUITE_LOGS_DIR_PATH}{/}Lic_To_Upload${/}${lic_file}
        Set Test Variable    ${License_template}    ${SUITE_LOGS_DIR_PATH}{/}Lic_To_Upload${/}${lic_file}
        Upload License    ${License_template}
    END
    Log    Licenses uploaded!    console=True

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
    #CLRAN00106.T (66352) - VP Downlink CA 3 to 4CC FR1 LK, [FB2425, Rel.25R1]
    Should Contain    ${out2}    66352: 5/0
    #CLRAN00162LK (70037) - Open O1 readiness LK, [FB2518, Rel.26R1]
    Should Contain    ${out2}    70037: 2/0
    #CLRAN00168LK (70065) - CB012259 REST API Interface Activation LK, [FB2522, Rel.26R1]
    Should Contain    ${out2}    70065: 1/0
