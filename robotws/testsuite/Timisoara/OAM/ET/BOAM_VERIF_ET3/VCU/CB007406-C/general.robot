*** Settings ***
Documentation
...    Author: Nicolae Cristina (cristina.nicolae@nokia.com), Catlan Radu-Vasile (radu-vasile.catlan@nokia.com)
...    Maintainer: Nicolae Cristina (cristina.nicolae@nokia.com), Catlan Radu-Vasile (radu-vasile.catlan@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_TIM_3_ET_GMS
...    Feature Description: CB007406-C
...    Sample execution: robot -L TRACE -b debug.log -d results general.robot

Resource    ./resources/CB007406-C.robot

Suite Teardown  Run Keyword  Close Connection
Force Tags  df

*** Variables ***

@{PROCESSES} =  /opt/nokia/SS_OAM/CPCONFIG/cpconfigvcu.json
...             /opt/nokia/SS_OAM/TRSCONFIG/trsconfig.json
...             /opt/nokia/SS_OAM/TAS/run.sh
...             /opt/nokia/SS_OAM/NTS/run.sh
...             /opt/ims/run.sh

@{PODS} =  oamconfig  oamfm

#${PODS_NON-CRITICAL_PROCESS_FAILURE}  =  Set Global Variable  ${Pods_non-critical_process_failure}

*** Test Cases ***

[1][1.0] 17. Cpconfig non-critical process failure_2N Deployment
    [Tags]         CRT
    Log to console  Pods non-critical process failure, 2N
    FOR  ${process}  IN  @{PROCESSES}
            Kill Process  ${process}
    END
    ${Pods_non_critical_process_failure}=  set variable  ${TEST_NAME}
    set suite variable  ${Pods_non_critical_process_failure}

[1][1.0] 27. NRTS non-critical process failure_2N Deployment
#    [Setup]  should be equal as strings   ${PODS_NON_CRITICAL_PROCESS_FAILURE}   PASS
    [Setup]  should be equal as strings  ${PREV_TEST_STATUS}  PASS
    Log to console  NRTS non-critical process failure_2N Deployment

[1][1.0] 21. Trsconfig non-critical process failure_2N Deployment
#    [Setup]  should be equal as strings  ${PODS_NON_CRITICAL_PROCESS_FAILURE}  PASS
    [Setup]  should be equal as strings  ${PREV_TEST_STATUS}  PASS

    Log to console  Trsconfig non-critical process failure_2N Deployment

[1][1.0] 77. TAS non-critical process failure_2N Deployment
#    [Setup]  should be equal as strings  ${PODS_NON_CRITICAL_PROCESS_FAILURE}  PASS
    Log to console  Trsconfig non-critical process failure_2N Deployment
        [Setup]  should be equal as strings  ${PREV_TEST_STATUS}  PASS


[1][1.0] 45. IMS critical process failure in 2N deployment
#    [Setup]  should be equal as strings  ${PODS_NON_CRITICAL_PROCESS_FAILURE}  PASS
    log to console  IMS critical process failure in 2N deployment
        [Setup]  should be equal as strings  ${PREV_TEST_STATUS}  PASS


[1][1.0] 41. OAMFM pod failover in 2N deployment
     [Tags]         CRT
     Log to console  OAMFM pod failover in 2N deployment
     FOR  ${pod}  IN  @{PODS}
        Delete Pods   ${pod}
     END
     Log to console  Waiting 6 min for pod to recreate
     Sleep   360
     BuiltIn.Wait Until Keyword Succeeds   6min   30s   Verify All Pods Are Running

[1][1.0] 15. OAMConfig 2N pod failover_2N Deployment
    [Setup]  should be equal as strings  ${PREV_TEST_STATUS}  PASS
    Log to console  OAMConfig 2N pod failover_2N Deployment
