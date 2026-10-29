*** Settings ***
Documentation     CB014024

Force Tags        vDUCNF00    QCD_MN_RAN     QCP_RAN_VRF    CA_RAN_PZ_HAZ_1

Resource    ../TRACE/CB014024.robot

*** Variables ***
${TEMP_LOGS_DIR}    /tmp/logs/

*** Test Cases ***
CB014024-A-WebEM
    [Documentation]    CB014024
    [Tags]    QC_159411    CB014024-A
    [Setup]     CB014024 setup
    [Timeout]    2h
    CB014024-A Verify Parameters
    [Teardown]  CB014024 teardown

CB014024-A-NMS
    [Documentation]    CB014024
    [Tags]    QC_163919    CB014024-A
    [Setup]     CB014024 setup
    [Timeout]    2h
    CB014024-A Verify Parameters - NMS
    [Teardown]  CB014024 teardown

CB014024-B-WebEM
    [Documentation]    CB014024
    [Tags]    QC_166530    CB014024-B
    [Setup]     CB014024 setup
    [Timeout]    2h
    CB014024-B Verify Parameters
    [Teardown]  CB014024 teardown

CB014024-B-NMS
    [Documentation]    CB014024
    [Tags]    QC_166527    CB014024-B
    [Setup]     CB014024 setup
    [Timeout]    2h
    CB014024-B Verify Parameters - NMS
    [Teardown]  CB014024 teardown

CB014024-C
    [Documentation]    CB014024
    [Tags]    QC_166540    CB014024-C
    [Setup]     CB014024 setup
    [Timeout]    2h
    CB014024-C Verify Parameters
    [Teardown]  CB014024 teardown

CB014024 Robustness - Commissioning
    [Documentation]    CB014024
    [Tags]    QC_166535    CB014024-A
    [Setup]     CB014024 setup
    [Timeout]    2h
    CB014024 Robustness Test For Delta Commissioning
    [Teardown]  CB014024 teardown

CB014024 Robustness - Migration
    [Documentation]    CB014024
    [Tags]    QC_166536    CB014024-C
    [Setup]     CB014024 setup
    [Timeout]    2h
    CB014024 Robustness Test For Migration
    [Teardown]  CB014024 teardown
