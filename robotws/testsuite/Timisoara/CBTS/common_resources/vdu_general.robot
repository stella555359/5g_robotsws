*** Settings ***
Documentation  This suite contains vDU KWs used in TCs

Resource  cbts_general.robot


*** Keywords ***
Verify RMODs Parameter From VDU
    [Documentation]  This keyword is used to verify certain parameter value for all vDU RMODs.
    ...  Given arguments are:
    ...  ${given_parameter} - which can be operational_state, availability_status and administrative_state.
    ...  ${parameter_value} - can be: Enabled/Disabled, Online/Degraded/Failed/Offline/Not installed/Other and Unlocked/Locked.
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com
    [Arguments]  ${given_parameter}  ${parameter_value}

    ${rmods_status}  vdu.Get Rmods Status
    Should Not Be Empty  ${rmods_status}
    FOR  ${status}  IN  @{rmods_status}
        ${status}  Run Keyword And Return Status  Should Contain  ${parameter_value}  ${status}[${given_parameter}]
        IF  ${status}  RETURN
    END
    Fail  No RMODs with ${given_parameter} ${parameter_value} found.

Check All Cells From VDU
    [Documentation]  This keyword is used to check the given parameters for all vDU cells.
    ...  Given argument is:
    ...  &{parameters} - which is a dictionary and can be for example: administrative_state=Unlocked  operational_state=Enabled
    ...  An example for using this KW: Check all cells from vDU  administrative_state=Unlocked  operational_state=Enabled
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    [Arguments]  &{parameters}

    ${cells_status}  vdu.Get Vdu Cells Status
    Should Not Be Empty  ${cells_status}
    FOR  ${cell_status}  IN  @{cells_status}
        Verify Parameters For Cell From VDU  ${cell_status}  ${parameters}
    END


Check The Specific Cell From VDU
    [Documentation]  This keyword is used to check the given parameters for one specific cell from vDU.
    ...  Given arguments are:
    ...  ${cell_id} - this is the id of the cell to be checked.
    ...  &{parameters} - which is a dictionary with all the parameters that will be checked.
    ...  An example for using this KW: Check the specific cell from vDU  administrative_state=Unlocked  operational_state=Enabled
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    [Arguments]  ${cell_id}  &{parameters}

    ${cells_status}  vdu.Get Vdu Cells Status
    FOR  ${cell_status}  IN  @{cells_status}
        Run Keyword If  ${cell_status}[id] == ${cell_id}
        ...  Verify Parameters For Cell From VDU  ${cell_status}  ${parameters}
        ...  ELSE
        ...  Continue For Loop
    END


Verify Parameters For Cell From VDU
    [Documentation]  This keyword is used to verify the value of the given parameters.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    [Arguments]  ${cell_status}  ${parameters}

    FOR  ${parameter}  IN  @{parameters}
        Should Contain  ${parameters}[${parameter}]  ${cell_status}[${parameter}]
    END


Change Specific Parameter For VDU
    [Documentation]  This keyword is used to change a specific parameter from vDU.
    ...  Given arguments are:
    ...  ${parameter_name} - which can be actCli for example.
    ...  ${parameter_value} - can be: true for example
    ...  ${distname_of_parameter_obj} - which is the parameter distname from Configuration Management.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    [Arguments]  ${parameter_name}  ${parameter_value}  ${distname_of_parameter_obj}

    Log  Change vDU ${parameter_name} parameter to be ${parameter_value}  console=true
    ${parameter}  Create Dictionary  parameterName=${parameter_name}  value=${parameter_value}  operation=update
    ${parameter_change_list}  Create List  ${parameter}
    ${changed_parameter}  Create Dictionary  distName=${distname_of_parameter_obj}  operation=update  parameters=${parameter_change_list}
    ${changed_parameter_list}  Create List  ${changed_parameter}
    ${changed_parameter_string}  Evaluate  json.dumps(${changed_parameter_list})  json
    vdu.Perform Delta Recommissioning  ${changed_parameter_string}


Open SSH Connection To VDU And Connect To Openshift
    [Documentation]
    ...  This keyword opens connection to vDU and Openshift.
    ...  ${VDU_SSH_IP}, ${VDU_SSH_USERNAME} and ${VDU_SSH_PASSWORD} are set in vdu_frame.robot resource.
    ...  *AUTHOR*: anna.benzar@nokia.com

    SSHLibrary.Open Connection  ${VDU_SSH_IP}  prompt=$  timeout=20s
    SSHLibrary.Login  ${VDU_SSH_USERNAME}  ${VDU_SSH_PASSWORD}
    SSHLibrary.Write  oc login -u nokiaadmin -p nokiaadmin
    ${oc_login_output}  SSHLibrary.Read Until Prompt
    ${oc_login_status}  Run Keyword And Return Status
    ...  Should Contain  ${oc_login_output}  Login successful
    SSHLibrary.Write  bind 'set enable-bracketed-paste off'  #This is here to remove [?2004l and [?2004h from output. Should not have other impact.
    SSHLibrary.Read Until Prompt
    Run Keyword If  ${oc_login_status} == ${FALSE}
    ...  Fail  Connection to Openshift failed. [NOK]


Get Time from vDU POD
    [Documentation]  KW used to retrive time from vDU pod.
    [Arguments]  ${pod}=oamfm  ${time_format}=%Y-%m-%dT%H:%M:%S%:z

    ssh.Connect To  ${VDU_SSH_IP}  ${VDU_SSH_USERNAME}  ${VDU_SSH_PASSWORD}  alias=get_vdu_time
    ssh.Execute  bind 'set enable-bracketed-paste off'  connection=get_vdu_time
    ssh.Execute  oc login -u nokiaadmin -p nokiaadmin  connection=get_vdu_time
    ${all_pods}  ssh.Execute  oc get pods -n ${VDU_CRAN}  connection=get_vdu_time
    ${pod_line}  Get Lines Containing String  ${all_pods}  ${pod}
    ${pod}  Fetch From Left  ${pod_line}  ${SPACE}
    ${date}  ssh.Execute  oc exec ${pod} -n ${VDU_CRAN} -- date "+${time_format}"  connection=get_vdu_time
    ${time}  Fetch From Left  ${date}  [
    ${time}  Remove String  ${time}  \r\n

    RETURN  ${time}
    [Teardown]  ssh.Disconnect  connection=get_vdu_time


Open SSH Connectin To OAMFH Pod
    [Documentation]
    ...  This keyword opens connection to RMOD pod.
    ...  "Get Full Name For Pod" and "Get Full Name For Container" are used to retrieve pod and container names specific to RMODs.
    ...  oc command is used to connect to the RMOD dedicated pod.
    ...  *AUTHOR*: anna.benzar@nokia.com

    Open SSH Connection To VDU And Connect To Openshift
    ${pod}  Get Full Name For Pod  ${VDU_CRAN}  oamfh
    ${container}  Get Full Name For Container  ${VDU_CRAN}  oamfh
    SSHLibrary.Write  oc exec -it ${pod} -n cran1 -c ${container} -- bash
    ${pod_connection_output}  SSHLibrary.Read Until Prompt
    ${pod_connection_status}  Run Keyword And Return Status  Should Contain  ${pod_connection_output}  bash-5.2$
    IF  ${pod_connection_status} == ${FALSE}  Fail  Connection to RMOD pod failed. [NOK]


Open SSH Connection To ECPRI RMOD
    [Documentation]
    ...  This keyword opens ssh connection to RMOD from pod.
    ...  Given arguments: ${rmod_ip}
    ...  *AUTHOR*: anna.benzar@nokia.com
    [Arguments]  ${rmod_ip}  ${rmod_username}  ${rmod_password}  ${prompt_on_rmod}=REGEXP:(#|\\$)

    Open SSH Connectin To OAMFH Pod
    SSHLibrary.Write  ssh ${rmod_username}@${rmod_ip}
    SSHLibrary.Set Client Configuration  prompt=(yes/no/[fingerprint])?
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  yes
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(Password:|password:)
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ${rmod_password}
    SSHLibrary.Set Client Configuration  prompt=${prompt_on_rmod}  timeout=30s
    SSHLibrary.Read Until Prompt
    Log  Connection on RMOD with ip: ${rmod_ip}, successfully done. [OK]  console=true


Check If Fault Is Visible In VDU WebEM
    [Documentation]
    ...  This keyword checks if given alarm/fault information matches any active alarms in WebEM.
    ...  If given alarm is found, it's information is set as a test variable.
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${alarm_id}  ${alarm_name}  ${fault_id}  ${fault_name}  ${severity}

    ${active_alarms}  vdu.Vdu Get Active Alarms
    ${alarms_list}  Set Variable  ${active_alarms}[alarms]
    ${fault_id}  Convert To String  ${fault_id}
    FOR  ${alarm}  IN  @{alarms_list}
        ${status_alarm_id}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[alarm_id]  ${alarm_id}
        ${status_alarm_name}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[alarm_name]  ${alarm_name}
        ${status_fault_id}  Run Keyword And Return Status  Should Contain  ${fault_id}  ${alarm}[fault_id]
        ${status_fault_name}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[fault_name]  ${fault_name}
        ${status_severity}  Run Keyword And Return Status  Should Contain  ${severity}  ${alarm}[severity]
        IF  ${status_alarm_id} and ${status_alarm_name} and ${status_fault_id} and ${status_fault_name} and ${status_severity}
            Set Test Variable  ${ALARM_INFO}  ${alarm}
            Log  Alarm "${alarm_name}", with fault id: ${fault_id}, is visible in WebEM. [OK]  console=true
            RETURN
        END
    END
    Fail  Alarm "${alarm_name}", with fault id: ${fault_id}, not found in active alarms list. [NOK]


Check If Fault Is Cleared From VDU WebEM
    [Documentation]
    ...  This keyword checks if given alarm/fault information matches any active alarms in WebEM.
    ...  If alarm is still found active in WebEM, keyword fails.
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${alarm_id}  ${fault_id}

    ${active_alarms}  vdu.Vdu Get Active Alarms
    ${alarms_list}  Set Variable  ${active_alarms}[alarms]
    FOR  ${alarm}  IN  @{alarms_list}
        ${status_alarm_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[alarm_id]  ${alarm_id}
        ${status_fault_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[fault_id]  ${fault_id}
        Run Keyword If  ${status_alarm_id} and ${status_fault_id}
        ...  Fail  Alarm with fault id: ${fault_id} is still visible in WebEM. [NOK]
    END
    Log  Alarm with fault id: ${fault_id}, successfully cleared from WebEM. [OK]  console=true


Check All PODs On VDU To Be On Air And Verify Their Information
    [Documentation]
    ...  This keyword verifies pods on DU.
    ...  name, instance, availability_status, operational_state, role and ip_addresses are checked.
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com

    ${pods_informations}  Get Pods Info
    FOR  ${pod}  IN  @{pods_informations}
        Should Not Be Empty  ${pod}[name]  Pod name should be set. [NOK]
        Should Not Be Empty  ${pod}[instance]  Pod instance should be set. [NOK]
        Should Contain  ${ONLINE}  ${pod}[availability_status]  Pod "${pod}[name]" is not on line. [NOK]
        Should Contain  ${ENABLED}  ${pod}[operational_state]  Pod "${pod}[name]" is not enabled. [NOK]
        Log  Pod "${pod}[name]" with instance id: "${pod}[instance]" is Online and Enabled and has the role: Disabled.  console=true
        ${ip_addresses_status}  Run Keyword And Return Status
        ...  Should Not Be Empty  ${pod}[ip_interfaces]
        Run Keyword If  ${ip_addresses_status}
        ...  Run Keywords
        ...  Log  \tIP interfaces are:  console=true
        ...  AND
        ...  Log  \t\t$${pod}[ip_interfaces]  console=true
    END


Delete Planned Configurations On VDU
    [Documentation]
    ...  This keyword deletes all planned configurations created, that were not activated.
    ...  ${plans} can be obtained with "Get staged plans info list" keyword from taf.gnb.oam.coam.vdu
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com
    [Arguments]  ${plans}

    FOR  ${plan}  IN  @{plans}
        vdu.Delete Staged Plan File  ${plan}[plan_id]
    END


Change JwtExpirationTime Parameter To Desired Value On VDU
    [Documentation]
    ...  This keyword reconnects to vDU and changes jwtExpirationTime to given value.
    ...  ${value} can be given in seconds or minutes.
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com
    [Arguments]  ${value}

    Connect To VDU  host=${VDU_OAM_IP}
    Change Specific Parameter For VDU  jwtExpirationTime  ${value}  MRBTS-1/MNL-1/AMGR-1/LUAC-1


Get ECPRI RFSW Name
    [Documentation]
    ...  This keyword fetches RFSW name from SRM file.
    ...  ${srm_file} can be: SRM-rfsw-image-install-aeqb#1_0x20F172A5.tar
    ...  Returned value: e.g. 0x20F172A5
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${srm_file}

    ${srm_file}  Fetch From Right  ${srm_file}  _
    ${rf_sw_name}  Fetch From Left  ${srm_file}  .

    [Return]  ${rf_sw_name}


Verify RFSW From ECPRI RMOD To Be On Passive Partition
    [Documentation]
    ...  This keyword verifies if RFSW was downloaded on passive partition.
    ...  Example of use: Verify RFSW from eCPRI RMOD to be on passive partition  192.168.254.37  0x20F172A5
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rmod_ip}  ${rmod_username}  ${rmod_password}  ${rmod_sw_name}

    Open SSH Connection To ECPRI RMOD  ${rmod_ip}  ${rmod_username}  ${rmod_password}
    SSHLibrary.Write  sudo su root
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  SWmanShellCommand -i
    ${rfsw_connection}  SSHLibrary.Read Until Prompt
    Should Contain  ${rfsw_connection}  ${rmod_sw_name}\r\nusage:${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}0 - it's passive\r\nintegrity: Valid
    ...  ${rmod_sw_name} is not on passive partiton from ssh connection.[NOK]
    Log  RFSW is on passive partition from ssh connection on RMOD with ip: ${rmod_ip}![OK]  console=true
    SSHLibrary.Close Connection


Get ECPRI RMOD Ip By Serial Number
    [Documentation]
    ...  This keyword retrieves RMOD ip by it's given serial number.
    ...  Example of use: Get eCPRI RMOD ip by serial number  1M204422762
    ...                                                serviceuser
    ...                                                bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=
    ...                                                ['192,158,254,37','192.168.254.39']
    ...  ${all_rmods_ips} can be obtained with "Get all eCPRI RMODs ips from RMODs dedicated pod" keyword.
    ...  It is used with "Verify eCPRI RMOD serial number" keyword.
    ...  *AUTHOR*: anna.benzar@nokia.com
    [Arguments]  ${serial_number}  ${rmod_username}  ${rmod_password}  ${all_rmods_ips}  ${prompt_on_rmod}=REGEXP:(#|\\$)
    ...  ${file_on_RF_with_serial_number}=/mnt/factory/configs/unit/core_assembly_serial_number.txt

    FOR  ${rmod_ip}  IN  @{all_rmods_ips}
        Open SSH Connection To ECPRI RMOD  ${rmod_ip}  ${rmod_username}  ${rmod_password}  ${prompt_on_rmod}
        ${rmod_ip_status}  Run Keyword And Return Status
        ...  Verify ECPRI RMOD Serial Number  ${serial_number}  ${file_on_RF_with_serial_number}
        SSHLibrary.Close Connection
        Run Keyword If  ${rmod_ip_status}
        ...  Return From Keyword  ${rmod_ip}
    END
    Fail  No RMOD found with serial number: ${serial_number} on vDU. [NOK]


Verify ECPRI RMOD Serial Number
    [Documentation]
    ...  This keyword verifies serial number on RMOD.
    ...  SSH connection must be opened beforehand.
    ...  *AUTHOR*: anna.benzar@nokia.com
    [Arguments]  ${serial_number}  ${file_on_RF_with_serial_number}=/mnt/factory/configs/unit/core_assembly_serial_number.txt

    SSHLibrary.Write  cat ${file_on_RF_with_serial_number}
    ${command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${command_output}  ${serial_number}  Serial number from current RMOD doesn't match with given serial number. [NOK]


Get All ECPRI RMODs Ips From RMODs Dedicated Pod
    [Documentation]
    ...  This keyword connects on RMOD pod and retrieves all RMODs ips mapped on vDU.
    ...  *AUTHOR*: anna.benzar@nokia.com
    [Arguments]  ${rmod_username}

    ${rmod_ips}  Create List
    Log  Get all RMODs ips mapped on vDU.  console=true
    Open SSH Connectin To OAMFH Pod
    SSHLibrary.Write  arp -a
    ${arp_command_output}  SSHLibrary.Read Until Prompt
    ${rmod_ips_matches}  Get Regexp Matches  ${arp_command_output}  192.168.[0-9]+.[0-9]+
    FOR  ${rmod_ip}  IN  @{rmod_ips_matches}
        SSHLibrary.Write  ssh ${rmod_username}@${rmod_ip}
        SSHLibrary.Set Client Configuration  prompt=REGEXP:(#|\\$)
        ${prompt_status}  Run Keyword And Return Status
        ...  SSHLibrary.Read Until Prompt
        Run Keyword If  ${prompt_status}
        ...  Continue For Loop
        SSHLibrary.Write  no
        SSHLibrary.Read Until Prompt
        Append To List  ${rmod_ips}  ${rmod_ip}
    END
    SSHLibrary.Close Connection
    Log  RMODs ips on current vDU are: ${rmod_ips}  console=true

    [Return]  ${rmod_ips}


Verify RMOD Parameter By RMOD Id
    [Documentation]  This keyword is used to verify certain parameter value for RMOD with given id.
    ...  Given arguments are:
    ...  ${rmod_id} - can be: 1,2,3.
    ...  ${given_parameter} - which can be operational_state, availability_status and administrative_state.
    ...  ${parameter_value} - can be: Enabled/Disabled, Online/Degraded/Failed/Offline/Not installed/Other and Unlocked/Locked.
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com
    [Arguments]  ${rmod_id}  ${given_parameter}  ${parameter_value}

    ${rmods}  vdu.Get Rmods Status
    Should Not Be Empty  ${rmods}
    FOR  ${rmod}  IN  @{rmods}
        ${id_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${rmod}[id]  ${rmod_id}
        Run Keyword If  ${id_status}
        ...  Should Contain  ${parameter_value}  ${rmod}[${given_parameter}]
    END


Connect To CPRI RMODs Through FHGW And Return RMODs Info List
    [Documentation]  This keyword is used to return RMODs info in a dictionary list.
    ...  One dictionary contains active and passive software code, serial number and rmod ip.
    ...  Given arguments are:
    ...  ${fhgw_ssh_ip} e.g. 10.15.198.16
    ...  ${fhgw_ssh_username} can be: toor4nsn
    ...  ${fhgw_ssh_password} can be: Fhgw@systeM!23
    ...  It uses "Connect to CPRI RMOD and return rmod info" keyword.
    ...  *AUTHOR*: anna.benzar@nokia.com
    [Arguments]  ${fhgw_ssh_ip}  ${fhgw_ssh_username}  ${fhgw_ssh_password}

    SSHLibrary.Open Connection  ${fhgw_ssh_ip}  prompt=REGEXP:(#|\\$)  timeout=20s
    SSHLibrary.Login  ${fhgw_ssh_username}  ${fhgw_ssh_password}
    SSHLibrary.Write  docker ps | grep rup
    ${ps_command_output}  SSHLibrary.Read Until Prompt
    ${ps_command_output}  Get Lines Containing String  ${ps_command_output}  ruproxy
    Should Not Be Empty  ${ps_command_output}  No containers found on FHGW. [NOK]
    ${splitted_output}  Split String  ${ps_command_output}  \n
    ${containers_list}  Create List
    FOR  ${string}  IN  @{splitted_output}
        ${container}  Fetch From Left  ${string}  ${SPACE}
        Append To List  ${containers_list}  ${container}
    END
    ${rmods_info_list}  Create List
    FOR  ${container}  IN  @{containers_list}
        SSHLibrary.Write  docker exec -it ${container} bash
        ${container_connection_output}  SSHLibrary.Read Until Prompt
        Should Not Contain  ${container_connection_output}  not running  Could not connect to container. Please verify RMODs status on vDU. [NOK]
        SSHLibrary.Write  arp -a
        SSHLibrary.Set Client Configuration  timeout=180s
        ${arp_command_output}  SSHLibrary.Read Until Prompt
        ${rmod_ips_matches}  Get Regexp Matches  ${arp_command_output}  169.254.[0-9]+.[0-9]+
        ${ip_matches_status}  Run Keyword And Return Status
        ...  Should Be Empty  ${rmod_ips_matches}
        Continue For Loop If  ${ip_matches_status}
        ${rmod_info_dictionary}  Create Dictionary
        Set To Dictionary  ${rmod_info_dictionary}  rmod_ip=${rmod_ips_matches}[0]
        ${rmod_info_dictionary}  Connect To CPRI RMOD And Return Rmod Info  ${rmod_ips_matches}[0]  ${rmod_info_dictionary}
        Append To List  ${rmods_info_list}  ${rmod_info_dictionary}
        SSHLibrary.Write  exit
        SSHLibrary.Read Until Prompt
    END

    [Return]  ${rmods_info_list}


Connect To CPRI RMOD And Return Rmod Info
    [Documentation]  This keyword connects ssh to RMOD with given ip and returns a dictionary with retrieved information.
    ...  Given arguments are:
    ...  ${rmod_ip} - 169.254.1.2
    ...  ${rmod_info_dictionary} - the dictionary in which the information is stored.
    ...  It uses "Return passive sw code from CPRI RMOD" keyword.
    ...  *AUTHOR*: anna.benzar@nokia.com
    [Arguments]  ${rmod_ip}  ${rmod_info_dictionary}

    SSHLibrary.Write  ssh -o HostKeyAlgorithms=+ssh-rsa root@${rmod_ip}
    SSHLibrary.Set Client Configuration  prompt=(yes/no/[fingerprint])?
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  yes
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(#|\\$)
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  cat /mnt/factory/configs/unit/core_assembly_serial_number.txt
    ${rmod_serial_number}  SSHLibrary.Read Until Prompt
    ${rmod_serial_number}  Fetch From Left  ${rmod_serial_number}  root
    ${rmod_serial_number}  Get Regexp Matches  ${rmod_serial_number}  [A-Z].+[0-9]
    Should Not Be Empty  ${rmod_serial_number}  Serial number not found for RMOD with ip: ${rmod_ip}. [NOK]
    Set To Dictionary  ${rmod_info_dictionary}  serial_number=${rmod_serial_number}[0]
    SSHLibrary.Write  SWmanShellCommand -i
    ${sw_output}  SSHLibrary.Read Until Prompt
    ${active_sw_info}  Get Regexp Matches  ${sw_output}  (?s)File\\[0]:(.*?)it's active
    Should Not Be Empty  ${active_sw_info}
    ${active_sw_code}  Fetch From Left  ${active_sw_info}[0]  -multi
    ${active_sw_code}  Fetch From Right  ${active_sw_code}  FPGA_
    Set To Dictionary  ${rmod_info_dictionary}  active_sw_code=${active_sw_code}
    ${passive_sw_info}  Get Regexp Matches  ${sw_output}  (?s)File\\[1]:(.*?)it's passive
    ${passive_sw_status}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${passive_sw_info}
    ${passive_sw_code}  Run Keyword If  ${passive_sw_status}
    ...  Return Passive Sw Code From CPRI RMOD  ${passive_sw_info}
    Run Keyword If  ${passive_sw_code} != ${None}
    ...  Set To Dictionary  ${rmod_info_dictionary}  passive_sw_code=${passive_sw_code}
    ${second_passive_sw_info}  Get Regexp Matches  ${sw_output}  (?s)File\\[2]:(.*?)it's passive
    ${second_passive_sw_status}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${second_passive_sw_info}
    ${second_passive_sw_code}  Run Keyword If  ${second_passive_sw_status}
    ...  Return Passive Sw Code From CPRI RMOD  ${second_passive_sw_info}
    Run Keyword If  ${second_passive_sw_code} != ${None}
    ...  Set To Dictionary  ${rmod_info_dictionary}  second_passive_sw_code=${second_passive_sw_code}
    SSHLibrary.Write  exit
    SSHLibrary.Read Until Prompt

    [Return]  ${rmod_info_dictionary}


Return Passive Sw Code From CPRI RMOD
    [Documentation]  This keyword fetches passive software code from RMOD.
    ...  *AUTHOR*: anna.benzar@nokia.com
    [Arguments]  ${passive_sw_info}

    ${passive_sw_code}  Fetch From Left  ${passive_sw_info}[0]  -multi
    ${passive_sw_code}  Fetch From Right  ${passive_sw_code}  FPGA_

    [Return]  ${passive_sw_code}


Get CPRI RFSW Package Name And Code From RFSW Zip File
    [Documentation]  This keyword returns RFSW name and code from the last software found in RFSW folder.
    ...  It uses "Get CPRI RFSW code" keyword.
    ...  *AUTHOR*: anna.benzar@nokia.com
    [Arguments]  ${path_to_rfsw}

    ${softwares}  OperatingSystem.List Directory  ${path_to_rfsw}
    ${rf_software_with_zip}  Get From List  ${softwares}  -1
    ${rf_software}  Fetch From Left  ${rf_software_with_zip}  .zip
    ${file_list}  Zip File List  ${path_to_rfsw}/${rf_software_with_zip}
    FOR  ${item}  IN  @{file_list}
        ${status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${item}  FRM-FPGA.*-multi\\.tar
        ${rf_sw_code}  Run Keyword If  ${status}
        ...  Get CPRI RFSW Code  ${item}
        Exit For Loop If  ${rf_sw_code} != ${None}
    END

    [Return]  ${rf_software}  ${rf_sw_code}


Get CPRI RFSW Code
    [Documentation]  This keyword fetches RFSW code from RFSW file name.
    ...  *AUTHOR*: anna.benzar@nokia.com
    [Arguments]  ${file_name}

    ${rf_sw_code}  Fetch From Left  ${file_name}  -multi.tar
    ${rf_sw_code}  Fetch From Right  ${rf_sw_code}  _

    [Return]  ${rf_sw_code}


Check Additional Information For Given Alarm And Fault
    [Documentation]
    ...  Mandatory parameters: fault_id, fault_name, alarm_id, alarm_name, severity.
    ...  KW checks if given alarm/fault information matches any active alarms in Netact.
    [Arguments]
    ...  ${fault_id}
    ...  ${fault_name}
    ...  ${alarm_id}
    ...  ${alarm_name}
    ...  ${severity}
    ...  ${additional_severity}=${EMPTY}
    ...  ${object_id}=${None}
    ...  ${suppl_info}=${None}

    ${netact_alarms}  netact.Get Alarms  dist_name=${MRBTS_DN}
    FOR  ${na_alarm}  IN  @{netact_alarms}
        Continue For Loop If  '${na_alarm}[additionalText1]'=='None' or '${na_alarm}[additionalText3]'=='None'
        ${additional_text3}  Get From Dictionary  ${na_alarm}  additionalText3
        ${fault_id_na}  Fetch From Left  ${additional_text3}  ${SPACE}
        ${check_fault_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${fault_id_na}  ${fault_id}
        ${additional_text1}  Get From Dictionary  ${na_alarm}  additionalText1
        ${check_fault_name}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${additional_text1}  ${fault_name}
        ${specific_problem}  Get From Dictionary  ${na_alarm}  specificProblem
        ${check_alarm_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${specific_problem}  ${alarm_id}
        ${alarm_text}  Get From Dictionary  ${na_alarm}  alarmText
        ${check_alarm_name}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm_text}  ${alarm_name}
        ${alarm_additional_attributes}  Get From Dictionary  ${na_alarm}  additionalAttributes
        ${alarm_severity}  Set Variable  ${alarm_additional_attributes}[severity]
        ${severity_uppercase}  Convert To Upper Case  ${severity}
        ${additional_severity_uppercase}  Run Keyword If  '${additional_severity}'!='${EMPTY}'
        ...  Convert To Upper Case  ${additional_severity}
        ${check_alarm_severity}  Run Keyword And Return Status
        ...  Should Match Regexp  ${alarm_severity}  (?i)(${severity_uppercase}|${additional_severity_uppercase})
        ${object_id_status}  Run Keyword If  $object_id is $None
        ...  Set Variable  ${TRUE}
        ...  ELSE
        ...  Run Keyword And Return Status
        ...  Should Contain  ${na_alarm}[dn]  ${object_id}
        ${suppl_info_status}  Run Keyword If  $suppl_info is $None
        ...  Set Variable  ${TRUE}
        ...  ELSE
        ...  Run Keyword And Return Status
        ...  Should Contain  ${na_alarm}[additionalText3]  ${suppl_info}
        ${match_condition}  Catenate  ${check_fault_id} and ${check_fault_name} and ${check_alarm_id} and ${check_alarm_name}
        ...  and ${check_alarm_severity} and ${object_id_status} and ${suppl_info_status}
        ${match}  Set Variable If  ${match_condition}  True  False
        Exit For Loop If  ${match} == True
    END
    Should Be Equal As Strings  ${match}  True


Check Additional Information For Given Alarm And Fault In NA Cleared Alarms
    [Documentation]
    ...  **Mandatory parameters: fault_id, fault_name, alarm_id, alarm_name, severity, time_from.
    ...  KW checks if given alarm/fault information maches any acknowledged or unacknowledged and cleared alarm in Netact.
    ...  KW will use get_cleared_alarms from taf.nms.netact with filtering time_from and time_to as arguments.
    ...  If the alarm is not in cleared and acknowledged alarms list, KW will execute get_alarms with only_active parameter set on False.
    ...  In this case, KW check if the alarm is cleared and unacknowledged.
    ...  If both methods don't find the given alarm, KW will fail.
    ...
    ...  *AUTHOR* laura.craciunel@nokia.com
    ...  *MAINTAINER* andrada-lavinia.baleti@nokia.com
    [Arguments]
    ...  ${fault_id}
    ...  ${fault_name}
    ...  ${alarm_id}
    ...  ${alarm_name}
    ...  ${severity}
    ...  ${time_from}
    ...  ${additional_severity}=${EMPTY}
    ...  ${object_id}=${None}
    ...  ${suppl_info}=${None}

    ${time_to}  Get Current Date  time_zone=UTC  result_format=datetime
    ${status_acked_alarms}  Check Alarm In Cleared And Acknowledged Alarms List From NA  ${fault_id}  ${fault_name}  ${alarm_id}  ${alarm_name}
    ...  ${severity}  ${time_from}  ${time_to}  ${additional_severity}  ${object_id}  ${suppl_info}
    Run Keyword If  '${status_acked_alarms}'=='True'
    ...  Return From Keyword
    ${status_unacked_alarms}  Check Alarm In Cleared And Unacknowledged Alarms List From NA  ${fault_id}  ${fault_name}  ${alarm_id}  ${alarm_name}
    ...  ${severity}  ${time_from}  ${time_to}  ${additional_severity}  ${object_id}  ${suppl_info}
    Run Keyword If  '${status_unacked_alarms}'=='False'
    ...  Fail  ${fault_id} with ${fault_name} is not cleared in NA.


Check Alarm In Cleared And Acknowledged Alarms List From NA
    [Documentation]  This keyword is used to check alarm in cleared and acknowledged alarms list from NA
    [Arguments]
    ...  ${fault_id}
    ...  ${fault_name}
    ...  ${alarm_id}
    ...  ${alarm_name}
    ...  ${severity}
    ...  ${time_from}
    ...  ${time_to}
    ...  ${additional_severity}=${EMPTY}
    ...  ${object_id}=${None}
    ...  ${suppl_info}=${None}

    ${netact_alarms}  netact.Get Cleared Alarms  dist_name=${MRBTS_DN}  time_from=${time_from}  time_to=${time_to}
    FOR  ${na_alarm}  IN  @{netact_alarms}
        Continue For Loop If  '${fault_id}' not in '${na_alarm}[additionalText3]'
        ${check_fault_name}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${na_alarm}[additionalText1]  ${fault_name}
        ${check_alarm_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${na_alarm}[specificProblem]  ${alarm_id}
        ${check_alarm_name}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${na_alarm}[alarmText]  ${alarm_name}
        ${alarm_severity}  Set Variable  ${na_alarm}[additionalAttributes][severity]
        ${check_alarm_severity}  Run Keyword And Return Status
        ...  Should Match Regexp  ${alarm_severity}  (?i)(${severity}|${additional_severity})
        ${object_id_status}  Run Keyword If  $object_id is $None
        ...  Set Variable  ${TRUE}
        ...  ELSE
        ...  Run Keyword And Return Status  Should Contain  ${na_alarm}[dn]  ${object_id}
        ${suppl_info_status}  Run Keyword If  $suppl_info is $None
        ...  Set Variable  ${TRUE}
        ...  ELSE
        ...  Run Keyword And Return Status  Should Contain  ${na_alarm}[additionalText3]  ${suppl_info}
        ${condition}  Catenate  ${check_fault_name} and ${check_alarm_id} and ${check_alarm_name}
        ...  and ${check_alarm_severity} and ${object_id_status} and ${suppl_info_status}
        Run Keyword If  ${condition}
        ...  Return From Keyword  True
    END

    [Return]  False


Check Alarm In Cleared And Unacknowledged Alarms List From NA
    [Documentation]  This keyword is used to check alarm in cleared and unacknowledged alarms list from NA
    [Arguments]
    ...  ${fault_id}
    ...  ${fault_name}
    ...  ${alarm_id}
    ...  ${alarm_name}
    ...  ${severity}
    ...  ${time_from}
    ...  ${time_to}
    ...  ${additional_severity}=${EMPTY}
    ...  ${object_id}=${None}
    ...  ${suppl_info}=${None}

    ${alarms_not_acked}  netact.Get Alarms  ${MRBTS_DN}  only_active=False
    FOR  ${na_alarm}  IN  @{alarms_not_acked}
        Continue For Loop If  '${na_alarm}[clearTime]'=='None' or '${fault_id}' not in '${na_alarm}[additionalText3]'
        ${alarm_datetime}  Convert To Datetime Format  ${na_alarm}[clearTime]
        Continue For Loop If  '${alarm_datetime}'<'${time_from}' or '${alarm_datetime}'>'${time_to}'
        ${fault_name_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${na_alarm}[additionalText1]  ${fault_name}
        ${alarm_id_status}  Run Keyword And Return Status
        ...  Should Be Equal As Integers  ${na_alarm}[specificProblem]  ${alarm_id}
        ${alarm_name_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${na_alarm}[alarmText]  ${alarm_name}
        ${severity_status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${na_alarm}[perceivedSeverity]  (?i)(${severity}|${additional_severity})
        ${object_id_status}  Run Keyword If  $object_id is $None
        ...  Set Variable  ${TRUE}
        ...  ELSE
        ...  Run Keyword And Return Status  Should Contain  ${na_alarm}[dn]  ${object_id}
        ${suppl_info_status}  Run Keyword If  $suppl_info is $None
        ...  Set Variable  ${TRUE}
        ...  ELSE
        ...  Run Keyword And Return Status  Should Contain  ${na_alarm}[additionalText3]  ${suppl_info}
        ${condition}  Catenate  ${fault_name_status} and ${alarm_id_status} and ${alarm_name_status} and ${severity_status}
        ...  and ${object_id_status} and ${suppl_info_status}
        Run Keyword If  ${condition}
        ...  Return From Keyword  True
    END

    [Return]  False


Convert To Datetime Format
    [Documentation]  This keyword is used to convert to datetime format: %Y-%m-%d %H:%M:%S.%f.
    ...  Example:
    ...    - input: 2024-09-24T02:50:42.000+0300
    ...    - returned value: 2024-09-23 23:50:42.000
    [Arguments]  ${time}

    ${operation_symbol}  Set Variable If  '+' in '${time}'  +  -
    ${datetime}  Replace String  ${time}  T  ${SPACE}
    ${additional_hours}  Fetch From Right  ${datetime}  ${operation_symbol}
    ${additional_hours}  Get Substring  ${additional_hours}  0  2
    ${datetime}  Fetch From Left  ${datetime}  ${operation_symbol}
    ${datetime}  Run Keyword If  '${operation_symbol}'=='+'
    ...  Subtract Time From Date  ${datetime}  ${additional_hours}:00:00
    ...  ELSE
    ...  Add Time To Date  ${datetime}  ${additional_hours}:00:00

    [Return]  ${datetime}


Check Fault Signature Of Alarm In Netact
    [Documentation]
    ...  KW checks if given fault signature matches regexp.
    ...  Expected fault id nedeed as argument for filtering out the alarms in NA cleared alarms.
    ...  KW will use Get Cleared Alarms from Netact Monitor with filtering time_from and time_to as arguments.
    [Arguments]  ${fault_id}  ${time_from}  ${category}  ${scope}  ${load}  ${component}  ${extra_info}

    ${time_to}  Get Current Date  time_zone=UTC  result_format=datetime
    ${date}  Get Current Date  result_format=%Y-%m-%d
    ${netact_alarms}  netact.Get Cleared Alarms  dist_name=${MRBTS_DN}  time_from=${time_from}  time_to=${time_to}
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${additional_text5}  Get From Dictionary  ${na_alarm}  additionalText5
        Run Keyword If  '${additional_text5}' == 'None'
        ...  Remove Values From List  ${netact_alarms}  ${na_alarm}
    END
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${additional_text3}  Get From Dictionary  ${na_alarm}  additionalText3
        ${fault_id_na}  Fetch From Left  ${additional_text3}  ${SPACE}additionalFaultID=
        ${check_fault_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${fault_id}${SPACE}additionalFaultID=${fault_id}  ${fault_id_na}${SPACE}additionalFaultID=${fault_id_na}
        Run Keyword If  ${check_fault_id}==${FALSE}
        ...  Remove Values From List  ${netact_alarms}  ${na_alarm}
    END
    Log  Alarm matched in Netact, fault signature will be checked.  console=true
    ${additional_text5}  Get From Dictionary  ${netact_alarms}[0]  additionalText5
    ${text5_dict}  Create Additional_text5 Dict  ${additional_text5}
    Should Be Equal  ${text5_dict}[CATEGORY]  CATEGORY:${SPACE}${category}  msg=Category did not matched
    Should Be Equal  ${text5_dict}[SCOPE]  SCOPE:${SPACE}${scope}  msg=Scope did not matched
    Should Be Equal  ${text5_dict}[LOAD_NAME]  LOAD_NAME:${SPACE}${load}  msg=Load did not matched
    Should Contain  ${text5_dict}[COMPONENT]  ${component}  msg=Component did not matched
    Should Match Regexp  ${text5_dict}[EXTRA_INFO]  EXTRA_INFO:${SPACE}${extra_info}  msg=Extra info did not matched
    Should Match Regexp  ${text5_dict}[DATE]  DATE:${SPACE}${date}  msg=Date did not matched
    Log  Fault signature from Netact is OK.  console=true


Create Additional_text5 Dict
    [Documentation]  This keyword is used to create additional_text5 dict
    [Arguments]  ${additional_text5}

    ${element_list}  Split String  ${additional_text5}  ] [
    Remove Values From List  ${element_list}  [FAULT_SIGNATURE
    ${dict}  Create Dictionary
    FOR  ${element}  IN  @{element_list}
        ${value}  Remove String  ${element}  [  ]
        ${key}  Fetch From Left  ${value}  :
        Set To Dictionary  ${dict}  ${key}  ${value}
    END

    [Return]  ${dict}


Check Fault Signature Of Alarm In WebEM
    [Documentation]  This keyword is used to check fault signature of alarm in WebEM
    [Arguments]  ${fault_name}  ${category}  ${load}  ${scope}  ${component}  ${extra_info}

    ${date}  Get Current Date  result_format=%Y-%m-%d
    ${historical_alarms}  vdu.Vdu Get Historical Alarms  sorted_by=appearTime  sort_order=desc  timeout=120s
    ${alarms}  Get From Dictionary  ${historical_alarms}  alarms
    FOR  ${alarm}  IN  @{alarms}
        Run Keyword If  '${alarm}[fault_name]'=='${fault_name}'
        ...  Run Keywords
        ...  Set Test Variable  ${alarm}  ${alarm}
        ...  AND
        ...  Exit For Loop
    END
    ${faultsig}  Get From Dictionary  ${alarm}  fault_signature
    Should Be Equal  ${faultsig}[category]  ${category}  msg=Category did not matched
    Should Be Equal  ${faultsig}[scope]  ${scope}  msg=Scope did not matched
    Should Be Equal  ${faultsig}[load_name]  ${load}  msg=Load did not matched
    Should Contain  ${faultsig}[component]  ${component}  msg=Component did not matched
    Should Match Regexp  ${faultsig}[extra_info]  ${extra_info}  msg=Extra info did not matched
    Should Match Regexp  ${faultsig}[date]  ${date}  msg=Date did not matched
    Log  Fault signature from WebEM is OK.  console=true


Open Connection To VDU And Bring Diagnostic Files To Local Machine
    [Documentation]
    ...  This keyword collects Diagnostic files from vDU to local machine in ${TEST_RESULTS_DIR}.
    ...  It uses "Get Full Name For Pod" and "Get Full Name For Container" keywords.
    ...  *ATUHOR*:  anna.benzar@nokia.com
    [Arguments]  ${namespace}  ${pod_name}  ${step_index}

    Open SSH Connection To VDU And Connect To Openshift
    ${pod}  Get Full Name For Pod  ${namespace}  ${pod_name}
    ${container}  Get Full Name For Container  ${namespace}  ${pod_name}
    ${copy_command}  Catenate  kubectl cp ${pod}:mnt/services/SS_OAM/ASM/working_dir/diagnostic_check/
    ...                        -n cran1 -c ${container} /var/home/core/diagnostic_check
    SSHLibrary.Write  ${copy_command}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Get Directory  /var/home/core/diagnostic_check  ${TEST_RESULTS_DIR}/Diagnostic_Check_step_${step_index}
    SSHLibrary.Write  rm -rf /var/home/core/diagnostic_check
    SSHLibrary.Read Until Prompt
    ${files}  OperatingSystem.List Files In Directory  ${TEST_RESULTS_DIR}/Diagnostic_Check_step_${step_index}
    Should Contain  ${files}  DiagnosticHistoryHistogram.csv  DiagnosticHistoryHistogram.csv not found in directory. [NOK]
    Should Contain  ${files}  DiagnosticReport.csv  DiagnosticReport.csv not found in directory. [NOK]

    [Teardown]  SSHLibrary.Close Connection


Check Active Time For A Specific Alarm On VDU
    [Documentation]  This keyword check if a specific fault id was active for a specific time.
    [Arguments]  ${required_fault}  ${required_active_time}

    ${historical_alarms}  vdu.Vdu Get Historical Alarms  sorted_by=appearTime  sort_order=desc  timeout=120s
    ${alarms}  Get From Dictionary  ${historical_alarms}  alarms
    FOR  ${alarm}  IN  @{alarms}
        ${fault}  Run Keyword If  '${alarm}[fault_id]' == '${required_fault}'
        ...  Set Variable  ${alarm}
        ...  ELSE
        ...  Set Variable  ${FALSE}
        Exit For Loop If  ${fault}
    END
    ${timestamp_appeared}  Fetch From Left  ${fault}[appear_time]  .
    ${timestamp_cleared}  Fetch From Left  ${fault}[cleared_time]  .
    ${date_time_appeared}  Convert Date  ${timestamp_appeared}  exclude_millis=yes
    Log  Alarm appeared at: ${date_time_appeared}.  console=true
    ${date_time_cleared}  Convert Date  ${timestamp_cleared}  exclude_millis=yes
    Log  Alarm dissapered at: ${date_time_cleared}.  console=true
    ${time_appeared}  Fetch From Right  ${date_time_appeared}  ${SPACE}
    ${time_cleared}  Fetch From Right  ${date_time_cleared}  ${SPACE}
    ${active_time}  Subtract Time From Time  ${time_cleared}  ${time_appeared}
    Run Keyword If  ${active_time}==${required_active_time}
    ...  Log  Alarm was active for: ${active_time} seconds![OK]  console=true
    ...  ELSE
    ...  Fail  Alarm was active for: ${active_time} seconds intead of ${required_active_time} seconds![NOK]


Reset VDU And Wait For Ping
    [Documentation]    Reset vDU and wait for ping
    [Arguments]  ${ping_reestablished_timeout}=300

    Reset VDU
    ${ip_adresses}  Create List  ${VDU_OAM_IP}
    ${ping_lost_status}  Run Keyword And Return Status
    ...  ping.Wait For No Ping  ip_addresses=${ip_adresses}  timeout=60s
    Run Keyword If  ${ping_lost_status}
    ...  Log  vDU is resetting...  console=true
    ...  ELSE
    ...  Fail  Ping not lost during vDU reset. [NOK]
    ${ping_reestablished_status}  Run Keyword And Return Status
    ...  ping.Wait For Ping  ip_addresses=${ip_adresses}  timeout=${ping_reestablished_timeout}s
    Run Keyword If  ${ping_reestablished_status}
    ...  Log  vDU reset completed.  console=true
    ...  ELSE
    ...  Fail  Ping not reestablished after ${ping_reestablished_timeout}s vDU reset. [NOK]


VDU Get Parameter Value
    [Documentation]  This keyword returns parameter value based on parameter name and its distname. (not applicable for complex parameters)
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${parameter}  ${dist_name}

    ${object_params}  Get Managed Object Parameters Of Current Plan  ${dist_name}
    ${params_list}  Set Variable  ${object_params}[parameters]
    FOR  ${param_fields}  IN  @{params_list}
        ${simple_parameter}  Run keyword and return status  Should be equal as strings  ${param_fields}[simple_parameter][name]  ${parameter}
        IF  ${simple_parameter}  RETURN  ${param_fields}[simple_parameter][value]
        ${simple_list_parameter}  Run keyword and return status  Should be equal as strings  ${param_fields}[simple_list_parameter][name]
        ...  ${parameter}
        IF  ${simple_list_parameter}  RETURN  ${param_fields}[simple_list_parameter][value]
    END

    Fail  Parameter ${parameter} is not defined.


Verify Fault In RawFaultHistory File
    [Documentation]  This keyword verifies is a specific fault is present in RawFaultHistory file.
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com
    [Arguments]  ${file_content}  ${fault_id}  ${fault_name}  ${date}  ${start_time}

    ${fault_lines}  Get Lines Containing String  ${file_content}  ${fault_id}
    Should Not Be Empty  ${fault_lines}  No fault with id: ${fault_id} found in "rawFaultHistory". [NOK]
    ${fault_lines_list}  Split String  ${fault_lines}  \n
    FOR  ${line}  IN  @{fault_lines_list}
         ${date_time_match}  Get Regexp Matches  ${line}  ${date}T[0-9:+]*
         ${date_status}  Run Keyword And Return Status  Should Not Be Empty  ${date_time_match}
         Continue For Loop If  ${date_status} == ${FALSE}
         ${current_fault_time}  Fetch From Left  ${date_time_match}[0]  +
         ${current_fault_time}  Fetch From Right  ${current_fault_time}  T
         Continue For Loop If  '''${current_fault_time}''' < '''${start_time}'''
         ${fault_name_match}  Get Regexp Matches  ${line}  ${fault_name}
         ${fault_name_status}  Run Keyword And Return status  Should Not Be Empty  ${fault_name_match}
         Continue For Loop If  ${fault_name_status} == ${FALSE}
         Return From Keyword
    END
    Fail  No fault with id: ${fault_id} found in "rawFaultHistory" file on current date, after ${start_time}.


Perform vDU Reset
    [Documentation]  This keyword performs reset on vDU.

    Log  vDU Reset will be performed...  console=true
    vdu.Reset Vdu  timeout=120
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5s
    ...  Check All Cells From VDU  operational_state=${ENABLED}  availability_status=${ONLINE}  administrative_state=${UNLOCKED}
    Log  Cells are online after vDU reset.[OK]  console=true


Get All RMODs IPs from vDU
    [Documentation]  This keyword returns all RMODs ips from vDU.

    Open SSH Connection To VDU And Connect To Openshift
    SSHLibrary.Set Client Configuration  timeout=40s
    ${pod}  Get Full Name For Pod  ${VDU_CRAN}  oamfh
    ${command}  Catenate  kubectl exec -n cran1 ${pod} -c ctr-oamfh -- bash -c "{ echo \\\"aasyscomgw -r\\\"; sleep 1; echo \\\"quit\\\"; } | nc
    ...  127.0.0.1 15067;"
    SSHLibrary.Write  ${command}
    ${output}  SSHLibrary.Read Until Prompt
    ${matches}  Get Regexp Matches  ${output}  [0-9]{3}\\.[0-9]{3}\\.[0-9]{1,3}\\.[0-9]{1,3}
    Should Not be Empty  ${matches}  msg=No RMOD ip found on vDU. [NOK]
    ${rmods_ips}  Remove Duplicates  ${matches}

    RETURN  ${rmods_ips}
    [Teardown]  SSHLibrary.Close Connection


Get Ip For RMOD
    [Documentation]  This keyword is able to connect on all types of RMODs on vDU except CPRI RMODs on SWN configurations.
    ...  All RMODs ips are given as an argument and the keyword tries to connect on every ip with the given user and password.
    ...  Verification is done in every step, when adding the user, the password,
    ...  and if the connection is done successfully, the serial number is verified in the end.
    ...  If the serial number is equal to the given one, the RMOD ip is returned.
    ...  The keyword also works with RMODS that have no password, but the ${rmod_password} must be empty.
    ...  ${dc} variable indicates if the configuration is DC or SWN, and it must be set by the tester.
    [Arguments]  ${rmod_sn}  ${rmod_user}  ${rmod_password}  ${all_rmods_ips}  ${prompt_on_rmod}=REGEXP:(:~#|\\$)  ${dc}=${TRUE}

    FOR  ${rmod_ip}  IN  @{all_rmods_ips}
        Open SSH Connectin To OAMFH Pod
        IF  ${dc}
            SSHLibrary.Write  ssh -B lo ${rmod_user}@${rmod_ip}
        ELSE
            SSHLibrary.Write  ssh ${rmod_user}@${rmod_ipl}
        END
        SSHLibrary.Set Client Configuration  prompt=(yes/no/[fingerprint])?
        ${user_status}  Run Keyword And Return Status  SSHLibrary.Read Until Prompt
        IF  not(${user_status})
            SSHLibrary.Close Connection
            CONTINUE
        END
        SSHLibrary.Write  yes
        IF  '${rmod_password}' != ''
            SSHLibrary.Set Client Configuration  prompt=REGEXP:(Password:|password:)
            SSHLibrary.Read Until Prompt
            SSHLibrary.Write  ${rmod_password}
        END
        SSHLibrary.Set Client Configuration  prompt=${prompt_on_rmod}
        ${password_status}  Run Keyword And Return Status  SSHLibrary.Read Until Prompt
        IF  not(${password_status})
            SSHLibrary.Close Connection
            CONTINUE
        END
        SSHLibrary.Write  sudo cat /mnt/factory/configs/unit/module_serial_number.txt
        ${cat_output}  SSHLibrary.Read Until Prompt
        ${sn_status}  Run Keyword And Return Status  Should Contain  ${cat_output}  ${rmod_sn}
        IF  not(${sn_status})
            SSHLibrary.Close Connection
            CONTINUE
        END
        RETURN  ${rmod_ip}
    END
    Fail  Could not find RMOD ip for RMOD with serial number: ${rmod_sn}

    [Teardown]  SSHLibrary.Close All Connections


Open SSH Connection To Specific RMOD
    [Documentation]  This keyword is able to connect on given RMOD with ip, user and password.
    ...  In this case, the RMOD ip is known for the given serial number.
    ...  Connection to OAMFH pod is opened.
    ...  Configuration type is verified -> can be SWN or DC.
    ...  Verificatiom is done for the user and also for the password, which can also be empty.
    [Arguments]  ${rmod_ip}  ${rmod_user}  ${rmod_password}  ${rmod_sn}  ${prompt_on_rmod}=REGEXP:(:~#|\\$)  ${dc}=${TRUE}

    Open SSH Connectin To OAMFH Pod
    IF  ${dc}
        SSHLibrary.Write  ssh -B lo ${rmod_user}@${rmod_ip}
    ELSE
        SSHLibrary.Write  ssh ${rmod_user}@${rmod_ip}
    END
    SSHLibrary.Set Client Configuration  prompt=(yes/no/[fingerprint])?
    ${user_status}  Run Keyword And Return Status  SSHLibrary.Read Until Prompt
    IF  not ${user_status}  Fail  Not able to connect on RMOD with ip: ${rmod_ip} and serial number: ${rmod_sn}. \tPlease check the user!
    SSHLibrary.Write  yes
    IF  '${rmod_password}' != ''
        SSHLibrary.Set Client Configuration  prompt=REGEXP:(Password:|password:)
        SSHLibrary.Read Until Prompt
        SSHLibrary.Write  ${rmod_password}
    END
    SSHLibrary.Set Client Configuration  prompt=${prompt_on_rmod}
    ${password_status}  Run Keyword And Return Status  SSHLibrary.Read Until Prompt
    IF  not ${password_status}  Fail  Not able to connect on RMOD with ip: ${rmod_ip} and serial number: ${rmod_sn}. \tPlease check the password!
    Log  Connection on RMOD with ip: ${rmod_ip} and serial number: ${rmod_sn}, successfully done. [OK]  console=true
