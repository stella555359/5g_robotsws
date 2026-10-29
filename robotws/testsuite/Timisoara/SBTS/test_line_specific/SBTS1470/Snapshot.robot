*** Settings ***
Force Tags  QCD_MN_SRAN  QCP_SRAN_SBTS  SRAN  CLOUD_SRAN_L_10470_1ASIA_3ABIA_2FXED_1FXED_3FRGU_2FXDB_1FRMF  STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource    ../../CIT/test_resources/LOGS__Snapshot.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${COMMISSIONING_PATH}
...  /home/ute/testline_configuration/10_18_UTESRANCLOUD1470/node1/BTS_CLOUD_SRAN_L_10470_1ASIA_3ABIA_2FXED_1FXED_3FRGU_2FXDB_1FRMF_SBTS00.xml

*** Test Cases ***


[2]Automated__LOGS__Snapshot
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SNAPSHOT_TIMEOUT}    600
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_FLAG}    always
    
    ...    AND    LOGS__Snapshot.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order
