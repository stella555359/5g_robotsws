*** Settings ***
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown
Resource          ../resources/DevHZ5_resource.robot

*** Variables ***
${ENB_CONFIG}    3CELLs_FDD
${AUTO_ANALYSIS_FLAG}  ${False}

*** Test Cases ***
setup BTS
    log    ${EMPTY}

*** Keywords ***
Start BTS With Specified Config Files
    Common Suite Setup
    Run Keyword If    'b48' in '${ENB_CONFIG.lower()}'     Start SAS Server
    Setup CUS Env    tl_type=${ENB_CONFIG}
