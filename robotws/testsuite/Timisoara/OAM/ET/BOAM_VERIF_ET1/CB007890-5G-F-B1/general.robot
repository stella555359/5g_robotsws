*** Settings ***
Documentation
...    Author: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Maintainer: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_SPIRIT_ET_GMS
...    Feature Description: CB007890-F1
...    Sample execution: robot -L TRACE -b debug.log -d results general.robot

Resource    ./resources/CB007890-F1.robot
Resource    ./resources/xpath_7890-F1.robot

Suite Teardown  Run Keyword  Close Connection

#Library      OperatingSystem
#Library      Collections
#Library      String
#Library      json

*** Variables ***

@{PROCESSES} =  /opt/nokia/SS_OAM/ASM/runvcu.sh
...             /opt/nokia/SS_OAM/ASM/asmvcu.json

@{PODS} =  oamconfig  oamfm  oamcm  oamasm  oamext  cpif  cpcl  cpnrt  cpnb

*** Test Cases ***
1_Check_the_RCP_HC_availability_during_runtime_and_raise_fault_4693_when_failure_is_detected
    [Tags]         CRT
    Delete Pods   healing-controller
    Generate Fault 4693
#        Close connection
#        sleep  30
#        Restart Pods  healing-controller
#        Reset reason unknown
#        Wait Until Keyword Succeeds    120    10  Verify pods  healing-controller
#      BuiltIn.Wait Until Keyword Succeeds   6min   30s  Verify All Pods Are Running
