*** Settings ***
Documentation
... 	[Procedure]				"The test case performs commissioning and verifies config of SSH port number using WebEM. Firewall rules also verified."
...	    [Date]					"26-10-2022"
...	    [Author]				"Punith"
...	    [Feature_ID] 			"CB007160"
... 	[Maintenance]			"TRS I & V Tools Bangalore Team"
...	    [Funtion_Hash_Tags] 	"E2LINK_RIC"
...	    [Validated_TestLine] 	"CLOUD_5G - ASIB, ASIL, ASIK, ASIM, ASOE topologies"
...	    [Precondition] 			"BTS should be operational and configured state"
...	    [QC_Path]               "QC_Path in Test Plan"
...	    [QC_ID]					"QC_ID in Test Lab for reporting"

Variables		ta_e2e_bts_trs_fw
Resource		taf/rfrl/trs_e2e_fw/setup/framework.robot

*** Variables ***
${tc_variables}     testcase_variables.json

*** Keywords ***
SSH Login should Pass
	Setup Remote Access    remote_device=bts
    [Teardown]		Teardown remote Access

SSH Login should fail
    Setup Remote Access    remote_device=bts
    Run Keyword And expect error  *SSHClientException: timed out*      Command to execute on board_R      iptables -nvL
   [Teardown]		Teardown remote Access

Deleting SSH port number
    Perform Recommissioning     type=param   param_path=SECADM-1:sshPortNumber       operation=delete       value=default timeout=200

Perform software upgrade
    [Arguments]     ${PORT}

    ${Active_SW_version}    ${passive_SW_version}=  Get Sw Version
     Setup Remote Access     remote_device=bts      port=${PORT}
     ${build_version}=       Remote Command Execute
     ...    command=cd /ffs/run/; ls -ltr | grep -i TargetBD | head -1 | awk '{print $9}' | cut -c -39 | cut -d_ -f 2-6
     Set Suite Variable      ${build_version}
    [Teardown]      Teardown remote Access
    @{active_release}=      Split String From Right     ${Active_SW_version}            _       max_split=2
     Run Keyword If  '${active_release[0]}' == 'SBTS23R2_ENB_9999'        PerformSoftware Download And Update    wft_profile=sbtstrunk_00
     ...    timeout=1600		        ELSE    Perform Software Download And Update    wft_profile=branch_SBTS23R1  timeout=1600
     Sleep  300
Command to execute on board
    [Arguments]      ${command}
    ${default_rule}=    Remote Command Execute      command=${command}
    Should Be Equal     ${default_rule}     1

Verify firewall rules with changing port
    [Arguments]     ${PORT}
    Perform Recommissioning     type=param  param_path=SECADM-1:sshPortNumber       operation=update    value=${PORT}    timeout=200
    Verify firewall rules   ${PORT}

Verify firewall rules
    [Arguments]     ${PORT}
    Setup Remote Access    remote_device=bts    port=${PORT}
    Run Keyword      Command to execute on board      nft list chain ip filter LIMIT_ETH_SECURITY| grep 'tcp dport { ${PORT} }'| wc -l
    Run Keyword      Command to execute on board      nft list chain ip filter MP_TRAFFIC| grep 'tcp dport { ${PORT} }'| wc -l
    Run Keyword      Command to execute on board      nft list chain ip filter LIMIT_ETH_SECURITY| grep 'tcp dport { ${PORT} }'| wc -l
    [Teardown]      Teardown remote Access

Command to execute on board_R
    [Arguments]      ${command}
    Remote Command Execute      command=${command}

Changing SSH port number fails due to Below range
    ${NPORT}   Evaluate    random.randrange(0,18999)    random
	Run Keyword and expect error        *VALUE_IS_TOO_SMALL*            Perform Recommissioning     type=param  rat=lte
	...     param_path=SECADM-1:sshPortNumber       operation=update    value=${NPORT}    timeout=200
Changing SSH port number fails due to out of range
    ${NPORT}   Evaluate    random.randrange(20000,50000)    random
		Run Keyword and expect error        *VALUE_IS_TOO_BIG*            Perform Recommissioning     type=param  rat=lte
		...     param_path=SECADM-1:sshPortNumber       operation=update    value=${NPORT}    timeout=200
