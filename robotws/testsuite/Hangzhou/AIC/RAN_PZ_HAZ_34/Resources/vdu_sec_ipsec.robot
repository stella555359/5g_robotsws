*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_sec_ipsec.robot



*** Variables ***



*** Keywords ***
_Vdu Delta Config Ipsec Paras
    [Arguments]  ${para_dict}  ${tnl_id}  ${mrbts_id}  ${plan_id}
    [Documentation]   Vdu Delta Config Ipsec
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_dict  | yes | ipsec parameters dict |
    ...    | tnl_id  | yes | tnl id where to configure ipsec, default is 1 |
    ...    | mrbts_id  | yes | mrbts id |
    ...    | plan_id  | yes | delta plan id |

    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | vDU Rest Login |
    ...    | Vdu Delta Config Ipsec | ${ipsec_para_list} | 2 |
    ...    | vDU Rest Logout |
    ...
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
    ${prefix_distname}   ${post_distname}   Split String From Right   ${distname}   /   1
    ${exists}  scf.Is Object In Scf   ${distname}
    ${operate}   Set Variable If  ${exists}  replace  add
    Run Keyword If  '${exists}'=='False'  Add Delta Plan MO   plan_id=${plan_id}
    ...  parent_mo_dn=${prefix_distname}   mo_name=${post_distname}
    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${distname}
    ...  updated_paras_dict=${para_dict}
    ...  operation=${operate}

Vdu Delta Config Ipsec
    [Arguments]  ${ipsec_para_list}   ${tnl_id}=1   ${vdu_index}=0
    [Documentation]   Vdu Delta Config Ipsec
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ipsec_para_list  | yes | list of ipsec parameters dict |
    ...    | tnl_id  | no | tnl id where to configure ipsec, default is 1 |
    ...    | vdu_index  | no | vdu index, default is 0 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | vDU Rest Login |
    ...    | Vdu Delta Config Ipsec | ${ipsec_para_list} | 2 |
    ...    | vDU Rest Logout |
    ...
    Run Keyword And Ignore Error  vDU Rest Logout
    wait until keyword succeeds  5min   10s    vDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${uniq_id}  Get Unique Id
    ${scf_path}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}
    ...  filename=scf_${uniq_id}.xml  include_runtime_data=${False}
    scf.load scf  ${scf_path}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${delta_plan_name}   Get Unique Id  prefix=TA_ipsec_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA IPSEC
    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
    Run Keyword If   "${ipapp_exists}"=="False"  Add Delta Plan MO
    ...  plan_id=${plan_id}   parent_mo_dn=MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}   mo_name=IPAPP-1
    FOR   ${item}   IN   @{ipsec_para_list}
      Sleep  1s
      _Vdu Delta Config Ipsec Paras  ${item}  ${tnl_id}  ${mrbts_id}  ${plan_id}
    END
    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}
    ${out}   vdu.activate_delta_plan    delta_plan_id=${plan_id}
    wait until keyword succeeds    3min    30s
    ...    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}
#    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${False}

Vdu Delta Delete All Ipsec Configurations
    [Arguments]  ${tnl_id}=1
    [Documentation]   Vdu Delta Delete All Ipsec Configurations
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | tnl_id  | no | tnl id where to configure ipsec, default is 1 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | vDU Rest Login |
    ...    | Vdu Delta Delete All Ipsec Configurations | 2 |
    ...    | vDU Rest Logout |
    ...
    Run Keyword And Ignore Error   vDU Rest Logout
    wait until keyword succeeds  5min   10s    vDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${uniq_id}  Get Unique Id
    ${scf_path}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}
    ...  filename=scf_${uniq_id}.xml  include_runtime_data=${False}
    scf.load scf  ${scf_path}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${delta_plan_name}   Get Unique Id  prefix=TA_ipsec_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA IPSEC
    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
    Return From Keyword If   "${ipapp_exists}"=="False"
    Delete Delta Plan MO   plan_id=${plan_id}   mo_dn=${ipapp_dist_name}
    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}
    ${out}   vdu.activate_delta_plan    delta_plan_id=${plan_id}
    wait until keyword succeeds    3min    30s
    ...    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}
#    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${False}

Vdu Ipsec Tunnel Should Be Established
    [Arguments]  ${pod_abbr}  ${local_ip}  ${remote_ip}  ${protocol}=any
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]    vdu ipsec tunnel should be established via cli check
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr    | yes | pod_abbr for vcu |
    ...    | local_ip  | yes | ipsec tunnel local ip |
    ...    | remote_ip  | yes | ipsec tunnel renmote ip |
    ...	  | protocol | no | ipsec protocol type: any/udp/sctp |
    ...    *RETURN VALUE*
    ...    output of ipsec statusall
    ...
    ...    Example
    ...    | Vdu Ipsec Tunnel Should Be Established  | cprt | 1.1.1.1 | 2.2.2.2 |

    ${alias}   Get Unique Id
    Connect To K8s Master Interactively    alias=${alias}
    ${out}   Kubectl Exec Interactively   pod_abbr=${pod_abbr}  container=ipsecmgmt  command=ipsec statusall
    ...      alias=${alias}
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


Get Vdu Ip Addresses And Tnls
    vDU Rest Login
    ${SCF_PATH}  Get A Directory  SCF
    ${VDU_SCF_PATH}=  vdu.Get Current Plan File    ${SCF_PATH}   vdu_SCF.xml   include_runtime_data=${True}
    Set Test Variable   ${VDU_SCF_PATH}
    ${VDU_UP_TNL}   Get vDU TNL ID   scf_path=${VDU_SCF_PATH}   templateType=5GUserPlane
    ${VDU_CP_TNL}   Get vDU TNL ID   scf_path=${VDU_SCF_PATH}   templateType=5GControlPlane
    ${VDU_MRBTS_ID}  ${VDU_NRBTS_ID}  ${VDU_NRDU_ID}  Get BTS ID From vDU SCF    scf_path=${VDU_SCF_PATH}
    Set Test Variable  ${VDU_MRBTS_ID}
    Set Test Variable  ${VDU_NRBTS_ID}
    Set Test Variable  ${VDU_NRDU_ID}
    ${VDU_F1C_ADDR_DN}   scf.Get_Value_From_Scf
    ...  dist_name=MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRDU-${VDU_NRDU_ID}
    ...  list_name=f1Cplane   p_name=ipV4AddressDN1
    ${VDU_F1U_ADDR_DN}   scf.Get_Value_From_Scf
    ...  dist_name=MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRDU-${VDU_NRDU_ID}
    ...  list_name=f1Uplane   p_name=ipV4AddressDN1
    Set Test Variable  ${VDU_F1C_ADDR_DN}
    Set Test Variable  ${VDU_F1U_ADDR_DN}
    Connect To K8s Master    alias=k8s1
    Set Test Variable   ${VDU_UP_TNL}
    Set Test Variable   ${VDU_CP_TNL}
    ${VDU_F1C_IP}  ${mask}  ${broadcast}  Get VDU Container Ip Address
    ...  container=cprt  network=f1cplane  connection=k8s1
    ${VDU_F1U_IP}  ${mask}  ${broadcast}  Get VDU Container Ip Address
    ...  container=l1hi  network=f1u  connection=k8s1
    Set Test Variable   ${VDU_F1C_IP}
    Set Test Variable   ${VDU_F1U_IP}
    Disconnect From K8s Master  connection=k8s1


Get Vcu Ip Addresses And Tnls
    Cu Login
    ${VCU_SCF_PATH}  Get A File    scf   vcu_scf.xml
    cu.Get Current Plan File   path=${VCU_SCF_PATH}  timeout=60  include_runtime_data=${True}
    scf.Load_Scf  file_path=${VCU_SCF_PATH}
    Set Test Variable   ${VCU_SCF_PATH}
    ${VCU_UP_TNL}   Get vDU TNL ID   scf_path=${VCU_SCF_PATH}   templateType=5GUserPlane
    ${VCU_CP_TNL}   Get vDU TNL ID   scf_path=${VCU_SCF_PATH}   templateType=5GControlPlane
    Set Test Variable   ${VCU_UP_TNL}
    Set Test Variable   ${VCU_CP_TNL}
    ${VCU_MRBTS_ID}  ${VCU_NRBTS_ID}  ${VCU_NRDU_ID}  Get BTS ID From vDU SCF    scf_path=${VCU_SCF_PATH}
    Set Test Variable  ${VCU_MRBTS_ID}
    Set Test Variable  ${VCU_NRBTS_ID}
    Set Test Variable  ${VCU_NRDU_ID}
    ${VCU_F1U_ADDR_DN}   scf.Get_Value_From_Scf
    ...      dist_name=MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}  list_name=f1Uplane   p_name=ipV4AddressDN1
    ${VCU_F1C_ADDR_DN}   scf.Get_Value_From_Scf
    ...      dist_name=MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}  list_name=f1Cplane   p_name=ipV4AddressDN1
    Set Test Variable   ${VCU_F1U_ADDR_DN}
    Set Test Variable   ${VCU_F1C_ADDR_DN}
    ${CU_F1C_IP}  Get Vcu Ip address  cpif  cpif   f1c
    Set Test Variable   ${CU_F1C_IP}
    ${GNB_CU_TYPE}  scf.Get_Value_From_Scf
    ...      dist_name=MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}  p_name=gNbCuType
    Set Test Variable   ${GNB_CU_TYPE}
    ${CU_BYPASS_IP}    Run keyword if    '${GNB_CU_TYPE}' == 'NSA'   Get Vcu Ip address  cpif  cpif   x2c
    ...   ELSE    Get Vcu Ip address  cpif  cpif   ngc
#    ${CU_BYPASS_IP}  Get Vcu Ip address  cpif  cpif   x2c
    Set Test Variable   ${CU_BYPASS_IP}
    ${res}=   Run Keyword And Ignore Error  Get Vcu Ip address  upue  l2hi  f1u
    ${res1}=   Run Keyword And Ignore Error  Get Vcu Ip address  upue  l2hicu  f1u
    ${CU_F1U_IP}  set variable if  '${res[0]}'=='PASS'   ${res[1]}     ${res1[1]}
#    ${CU_F1U_IP}=   Get Vcu Ip address  upue  l2hicu  f1u
    Set Test Variable   ${CU_F1U_IP}