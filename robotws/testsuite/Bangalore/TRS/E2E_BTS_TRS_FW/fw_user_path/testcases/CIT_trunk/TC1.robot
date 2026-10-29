*** Settings ***
Documentation
...	[Author]	"Ankita"


Library		ute_fsmaccess
Library		SSHLibrary

Resource   taf/rfrl/trs_e2e_fw/setup/framework.robot
#Resource  testcases/resources/route_operations.robot
#Resource  testcases/resources/common_keywords.robot
Resource   ${CURDIR}/../resources/route_operations.robot
Resource   ${CURDIR}/../resources/common_keywords.robot

Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops

#Suite Setup       Setup Oamops
#Suite Teardown    Teardown Oamops

Force Tags    CA_E2ET_BTSTRSPZ        SBTS00   SBTS21B        SBTS22R1    SBTS22R2    4G_FDD     QCD_MN_RAN    QCP_RAN_VRF      CIT

*** Variables ***
${file_password}	Trsiv123!
${eNB_ip}		192.168.255.129
${validLmpIp}		192.168.255.126
${invalidLmpIp}		192.168.255.127
${netMask}		255.255.240.0
${username}				toor4nsn
${password}				oZPS0POrRieRtu
${wrong_password}		oZPS0POrRieRtu1
${secadm_ethernetPortSecurityEnabled_moc_path}	SECADM-1:ethernetPortSecurityEnabled
${capture_ongoing_fault_id}	61641
${build_number}
${sbh_config}          delta_sbh_config.xml
${remove_sbh_config}     remove_sbh_config.xml
${LMP}                  61649
${plain_mplane_ip}      10.41.220.67

*** Test Cases ***

#[1]SBTS_Transport_Network_scenario_5VLAN_Alias_Ipv4_EIF1
[1.0] SBTS_Transport_Network_scenario_5VLAN_Alias_Ipv4_EIF1

    LMP_PORT Alarm should exit
    Reset Admin
    sleep       100
#    LMP_Port Alarm should not exit  ${plain_mplane_ip}  ${LMP}
#Build Upgrade
#    Initial SBH config
#   Perform Software Download And Update  package=${build_number}_release_BTSSM_downloadable_A54.zip    timeout=1800
#   Sleep   900
#    Remove SBH config
#Commisioning
	Setup Oamops
    Pre Conditions
	Perform Commissioning	rat=lte     verify_bts_status=False    timeout=600
    Sleep   120
#Unexpected alarms
	Verify Alarm    expected_alarms=${expected_alarms}
#    Check R&D and SSH alarm
#Ethernet Port Security
	Ethernet Port Security
    Sleep  60
#Basic IR, KUR
	certificate configure           operation=install_cmp_certificate    timeout=120
	Sleep   80
	certificate configure           operation=cmp_update_key            timeout=120
    Sleep   80
#BFD#As part of config
#Logging of IP traffic capture sessions
#######	Verify Logging Of Traffic Capture Sessions
#907 SSH Support
	Run Keyword And Ignore Error    SSH Support
###RAT Calls with IP Traffic Capture
#	Three Rat Calls
#Snapshot
	${snap}=	Collect Snapshot        timeout=1200
	Validate Snapshot	${snap}
#Unexpected alarms
	Verify Alarm    expected_alarms=${expected_alarms}
    sleep   10
    [Teardown]	Post Conditions

*** Keywords ***
Check R&D and SSH alarm
    [Documentation]        SSH and r&d is already enabled as part of full commissioning
     Verify Alarm        faultid=61652    rat=lte     should_exist=${True}
     Verify Alarm        faultid=61524    rat=lte     should_exist=${True}
     Verify Alarm        faultid=61649    rat=lte     should_exist=${True}
    Perform Recommissioning     type=param      rat=lte     param_path=${randdport_moc}  operation=update    value=false     timeout=300
    Sleep   15
    Verify Alarm        faultid=61652    rat=lte     should_exist=${False}
    Perform Recommissioning     type=param      rat=lte     param_path=${randdport_moc}  operation=update    value=true     timeout=300
    Sleep   15
    Verify Alarm        faultid=61652    rat=lte     should_exist=${True}

    #SSH support
    Perform Recommissioning     type=param      rat=lte     param_path=${sshport}  operation=update    value=false     timeout=300
    Sleep   15
    Verify Alarm        faultid=61524    rat=lte     should_exist=${False}
    Perform Recommissioning     type=param      rat=lte     param_path=${sshport}  operation=update    value=true     timeout=300
    Sleep   15
    Verify Alarm        faultid=61524    rat=lte     should_exist=${True}

Initial SBH config
    Run     sudo tc qdisc add dev eth1 root netem delay 50ms
    Perform Recommissioning      type=delta     delta_file=${sbh_config}     timeout=300
    Sleep    60

Remove SBH config
    Run     sudo tc qdisc del dev eth1 root
    Perform Recommissioning      type=delta     delta_file=${remove_sbh_config}     timeout=300
    Sleep   60

Verify Logging Of Traffic Capture Sessions
		Start Syslog     /home/ute      syslog.txt      alias=analyse_password
		Traffic Capture Start        capture_device=oam_device    mode=file  measurement_point=Transport_Interface   uplane_capturing=True
	...		password=${file_password}   timeout=120   alias=capture_file
		Sleep   100
##@		Verify Alarm            faultid=${capture_ongoing_fault_id}
		${filename_pwd}=   Traffic Capture Stop   mode=file  alias=capture_file     password=${file_password}     timeout=200
		Analyse Syslog         analysis=analysis_name2         alias=analyse_password
		Stop Syslog       alias=analyse_password
        Setup Remote Access	remote_device=bts
#        ${output}=      Run Keyword And Expect Error     *SSHExecutionError*
	Remote Command Execute	command=cat /var/log/trs | grep -i ${file_password}
        ...		${output}=     Remote Command Execute		command=cat /var/log/trs | grep -i ${file_password}
         Should Be Empty     ${output}
       	Teardown Remote Access
SSH Support
#        SSH verification with high data traffic
        Verify SSH authentication is limited to 3
        FOR    ${INDEX}    IN RANGE    1    11
            Open Connection    ${eNB_ip}      alias=conn${INDEX}
		    Login    ${username}      ${password}
        END
        Close all connections
SSH verification with high data traffic
        Setup Remote Access	remote_device=bts
        Remote Command Execute    command=ping -w 120 -i 0.001 10.43.255.23 &
    	Teardown Remote Access
        Open Connection  ${eNB_ip}
        Login     ${username}           ${password}
        Close all Connections

Verify SSH authentication is limited to 3
        Open Connection    ${eNB_ip}   alias=session1
        Run Keyword and Expect error	*Authentication failed*		Login	${username}	${wrong_password}    alias=session1
        Sleep   10
        Open Connection    ${eNB_ip}   alias=session2
        Run Keyword and Expect error	*Authentication failed* 	Login     ${username}           ${wrong_password}     alias=session2
        Sleep   10
        Open Connection    ${eNB_ip}    alias=session3
        Run Keyword and Expect error	*Authentication failed*		Login     ${username}           ${wrong_password}    alias=session3
        Sleep   10
        Open Connection    ${eNB_ip}    alias=session4
        Run Keyword and Expect Error    *SSHException: Error reading SSH protocol banner*
	...		Login     ${username}           ${wrong_password}    alias=session4
        Close all Connections
        Open Connection    ${eNB_ip}
        ${output}=    Login    ${username}    ${password}
        Should Match Regexp    ${output}    There were 3 failed login attempts since the last successful login
        Close all Connections

Ethernet Port Security
		#Step1
        ${soe}=         Get Parameter           param_path=${secadm_ethernetPortSecurityEnabled_moc_path}
        Run Keyword If          '${soe}'=='False'               Perform Recommissioning         type=param
	...		param_path=${secadm_ethernetPortSecurityEnabled_moc_path}       value=true      operation=update
        Sleep    15
        Verify Alarm        faultid=4654    rat=lte     should_exist=${False}
        Perform Recommissioning         type=param      param_path=${secadm_ethernetPortSecurityEnabled_moc_path}
	...		 value=false      operation=update    timeout=180
        Sleep   15
        Verify Alarm        faultid=4654    rat=lte     should_exist=${True}
        Perform Recommissioning         type=param      param_path=${secadm_ethernetPortSecurityEnabled_moc_path}
	...		value=true      operation=update    timeout=180
        Sleep   15
        Verify Alarm        faultid=4654    rat=lte     should_exist=${False}
		#Discard Chain pre-count
        Get Discard Chain Count
        ${precount}=    Get From List   ${count}        0
     	${precount}=    Convert to Integer    ${precount}
		#Change lan settings
        Run     sudo ifconfig eth1 ${invalidLmpIp} netmask ${netMask}
        Run     ping -c 10 ${eNB_ip}
        Sleep   60
		# change back LAN Settings
        Run     sudo ifconfig eth1 ${validLmpIp} netmask ${netMask}
		#Discard Chain post-count
        Get Discard Chain Count
        ${postcount}=   Get From List   ${count}        0
	${postcount}=    Convert to Integer    ${postcount}
		#Compare pre and post values
        Should Be True  ${postcount}>${precount}
        Sleep    60

Three Rat Calls
	Traffic Capture Start   capture_device=oam_device    mode=file  measurement_point=NE_Terminated
	...		uplane_capturing=True  timeout=120  alias=no_password
        All Rat Calls
		#Discard Chain pre-count
        Get Discard Chain Count
        ${precount}=    Get From List   ${count}        0
	${precount}=    Convert to Integer    ${precount}
		#Change lan settings
        Run     sudo ifconfig eth1 ${invalidLmpIp} netmask ${netMask}
        Run     ping -c 10 ${eNB_ip}
        Sleep   60
		# change back LAN Settings
        Run     sudo ifconfig eth1 ${validLmpIp} netmask ${netMask}
		#Discard Chain post-count
        Get Discard Chain Count
        ${postcount}=   Get From List   ${count}        0
	${postcount}=    Convert to Integer    ${postcount}
		#Compare pre and post values
        Should Be True  ${postcount}>${precount}

#Three Rat Calls
#Traffic Capture Start   capture_device=oam_device    mode=file  measurement_point=NE_Terminated
#uplane_capturing=True  timeout=120alias=no_password
#        All Rat Calls
#        Traffic Capture Stop   mode=file  alias=no_password  timeout=12
All Rat Calls
#	Call Setup      lte=device_1:data       wcdma=device_1:data     gsm=device_1:voice      parallel=${True}
	Call Setup      lte=device_1:data       gsm=device_1:voice      parallel=${True}
	Call Start      lte=device_1:data       profile=udp_ul
        Call Start      lte=device_1:data       profile=udp_dl
#        Call Start      wcdma=device_1:data     profile=udp_ul_wcdma
#        Call Start      wcdma=device_1:data     profile=udp_dl_wcdma
        Call Start      gsm=device_1:voice
        Sleep   30
	Call Stop       lte=device_1:data       profile=udp_ul
        Call Stop       lte=device_1:data       profile=udp_dl
#        Call Stop       wcdma=device_1:data     profile=udp_ul_wcdma
#        Call Stop       wcdma=device_1:data     profile=udp_dl_wcdma
        Call Stop       gsm=device_1:voice

Validate Snapshot
        [Arguments]             ${snap}
        Run     unzip -o ${snap} -d Sample/
        ${ext_location}=        Run     cat Sample/snapshot_file_list.txt | grep -B 1000 Exte | grep -e "zip:" | tail -1 | awk -F ':' '{print $1}'
        Run     unzip -o Sample/${ext_location} -d Sample/
        ${ExtendedNezip}=       Run     find . -name *Extended*.txz
        Run     xz -d ${ExtendedNezip}
        ${ExtendedNeziptar}=    Run     find . -name *Extended*.tar
	${ext_content}=		Run     tar xvf ${ExtendedNeziptar} -C Sample/
        log     ${mandatoryfiles}
        FOR    ${ELEMENT}    IN    @{mandatoryfiles}
               Should Match Regexp     ${ext_content}  ${ELEMENT}
        END

Get Discard Chain Count
	Setup Remote Access	remote_device=bts
#a	${count}=	Remote Command Execute    command=iptables -nvL ETH_SECURITY_SRC |grep -e "DISCARD_CHAIN"|awk '{print $1}'
#	return_rc=False
	${count}=	Remote Command Execute
	...		command=nft list chain filter ETH_SECURITY_SRC |grep -e "DISCARD_CHAIN"| awk '{print $3}'     return_rc=False
#a	${count}=    Convert to Integer    ${count}
	Set Suite Variable	${count}	${count}
	Teardown Remote Access

LMP_PORT Alarm should exit
    Setup Oamops    dut=bts    bts_port=443     use_ssl=True
    Verify Alarm    expected_alarms=${LMP}

Reset Admin
    Reset Bts       verify_bts=False    req_rat=lte     should_be_onair=False   wait_for=800
    Sleep   100
    Verify Alarm    expected_alarms=${LMP}
    Teardown Oamops

LMP_Port Alarm should not exit
    [Arguments]     ${fsmr4_plain_mplane_ip}        ${Fault_id}
    Setup Oamops    bts_host=${fsmr4_plain_mplane_ip}   bts_port=443    use_ssl=True
    Should Not Be Equal     Verify Alarm    expected_alarms=${Fault_id}
    Teardown Oamops

Pre Conditions
	Add Routes For Alias IPs
#a    Sleep   111


Post Conditions
	Remove Routes For Alias IPs
#a    Sleep   111
	Run Keyword And Ignore Error	Call Stop       lte=device_1:data       profile=udp_ul
        Run Keyword And Ignore Error	Call Stop       lte=device_1:data       profile=udp_dl
        Run Keyword And Ignore Error	Call Stop       wcdma=device_1:data     profile=udp_ul_wcdma
        Run Keyword And Ignore Error	Call Stop       wcdma=device_1:data     profile=udp_dl_wcdma
        Run Keyword And Ignore Error	Call Stop       gsm=device_1:voice
	Run Keyword And Ignore Error	Traffic Capture Stop   mode=file  alias=capture_file  timeout=120
	Run Keyword And Ignore Error	Traffic Capture Stop   mode=file  alias=no_password  timeout=120
    Run Keyword and ignore error    Remove SBH config
