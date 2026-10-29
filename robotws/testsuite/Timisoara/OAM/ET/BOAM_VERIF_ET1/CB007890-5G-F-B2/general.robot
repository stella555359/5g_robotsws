*** Settings ***
Documentation
...    Author: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Maintainer: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_SPIRIT_ET_GMS
...    Feature Description: CB007890-5G-F
...    Sample execution: robot -L TRACE -b debug.log -d results general.robot

Resource    ./resources/CB007890-5G-F.robot

Suite Teardown  Run Keyword and ignore error  SSHLibrary.Close All Connections

#*** Variables ***

#*** Test Cases ***

#1_vCU_Fault_4592_BTS_precommissioned
#    [Tags]         CRT
#    vCU_Fault_4592_BTS_precommissioned

#4_vCU_Fault_4001_precommissioned
#    [Tags]          CRT
#    Generate fault 4001 when vCU is precommissioned
#    [Teardown]   Run keyword    Clear fault 4001

#9_vCU_Fault_4695_N+_cancelation_commissioned
#    [Tags]          CRT
#    [Setup]   Run keywords   Branch or Trunk Jenkins
#    ...       AND            SCF FILE
#    Fault_4695_N+_cancelation_commissioned
#    [Teardown]    Clear fault 4350 and fault 4695
