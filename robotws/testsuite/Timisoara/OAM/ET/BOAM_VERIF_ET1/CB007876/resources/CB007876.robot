*** Settings ***
Documentation
...

Library        String
Library        OperatingSystem
Library        Process
Library        taf.gnb.oam.coam.admin
Library        taf.transport.ssh
Library        taf.gnb.oam.coam.admin.interface.admin   WITH NAME   taf_admin
Library        taf.selenium.gnb.oam.coam.classical      WITH NAME   taf_selenium

Resource    ./keywords.robot
Resource    ../../resources/admin.robot
Resource    ../../resources/admin_infomodel.robot
#Resource    ../../resources/pdu.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/fault_trigger.robot
Resource    ../../resources/AirPhone/resources/ute/ute_wts_runner.robot
Resource    ../../resources/selenium.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True
${SW_DESTINATION}     /home/ute

# Variables for the used SCFs
${scf_actForcefalse}      ${CURDIR}/actForceAutoReset_False.xml
${scf_default}             ${CURDIR}/actForceAutoReset_True_default.xml
${scf_leftside_dual_core_branch}   ${CURDIR}/scf_sbts22r4.xml

# Variables for the first and fourth cells path
${cell1}=             /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
${cell4}=             /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-4

&{FAULT_2080}    fault_id=2080
...              alarm_id=7101
...              alarm_severity=Warning
...              alarm_description="BTS secondary core autonomous reset as recovery action"
...              alarm_resource=/MRBTS-23212/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
#
*** Keywords ***
SC_fault_detection
#    log to console  Perform commissioning  on BTS
#    ADMIN Perform Commissioning
#    ...     scf_file=${scf_default}
#    ...     skip_parameter_relation_errors=True
#    Sleep  10
#    log to console  Waiting for BTS onAir
#    Wait Until Keyword Succeeds    900    30    ADMIN INFOMODEL Check If BTS Is OnAir
#    Sleep   15

## Triggering fault 2074 as a precondition to escalate to Baseband
    log to console   Trigger fault 2074 as a precondition.
    SYSTEM Check if fault is not in active raw alarm  2074  EFaultId_SrioRetryStoppedAl
    Trigger fault 2074 in RD models     9037
    log to console   Check SoC fault 2074.
    Wait Until Keyword Succeeds    200    1     SYSTEM Check if fault is in active raw alarm  2074  EFaultId_SrioRetryStoppedAl
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is OnAir
    Wait Until Keyword Succeeds    200    20    SYSTEM Check if fault is not in active raw alarm  2074   EFaultId_SrioRetryStoppedAl
    log to console   Check for BTS OnAir and Cells Online
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is OnAir
    Wait Until Keyword Succeeds    600    20    ADMIN INFOMODEL Check If All Cells Are In Online State

## 1
    log to console   Trigger Baseband fault 2074 for 1-st time.
    SYSTEM Check if fault is not in active raw alarm  2074  EFaultId_SrioRetryStoppedAl
    Trigger fault 2074 in RD models     9037
    log to console   Check Baseband fault 2074 for 1-st time.
    Wait Until Keyword Succeeds    200    1     SYSTEM Check if fault is in active raw alarm  2074  EFaultId_SrioRetryStoppedAl
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is OnAir
    Wait Until Keyword Succeeds    200    20    SYSTEM Check if fault is not in active raw alarm  2074   EFaultId_SrioRetryStoppedAl
    log to console   Check for BTS OnAir and Cells Online
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is OnAir
    Wait Until Keyword Succeeds    600    20    ADMIN INFOMODEL Check If All Cells Are In Online State

## 2
    log to console   Trigger Baseband fault 2074 for 2-nd time.
    SYSTEM Check if fault is not in active raw alarm  2074  EFaultId_SrioRetryStoppedAl
    Trigger fault 2074 in RD models     9037
    log to console   Check Baseband fault 2074 for 2-nd time.
    Wait Until Keyword Succeeds    200    1    SYSTEM Check if fault is in active raw alarm  2074  EFaultId_SrioRetryStoppedAl
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is OnAir
    Wait Until Keyword Succeeds    200    20    SYSTEM Check if fault is not in active raw alarm  2074   EFaultId_SrioRetryStoppedAl
    log to console   Check for BTS OnAir and Cells Online
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is OnAir
    Wait Until Keyword Succeeds    600    20    ADMIN INFOMODEL Check If All Cells Are In Online State

## 3
    log to console   Trigger Baseband fault 2074 for 3-rd time.
    SYSTEM Check if fault is not in active raw alarm  2074  EFaultId_SrioRetryStoppedAl
    Trigger fault 2074 in RD models     9037
    log to console   Check Baseband fault 2074 for 3-rd time.
    Wait Until Keyword Succeeds    200    1    SYSTEM Check if fault is in active raw alarm  2074  EFaultId_SrioRetryStoppedAl
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is OnAir
    Wait Until Keyword Succeeds    200    20    SYSTEM Check if fault is not in active raw alarm  2074   EFaultId_SrioRetryStoppedAl
    log to console   Check for BTS OnAir and Cells Online
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is OnAir
    Wait Until Keyword Succeeds    600    20    ADMIN INFOMODEL Check If All Cells Are In Online State

## 4
    log to console   Trigger Baseband fault 2074 for 4-th time.
    SYSTEM Check if fault is not in active raw alarm  2074  EFaultId_SrioRetryStoppedAl
    Trigger fault 2074 in RD models     9037
    log to console   Check Baseband fault 2074 for 4-th time.
    Wait Until Keyword Succeeds    200    1    SYSTEM Check if fault is in active raw alarm  2074  EFaultId_SrioRetryStoppedAl
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is OnAir
    log to console   Check after 4 times alarm 2074 remain active
    Wait Until Keyword Succeeds    200    2    SYSTEM Check if fault is in active raw alarm  2074  EFaultId_SrioRetryStoppedAl
    log to console   Check for BTS OnAir
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is OnAir

SC_Autonomous_Reset_on_fault_detection
#    log to console  Perform commissioning on BTS
#   ADMIN Perform Commissioning
#  ...     scf_file=${scf_actForceFalse}
#    ...     skip_parameter_relation_errors=True
#    ADMIN Perform Commissioning
#    ...     scf_file=${scf_default}
#    ...     skip_parameter_relation_errors=True
#    Sleep  10
#    log to console  Waiting for BTS onAir
#    Wait Until Keyword Succeeds    900   30    ADMIN INFOMODEL Check If BTS Is OnAir

#    log to console  Blocking cell number 1
#    Blocking cell
#    ...     NRCELL_R_path=${cell1}

    log to console  Blocking cell number 4
    Blocking cell
    ...     NRCELL_R_path=${cell4}

    log to console   Trigger fault 2080
    SYSTEM Check if fault is not in active raw alarm  2080  EFaultId_SrioHostLinkDownAl
    Trigger fault 2080 in RD models
    Wait Until Keyword Succeeds    200    2    SYSTEM Check if fault is in active raw alarm  2080  EFaultId_SrioHostLinkDownAl

    log to console   Check Site Reset - ping to gNB should be unreacheable
    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period  400
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period  400

    log to console   Final Checks: BTS Is Configured , Alarm is not active
    Wait Until Keyword Succeeds
    ...    900
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is Configured
    SYSTEM Check if fault is not in active raw alarm  2080   EFaultId_SrioHostLinkDownAl
    log to console   Waiting for BTS OnAir
    Wait Until Keyword Succeeds
    ...    600
    ...    60
    ...    ADMIN INFOMODEL Check If BTS Is OnAir

Robustness_SC_Autonomous_Reset_on_fault_detection

#    log to console  Perform commissioning  on BTS
#    ADMIN Perform Commissioning
#    ...     scf_file=${scf_default}
#    ...     skip_parameter_relation_errors=True
#    Sleep  10
#    log to console  Waiting for BTS onAir
#    Wait Until Keyword Succeeds    900    30    ADMIN INFOMODEL Check If BTS Is OnAir

# 1
    log to console  Trigger fault 2080 (=> site reset) for the 1-st time
    log to console   Trigger fault 2080
    SYSTEM Check if fault is not in active raw alarm  2080  EFaultId_SrioHostLinkDownAl
    Trigger fault 2080 in RD models
    Wait Until Keyword Succeeds    200    2    SYSTEM Check if fault is in active raw alarm  2080  EFaultId_SrioHostLinkDownAl

    log to console   Check Site Reset - ping to gNB should be unreacheable
    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period  400
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period  400

    Wait Until Keyword Succeeds
    ...    900
    ...    20
    ...    ADMIN INFOMODEL Check If BTS Is Configured
    SYSTEM Check if fault is not in active raw alarm  2080   EFaultId_SrioHostLinkDownAl
    log to console   Wait for BTS OnAir
    Wait Until Keyword Succeeds
    ...    600
    ...    20
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
## 2
    log to console  Trigger fault 2080 (=> site reset) for the 2-nd time
    log to console   Trigger fault 2080
    SYSTEM Check if fault is not in active raw alarm  2080  EFaultId_SrioHostLinkDownAl
    Trigger fault 2080 in RD models
    Wait Until Keyword Succeeds    200    2    SYSTEM Check if fault is in active raw alarm  2080  EFaultId_SrioHostLinkDownAl

    log to console   Check Site Reset - ping to gNB should be unreacheable
    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period  400
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period  400

    Wait Until Keyword Succeeds
    ...    900
    ...    20
    ...    ADMIN INFOMODEL Check If BTS Is Configured
    SYSTEM Check if fault is not in active raw alarm  2080   EFaultId_SrioHostLinkDownAl
    log to console   Wait for BTS OnAir
    Wait Until Keyword Succeeds
    ...    600
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
## 3
    log to console  Trigger fault 2080 (=> site reset) for the 3-rd time
    log to console   Trigger fault 2080
    SYSTEM Check if fault is not in active raw alarm  2080  EFaultId_SrioHostLinkDownAl
    Trigger fault 2080 in RD models
    Wait Until Keyword Succeeds    200    2    SYSTEM Check if fault is in active raw alarm  2080  EFaultId_SrioHostLinkDownAl

    log to console   Check Site Reset - ping to gNB should be unreacheable
    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period  400
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period  400

    Wait Until Keyword Succeeds
    ...    900
    ...    20
    ...    ADMIN INFOMODEL Check If BTS Is Configured
    SYSTEM Check if fault is not in active raw alarm  2080   EFaultId_SrioHostLinkDownAl
    log to console   Wait for BTS OnAir
    Wait Until Keyword Succeeds
    ...    600
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is OnAir

## 4
    log to console  Trigger fault 2080 (=> site reset) for the 4-th time
    log to console   Trigger fault 2080
    SYSTEM Check if fault is not in active raw alarm  2080  EFaultId_SrioHostLinkDownAl
    Trigger fault 2080 in RD models
    Wait Until Keyword Succeeds    200    2    SYSTEM Check if fault is in active raw alarm  2080  EFaultId_SrioHostLinkDownAl

    log to console   Check Site Reset - ping to gNB should not be unreacheable
#    ${last_ping}=  SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period  200
#    Shoud be true  ${last_ping} != 0
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period  400

#    Wait Until Keyword Succeeds
#    ...    900
#    ...    30
#    ...    ADMIN INFOMODEL Check If BTS Is Configured

    log to console   Wait for BTS OnAir
    Wait Until Keyword Succeeds
    ...    600
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    log to console   Check if fault remains active
    SYSTEM Check if fault is in active raw alarm  2080   EFaultId_SrioHostLinkDownAl
