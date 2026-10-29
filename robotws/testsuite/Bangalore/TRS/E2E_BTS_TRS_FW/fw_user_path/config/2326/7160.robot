*** Settings ***
Documentation
... 	[Procedure]				"The test case performs commissioning and verifies config of SSH port number using WebEM."
...	    [Date]					"06-10-2025"
...	    [Author]				"Parvati"
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
${tc_variables}    /home/ute/MN/UTE/robotws/testsuite/Bangalore/TRS/E2E_BTS_TRS_FW/fw_user_path/testcases/resource/testcase_variables.json

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
#    [Arguments]     ${PORT}

    ${Active_SW_version}    ${passive_SW_version}=  Get Sw Version
#     Setup Remote Access     remote_device=bts      port=${PORT}
      Setup Remote Access     remote_device=bts
     ${build_version}=       Remote Command Execute
     ...    command=cd /ffs/run/; ls -ltr | grep -i TargetBD | head -1 | awk '{print $9}' | cut -c -39 | cut -d_ -f 2-6
     Set Suite Variable      ${build_version}
    [Teardown]      Teardown remote Access
    @{active_release}=      Split String From Right     ${Active_SW_version}            _       max_split=2
     Run Keyword If  '${active_release[0]}' == 'SBTS25R3_ENB_9999'        PerformSoftware Download And Update    wft_profile=sbtstrunk_00
     ...    timeout=1600		        ELSE    Perform Software Download And Update    wft_profile=SBTS25R2  timeout=1600
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
    Run Keyword      Command to execute on board      nft list chain ip filter ETH_SSH_CHAIN| grep 'tcp dport ${PORT}'| wc -l
    Run Keyword      Command to execute on board      nft list chain ip filter MPLANE_SSH_CHAIN| grep 'tcp dport ${PORT}'| wc -l
#    Run Keyword      Command to execute on board      nft list chain ip filter ETH_SSH_CHAIN| grep 'tcp dport ${PORT}'| wc -l
    [Teardown]      Teardown remote Access

Command to execute on board_R
    [Arguments]      ${command}
    Remote Command Execute      command=${command}

Changing SSH port number fails due to Below range
    ${NPORT}   Evaluate    random.randrange(0,18999)    random
	Run Keyword and expect error        *VALUE_IS_TOO_SMALL*            Perform Recommissioning     type=param      param_path=SECADM-1:sshPortNumber
    ...       operation=update    value=${NPORT}    timeout=200
#    Perform Recommissioning     type=param      param_path=SECADM-1:sshPortNumber       operation=update    value=${NPORT}    timeout=200
Changing SSH port number fails due to out of range
    ${NPORT}   Evaluate    random.randrange(20000,50000)    random
    Run Keyword and expect error        *VALUE_IS_TOO_BIG*            Perform Recommissioning     type=param    param_path=SECADM-1:sshPortNumber
    ...       operation=update    value=${NPORT}    timeout=200
#    Perform Recommissioning     type=param      param_path=SECADM-1:sshPortNumber       operation=update    value=${NPORT}    timeout=200
Get Hostname
  [Documentation]    Get hosename of test machine
  ${output}      Run      hostname
  ${Hostname}    Replace String   string=${output}     search_for=-     replace_with=_
  Set Suite variable  ${Hostname}

Link SCOUT SCF to Configuration ID for Reporting
   [Arguments]    ${tl_name_only}

   Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
   ${scout_testline_name}=    Set Variable    ${tl_name_only}
   ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
   ${TC_ID}=    Set Variable      ute:id:${external_scf_id}
   Set Suite Variable  ${external_scf_id}
   Set Tags  ${TC_ID}

Request Scout SCF
  [Arguments]  ${scout_testline_name}
  scout.setup_scout      scout_testline_name=${scout_testline_name}
  ${external_scf_id}=  scout.request_scf       use_scout_internal_id=True
  scout.teardown_scout_api
  [Return]   ${external_scf_id}