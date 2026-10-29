*** Settings ***
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown
Resource          ../resources/DevHZ5_resource.robot

*** Variables ***
${ENB1_CONFIG}    3CELLs_FDD
${ENB2_CONFIG}    3CELLs_FDD
${AUTO_ANALYSIS_FLAG}  ${False}
*** Test Cases ***
setup BTS
    log    ${EMPTY}

*** Keywords ***
Start BTS With Specified Config Files
    Common Suite Setup
    # for band46, plmn must be 311:09
    Run Keyword If    'b46' in '${ENB1_CONFIG.lower()}' or 'b46' in '${ENB2_CONFIG.lower()}'
    ...    Append to List    ${PARAMS_IN_SCF}    LNBTS:mcc=311    LNBTS:mnc=9    LNCEL:tac=124
    Run Keyword If    'b46' in '${ENB1_CONFIG.lower()}' or 'b46' in '${ENB2_CONFIG.lower()}'
    ...    Append to List    ${PARAMS_IN_SCF_ENB2}    LNBTS:mcc=311    LNBTS:mnc=9    LNCEL:tac=124
    # for band48, sas server need to startup before enb start
    Run Keyword If    'b48' in '${ENB1_CONFIG.lower()}' or 'b48' in '${ENB2_CONFIG.lower()}'     Start SAS Server
    Setup 2CUS Env    tl_type=${ENB1_CONFIG}    tl_type_enb2=${ENB2_CONFIG}
