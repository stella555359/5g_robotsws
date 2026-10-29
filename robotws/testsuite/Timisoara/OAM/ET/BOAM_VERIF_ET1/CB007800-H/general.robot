*** Settings ***
Documentation
...    Author: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Maintainer: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_SPIRIT_ET_GMS
...    Feature Description: CB007800-H
...    Sample execution: robot -L TRACE -b debug.log -d results general.robot

Resource    ./resources/CB007800-H.robot
Resource    ./resources/xpath_7800-H.robot

Suite Teardown  Run Keyword and ignore error  SSHLibrary.Close All Connections

*** Variables ***

@{PROCESSES} =  /opt/nokia/SS_OAM/ASM/runvcu.sh
...             /opt/nokia/SS_OAM/ASM/asmvcu.json

@{PODS} =  oamconfig  oamfm  oamcm  oamasm  oamext  cpif  cpcl  cpnrt  cpnb

#*** Test Cases ***


#Pods_failover_2N
#     [Tags]         CRT
#     FOR  ${pod}  IN  @{PODS}
#        Delete Active Pods   ${pod}
#     END
#      BuiltIn.Wait Until Keyword Succeeds   6min   30s  Verify All Pods Are Running

#6_vCU_Fault_4350_Alarm_7115_on_standby_Cplane_OAM_pods_during_runtime_2N
#     [Tags]         CRT
#     FOR  ${pod}  IN  @{PODS}
#        Delete Standby Pods   ${pod}
#     END
#      BuiltIn.Wait Until Keyword Succeeds   6min   30s  Verify All Pods Are Running

#ASM_Pods_non-critical_process_failure_2N
#    [Tags]         CRT
#    FOR  ${process}  IN  @{PROCESSES}
#            Kill Process  ${process}
#    END

#10_ROBUSTNESS_vCU_Multiples_Resets_Fault_4592_last_BTS_reset_cause
#    [Tags]         CRT
#    Generate Fault 4592
