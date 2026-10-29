*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_sec_cert.robot



*** Variables ***



*** Keywords ***
Install Operator Certificate on VCU
    [Arguments]     ${CA_SubjectName}=${CA1_SubjectName}  ${CMP_Server_PORT}=${CMP1_Server_SingleLayer_PORT}
    ...   ${ref_number}=${CA1_Ref_Num}  ${psk_key}=${CA1_PSK}   ${gnb_index}=0
    [Documentation]   Install Operator Certificate on VCU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...   history change:
    ...  12.10.2021, zhiqiang.q2.liu@nokia-sbell.com, modify for multiple layer certificate
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | ref_number          | no | default is CA1_Ref_Num |
    ...   |psk_key              | no | default is CA1_PSK |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | Install Operator Certificate on VCU |
    ...
    Configure CMP related parameters on VCU  CA_SubjectName=${CA_SubjectName}  CMP_Server_PORT=${CMP_Server_PORT}
    ...   gnb_index=${gnb_index}

    Log To Console    Configure PSK and Ref#
    ${alias}    CU Rest Login    gnb_index=${gnb_index}
    Update VCU CMP Server Settings  ref_number=${ref_number}  psk_key=${psk_key}   alias=${alias}
    ${oldCertificate}  cu.get_operator_certificate_list   connection=${alias}

    Log To Console    Enroll operator Certificate
    wait until keyword succeeds  5x  60s   Initialize Operator Certificate On VCU   alias=${alias}
#    CU Rest Logout   gnb_index=${gnb_index}   connection=${alias}
#    ${alias}   wait until keyword succeeds  100   5    CU Rest Login    gnb_index=${gnb_index}
    ${newCertificate}  cu.get_operator_certificate_list   connection=${alias}
    Should Be True   ${oldCertificate[0]["details"]["serial_number"]}!=${newCertificate[0]["details"]["serial_number"]}


Install ECDSA Operator Certificate via CMP on vCU
    [Arguments]   ${CA_SubjectName}=${CA2_SubjectName_EC}       ${CMP_Server_PORT}=${CMP1_Server_SingleLayer_PORT}
    ...              ${ref_number}=${CA2_Ref_Num_EC}    ${psk_key}=${CA2_PSK_EC}
    [Documentation]   Install ECDSA Operator Certificate via CMP on vCU
    ...   *AUTHOR* huilin.xu@nokia-sbell.com
    ...   history change: 08.05.2023, huilin.xu@nokia-sbell.com, initial create
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | CA_SubjectName      | no | default is CA2_SubjectName_EC in variables.robot |
    ...   | CMP_Server_PORT     | no | default is CMP1_Server_SingleLayer_PORT in variables.robot |
    ...   | ref_number          | no | default is CA2_Ref_Num_EC in variables.robot |
    ...   | psk_key             | no | default is CA2_PSK_EC in variables.robot |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | Install ECDSA Operator Certificate via CMP on vCU | CA_SubjectName=${CA2_SubjectName_EC} |
    ...  | CMP_Server_PORT=${CMP1_Server_SingleLayer_PORT}   |  ref_number=${CA2_Ref_Num_EC}        |
    ...  | psk_key=${CA2_PSK_EC} |
    ...

    Configure CMP related parameters on VCU    CA_SubjectName=${CA_SubjectName}  CMP_Server_PORT=${CMP_Server_PORT}  CMP_Type=ECDSA
	  Log To Console    Configure PSK and Ref#
    CU Login
    Update VCU CMP Server Settings        ref_number=${ref_number}  psk_key=${psk_key}  key_pool_type=ECDSA
    Log To Console    Enroll operator Certificate
    Initialize Operator Certificate On VCU     key_pool_type=ECDSA
    CU Rest Logout


Configure CMP related parameters on VCU
    [Arguments]     ${CA_SubjectName}=${CA1_SubjectName}  ${CMP_Server_PORT}=${CMP1_Server_SingleLayer_PORT}  ${CMP_Type}=RSA
    ...   ${gnb_index}=0
    [Documentation]   Configure CMP related parameters on VCU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...   history change:
    ...   12.10.2021, zhiqiang.q2.liu@nokia-sbell.com, modify for multiple layer certificate
    ...   14.12.2021, zhiqiang.q2.liu@nokia-sbell.com, modify for failure when both serverPort and serverPath are not changed
    ...   20.12.2021, chris.l.cao@nokia-sbell.com, do not delete eeSubjectName when it's not avaliable,
    ...                                            do not delete caSubjectName when it's not avaliable
    ...   08.05.2023,huilin.xu@nokia-sbell.com, add CMP_Type parameter to cover ECDSA type
    ...   06.07.2023,rui.3.li@nokia-sbell.com, support multiple cu
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | CA_SubjectName    | No | SubjectName |
    ...   | CMP_Server_PORT    | No | default value is 8080 |
    ...   | CMP_Type           | No | cmp certificate type, default value is RSA |
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | Configure CMP related parameters on VCU |
    ...  | Configure CMP related parameters on VCU |  CA_SubjectName=${CA2_SubjectName_EC}  |
    ...  | CMP_Server_PORT=${CMP1_Server_SingleLayer_PORT}  | CMP_Type=ECDSA |
    ...
    Log To Console    Configure CMP related parameters on VCU
    ${alias}   CU Rest Login    gnb_index=${gnb_index}
    ${plan_file_path}=    Get A File    CMP_KW_SCF    vcu_cmp_scf.xml
#    cu.get_current_plan_file   path=${plan_file_path}  timeout=60  include_runtime_data=${True}
    cu.get_current_plan_file   path=${plan_file_path}  timeout=60  include_runtime_data=${False}   connection=${alias}
    scf.Load_Scf  file_path=${plan_file_path}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${plan_file_path}
    ${BTS_ID}  set variable   ${mrbts_id}

    ${isIPv6}  Check if VCU OAM is IPv6    gnb_index=${gnb_index}
    ${CMP_Server_IP}  Set Variable If   ${isIPv6}    ${CMP1_Server_IPv6}  ${CMP1_Server_IP}

    ${target_dict}  create dictionary
    ...  eeSubjectName=CN=MRBTS-${BTS_ID}
    ...  caSubjectName=${CA_SubjectName}
    ...  serverHost=${CMP_Server_IP}
    ...  serverPort=${CMP_Server_PORT}
    ...  serverPath=${CMP1_Server_Path}
    ${CMP_para}  create list  eeSubjectName    caSubjectName    serverHost    serverPort    serverPath

    ${cmp_dn}  Set Variable If  "${CMP_Type}"=="ECDSA"  MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1  MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ${out}  Get VCU Current Parameters Dict   para_list=${CMP_para}   mo=${cmp_dn}   gnb_index=${gnb_index}
    Return from keyword if   ${target_dict}==${out}

	${alias}   CU Rest Login    gnb_index=${gnb_index}
	${delta_plan_id}=  CU Generate Delta Plan Should Be Successful   alias=${alias}

	${need_delete}  Set Variable If
    ...   "${out["serverHost"]}"!="${None}" or "${out["eeSubjectName"]}"!="${None}" or "${out["caSubjectName"]}"!="${None}"   1  0

    #Remove
    &{temp_eeSubjectName}=   Create Dictionary    operation_type=remove    parameter_path=/eeSubjectName    value=${Empty}
    &{temp_caSubjectName}=    Create Dictionary    operation_type=remove    parameter_path=/caSubjectName    value=${Empty}
    &{temp_serverHost}=   Create Dictionary    operation_type=remove    parameter_path=/serverHost     value=${Empty}
    #@{deleted_List}=    Create List    ${temp_eeSubjectName}    ${temp_caSubjectName}    ${temp_serverHost}
    ${deleted_List}    Create List
    Run Keyword If   "${out["serverHost"]}"!="${None}"      Append To List   ${deleted_List}    ${temp_serverHost}
    Run Keyword If   "${out["eeSubjectName"]}"!="${None}"   Append To List   ${deleted_List}    ${temp_eeSubjectName}
    Run Keyword If   "${out["caSubjectName"]}"!="${None}"   Append To List   ${deleted_List}    ${temp_caSubjectName}

    #add
    &{temp_eeSubjectName}=   Create Dictionary    operation_type=add    parameter_path=/eeSubjectName    value=CN=MRBTS-${BTS_ID}
    &{temp_caSubjectName}=    Create Dictionary    operation_type=add    parameter_path=/caSubjectName    value=${CA_SubjectName}
    &{serverHost}=            Create Dictionary    operation_type=add    parameter_path=/serverHost     value=${CMP_Server_IP}
    &{serverPort}=   Create Dictionary    operation_type=replace    parameter_path=/serverPort    value=${CMP_Server_PORT}
    &{serverPath}=    Create Dictionary    operation_type=replace    parameter_path=/serverPath    value=${CMP1_Server_Path}
    @{add_List}=    Create List    ${temp_eeSubjectName}    ${temp_caSubjectName}    ${serverHost}  ${serverPort}  ${serverPath}

    #Remove
    ${out}   Run Keyword If  ${need_delete}==1   CU Update Delta Plan Should Be Successful   plan_id=${delta_plan_id}   mo_dn=${cmp_dn}
        ...   parameter_change_list=${deleted_List}   alias=${alias}
    Run Keyword If   ${need_delete}==1    CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}   alias=${alias}
    Run Keyword If   ${need_delete}==1    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}   alias=${alias}

    #add

    ${delta_plan_id}=  CU Generate Delta Plan Should Be Successful   alias=${alias}
    CU Update Delta Plan Should Be Successful   plan_id=${delta_plan_id}  mo_dn=${cmp_dn}   parameter_change_list=${add_List}
    ...   alias=${alias}
    CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}   alias=${alias}
    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}   alias=${alias}


Get VCU Current Parameters Dict
    [Arguments]   ${para_list}    ${mo}    ${gnb_index}=0
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
    CU Rest Login    gnb_index=${gnb_index}
    ${length}=    get length    ${para_list}
    FOR    ${i}    IN RANGE    0     ${length}
        ${status}  ${value}   Run Keyword And Ignore Error   CU Get Online Parameter Value   ${mo}  ${para_list[${i}]}
        ${value_current}  Set Variable If  '${status}'=='PASS'   ${value}  ${null}
        Set to Dictionary  ${origin_para_value_dict}  ${para_list[${i}]}   ${value_current}
    END
    [Return]  &{origin_para_value_dict}


Update VCU CMP Server Settings
    [Arguments]  ${ref_number}   ${psk_key}  ${key_pool_type}=RSA   ${alias}=default
    [Documentation]   Update VCU CMP Server Settings
    ...   *AUTHOR* Shubin.Ren@nokia-sbell.com
    ...  27.5.2023  chris.l.cao@nokia-sbell.com, rename KW name to 'Update VCU CMP Server Settings'
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | ref_number    | yes | Reference Number |
    ...   | psk_key       | yes | Pre-shared Key |
    ...   | key_pool_type | no  | RSA or ECDSA,default is RSA |
    ...
    ...   *RETURN VALUE*
    ...    dictionary result of operation result, e.g. {'status': 'Successful'}
    ...
    ...   Example
    ...  | CU Rest Login |
    ...  | Update VCU CMP Server Settings | ref_number=3071 | psk_key=LqH6-myAf-5FXH-TCQw |
    ...  | Update VCU CMP Server Settings | ref_number=3071 | psk_key=LqH6-myAf-5FXH-TCQw | key_pool_type=ECDSA |
    ...
    ${out}  cu.update_cmp_server_settings   ref_number=${ref_number}  psk_key=${psk_key}  key_pool_type=${key_pool_type}
    ...   timeout=60   connection=${alias}
    Should Be True  "${out["status"]}"=="Successful"
    [Return]  ${out}


Initialize Operator Certificate On VCU
    [Arguments]   ${timeout}=60  ${key_pool_type}=RSA   ${alias}=default
    [Documentation]   Initialize Operator Certificate On VCU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...  Change History
    ...  10.8.2021  lijuan.1.wang@nokia-sbell.com, Initiation
    ...  20.12.2021   chris.l.cao@nokia-sbell.com,  add parameter timeout
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | timeout | no | timeout, default is 30 |
    ...   | key_pool_type | no | RSA or ECDSA, default is RSA |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | CU Rest login |
    ...  | Initialize Operator Certificate On VCU |
    ...  | Initialize Operator Certificate On VCU | key_pool_type=RSA |
    ...  | Initialize Operator Certificate On VCU | key_pool_type=ECDSA |
    ...
    ${out}  cu.trigger_certificate_initialization   timeout=${timeout}  key_pool_type=${key_pool_type}   connection=${alias}
    Should Be True  "${out["status"]}"=="Successful"
    [Return]  ${out}


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
    [Arguments]  ${timeout}=30   ${gnb_index}=0
    [Documentation]   Delete All Operator Certificates On vCU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...  Change History
    ...  10.8.2021  lijuan.1.wang@nokia-sbell.com, Initial creation
    ...  6.12.2021   chris.l.cao@nokia-sbell.com,  add parameter timeout
    ...  6.7.2023   rui.3.li@nokia-sbell.com, support multiple cu
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | timeout | no | timeout, default is 30 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | Delete All Operator Certificates On vCU |
    ...
    ${alias}   CU Rest Login   gnb_index=${gnb_index}
    ${out}  cu.delete_all_operator_certificates    timeout=${timeout}   connection=${alias}
    Should Be True  "${out["status"]}"=="Successful"
    [Return]  ${out}


Add manual CRLDP on CU Via Delta Plan
   [Documentation]  Add manual CRLDP on CU Via Delta Plan
    ...    author: chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2023.1.11  chris.l.cao@nokia-sbell.com, initialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...   None
    ...
    ...   Example
    ...  | Add manual CRLDP on CU Via Delta Plan |
    ...

    Log To Console   Add manual CRLDP on CU Via Delta Plan

    ${mrbts_id}	 Get MRBTS Id From vCU SCF
    ${mo_list}  Create List    MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
        ...   MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-20
    ${result}  VCU Get Object Existence  ${mo_list}

    ${existence_CRLDPCONFIG_1}  Set Variable    ${result["MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1"]}
    ${existence_CRLDPCONFIG_20}  Set Variable    ${result["MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-20"]}

    Run Keyword If  "${existence_CRLDPCONFIG_1}"=="${True}" or "${existence_CRLDPCONFIG_20}"=="${True}"
      ...   Log To Console  There is old manual DP, so delete it firstly ...
    Run Keyword If  "${existence_CRLDPCONFIG_1}"=="${True}" or "${existence_CRLDPCONFIG_20}"=="${True}"   Delete manual CRLDP on CU Via Delta Plan

    ${delta_plan_id}   CU Generate Delta Plan Should Be Successful

    CU Create Delta Plan Managed Object Should Be Successful   plan_id=${delta_plan_id}   mo_dn=MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1
    ...   name=com.nokia.srbts.mnl:CRLDPCONFIG   instance_id=1

    CU Create Delta Plan Managed Object Should Be Successful   plan_id=${delta_plan_id}   mo_dn=MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1
    ...   name=com.nokia.srbts.mnl:CRLDPCONFIG   instance_id=20

    &{primaryCRLDP}   create dictionary   operation_type=add    parameter_path=/primaryCRLDP    value=${CRLDP1}
    &{secondaryCRLDP}   create dictionary   operation_type=add    parameter_path=/secondaryCRLDP    value=${CRLDP2}
    @{value_CRLDPCONFIG_1}      Create List  ${primaryCRLDP}  ${secondaryCRLDP}
    CU Update Delta Plan Should Be Successful  plan_id=${delta_plan_id}  mo_dn=MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...  parameter_change_list=${value_CRLDPCONFIG_1}

    &{primaryCRLDP}   create dictionary   operation_type=add    parameter_path=/primaryCRLDP    value=${CRLDP3}}
    &{secondaryCRLDP}   create dictionary   operation_type=add    parameter_path=/secondaryCRLDP    value=${CRLDP4}
    @{value_CRLDPCONFIG_20}      Create List  ${primaryCRLDP}  ${secondaryCRLDP}
    CU Update Delta Plan Should Be Successful  plan_id=${delta_plan_id}  mo_dn=MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-20
    ...  parameter_change_list=${value_CRLDPCONFIG_20}

    CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}

    ${alias}    Connect To CU K8S Master With Admin
    Wait Until Keyword Succeeds  12min    20s   CU Pods Status Should Be Normal  alias=${alias}
    Wait Until Keyword Succeeds  180     20s   CU Oam Service Should Be Ready


Delete manual CRLDP on CU Via Delta Plan
   [Documentation]  Add manual CRLDP on CU Via Delta Plan
    ...    author: chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2023.1.11  chris.l.cao@nokia-sbell.com, initialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...   None
    ...
    ...   Example
    ...  | Delete manual CRLDP on CU Via Delta Plan |
    ...

    Log To Console   Delete manual CRLDP on CU Via Delta Plan

    ${mrbts_id}	 Get MRBTS Id From vCU SCF
    ${mo_list}  Create List    MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
        ...   MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-20
    ${result}  VCU Get Object Existence  ${mo_list}

    ${delta_plan_id}   CU Generate Delta Plan Should Be Successful
	Run Keyword If  "${result["MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1"]}"=="${True}"
	   ...   CU Delete Delta Plan Managed Object Should Be Successful    ${delta_plan_id}    MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1

	Run Keyword If  "${result["MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-20"]}"=="${True}"
	   ...   CU Delete Delta Plan Managed Object Should Be Successful    ${delta_plan_id}    MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-20

    CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}

    Sleep  2


vCU Configure CRL DP Source
   [Arguments]    ${DP_source}=Certificate_extension   ${updatePeriod}=10  ${usageEnabled}=Enabled
   [Documentation]  vCU Configure CRL DP via Certificate
    ...    author: hefeng-cookie.qu@nokia-sbell.com
    ...    modified by:        <19-10-2021>, <hqu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  DP_source  | YES |  Certificate_extension or configuration_parameter or Extension_and_parameter |
    ...    | usageEnabled | YES |
    ...    | updatePeriod | YES |

    ...   Example
    ...  | vCU Configure CRL DP Source | DP_source=Certificate_extension | usageEnabled=Enabled | updatePeriod=24 |
    ...
    Log To Console   vCU Configure CRL DP Source: DP_source(${DP_source}),usageEnabled(${usageEnabled})
    CU Rest Login
    ${plan_file_path}=    Get A File    SCF    vcu_crl_scf.xml
    cu.get_current_plan_file   path=${plan_file_path}  timeout=60  include_runtime_data=${False}
    scf.Load_Scf  file_path=${plan_file_path}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${plan_file_path}

    ${target_dict}  create dictionary
    ...  distributionPointSource=${DP_source}
    ...  updatePeriod=${updatePeriod}
    ...  usageEnabled=${usageEnabled}

    ${CRL_para}  create list   distributionPointSource    updatePeriod   usageEnabled
    ${out}  Get VCU Current Parameters Dict   para_list=${CRL_para}   mo=MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1
    Return from keyword if   ${target_dict}==${out}

	CU Rest Login
	${delta_plan_id}=  CU Generate Delta Plan Should Be Successful

    &{distributionPointSource}=   Create Dictionary    operation_type=replace    parameter_path=/distributionPointSource    value=${DP_source}
    &{updatePeriod}=    Create Dictionary    operation_type=replace    parameter_path=/updatePeriod    value=${updatePeriod}
    &{usageEnabled}=    Create Dictionary    operation_type=replace    parameter_path=/usageEnabled    value=${usageEnabled}
    @{replaced_List}=    Create List    ${distributionPointSource}    ${updatePeriod}    ${usageEnabled}

    ${crl_dn}   set variable   MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1
    CU Update Delta Plan Should Be Successful   plan_id=${delta_plan_id}  mo_dn=${crl_dn}   parameter_change_list=${replaced_List}

	CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}


VCU Trigger CRL
    [Arguments]  ${timeout}=60
    [Documentation]  VCU Trigger CRL
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  30.12.2022   chris.l.cao@nokia-sbell.com,  initialization
    ...
    CU Rest Login
    ${out}   cu.trigger_crl_information_update   timeout=${timeout}
    [Return]  ${out}


Trigger CRL Should Be Successful
    [Arguments]  ${timeout}=60
    ${out}   VCU Trigger CRL
    Should Be True   "${out["status"]}"=="Successful"


Trigger CRL Should Be Failed
    [Arguments]  ${timeout}=60
    ${out}  VCU Trigger CRL
    Should Be True   "${out["status"]}"=="Failed"
