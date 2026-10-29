*** Settings ***
Documentation     CB014455
Suite Setup       suite setup   skip_build_download=${TRUE}
Suite Teardown    suite teardown

Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_VRF    CA_RAN_PZ_HAZ_1
Resource    ../SWM/CB014455/CB014455.robot

*** Variables ***
${sw_package_path}      /home/ute/btsauto
${target_release}       SBTS00
${Target SW dir}        /home/ute/btsauto/TARGET_SW
${mplane_IP}            192.168.255.129


*** Test Cases ***
CB014455 Roustness Test
    [Tags]    rrr
    [Setup]     CB014455 setup
    [Timeout]    24h
    Robustness Test
    [Teardown]  CB014455 teardown

CB014455 Update FH Vlans
    [Tags]    vvv
    [Setup]     CB014455 setup
    [Timeout]    48h
    Update FH vlans Loop
    [Teardown]  CB014455 teardown

Site Reset
    [Tags]    xxx
    [Setup]     CB014455 setup
    [Timeout]    24h
    Site Reset Loop
    [Teardown]  CB014455 teardown

BBMOD Reset
    [Tags]    bbb
    [Setup]     CB014455 setup
    [Timeout]    24h
    BBMOD reset Loop
    [Teardown]  CB014455 teardown

Radio Power Reset
    [Tags]    ppp
    [Setup]     CB014455 setup
    [Timeout]    24h
    ORU Power Reset Loop
    [Teardown]  CB014455 teardown

Cell Reset
    [Tags]    yyy
    [Setup]     CB014455 setup
    [Timeout]    24h
    Cell reset Loop
    [Teardown]  CB014455 teardown

Radio Reset
    [Tags]    zzz
    [Setup]     CB014455 setup
    [Timeout]    24h
    Radio reset Loop
    [Teardown]  CB014455 teardown

Verification of multiple times Cell Lock Unlock & Cell block unblock
    [Tags]    QC_171193
    [Setup]     CB014455 setup
    [Timeout]    2h
    Cell Lock Unlock Cell block unblock Loop
    [Teardown]  CB014455 teardown

Verification of cell reconfiguration from 64QAM to 256 QAM configuration
    [Tags]    QC_171192
    [Setup]     CB014455 setup
    [Timeout]    1h
    Cell reconfiguration from 64QAM to 256 QAM
    [Teardown]  CB014455 teardown

CB010918_A_Verification of OSQA O-RU reset through WEBEM
    [Tags]    QC_171148
    [Setup]     CB014455 setup
    [Timeout]    15min
    Radio reset via Admin
    [Teardown]  CB014455 teardown

Verification of multiple times Cell lock and unlock operation via NetAct
    [Tags]    QC_171137
    [Setup]     CB014455 setup
    [Timeout]    1h
    Cell Lock Unlock Loop From NMS
    [Teardown]  CB014455 teardown

Verification of runtime changes of different Tx Power (Out of boundary & supported Tx power) of the cell
    [Tags]    QC_171188
    [Setup]     CB014455 setup
    [Timeout]    15min
    Verification of runtime changes of different Tx Power of the cell
    [Teardown]  CB014455 teardown

Verify O-RU shall support frequency and time recovery
    [Tags]    QC_171186
    [Setup]     CB014455 setup
    [Timeout]    15min
    Verify O-RU shall support frequency and time recovery
    [Teardown]  CB014455 teardown

Verification of NETCONF user account management according to O-RAN specification
    [Tags]    QC_171147
    [Setup]     CB014455 setup
    [Timeout]    15min
    Verification of NETCONF user account management according to O-RAN specification
    [Teardown]  CB014455 teardown

Verification of HW specificaitons in 3rd Party ORU
    [Tags]    QC_171205
    [Setup]     CB014455 setup
    [Timeout]    15min
    Verification of HW specificaitons in 3rd Party ORU
    [Teardown]  CB014455 teardown

Verify ORU reset completes In 3 minute 30 Second
    [Tags]    QC_171202
    [Setup]     CB014455 setup
    [Timeout]    15min
    Radio Reset via Admin
    [Teardown]  CB014455 teardown

Verification of power reset of site
    [Tags]    QC_171140
    [Setup]     CB014455 setup
    [Timeout]    15min
    Cell Lock and Unlock from NMS
    [Teardown]  CB014455 teardown

Verification of gNB behaviour with BBMOD reset plugin-plugout & BBMOD lock Unlock
    [Tags]    QC_xxx
    [Setup]     CB014455 setup
    [Timeout]    15min
    BBMOD Reset via Admin
    [Teardown]  CB014455 teardown

O-RU SW upgrade and rollback via WebEM
    [Tags]    QC_171142
    [Setup]     CB014455 setup
    [Timeout]    15min
    O-RU SW upgrade and rollback via WebEM
    [Teardown]  CB014455 teardown

O-RU fault management FH alarm generation and cancellation - Fault 2: Unit dangerously overheating
    [Tags]    QC_171167
    [Setup]     CB014455 setup
    [Timeout]    15min
    Verification of Fault 2 Unit dangerously overheating
    [Teardown]  CB014455 teardown

O-RU fault management FH alarm generation and cancellation - Fault 4: Temperature too low
    [Tags]    QC_171162
    [Setup]     CB014455 setup
    [Timeout]    15min
    Verification of Fault 4 Transmission quality deteriorated
    [Teardown]  CB014455 teardown

O-RU fault management FH alarm generation and cancellation - Fault 9: Transmission quality deteriorated
    [Tags]    QC_171155
    [Setup]     CB014455 setup
    [Timeout]    15min
    Verification of Fault 9 Transmission quality deteriorated
    [Teardown]  CB014455 teardown

Verification of sFTP client suppot in O-RU and its Authentication Process
    [Tags]    QC_171201
    [Setup]     CB014455 setup
    [Timeout]    15min
    Verification of sFTP client suppot in O-RU and its Authentication Process
    [Teardown]  CB014455 teardown

Verification of NETCONF user account management
    [Tags]    QC_xxxxxxxxx
    [Setup]     CB014455 setup
    [Timeout]    15min
    Verification of NETCONF user account management
    [Teardown]  CB014455 teardown

Verification of default and additional sudo account on one O-DU via WebEM
    [Tags]    QC_171146
    [Setup]     CB014455 setup
    [Timeout]    15min
    Verification of NETCONF user account management according to O-RAN specification
#    [Teardown]  CB014455 teardown

