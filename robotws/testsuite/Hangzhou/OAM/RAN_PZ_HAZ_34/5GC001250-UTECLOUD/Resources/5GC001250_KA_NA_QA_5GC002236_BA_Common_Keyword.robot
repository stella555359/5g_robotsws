*** Settings ***
Documentation     author: wuxia
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: xia.wu@nokia-sbell.com

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/siso_resource.robot
Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py   WITH NAME    lib
Library           taf.sbts.oam.coam.admin   WITH NAME   cli
Library           taf.transport.ssh    WITH NAME    ssh
Library           taf.ul.oam.netact.cm     WITH NAME     netact_cm
Library           OperatingSystem
Library           Collections
Library           taf.pdu
Library           String
Library           Process
Library           XML   use_lxml=True    WITH NAME    myxml
Library           taf.config.scf    WITH NAME    scf
Library           5GC001250-KA.py



*** Variables ***
${DU_OAM_IP}            ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${CU_OAM_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${scf_name}    current_scf.xml
${NETACT_USERNAME}=   omc
${NETACT_PASSWORD}=   Nokia123!
${connection}     DU_OAM
${tmp_log_dir}          /home/ute/logs
${ADMIN_IP_Address}     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${testline}  7_5_UTE5G401T906

${Template_SCF}=     <?xml version="1.0" encoding="UTF-8"?>
...   <!DOCTYPE raml SYSTEM 'raml20.dtd'>
...   <raml version="2.0" xmlns="raml20.xsd">
...     <cmData type="plan" scope="all" name="SCF_Template" id="SCF_conf">
...       <header>
...         <log dateTime="2020-02-13T09:44:55.000+08:00" action="created" appInfo="ActualExporter">InternalValues are used</log>
...       </header>
...       <managedObject class="FEATCADM" version="MNL5GC19B_1911_003" distName="PLMN-PLMN/MRBTS-xxxx/MNL-1/MNLENT-1/FEATCADM-1" operation="update">
...          <p name="systemAcctPermEnable">1</p>
...       </managedObject>
...     </cmData>
...   </raml>

${Template_SCF_RMOD_Lock}=     <?xml version="1.0" encoding="UTF-8"?>
...   <!DOCTYPE raml SYSTEM 'raml20.dtd'>
...   <raml version="2.0" xmlns="raml20.xsd">
...     <cmData type="plan" scope="all" name="SCF_Template" id="SCF_conf">
...       <header>
...         <log dateTime="2020-02-13T09:44:55.000+08:00" action="created" appInfo="ActualExporter">InternalValues are used</log>
...       </header>
...       <managedObject class="com.nokia.srbts.eqm:RMOD" version="MNL5GC19B_1911_003"
...    distName="PLMN-PLMN/MRBTS-xxxx/EQM-1/APEQM-1/RMOD-1" operation="update">
...       </managedObject>
...     </cmData>
...   </raml>

*** Keywords ***
5GC001250_Common Suite Setup for COAM
#    CI_interface.Common Suite Setup
    Set Suite Variable    ${TS_LOG_PATH_BASE}    ${tmp_log_dir}
    5GC001250_COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}
    Create directory    ${epc_log_path}
    Admin Get MrbtsId And NrbtsId

5GC001250_Common Suite Teardown for COAM
    Run Keyword And Ignore Error    AdminCli disconnection and Test teardown

5GC001250_Generate suite log path
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    Connect to DU via ssl
    ${sw_version} =     coam.get_sw_version    connection=${connection}
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}

5GC001250_COAM Create log directory
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    5GC001250_Generate suite log path    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

Connect to DU via ssl
    [Arguments]  ${connection}=${connection}    ${bts_host}=${DU_OAM_IP}
    ...    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

Precondition: All cells can be on air
    log to console  \n***** Precondition: All cells can be on air *****
    Check If BTS Is OnAir

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    cli.teardown    connection=${connection}

Admin Get MrbtsId And NrbtsId
    run keyword and ignore error    cli.Teardown
    cli.get_current_scf_file    local_dir_path=${epc_log_path}    file_name=${scf_name}    connection=${connection}
    ${commission_file}    set variable    ${epc_log_path}/${scf_name}
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${commission_file}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${commission_file}
    ${BTS_NAME}   lib.Get_BTS_name    scf_path=${commission_file}
    Set Suite Variable     ${mrbtsId}
    Set Suite Variable     ${nrbtsId}
    Set Suite Variable     ${dist_name}    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Set Suite Variable     ${commission_file}
    Set Suite Variable     ${BTS_NAME}

Check If BTS Is OnAir
    ${bts_statuses_response}=    cli.Get Bts Info    connection=${connection}
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=OnAir

Connect to cOAM as toor4nsn
    [Arguments]  ${ip_address}=${ADMIN_IP_Address}  ${alias}=${connection}  ${password}=${ROOT_PASSWORD}
    ${connection}=  ssh.Connect to  hostname=${ip_address}
    ...                             username=${ROOT_USERNAME}
    ...                             password=${password}
    ...                             alias=${connection}
    [Return]  ${connection}

Connect to cOAM as serviceuser
    [Arguments]  ${ip_address}=${ADMIN_IP_Address}  ${alias}=${connection}  ${password}=${SERVICEUSER_PASSWORD}
    ${connection}=  ssh.Connect to  hostname=${ip_address}
    ...                             username=${SERVICEUSER_USERNAME}
    ...                             password=${password}
    ...                             alias=${connection}
    [Return]  ${connection}

Disconnect from cOAM
    [Arguments]  ${connection}=${connection}
    ssh.disconnect  connection=${connection}

Change ${parameter_name} parameter value to ${value} in ${SECADM_or_FEATCADM} on connection
     cli.perform_parameter_recommissioning         dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/${SECADM_or_FEATCADM}-1
     ...                                           parameter=${parameter_name}
     ...                                           operation=update
     ...                                           value=${value}
     ...                                           skip_parameter_relation_errors=${True}
     ...                                           should_activate=${True}
     ...                                           connection=${connection}

Send private SSH key ${ssh_filepaths} onto BTS to ${user} profile
    send private key to             ip_address=${ADMIN_IP_Address}
    ...                             username=${user}
    ...                             password=${serviceuser_password}
    ...                             keypath=${ssh_filepaths}
    log to console  \nSSH key sent to ${user}.

Add ${num} public keys for ${user} to BTS and send private key with name ${name}
        @{payload_list}    create list
        @{ssh_filepaths_list}   create list
        FOR    ${i}    IN RANGE    ${num}
               ${ssh_filepaths}=      create_ssh_keypair_for  ${name}${i}
               append to list   ${ssh_filepaths_list}   ${ssh_filepaths}
               ${public_key}=    get_public_ssh_key_content    ${ssh_filepaths}
               ${payload}=    create dictionary   keyValue=${public_key}   keyDescription=#${name}${i}
               append to list   ${payload_list}   ${payload}
               ${private_key_paths}=    set variable     ${ssh_filepaths[0]}
               Send private SSH key ${private_key_paths} onto BTS to serviceuser profile
        END
        set global variable   ${ssh_filepaths_list}
        set global variable   ${payload_list}
        ${dict}=    create dictionary               parameterName=${user}
        ...                                         operation=update
        ...                                         value=@{payload_list}

        @{parameter_list}   create list    ${dict}
        cli.perform_object_recommissioning          dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SECADM-1
        ...                                         parameter=@{parameter_list}
        ...                                         operation=update
        ...                                         skip_parameter_relation_errors=${True}
        ...                                         should_activate=${True}
        ...                                         connection=${connection}

Delete the ${i}th SSH key credentials for ${user}
        @{parameter_list}   create list    ${payload_list[${i}]}
        cli.perform_parameter_recommissioning       dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SECADM-1
        ...                                         parameter=${user}
        ...                                         operation=delete
        ...                                         value=@{parameter_list}
        ...                                         skip_parameter_relation_errors=${True}
        ...                                         should_activate=${True}
        ...                                         connection=${connection}

Delete SSH keys from OAM serviceuser
    Connect to cOAM as serviceuser
    ssh.execute     command=chmod 777 *.key  connection=${connection}
    ssh.execute     command=rm *.key         connection=${connection}
    log to console  \nDeleted SSH keys from OAM serviceuser.

Delete SSH keys of abbreviation
    [Arguments]  ${abbreviation}
    cli.perform_parameter_recommissioning       dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SECADM-1
    ...                                         parameter=${abbreviation}
    ...                                         operation=delete
    ...                                         value=${False}
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}
    ...                                         connection=${connection}

Change parameters on BTS for teardown
    Change keyContinuation parameter value to false in SECADM on connection
    Change systemAcctPermEnable parameter value to false in FEATCADM on connection

Generate Netact plan file for systemAcctPermEnable
    [Arguments]      ${new_plan_file}    ${Value}    ${Version}

        ${mo_xpath}=    set variable  //managedObject[@distName="PLMN-PLMN/MRBTS-xxxx/MNL-1/MNLENT-1/FEATCADM-1"]

         ${root}=        myxml.Parse XML    ${Template_SCF}
         myxml.Set Element Attribute   ${root}  name=version      value=${Version}   xpath=${mo_xpath}
         myxml.Set Element Attribute   ${root}  name=distName  value=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1    xpath=${mo_xpath}
         myxml.Remove Elements         ${root}  xpath=//p
         myxml.Add Element	           ${root}   <p name="systemAcctPermEnable">${Value}</p>
         ...                                     xpath=//managedObject[@distName="PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1"]
         Save XML  ${root}  ${epc_log_path}/${new_plan_file}

Case Setup
    Log To Console    \n *** Case Setup
    Connect to DU via ssl
    Precondition: All cells can be on air

Connect to Netact
     netact_cm.connect_to    hostname=${NetAct_dmgr}
     ...                     username=${NETACT_USERNAME}
     ...                     password=${NETACT_PASSWORD}

Disconnect from Netact
    [Timeout]           30 seconds
     netact_cm.disconnect

Netact CM Upload
    [Timeout]  3 minutes
    netact_cm.upload    bts_dist_name=MRBTS-${mrbts_id}

Netact CM Import
    [Timeout]  3 minutes
    netact_cm.import_plan    path_to_file=${epc_log_path}/SCF_${mrbts_id}.xml     planname=SCF_${mrbts_id}

Netact Provision Plan
    [Timeout]  3 minutes
    netact_cm.provision    plan_name=SCF_${mrbts_id}


Netact Remove Plan
    [Timeout]  3 minutes
    netact_cm.remove_plan    plan_name=SCF_${mrbts_id}

Admin Get MO Version
    [Arguments]   ${dist_name}
    scf.load_scf    file_path=${epc_log_path}/current_scf.xml
    ${version}   scf.get_mo_attribute    dist_name=${dist_name}   attribute=version
    [Return]     ${version}

#*************************5GC001250-KA_5GC000270_001********************************
SSH to gNB with toor4nsn by password while systemAcctPerm is false
    log to console    \n *** SSH to gNB with toor4nsn by password while systemAcctPerm is false
    Change systemAcctPermEnable parameter value to false in FEATCADM on connection
    Connect to cOAM as toor4nsn
    Disconnect from cOAM    connection=${connection}

SSH to gNB with toor4nsn by password while systemAcctPerm is true
       log to console   \n *** Step2: SSH to gNB with toor4nsn by password while systemAcctPerm is true
       Change systemAcctPermEnable parameter value to true in FEATCADM on connection
       Run keyword and expect error   ConnectFailedError: authentication failed*   Connect to cOAM as toor4nsn

SSH to gNB with serviceuser by password and verify the accesss permission is non-root
       log to console  \n *** SSH to gNB with serviceuser by password and verify the accesss permission is non-root
       ${connection}=    Connect to cOAM as serviceuser
       ${answer}=   ssh.execute  id -u
       ...          connection=${connection}
       Check If Permission Is Non Root    answer=${answer}

SSH to toor4nsn with SSH root key via local host's loopback IP address and verify the access permission is root
       log to console  \n *** SSH to toor4nsn with SSH root key
       ${connection}=   ssh.connect to
       ...              hostname=localhost
       ...              username=toor4nsn
       ...              key_path=${ssh_filepaths_list[0]}
       ...              alias=coam_toor
       ...              proxy=${connection}
       ${answer}=   ssh.execute  fdisk -l
       ...          connection=${connection}
       check_if_system_control_possible    answer=${answer}
       Disconnect from cOAM

Preapare for Case2
      log to console   \n *** Preapare for Case2
      Add 1 public keys for rootUserPublicKeys to BTS and send private key with name toor4nsn
      Change actServiceAccountSsh parameter value to true in SECADM on connection
      Change keyContinuation parameter value to false in SECADM on connection
      Change ethernetPortSecurityEnabled parameter value to false in SECADM on connection

Test Teardown for case1
      Delete SSH keys from OAM serviceuser
      Delete SSH keys of abbreviation  abbreviation=serviceUserPublicKeys
      Delete SSH keys of abbreviation  abbreviation=rootUserPublicKeys
      Change parameters on BTS for teardown
      delete ssh files locally  private_path=${ssh_filepaths_list[0][0]}    public_path=${ssh_filepaths_list[0][1]}
      CI_interface.Common Case Teardown

#*************************5GC001250-KA_5GC000270_002********************************
SSH to gNB with serviceuser by key credentials and verify the accesss permission is non-root
      log to console  SSH to gNB with serviceuser by key credentials and verify the accesss permission is non-root
      ${connection}=   ssh.connect to
      ...              hostname=${DU_OAM_IP}
      ...              username=serviceuser
      ...              key_path=${ssh_filepaths_list[0]}
      ...              alias=${connection}
      ${answer}=   ssh.execute  id -u
      ...          connection=${connection}
      Check If Permission Is Non Root    answer=${answer}

SSH to toor4nsn with SSH serviceuser key via local host's loopback IP address and verify the access permission is root
      log to console  SSH to toor4nsn with SSH serviceuser key via local host's loopback IP address and verify the access permission is root
      ${connection}=   ssh.connect to
      ...              hostname=localhost
      ...              username=toor4nsn
      ...              key_path=${ssh_filepaths_list[0]}
      ...              alias=coam_toor
      ...              proxy=${connection}
      ${answer}=   ssh.execute  fdisk -l
      ...          connection=${connection}
      check_if_system_control_possible    answer=${answer}
      Disconnect from cOAM

#*************************5GC001250-KA_5GC000270_003********************************
Case Setup for case3
      Connect to Netact
      Netact CM Upload via ssh
      ${version}  Admin Get MO Version   dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1
      set global variable    ${version}
      Add 1 public keys for rootUserPublicKeys to BTS and send private key with name toor4nsn
      Change actServiceAccountSsh parameter value to true in SECADM on connection
      Change keyContinuation parameter value to false in SECADM on connection
      Change ethernetPortSecurityEnabled parameter value to false in SECADM on connection

SSH to gNB with toor4nsn by password while systemAcctPerm is false for case3
    log to console    SSH to gNB with toor4nsn by password while systemAcctPerm is false
    Generate Netact plan file for systemAcctPermEnable    new_plan_file=SCF_${mrbtsId}.xml   Value=0   Version=${version}
    Netact CM Import
    Netact Provision Plan
    Connect to cOAM as toor4nsn
    Disconnect from cOAM    ${connection}

SSH to gNB with toor4nsn by password while systemAcctPerm is true for case3
       log to console   SSH to gNB with toor4nsn by password while systemAcctPerm is true
       Generate Netact plan file for systemAcctPermEnable    new_plan_file=SCF_${mrbtsId}.xml   Value=1   Version=${version}
       Netact Remove Plan
       Netact CM Import
       Netact Provision Plan
       Run keyword and expect error   ConnectFailedError: authentication failed*   Connect to cOAM as toor4nsn

Test Teardown for case3
      Delete SSH keys from OAM serviceuser
      Delete SSH keys of abbreviation  abbreviation=serviceUserPublicKeys
      Delete SSH keys of abbreviation  abbreviation=rootUserPublicKeys
      Change parameters on BTS for teardown
      run keyword and ignore error     delete ssh files locally  private_path=${ssh_filepaths_list[0][0]}    public_path=${ssh_filepaths_list[0][1]}
      run keyword and ignore error  Netact Remove Plan
      Disconnect from Netact
      CI_interface.Common Case Teardown

Netact CM Upload via ssh
    [Timeout]  3 minutes
    ${stdout}=     ssh.execute     command=racclimx.sh -op Upload -DN PLMN-PLMN/MRBTS-${mrbts_id} -v  timeout=120    connection=netact_cm
    Should Contain Any  ${stdout}   The operation was successfully completed.:Upload is Successful

#*************************5GC001250-KA_5GC000270_006********************************
Add 10 ssh public key for serviceuser to BTS
       log to console  Add 10 ssh public key for serviceuser to BTS
       Add 10 public keys for serviceUserPublicKeys to BTS and send private key with name serviceuser

SSH to gNB via serviceuser account and next to toor4nsn with any one of the SSH key
       log to console  SSH to gNB via serviceuser account and next to toor4nsn with removed SSH Key any one of the SSH key
       ${int}    evaluate  random.randrange(10)   modules=random
       ssh.connect to
       ...              hostname=${DU_OAM_IP}
       ...              username=serviceuser
       ...              key_path=${ssh_filepaths_list[${int}]}
       ...              alias=${connection}
       ssh.connect to
       ...              hostname=localhost
       ...              username=toor4nsn
       ...              key_path=${ssh_filepaths_list[${int}]}
       ...              alias=coam_toor
       ...              proxy=${connection}
       Disconnect from cOAM

SSH to gNB via serviceuser account and next to toor4nsn with removed SSH Key
       log to console  SSH to gNB via serviceuser account and next to toor4nsn with removed SSH Key
       ${int}    evaluate  random.randrange(10)   modules=random
       log list  ${payload_list[${int}]}
       Delete the ${int}th SSH key credentials for serviceUserPublicKeys
       ssh.reset_cache
       Connect to cOAM as serviceuser
       run keyword and expect error  *    ssh.connect to
       ...              hostname=localhost
       ...              username=toor4nsn
       ...              key_path=${ssh_filepaths_list[${int}]}
       ...              alias=coam_toor
       ...              proxy=${connection}

Case Setup for case6
      Change actServiceAccountSsh parameter value to true in SECADM on connection
      Change keyContinuation parameter value to true in SECADM on connection
      Change ethernetPortSecurityEnabled parameter value to false in SECADM on connection

Test Teardown for case6
      Delete SSH keys from OAM serviceuser
      Delete SSH keys of abbreviation  abbreviation=serviceUserPublicKeys
      Delete SSH keys of abbreviation  abbreviation=rootUserPublicKeys
      Change parameters on BTS for teardown
      FOR    ${i}    IN RANGE    10
          delete ssh files locally  private_path=${ssh_filepaths_list[${i}][0]}    public_path=${ssh_filepaths_list[${i}][1]}
      END
      CI_interface.Common Case Teardown

#*************************5GC001250-NA_5GC000325_004********************************
Case Setup for case4
    Log    \n Enable security functions    console=yes
    Change actServiceAccountSsh parameter value to true in SECADM on connection
    Change actServicePortState parameter value to true in SECADM on connection
    Change sshClientAliveTimer parameter value to 1 in SECADM on connection

SSH to gNB with toor4nsn by password and check ssh config file
    Log    \n SSH to gNB with toor4nsn by password    console=yes
   Change systemAcctPermEnable parameter value to false in FEATCADM on connection
   ${get_managed_objects}    cli.get_managed_objects    class_name=SECADM_A    connection=${connection}
   ${sshClientAliveTimer}    cli.get_parameters    dist_name=${get_managed_objects[0]['distName']}
   ...          pattern=sshClientAliveTimer    connection=${connection}

   ${sshClientAliveTimer} =    Convert To Integer    ${sshClientAliveTimer['sshClientAliveTimer']}
   Connect to cOAM as toor4nsn
   csn.send command    command=cat /etc/ssh/sshd_config | grep -i ClientAliveCountMax | awk '{print $2}'
   ...          connection=${connection}
   ${ClientAliveCountMax}    csn.Read Output    connection=${connection}
   ${ClientAliveCountMax} =    Convert To Integer    ${ClientAliveCountMax}
   csn.send command    command=cat /etc/ssh/sshd_config | grep -i ClientAliveInterval| awk '{print $2}'
   ...          connection=${connection}
   ${ClientAliveInterval}    csn.Read Output    connection=${connection}
   ${ClientAliveInterval} =    Convert To Integer    ${ClientAliveInterval}
   should be true   ${sshClientAliveTimer}*60==int(${ClientAliveInterval})*int(${ClientAliveCountMax})

Case Teardown for case4
    Change sshClientAliveTimer parameter value to 45 in SECADM on connection
    CI_interface.Common Case Teardown

#*************************5GC001250-QA_5GC000372_001********************************
Check operational state of ASOD and RMOD
    Log To Console    Check operational state of ASOD and RMOD    console=yes
    Connect to DU via ssl
    ${get_fsm_info}    coam.get_fsm_info    connection=${connection}
    Should Contain   ${get_fsm_info[0]['status']['availabilityStatus']}   Online
    ${get_frm}    coam.get_frm    connection=${connection}
    Should Contain   ${get_frm[0]['status']['availabilityStatus']}    Online

Reset RU and check result
    Log To Console    Reset RU and check result
    DU RU Reset
    Wait until keyword succeeds    30 min     30 s    Check If BTS Is OnAir
    ${get_frm}    coam.get_frm    connection=${connection}
    Should Contain   ${get_frm[0]['status']['availabilityStatus']}    Online

Reset site and check result
    Log To Console    Reset site and check result
    ${reset_site}    coam.reset_site    connection=${connection}
    Wait until keyword succeeds    30 min     20 s    Check If BTS Is OnAir

Repeat test for case1
    Log To Console    Repeat test
    Reset RU and check result
    Reset site and check result

DU RU Reset
    log to console      DU RU Reset
    selenium_coam.enable_virtual_display
    selenium_coam.login               url=https://${DU_OAM_IP}
    ...                    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    selenium_coam.disable_screen_lock
    selenium_coam.reset_ru
    [Teardown]          selenium_coam.logout

case teardown
    AdminCli disconnection and Test teardown
    CI_interface.Common Case Teardown

#*************************5GC001250-QA_5GC000372_002********************************
Get Parameters from DU WebEM
    Log To Console    Get Parameters from DU WebEM
    ${get_managed_objects}    coam.get_managed_objects    class_name=MRBTS_A    connection=${connection}
    ${btsname_info}    coam.get_parameters    dist_name=${get_managed_objects[0]['distName']}
    ...    pattern=btsName    connection=${connection}
    set suite variable    ${bts_default_name}    ${btsname_info['btsName']}
    set suite variable    ${bts_modify_name}    new_${bts_default_name}
    Log To Console    ${bts_default_name}
    Log To Console    ${bts_modify_name}

Modify Parameters from DU WebEM
    Log To Console    Modify Parameters from DU WebEM
    ${get_managed_objects}    coam.get_managed_objects    class_name=MRBTS_A    connection=${connection}
    ${btsname_current}    coam.get_parameters    dist_name=${get_managed_objects[0]['distName']}
    ...    pattern=btsName    connection=${connection}
    run keyword if    "${bts_default_name}" != "${btsname_current['btsName']}"     Modify BTSname
    ...    ELSE    Modify BTSname    btsname=${bts_modify_name}
    [Teardown]    Run Keyword And Ignore Error    Modify BTSname

repeat test for case2
    Log To Console    repeat test
    Modify Parameters from DU WebEM

Modify BTSname
    [Arguments]   ${btsname}=${bts_default_name}
    COAM Update Parameter    dist_name=MRBTS-${mrbts_id}    parameter=btsName    value=${btsname}
    sleep    5s

COAM Update Parameter
    [Arguments]   ${dist_name}   ${parameter}   ${value}   ${connection}=${connection}
    coam.perform_parameter_recommissioning   dist_name=${dist_name}   parameter=${parameter}   value=${value}
    ...   operation=update
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=60
    ...   connection=${connection}

#*************************5GC001250-QA_5GC000372_005********************************
Invalid_Credential_Verify_on_DU_WebEM
    Log To Console    Invalid_Credential_Verify_on_DU_WebEM
    ${pwd}    evaluate    ''.join(random.sample('abcdefghijklmnopqrstuvwxyz',8))    random
    ${Status}=    Run Keyword And Return Status    cli.connect to   bts_host=${DU_OAM_IP}
    ...      username=${WEBUI_USER}
    ...      password=${pwd}
    ...      name=Invalid
    should be true    ${Status}==False

#*************************5GC001250-QA_5GC000372_006********************************
Idle_Timeout_Verify_on_DU_WebEM
    Log To Console    Idle_Timeout_Verify_on_DU_WebEM
    wait until keyword succeeds    2min    30s    siso_resource.WEBUI Login
    ${lock_screen_time}    selenium_coam.get_lock_screen_time
    run keyword if    "${lock_screen_time}" == "${15}"     selenium_coam.set_lock_screen_time    lock_time=${2}
    sleep    30s
    #selenium_coam.login_after_screen_lock    passwd=${WEBUI_PASSWORD}
    [Teardown]    Run Keyword And Ignore Error    selenium_coam.set_lock_screen_time    lock_time=${15}

#*************************5GC002236-BA-002-004*******************************
Check Active Alarms in DU
    log to console      Check Active Alarms in DU
    Connect to DU via ssl
    Get Active Alarms

Get Active Alarms
    @{alarm_list_details}    cli.get_active_alarms    connection=${connection}
    ${act_alarm_length}    cli.get_active_alarms_number    connection=${connection}
    @{act_alarm_ID_list}    Create List
    FOR    ${alarm}    IN    @{alarm_list_details}
        Append To List    ${act_alarm_ID_list}    ${alarm["alarmId"]}
    END
    set suite variable    @{act_alarm_ID_list}
    set suite variable    ${act_alarm_length}

RMOD Reset Via NMS
    log to console    RMOD Reset Via NMS
    NetAct RMOD Reset

Check RU STATUS during Reseting
    log to console      Check RU STATUS during Reseting
	selenium_coam.enable_virtual_display
    selenium_coam.login               url=https://${DU_OAM_IP}
    ...                    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ${output_tmp}    selenium_coam.get_ru_info
    ${RU_info}    set variable    ${output_tmp}[Status]
    should match regexp    ${RU_info}[Operational state]    Disabled
    should match regexp    ${RU_info}[Availability status]    NotInstalled
    should match regexp    ${RU_info}[Administrative state]    Unlocked
    should match regexp    ${RU_info}[Procedural status]    not initialized
    [Teardown]          selenium_coam.logout

Test Setup
      Log To Console    \n *** Test Setup
      run keyword and ignore error  Delete HWRESETREQ Object
      run keyword and ignore error  Delete CMD Object
      Connect to Netact
      Netact CM Upload via ssh
      ${version}  Admin Get MO Version   dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1
      set global variable    ${version}

Test Teardown
      run keyword and ignore error  Netact Remove Plan
      Disconnect from Netact
      AdminCli disconnection and Test teardown
      run keyword and ignore error  Delete HWRESETREQ Object
      run keyword and ignore error  Delete CMD Object
	  CI_interface.Common Case Teardown

Delete HWRESETREQ Object
    @{empty_list}   Create List
    cli.perform_object_recommissioning
    ...    dist_name=MRBTS-${mrbtsId}/MNL-1/CMD-1/HWRESETREQ-1111
    ...    parameter=${empty_list}
    ...    should_activate=${True}
    ...    operation=delete
    ...    skip_parameter_relation_errors=${True}
    ...    connection=${connection}

Delete CMD Object
    @{empty_list}   Create List
    cli.perform_object_recommissioning
    ...    dist_name=MRBTS-${mrbtsId}/MNL-1/CMD-1
    ...    parameter=${empty_list}
    ...    should_activate=${True}
    ...    operation=delete
    ...    skip_parameter_relation_errors=${True}
    ...    connection=${connection}

NetAct Lock RU
    log to console    Lock RU via NetAct
    Generate Netact plan file for RMOD Lock Unlock    new_plan_file=SCF_${mrbtsId}.xml   Value=0   Version=${version}
    run keyword and ignore error  Netact Remove Plan
    Netact CM Import
    Netact Provision Plan

NetAct Unlock RU
    log to console    Unlock RU via NetAct
    Generate Netact plan file for RMOD Lock Unlock    new_plan_file=SCF_${mrbtsId}.xml   Value=2   Version=${version}
    run keyword and ignore error  Netact Remove Plan
    Netact CM Import
    Netact Provision Plan

NetAct RMOD Reset
    log to console    Reset RMOD via NetAct
    Generate Netact plan file for RMOD Reset    new_plan_file=SCF_${mrbtsId}.xml   Version=${version}
    run keyword and ignore error  Netact Remove Plan
    Netact CM Import
    Netact Provision Plan

Generate Netact plan file for RMOD Lock Unlock
    [Arguments]      ${new_plan_file}    ${Value}    ${Version}

        ${mo_xpath}=    set variable  //managedObject[@distName="PLMN-PLMN/MRBTS-xxxx/EQM-1/APEQM-1/RMOD-1"]

         ${root}=        myxml.Parse XML    ${Template_SCF_RMOD_Lock}
         myxml.Set Element Attribute   ${root}  name=version      value=${Version}   xpath=${mo_xpath}
         myxml.Set Element Attribute   ${root}  name=distName  value=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1    xpath=${mo_xpath}
         myxml.Add Element	           ${root}   <p name="administrativeState">${Value}</p>
         ...                                     xpath=//managedObject[@distName="PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1"]
         Save XML  ${root}  ${epc_log_path}/${new_plan_file}

Generate Netact plan file for RMOD Reset
    [Arguments]      ${new_plan_file}    ${Version}

         ${mo_xpath}=    set variable  //managedObject[@distName="PLMN-PLMN/MRBTS-xxxx/MNL-1/CMD-1"]
         ${root}=        myxml.Parse XML    ${Template_SCF}
         myxml.Set Element Attribute   ${root}  name=version      value=${Version}   xpath=${mo_xpath}
         myxml.Set Element Attribute   ${root}  name=distName  value=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/CMD-1    xpath=${mo_xpath}

         ${sub_mo_xpath}=    set variable  //managedObject[@distName="PLMN-PLMN/MRBTS-xxxx/MNL-1/CMD-1/HWRESETREQ-1111"]
         myxml.Set Element Attribute   ${root}  name=version      value=${Version}   xpath=${sub_mo_xpath}
         myxml.Set Element Attribute   ${root}  name=distName  value=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/CMD-1/HWRESETREQ-1111    xpath=${sub_mo_xpath}
         myxml.Add Element	           ${root}   <p name="targetHwResetUDN">MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1</p>
         ...                                     xpath=//managedObject[@distName="PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/CMD-1/HWRESETREQ-1111"]
         myxml.Save XML  ${root}  ${epc_log_path}/${new_plan_file}

RMOD Lock
    log to console      RMOD Lock
    NetAct Lock RU
    Wait Until Keyword Succeeds   1min    10s    Check RU STATUS after lock

RMOD Unlock
    log to console      RMOD Unlock
    NetAct Unlock RU
    Connect to DU via ssl
    Wait Until Keyword Succeeds   15min    3min    Check If BTS Is OnAir
    Check Active Alarms in DU

Check RU STATUS after lock
    log to console      Check RU STATUS after lock
    selenium_coam.enable_virtual_display
    siso_resource.WEBUI Login
    ${output_tmp}    selenium_coam.get_ru_info
    ${RU_info}    set variable    ${output_tmp}[Status]
    should match regexp    ${RU_info}[Operational state]    Enabled
    should match regexp    ${RU_info}[Availability status]    Online
    should match regexp    ${RU_info}[Administrative state]    Locked
    should match regexp    ${RU_info}[Procedural status]    configured
    [Teardown]          selenium_coam.logout

Unlock RU
    log to console      Unlock RU
    selenium_coam.enable_virtual_display
    siso_resource.WEBUI Login
    selenium_coam.disable_screen_lock
    selenium_coam.unlock_ru    type_=RMOD_R  ru_index=1
     [Teardown]       cli.teardown    connection=DU_OAM
