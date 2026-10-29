*** Settings ***
Documentation
...    Author: Andrada Bugiu (andrada.bugiu@nokia.com)
...    Maintainer: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Group in charge: RAN_BOAM_VERIF
...    References: doors
...    Feature Description: CB002279-A
...    Sample execution:  robot -L TRACE -b debug.log -d results
...    /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/5GC002279-5G-A/general_vCU.robot

Resource   ./resources/5GC002279-A.robot
Resource   ./resources/xpath_2279A.robot
Suite Teardown  Run Keyword And Ignore Error  Logout

*** Test Cases ***
1_vCU_Static_Route_IPv4_Fault61665_same_Gateway
        [Tags]     CRT
        5GC002279-A.Login  #${VCU}
        Generate fault 61665  ${gw_err_vcu}  ${destIpAddr_vcu}  ${destIpPrefixLength_vcu}
        [Teardown]  None

9_vCU_Static_Route_IPv4_modify_Fault61665_clear
        [Tags]     CRT
        Clear fault 61665  ${gw_vcu}  #${VCU}
        [Teardown]  Delete IPRT parameters list

#5_vCU_Routing_Policy_IPv4_Fault61664
#        [Tags]     CRT
##        5GC002279-A.Login  #${VCU}
#        Generate fault 61664  ${orderNumber_err_vcu}  ${VCU}
#        [Teardown]  None

11_vCU_Routing_Policy_IPv4_modify_Fault61664_clear
        [Tags]     CRT
        Generate fault 61664  ${orderNumber_err_vcu}  ${VCU}
        Clear fault 61664  ${orderNumber_vcu}  #${VCU}
        [Teardown]  Delete RTPOL parameters list
