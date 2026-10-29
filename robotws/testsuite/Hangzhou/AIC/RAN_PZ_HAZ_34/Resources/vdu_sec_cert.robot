*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_sec_cert.robot




*** Keywords ***
Install Operator Certificate via CMP on vDU
    [Arguments]   ${caSubjectName}=${CA1_SubjectName}   ${serverPort}=${CMP1_Server_SingleLayer_PORT}
    ...           ${ref_number}=${CA1_Ref_Num}    ${psk_key}=${CA1_PSK}
    [Documentation]    Install Operator Certificate via CMP on vDU
    ...   *AUTHOR* hefeng-cookie.qu@nokia-sbell.com
    ...  27.5.2023  chris.l.cao@nokia-sbell.com, assert certificate serial number is changed
    ...  21.6.2023  lingting.sun@nokia-sbell.com, assert length of specific certificate list changed
    ...  25.6.2023  chris.l.cao@nokia-sbell.com, change assertion from length change to SN change
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | caSubjectName | no | caSubjectName, default value is ${CA1_SubjectName} |
    ...   | serverPort      | no | serverPort, default value is ${CMP1_Server_SingleLayer_PORT} |
    ...   | ref_number | no | ref_number, default value is ${CA1_Ref_Num} |
    ...   | psk_key      | no | psk_key, default value is ${CA1_PSK} |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | Install Operator Certificate via CMP on vDU |
    ...  | Install Operator Certificate via CMP on vDU | ref_number=${CA1_Ref_Num} | psk_key=${CA1_PSK} |
    ...  | ...          | caSubjectName=${CA1_SubjectName} | serverPort=${CMP1_Server_SingleLayer_PORT} |
    ...
    Configure CMP related parameters  caSubjectName=${caSubjectName}  serverPort=${serverPort}  CMP_type=RSA
    vDU Rest Login
    Update vDU CMP Server Settings  ref_number=${ref_number}  psk_key=${psk_key}
    ${oldCertificate}  vdu.get_vdu_certificates
    ${old_RSA_Certificate}  _Get Specific Type Certificate List  Certificate_list=${oldCertificate}   type=EE   key_pool_type=RSA
    Initialize Operator Certificate
    sleep  20
    wait until keyword succeeds  120   5    vDU Rest Login
    ${newCertificate}  vdu.get_vdu_certificates
    ${new_RSA_Certificate}  _Get Specific Type Certificate List  Certificate_list=${newCertificate}  type=EE   key_pool_type=RSA
    ${old_cert_length}  get length   ${old_RSA_Certificate}
    ${new_cert_length}  get length   ${new_RSA_Certificate}
    ${old_sn}  Set Variable  ${old_RSA_Certificate[0]["details"]["serial_number"]}
    ${new_sn}  Set Variable  ${new_RSA_Certificate[0]["details"]["serial_number"]}
    log to console   old certtificat SN:${old_sn}
    log to console   new certtificat SN:${new_sn}
    Should Be True   "${old_sn}"!="${new_sn}"


Install ECDSA Operator Certificate via CMP on vDU
    [Arguments]   ${caSubjectName}=${CA2_SubjectName_EC}       ${serverPort}=${CMP1_Server_SingleLayer_PORT}
    ...              ${ref_number}=${CA2_Ref_Num_EC}    ${psk_key}=${CA2_PSK_EC}
    [Documentation]    Install ECDSA Operator Certificate via CMP on vDU
    ...   *AUTHOR* huilin.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | caSubjectName | no | caSubjectName, default value is CA2_SubjectName_EC in variables.robot |
    ...   | serverPort      | no | serverPort, default value is CMP1_Server_SingleLayer_PORT in variables.robot  |
    ...   | ref_number      | no | serverPort, default value is CA2_Ref_Num_EC in variables.robot |
    ...   | psk_key         | no | serverPort, default value is CA2_PSK_EC in variables.robot |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | Install ECDSA Operator Certificate via CMP on vDU |
    ...  | Install ECDSA Operator Certificate via CMP on vDU | caSubjectName=${CA2_SubjectName_EC} | serverPort=${CMP1_Server_SingleLayer_PORT} |
    ...                                                      | ref_number=${CA2_Ref_Num_EC} |
    ...                                                      | psk_key=${CA2_PSK_EC}   |

    Configure CMP related parameters    caSubjectName=${caSubjectName}  serverPort=${serverPort}  CMP_type=ECDSA
    vDU Rest Login
    Update vDU CMP Server Settings      ref_number=${ref_number}  psk_key=${psk_key}  key_pool_type=ECDSA
    Initialize Operator Certificate     key_pool_type=ECDSA
    sleep  20


Install Netact CA Certificate on vDU
    [Documentation]   Install Netact CA Certificate on vDU
    ...   *AUTHOR* huilin.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | Install Netact CA Certificate on vDU |
    vDU Rest Login
    ${Result}   Check If Netact CA Cert Exists on DU
    Return from keyword if   ${Result}==True
    ${NETACT_CA_cert}   _Get Netact Certificate File Name
    ${operationID}  vdu.install_vdu_certificates    cert_file_path=${NETACT_CA_cert}    cert_type=CA
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Check vDU CMP Operation Should Be Expected   operationID=${operationID}   expected_status=Successful
    [Return]  ${rtn}


Check If Netact CA Cert Exists on DU
    [Documentation]   Check If Netact CA Cert Exists on DU
    ...   It fetches all certificate from VDU and from testline configuration, then compares them.
    ...   it returns ${True} if the comparision result is same, otherwise returns ${False}
    ...
    ...   *AUTHOR* unknown
    ...  Change History
    ...  8.2.2023  chris.l.cao@nokia-sbell.com, change it to public common KW by removing underline at the begining of keyword name
    ...
    ...   | Input Parameters    | Man. | Description |
    ...
    ...   *RETURN VALUE*
    ...    ${True} or ${False}
    ...
    ...   Example
    ...  | VDU Rest Login |
    ...  | ${result} | Check If Netact CA Cert Exists on DU |
    ...
    @{vDU_Cert_list}  vdu.get_vdu_certificates
    ${netact_conf}   Get Netact Config From Test Line
    ${ca_sn}   Set Variable   ${netact_conf["ca_sn"]}
    FOR  ${Cert}  IN   @{vDU_Cert_list}
       ${serial_numer}   Set Variable    ${Cert["details"]["serial_number"]}
       Return From Keyword If   "${serial_numer}"=="${ca_sn}"   ${True}
       ${Cert_exists}=   set variable   ${False}
    END
    [Return]    ${Cert_exists}


Enable Certificate_extension CRL on vDU
    VDU Rest Login
    ${crl_para}    create dictionary     usageEnabled=Enabled  updatePeriod=24
    ...  distributionPointSource=Certificate_extension
    VDU Online Change Parameters By Delta Plan REST
    ...    mo_dn=MRBTS-${VDU_CONF["mrbts_id"]}/MNL-1/CERTH-1/CRLH-1
    ...    updated_paras_list=${crl_para}
    ...    operation=replace
    ...    activate=${True}
    ...    force_reset=${False}
    ...    auto_lock_cells=${False}
    ...    timeout=60


#-----Add manual CRLDP on vDU------#
Add manual CRLDP on vDU
    [Documentation]  Add manual CRLDP on vDU
    ...    author: hefeng-cookie.qu@nokia-sbell.com
    ...    modified by:        <20-10-2021>, <hqu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |

    ...   Example
    ...  | Add manual CRLDP on vDU|

    Log To Console   Add manual CRLDP on vDU
    vdu Rest Login
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=manualcrldp.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_file_with_fullpath}
    ${mnl_version}    scf.get_mo_attribute    dist_name=MRBTS-${MRBTS_ID}/MNL-1     attribute=version
    ${BTS_ID}   set variable    ${mrbts_id}
    ${mnl_version}    set variable   ${mnl_version}

    FOR    ${i}    IN RANGE   1   21
       run keyword and ignore error     scf.Remove_Mo_With_Descendant_Mos
    ...    dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-${i}
    END


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
    Check Maximum Plan Number And Delete One If Reach Maximum Number
    ${PLAN_ID}    ${ACTION_ID}   ${VALIDATION_ID}   Upload Plan And Validate And Activate   plan_file=${new_scf}
    ...   plan_name=${Plan_Name}
    ...   wait_vdu_up=${False}





#---vDU Configure CRL DP Source-----#
vDU Configure CRL DP Source
   [Arguments]    ${DP_source}=Certificate_extension   ${updatePeriod}=10  ${usageEnabled}=Enabled
   [Documentation]  vDU Configure CRL DP Source
    ...    author: hefeng-cookie.qu@nokia-sbell.com
    ...    modified by:        <20-10-2021>, <hqu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | DP_source  | YES |  Certificate_extension |Configuration_parameter|Extension_and_parameter |
    ...    |usageEnabled | YES |

    ...   Example
    ...  | vDU Configure CRL DP Source |
    ...  | vDU Configure CRL DP Source | DP_source=Configuration_parameter | usageEnabled=Disabled |
    Log To Console   vDU Configure CRL DP Source
    Vdu Rest Login
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=crldp.xml  include_runtime_data=${False}
    #scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_file_with_fullpath}
    ${BTS_ID}  set variable   ${mrbts_id}

    ${target_dict}  create dictionary
    ...  distributionPointSource=${DP_source}
    ...  updatePeriod=${updatePeriod}
    ...  usageEnabled=${usageEnabled}

    ${CRL_para}  create list   distributionPointSource    updatePeriod   usageEnabled
    ${out}  Get Current Parameters Dict   para_list=${CRL_para}   mo=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1
    Return from keyword if   ${target_dict}==${out}

	Vdu Rest Login
	VDU Online Change Parameters By Delta Plan REST
    ...    mo_dn=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1
    ...    updated_paras_list=${target_dict}
    ...    operation=replace
    ...    activate=${True}
    ...    force_reset=${False}
    ...    auto_lock_cells=${False}
    ...    timeout=60


#-----Delta Remove One Incorrect CRL DP-----#
Delta Remove One Incorrect CRL DP
    [Arguments]    ${id}=20
    [Documentation]   Delta Remove One Incorrect CRL DP
    ...    author: hefeng-cookie.qu@nokia-sbell.com
    ...    modified by:        <20-10-2021>, <hqu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | id  | YES |  CRLDPCONFIG id |

    ...   Example
    ...  | Delta Remove One Incorrect CRL DP |
    ...  | Delta Remove One Incorrect CRL DP | id=20 |
    vdu Rest Login
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=manualcrldp.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_file_with_fullpath}
    ${mnl_version}    scf.get_mo_attribute    dist_name=MRBTS-${MRBTS_ID}/MNL-1     attribute=version
    ${BTS_ID}   set variable    ${mrbts_id}
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=Delete_oneCRL
    ${distname}  Set Variable    MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-${id}
    Delete Delta Plan MO   ${plan_id}   ${distname}
    Validate Delta Plan By REST   ${plan_id}
    Activate Delta Plan By REST   ${plan_id}


Configure CMP related parameters
    [Arguments]  ${caSubjectName}=${CA1_SubjectName}  ${serverPort}=${CMP1_Server_SingleLayer_PORT}  ${CMP_type}=RSA
    [Documentation]    Configure CMP related parameters
    ...   *AUTHOR* zhiqiang.q2.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   4.1.2022,chris.l.cao@nokia-sbell.com, enhnance CMP old parameters deletion arithmetics to imporve case pass ratio
    ...   08.05.2023,huilin.xu@nokia-sbell.com, add CMP_type parameter to cover ECDSA type
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | caSubjectName | no | caSubjectName, default value is DC=cmp, O=nokia, OU=ivtrans, CN=IPsecbackup |
    ...   | serverPort      | no | serverPort, default value is 8080 |
    ...   | CMP_type      | no | cmp certificate type, default value is RSA |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Configure CMP related parameters | caSubjectName=${Three_layer_CA_SubjectName} | serverPort=${CMP1_Server_MultiLayer_PORT}
    ...
    Log To Console    Configure CMP related parameters
    ${conf}   Get VDU Conf From SCF
    ${mrbts_id}  set variable   ${conf["mrbts_id"]}
    ${isIPv6}  Check if OAM is IPv6
    ${CMP_Server_IP}  Set Variable If   ${isIPv6}    ${CMP1_Server_IPv6}  ${CMP1_Server_IP}
    ${target_dict}  create dictionary
    ...  eeSubjectName=CN=MRBTS-${mrbts_id}
    ...  caSubjectName=${caSubjectName}
    ...  serverHost=${CMP_Server_IP}
    ...  serverPort=${serverPort}
    ...  serverPath=${CMP1_Server_Path}
    ${CMP_para}  create list  eeSubjectName    caSubjectName    serverHost    serverPort    serverPath
    ${CMP_MO_Name}  Set Variable If  "${CMP_type}"=="ECDSA"  MRBTS-${mrbts_id}/MNL-1/CERTH-1/CMPECDSA-1  MRBTS-${mrbts_id}/MNL-1/CERTH-1/CMP-1

    ${out}  Get Current Parameters Dict   para_list=${CMP_para}   mo=${CMP_MO_Name}
    Return from keyword if   ${target_dict}==${out}

    vDU Rest Login
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA

    #delete
    ${deleted_dict}   create dictionary
    Run Keyword If   "${out["serverHost"]}"!="${None}"  Set To Dictionary   ${deleted_dict}   serverHost   *
    Run Keyword If   "${out["eeSubjectName"]}"!="${None}"  Set To Dictionary   ${deleted_dict}   eeSubjectName   *
    Run Keyword If   "${out["caSubjectName"]}"!="${None}"  Set To Dictionary   ${deleted_dict}   caSubjectName   *

#    ${out}  Run Keyword And Ignore Error   Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=MRBTS-${mrbts_id}/MNL-1/CERTH-1/CMP-1
#    ...   updated_paras_dict=${deleted_dict}  operation=remove
    ${need_delete}  Set Variable If
        ...   "${out["serverHost"]}"!="${None}" or "${out["eeSubjectName"]}"!="${None}" or "${out["caSubjectName"]}"!="${None}"   1  0
    ${out}   Run Keyword If  ${need_delete}==1   Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${CMP_MO_Name}
        ...   updated_paras_dict=${deleted_dict}  operation=remove
    ${validation_id}  Run Keyword If   ${need_delete}==1    Validate Delta Plan By REST  plan_id=${planid}
    Run Keyword If  ${need_delete}==1   Activate Delta Plan By REST  plan_id=${plan_id}

    #add and replace
    vDU Rest Login
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${delta_plan_name}   get unique id  prefix=TA_delta_plan2   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA2
    ${add_dict}  create dictionary
    ...  eeSubjectName=CN=MRBTS-${mrbts_id}
    ...  caSubjectName=${caSubjectName}
    ...  serverHost=${CMP_Server_IP}
    ${replaced_dict}  create dictionary
    ...  serverPort=${serverPort}
    ...  serverPath=${CMP1_Server_Path}

    ${out}   Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${CMP_MO_Name}
    ...   updated_paras_dict=${add_dict}   operation=add
    ${out}   Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${CMP_MO_Name}
    ...   updated_paras_dict=${replaced_dict}   operation=replace

    ${validation_id}  Validate Delta Plan By REST  plan_id=${planid}
    Activate Delta Plan By REST  plan_id=${plan_id}


Update vDU CMP Server Settings
    [Arguments]  ${ref_number}=${CA1_Ref_Num}   ${psk_key}=${CA1_PSK}   ${key_pool_type}=RSA
    [Documentation]   Update vDU CMP Server Settings
    ...   *AUTHOR* Shubin.Ren@nokia-sbell.com
    ...   history change:
    ...    6.29.2022, exuan@nokia-sbell.com, Modify wait until keyword succeeds
    ...    11.18.2022, chris.l.cao@nokia-sbell.com, add parameter key_pool_type
    ...    5.27.2023, chris.l.cao@nokia-sbell.com, change KW name to 'Update vDU CMP Server Settings'
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | ref_number    | no | Reference Number |
    ...   | psk_key       | no | Pre-shared Key |
    ...   | key_pool_type | no | RSA or ECDSA,default is RSA |
    ...
    ...   *RETURN VALUE*
    ...    dictionary result of operation result, e.g. {'status': 'Successful'}
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Update Delta Plan Parameter Should Be Successful |
    ...  | Update Delta Plan Parameter Should Be Successful | ref_number=<my_ref_number> | psk_key=<my_psk_key> | key_pool_type=RSA |
    ...  | Update Delta Plan Parameter Should Be Successful | ref_number=<my_ref_number> | psk_key=<my_psk_key> | key_pool_type=ECDSA |
    ...
    ${operationID}  vdu.update_vdu_cmp_server_settings   ref_number=${ref_number}  psk_key=${psk_key}   key_pool_type=${key_pool_type}
    ${rtn}  wait until keyword succeeds  3min  2s
    ...   _Check vDU CMP Operation Should Be Expected   operationID=${operationID}   expected_status=Successful
    [Return]  ${rtn}


Restore Default Certificates On vDU
    [Arguments]  ${timeout}=30
    [Documentation]   Restore Default Certificates Should Be Successful
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <28-07-2021>, <lijuwang>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | NONE |
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...  | vdu rest login |
    ...  | Restore Default Certificates |
    ...
    ${operationID}  vdu.restore_default_certificates   timeout=${timeout}
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Check vDU CMP Operation Should Be Expected   operationID=${operationID}   expected_status=Successful
    [Return]  ${rtn}


Delete Operator Certificates On vDU
    [Arguments]  ${timeout}=30
    [Documentation]   Delete Operator Certificates On vDU
    ...   *AUTHOR* huilin.xu@nokia-sbell.com
    ...  Change History
    ...  24.4.2022  huilin.xu@nokia-sbell.com, Initial creation
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | timeout | no | timeout, default is 30 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...  | vdu rest login |
    ...  | Delete Operator Certificates On vDU |
    ${ca_id}   _Get Netact Certificate Id Name
    ${operationID}  vdu.delete_certificates_by_id   certificate_id=${ca_id}    timeout=${timeout}
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Check vDU CMP Operation Should Be Expected   operationID=${operationID}   expected_status=Successful
    [Return]  ${rtn}


_Check vDU CMP Operation Should Be Expected
    [Arguments]  ${operationID}  ${expected_status}
    [Documentation]    _Update vDU CMP Server Settings Should Be Expected
    ...   *AUTHOR* Shubin.ren@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | operationID      | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Update vDU CMP Server Settings Should Be Expected |  | expected_status=success |
    ...
    ${out}  vdu.get_trs_api_operation_status  operation_id=${operationID}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Initialize Operator Certificate
    [Arguments]   ${timeout}=30   ${key_pool_type}=RSA
    [Documentation]   Initialize Operator Certificate
    ...   *AUTHOR* Shubin.Ren@nokia-sbell.com
    ...   history change: 11.18.2022, chris.l.cao@nokia-sbell.com, add parameter key_pool_type
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | timeout       | no | timeout, default 30 second |
    ...   | key_pool_type | no | RSA or ECDSA, default is RSA |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Initialize Operator Certificate |
    ...  | Initialize Operator Certificate | key_pool_type=RSA |
    ...  | Initialize Operator Certificate | key_pool_type=ECDSA |
    ...
    ${operationID}  vdu.initialize_certificate   timeout=${timeout}   key_pool_type=${key_pool_type}
    ${rtn}  wait until keyword succeeds  180   5
    ...   _Check vDU CMP Operation Should Be Expected   operationID=${operationID}   expected_status=Successful
    [Return]  ${rtn}


Install Operator Certificate on vDU
    [Arguments]
    [Documentation]   Install Operator Certificate on vDU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...   11.07.2022  eahsuan.xuan@nokia-sbell.com, add sleep time
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Install Operator Certificate on vDU |
    ...
#    Configure CMP related parameters
#    Log To Console    Configure PSK and Ref#
#    vDU Rest Login
#    Sleep  20s
#    Update vDU CMP Server Settings  ref_number=${CA1_Ref_Num}  psk_key=${CA1_PSK}
#    Log To Console    Enroll operator Certificate
#    ${oldCertificate}  vdu.get_vdu_certificates
#    Initialize Operator Certificate
#    vDU Rest Logout
#    wait until keyword succeeds  100   5    vDU Rest Login
#    ${newCertificate}  vdu.get_vdu_certificates
#    Log To Console     ${oldCertificate[0]["details"]["serial_number"]}
#    Log To Console     ${newCertificate[0]["details"]["serial_number"]}
#    Should Be True   ${oldCertificate[0]["details"]["serial_number"]}!=${newCertificate[0]["details"]["serial_number"]}

    Install Operator Certificate via CMP on vDU



Genarate And Install Additional TA
    [Arguments]  ${cert_number}=15  ${days}=365
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]  Generate Cert CSR
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  history change:
    ...  11.8.2021, zhiqiang.q2.liu@nokia-sbell.com, add #generate ca.pem, add #install ca, delete vdu rest logout
    ...  2.3.2023, chris.l.cao@nokia-sbell.com, add certificate valid period parameter, default value is 365 days
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | cert_number  |  no  | cert_number, default is 15 |
    ...    | days         |  no  | certificate valid period, default is 365 (days) |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Genarate And Install Additional TA |
    ...
    ${alias}   get unique id
    connect to ute locally  alias=${alias}
    ${folder_root}   set variable   /opt/ca/root
    ${folder_key}    set variable   ${folder_root}/key
    ${folder_newcerts}   set variable  ${folder_root}/newcerts
    ${file_openssl_cnf_seed}  set variable  ${folder_root}/openssl_seed.cnf
    ${file_serial}       set variable    ${folder_root}/serial
    ${file_cakey_pem}    set variable    ${folder_key}/cakey.pem
    ${file_ca_csr}       set variable    ${folder_key}/ca.csr

    ${out}  issh.Execute  command=sudo rm -rf ${folder_root}   check_result=False   alias=${alias}
    ${out}  issh.Execute  command=sudo mkdir -p ${folder_root}    alias=${alias}
    ${out}  issh.Execute  command=sudo mkdir -p ${folder_key}    alias=${alias}
    ${out}  issh.Execute  command=sudo mkdir -p ${folder_newcerts}    alias=${alias}

    #sudo vim /opt/ca/root/openssl.cnf
    ${out}  issh.Execute  command=sudo touch ${folder_root}/index.txt   alias=${alias}
    ${out}  issh.Execute  command=sudo touch ${folder_root}/index.txt.attr   alias=${alias}
    ${out}  issh.Execute  command=sudo touch ${file_serial}   alias=${alias}
    ${out}  issh.Execute  command=sudo chmod 777 ${file_serial}   alias=${alias}
    ${out}  issh.Execute  command=sudo echo 01 > ${file_serial}   alias=${alias}

    #generate key
    ${out}  issh.Execute  command=sudo openssl genrsa -out ${file_cakey_pem} 2048   alias=${alias}

    #get file_openssl_cnf_seed
    Upload Tools To UTE
    ${file_openssl_cnf_from_tool_repository}   set variable   ${TOOLS_INFO["work_folder_data"]}/${TOOLS_INFO["openssl_cnf"]}
    ${out}  issh.Execute  command=sudo cp ${file_openssl_cnf_from_tool_repository} ${file_openssl_cnf_seed}   alias=${alias}

    ${old_prompt}  issh.Get Prompt   alias=${alias}
    ${new_prompt}  set variable   ${old_prompt}|\\s\\[y/n\\]
    issh.Set Prompt     prompt_str=${new_prompt}    alias=${alias}
    vDU Rest Login
    FOR  ${i}  IN RANGE  ${cert_number}
       ${file_openssl_cnf}  set variable  ${folder_root}/openssl_${i}.cnf
       ${file_cert}  set variable   ${folder_key}/cacert_${i}.pem
       log to console  ${file_openssl_cnf}, ${file_cert}
       ${out}  issh.Execute  command=sudo cp ${file_openssl_cnf_seed} ${file_openssl_cnf}   alias=${alias}
       #change CA subject
       ${out}  issh.Execute  command=sudo sed -i 's/iv2trans/iv2trans_${i}/g' ${file_openssl_cnf}   alias=${alias}
       #generate ca.csr
       ${out}  issh.Execute  command=sudo openssl req -new -key ${file_cakey_pem} -out ${file_ca_csr} -config ${file_openssl_cnf}   alias=${alias}
       #generate ca.pem
       ${out}  issh.Execute
       ...   command=sudo openssl req -x509 -key ${file_cakey_pem} -outform PEM -out ${file_cert} -config ${file_openssl_cnf} -days ${days}
       ...   alias=${alias}  check_result=False
       #install ca
       ${operationID}  vdu.install_vdu_certificates  cert_file_path=${file_cert}  cert_type=CA
       ${rtn}  wait until keyword succeeds  180   5
       ...   _Check vDU CMP Operation Should Be Expected   operationID=${operationID}   expected_status=Successful
    END


Genarate Additional TA
    [Arguments]  ${cert_number}=15
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]  Genarate Additional TA
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   history change:
    ...     11.8.2021, zhiqiang.q2.liu@nokia-sbell.com, add #generate ca.pem, add #install ca, delete vdu rest logout
    ...     16.11.2021,hefeng-cookie.qu@nokia-sbell.com, split KW "Genarate And Install Additional TA"
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | cert_number  |  no  | cert_number, default is 15 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Genarate additional TA at Netact |
    ...
    ${alias}   get unique id
    connect to ute locally  alias=${alias}
    ${folder_root}   set variable   /opt/ca/root
    ${folder_key}    set variable   ${folder_root}/key
    ${folder_newcerts}   set variable  ${folder_root}/newcerts
    ${file_openssl_cnf_seed}  set variable  ${folder_root}/openssl_seed.cnf
    ${file_serial}       set variable    ${folder_root}/serial
    ${file_cakey_pem}    set variable    ${folder_key}/cakey.pem
    ${file_ca_csr}       set variable    ${folder_key}/ca.csr

    ${out}  issh.Execute  command=sudo rm -rf ${folder_root}   check_result=False   alias=${alias}
    ${out}  issh.Execute  command=sudo mkdir -p ${folder_root}    alias=${alias}
    ${out}  issh.Execute  command=sudo mkdir -p ${folder_key}    alias=${alias}
    ${out}  issh.Execute  command=sudo mkdir -p ${folder_newcerts}    alias=${alias}

    #sudo vim /opt/ca/root/openssl.cnf
    ${out}  issh.Execute  command=sudo touch ${folder_root}/index.txt   alias=${alias}
    ${out}  issh.Execute  command=sudo touch ${folder_root}/index.txt.attr   alias=${alias}
    ${out}  issh.Execute  command=sudo touch ${file_serial}   alias=${alias}
    ${out}  issh.Execute  command=sudo chmod 777 ${file_serial}   alias=${alias}
    ${out}  issh.Execute  command=sudo echo 01 > ${file_serial}   alias=${alias}

    #generate key
    ${out}  issh.Execute  command=sudo openssl genrsa -out ${file_cakey_pem} 2048   alias=${alias}

    #get file_openssl_cnf_seed
    Upload Tools To UTE
    ${file_openssl_cnf_from_tool_repository}   set variable   ${TOOLS_INFO["work_folder_data"]}/${TOOLS_INFO["openssl_cnf"]}
    ${out}  issh.Execute  command=sudo cp ${file_openssl_cnf_from_tool_repository} ${file_openssl_cnf_seed}   alias=${alias}

    ${old_prompt}  issh.Get Prompt   alias=${alias}
    ${new_prompt}  set variable   ${old_prompt}|\\s\\[y/n\\]
    issh.Set Prompt     prompt_str=${new_prompt}    alias=${alias}
    #vDU Rest Login
    ${cert_file_list}    Create List
    FOR  ${i}  IN RANGE  ${cert_number}
       ${file_openssl_cnf}  set variable  ${folder_root}/openssl_${i}.cnf
       ${file_cert}  set variable   ${folder_key}/cacert_${i}.pem
       log to console  ${file_openssl_cnf}, ${file_cert}
       ${out}  issh.Execute  command=sudo cp ${file_openssl_cnf_seed} ${file_openssl_cnf}   alias=${alias}
       #change CA subject
       ${out}  issh.Execute  command=sudo sed -i 's/iv2trans/iv2trans_${i}/g' ${file_openssl_cnf}   alias=${alias}
       #generate ca.csr
       ${out}  issh.Execute  command=sudo openssl req -new -key ${file_cakey_pem} -out ${file_ca_csr} -config ${file_openssl_cnf}   alias=${alias}
       #generate ca.pem
       ${out}  issh.Execute  command=sudo openssl req -x509 -key ${file_cakey_pem} -outform PEM -out ${file_cert} -config ${file_openssl_cnf}
       ...   alias=${alias}  check_result=False
       Append To List   ${cert_file_list}   ${file_cert}
    END
    [Return]   ${cert_file_list}


Delete All Additional TA
    [Documentation]  Delete All Additional TA
    ...    *AUTHOR* zhiqiang.q2.liu@nokia-sbell.com
    ...   history change:
    ...     11.8.2021, zhiqiang.q2.liu@nokia-sbell.com, new
    ...     28.5.2023,chris.l.cao@nokia-sbell.com, move to common KW
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Delete All Additional TA |
    ...
    vDU Rest Login
    ${Certificate_dict}  vdu.get_vdu_certificates
    ${Cert_dict_length}=  get length  ${Certificate_dict}
    FOR  ${i}  IN RANGE  ${Cert_dict_length}
       ${id}  set variable  ${Certificate_dict[${i}]["id"]}
       ${operationID}  vdu.delete_certificates_by_id  certificate_id=${id}
       ${rtn}  Run Keyword And Ignore Error  wait until keyword succeeds  10   2
    ...   _Check vDU CMP Operation Should Be Expected   operationID=${operationID}   expected_status=Successful
    END


Change CRL Usage on vDU
    [Arguments]   ${usageEnabled}=Disabled
    [Documentation]   Change CRL Usage on vDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
	...   9.2.2023,chris.l.cao@nokia-sbell.com, initialization
    ...
    ...   | Input Parameters    | Man. | Description |
	...   | usageEnabled |   No   | Disabled or Enabled, default value is Disabled|
	...
    ...   *RETURN VALUE*
    ...   Change result, it includes original value and new value, we can restore it with this result by 'VDU Online Restore Parameters'
    ...   Please see examples.
    ...
    ...   Example
    ...   | ${change_result} | Change CRL Usage on vDU | usageEnabled=Disabled |
    ...   | Log To Console | Do something here... |
    ...   | VDU Online Restore Parameters | ${change_result} |
    ...
    ...   | ${change_result} | Change CRL Usage on vDU | usageEnabled=Enabled |
    ...   | Log To Console | Do something here... |
    ...   | VDU Online Restore Parameters | ${change_result} |
    ...
    ${vdu_conf}    Get VDU Conf From SCF
    ${para_list}   Create List      usageEnabled
    ${value_list}  Create List      ${usageEnabled}
    ${mo_list}     Create List      MRBTS-${vdu_conf["mrbts_id"]}/MNL-1/CERTH-1/CRLH-1
    vDU Rest Login
    ${ret}  VDU Online Change Parameters   para_list=${para_list}  value_list=${value_list}  mo_list=${mo_list}
    [Return]  ${ret}


_Get Specific Type Certificate List
    [Arguments]   ${Certificate_list}   ${type}=EE   ${key_pool_type}=RSA
    ${filter_certificate_list}   create list
    FOR  ${Certificate}  IN  @{Certificate_list}
        run keyword if   '${Certificate['type']}'=='${type}' and '${Certificate["details"]["key_pool_type"]}'=='${key_pool_type}'
    ...  append to list   ${filter_certificate_list}   ${Certificate}
    END
    [Return]  ${filter_certificate_list}
