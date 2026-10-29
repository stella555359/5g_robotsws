*** Settings ***
Library     taf.sbts.oam.coam.admin  WITH NAME  admin
Library     taf.transport.ssh  WITH NAME  ssh
Library     SSHLibrary
Library     taf.config.scf  WITH NAME  scf
Library     ./python_lib/onap.py
Resource    ./common.robot

Documentation
...  AUTHORS:       mateusz.gumieniak@nokia.com, grzegorz.niedzwiedz@nokia.com, jakub.hirny@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library for ONAP connections keywords
...  Based on testsuite/Wroclaw/TRS/RAN_5G/features/CB007010_FM/keywords.robot
...  ******************
...  History of changes
...  ******************
...  23.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-398 Library creation
...  04.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-450 Adaptation for local server option
...  07.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-479 Change ${cert_path}
...  05.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-497 Update "Get Param List" to dynamically aquire MPLANEONAP-1.mPlaneAddressDN value
...  25.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-554 - Add KW "Delta Reconfig For certToNameMappingList"
...               and modify "Get Params List" to support setting specified value for activateOranO1NetconfService
...  30.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-576 - Adapt KWs: "Create MPLANEONAP Object", "Get Params List" and "Delta Reconfig For
...               certToNameMappingList" to work during Suite Setup/Teardown.

*** Variables ***
#ONAP data from local server
${ONAP_local}               10.42.54.11
${ONAP_local_LOGIN}         trssec
${ONAP_local_PASSWORD}      YT_xk39b
#ONAP data from ONAP labs OneNote @IMPORTANT@ - may be changed by Netact
${ONAP2_IP}                 10.110.73.138
${ONAP2_LOGIN}              ute
${ONAP2_PASSWORD}           Ut3pa5s#84b6
#Other variables
${CERTS_SUBJECT_NAME}       C=PL, O=Common, CN=IPSEC
${CA_SERVER_IP}             10.42.54.13
${CA_SERVER_PATH}           pkix
${CA_DEFAULT_PORT}          8080
${fingerprint_local}        98:81:C4:73:44:34:1D:AB:58:26:D3:0A:D4:9F:9B:AA:77:0C:73:F0
${cmd_certFingerPrint1}     kubectl -n onap exec -it dev-sdnc-0 -- /bin/bash -c 'openssl x509 -fingerprint -noout
${cmd_certFingerPrint2}     -in /var/custom-certs/cert.pem | sed -e"s/SHA1 Fingerprint//; s/=//; s/=//p"'
${cert_path}                /media/Global_veryfication/Netconf_cert/BTS 1.p12
#toor4nsn
${ssh_host}                 192.168.255.129
${ssh_LOGIN}                toor4nsn
${ssh_PASSWORD}             oZPS0POrRieRtu

*** Keywords ***
Setup TAF ONAP
    [Documentation]    KW for ONAP setup with possibility to choose between local and remote server connection. Remote connection is default.
    ...    There is possibility to set variable -v NETCONF_SERVER:local
    [Arguments]    ${server}=remote
    ${server_chosen}=    Run Keyword And Return Status    Variable Should Exist    ${NETCONF_SERVER}
    ${remote}=    Run Keyword And Return Status    Run Keyword If    ${server_chosen}
    ...    Should Be Equal    ${NETCONF_SERVER}    remote    ignore_case=${true}
    ${local}=    Run Keyword And Return Status    Run Keyword If    ${server_chosen}
    ...    Should Be Equal    ${NETCONF_SERVER}    local    ignore_case=${true}
    Run Keyword If    ${server_chosen} and ${local}
    ...    Set Test Variable    ${server}    local
    Run Keyword If    ${server_chosen} and not ${remote} and not ${local}
    ...    Log to console    Chosen server value "${NETCONF_SERVER}" is invalid. Connection to ${server} server will be selected.
    Log to console  ==============
    Log to console  Setup TAF ONAP
    Log to console  ==============
    ${rats}=  Detect RATs
    Set Test Variable  ${rats}
    Log To Console  Detected RATs: ${rats}
    ${if_NR_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  nr
    Run Keyword If  ${if_NR_exist}  Run Keywords  Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                    ...    AND    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                    ...    AND    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
                                    ...    AND    Allow Fault In Watchdog  faultID=6150  #GTP-U Path failure can be visible during startup
    ${connection}=  admin.connect_to  bts_host=192.168.255.129   bts_port=443  username=Nemuadmin  password=nemuuser
    Set Suite Variable     ${GLOBAL_ADMIN_CONNECTION}  ${connection}
    Log to console  Create MPLANEONAP object
    Run keyword and ignore error  Create MPLANEONAP Object
    Run Keyword If    '${server}'=='local'
    ...    Run Keywords
    ...    Install Cert
    ...    AND    Log to console  Create certificate to NameMappingList for local server
    ...    AND    Wait until keyword succeeds  15min  1min  Create certificateToNameMappingList  ${fingerprint_local}
    ...    ELSE    Run Keywords
    ...    Get Fingerprint
    ...    AND    Log to console  Create certificate to NameMappingList for remote server
    ...    AND    Wait until keyword succeeds  15min  1min  Create certificateToNameMappingList  ${remote_fingerprint}
    Log to console  Activate parameter: activateOranO1NetconfService
    Netconf Service Parameter Update    True
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Run Keyword If  ${if_NR_exist}  Run Keywords  Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                    ...    AND    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                    ...    AND    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
                                    ...    AND    Disallow Fault In Watchdog  faultID=6150  #GTP-U Path failure can be visible during startup
    Add mplane to /etc/hosts   name=NetConfServer
    Log to console  Establish connection
    Establish Connection    ${server}
    Log to console  =======================
    Log to console  Setup TAF ONAP Finished with connection to ${server} server.
    Log to console  =======================

Install Cert
     admin.install_certificate    ${cert_path}     BtsTrustChain    P12    password=${ONAP_local_PASSWORD}    timeout=60
     ...    connection=${GLOBAL_ADMIN_CONNECTION}    detailed_output=True    key_pool_type=RSA    # Install cert from file

Establish Connection
    [Arguments]    ${connection_type}
    #bts
    ${ssh_index}  SSHLibrary.Open Connection  host=${ssh_host}
    ${out_put}  SSHLibrary.Login  ${ssh_LOGIN}  ${ssh_PASSWORD}
    SSHLibrary.Write  netstat -alnp | grep 6513
    ${op}  SSHLibrary.Read Until  LISTEN
    Log to console  ${op}
    #onap
    Run Keyword If    '${connection_type}'=='local'
    ...    Local Connection
    Run Keyword If    '${connection_type}'=='remote'
    ...    Remote Connection
    #bts
    Switch Connection  ${ssh_index}
    SSHLibrary.Write  netstat -alnp | grep 6513
    ${op}  SSHLibrary.Read Until  ESTABLISHED
    Log to console  ${op}

Local Connection
    ${ssh_index2}  SSHLibrary.Open Connection  host=${ONAP_local}
    ${out_put2}  SSHLibrary.Login  ${ONAP_local_LOGIN}  ${ONAP_local_PASSWORD}
    Set Test Variable  ${ssh_index2}
    Set Test Variable  ${out_put2}
    Switch Connection  ${ssh_index2}
    SSHLibrary.Write  netopeer2-cli
    ${output}= 	Read 	delay=1s
    Log to console  ${output}
    SSHLibrary.Write Bare  connect --tls --host NetConfServer --key NetConf/certy_rsa/btskey.pem --
    SSHLibrary.Write  cert NetConf/certy_rsa/btscert.pem --trusted NetConf/certy_rsa/ca256.pem\r\n
    ${output}= 	Read 	delay=0.5s
    Log to console  ${output}

Remote Connection
    ${ssh_index2}  SSHLibrary.Open Connection  host=${ONAP2_IP}
    ${out_put2}  SSHLibrary.Login  ${ONAP2_LOGIN}  ${ONAP2_PASSWORD}
    Set Test Variable  ${ssh_index2}
    Set Test Variable  ${out_put2}
    Switch Connection  ${ssh_index2}
    SSHLibrary.Set Client Configuration  prompt=#
    Run Keyword If   '${ONAP2_LOGIN}'!='root'   Run Keywords   SSHLibrary.Write   sudo -i
    ...   AND   SSHLibrary.Read Until Prompt
    SSHLibrary.Write  kubectl -n onap get pod | grep netconf
    ${output}  SSHLibrary.Read Until  Running
    Log to console  ${output}
    ${server_id}  Get Substring 	${output} 	0 	31
    Log to console  Netconf server: ${server_id}
    SSHLibrary.Write  kubectl -n onap exec -it ${server_id} bash
    ${output}= 	Read 	delay=1s
    Log to console  ${output}
    SSHLibrary.Write  netopeer2-cli
    ${output}= 	Read 	delay=1s
    Log to console  ${output}
    SSHLibrary.Write  connect --tls --host ${ENB_MPLANE_IP}\r\n
    ${output}= 	Read 	delay=0.5s
    Log to console  ${output}

Add mplane to /etc/hosts
    [Arguments]   ${name}
    SSHLibrary.Open Connection   ${ONAP_local}
    SSHLibrary.Login             ${ONAP_local_LOGIN}   ${ONAP_local_PASSWORD}
    ${write}  SSHLibrary.Write  sudo su
    Sleep  5
    ${sudo}  SSHLibrary.Read
    Should contain  ${sudo}  password
    SSHLibrary.Write  ${ONAP_local_PASSWORD}
    ${z}  SSHLibrary.Write  echo ${ENB_MPLANE_IP} ${name} >> /etc/hosts
    ${sudo}  SSHLibrary.Read

Delete mplane from /etc/hosts
    SSHLibrary.Open Connection    ${ONAP_local}
    SSHLibrary.Login              ${ONAP_local_LOGIN}   ${ONAP_local_PASSWORD}
    ${write}  SSHLibrary.Write  sudo su
    Sleep  5
    ${sudo}  SSHLibrary.Read
    Should contain  ${sudo}  password
    SSHLibrary.Write  ${ONAP_local_PASSWORD}
    ${z}  SSHLibrary.Write  sed -i '/${ENB_MPLANE_IP}/d' /etc/hosts
    ${sudo}  SSHLibrary.Read

Get Fingerprint
    ${ssh_index}  SSHLibrary.Open Connection  host=${ONAP2_IP}
    ${out_put}  SSHLibrary.Login  ${ONAP2_LOGIN}  ${ONAP2_PASSWORD}
    SSHLibrary.Set Client Configuration  prompt=#
    SSHLibrary.Set Client Configuration   timeout=20
    Run Keyword If   '${ONAP2_LOGIN}'!='root'   Run Keywords   SSHLibrary.Write   sudo -i
    ...   AND   SSHLibrary.Read Until Prompt
    ${cmd_certFingerPrint}  Set Variable  ${cmd_certFingerPrint1} ${cmd_certFingerPrint2}
    SSHLibrary.Write  ${cmd_certFingerPrint}
    ${fingerprint}  SSHLibrary.Read Until  r
    ${certFingerPrint}  Split string  ${fingerprint}
    Set Test Variable    ${remote_fingerprint}    ${certFingerPrint}[0]
    [Return]  ${certFingerPrint}[0]    # Fingerprint for ONAP labs

Create MPLANEONAP Object
    [Arguments]  ${activateOran}=false
    ${dist_name}=  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${params_list}=  Get Params List  ${activateOran}
    admin.perform_object_recommissioning  dist_name=${dist_name}
    ...                                   parameter=${params_list}
    ...                                   operation=create
    ...                                   skip_parameter_relation_errors=${FALSE}
    ...                                   should_activate=${True}
    ...                                   connection=${GLOBAL_ADMIN_CONNECTION}

Get Params List
    [Arguments]  ${activateOran}=false
    ${is_in_test}  Run Keyword And Return Status  Variable Should Exist  ${RESULTS}
    ${RESULTS}  Set Variable If  ${is_in_test}  ${RESULTS}  ${SUITE_RESULTS}
    scf.load_scf    ${RESULTS}/SCF_BACKUP.xml
    ${mplanenw_ipv4}=    Run Keyword And Ignore Error
    ...    scf.get_value_from_scf    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANENW-1    p_name=mPlaneIpv4AddressDN
    ${mplanenw_ipv6}=    Run Keyword And Ignore Error
    ...    scf.get_value_from_scf    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANENW-1    p_name=mPlaneIpv6AddressDN
    ${mplanenw_ip_DN}=    Set Variable If    '${mplanenw_ipv4[0]}'=='PASS'    ${mplanenw_ipv4[1]}   ${mplanenw_ipv6[1]}
    &{l1}  Create Dictionary  parameterName=activateOranO1NetconfService  operation=update  value=${activateOran}
    &{l2}  Create Dictionary  parameterName=mPlaneOnapId  operation=update  value=1
    &{l3}  Create Dictionary  parameterName=mPlaneAddressDN  operation=update  value=${mplanenw_ip_DN}
    @{params_list}  Create List  ${l1}  ${l2}  ${l3}
    [Return]  ${params_list}


#Initialize certificate
#    admin.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID}/MNL-1/CERTH-1/CMP-1  parameter=caSubjectName
#    ...                         operation=update  value=${CERTS_SUBJECT_NAME}  connection=${GLOBAL_ADMIN_CONNECTION}
#    admin.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID}/MNL-1/CERTH-1/CMP-1  parameter=serverHost
#    ...                         operation=update  value=${CA_SERVER_IP}   connection=${GLOBAL_ADMIN_CONNECTION}
#    admin.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID}/MNL-1/CERTH-1/CMP-1  parameter=serverPath
#    ...                         operation=update  value=${CA_SERVER_PATH}   connection=${GLOBAL_ADMIN_CONNECTION}
#    admin.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID}/MNL-1/CERTH-1/CMP-1  parameter=serverPort
#    ...                         operation=update  value=${CA_DEFAULT_PORT}  connection=${GLOBAL_ADMIN_CONNECTION}
#    admin.cmp_initialize_certificate  connection=${GLOBAL_ADMIN_CONNECTION}

Create certificateToNameMappingList
    [Arguments]  ${fingerprint}
    ${base_scf_path}=  admin.get_current_scf_file  local_dir_path=/home/ute  file_name=old_scf.xml   connection=${GLOBAL_ADMIN_CONNECTION}
    &{params}=  Create dictionary  certFingerPrint=02:${fingerprint}   mapType=specified  userName=cmuser
    ${new_scf_path}=   modify_scf  ${MRBTS_ID}  ${params}  ${base_scf_path}
    Log  Uploading scf...  console=${true}
    admin.perform_commissioning    scf_file=${new_scf_path}  skip_parameter_relation_errors=False  should_activate=True
    ...                            timeout=900  connection=${GLOBAL_ADMIN_CONNECTION}
    Log  Scf uploaded  console=${true}

Modify SCF ROBOT
    [Arguments]  ${MRBTS_ID}   ${params}  ${base_scf_path}
    Log  ${params}  console=${True}
    scf.load_scf  ${base_scf_path}
    Run Keyword If  scf.is_list_in_object  dist_name="MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1"  list_name="certToNameMappingList"
    ...  scf.save_scf  /home/ute/new_scf.xml
    ...  ELSE  scf.add_list_to_scf  dist_name="MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1"  list_name="certToNameMappingList"
    ...  scf.add_item_to_list  dist_name="MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1"  list_name="certToNameMappingList"  elements=dict_name
    ...  scf.save_scf  /home/ute/new_scf.xml
    [Return]  ${new_scf_path}

Teardown TAF ONAP
    Log to console  =================
    Log to console  Teardown TAF ONAP
    Log to console  =================
    Switch Connection  ${ssh_index2}
    SSHLibrary.Write  disconnect\r\n
    ${output}  Run keyword And Return Status  SSHLibrary.Read Until  ESTABLISHED
    Run Keyword If  '${output}'=='False'  Log To Console  Disconnected from ONAP server
    Delete mplane from /etc/hosts
    ${if_NR_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  nr
    Run Keyword If  ${if_NR_exist}  Run Keywords  Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                    ...    AND    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                    ...    AND    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
                                    ...    AND    Allow Fault In Watchdog  faultID=6150  #GTP-U Path failure can be visible during startup
    Remove MPLANEONAP Object If Exists
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Run Keyword If  ${if_NR_exist}  Run Keywords  Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                    ...    AND    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                    ...    AND    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
                                    ...    AND    Disallow Fault In Watchdog  faultID=6150  #GTP-U Path failure can be visible during startup
    Log To Console  ======================
    Log To Console  Teardown TAF ONAP done
    Log To Console  ======================

Remove MPLANEONAP Object If Exists
    ${gpoup_obj_all}=  admin.get managed objects  MPLANEONAP_A
    Run Keyword If  ${gpoup_obj_all}!=[]  Run Keywords
    ...  Log  MPLANEONAP object exists and will be deleted  console=${true}
    ...  AND  Delete Old MPLANEONAP Object  ${gpoup_obj_all}
    ...  ELSE  Log  There is no MPLANEONAP object on testline

Delete Old MPLANEONAP Object
    [Documentation]  Remove old MPLANEONAP object from BTS.
    [Arguments]    ${gpoup_obj_all}
    ${gpoup_path_list}=  Create List
    FOR  ${i}  IN  @{gpoup_obj_all}
        ${gpoup_distName}=  Set Variable  ${i['distName']}
        ${ignore}  ${gpoup_path}=  Split String From Right  ${gpoup_distName}  separator=SCF-1/
        ${gpoup}=  Replace String  ${gpoup_path}  search_for=_A  replace_with=
        Append To List  ${gpoup_path_list}  ${gpoup}
    END
    ${delta_gpoup_obj}=  Set Variable  gpoup_del
    admin.Create Delta  ${delta_gpoup_obj}
    FOR  ${i}  IN  @{gpoup_path_list}
        append managed object to delta  ${i}  delete  delta_id=${delta_gpoup_obj}
    END
    get delta  ${delta_gpoup_obj}
    save delta  ${RESULTS}/delete_gpoup_obj.json  delta_id=${delta_gpoup_obj}
    admin.perform delta recommissioning  ${RESULTS}/delete_gpoup_obj.json  ${SKIP_PARAMETER_RELATION_ERRORS}

Check Netconf Status
    [Documentation]    Keyword checks current Netconf Server status and compares it to expected value.
    ...    Possible status values are: Disabled, Initializing, Ready, InRecovery, Failed.
    [Arguments]    ${expected}=Ready
    ${netconf_MO}=    admin.get managed objects    NETCONF_SERVER
    FOR    ${i}    IN    @{netconf_MO}
        ${status}=    Set Variable    ${i['parameters']['status']}
        ${is_expected}=    Run Keyword And Return Status    Should Be Equal    ${status}    ${expected}    ignore_case=${True}
        Run Keyword If    ${is_expected}    Log To Console    Netconf Server Status (${status}) is as expected (${expected}).
        ...    ELSE    Run Keywords    Log To Console    Checking Netconf Server Status...
        ...    AND    Log    Netconf Server Status (${status}) is NOT as expected (${expected}).
        ...    AND    Fail    msg=Netconf Server Status (${status}) was NOT as expected (${expected}).
    END
    [Return]    ${is_expected}    ${status}    ${expected}

Get Value Under MPLANEONAP Object
    [Arguments]  ${parameter}
    ${MPLANEONAP_A}=  admin.Get Managed Objects  MPLANEONAP_A
    FOR  ${item}  IN  @{MPLANEONAP_A}
         ${value}=  Set Variable If  ${item['parameters']['${parameter}']}==${None}   ${value}  ${item['parameters']['${parameter}']}
    END
    [Return]  ${value}

Netconf Service Parameter Update
    [Arguments]    ${value}
    ${current_value}=    Wait Until Keyword Succeeds    6x    10 sec    Get Value Under MPLANEONAP Object    activateOranO1NetconfService
    ${is_same}=    Run Keyword And Return Status    Should Be Equal    '${value}'    '${current_value}'    ignore_case=${True}
    ${is_true}=    Run Keyword And Return Status    Should Be Equal    ${value}    true     ignore_case=${True}
    ${is_false}=   Run Keyword And Return Status    Should Be Equal    ${value}    false    ignore_case=${True}
    ${param}=    Run Keyword If    ${is_true}    Set Variable    true
    ...    ELSE    Set Variable    false
    Run Keyword If    not ${is_same} and ${is_false}
    ...    Log To Console    == Performing site reset after flag deactivation ==
    Run Keyword If    not ${is_same} and ${is_true}
    ...    Log To Console    == Performing site reset after flag activation ==
    ${state}=    Set Variable If    '${param}'=='true'    turned ON - flag enabled
    ...    '${param}'=='false'    turned OFF - flag disabled
    Run Keyword If    not ${is_same}    Run Keywords
    ...    Wait Until Keyword Succeeds  15min  1min  admin.perform_parameter_recommissioning
    ...                             dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...                             parameter=activateOranO1NetconfService
    ...                             operation=update  value=${param}
    ...    AND    Log To Console    == Netconf Service is now ${state} ==
    ...    ELSE   Log To Console    Parameter activateOranO1NetconfService is already set to ${value}.
    [Return]    ${is_same}

Delta Reconfig For certToNameMappingList
    [Documentation]  Keyword creates delta for certToNameMappingList and performs its recomissioning.
    ${is_in_test}  Run Keyword And Return Status  Variable Should Exist  ${RESULTS}
    ${RESULTS}  Set Variable If  ${is_in_test}  ${RESULTS}  ${SUITE_RESULTS}
    admin.create delta  delta_reconfig
    ${cert_reconfig}  Create Dictionary
    ${ONAP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    Set To Dictionary  ${cert_reconfig}  userName=cmuser
    Set To Dictionary  ${cert_reconfig}  mapType=specified
    Set To Dictionary  ${cert_reconfig}  certFingerPrint=02:${fingerprint_local}
    admin.append complex item to delta  ${ONAP_DN}  list_name=certToNameMappingList  &{cert_reconfig}  delta_id=delta_reconfig
    admin.get delta  delta_reconfig
    admin.save delta  ${RESULTS}/delta_reconfig_ONAP.json  delta_reconfig
    admin.perform delta recommissioning  ${RESULTS}/delta_reconfig_ONAP.json  delta_reconfig
