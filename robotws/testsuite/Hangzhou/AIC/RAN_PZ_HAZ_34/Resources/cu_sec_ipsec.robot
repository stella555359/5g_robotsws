*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_sec_ipsec.robot



*** Variables ***
&{IPSECC_PARA_DICT}    authenticationScheme=CERTIFICATE
...  ikeDscp=36
...  ipFragmentationAlgorithm=Pre-fragmentation
...  ipSecEnabled=true
...  ipSeccId=1

&{IKEP_PARA_DICT}   connectionEstablishmentMode=INITIATOR_AND_RESPONDER
...  dpdDelay=10
...  ikeAuthenticationMethod=AUTH_HMAC_SHA2_512_256
...  ikeDiffHellGrp=DH19
...  ikeEncryptionMethod=ENC_AES_256_CBC
...  ikeMaxLifeTime=86400
...  ipsecPerfForwSecEnabled=true
...  ikeReauthEnabled=true
...  prfMethod=PRF_DEFAULT
...  ikePId=1
...  localTunnelEndpointDN=${EMPTY}
...  remoteTunnelEndpoint=${EMPTY}

&{IPSECP_PARA_DICT}   antiReplayEnabled=true
...  antiReplayWindowSize=SIZE_512
...  authenticationMethod=AUTH_HMAC_SHA2_256_128
...  encryptionMethod=ENC_AES_256_CBC
...  extendedSequenceNumberMode=NORMAL_SEQUENCE
...  pfsDiffHellGrp=DH19
...  saMaxLifeTime=86400
...  ipSecpId=1

&{SECPOL_PARA_DICT}  ikePDN=${EMPTY}
...  ipSecAction=PROTECT
...  policyOrderNumber=2
...  secPolId=1
...  ipSecPDN=${EMPTY}
...  trafficSelectorList=${EMPTY}
...  trafficSelectorList/0/localIpAddress=${EMPTY}
...  trafficSelectorList/0/localIpPort=-1
...  trafficSelectorList/0/localIpPrefixLength=32
...  trafficSelectorList/0/protocol=-1
...  trafficSelectorList/0/remoteIpAddress=${EMPTY}
...  trafficSelectorList/0/remoteIpPort=-1
...  trafficSelectorList/0/remoteIpPrefixLength=32



*** Keywords ***
Vcu Delta Delete All Ipsec Configurations
    [Arguments]   ${tnl_id}=1
    [Documentation]   Vcu Delta Delete All Ipsec Configurations
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...  Change History
    ...  10.10.2023   chris.l.cao@nokia-sbell.com, use 'Get VCU SCF From Current Plan', 'CU Activate Delta Plan Should Be Successful'
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | tnl_id  | yes | tnl id where to configure ipsec |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | CU Login |
    ...    | Vcu Delta Delete All Ipsec Configurations | 2 |
    ...    | CU Logout |
    ...
    wait until keyword succeeds  5min   10s    CU Rest Login
    ${scf_full_path}  Get VCU SCF From Current Plan
    scf.Load Scf   ${scf_full_path}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_full_path}
    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
    Return From Keyword If   "${ipapp_exists}"=="False"
    ${delta_plan_id}=  CU Generate Delta Plan Should Be Successful
    CU Delete Delta Plan Managed Object Should Be Successful
    ...  plan_id=${delta_plan_id}
    ...  mo_dn=${ipapp_dist_name}

    ${uni_id}   Get Unique Id
    ${scf_full_path}  Get A File    scf    vcu_delta_delete_ipsec_scf_${uni_id}.xml
    cu.Save Delta Plan File    ${delta_plan_id}   ${scf_full_path}
    CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
#    ${active_res}=   cu.activate_delta_plan   plan_id=${delta_plan_id}
#	Wait until keyword succeeds  3x  30s
#	...  _Activating Delta Plan Operation Should Be Successful   plan_id=${delta_plan_id}
#	...  operation_id=${active_res['operation_id']}
    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}


Vcu Delta Config Ipsec
    [Arguments]   ${ipsec_para_list}   ${tnl_id}=1
    [Documentation]   Vcu Delta Config Ipsec
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ipsec_para_list  | yes | list of ipsec parameters dict |
    ...    | tnl_id  | yes | tnl id where to configure ipsec |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | CU Login |
    ...    | Vcu Delta Config Ipsec | ${ipsec_para_list} | 2 |
    ...    | CU Logout |
    ...
    wait until keyword succeeds  5min   10s    CU Rest Login
#    ${uni_id}   Get Unique Id
#    ${scf_full_path}  Get A File    scf    vcu_scf_${uni_id}.xml
#    cu.Get Current Plan File   path=${scf_full_path}  timeout=60  include_runtime_data=${True}
    ${scf_full_path}    Get VCU SCF From Current Plan
    scf.Load Scf   ${scf_full_path}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_full_path}
    ${delta_plan_id}=  CU Generate Delta Plan Should Be Successful
    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
    ${prefix}   ${rest}   Split String From Right   ${ipapp_dist_name}   /   1
    ${prefix1}   ${index}   Split String From Right   ${rest}   -   1

    Run Keyword If   "${ipapp_exists}"=="False"  CU Create Delta Plan Managed Object Should Be Successful
    ...  plan_id=${delta_plan_id}
    ...  mo_dn=${prefix}
    ...  name=com.nokia.srbts.tnl:IPAPP  instance_id=${index}
    FOR   ${item}   IN   @{ipsec_para_list}
      Sleep  1s
       _Vcu Delta Config Ipsec Paras  ${item}  ${tnl_id}  ${mrbts_id}  ${delta_plan_id}
    END

    ${uni_id}   Get Unique Id
    ${scf_full_path}  Get A File    SCF    vcu_delta_add_ipsec_scf_${uni_id}.xml
    cu.Save Delta Plan File    ${delta_plan_id}   ${scf_full_path}
    CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
#    ${active_res}=   cu.activate_delta_plan   plan_id=${delta_plan_id}
#	Wait until keyword succeeds  3x  30s
#	...  _Activating Delta Plan Operation Should Be Successful   plan_id=${delta_plan_id}
#	...  operation_id=${active_res['operation_id']}

    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}


_Vcu Delta Config Ipsec Paras
    [Arguments]  ${para_dict}  ${tnl_id}  ${mrbts_id}  ${plan_id}
    [Documentation]   Vcu Delta Config Ipsec Paras
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_dict  | yes | ipsec parameters dict |
    ...    | tnl_id  | yes | tnl id where to configure ipsec |
    ...    | mrbts_id | yes | mrbts id |
    ...    | plan_id | yes | delta plan id |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | _Vcu Delta Config Ipsec Paras | ${item} | ${tnl_id} | ${mrbts_id} | ${delta_plan_id} |
    ${para_dict_local}  copy dictionary   ${para_dict}   deepcopy=${TRUE}
    ${ipsec_mo_list}=   Create List   ipSeccId  ikePId  ipSecpId  secPolId
    ${mo_name}   Set Variable
    ${mo_id}   Set Variable
    FOR   ${item}   IN   @{ipsec_mo_list}
       ${res}   Run Keyword And Ignore Error   Pop From Dictionary  ${para_dict_local}  ${item}
       ${mo_name}  Set Variable If  '${res[0]}'=='PASS'  ${item}   ${EMPTY}
       ${mo_id}  Set Variable If  '${res[0]}'=='PASS'  ${res[1]}   ${EMPTY}
       Exit For Loop If    '${res[0]}'=='PASS'
    END

    ${distname}   Set Variable If
    ...  '${mo_name}'=='ipSeccId'  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1/IPSECC-${mo_id}
    ...  '${mo_name}'=='ikePId'  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1/IPSECC-1/IKEP-${mo_id}
    ...  '${mo_name}'=='ipSecpId'  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1/IPSECC-1/IPSECP-${mo_id}
    ...  '${mo_name}'=='secPolId'  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1/IPSECC-1/SECPOL-${mo_id}

    ${prefix}   ${rest}   Split String From Right   ${distname}   /   1
    ${prefix1}   ${index}   Split String From Right   ${rest}   -   1
    ${exists}  scf.Is Object In Scf   ${distname}
    ${operate}   Set Variable If  ${exists}  replace  add
    Run Keyword If     "${exists}"=="False"  CU Create Delta Plan Managed Object Should Be Successful
    ...  plan_id=${plan_id}
    ...  mo_dn=${prefix}
    ...  name=com.nokia.srbts.tnl:${prefix1}  instance_id=${index}
    &{trafficSelectorList}  Create Dictionary   operation_type=add    parameter_path=/trafficSelectorList
    ${keys}  Get Dictionary Keys    ${para_dict}
    @{Para_list}=    Create List
    ${traffic_selector_flag}   Set Variable   ${False}
    FOR   ${key}   IN   @{keys}
       ${value}  get_from_dictionary   ${para_dict}  ${key}
       ${key}  Set Variable If  '${key.startswith("/")}'=='False'  /${key}  ${key}
       ${traffic_selector_flag}  Set Variable If  'key'=='/trafficSelectorList'   ${True}  ${traffic_selector_flag}
       &{para}  Create Dictionary   operation_type=${operate}  parameter_path=${key}  value=${value}
       Log Dictionary    ${para}
       append_to_list  ${Para_list}   ${para}
    END

    Run Keyword If  '${mo_name}'=='secPolId' and '${traffic_selector_flag}'=='False'  Insert Into List
    ...  ${Para_list}   0  ${trafficSelectorList}

    Log List  ${Para_list}
    CU Update Delta Plan Should Be Successful  plan_id=${plan_id}  mo_dn=${distname}
	...  parameter_change_list=${Para_list}

Vcu Ipsec Tunnel Should Be Established
    [Arguments]  ${pod_abbr}  ${local_ip}  ${remote_ip}  ${protocol}=any
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   ${alias_cu}
    [Documentation]   vcu ipsec tunnel should be established via cli check
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ${pod_abbr}    | yes | pod_abbr for vcu |
    ...    | local_ip  | yes | ipsec tunnel local ip |
    ...    | remote_ip  | yes | ipsec tunnel renmote ip |
    ...	  | protocol | no | ipsec protocol type: any/udp/sctp |
    ...    *RETURN VALUE*
    ...    output of ipsec statusall
    ...
    ...    Example
    ...    | Vcu Ipsec Tunnel Should Be Established  | upue | 1.1.1.1 | 2.2.2.2 |
    Log To Console    LOOP_pod_abbr=${pod_abbr}
    ${alias_cu}=    Connect To CU K8S Master With Tenant
    ${out}=    CU Kubectl Exec    pod_abbr=${pod_abbr}    container=ipsecmgmt
    ...    command=ipsec statusall
    ...    alias=${alias_cu}
    ...    check_result=${False}
    Log To Console  ${out}
    ${match}   Get Regexp Matches    ${out}    ESTABLISHED.*?\\s+${local_ip}\\[.*?\.\.\.${remote_ip}
    Should Be True     ${match}
    ${reg_exp}   Set Variable If
    ...  '${protocol}'=='any'  conn\\d+\\{\\d+\\}:\\s+${local_ip}/\\d+ === ${remote_ip}/\\d+
    ...  '${protocol}'=='sctp'  conn\\d+\\{\\d+\\}:\\s+${local_ip}/\\d+\\[sctp\\] === ${remote_ip}/\\d+\\[sctp\\]
    ...  '${protocol}'=='udp'  conn\\d+\\{\\d+\\}:\\s+${local_ip}/\\d+\\[udp\\] === ${remote_ip}/\\d+\\[udp\\]
    ${match}   Get Regexp Matches    ${out}    ${reg_exp}
    Should Be True     ${match}
    [Return]   ${out}
