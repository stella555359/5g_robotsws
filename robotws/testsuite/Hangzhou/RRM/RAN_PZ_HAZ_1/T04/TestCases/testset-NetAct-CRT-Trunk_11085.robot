*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com

Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT
...      TRUNK

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../Resources/AIC_Utils.robot
#Resource          ../Resources/AIC_BTS_T04.robot
Resource          ../Resources/cm_ONAP.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-A_002_Upload_Full_Or_Part_From_SMO_When_VCU_In_Commission_State.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-A_004_Upload_Full_Or_Part_From_SMO_When_VDU_In_Commission_State.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-A_010_CM_Enable_Disable_O-RAN_O1_Netconf_Server_for_vCU.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-A_012_CM_Enable_Disable_O-RAN_O1_Netconf_Server_for_vDU.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-B_013_CM_Provision_Delta_Plan_for_VCU_from_SMO.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-B_014_CM_Provision_Delta_Plan_for_VDU_from_SMO.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-B_015_Creation_And_Deletion_Of_Managed_Object_In_vCU.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-B_016_Creation_And_Deletion_Of_Managed_Object_In_vDU.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-B_019_STATE_SW_Reset_Request_To_SBTS_Via_SWRESETREQ_Object_From_SMO_In_vDU_And_vCU.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-B_020_CM_STATE_HW_Reset_Request_to_SBTS_via_HWRESETREQ_object_from_SMO_in_vDU.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-B_021_Full_Commission_From_SMO_In_vCU.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-B_022_Full_Commission_From_SMO_In_vDU.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-C_003_Lock_Unlock_The_BTS_Running_Datastore_From_SMO_For_vCU_In_Commission_State.robot
Resource          ../CB006092/VRAN_SyVe_CM_CB006092-G_004_CNF_Registration_And_Stop-nfregistration_For_vDU_In_Commission_State.robot
Resource          ../CB007518/VRAN_SyVe_CB007518-B_002_CM_Online_Configuring_Predefined_RU_Then_Connect_To_BTS_With_Manual_Installation.robot
Resource          ../CB007518/VRAN_SyVe_CB007518-B_003_CM_BTS_Startup_With_Predefined_RU_Then_Connect_To_BTS_With_Automatic_Installation.robot
Variables         ../TestCases/My_NetAct.py

*** Variables ***
${SRNCLAB}        SRNCLAB1019
${NETACT}         &{${SRNCLAB}}
&{ONAP}      host_ip=10.106.245.34    user=ute    pwd=uteUTE!
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
${vCU_oamssh_ip}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${vDU_oamssh_ip}    ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}

*** Test Cases ***
CB006092-A_002
    [Tags]    6092-A-2    QCD_MN_RAN    QCP_RAN_VRF    QC_226581    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
	...    VRAN_SyVe_CM_CB006092-A_002_Upload_Full_Or_Part_From_SMO_When_VCU_In_Commission_State
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-A_002_Upload_Full_Or_Part_From_SMO_When_VCU_In_Commission_State
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-A_002_CM_Upload full or part from SMO when VCU in comission state
    ...    226581

CB006092-A_004
    [Tags]    6092-A-4    QCD_MN_RAN    QCP_RAN_VRF    QC_226576    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
	...    VRAN_SyVe_CM_CB006092-A_004_Upload_Full_Or_Part_From_SMO_When_VDU_In_Commission_State
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-A_004_Upload_Full_Or_Part_From_SMO_When_VDU_In_Commission_State
    [Teardown]    Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-A_004_CM_Upload full or part from SMO when VDU in comission state
    ...    226576

CB006092-A_010
    [Tags]    6092-A-10    QCD_MN_RAN    QCP_RAN_VRF    QC_226580    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_CB006092-A_010_CM_Enable_Disable_O-RAN_O1_Netconf_Server_for_vCU
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-A_010_CM_Enable_Disable_O-RAN_O1_Netconf_Server_for_vCU
    [Teardown]   Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-A_010_CM_Enable_Disable O-RAN O1 Netconf server for vCU
    ...    226580

CB006092-A_012
    [Tags]    6092-A-12    QCD_MN_RAN    QCP_RAN_VRF    QC_226582    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_CB006092-A_012_CM_Enable_Disable_O-RAN_O1_Netconf_Server_for_vDU
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-A_012_CM_Enable_Disable_O-RAN_O1_Netconf_Server_for_vDU
    [Teardown]   Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-A_012_CM_Enable_Disable O-RAN O1 Netconf server for vDU
    ...    226582

CB006092-B_013
    [Tags]    6092-B-13    QCD_MN_RAN    QCP_RAN_VRF    QC_228125    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_CB006092-B_013_CM_Provision_Delta_Plan_for_VCU_from_SMO
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-B_013_CM_Provision_Delta_Plan_for_VCU_from_SMO
    [Teardown]   Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-B_013_CM_Provision delta plan for SBTS from SMO for vCU
    ...    228125

CB006092-B_014
    [Tags]    6092-B-14    QCD_MN_RAN    QCP_RAN_VRF    QC_228129    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_CB006092-B_014_CM_Provision_Delta_Plan_for_VDU_from_SMO
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-B_014_CM_Provision_Delta_Plan_for_VDU_from_SMO
    [Teardown]   Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-B_014_CM_Provision delta plan for SBTS from SMO for vDU
    ...    228129

CB006092-B_015
    [Tags]    6092-B-15    QCD_MN_RAN    QCP_RAN_VRF    QC_228126    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_CB006092-B_015_Creation_And_Deletion_Of_Managed_Object_In_vCU
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-B_015_Creation_And_Deletion_Of_Managed_Object_In_vCU
    [Teardown]   Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-B_015_CM_Creation and Deletion of managed object for vCU
    ...    228126

CB006092-B_016
    [Tags]    6092-B-16    QCD_MN_RAN    QCP_RAN_VRF    QC_228130    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_CB006092-B_016_Creation_And_Deletion_Of_Managed_Object_In_vDU
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-B_016_Creation_And_Deletion_Of_Managed_Object_In_vDU
    [Teardown]   Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-B_016_CM_Creation and Deletion of managed object for vDU
    ...    228130

CB006092-B_019
    [Tags]    6092-B-19    QCD_MN_RAN    QCP_RAN_VRF    QC_228131    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_CB006092-B_019_STATE_SW_Reset_Request_To_SBTS_Via_SWRESETREQ_Object_From_SMO_In_vDU_And_vCU
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-B_019_STATE_SW_Reset_Request_To_SBTS_Via_SWRESETREQ_Object_From_SMO_In_vDU_And_vCU
    [Teardown]   Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-B_019_CM_STATE_SW reset request to SBTS via SWRESETREQ object from SMO in vDU and vCU
    ...    228131

CB006092-B_020
    [Tags]    6092-B-20    QCD_MN_RAN    QCP_RAN_VRF    QC_228128    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    60 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_CB006092-B_020_CM_STATE_HW_Reset_Request_to_SBTS_via_HWRESETREQ_object_from_SMO_in_vDU
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-B_020_CM_STATE_HW_Reset_Request_to_SBTS_via_HWRESETREQ_object_from_SMO_in_vDU
    [Teardown]   Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-B_020_CM_STATE_HW reset request to SBTS via HWRESETREQ object from SMO in vDU
    ...    228128

CB006092-B_021
    [Tags]    6092-B-21    QCD_MN_RAN    QCP_RAN_VRF    QC_228127    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    120 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_CB006092-B_021_Full_Commission_From_SMO_In_vCU
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-B_021_Full_Commission_From_SMO_In_vCU
    [Teardown]   Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-B_021_CM_Full commission from SMO in vCU
    ...    228127

CB006092-B_022
    [Tags]    6092-B-22    QCD_MN_RAN    QCP_RAN_VRF    QC_228132    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    120 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_CB006092-B_022_Full_Commission_From_SMO_In_vDU
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-B_022_Full_Commission_From_SMO_In_vDU
    [Teardown]   Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_ST_CB006092-B_022_CM_Full commission from SMO in vDU
    ...    228132

CB006092-C_003
    [Tags]    6092-C-003    QCD_MN_RAN    QCP_RAN_VRF    QC_238844    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    120 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_CB006092-C_003_Lock_Unlock_The_BTS_Running_Datastore_From_SMO_For_vCU_In_Commission_State
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-C_003_Lock_Unlock_The_BTS_Running_Datastore_From_SMO_For_vCU_In_Commission_State
    [Teardown]   Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    RAN_ST_CB006092-C_003_CM_Lock_Unlock the BTS Running Datastore from SMO for vCU in commission state
    ...    238844

CB006092-G_004
    [Tags]    6092-G-004    QCD_MN_RAN    QCP_RAN_VRF    QC_235135    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    120 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_CB006092-G_004_CNF_Registration_And_Stop-nfregistration_For_vDU_In_Commission_State
    ...    AND    Case Precondition
    VRAN_SyVe_CM_CB006092-G_004_CNF_Registration_And_Stop-nfregistration_For_vDU_In_Commission_State
    [Teardown]   Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    RAN_ST_CB006092-G_004_CM_CNF Registration and stop-nfregistration for vDU in commission state
    ...    235135

CB007518-B_002
    [Tags]    7518-B_002    QCD_MN_RAN    QCP_RAN_VRF    QC_233800    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    120 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CB007518-B_002_CM_Online_Configuring_Predefined_RU_Then_Connect_To_BTS_With_Manual_Installation
    ...    AND    Case Precondition
    VRAN_SyVe_CB007518-B_002_CM_CR_Online configuring pre-defined RU and then connect to BTS with manual installation
    [Teardown]   Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_SyVe_CB007518-B_002_CM_CR_Online configuring pre-defined RU and then connect to BTS with manual installation
    ...    233800

CB007518-B_003
    [Tags]    7518-B_003    QCD_MN_RAN    QCP_RAN_VRF    QC_233801    CA_RAN_PZ_HAZ_1    CLOUD_5G_AIC_SA_1XvDU_OE20_1XFHGW_1XAZQI_11085
    [Timeout]    120 minutes
    [Documentation]
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CB007518-B_003_CM_BTS_Startup_With_Predefined_RU_Then_Connect_To_BTS_With_Automatic_Installation
    ...    AND    Case Precondition
    VRAN_SyVe_CB007518-B_003_CM_CR_BTS startup with pre-defined RU and then connect to BTS with automatic installation
    [Teardown]   Run Keywords    Case Postcondition    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1]RAN_SyVe_CB007518-B_003_CM_CR_BTS startup with pre-defined RU and then connect to BTS with automatic installation
    ...    233801

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