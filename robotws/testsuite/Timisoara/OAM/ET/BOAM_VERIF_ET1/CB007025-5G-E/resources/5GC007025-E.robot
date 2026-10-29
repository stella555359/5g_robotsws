*** Settings ***
Documentation
...    Author: Radu Turcu (radu.turcu@nokia.com)
...    Maintainer: Radu Turcu (radu.turcu@nokia.com)

#Resource  ../../vduResources/vduSelenium.robot
Resource  ../../vduResourcesAIC/aic_common_resources.robot
#Resource  ../../vduResourcesAIC/aic_common_resources_new.robot

*** Variables ***
${NEW_PLAN_NAME}=  XXX
${expected_fhm_IPinterface_name}=  fhm
${expected_dest_ip_addr}=  10.15.254.233
${expected_gateway}=  10.15.254.233
${expected_fhmplane}=  fhmplane
${expected_localipaddr}=  192.168.254.33
${expected_dest_ip_addr_tnl}=   192.168.254.0
${expected_dest_prefix}=  26
${expected_route}=  direct

*** Keywords ***

Create_a_new_vDU_configuration_file_with_TNL_configuration_Type_OAMFH
    VDU Rest Login
    @{fault_id_list}  create list   7505  23  1931  10
#    VDU Active Alarm Should Not Contain Fault ID  @{fault_id_list}
    ${scf_path}  Get A Directory  Get A Directory  /home/ute/robotws/results/
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    Delete Plan  plan_name=${NEW_PLAN_NAME}
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=/home/ute/robotws/results/
    ...  filename=scf.xml  include_runtime_data=${True}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${VDU_CONF}  Get VDU Conf From SCF   scf_path=${scf_file_with_fullpath}
    ${all_BTS_ID}    Get BTS ID From vDU SCF    scf_path=${scf_file_with_fullpath}
    set test variable    ${MRBTS_ID}    ${all_BTS_ID[0]}
    ${TNLconf}  Get parameters from VDU scf
    Check TNL Configuration   ${TNLconf}

Check_a_new_OAM-FH_process_added_inside_to_OAM-FH Pod
    Check pod OAMFH is running
    Connect to OAMFH container
    Check OAMFH Process
    [teardown]    Exit From Container

Check pod OAMFH is running
    ${vdu_namespace}   Get VDU Namespace From TestLine    vdu_index=0
    vDU Pod Status Should Be As Expected    expect_status=Running  pod_name=po-cran1-oamfh-0  namespace=${vdu_namespace}

Check OAMFH Process
    ${GETPROCESS}=   Execute Command In Container    ps -def | grep OAMFH
    Should contain  ${GETPROCESS}  OAMFH/run.sh

Connect to OAMFH container
    Connect To vDU Container  po-cran1-oamfh-0    ctr-cran1-oamfh   cran1  vdu_index=${0}


Case Precondition
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    ${SUITE_LOG_DIRECTORY}=    Get A Directory
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}
#    Log To Console   \nStep0: PRECONDITIONS AND Download SCF
    ${rmod_id_list}=    Get RMOD ID List
    ${rmod_number}=    get length    ${rmod_id_list}
    LOG TO CONSOLE   \nRUs installed = ${rmod_number}
#    VDU Rest Login
#    Run Keyword If  ${rmod_number} < 2  Upload Plan And Validate And Activate
#    ...   plan_file=/home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB008022-5G-CLOUD/resources/scf2RUs.xml
#    ...   plan_name=${NEW_PLAN_NAME}  wait_vdu_up=True
    VDU Rest Login
    @{fault_id_list}  create list   7505  23  1931  10
    Wait until keyword succeeds  25 min  30 sec  VDU Active Alarm Should Not Contain Fault ID  @{fault_id_list}
    Wait until keyword succeeds  40 min  90 sec  vDU Verify All Cells Status Should Be Onair

Case Postcondition
    Log To Console   RESTORE INITIAL CONFIGURATION - TBD
#    Delete Plan  plan_name=${NEW_PLAN_NAME}
#    ${PLAN_ID}    ${ACTION_ID}   ${VALIDATION_ID}   Upload Plan And Validate And Activate
#    ...   plan_file=/home/ute/robotws/results/scf.xml
#    ...   plan_name=${NEW_PLAN_NAME}  wait_vdu_up=True
#    Run Keyword And Ignore Error  VDU Rest Logout

Get RMOD ID List
    ${rmod_id_list}=  create list
    vdu rest login
    ${rmods_info}=   vdu.get_rmods_status
    FOR  ${rmod}  IN  @{rmods_info}
        append to list   ${rmod_id_list}   ${rmod["id"]}
    END
    [Return]   ${rmod_id_list}
    [Teardown]  VDU Rest Logout

Get parameters from VDU scf
    [Arguments]  ${scf_path}=${EMPTY}   ${vdu_index}=0   ${gnb_index}=0  ${nr}=6  ${path_tnl}=MRBTS-${mrbts_id}/TNLSVC-1/TNL-${nr}

    ${scf_path}   run keyword if  "${scf_path}"=="${EMPTY}"  Get Temporary Scf From Current Plan    gnb_index=${gnb_index}  vdu_index=${vdu_index}
       ...    ELSE    set variable  ${scf_path}

    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    ${fhm_IPinterface_name}  scf.get_value_from_scf   dist_name=MRBTS-${mrbts_id}/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1
    ...  p_name=uniqueIpAddressIdentifier
    ${fhmplane}  scf.get_value_from_scf   dist_name=MRBTS-${mrbts_id}/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-1  p_name=vlanIfName
    ${gateway}  scf.get_value_from_scf   dist_name=MRBTS-${mrbts_id}/TNLSVC-1/TNL-4/IPNO-1/IPRT-1  p_name=gateway
    ${dest_ip_addr}  scf.get_value_from_scf   dist_name=MRBTS-${mrbts_id}/TNLSVC-1/TNL-4/IPNO-1/IPRT-1   p_name=destIpAddr

    @{ListCmdS1}        Create List     6  7  8  9
    FOR   ${nr}    IN    @{ListCmdS1}
           ${ip_addr}  scf.get_value_from_scf
    ...  dist_name=MRBTS-${mrbts_id}/TNLSVC-1/TNL-${nr}/IPNO-1/IPIF-1/IPADDRESSV4-1/IPADDRESSV4_R-1  p_name=localIpAddrAllocated
           Run Keyword If	'${ip_addr}' == '192.168.254.33'	Exit For Loop
    END

    ${localipaddr}  scf.get_value_from_scf  dist_name=${path_tnl}/IPNO-1/IPIF-1/IPADDRESSV4-1/IPADDRESSV4_R-1  p_name=localIpAddrAllocated
    ${dest_ip_addr_tnl}  scf.get_value_from_scf  dist_name=${path_tnl}/IPNO-1/IPRT-1/IPRT_R-1   p_name=destIpAddr
#    ${adress_object}  scf.get_value_from_scf  dist_name=${path_tnl}/IPNO-1/IPIF-1/IPADDRESSV4-1/IPADDRESSV4_R-1  p_name=ipAddressV4RId
    ${dest_prefix}  scf.get_value_from_scf  dist_name=${path_tnl}/IPNO-1/IPRT-1/IPRT_R-1  p_name=destinationIpPrefixLength
#    ${ipfdn}  scf.get_value_from_scf  dist_name=${path_tnl}/IPNO-1/IPRT-1/IPRT_R-1  p_name=ipfDN
    ${route}  scf.get_value_from_scf  dist_name=${path_tnl}/IPNO-1/IPRT-1/IPRT_R-1  p_name=routeType
#    ${iprt}  scf.get_value_from_scf  dist_name=${path_tnl}/IPNO-1/IPRT-1/IPRT_R-1  p_name=ipRtRId
    ${conf}   create dictionary
    ...  mrbts_id=${mrbts_id}
    ...  nrbts_id=${nrbts_id}
    ...  nrdu_id=${nrdu_id}
    ...  fhm_IP_name=${fhm_IPinterface_name}
    ...  gateway=${gateway}
    ...  dest_ip_addr=${dest_ip_addr}
#    ...  local_Ip_addr_alocated=${local_Ip_addr_alocated}
    ...  fhmplane=${fhmplane}
    ...  localipaddr=${localipaddr}
    ...  dest_ip_addr_tnl=${dest_ip_addr_tnl}
#    ...  adress_object=${adress_object}
    ...  dest_prefix=${dest_prefix}
#    ...  ipfdn=${ipfdn}
    ...  route=${route}
#    ...  iprt=${iprt}
    [Return]  ${conf}

Check TNL Configuration
    [Arguments]  ${TNLconf}

    ${fhm_IPinterface_name}=    Get from dictionary    ${TNLconf}    fhm_IP_name
    Run Keyword If    '${fhm_IPinterface_name}' == '${expected_fhm_IPinterface_name}'
    ...  Log to Console   fhm param is correct

    ${gateway}=    Get from dictionary    ${TNLconf}    gateway
    Run Keyword If    '${gateway}' == '${expected_gateway}'
    ...  Log to Console   gateway param is correct

    ${dest_ip_addr}=    Get from dictionary    ${TNLconf}    dest_ip_addr
    Run Keyword If    '${dest_ip_addr}' == '${expected_dest_ip_addr}'
    ...  Log to Console   dest_ip_addr param is correct

    ${fhmplane}=    Get from dictionary    ${TNLconf}    fhmplane
    Run Keyword If    '${fhmplane}' == '${expected_fhmplane}'
    ...  Log to Console   fhmplane param is correct

    ${localipaddr}=    Get from dictionary    ${TNLconf}    localipaddr
    Run Keyword If    '${localipaddr}' == '${expected_localipaddr}'
    ...  Log to Console   localipaddr param is correct

    ${dest_ip_addr_tnl}=   Get from dictionary    ${TNLconf}  dest_ip_addr_tnl
    Run Keyword If    '${dest_ip_addr_tnl}' == '${expected_dest_ip_addr_tnl}'
    ...  Log to Console   dest_ip_addr_tnl param is correct

    ${dest_prefix}=   Get from dictionary    ${TNLconf}  dest_prefix
    Run Keyword If    '${dest_prefix}' == '${expected_dest_prefix}'
    ...  Log to Console   dest_prefix param is correct

    ${route}=   Get from dictionary    ${TNLconf}  route
    Run Keyword If    '${route}' == '${expected_route}'
    ...  Log to Console   expected_route param is correct

