*** Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to validate user credential verification via mplane"
    ...     [Date]                  "23-07-2025"
    ...     [Author]                "Shivani"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"

Library     ute_fsmaccess
Library     Collections
Library     String

variables       ta_e2e_bts_trs_fw
Library          ute_btssm
Library			 SeleniumLibrary
Resource		 ${CURDIR}/../resources/Admin_Common_Library.robot
Resource         ${CURDIR}/../resources/CB007162_Common_Keywords.robot
Resource	    ${CURDIR}/../resources/common_keywords.robot

Suite setup    Run Keywords    setup oamops
...            AND    Setup Oamops     dut=chained_bts     alias=secondary
Suite Teardown     Run Keywords     Teardown oamops
...            AND    Teardown Oamops    dut=chained_bts    alias=secondary


*** Variables ***
${counter_analysis_file_name}                   cb7135_counters_analysis.json
${LMP_ip}       192.168.255.129
${ipv4_ip}      10.0.1.2
#${secondary_ipv4_ip}      10.0.1.2
#${secondary_LMP_ip}       192.168.255.119


***Test Cases***
[1]Verification of user credentials and alarm for accounts
#Create and enable BTS Security Administrator, BTS Application Administrator and BTS Read-Only User accounts.
    Enable 'BtsSecurity' account
    Setup Oamops	bts_host=192.168.255.119    bts_port=443    username=btssec	password=Btsec@123	      	alias=secondary

    Enable 'BtsApplication' account
	Setup Oamops	bts_host=192.168.255.119    bts_port=443    username=btsapp	password=Btsap@123	      	alias=secondary

    Enable 'BtsRead' account
	Setup Oamops	bts_host=192.168.255.119    bts_port=443    username=btsread	password=Btsred@123	      	alias=secondary

#Failedattempts
#Set BTS session login values
    Perform Recommissioning     type=param  rat=lte     param_path=LUAC-1:btsSessionLoginDelay      operation=update
    ...     value=${btsSessionLoginDelay_value}     timeout=300
    Perform Recommissioning     type=param  rat=lte     param_path=LUAC-1:btsMaxFailedLoginAttempts     operation=update
    ...     value=${btsMaxFailedLoginAttempts_value}    timeout=300
    Perform Recommissioning     type=param  rat=lte     param_path=LUAC-1:btsAccountLockoutDuration     operation=update
    ...     value=${btsAccountLockoutDuration_value}    timeout=300
    Perform Recommissioning     type=param  rat=lte     param_path=LUAC-1:btsFailedLoginCountingPeriod      operation=update
    ...     value=${btsFailedLoginCountingPeriod_value}     timeout=300
#    Sleep    10
    Setup Oamops    bts_host=192.168.255.129    bts_port=443    username=Nemuadmin    password=nemuuser    alias=default
    Setup Oamops    bts_host=192.168.255.119    bts_port=443    username=Nemuadmin    password=nemuuser    alias=secondary

    Run Keyword And Expect Error    *AdminApiConnectionClosedException*     Setup Oamops    bts_host=192.168.255.129
    ...     bts_port=443    username=Nemuadmin    password=nemu    alias=one    timeout=17s
	Verify Alarm   faultid=61642     rat=5g       should_exist=${True}      occurrences=1
    Verify Alarm   faultid=61642     rat=5g       should_exist=${True}      occurrences=1     alias=secondary


#########RUEM_LOG####################
#primary
     ${output}=  Get Infomodel Dump      dut=bts         dist_name_regex=/MRBTS-1/RAT-1/EVENT_LOG-1
     ${dict_valu}=    Get Dictionary Values     ${output}

     ${length}=  Get length    ${dict_valu}
    Log To console    ${dict_valu}[1]
     FOR    ${i}    IN RANGE    1   ${length}
          ${counter_param_dict}=      Get From Dictionary   ${dict_valu}[${i}]     key=operation
#          should be equal as strings    ${counter_param_dict}     SSH Login operation
#          should be equal as strings    ${counter_param_dict}    SSH Logout operation
    END
    ${counter_param_dict3}=      Get From Dictionary   ${dict_valu}[3]     key=operation
#        should be equal as strings    ${counter_param_dict}    SSH Login operation
#        should be equal as strings    ${counter_param_dict}    SSH Logout operation
#secondary

    ${output}=  Get Infomodel Dump      dut=bts    alias=secondary        dist_name_regex=/MRBTS-1/RAT-1/EVENT_LOG-1
     ${dict_valu}=    Get Dictionary Values     ${output}

     ${length}=  Get length    ${dict_valu}
    Log To console    ${dict_valu}[1]
     FOR    ${i}    IN RANGE   1    ${length}
          ${counter_param_dict}=      Get From Dictionary   ${dict_valu}[${i}]     key=operation
#          should be equal as strings    ${counter_param_dict}     SSH Login operation
#          should be equal as strings    ${counter_param_dict}    SSH Logout operation
    END
    ${counter_param_dict4}=      Get From Dictionary   ${dict_valu}[3]     key=operation
    should be equal    ${counter_param_dict3}    ${counter_param_dict4}

#####################Verification_of_open_filtered_ports_on_nmap###########################
    [Documentation]     This test case verifies the port 80 removal and port 3600 status according to actcli parameter
    Perform Recommissioning     type=param      param_path=SECADM-1:ethernetPortSecurityEnabled
    ...     value=true       operation=update        timeout=120
#    Perform NMAP Port scan for Mplane
    Perform NMAP Port scan for LMP

#####Nmap verificaton of ports on secondary##############
#    [Documentation]     This test case performs NMAP port scan for secondary BTS (both Mplane and LMP) before and after enabling actcli
    Perform Recommissioning     dut=chained_bts     type=param      param_path=SECADM-1:ethernetPortSecurityEnabled
    ...     value=true       operation=update        timeout=120     alias=secondary
    Setup Remote Access  remote_device=Secondarybts
    ${output}=         Remote Command Execute      command=nmap -oN - -p 22,80,443,3600,15001-15006 -Pn --min-rate 1000 192.168.255.119
#    Should Be Equal    ${stdout}     ${output}
#    Perform NMAP Port scan for Secondary LMP
#    Perform NMAP Port scan for Secondary Mplane
#    Perform Recommissioning     dut=chained_bts     type=param      param_path=FEATCADM-1:actCli    value=true
     ...    operation=update       timeout=120        alias=secondary
#    Perform NMAP Port scan for Secondary Mplane after enabling actcli
#    Perform NMAP Port scan for Secondary LMP after enabling actcli
    Setup Remote Access  remote_device=Secondarybts
    ${output}=         Remote Command Execute      command=nmap -oN - -p 22,80,443,3600,15001-15006 -Pn --min-rate 1000 192.168.255.119
        Should Match Regexp   '${output}'   443\\/tcp\\s*open\\s*https
        Should Match Regexp   '${output}'   3600\\/tcp\\s*filtered\\s*trap-daemon
        Should Match Regexp   '${output}'   80\\/tcp\\s*filtered\\s*http

#    Should Be Equal    ${stdout}     ${output}

#######enabling cli on primary####
    Perform Recommissioning     type=param      param_path=FEATCADM-1:actCli    value=true       operation=update        timeout=120
#    Perform NMAP Port scan for Mplane after enabling actcli
    Perform NMAP Port scan for LMP after enabling actcli


*** Keywords ***

Verify ssh login
        Setup Remote Access    remote_device=bts
#        ${stdout}       Remote Command Execute      command=${cmd}
#        Set Suite Variable          ${stdout}
        [Teardown]      Teardown remote Access

#Perform NMAP Port scan for Mplane
#    ${rc}  ${output}=    Run and Return Rc And Output   nmap -oN - -p 22,80,443,3600,15001-15006 -Pn --min-rate 1000 ${ipv4_ip}
#    Sleep       30
#    Log     ${output}
#    Should Match Regexp   '${output}'   443\\/tcp\\s*open\\s*https
#    Should Match Regexp   '${output}'   3600\\/tcp\\s*filtered\\s*trap-daemon
#    Should Match Regexp   '${output}'   80\\/tcp\\s*filtered\\s*http

Perform NMAP Port scan for LMP
    ${rc}  ${output}=    Run and Return Rc And Output   nmap -oN - -p 22,80,443,3600,15001-15006 -Pn --min-rate 1000 ${LMP_ip}
    Sleep       30
    Log     ${output}
    Should Match Regexp   '${output}'   443\\/tcp\\s*open\\s*https
    Should Match Regexp   '${output}'   3600\\/tcp\\s*filtered\\s*trap-daemon
    Should Match Regexp   '${output}'   80\\/tcp\\s*filtered\\s*http

#Perform NMAP Port scan for Mplane after enabling actcli
#    ${rc}  ${output}=    Run and Return Rc And Output   nmap -oN - -p 22,80,443,3600,15001-15006 -Pn --min-rate 1000 ${ipv4_ip}
#    Sleep       30
#    Log     ${output}
#    Should Match Regexp   '${output}'   443\\/tcp\\s*open\\s*https
#    Should Match Regexp   '${output}'   3600\\/tcp\\s*open\\s*trap-daemon
#    Should Match Regexp   '${output}'   80\\/tcp\\s*filtered\\s*http

Perform NMAP Port scan for LMP after enabling actcli
    ${rc}  ${output}=    Run and Return Rc And Output   nmap -oN - -p 22,80,443,3600,15001-15006 -Pn --min-rate 1000 ${LMP_ip}
    Sleep       30
    Log     ${output}
    Should Match Regexp   '${output}'   443\\/tcp\\s*open\\s*https
    Should Match Regexp   '${output}'   3600\\/tcp\\s*open\\s*trap-daemon
    Should Match Regexp   '${output}'   80\\/tcp\\s*filtered\\s*http

#Perform NMAP Port scan for Secondary LMP
#    ${rc}  ${output}=    Run and Return Rc And Output   nmap -oN - -p 22,80,443,3600,15001-15006 -Pn --min-rate 1000 ${remote_lmp_ip}
#    Sleep       30
#    Log     ${output}
#    Should Match Regexp   '${output}'   443\\/tcp\\s*open\\s*https
#    Should Match Regexp   '${output}'   3600\\/tcp\\s*filtered\\s*trap-daemon
#    Should Match Regexp   '${output}'   80\\/tcp\\s*filtered\\s*http

#Perform NMAP Port scan for Secondary LMP after enabling actcli
#    ${rc}  ${output}=    Run and Return Rc And Output   nmap -oN - -p 22,80,443,3600,15001-15006 -Pn --min-rate 1000 ${remote_lmp_ip}
#    Sleep       30
#    Log     ${output}
#    Should Match Regexp   '${output}'   443\\/tcp\\s*open\\s*https
#    Should Match Regexp   '${output}'   3600\\/tcp\\s*open\\s*trap-daemon
#    Should Match Regexp   '${output}'   80\\/tcp\\s*filtered\\s*http

#Pump ICMP Packets
#        Run Keyword And Ignore Error      Capture ipv4 packets      ping -c 20 -I ${srcipv4_1} ${dstipv4_1}
#        Run Keyword And Ignore Error      Capture ipv4 packets      ping -c 20 -I ${srcipv4_2} ${dstipv4_2}
#        Run Keyword And Ignore Error      Capture ipv4 packets      ping -c 20 -I ${srcipv4_3} ${dstipv4_3}
#        Run Keyword And Ignore Error      Capture ipv4 packets      ping -c 20 -I ${srcipv4_4} ${dstipv4_4}
#        Run Keyword And Ignore Error      Capture ipv4 packets      ping -c 20 -I ${srcipv4_6} ${dstipv4_6}
#        Run Keyword And Ignore Error      Capture ipv4 packets      ping -c 20 -I ${srcipv4_5} ${dstipv4_5}
#        Run Keyword And Ignore Error      Capture ipv4 packets      ping -c 20 -I ${srcipv4_1} ${dstipv4_7}

