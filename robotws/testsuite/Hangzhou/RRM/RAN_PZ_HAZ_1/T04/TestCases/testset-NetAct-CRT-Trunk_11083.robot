*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com    lixin.kang@nokia-sbell.com

Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      TRUNK             #Tag Item

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../Resources/AIC_Utils.robot
#Resource          ../Resources/AIC_BTS_T04.robot
Resource          ../Resources/cm_ONAP.robot
Resource          ../CB008936/VRAN_SyVe_CM_Delta_Plan_Online_Validation_with_Validation_Scope_Setting_CB008936_003.robot
Resource          ../CB008660/VRAN_SyVe_CM_Reconfiguration_Of_Existing_Parameter_From_NetAct_CB008660-A_001.robot
Resource          ../CB008660/VRAN_SyVe_CM_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity_CB008660-A_004.robot
Resource          ../CB009451/VRAN_SyVe_CM_Configure_Optimize_Recalculate_Feature_Using_NetAct_CB009451-F_001.robot
Resource          ../CB009451/VRAN_SyVe_CM_Audit_Recommended_Feature_Configuration_Using_NetAct_CB009451-G_001.robot
Resource          ../CB011169/VRAN_SyVe_CM_Delta_Plan_Restriction_Rules_Creation_From_NetAct_CB006530.robot
Resource          ../CB011169/VRAN_SyVe_CM_Delta_Plan_Add_Rule_With_Modified_Restricted_Param_CB006530.robot
Resource          ../CB011169/VRAN_SyVe_CM_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param_CB006530.robot
Resource
...   ../CB007188/VRAN_SyVe_CM_CB007188_5G_B_VDU_Combine_Online_Modification_NRCELLGRP_And_NRCELL_Param_Modification_With_Obj_Locking_via_DC.robot
Resource          ../CB007188/VRAN_SyVe_CM_CB007188_5G_B_VDU_Parameter_Modification_with_Cell_Deletion_via_DC.robot
Resource          ../CB012523/VRAN_SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored.robot
Resource          ../CB012523/VRAN_SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts.robot
Resource          ../CB012523/VRAN_SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost.robot
Resource          ../CB012523/VRAN_SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled.robot
Resource          ../CB011058/VRAN_SyVe_CM_CB011058_CR_Static_HW_Properties_Pre-validation_In_MantaRay_NM.robot
Resource          ../CB009829/VRAN_SyVe_CB009829_003_004_Provision_Plan_Containing_Modifications_Parameters_that_Triggering_5G_RAT_Reset.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-E_002_Verify_CCN_On_O-RAN_O1_Interface_In_vDU.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-E_001_Verify_CCN_On_O-RAN_O1_Interface_In_vCU.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-E_004_Verify_CCN_On_O-RAN_O1_Interface_When_Resynchronization_In_vDU.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-E_003_Verify_CCN_On_O-RAN_O1_Interface_When_Resynchronization_In_vCU.robot
Resource          ../CB013998/VRAN_SyVe_CB013998_004_Modify_Parameters_With_RAT_Reset_vDU.robot
Resource          ../CB013998/VRAN_SyVe_CB013998_005_007_Modify_Parameters_With_Cell_Reset_vDU.robot
Resource          ../CB013998/VRAN_SyVe_CB013998_001_Modify_Parameters_With_RAT_Reset_CU.robot
Resource          ../CB013998/VRAN_SyVe_CB013998_002_003_Modify_Parameters_With_Cell_Reset_CU.robot
Resource          ../CB013998/VRAN_SyVe_CB013998_006_008_Modify_Parameters_With_RU_Reset_vDU.robot

Variables         ../TestCases/My_NetAct.py

*** Variables ***
${SRNCLAB}        SRNCLAB3007
${NETACT}         &{${SRNCLAB}}
${NETACT_CB009451_1}    &{${SRNCLAB}}
${SRNCLAB_11058}       SRNCLAB3006
${NETACT_CB011058}    &{${SRNCLAB_11058}}
&{ONAP}      host_ip=10.68.93.56    user=ute    pwd=uteUTE!
#${fhgw_ip}    10.108.194.23
#${fhgw_release}     FHGW22R4
#${fhgw_mr}     MRC-CB006543/MR-FHGW
${cu_ip}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${cu_release}    23R2VCU
${cu_mr}    MRC-CB006543/MR-vCU
${du_ip}     ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
${du_release}    23R2VDU
${du_mr}    MRC-CB006543/MR-vCU
${vDU_id}           ${tl.gnbs[0].dus[0].instance_id}
${vCU_id}           ${tl.gnbs[0].instance_id}
${Trunk_Prefix}    vDUCNF26R2
${Report_Rep}     ${False}
${CB006530_case6_QCName}    [1][1.0] SRAN_SyVe_CB006530_006__Removal_of_an_element_in_restriction_list_and_modification_of_that_parameter_in_the_same
${CB006530_long_common}    _delta_plan_via_WebEM_with_"Nemuadmin"_role_and_NetAct
${CB006530_case10_QCName}    [1][1.0] SRAN_SyVe_CB006530_010__Addition_of_restriction_list_and_accidental_parameter_modification_in_the_same
${7188_case1_codeName}    VRAN_SyVe_CM_CB007188_5G_B_VDU_Combine_Online_Modification_NRCELLGRP_And_NRCELL_Param_Modification_With_Obj_Locking_via_DC
${7188_case2_codeName}    VRAN_SyVe_CM_CB007188_5G_B_VDU_Parameter_Modification_with_Cell_Deletion_via_DC
${9829_case4_QCname_1}    [1][1.0] RAN_ST_CB009829_004_CM_CR_vDU_Provision plan containing modifications
${9829_case4_QCname_2}    to parameters that are triggering only 5G RAT reset with MantaRay NM Configurations UI


*** Test Cases ***
CB008936_003
    [Tags]    CB008936    QCD_MN_RAN    QCP_RAN_VRF    QC_33012    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    120 minutes
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    10.01.2022, lixin.kang@nokia-sbell.com, draft
    [Setup]    Run Keywords    Set Library Search Order    VRAN_SyVe_CM_Delta_Plan_Online_Validation_with_Validation_Scope_Setting_CB008936_003
    ...    AND    Case Precondition    False    False    #True    True
    TC__VRAN_SyVe_CM_Delta_Plan_Online_Validation_with_Validation_Scope_Setting_CB008936_003
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1.0] RAN_SyVe_CB008936_003_CM_Delta plan online validation in Netact with validation scope setting
    ...    33012

CB008660-A_001
    [Tags]    CB008660_001    QCD_MN_RAN    QCP_RAN_VRF    QC_33011    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    120 minutes
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    14.02.2022, yuyan.xu@nokia-sbell.com, draft
    [Setup]    Run Keywords
    ...    Set Library Search Order    VRAN_SyVe_CM_Reconfiguration_Of_Existing_Parameter_From_NetAct_CB008660-A_001
    ...    AND    Case Precondition    False    False    #True    True
    TC__VRAN_SyVe_CM_Reconfiguration_Of_Existing_Parameter_From_NetAct_CB008660-A_001
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1.0] VRAN_SyVe_CB008660-A_001_CM_Reconfiguration of existing distname-type parameter from NMS
    ...    33011

CB008660-A_004
    [Tags]    CB008660_004    QCD_MN_RAN    QCP_RAN_VRF    QC_33014    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    120 minutes
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    30.01.2022, lixin.kang@nokia-sbell.com, draft
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity_CB008660-A_004
    ...    AND    Case Precondition    False    False    #True    True
    TC__VRAN_SyVe_CM_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity_CB008660-A_004
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1.0] VRAN_SyVe_CB008660-A_004_CM_Adding an object breaking (or not) existing distname unambiguity to the live NE
    ...    33014

CB009451-F_001
    [Documentation]    Author: bin.7.Liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    2023-06-05, bin.7.Liu@nokia-sbell.com, draft
    [Tags]    CB009451-F_001    QCD_MN_RAN    QCP_RAN_VRF    QC_33006    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Setup]    Run Keywords    Set Library Search Order    VRAN_SyVe_CM_Configure_Optimize_Recalculate_Feature_Using_NetAct_CB009451-F_001
	...    AND    Set Test Variable    &{NETACT}    &{NETACT_CB009451_1}
    ...    AND    Case Precondition
    [Timeout]    120 minutes
    TC__VRAN_SyVe_CM_Configure_Optimize_Recalculate_Feature_Using_NetAct_CB009451-F_001
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1.0] RAN_ST_CB009451-F_001_CM_Configure optimize recalculate feature with Multi BTSs using NetAct    33006

CB009451-G_001
    [Documentation]    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    2023-07-05, lixin.kang@nokia-sbell.com, draft
    [Tags]    CB009451-G_001    QCD_MN_RAN    QCP_RAN_VRF    QC_32998    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_Audit_Recommended_Feature_Configuration_Using_NetAct_CB009451-G_001
    ...    AND    Set Test Variable    &{NETACT}    &{NETACT_CB009451_1}
    ...    AND    Case Precondition
    [Timeout]    120 minutes
    TC__VRAN_SyVe_CM_Audit_Recommended_Feature_Configuration_Using_NetAct_CB009451-G_001
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1.0] RAN_ST_CB009451-G_001_CM_Audit recommended feature configuration using NetAct
    ...    32998

CB006530_05
    [Documentation]    Author: bin.7.Liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    2024-05-16, bin.7.Liu@nokia-sbell.com
    [Tags]    CB006530_05    QCD_MN_RAN    QCP_RAN_VRF    QC_33001    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Setup]    Run Keywords    Set Library Search Order    VRAN_SyVe_CM_Delta_Plan_Restriction_Rules_Creation_From_NetAct_CB006530
    ...    AND    Case Precondition
    [Timeout]    120 minutes
    TC__VRAN_SyVe_CM_Delta_Plan_Restriction_Rules_Creation_From_NetAct_CB006530
    [Teardown]    Run Keywords     VRAN_SyVe_CM_Delta_Plan_Restriction_Rules_Creation_From_NetAct_CB006530.Case Postcondition
    ...    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1][1.0] RAN_ST_CB011169_CB006530_005_Creation_of_restriction_rules_in_a_delta_plan_via_WebEM_with_“Nemuadmin”_role_and_NetAct    33001


CB006530_10
    [Documentation]    Author: bin.7.Liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    2024-05-16, bin.7.Liu@nokia-sbell.com
    [Tags]    CB006530_10    QCD_MN_RAN    QCP_RAN_VRF    QC_32999    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Setup]    Run Keywords    Set Library Search Order    VRAN_SyVe_CM_Delta_Plan_Add_Rule_With_Modified_Restricted_Param_CB006530
    ...    AND    Case Precondition
    [Timeout]    120 minutes
    TC__VRAN_SyVe_CM_Delta_Plan_Add_Rule_With_Modified_Restricted_Param_CB006530
    [Teardown]    Run Keywords     VRAN_SyVe_CM_Delta_Plan_Restriction_Rules_Creation_From_NetAct_CB006530.Case Postcondition
    ...    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    ${CB006530_case10_QCName}${CB006530_long_common}    32999


CB006530_06
    [Documentation]    Author: bin.7.Liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    2024-05-16, bin.7.Liu@nokia-sbell.com
    [Tags]    CB006530_06    QCD_MN_RAN    QCP_RAN_VRF    QC_33000    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Setup]    Run Keywords    Set Library Search Order    VRAN_SyVe_CM_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param_CB006530
    ...    AND    Case Precondition
    [Timeout]    120 minutes
    TC__VRAN_SyVe_CM_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param_CB006530
    [Teardown]    Run Keywords     VRAN_SyVe_CM_Delta_Plan_Restriction_Rules_Creation_From_NetAct_CB006530.Case Postcondition
    ...    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    ${CB006530_case6_QCName}${CB006530_long_common}    33000

CB007188_001
    [Documentation]    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    15.10.2024, lixin.kang@nokia-sbell.com, draft
    [Tags]    CB007188_001    QCD_MN_RAN    QCP_RAN_VRF    QC_99191    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Setup]    Run Keywords    Set Library Search Order
    ...    ${7188_case1_codeName}
    ...    AND    ${7188_case1_codeName}.Case Precondition    False    False
    [Timeout]    120 minutes
    VRAN_SyVe_CM_CB007188_5G_B_VDU_Combine_Online_Modification_NRCELLGRP_And_NRCELL_Param_Modification_With_Obj_Locking_via_DC
    [Teardown]    Run Keywords    ${7188_case1_codeName}.Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1.0] CB007188_5G_B_VDU_Combine_Online_Modification_NRCELLGRP_Parameter_And_NRCELL_Parameter_Modification_With_Objeck_Locking_via_NOM_DC
    ...    99191

CB007188_002
    [Documentation]    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    15.10.2024, lixin.kang@nokia-sbell.com, draft
    [Tags]    CB007188_002    QCD_MN_RAN    QCP_RAN_VRF    QC_109321    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Setup]    Run Keywords    Set Library Search Order
    ...    ${7188_case2_codeName}
    ...    AND    ${7188_case2_codeName}.Case Precondition    False    False
    [Timeout]    120 minutes
    VRAN_SyVe_CM_CB007188_5G_B_VDU_Parameter_Modification_with_Cell_Deletion_via_DC
    [Teardown]    Run Keywords    ${7188_case2_codeName}.Case Postcondition
	...  AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1][1.0] CB007188_5G_B_VDU_Parameter_Modification_with_Cell_deletion_via_NOM_DC    109321

CB012523_001
    [Tags]    CB012523_001    QCD_MN_RAN    QCP_RAN_VRF    QC_100821    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    120 minutes
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    06.01.2025, yuyan.xu@nokia-sbell.com, draft
    [Setup]    Run Keywords
    ...    Set Library Search Order    VRAN_SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1][1.0] RAN_ST_CB012523-B_001_Cell graceful shutdown when M-Plane connection toward NMS is lost.
    ...    100821

CB012523_004
    [Tags]    CB012523_004    QCD_MN_RAN    QCP_RAN_VRF    QC_100822    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    120 minutes
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    06.01.2025, yuyan.xu@nokia-sbell.com, draft
    [Setup]    Run Keywords
    ...    Set Library Search Order    VRAN_SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1][1.0] RAN_ST_CB012523-B_004_Enable feature when NMS connection is already lost
    ...    100822

CB012523_005
    [Tags]    CB012523_005    QCD_MN_RAN    QCP_RAN_VRF    QC_100823    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    120 minutes
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    06.01.2025, yuyan.xu@nokia-sbell.com, draft
    [Setup]    Run Keywords
    ...    Set Library Search Order    VRAN_SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1][1.0] RAN_ST_CB012523-B_005_Prevent enable cells that has been disabled for another reason
    ...    100823

CB012523_006
    [Tags]    CB012523_006    QCD_MN_RAN    QCP_RAN_VRF    QC_109320    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    180 minutes
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    06.01.2025, yuyan.xu@nokia-sbell.com, draft
    [Setup]    Run Keywords
    ...    Set Library Search Order    VRAN_SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1][1.0] RAN_ST_CB012523-B_006_Prevent enable cells with status unlocked in case gNB restarts
    ...    109320

CB011058
    [Tags]    CB011058    QCD_MN_RAN    QCP_RAN_VRF    QC_161036    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    180 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order    VRAN_SyVe_CM_CB011058_CR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB011058_CR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB011058_001_CM_CR_Static HW properties pre-validation for RMOD_ANTL in MantaRay NM
    ...    161036

CB009829
    [Tags]    CB009829   QCD_MN_RAN    QCP_RAN_VRF    QC_122008    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    180 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CB009829_003_004_Provision_Plan_Containing_Modifications_Parameters_that_Triggering_5G_RAT_Reset
    ...    AND    Case Precondition
    VRAN_SyVe_CB009829_003_004_Provision_Plan_Containing_Modifications_Parameters_that_Triggering_5G_RAT_Reset
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    ${9829_case4_QCname_1} ${9829_case4_QCname_2}
    ...    122008

CB006092-E_001
    [Tags]    6092-1   QCD_MN_RAN    QCP_RAN_VRF    QC_185141    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order    VRAN_SyVe_CM_CB006092-E_001_Verify_CCN_On_O-RAN_O1_Interface_In_vCU
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-E_001_Verify_CCN_On_O-RAN_O1_Interface_In_vCU
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-E_001_CM_Verify CCN on O-RAN O1 interface in vCU
    ...    185141

CB006092-E_002
    [Tags]    6092-2   QCD_MN_RAN    QCP_RAN_VRF    QC_185142    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order    VRAN_SyVe_CM_CB006092-E_002_Verify_CCN_On_O-RAN_O1_Interface_In_vDU
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-E_002_Verify_CCN_On_O-RAN_O1_Interface_In_vDU
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-E_002_CM_Verify CCN on O-RAN O1 interface in vDU
    ...    185142

CB006092-E_003
    [Tags]    6092-3   QCD_MN_RAN    QCP_RAN_VRF    QC_185143    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_CB006092-E_003_Verify_CCN_On_O-RAN_O1_Interface_When_Resynchronization_In_vCU
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-E_003_Verify_CCN_On_O-RAN_O1_Interface_When_Resynchronization_In_vCU
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-E_003_CM_Verify CCN on O-RAN O1 interface when resynchronization in vCU
    ...    185143

CB006092-E_004
    [Tags]    6092-4   QCD_MN_RAN    QCP_RAN_VRF    QC_185144    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_CB006092-E_004_Verify_CCN_On_O-RAN_O1_Interface_When_Resynchronization_In_vDU
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-E_004_Verify_CCN_On_O-RAN_O1_Interface_When_Resynchronization_In_vDU
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-E_004_CM_Verify CCN on O-RAN O1 interface when resynchronization in vDU
    ...    185144

CB013998_001_CU
    [Tags]    13998_01   QCD_MN_RAN    QCP_RAN_VRF    QC_218529    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order    VRAN_SyVe_CB013998_001_Modify_Parameters_With_RAT_Reset_CU
    ...    AND    Case Precondition
    VRAN_SyVe_CB013998_001_Modify_Parameters_With_RAT_Reset_CU
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB013998_001_CM_CR_Modify in CU some parameter(s) with “Conditional RAT reset” modification type
    ...    218529

CB013998_002_CU
    [Tags]    13998_02   QCD_MN_RAN    QCP_RAN_VRF    QC_218530    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order    VRAN_SyVe_CB013998_002_003_Modify_Parameters_With_Cell_Reset_CU
    ...    AND    Case Precondition
    VRAN_SyVe_CB013998_002_003_Modify_Parameters_With_Cell_Reset_CU
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB013998_002_CM_CR_Modify in CU some parameter(s) with “Conditional cell reset” modification type
    ...    218530

CB013998_004_vDU
    [Tags]    13998_04   QCD_MN_RAN    QCP_RAN_VRF    QC_218531    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order    VRAN_SyVe_CB013998_004_Modify_Parameters_With_RAT_Reset_vDU
    ...    AND    Case Precondition
    VRAN_SyVe_CB013998_004_Modify_Parameters_With_RAT_Reset_vDU
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB013998_004_CM_CR_Modify in vDU some parameter(s) with “Conditional RAT reset” modification type
    ...    218531

CB013998_005_vDU
    [Tags]    13998_04   QCD_MN_RAN    QCP_RAN_VRF    QC_218532    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order    VRAN_SyVe_CB013998_005_007_Modify_Parameters_With_Cell_Reset_vDU
    ...    AND    Case Precondition
    VRAN_SyVe_CB013998_005_007_Modify_Parameters_With_Cell_Reset_vDU
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB013998_005_CM_CR_Modify in vDU some parameter(s) with “Conditional cell reset” modification type
    ...    218532

CB013998_006_vDU
    [Tags]    13998_06   QCD_MN_RAN    QCP_RAN_VRF    QC_218533    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order    VRAN_SyVe_CB013998_006_008_Modify_Parameters_With_RU_Reset_vDU
    ...    AND    Case Precondition
    VRAN_SyVe_CB013998_006_008_Modify_Parameters_With_RU_Reset_vDU
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB013998_006_CM_CR_Modify in vDU some parameter(s) with “Conditional RU reset” modification type
    ...    218533

*** Keywords ***
Report To Reporting Portal
    [Arguments]    ${test_run}    ${qc_instance_id}    ${status}=passed
    [Documentation]    Keyword send report to reporting portal and return link
    Run Keyword Unless  ${Report_Rep}    Return From Keyword
    ${qc_domain}=    set variable    MN_RAN
    ${qc_project}=    set variable    RAN_VRF
    ${ca}=    convert to string    RAN_PZ_HAZ_1
    &{empty_dict}=    Create Dictionary
    ${add_info}    Create List
    ${testline_name}    Set Variable    5G_Hangzhou_UTE5GAIC015T0011083
    log    ${testline_name}    console=${True}
    ${active_sw_version}    Get vDU Version
    ${current_prefix}    Set Variable    ${active_sw_version.split('_')[0].strip()}
    ${current_release}    Set Variable If    "${current_prefix}" == "${Trunk_Prefix}"    vDUCNF00    ${current_prefix}
    ${version_num}    Fetch From Right    ${active_sw_version}    _
    ${build}    Set Variable    ${current_release}_${version_num}
    ${link_to_reporting_portal}=    report to rp    qc_domain=${qc_domain}    qc_project=${qc_project}
    ...    name=${test_run}    result=${status}    ca=${ca}    build=${build}    links=&{empty_dict}    tool=Robot
    ...    add_info=${add_info}    testline=${testline_name}    qc_id=${qc_instance_id}
    set suite variable    ${LINK_TO_RP}    ${link_to_reporting_portal}