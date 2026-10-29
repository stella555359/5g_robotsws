*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_sec_cert.robot



#*** Variables ***



*** Keywords ***
Install Operator Certificate on VCU
    [Arguments]     ${CA_SubjectName}=${CA1_SubjectName}  ${CMP_Server_PORT}=${CMP1_Server_SingleLayer_PORT}
    ...   ${ref_number}=${CA1_Ref_Num}  ${psk_key}=${CA1_PSK}
    [Documentation]   Install Operator Certificate on VCU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...   history change: 12.10.2021, zhiqiang.q2.liu@nokia-sbell.com, modify for multiple layer certificate
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | ref_number          | no | default is CA1_Ref_Num |
    ...   |psk_key              | no | default is CA1_PSK |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Install Operator Certificate on vDU |
    ...
    Configure CMP related parameters on VCU  CA_SubjectName=${CA_SubjectName}  CMP_Server_PORT=${CMP_Server_PORT}

    Log To Console    Configure PSK and Ref#
    CU Login
    Update VCU CMP Server Settings Should Be Successful  ref_number=${ref_number}  psk_key=${psk_key}
    Log To Console    Enroll operator Certificate
    ${oldCertificate}  cu.get_operator_certificate_list
    #Log To Console   ${oldCertificate}
    Initialize Operator Certificate On VCU
    CU Logout
    wait until keyword succeeds  100   5    CU Login
    ${newCertificate}  cu.get_operator_certificate_list
    #Log To Console     ${oldCertificate[0]["details"]["serial_number"]}
    #Log To Console     ${newCertificate[0]["details"]["serial_number"]}
    Should Be True   ${oldCertificate[0]["details"]["serial_number"]}!=${newCertificate[0]["details"]["serial_number"]}
    #Should Be True   ${oldCertificate[0]["details"].serial_number}!=${newCertificate[0]["details"].serial_number}


Configure CMP related parameters on VCU
    [Arguments]     ${CA_SubjectName}=${CA1_SubjectName}  ${CMP_Server_PORT}=${CMP1_Server_SingleLayer_PORT}
    [Documentation]   Configure CMP related parameters on VCU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...   history change:
    ...   12.10.2021, zhiqiang.q2.liu@nokia-sbell.com, modify for multiple layer certificate
    ...   14.12.2021, zhiqiang.q2.liu@nokia-sbell.com, modify for failure when both serverPort and serverPath are not changed
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | CA_SubjectName    | No | SubjectName |
    ...   | CMP_Server_PORT    | No | default value is 8080 |
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | Configure CMP related parameters on VCU |
    ...
    Log To Console    Configure CMP related parameters on VCU
    CU Login
    ${plan_file_path}=    Get A File    SCF    vcu_cmp_scf.xml
    cu.get_current_plan_file   path=${plan_file_path}  timeout=60  include_runtime_data=${True}
    scf.Load_Scf  file_path=${plan_file_path}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${plan_file_path}
    ${BTS_ID}  set variable   ${mrbts_id}

    ${isIPv6}  Check if VCU OAM is IPv6
    ${CMP_Server_IP}  Set Variable If   ${isIPv6}    ${CMP1_Server_IPv6}  ${CMP1_Server_IP}

    ${target_dict}  create dictionary
    ...  eeSubjectName=CN=MRBTS-${BTS_ID}
    ...  caSubjectName=${CA_SubjectName}
    ...  serverHost=${CMP_Server_IP}
    ...  serverPort=${CMP_Server_PORT}
    ...  serverPath=${CMP1_Server_Path}
    ${CMP_para}  create list  eeSubjectName    caSubjectName    serverHost    serverPort    serverPath
    ${out}  Get VCU Current Parameters Dict   para_list=${CMP_para}   mo=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    Return from keyword if   ${target_dict}==${out}

	CU Login
	${delta_plan_id}=  CU Generate Delta Plan Should Be Successful

    &{temp_eeSubjectName}=   Create Dictionary    operation_type=remove    parameter_path=/eeSubjectName    value=${Empty}
    &{temp_caSubjectName}=    Create Dictionary    operation_type=remove    parameter_path=/caSubjectName    value=${Empty}
    &{serverHost}=   Create Dictionary    operation_type=remove    parameter_path=/serverHost     value=${Empty}
    @{deleted_List}=    Create List    ${temp_eeSubjectName}    ${temp_caSubjectName}    ${serverHost}

    &{temp_eeSubjectName}=   Create Dictionary    operation_type=add    parameter_path=/eeSubjectName    value=CN=MRBTS-${BTS_ID}
    &{temp_caSubjectName}=    Create Dictionary    operation_type=add    parameter_path=/caSubjectName    value=${CA_SubjectName}
    &{serverHost}=            Create Dictionary    operation_type=add    parameter_path=/serverHost     value=${CMP_Server_IP}
    &{serverPort}=   Create Dictionary    operation_type=replace    parameter_path=/serverPort    value=${CMP_Server_PORT}
    &{serverPath}=    Create Dictionary    operation_type=replace    parameter_path=/serverPath    value=${CMP1_Server_Path}
    @{add_List}=    Create List    ${temp_eeSubjectName}    ${temp_caSubjectName}    ${serverHost}  ${serverPort}  ${serverPath}

#    ${cmp_dn}   set variable   MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
#    CU Update Delta Plan Should Be Successful   plan_id=${delta_plan_id}  mo_dn=${cmp_dn}   parameter_change_list=${deleted_List}
#    CU Update Delta Plan Should Be Successful   plan_id=${delta_plan_id}  mo_dn=${cmp_dn}   parameter_change_list=${add_List}
#    CU Update Delta Plan Should Be Successful   plan_id=${delta_plan_id}  mo_dn=${cmp_dn}   parameter_change_list=${replaced_List}
#
#	CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
#    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}

    ${cmp_dn}   set variable   MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    CU Update Delta Plan Should Be Successful   plan_id=${delta_plan_id}  mo_dn=${cmp_dn}   parameter_change_list=${deleted_List}
    CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}

    ${delta_plan_id}=  CU Generate Delta Plan Should Be Successful
    CU Update Delta Plan Should Be Successful   plan_id=${delta_plan_id}  mo_dn=${cmp_dn}   parameter_change_list=${add_List}
    CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}


Get VCU Current Parameters Dict
    [Arguments]   ${para_list}    ${mo}    ${vcu_index}=0
    [Documentation]   Get VCU Current Parameters Dict
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | para_list    | yes | the names of parameters list |
    ...   | mo    | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...
    ...   *RETURN VALUE*
    ...   | origin_para_value_dict    | yes | the parameters and value in testline |
    ...
    ...   Example
    ...  | ${origin_para_value_dict}=    Get VCU Current Parameters Dict |
    ...   para_list=${para_list}    mo=${mo} |
    ...
    ${origin_para_value_dict}   create dictionary
    CU Login    gnb_index=${vcu_index}
    ${length}=    get length    ${para_list}
    FOR    ${i}    IN RANGE    0     ${length}
        ${status}  ${value}   Run Keyword And Ignore Error   CU Get Online Parameter Value   ${mo}  ${para_list[${i}]}
        ${value_current}  Set Variable If  '${status}'=='PASS'   ${value}  ${null}
        Set to Dictionary  ${origin_para_value_dict}  ${para_list[${i}]}   ${value_current}
    END
    [Return]  &{origin_para_value_dict}

Update VCU CMP Server Settings Should Be Successful
    [Arguments]  ${ref_number}   ${psk_key}
    [Documentation]   Update vCU CMP Server Settings Should Be Successful
    ...   *AUTHOR* Shubin.Ren@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | ref_number    | yes | Reference Number |
    ...   | psk_key       | yes | Pre-shared Key |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Update VCU CMP Server Settings Should Be Successful | ref_number=3071 | psk_key=LqH6-myAf-5FXH-TCQw |
    ...
    ${out}  cu.update_cmp_server_settings   ref_number=${ref_number}  psk_key=${psk_key}
    Should Be True  "${out["status"]}"=="Successful"
    [Return]  ${out}

Initialize Operator Certificate On VCU
    [Arguments]
    [Documentation]   Initialize Operator Certificate On VCU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | cu login |
    ...  | Initialize Operator Certificate |
    ...
    ${out}  cu.trigger_certificate_initialization
    Should Be True  "${out["status"]}"=="Successful"
    [Return]  ${out}


Restore Default Certificates On vCU
    [Documentation]   Restore Default Certificates On vCU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
	...    modified by:        <10-08-2021>, <lijuwang>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | NONE |
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...  | cu login |
    ...  | Restore Default Certificates On vCU |
    ...
    ${operationID}  cu.restore_default_certificates
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Check vCU CMP Operation Should Be Expected   operationID=${operationID}   expected_status=Successful
    [Return]  ${rtn}

Install Netact CA Certificate on vCU
    [Documentation]   Install CNMS04 CA Certificate on vDU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | Install CNMS CA Certificate on vDU |
    CU Login
    ${Result}   _Check If Netact CA Cert Exists
    Return from keyword if   ${Result}==True
    #${NETACT_CA_cert}=   set variable  ${CURDIR}/nom/clab3766ca.pem
    ${NETACT_CA_cert}   _Get Netact Certificate File Name
    ${out}  cu.install_operators_certificate    certificate_file_path=${NETACT_CA_cert}   certificate_type=CA
    Should Be True  "${out["status"]}"=="Successful"
    [Return]  ${out}

_Check If Netact CA Cert Exists
    @{vCU_Cert_list}  cu.get_operator_certificate_list
    ${netact_conf}   Get Netact Config From Test Line
    ${ca_sn}   Set Variable   ${netact_conf["ca_sn"]}
    FOR  ${Cert}  IN   @{vCU_Cert_list}
       ${serial_numer}   Set Variable    ${Cert["details"]["serial_number"]}
       # ${Cert_exists}=   run keyword and return if    "${serial_numer}"=="${NETACT_3766_CA_SN}"   set variable   True
       ${Cert_exists}=   run keyword and return if    "${serial_numer}"=="${ca_sn}"   set variable   True
       ${Cert_exists}=   set variable   False
    END
    [Return]    ${Cert_exists}


Delete All Operator Certificates On vCU
    [Documentation]   Delete All Operator Certificates On vCU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
	...    modified by:        <10-08-2021>, <lijuwang>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | NONE |
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...  | cu login |
    ...  | Restore Default Certificates On vCU |
    ...
    ${out}  cu.delete_all_operator_certificates
    Should Be True  "${out["status"]}"=="Successful"
    [Return]  ${out}


Add manual CRLDP on CU
   [Documentation]  Add manual CRLDP on CU
    ...    author: hefeng-cookie.qu@nokia-sbell.com
    ...    modified by:        <19-10-2021>, <hqu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |

    ...   Example
    ...  | Add manual CRLDP on CU|

    Log To Console   Add manual CRLDP on CU
     CU Login
    ${plan_file_path}=    Get A File    SCF    vcu_crl_scf.xml
    ${scf_file_fullpath}   cu.get_current_plan_file   path=${plan_file_path}  timeout=60  include_runtime_data=${True}
    scf.Load_Scf  file_path=${scf_file_fullpath}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_file_fullpath}
    ${mnl_version}    scf.get_mo_attribute    dist_name=MRBTS-${MRBTS_ID}/MNL-1     attribute=version
    ${BTS_ID}  set variable   ${mrbts_id}
    ${mnl_version}   set variable   ${mnl_version}

    FOR    ${i}    IN RANGE   1   21
       run keyword and ignore error     scf.Remove_Mo_With_Descendant_Mos
    ...    dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-${i}
    END
    #scf.remove_element_from_scf


    ${CRLDPCONFIG-1}   Set Variable   MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ${CRLDPCONFIG-20}   Set Variable   MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-20

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.mnl:CRLDPCONFIG
        ...    dist_name=${CRLDPCONFIG-1}   version=${mnl_version}
    scf.Add_Element_To_Scf   dist_name=${CRLDPCONFIG-1}   p_name=primaryCRLDP   value=${CRLDP1}
    scf.Add_Element_To_Scf   dist_name=${CRLDPCONFIG-1}   p_name=secondaryCRLDP   value=${CRLDP2}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.mnl:CRLDPCONFIG
        ...    dist_name=${CRLDPCONFIG-20}   version=${mnl_version}
    scf.Add_Element_To_Scf   dist_name=${CRLDPCONFIG-20}   p_name=primaryCRLDP   value=${CRLDP3}
    scf.Add_Element_To_Scf   dist_name=${CRLDPCONFIG-20}   p_name=secondaryCRLDP   value=${CRLDP4}

    ${new_scf}   Get A File   new_scf   AddManualcrldp.xml
    scf.Save_Scf  file_path=${new_scf}
    ${Plan_Name}   get unique id
    Recommission vCU with new SCF     ${new_scf}    ${Plan_Name}
    ${alias_cu}=    Connect To CU K8S Master With Admin
    Wait Until Keyword Succeeds  2min    10s   All CU Containers Should Be Normal    alias=${alias_cu}


vCU Configure CRL DP Source
   [Arguments]    ${DP_source}=Certificate_extension   ${updatePeriod}=10  ${usageEnabled}=Enabled
   [Documentation]  vCU Configure CRL DP via Certificate
    ...    author: hefeng-cookie.qu@nokia-sbell.com
    ...    modified by:        <19-10-2021>, <hqu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  DP_source  | YES |  Certificate_extension |Configuration_parameter|Extension_and_parameter |
    ...    | usageEnabled | YES |
    ...    | updatePeriod | YES |

    ...   Example
    ...  | vCU Configure CRL DP Source | DP_source=Certificate_extension | usageEnabled=Enabled | updatePeriod=24 |

    Log To Console   vCU Configure CRL DP Source
    CU Login
    ${plan_file_path}=    Get A File    SCF    vcu_crl_scf.xml
    cu.get_current_plan_file   path=${plan_file_path}  timeout=60  include_runtime_data=${True}
    scf.Load_Scf  file_path=${plan_file_path}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${plan_file_path}

    ${target_dict}  create dictionary
    ...  distributionPointSource=${DP_source}
    ...  updatePeriod=${updatePeriod}
    ...  usageEnabled=${usageEnabled}

    ${CRL_para}  create list   distributionPointSource    updatePeriod   usageEnabled
    ${out}  Get VCU Current Parameters Dict   para_list=${CRL_para}   mo=MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1
    Return from keyword if   ${target_dict}==${out}

	CU Login
	${delta_plan_id}=  CU Generate Delta Plan Should Be Successful

    &{distributionPointSource}=   Create Dictionary    operation_type=replace    parameter_path=/distributionPointSource    value=${DP_source}
    &{updatePeriod}=    Create Dictionary    operation_type=replace    parameter_path=/updatePeriod    value=${updatePeriod}
    &{usageEnabled}=    Create Dictionary    operation_type=replace    parameter_path=/usageEnabled    value=${usageEnabled}
    @{replaced_List}=    Create List    ${distributionPointSource}    ${updatePeriod}    ${usageEnabled}

    ${crl_dn}   set variable   MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1
    CU Update Delta Plan Should Be Successful   plan_id=${delta_plan_id}  mo_dn=${crl_dn}   parameter_change_list=${replaced_List}

	CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
