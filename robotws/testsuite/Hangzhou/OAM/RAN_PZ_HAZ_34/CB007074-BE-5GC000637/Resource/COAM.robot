*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   Common.robot

*** Variables ***


*** Keyword ***
COAM Login Local
    COAM Login
    ...   bts_host=${LOCAL_WEBUI_ADDR}
    ...   username=${LOCAL_WEBUI_USER}
    ...   password=${LOCAL_WEBUI_PWD}
    ...   alias=LOCAL

COAM Logout Local
    COAM Logout   connection=LOCAL

COAM Login Peer
    COAM Login
    ...   bts_host=${PEER_WEBUI_ADDR}
    ...   username=${PEER_WEBUI_USER}
    ...   password=${PEER_WEBUI_PWD}
    ...   alias=PEER

COAM Logout Peer
    COAM Logout   connection=PEER

Change Administrative Status
    [Arguments]   ${connection}   ${status}
    COAM Update Parameter
    ...   dist_name=${${connection}_ADJGNB_DN}
    ...   parameter=administrativeState
    ...   value=${status}
    ...   connection=${connection}

Check XN Link Status
    [Arguments]   ${connection}   ${xn_status}
    COAM Backup Full SCF   connection=${connection}   file_name=full_commission_${connection}.xml
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission_${connection}.xml
    ${xn_status}   XML.Get Element Text   ${scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:XNLINK"]/p[@name="xnLinkStatus"]
    Should Be Equal   ${xn_status}   ${xn_status}

Check Fault 7311 Cleared
    [Arguments]   ${connection}
    ${active_alarms}   taf_coam.COAM Get Active Alarms   connection=${connection}
    FOR   ${active_alarm}   IN   @{active_alarms}
       Should Not Be Equal As Strings   ${active_alarm['faultId']}   7311
    END

Check Fault 7311 Raised
    [Arguments]   ${connection}
    ${active_alarms}   taf_coam.COAM Get Active Alarms   connection=${connection}
    ${fault_status}   Set Variable   clear
    FOR   ${active_alarm}   IN   @{active_alarms}
       ${fault_status}   Set Variable If
        ...   '${active_alarm['faultId']}'=='7311'   raise
        ...   '${active_alarm['faultId']}'!='7311'   ${fault_status}
       Exit For Loop If   '${active_alarm['faultId']}'=='7311'
    END
    Should Be Equal   ${fault_status}   raise

Remove NRADJGNB Object
    [Arguments]   ${connection}
    ${delta_file}   Set Variable   [{"distName": "${${connection}_ADJGNB_DN}", "operation": "delete", "parameters": []}]
    COAM Perform Delta Recommission
    ...   delta_file=${delta_file}
    ...   connection=${connection}

Create NRADJGNB Object
    [Arguments]   ${connection}   ${gnb_release}
    ${adj}   Set Variable If
    ...   '${connection}'=='LOCAL'   PEER
    ...   '${connection}'=='PEER'   LOCAL
    ${xnlinkref}   Set Variable   ${${connection}_XN_DN.split('-')[-1]}

    ${param1}   Set Variable   {"parameterName": "administrativeState", "value": "Unlocked", "operation": "update"}
    ${param2}   Set Variable   {"parameterName": "gNbIdLength", "value": ${${adj}_GNBIDLENTH}, "operation": "update"}
    ${param3}   Set Variable   {"parameterName": "gNodeBId", "value": ${${adj}_NRBTS_ID}, "operation": "update"}
    ${param4}   Set Variable   {"parameterName": "xnLinkRef", "value": ${xnlinkref}, "operation": "update"}
    ${param5}   Set Variable
    ...   {"parameterName":"gnbPlmn","value":[{"mcc":${${adj}_MCC},"mnc":${${adj}_MNC},"mncLength":${${adj}_MNCLENGTH}}],"operation":"update"}
    ${param6}   Set Variable   {"parameterName": "gNodeBIdCtrl", "value": "oamControlled", "operation": "update"}

    ${parameters}   Set Variable If   '${gnb_release}'>'SBTS22R3'   [${param1}, ${param2}, ${param3}, ${param4}, ${param5}, ${param6}]
    ...   [${param1}, ${param2}, ${param3}, ${param4}, ${param5}]

    ${delta_file}   Set Variable   [{"distName": "${${connection}_ADJGNB_DN}", "operation": "create", "parameters": ${parameters}}]
    COAM Perform Delta Recommission
    ...   delta_file=${delta_file}
    ...   connection=${connection}

Check NR XN Counters
    [Arguments]   ${counter_dict}   ${connection}
#    ${counters}   Set Variable    @{counter_dict.keys()}
    @{counters}   Create List    @{counter_dict.keys()}
    ${length}    Get Length    ${counters}
    ${counters_comma}   Set Variable   ${counters[0]}
    FOR   ${i}    IN RANGE    1   ${length}
       ${counters_comma}   Set Variable   ${counters_comma},${counters[${i}]}
    END
    ${return_msg}   coam.get_pm_counters   couter_ids=${counters_comma}   timeout=${60}   connection=${connection}
    FOR   ${counter}   IN   @{counters}
       ${counter_detail}   Set Variable   ${return_msg['BTS']['BTS']['NRBTS-${${connection}_NRBTS_ID}']['NXNCB']['${counter}']}
       ${return_max}   ${return_sec_max}   Get Max Values   counters=${counter_detail}
#       Should Be Equal As Strings   ${return_max}   ${counter_dict['${counter}']}
       Should Be true   ${return_max} + ${return_sec_max} >= ${counter_dict['${counter}']}
    END

Get Max Values
    [Arguments]   ${counters}
    ${max}   Set Variable   ${0}
    ${sec_max}   Set Variable   ${0}
    FOR   ${key}   IN   @{counters.keys()}
        ${max}   Set Variable If
        ...   int(${key})>${max}   ${key}
        ...   int(${key})<${max}   ${max}
    END

    FOR   ${key}   IN   @{counters.keys()}
        ${sec_max}   Set Variable If
        ...   int(${key})>${sec_max} and int(${key})<${max}   ${key}
        ...   ${sec_max}
#        ...   int(${key})<=${sec_max} or int(${key})>=${max}   ${sec_max}
    END

    ${return_max}   set variable   ${counters['${max}']}
    ${return_sec_max}   set variable   ${counters['${sec_max}']}
    [Return]   ${return_max}   ${return_sec_max}

Change XN Setup Retry Time
    [Arguments]   ${connection}   ${retry_time}
    COAM Update Parameter
    ...   dist_name=${${connection}_DIST_NAME}
    ...   parameter=maxNumXnSetupRetry
    ...   value=${retry_time}
    ...   connection=${connection}

Change XN Setup Tmr
    [Arguments]   ${connection}   ${tmr}
    COAM Update Parameter
    ...   dist_name=${${connection}_DIST_NAME}
    ...   parameter=retryXnSetupTmr
    ...   value=${tmr}
    ...   connection=${connection}

Check XN Link Status by WebEM
    [Arguments]   ${url}   ${username}   ${password}   ${xn_status}   ${BTS}
    COAM WEBUI Login   url=https://${url}    username=${username}   password=${password}
    ${xn_status_web}   selenium_coam.get_parameter_value  dist_name=MRBTS-${BTS}/NRBTS-${BTS}/XNLINK-1
    ...   filter_param=XnC link status
    Should Be Equal   ${xn_status_web}   ${xn_status}
    [Teardown]   Run Keyword And Ignore Error   COAM WEBUI Logout

Get nrCellIdentity from gNB and Convert to HEX
    [Arguments]   ${url}   ${username}   ${password}   ${BTS}
    COAM WEBUI Login   url=https://${url}    username=${username}   password=${password}
    ${nrcell_id}   selenium_coam.get_parameter_value  dist_name=MRBTS-${BTS}/NRBTS-${BTS}/NRCELL-1
    ...   filter_param=NR Cell Identity
    ${convert_nrcell_id}   convert to hex   ${nrcell_id}
    [Return]   ${convert_nrcell_id}
    [Teardown]   Run Keyword And Ignore Error   COAM WEBUI Logout

COAM Wait XNLINK Status Available
    ${LOCAL_XN_STATUS}   Run Keyword And Return Status   Check XN Link Status by WebEM
    ...   url=${LOCAL_WEBUI_ADDR}   username=${LOCAL_WEBUI_USER}   password=${LOCAL_WEBUI_PWD}   xn_status=available   BTS=${LOCAL_MRBTS_ID}
    ${PEER_XN_STATUS}   Run Keyword And Return Status   Check XN Link Status by WebEM
    ...   url=${PEER_WEBUI_ADDR}   username=${PEER_WEBUI_USER}   password=${PEER_WEBUI_PWD}   xn_status=available   BTS=${PEER_MRBTS_ID}
    run keyword if  not ${LOCAL_XN_STATUS} and ${PEER_XN_STATUS}   COAM Reset Site And Wait XNLINK Status Available

COAM Reset Site And Wait XNLINK Status Available
    Run Keyword And Ignore Error   COAM Reset Site   wait_for_reconnection=${False}   connection=LOCAL
    Run Keyword And Ignore Error   COAM Reset Site   wait_for_reconnection=${False}   connection=PEER
    Run Keyword And Ignore Error   COAM Logout Local
    Run Keyword And Ignore Error   COAM Logout Peer
    Wait Until Keyword Succeeds   20m   1m   COAM Login Peer
    Wait Until Keyword Succeeds   20m   1m   COAM Login Local
    Wait Until Keyword Succeeds   20m   3m   Check XN Link Status by WebEM
    ...   url=${LOCAL_WEBUI_ADDR}   username=${LOCAL_WEBUI_USER}   password=${LOCAL_WEBUI_PWD}   xn_status=available   BTS=${LOCAL_MRBTS_ID}
    Wait Until Keyword Succeeds   20m   3m   Check XN Link Status by WebEM
    ...   url=${PEER_WEBUI_ADDR}   username=${PEER_WEBUI_USER}   password=${PEER_WEBUI_PWD}   xn_status=available   BTS=${PEER_MRBTS_ID}

Add XNLINK and NRADJGNB by WebEM Local
    Add XNLINK and NRADJGNB by WebEM   url=${LOCAL_WEBUI_ADDR}   username=${LOCAL_WEBUI_USER}   password=${LOCAL_WEBUI_PWD}   BTS=${LOCAL_MRBTS_ID}
    ...   opp_url=${PEER_WEBUI_ADDR}   gnb_id=${PEER_MRBTS_ID}   gnb_len=${peer_gnbidlenth}   mcc=${peer_mcc}   mnc=${peer_mnc}
    ...   mnc_len=${peer_mnclength}   connection=LOCAL

Add XNLINK and NRADJGNB by WebEM Peer
    Add XNLINK and NRADJGNB by WebEM   url=${PEER_WEBUI_ADDR}   username=${PEER_WEBUI_USER}   password=${PEER_WEBUI_PWD}   BTS=${PEER_MRBTS_ID}
    ...   opp_url=${LOCAL_WEBUI_ADDR}   gnb_id=${LOCAL_MRBTS_ID}   gnb_len=${local_gnbidlenth}   mcc=${local_mcc}   mnc=${local_mnc}
    ...   mnc_len=${local_mnclength}   connection=PEER

Add XNLINK and NRADJGNB by WebEM
    [Arguments]   ${url}   ${username}   ${password}   ${BTS}   ${opp_url}   ${gnb_id}   ${gnb_len}   ${mcc}   ${mnc}   ${mnc_len}   ${connection}
    ${Return_XNLINK}   coam.Get Managed Objects  class_name=XNLINK_A   connection=${connection}
    ${Return_NRADJGNB}   coam.Get Managed Objects  class_name=NRADJGNB_A   connection=${connection}
    COAM WEBUI Login   url=https://${url}    username=${username}   password=${password}
    run keyword if   "${Return_XNLINK}" == "[]"   Add XNLINK and NRADJGNB   opp_url=${opp_url}   BTS=${BTS}   gnb_id=${gnb_id}
    ...   gnb_len=${gnb_len}   mcc=${mcc}   mnc=${mnc}   mnc_len=${mnc_len}
    [Teardown]   Run Keyword And Ignore Error   COAM WEBUI Logout

Add XNLINK and NRADJGNB
    [Arguments]   ${opp_url}   ${BTS}   ${gnb_id}   ${gnb_len}   ${mcc}   ${mnc}   ${mnc_len}
    COAM WEBUI Add Object With Close Startup View window Retry   object_name=MRBTS-${BTS}/NRBTS-${BTS}
    ...   object_class_name=XNLINK   id_value=1   is_load_default_values=${true}
    selenium_coam.set_parameter_value
	...   dist_name=MRBTS-${BTS}/NRBTS-${BTS}/XNLINK-1
	...   filter_param=C-Plane IPv4/v6 address
	...   new_value=${opp_url}
	COAM WEBUI Add Object With Close Startup View window Retry   object_name=MRBTS-${BTS}/NRBTS-${BTS}
    ...   object_class_name=NRADJGNB   id_value=1   is_load_default_values=${true}
    selenium_coam.set_parameter_value
	...   dist_name=MRBTS-${BTS}/NRBTS-${BTS}/NRADJGNB-1
	...   filter_param=Administrative state
	...   new_value=Unlocked
	selenium_coam.set_parameter_value
	...   dist_name=MRBTS-${BTS}/NRBTS-${BTS}/NRADJGNB-1
	...   filter_param=gNB id length
	...   new_value=${gnb_len}
	selenium_coam.set_parameter_value
	...   dist_name=MRBTS-${BTS}/NRBTS-${BTS}/NRADJGNB-1
	...   filter_param=gNodeB Id
	...   new_value=${gnb_id}
	selenium_coam.add_element
	...   dist_name=MRBTS-${BTS}/NRBTS-${BTS}/NRADJGNB-1
	...   filter_param=PLMN of Global gNB Id
	selenium_coam.set_parameter_value
	...   dist_name=MRBTS-${BTS}/NRBTS-${BTS}/NRADJGNB-1
	...   filter_param=MCC of PLMN ID in Global gNB ID
	...   new_value=${mcc}
	selenium_coam.set_parameter_value
	...   dist_name=MRBTS-${BTS}/NRBTS-${BTS}/NRADJGNB-1
	...   filter_param=MNC of PLMN ID in Global gNB ID
	...   new_value=${mnc}
	selenium_coam.set_parameter_value
	...   dist_name=MRBTS-${BTS}/NRBTS-${BTS}/NRADJGNB-1
	...   filter_param=MNC length of PLMN ID in Global gNB ID
	...   new_value=${mnc_len}
	selenium_coam.set_parameter_value
	...   dist_name=MRBTS-${BTS}/NRBTS-${BTS}/NRADJGNB-1
	...   filter_param=Xn link reference
	...   new_value=1
    Validate and Activate Plan

Validate and Activate Plan
    COAM WEBUI Whether Close Start Up View Window
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=120
    Sleep   10s
    COAM WEBUI Whether Close Start Up View Window
