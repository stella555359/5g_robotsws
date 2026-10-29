*** Settings ***
Resource    ../resources/CB008083_common_keywords.robot


Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup
...    Run keywords

*** Variables ***


*** Test Cases ***
example
    [Tags]    A1
    get parameters for object type          SERVEDAMF       guami