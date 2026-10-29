***Settings ***
Documentation
...   [Procedure]          "Configuration & verification of TWAMP Reflector session & loss."
...   [Date]               "Date of creation DD:MM:YY"
...   [Author]             "Abhishek Patil"
...   [QC_Path]            "QC_Path in Test Plan"
...   [QC_ID]              "QC_ID in Test Lab for reporting"
...   [Feature_ID]         "CB007308-SR001202"
...   [Funtion_Hash_Tags]  "TWAMP Reflector"
...   [Validation_status]  Validated and Passed
...   [Validation Date]    MM-DD-YY



Resource       ${CURDIR}/../resources/Common_Twamp.robot
Resource       ${CURDIR}/../resources/common_keywords.robot
Resource       ${CURDIR}/../resources/Admin_Common_Library.robot


Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for test teardown


*** Variables ***
${Back_up_file}             /tmp/192.168.255.129_scf.xml
${tshark_alias_eth3}        tshark_eth3
${tshark_eth3_interface}    eth3
${uplane_ip}            10.0.1.2
${index}                                0
${port}                                         2202
${twamp_file}              /home/ute/twampy.py
***Test Cases***
[1][1.0] RP001202_Verification of session context with packet loss
    Download BTS_TRS File from eNB
    Start TWAMP Sender Sessions
	Verify TWAMP Reflector session
	Verify Loss for TWAMP session

    [Teardown]      Keywords To Run At End

*** Keywords ***

Start TWAMP Sender Sessions
	${Sender_port}=         Set Variable            5020
    ${Sender_IP} =        Run        sudo ifconfig -a eth3 | grep inet | awk -F ' ' '{print $2}'| head -1
    Run     python ${twamp_file} sender -v ${uplane_ip}:5018 ${Sender_IP}:${Sender_port} --padding 100 -i 6000 -c 9999 > twam.txt & echo $! > pid.txt

Verify TWAMP Reflector session
    &{dict_var_temp}=    Create Dictionary
    Execute command on ENodeB       /opt/trs/bin/trs-twamp-d -f /tmp/twampd.ini -s /tmp/twampd.sock execute dumpReflectorTestSessionsInfo
    Execute command on ENodeB       cat /tmp/twamp_Reflector_session_info.txt |grep -A 10 -i "session ID" |head -10
    @{lines}=          Split to lines       ${stdout}
    ${length}=      Get Length    ${lines}
    FOR    ${val}    IN RANGE   0    ${length}
        ${list_var2} =    Split String    ${lines}[${val}]    :    max_split=1
        ${str} =    Remove String    ${list_var2}[0]    ${SPACE}
        Set To Dictionary    ${dict_var_temp}    ${str}=${list_var2}[1]

    Log    ${dict_var_temp}
    END

    Download BTS_TRS File from eNB
    ${TWAMP_Reflector_IP}=    Get Element Text       /tmp/192.168.255.129_scf.xml
    ...    .//managedObject[@distName="MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/TWAMPREFLECT-1"]/p[@name="twampReflectorLocalIpAddressDN"]
    ${twamp_reflector}=     Get Element Text      /tmp/192.168.255.129_scf.xml
    ...    .//managedObject[@distName="MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"]/p[@name="localIpAddr"]
    ${lmp_ip_addr} =        Run        sudo ifconfig -a eth3 | grep inet | awk -F ' ' '{print $2}'| head -1

Verify Loss for TWAMP session
	Run     sudo tc qdisc add dev eth3 root netem loss 100%
	&{dict_var_temp}=    Create Dictionary
	&{dict_var_temp}=    Create Dictionary
    Execute command on ENodeB       /opt/trs/bin/trs-twamp-d -f /tmp/twampd.ini -s /tmp/twampd.sock execute dumpReflectorTestSessionsInfo
    Execute command on ENodeB       cat /tmp/twamp_Reflector_session_info.txt |grep -A 10 -i "session ID" |head -10
    ${lines}=          Split to lines       ${stdout}
    ${length}=      Get Length    ${lines}
    FOR    ${val}    IN RANGE   0    ${length}
	    ${list_var2} =    Split String     ${lines}[${val}]   :    max_split=1
        ${str} =    Remove String    ${list_var2}[0]    ${SPACE}
        Set To Dictionary    ${dict_var_temp}    ${str}=${list_var2}[1]
    END
    Log    ${dict_var_temp}
    ${val} =    Remove String    ${dict_var_temp['TimelastPktRecv']}    (in Sec Before)
    Should Be True    ${val} > 0

Keywords To Run At End
	Run     sudo tc qdisc del dev eth3 root
