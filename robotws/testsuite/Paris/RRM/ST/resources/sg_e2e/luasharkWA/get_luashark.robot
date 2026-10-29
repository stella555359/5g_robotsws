*** Settings ***

Resource        ${CURDIR}/../luashark.robot

*** Test Cases ***
Get release Luashark
    ${rel}=    Get Variable Value    ${rel}    ${EMPTY}
    Run Keyword If    '${rel}' != '${EMPTY}'
    ...      luashark.Get Related Luashark    ${rel}
