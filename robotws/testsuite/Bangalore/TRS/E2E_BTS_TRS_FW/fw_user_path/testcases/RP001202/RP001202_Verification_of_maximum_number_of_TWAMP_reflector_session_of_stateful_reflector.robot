***Settings ***
Documentation
...   [Procedure]          "Configuration of TWAMP Reflector session.Verification of 140 TWAMP reflector sessions."
...   [Date]               "Date of creation DD:MM:YY"
...   [Author]             "Abhishek Patil"
...   [QC_Path]            "QC_Path in Test Plan"
...   [QC_ID]              "QC_ID in Test Lab for reporting"
...   [Feature_ID]         "CB006886"
...   [Funtion_Hash_Tags]  "TWAMP"
...   [Validation_status]  Validated and Passed
...   [Validation Date]    MM-DD-YY

Force Tags        CA_E2ET_BTSTRSPZ        SBTS00      RAN_4G    RAN_4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

#Library        ute_syslog
Resource       ${CURDIR}/../resources/Common_Twamp.robot
Resource       ${CURDIR}/../resources/common_keywords.robot
Resource       ${CURDIR}/../resources/Admin_Common_Library.robot
Resource       taf/rfrl/trs_e2e_fw/setup/framework.robot


Suite Setup             Run Keywords    Pre-conditions for testsuite
Suite Teardown     Run Keywords         Post-conditions for testteardown

*** Variables ***
${Back_up_file}         	/tmp/192.168.255.129_scf.xml
#${EGATE_CONFIG}         	${CURDIR}/../resources/egate_configuration.lua
${tshark_alias_eth3}        tshark_eth3
${tshark_eth3_interface}    eth3
${enb_uplane_ip}			10.0.1.2
@{L1}
${index}    				0
${port}						2202

***Test Cases***
[1][1.0] RP001202_Verification of maximum number of TWAMP reflector session of stateful reflector

#Pre-conditions
	Download BTS_TRS File from eNB

#Step-1,2,3
	Start Twamp reflector
	Start 140 Sender Sessions

#Step-4
    Verify Twamp Traffic for 140 sessions
    Check Number of active seesion

#Step-5
    Configure 141st Sender Session
    No Twamp Traffic for the 141st Session
    Check Number of active seesion

	[Teardown]	Keywords To Run At End

*** Keywords ***


Start 140 Sender Sessions
	${Sender_port}=		Set Variable		5020
	@{Sender_port_list}=			Create List
	${Sender_IP} =        Run        sudo ifconfig -a eth3.800 | grep inet | awk -F ' ' '{print $2}'| head -1
    FOR     ${i}    IN RANGE    0		140
            ${twampy_command}=    Set Variable      python /home/ute/MN/UTE/robotlte/testsuite/WMP/E2E_BTS_TRS_FW/fw_user_path/testcases/resources/
            ...     twamp_reflector/twampy.py sender -v ${enb_uplane_ip}:5018 ${Sender_IP}:${Sender_port} --padding 100 -i 6000 -c 9999
            ...     > twamp_port_5018.txt & echo $! > pid.txt
   			Run     ${twampy_command}
			Append To List		${Sender_port_list}			${Sender_port}
			${Sender_port}=		Evaluate		${Sender_port}+1
            ${Sender_port}=     Convert To String           ${Sender_port}
    END
	Set Suite Variable		${Sender_port_list}

Verify Twamp Traffic for 140 sessions
#    Capture traffic for 140 TWAMP session
#    Verification of all 140 Twamp Sessions on Wireshark
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=twamp_max_session
    Sleep   300
    ${capture_file_name} =      Traffic Capture Stop        alias=twamp_max_session
    ${reflector_traffic_data}=    Set Variable      tshark -o twamp.port:5000-5200 -r ${capture_file_name} -Y 'twamp && !icmp && ip.src==10.0.1.2
    ...     && ip.dst==10.0.1.1 && ip.dsfield.dscp==34' -T fields -e udp.dstport 2>/dev/null
    ${reflector_traffic}=       Run     ${reflector_traffic_data}
    Check all 140 Twamp Sessions     ${reflector_traffic}

Capture traffic for 140 TWAMP session
#    [Arguments]     ${capture_file_name}
#    Set Suite Variable  ${capture_file_name}
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=twamp_max_session
    Sleep   300
    ${capture_file_name} =      Traffic Capture Stop        alias=twamp_max_session

Check Number of active seesion
    Execute command on ENodeB       /opt/trs/bin/trs-twamp-d -f /tmp/twampd.ini -s /tmp/twampd.sock execute dumpReflectorTestSessionsInfo
    Execute command on ENodeB       cat /tmp/twamp_Reflector_session_info.txt | grep "Session Active"
    ${lines}=          Split to lines       ${stdout}
    @{lines}=       Convert To List     ${lines}
    FOR    ${i}      IN RANGE      0       140
           Should Match Regexp         ${lines}[${i}]          (?im)Session Active\\s*:\\s*1
    END
    ${total}=       Get Length             ${lines}
    Should Be Equal     '${total}'            '140'


Verification of all 140 Twamp Sessions on Wireshark
    ${sender_traffic_data}=    Set Variable      tshark -o twamp.port:5000-5200 -r ${capture_file_name} -Y 'twamp && !icmp && ip.src==10.0.1.1
    ...     && ip.dst==10.0.1.2 && ip.dsfield.dscp==34' -T fields -e udp.srcport 2>/dev/null
    ${sender_traffic}=  Run     ${sender_traffic_data}
    ${reflector_traffic_data}=    Set Variable      tshark -o twamp.port:5000-5200 -r ${capture_file_name} -Y 'twamp && !icmp && ip.src==10.0.1.2
    ...     && ip.dst==10.0.1.1 && ip.dsfield.dscp==34' -T fields -e udp.dstport 2>/dev/null
    ${reflector_traffic}=   Run     ${reflector_traffic_data}
    Match DSCP Values of all 140 Twamp Sessions     ${sender_traffic}
    Match DSCP Values of all 140 Twamp Sessions     ${reflector_traffic}




Check all 140 Twamp Sessions
    [Arguments]     ${tshark_output}
    @{lines}=          Split to lines   ${tshark_output}
    ${lines}=       Remove Duplicates       ${lines}
    Sort List       ${lines}
    Lists Should Be Equal   ${lines}    ${Sender_port_list}


Configure 141st Sender Session
    ${Sender_IP} =        Run        sudo ifconfig -a eth3.800 | grep inet | awk -F ' ' '{print $2}'| head -1
    ${sender_traffic_data_141}=    Set Variable      python /home/ute/MN/UTE/robotlte/testsuite/WMP/E2E_BTS_TRS_FW/fw_user_path/testcases/resources/
    ...     twamp_reflector/twampy.py sender -v ${enb_uplane_ip}:5018 ${Sender_IP}:5160 --padding 100 -i 2000 > twamp_port_5018_141_session.txt
    ...     & echo $! > pid.txt
    Run     ${sender_traffic_data_141}
    Sleep   5

No Twamp Traffic for the 141st Session
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=twamp_max_session
    Sleep   60
    ${capture_file_name_1} =      Traffic Capture Stop        alias=twamp_max_session
    ${reflector_traffic_data_141}=    Set Variable      tshark -o twamp.port:5000-5200 -r ${capture_file_name_1} -Y 'twamp && !icmp &&
    ...     ip.src==10.0.1.2 && ip.dst==10.0.1.1 && ip.dsfield.dscp==34 && udp.dstport == 5160' -T fields -e udp.dstport 2>/dev/null
    ${reflector_traffic}=       Run     ${reflector_traffic_data_141}

#    Capture traffic     twamp_141st_session.pcap
    Should Be Empty     ${reflector_traffic}
##    ${srcport}=         Evaluate     5020+140


Keywords To Run At End
    Run     for pid in $(ps -ef | grep "twampy" | awk '{print $2}'); do kill -9 $pid; done
