*** Settings ***
Documentation
...     [Documentation]
...     [Author]                        "Pavithra"
...     [Function_Hash_Tags]            "CB015352"

#variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
#Resource        ${CURDIR}/resources/common_keywords.robot
Library        taf.sw.scout    WITH NAME   scout
Suite Setup     Run Keywords  Setup Oamops
...    AND     Setup Oamops     dut=chained_bts_2006_new     alias=target
Suite Teardown  Run Keywords    Teardown Oamops
...    AND     Teardown Oamops     dut=chained_bts_2006_new     alias=target


***Test Cases***
[1]CB015352_Verification_of_alarm_grouping_for_DPD_IKEAUTH_X2_classical_to_classical
       Get Scout configuration
       Log to Console    Started Execution
       Perform Commissioning       scf_file=${Source_Base_scfc_CB015352}     verify_bts_status=False     timeout=400
       Perform Commissioning       scf_file=${Target_Base_scfc_CB015352}     verify_bts_status=False     timeout=400    alias=target
       Sleep    300
        Setup Ems  config_device=netact_1042   alias=lab1042
        Cm Upload   config_device=netact_1042   alias=lab1042
#Enable Xmesh Feature at source BTS
       Configuration Manage    config_device=netact_1042   config=${ACTENDCAUTOX2SETUP_TRUE}  plan_name=iv_fw_plan    delete_plan=${True}
    ...    should_provision=True       alias=lab1042
       Configuration Manage    config_device=netact_1042   config=${ACTENDCAUTOX2SETUPSBTS_TRUE}  plan_name=iv_fw_plan    delete_plan=${True}
    ...    should_provision=True       alias=lab1042
       Perform Recommissioning    dut=bts    type=param    param_path=${param_path_16}   operation=update    value=MRBTS-2004/TNLSVC-1/IPSECTEMPLATE-1
    ...    timeout=300
       ${4g_cplane1_ipv4}=     Get Parameter    param_path=${4g_cPlane_ipv4_moc_path}    dut=bts     timeout=300    str_format=True
       Set Suite Variable    ${4g_cplane1_ipv4}    ${4g_cplane1_ipv4}
       ${4g_uplane1_ipv4}=     Get Parameter    param_path=${4g_uPlane_ipv4_moc_path}    dut=bts     timeout=300    str_format=True
       Set Suite Variable    ${4g_uplane1_ipv4}    ${4g_uplane1_ipv4}
       ${5g_cplane1_ipv4}=    Get Parameter    param_path=${5g_nsa_x2cplane1_ipv4_moc_path}    dut=bts    alias=target   timeout=300  str_format=True
       Set Suite Variable    ${5g_cplane1_ipv4}    ${5g_cplane1_ipv4}
       ${5g_uplane1_ipv4}=    Get Parameter    param_path=${5g_nsa_x2uplane1_ipv4_moc_path}    dut=bts    alias=target   timeout=300  str_format=True
       Set Suite Variable    ${5g_uplane1_ipv4}    ${5g_uplane1_ipv4}
       Perform Recommissioning     type=delta    delta_file=${lnadjgnb_addition_2006}     timeout=60
       sleep    30
       Verify ANR status
       Perform Recommissioning    dut=bts    type=param    param_path=MRBTS-2006/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1:authenticationScheme
    ...    operation=update    value=PSK    timeout=300    alias=target
        Sleep    180
        Verify Alarm    faultid=${61644_ALARM}
        Verify Ems Alarm   config_device=netact_1042   faultid=${61644_ALARM}  occurrences=1  alias=lab1042
        [Teardown]      Teardown Ems  config_device=netact_1042  alias=lab1042
***Keywords***
Verify ANR status
       ${x2linkstatus}=   Get Parameter    param_path=MRBTS-2004/LNBTS-2004/LNADJGNB-10:x2ToGnbLinkStatus
       Should Be Equal    ${x2linkstatus}       available

Get Scout configuration
    Get Hostname
    Link SCOUT SCF to Configuration ID for Reporting        ${Hostname}

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
  scout.setup_scout     scout_testline_name=${scout_testline_name}
  ${external_scf_id}=   scout.request_scf    use_scout_internal_id=True
  scout.teardown_scout_api
  [Return]   ${external_scf_id}