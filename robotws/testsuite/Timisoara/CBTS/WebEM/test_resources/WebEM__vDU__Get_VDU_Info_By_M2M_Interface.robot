*** Settings ***
Documentation
    ...  This TC checks VDU information using M2M interface and taf library.
    ...  M2M output is checked to have the same values for all parameters as taf output from
    ...  get_vdu_state_data method.
    ...  If there is one valid parameter from taf output which is not visible or it does not have
    ...  the expected value in M2M output, TC will fail.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/M2M_Interface.robot


*** Keywords ***
TC__WebEM__vDU__Get_VDU_Info_By_M2M_Interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26615
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  18.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26615 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-mihai-adrian.pirjol@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  FEATURE-CB010545

    Step1: Get VDU Info Through M2M Interface
    Step2: Check VDU Info To Be As Expected


Step1: Get VDU Info Through M2M Interface
    Log  \nStep1: Get VDU info through M2M interface  console=true
    ${vdu_info}  Run M2M Command  GET  https://10.15.255.186/api/licensed/v1/vdu  Bearer  ${TOKEN}
    ${vdu_info}  Remove M2M Output Noise  ${vdu_info}
    ${vdu_info}  Fetch From Left  ${vdu_info}  curl
    ${vdu_info}  Fetch From Left  ${vdu_info}  \n
    ${vdu_info}  Change Keys Names According To Taf Output  ${vdu_info}
    ${vdu_info}  Evaluate  json.loads('''${vdu_info}''')  json
    Set Test Variable  ${VDU_INFO_M2_M_INTERFACE}  ${vdu_info}


Step2: Check VDU Info To Be As Expected
    Log  \nStep2: Check VDU info to be as expected  console=true
    ${vdu_state_data}  vdu.Get VDU State Data
    FOR  ${parameter}  IN  @{vdu_state_data}
        Run Keyword If  '${parameter}'=='ip_addresses'
        ...  Run Keywords
        ...  Check Ip Addresses  ${VDU_INFO_M2_M_INTERFACE}[${parameter}]  ${vdu_state_data}[${parameter}]
        ...  AND
        ...  Continue For Loop
        Should Be Equal As Strings  ${VDU_INFO_M2_M_INTERFACE}[${parameter}]  ${vdu_state_data}[${parameter}]
        ...  ${VDU_INFO_M2_M_INTERFACE}[${parameter}] parameter doesn't have the expected value.
    END


Change Keys Names According To Taf Output
    [Arguments]  ${vdu_info}

    ${vdu_info_keys}  Create Dictionary  cuName=cu_name  f1CLinkStatusDU=f1_c_link_status_du  id=id  ipAddresses=ip_addresses
    ...  cuF1CIpAddress=cu_f1_c_ip_address  f1CIpAddress=f1_c_ip_address  f1UIpAddresses=f1_u_ip_address  mPlaneIpAddress=m_plane_ip_address  v4=ipv4
    ...  v6=ipv6  mncLength=mnc_length  mrbtsId=mrbts_id  nrDuId=nr_du_id  nrbtsId=nrbts_id  numberOfAlarms=number_of_alarms
    ...  operationalState=operational_state  softwareVersion=software_version  timeZone=time_zone
    FOR  ${key}  IN  @{vdu_info_keys}
        ${vdu_info}  Replace String  ${vdu_info}  ${key}  ${vdu_info_keys}[${key}]
    END

    [Return]  ${vdu_info}


Check Ip Addresses
    [Arguments]  ${interfaces_m2m}  ${interfaces_taf}

    Should Be Equal As Strings  ${interfaces_m2m}[cu_f1_c_ip_address]  ${interfaces_taf}[cu_f1_c_ip_address]
    ...  cu_f1_c_ip_address parameter doesn't have the expected value.
    ${ip_interfaces}  Create List  f1_c_ip_address  m_plane_ip_address
    FOR  ${ip_interface}  IN  @{ip_interfaces}
        Check Ipv4 And Ipv6  ${interfaces_m2m}[${ip_interface}]  ${interfaces_taf}[${ip_interface}]  ${ip_interface}
    END
    ${length}  Get Length  ${interfaces_m2m}[f1_u_ip_address]
    FOR  ${index}  IN RANGE  0  ${length}
        Check Ipv4 And Ipv6  ${interfaces_m2m}[f1_u_ip_address][${index}]  ${interfaces_taf}[f1_u_ip_address][${index}]  f1_u_ip_address
    END


Check Ipv4 And Ipv6
    [Arguments]  ${m2m_dict}  ${taf_dict}  ${ip_interface}

    Run Keyword If  '${taf_dict}[ipv4]'!='None'
    ...  Should Be Equal As Strings  ${m2m_dict}[ipv4]  ${taf_dict}[ipv4]  ${ip_interface} parameter doesn't have the expected value fpr ipv4.
    Run Keyword If  '${taf_dict}[ipv6]'!='None'
    ...  Should Be Equal As Strings  ${m2m_dict}[ipv6]  ${taf_dict}[ipv6]  ${ip_interface} parameter doesn't have the expected value for ipv6.


TC Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__Get_VDU_Info_By_M2M_Interface
    Login Using M2M Interface  ${VDU_OAM_IP}


TC Teardown
    Logout Using M2M Interface  ${VDU_OAM_IP}
    Common VDU Teardown
