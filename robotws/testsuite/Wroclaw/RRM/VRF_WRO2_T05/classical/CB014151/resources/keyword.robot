*** Settings ***
Documentation    Keywords for CB014151

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB014151/resources/keywords.py    WITH NAME    kw

*** Keywords ***
Verify physCellId in sCellTeoAddModList
    [Arguments]  ${directory_path}=${None}
    kw.check physCellId in sCellTeoAddModList  directory_path=${directory_path}

Verify sCellInactiveReason RLQ
    [Arguments]  ${directory_path}=${None}
    kw.check sCellInactiveReason rlq  directory_path=${directory_path}

Verify UE sends Measurement Report for SCell Addition A1 event
    [Arguments]  ${directory_path}=${None}
    kw.scell_addition_a1_event  directory_path=${directory_path}

Check UEContextModificationRequired RLF
    [Arguments]  ${directory_path}=${None}
        kw.check rlf  directory_path=${directory_path}