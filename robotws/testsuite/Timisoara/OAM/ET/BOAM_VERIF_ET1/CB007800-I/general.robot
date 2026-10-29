*** Settings ***
Documentation
...    Author: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Maintainer: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_SPIRIT_ET_GMS
...    Feature Description: CB007800-I
...    Sample execution: robot -L TRACE -b debug.log -d results general.robot

Resource    ./resources/CB007800-I.robot

Suite Teardown  Run Keyword  Close Connection
#Suite Teardown  Run Keyword  Logout

#Library      OperatingSystem
#Library      Collections
#Library      String
#Library      json

#Library      taf.gnb.oam.coam.cu             WITH NAME    coam_cu
#Library      taf.gnb.oam.coam.admin          WITH NAME    coam
#Library      taf.gnb.oam.commissioning       WITH NAME    commissioning
#Library      taf.ul.oam.selenium_coam        WITH NAME    selenium_coam
#Library      taf.transport.ssh               WITH NAME    csn
#Library      taf.cloud.openstack             WITH NAME    ta_stack_creator

*** Variables ***

@{PROCESSES} =  /opt/nokia/SS_OAM/ASM/runvcu.sh
...             /opt/nokia/SS_OAM/ASM/asmvcu.json

#@{PODS} =  oamconfig  oamfm  oamcm  oamasm  oamext  cpif  cpcl  cpnrt  cpnb

*** Test Cases ***
ASM_Pods_non-critical_process_failure_2N
    [Tags]         CRT
    FOR  ${process}  IN  @{PROCESSES}
            Kill Process  ${process}
    END


