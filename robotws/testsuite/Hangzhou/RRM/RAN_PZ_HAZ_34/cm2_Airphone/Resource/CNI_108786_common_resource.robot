*** Settings ***
Documentation
...   author: Yin Chen
...   contact: yin.1.chen@nokia-sbell.com
...   squad group: SG_02
Library      taf.hw.mcs    WITH NAME    mcs
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot

*** Keywords ***
CNI108786 Common Case setup
    SG2_Common_setup_teardown.Common Case setup    need_Btslog=${True}
    CI_interface.Common Case Teardown