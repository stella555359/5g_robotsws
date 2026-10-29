*** Settings ***
Documentation
...     [Procedure]             "Virtual Router Redunancy Protocol Backhaul"
...     [Author]                "Aishwarya Gade"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab For Reporting"
...     [Feature_ID]            "CNI-95000"
...     [Requirement ID]        "TT_IPT.787,TT_IPT.905,RPREQ_7902"
...     [Funtion_Hash_Tags]     "VRRP-switchover"
...     [Domain_Hash_Tags]      "Backhaul L3"
...     [Validated_TestLine]    "2213"
...     [Config]                "Multi-homing,TOP configuartion in BTS and VRRP configuration in IXR"
...     [Runtime param]         "bts_id is provided at run time."

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_VRRP.robot
Resource        ${CURDIR}/../CB006666/resources/Common_LAG.robot


Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops



*** Test Cases ***
[1][1.0] TC01_ASIB_CNI95000_LAG_EIF1_EIF2_IPV4_IPV6
    Base Configurations for LAG
    Verify VRRP Single Link Redundancy with IPV4 multihomming and TOP
    Verify VRRP Single Link Redundancy with IPV6 multihomming and TOP
    Remove LAG Configuration From BTS and Switch       remove_lag      ${DeleteLAGActiveStandby}
    [Teardown]    Perform Switchover IXR14
