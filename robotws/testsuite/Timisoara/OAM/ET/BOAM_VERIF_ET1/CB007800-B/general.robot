*** Settings ***
Documentation
...    Author: Ana-Maria Rodean (ana-maria.rodean@nokia.com)
...    Maintainer: Ana-Maria Rodean (ana-maria.rodean@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_SPIRIT_ET_GMS
...    Feature Description: CB007800-B
...    Sample execution: robot -L TRACE -b debug.log -d results general.robot

Resource    ./resources/CB007800-B.robot
Resource    ./resources/xpath_7800B.robot

Suite Teardown  Run Keyword  Close Connection
#Suite Teardown  Run Keyword  Logout

#Library      OperatingSystem
#Library      Collections
#Library      String
#Library      json
#Library      DateTime
#Library      taf.gnb.oam.coam.cu             WITH NAME    coam_cu
#Library      taf.gnb.oam.coam.admin          WITH NAME    coam
#Library      taf.gnb.oam.commissioning       WITH NAME    commissioning
#Library      taf.ul.oam.selenium_coam        WITH NAME    selenium_coam
#Library      taf.transport.ssh               WITH NAME    csn
#Library      taf.cloud.openstack             WITH NAME    ta_stack_creator

*** Variables ***


#@{PODS} =  oamconfig  oamfm  oamcm  oamasm  oamext  cpif  cpcl  cpnrt  cpnb

*** Test Cases ***

1.Check that Pods are redundant for 2N
    [Tags]         CRT
    [Documentation]
    ...

    Verify All Pods Are Running
    Check Redundant Pod
    Delete Active Pods   oamfm
    Check Active Pod   oamfm
    Verify All Pods Are Running


6. ROBUSTNESS Fault 4350 for CPUE Pod
    [Tags]         CRT
    [Documentation]
    ...

#    Verify All Pods Are Running
#    Check Redundant Pod
#    Delete Active Pods   oamfm
#    Check Active Pod   oamfm
    Verify All Pods Are Running
    Kill CPUE-0 pod
    Check Fault 4350
    Logout


