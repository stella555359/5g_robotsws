# Keywords used for robot scripts of feature 5GC002478-A for Classical BTS

*** Settings ***
Library         OperatingSystem
Library         String
Library         Process
Library         Collections
Library         BuiltIn
Library         XML
Library         ArchiveLibrary
Library         SSHLibrary                  WITH NAME       robssh
Library         taf.transport.ssh           WITH NAME       ssh
Library         taf.sbts.oam.coam.admin      WITH NAME       coam
Library         taf.ul.oam.selenium_coam    WITH NAME       selenium_coam
Library         taf.collectors.core         WITH NAME       core
Library         taf.collectors.tcpdump      WITH NAME       tcpdump
Library         taf.sbts.oam.coam.admin      WITH NAME       coam
Library         taf.config.scf              WITH NAME       scf
Library         ute_ue
Library         ute_common_admin

Variables                testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/check_cap.py
Library    taf.analyzer.pcap         WITH NAME    cap
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot





*** Variables ***
${TL_Number}                    ${tl.gnbs[0].instance_id}

${OAM_IP_GNB}                   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${MRBTS_ID_GNB}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID_GNB}                 ${tl.gnbs[0].instance_id}
${X2_IP_GNB}                    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${OAM_IP_ENB1}                  ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${MRBTS_ID_ENB1}                ${tl.enbs[0].instance_id}
${LNBTS_ID_ENB1}                ${tl.enbs[0].global_bts_id}
${LNADJGNB_ID_ENB1}             ${tl.enbs[0].bcf_id}
${X2_IP_ENB1}                   ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${OAM_IP_ENB2}                  ${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
${MRBTS_ID_ENB2}                ${tl.enbs[1].instance_id}
${LNBTS_ID_ENB2}                ${tl.enbs[1].global_bts_id}
${LNADJGNB_ID_ENB2}             ${tl.enbs[1].bcf_id}
${X2_IP_ENB2}                   ${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}

${DU_LOGIN}                     ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${DU_PASSWORD}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

${Log_directory}                /home/ute/5GC002478
#${BTS_PATH}                     MRBTS-1975/NRBTS-1975
${WEBUI_NAME}                   Nemuadmin
${WEBUI_PWD}                    nemuuser
${WEBUI_URL}                    https://${OAM_IP_GNB}
#${uetype}                       smartphone

*** Keywords ***
gNB Get SCF Content
    [Documentation]     Get SCF content
    coam.connect_to     bts_host=${OAM_IP_GNB}
    ${content}=         coam.get_current_scf_content
    [Return]            ${content}
    [Teardown]          coam.teardown


gNB Get CellId and BTSId DN in SCF

    ${content}=    gNB Get SCF Content
    ${parsed_xml}=    XML.Parse Xml    ${content}
    ${cell_elements}=     XML.Get Elements    ${parsed_xml}
    ...    cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    BuiltIn.Should Not Be Empty    ${cell_elements}
    ${cell_num}=    BuiltIn.Get Length    ${cell_elements}

    BuiltIn.Set Suite Variable    ${CV_NRCELL_1}    ${cell_elements[0].attrib['distName']}

    ${result}=          XML.Get Element    ${parsed_xml}
    ...                 .//managedObject[@distName="${CV_NRCELL_1}"]/p[@name="physCellId"]
    BuiltIn.Set Suite Variable            ${physCellId}    ${result.text}

    Log to console                  ${physCellId}


Check NSA call
     #Check L3 call with Askey
    [Arguments]           ${host_ip}      ${PCI}    ${TC_id}    ${connection}
    Do Detach UE
    Start To Capture pcap

    ...                 host_ip=${host_ip}
    ...                 filename_pcap=tcpdump_${TC_id}.pcap
    ...                 connection=${connection}

    #sleep   10
    #Do Attach UE

    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=samsung    log_type=Aasyslog  attach_mode=5G_NSA
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=True


    sleep   10
    Stop To Capture pcap

    ...                 filename_pcap=tcpdump_${TC_id}.pcap
    ...                 connection=${connection}

    cap.read_cap        ${Log_directory}/tcpdump_${TC_id}.pcap
    ${filter1}   Catenate       x2ap.procedureCode == 27

    ...                         && nr-rrc.physCellId == ${PCI}
    cap.Check Expression        ${filter1}
    ${filter2}   Catenate       x2ap.ResponseInformationSgNBReconfComp == 0

    ...                         && x2ap.meNBtoSgNBContainer == 00
    ...                         && nr-rrc.criticalExtensions == 0
    cap.Check Expression        ${filter2}
    Do Detach UE
	Log to console		NSA call is ok

Check X2 lock failure
    [Arguments]         ${TC_id}    ${connection}
    Stop To Capture pcap
    ...                 filename_pcap=tcpdump_${TC_id}.pcap
    ...                 connection=${connection}

    cap.read_cap        ${Log_directory}/tcpdump_${TC_id}.pcap
    Log         Check x2 reset with cause om-intervention
        ${filter}   Catenate       x2ap.procedureCode == 7
        ...                         && x2ap.misc == 2
        cap.Check Expression        ${filter}

    Log to console		L3 call is dropped because of X2 failure

Check X2 sctp failure
    [Arguments]         ${TC_id}
    Stop To Capture pcap
    ...                 filename_pcap=tcpdump_${TC_id}.pcap
    ...                 connection=${connection}
    cap.read_cap        ${Log_directory}/tcpdump_${TC_id}.pcap
    Log         Check SCTP-ABORT
    ${filter}   Catenate        sctp.chunk_type == 6
    ...                         && sctp.abort_t_bit == 0
#    Log         Check SgnbReleaseRequired with cause radio-connection-with-UE-lost
#    ${filter}   Catenate        x2ap.procedureCode == 32
#    ...                         && x2ap.radioNetwork == 43
    cap.Check Expression        ${filter}

Start To Capture pcap
  [Arguments]         ${host_ip}        ${filename_pcap}     ${connection}
   #ssh.connect_to      hostname=${OAM_IP_GNB}      username=${DU_LOGIN}        password=${DU_PASSWORD}
   ssh.send_command    command= tcpdump -i any -n host ${host_ip} -w /tmp/${filename_pcap}  connection=${connection}
   Log to console      command= tcpdump -i any -n host ${host_ip} -w /tmp/${filename_pcap}  connection=${connection}
   #ssh.disconnect

Stop To Capture pcap
  [Arguments]         ${filename_pcap}   ${connection}
  ssh.connect_to      hostname=${OAM_IP_GNB}      username=${DU_LOGIN}        password=${DU_PASSWORD}     alias=new2
  ssh.send_command    command= pkill tcpdump  connection=new2
  sleep    5
  ssh.download_file   /tmp/${filename_pcap}    ${Log_directory}/${filename_pcap}      connection=new2
  Log to console      ssh.download_file /tmp/${filename_pcap} ${Log_directory}/${filename_pcap}
  ssh.disconnect      connection=new2

Do Attach UE
    power_ue.UE Attach    ue_type=samsung    attach_mode=5G_NSA
    sleep       5s
    Log         UE Attached

Do Status UE
    Status Ue   UE_1
    sleep       5s
    Log         Status UE

Do Detach UE
    power_ue.UE Detach    ue_type=samsung
    Log         UE Detached

Do Require UE
    [Arguments]     ${capabilities}=REAL_ANDROID_UE
    Require Ue      UE_1    capabilities=${capabilities}
    Log             UE available




Connect to GNB
  ssh.connect_to              hostname=${OAM_IP_GNB}      username=${DU_LOGIN}        password=${DU_PASSWORD}

Disconnect from GNB
  ssh.disconnect

connect to COAM
    [Arguments]    ${ip_addr}    ${connection}=COAM
    coam.connect to   bts_host=${ip_addr}
                  ...      username=Nemuadmin
                  ...      password=nemuuser
                  ...      name=${connection}


COAM Update Parameter
    [Arguments]   ${dist_name}   ${parameter}   ${value}   ${connection}=COAM
    coam.perform_parameter_recommissioning   dist_name=${dist_name}   parameter=${parameter}   value=${value}
    ...   operation=update
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=60
    ...   connection=${connection}

COAM Check Parameter
    [Arguments]   ${dist_name}   ${parameter}   ${parameterValue}   ${connection}=COAM
    ${getParameterValue}   COAM Get Attribute value in SCF    ${dist_name}   ${parameter}   ${connection}=COAM
	sleep    120
    Should Be Equal       {getParameterValue}    ${parameterValue}
	
	
COAM check_x2_is_locked
    [Documentation]     Get log
    [Arguments]       ${ip_addr}    ${flagavailable}
    ${output}         coam.get_managed_objects    class_name=LTEENB_R    timeout=30    connection=COAM

	${length}    Evaluate    len(${output})

	FOR  ${var}    IN RANGE    0    ${length}
		${x} =	Get From List	${output}	${var}
		${value} =	Get From Dictionary    ${x}    parameters
		${value2} =	Get From Dictionary    ${value}    ipAddr
		Exit For Loop If    "${value2}"=="${ip_addr}"
	END


    ${var1}=    Get From Dictionary    ${value}    x2LinkStatus

	Should Be Equal	 "${var1}"	 "${flagavailable}"
	

COAM Check and Set Parameter
    [Arguments]   ${dist_name}   ${parameter}   ${parameterValue}   ${connection}=COAM
    ${getParameterValue}   COAM Get Attribute value in SCF    ${dist_name}   ${parameter}   ${connection}=COAM
	sleep    120
    run keyword if  not "${getParameterValue}" == "${parameterValue}"
    ...                 COAM Update Parameter
    ...                                 dist_name=${dist_name}
    ...                                 parameter=${parameter}
    ...                                 value=${parameterValue}

	
COAM teardown
    coam.teardown    connection=COAM

COAM Get SCF Content 
    [Documentation]     Get SCF content
    ${content}=         coam.get_current_scf_content    connection=COAM
    [Return]            ${content}
    ##[Teardown]          coam.teardown


COAM Get Attribute value in SCF
    [Documentation]     Get element value in SCF content
    [Arguments]         ${dist_name}    ${p_name}  ${connection}=COAM
    ${content}=         COAM Get SCF Content   
    ${xml_root}=        XML.Parse XML    ${content}
    ${result}=          XML.Get Element    ${xml_root}
    ...                 .//managedObject[@distName="${dist_name}"]/p[@name="${p_name}"]
    [Return]            ${result.text}


Sctp Failure
  [Arguments]           ${address_ip}
  ssh.send_command    command= route add -host ${address_ip} dev vnfh0
  ##ssh.send_command      command= iptables -A INPUT -s ${address_ip} -p sctp -j DROP
  ##ssh.send_command      command= ${BSH_XEONB_GNB} "iptables -A INPUT -s ${address_ip} -p sctp -j DROP"
  ##Log to console        command= ${BSH_XEONB_GNB} "iptables -A INPUT -s ${address_ip} -p sctp -j DROP"
  ##Log to console        route add -host ${address_ip} dev vnfh0

Sctp Recovery
  [Arguments]           ${address_ip}
  ssh.send_command    command= route delete ${address_ip}
  ##ssh.send_command      command= iptables -D INPUT -s ${address_ip} -p sctp -j DROP
  ##ssh.send_command      command= iptables -D INPUT -s ${address_ip} -p sctp -j DROP
  ##ssh.send_command      command= iptables -D INPUT -s ${address_ip} -p sctp -j DROP
  ##ssh.send_command      command= ${BSH_XEONB_GNB} "iptables -D INPUT -s ${address_ip} -p sctp -j DROP"
  ##ssh.send_command      command= ${BSH_XEONB_GNB} "iptables -D INPUT -s ${address_ip} -p sctp -j DROP"
  ##ssh.send_command      command= ${BSH_XEONB_GNB} "iptables -D INPUT -s ${address_ip} -p sctp -j DROP"
  ##Log to console        command= ${BSH_XEONB_GNB} "iptables -D INPUT -s ${address_ip} -p sctp -j DROP"
  Log to console        Sctp recovery

#Stop and download Wireshark file on gNB
#  [Arguments]         ${filename}
#  ssh.send_command    command= pkill tcpdump
#  sleep    30
#  ssh.download_file   ${filename}    ${Log_directory}/${filename}
#  ssh.send_command    command= rm ${filename}

#Expected Fault Should Be Present
#    [Documentation]
#    [Arguments]    ${faultId}       ${expected_status}     ${alarming_object}     ${source}=${None}   ${severity}=${None}    ${alarmId}=${None}
#    ${alarms}           selenium_coam.get active alarm info
#    ${alarm_num}        Get Length    ${alarms}
#    ${present_status}   Set Variable    ${False}
#    FOR  ${alarm}  IN  @{alarms}
#       Exit For Loop If     ${alarm_num}==${0}
#       ${present_status}    Run Keyword And Return Status
#       ...                          Run Keywords
#       ...                                          Should Be Equal As Strings      ${alarm['Alarm ID']}    ${alarmId}
#       ...                                  AND
#       ...                                          Should Be Equal As Strings      ${alarm['Fault ID']}    ${faultId}
#       ...                                  AND
#       ...                                          Should Be Equal As Strings      ${alarm['Alarming object']}    ${alarming_object}
#      Exit For Loop If      ${present_status}
#     END
#    Run keyword and continue on failure     Should Be Equal         ${present_status}       ${expected_status}

Expect Fault Should Present new
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    ${faultId}    Convert To Integer    ${faultId}
    @{alarms}    coam.get_active_alarms    connection=${connection}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
        Exit For Loop If    ${alarm_num}==${0}
        ${present_status}    Run Keyword And Return Status    Run Keywords
        ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
        ...                      Run Keyword If    '${source}'!='${None}'
        ...                      Should Contain     ${alarm['notifier']}    ${source}    case_insensitive=True    AND
        ...                      Run Keyword If    '${severity}'!='${None}'
        ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
        ...                      Run Keyword If    '${alarmId}'!='${None}'
        ...                      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}
        Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.





Test Setup TC01
    Log to console         starting Setup TC01
    OperatingSystem.Create Directory    /home/ute/5GC002478

    connect to COAM        ${OAM_IP_ENB1}
	COAM Check and Set Parameter
	...         dist_name=MRBTS-${MRBTS_ID_ENB1}/LNBTS-${LNBTS_ID_ENB1}/LNADJGNB-${LNADJGNB_ID_ENB1}
    ...         parameter=administrativeState
    ...         parameterValue=unlocked
    COAM teardown
	
    connect to COAM        ${OAM_IP_ENB2}
    COAM Check and Set Parameter
    ...         dist_name=MRBTS-${MRBTS_ID_ENB2}/LNBTS-${LNBTS_ID_ENB2}/LNADJGNB-${LNADJGNB_ID_ENB2}
    ...         parameter=administrativeState
    ...         parameterValue=unlocked
	COAM teardown

	
#    ssh.connect_to              hostname=${OAM_IP_GNB}      username=${DU_LOGIN}        password=${DU_PASSWORD}
#    Sctp Recovery               address_ip=${X2_IP_ENB1}
#    ssh.disconnect
    Log to console      TC01 Test setup completed


Test Setup TC08
    Log to console         starting Setup TC08
    OperatingSystem.Create Directory    /home/ute/5GC002478

	connect to COAM        ${OAM_IP_ENB1}

    COAM Check and Set Parameter
    ...         dist_name=MRBTS-${MRBTS_ID_ENB1}/LNBTS-${LNBTS_ID_ENB1}/LNADJGNB-${LNADJGNB_ID_ENB1}
    ...         parameter=administrativeState
    ...         parameterValue=unlocked
    COAM teardown
	
    connect to COAM        ${OAM_IP_ENB2}
	
    COAM Check and Set Parameter
    ...         dist_name=MRBTS-${MRBTS_ID_ENB2}/LNBTS-${LNBTS_ID_ENB2}/LNADJGNB-${LNADJGNB_ID_ENB2}
    ...         parameter=administrativeState
    ...         parameterValue=unlocked
    COAM teardown
	

	connect to COAM        ${OAM_IP_GNB}

#    ssh.connect_to              hostname=${OAM_IP_GNB}      username=${DU_LOGIN}        password=${DU_PASSWORD}
#    Sctp Recovery               address_ip=${X2_IP_ENB1}
#    ssh.disconnect
    Log to console      TC08 Test setup completed

Test Setup TC09
    Log to console         starting Setup TC09
    OperatingSystem.Create Directory    /home/ute/5GC002478

    ssh.connect_to              hostname=${OAM_IP_GNB}      username=${DU_LOGIN}        password=${DU_PASSWORD}
    Sctp Failure                address_ip=${X2_IP_ENB2}
    ssh.disconnect

    sleep    60

	connect to COAM        ${OAM_IP_ENB2}
    COAM Check and Set Parameter
    ...         dist_name=MRBTS-${MRBTS_ID_ENB2}/LNBTS-${LNBTS_ID_ENB2}/LNADJGNB-${LNADJGNB_ID_ENB2}
    ...         parameter=administrativeState
    ...         parameterValue=unlocked
    COAM teardown
	
    
	connect to COAM        ${OAM_IP_ENB1}
    COAM Check and Set Parameter
    ...         dist_name=MRBTS-${MRBTS_ID_ENB1}/LNBTS-${LNBTS_ID_ENB1}/LNADJGNB-${LNADJGNB_ID_ENB1}
    ...         parameter=administrativeState
    ...         parameterValue=locked
    COAM teardown
	
	
    Log to console      TC09 Test setup completed
