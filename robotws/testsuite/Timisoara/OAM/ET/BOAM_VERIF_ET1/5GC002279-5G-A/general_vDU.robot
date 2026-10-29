*** Settings ***
Documentation
...    Author: Andrada Bugiu (andrada.bugiu@nokia.com)
...    Maintainer: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Group in charge: RAN_BOAM_VERIF
...    References: doors
...    Feature Description: 5GC002279-A
...    Sample execution:  robot -L TRACE -b debug.log -d results
...    /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/5GC002279-5G-A/general_vDU.robot

Resource   ./resources/5GC002279-A.robot
Resource   ./resources/xpath_2279A.robot
Resource   ../vduResourcesAIC/vduSelenium.robot
Resource   ../resources/get_build_wft.robot

Suite Teardown  None  #Logout  #AND  Case Postcondition

*** Variables ***
${G_VDU_NAME}         vdu5
${CLUSTER_NAME}       cran1
${G_OAM_PODS_NAME}    po-${CLUSTER_NAME}-oamext-0
${G_USER}             core
${NRBTS_ID}           0

*** Test Cases ***
3_vDU_Static_Route_IPv4_Fault61665_same_Gateway
        [Tags]     CRT
#        Login  ${VDU}
        Log to console  Test
        vduSelenium.Login vDU
        Generate fault 61665  ${gw_err_vdu}  ${destIpAddr_vdu}  ${destIpPrefixLength_vdu}

13_vDU_Static_Route_IPv4_modify_Fault61665_clear
        [Tags]     CRT
        Clear fault 61665  ${gw_vdu}  #${VDU}
        [Teardown]  Delete IPRT parameters list

#7_vDU_Routing_Policy_IPv4_Fault61664
#        [Tags]     CRT
#        Generate fault 61664  ${orderNumber_err_vdu}  ${VDU}

15_vDU_Routing_Policy_IPv4_modify_Fault61664_clear
        [Tags]     CRT
        Generate fault 61664  ${orderNumber_err_vdu}  ${VDU}
        Clear fault 61664  ${orderNumber_vdu}  #${VDU}
        [Teardown]  Delete RTPOL parameters list
