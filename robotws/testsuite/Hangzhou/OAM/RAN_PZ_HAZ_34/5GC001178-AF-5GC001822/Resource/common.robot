*** Settings ***
Documentation    Owner: Wang David
Resource   ../../common/L3_Call.robot
Variables  ../../libraries/global_vars.py
*** Variables ***
${coam_alias}   COAM


*** Keywords ***
COAM WEBUI Change CHBW to 100MHZ
    [Arguments]    ${L3CALL_CELLID}=2
    Wait Until Keyword Succeeds   2m   20s    COAM Login   alias=${coam_alias}
    ${chbw}    COAM Get Parameter Value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${L3CALL_CELLID}
    ...   parameter=chBw    connection=${coam_alias}
    run keyword if  ${chbw.count('100')} <= 0     UPDATE CHBW AND RESET    L3CALL_CELLID=${L3CALL_CELLID}
    [Teardown]    Run Keyword And Ignore Error  COAM Logout

UPDATE CHBW AND RESET
    [Arguments]    ${L3CALL_CELLID}=2
    COAM Update Parameter
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${L3CALL_CELLID}    parameter=chBw
    ...    value=60MHz
    COAM Try Connect gNB



