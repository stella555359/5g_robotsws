*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : CB007351

Resource    ../../resources/cbrs_common_keywords.robot

*** Variables ***
${Certificate}    ${CURDIR}/certificates
${CBRSAdditionalCa_FILE}   ${Certificate}/5GC001321_TA_1125.pem
${CERT_FINGERPRINT}    15:4F:E2:42:10:AC:63:66:80:9F:E1:86:4C:AD:4C:09:66:48:BA:B8
${conf_path}    ${CURDIR}/conf
${CB008827_conf}    ${conf_path}/CB008827.conf

*** Keywords ***
CB007351 Environment Recovery
    Connect to gnb coam via ssl
    Sleep    20s
    ${status}  run keyword and return status    Get CBRS Certificate file    fingerprint=${CERT_FINGERPRINT}
    ...    target_file_name=5GC001321_TA_1125    connection=GNB_OAM
    Run Keyword If    ${status}== False    Install CBRS Certificate    cert_file=${CBRSAdditionalCa_FILE}
    ...    cert_type=CBRSAdditionalCa    cert_format=PEM

CB007351_Verify_Valid_certificates_are_taken_after_SW_fallback
    Start SAS server    config_name=${CB008827_conf}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Sleep    5s
    ${status}  run keyword and return status    Get CBRS Certificate file    fingerprint=${CERT_FINGERPRINT}
    ...    target_file_name=5GC001321_TA_1125    connection=GNB_OAM
    Should be True    ${status} == True
    Delete CBRS Certificate    fingerprint=${CERT_FINGERPRINT}
    ${stamp_case_start}    Get Timestamp For Current Time
    Wait Until Keyword Succeeds    5min    20s    Check Alarm in Alarm List    type=Active    faultId=6832
    ...    stamp_case_start=${stamp_case_start}    expect=${True}
    ...    Supplementary=SSL handshake failed
    Sleep    20s
    Perform SW rollback
    Sleep    10min
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    Sleep    20s
    ${SCF_temp}    Replace String    ${Golden_SCF_Path}    _SBTS00    _SBTS24R3
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_temp}
    Sleep    5min
    ${stamp_case_start}    Get Timestamp For Current Time
    Activate feature CBRS By Coam
    Wait Until Keyword Succeeds    3min    10s    Check Alarm in Alarm List    type=Active    faultId=6832
    ...    stamp_case_start=${stamp_case_start}    expect=${True}
    ...    Supplementary=SSL handshake failed
    ${status}  run keyword and return status    Get CBRS Certificate file    fingerprint=${CERT_FINGERPRINT}
    ...    target_file_name=5GC001321_TA_1125    connection=GNB_OAM
    Should be True    ${status} == False
    Install CBRS Certificate    cert_file=${CBRSAdditionalCa_FILE}    cert_type=CBRSAdditionalCa    cert_format=PEM
    Sleep    30s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Perform SW rollback
    Sleep    10min
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    [Teardown]    CB007351 Environment Recovery
