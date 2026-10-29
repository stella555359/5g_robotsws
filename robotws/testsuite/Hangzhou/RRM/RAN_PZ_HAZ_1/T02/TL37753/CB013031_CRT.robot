*** Settings ***
Documentation
...                 author:  Liu AnAn

Library    taf.nms.netact
Library    DateTime

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${NETACT_NAME}=    srnclab2024
${HOSTNAME}=    10.99.113.46
${USERNAME}=    omc
${PASSWORD}=    Medsql!_1893
${DIST_NAME}=    PLMN-PLMN/MRBTS-37753
${LOCAL_DIR}=    /tmp/

*** Test Cases ***
CB013031_SR_09
    ${parameters}=   Create Dictionary    -lteHwContentInUse=${TRUE}    -sranBtsHwContentInUse=${TRUE}
    Upload Configuration    ${DIST_NAME}    parameters=${parameters}    alias=${NETACT_NAME}


*** Keywords ***
Suite Precondition
    Add Node    cmwas    ${HOSTNAME}    ${USERNAME}    ${PASSWORD}    alias=${NETACT_NAME}
    ${web_url}=    Detect WEB URL    alias=${NETACT_NAME}
    Add WEB URL    ${web_url}    ${USERNAME}    ${PASSWORD}    alias=${NETACT_NAME}

Suite Postcondition
    Delete Node    cmwas    alias=${NETACT_NAME}
    Clean All    alias=${NETACT_NAME}