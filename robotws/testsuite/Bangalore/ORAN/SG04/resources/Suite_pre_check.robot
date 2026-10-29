*** Settings ***

Documentation   ---SW Download & Update to NR and LTE BTS---
...			     :copyright: Nokia
...              :author:Sudarshan Kanapuram
...              :contact:sudarshan.kanapuram@nokia.com
Library    Process
Library    SSHLibrary
Library    taf.nms.netact
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    ./testsuite/Bangalore/ORAN/SG04/resources/sg04_local_keywords.py

Resource    ./testsuite/Bangalore/ORAN/SG04/resources/collect_logs.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot

Variables      ./testsuite/Bangalore/ORAN/SG04/resources/CRT4_parameters.py

*** Variables ***

${SW_Ver_usr}=     SBTS24R3_ENB_0000_000889_000000
${enb_IP}=    10.58.239.89
${state}=    notSecured
${SW_Ver_lte}=    empty
${is_TrunkBuild1}=    False

*** Keywords ***

BTS SW Download and Update
    [Arguments]    ${lte_bts_upd}=Yes
    coam.setup_admin	bts_host=192.168.255.129
    ${SW_Ver}    coam.get_sw_version
    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${SW_Ver}      _9999_
    ${SW_Ver1}=     Run keyword if
    ...           ${is_Trunk_Build}==True        Replace String Using Regexp    ${SW_Ver}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...  ELSE     Set variable   ${SW_Ver}
    Log to console  \n NR BTS SW Current Ver: ${SW_Ver1} \n
	IF     "${lte_bts_upd}" == "Yes"
	    coam.setup_admin	bts_host=${enb_IP}    name=lte_conn
        ${SW_Ver_L}    coam.get_sw_version    connection=lte_conn
        ${is_TrunkBuild1}=     Run Keyword and Return Status    Should Contain      ${SW_Ver_L}      _9999_
        ${SW_Ver_lte}=     Run keyword if
        ...           ${is_Trunk_Build1}==True        Replace String Using Regexp    ${SW_Ver_L}    ^SBTS[A-Za-z0-9]+_    SBTS00_
        ...  ELSE     Set variable   ${SW_Ver_L}
		Log to console  \n LTE BTS SW Current Ver: ${SW_Ver_L} \n

	END

	IF    "${SW_Ver1}" == "${SW_Ver_usr}" and "${SW_Ver_lte}" == "${SW_Ver_usr}"
	    Log to console  \n NR BTS and LTE BTS Already updated with the Target version: ${SW_Ver_usr} \n
	ELSE IF    "${SW_Ver1}" == "${SW_Ver_usr}" and ("${SW_Ver_lte}" != "${SW_Ver_usr}" and "${SW_Ver_lte}" != "empty")
	    Log to console  \n NR BTS Already updated with the Target version: ${SW_Ver_usr} \n
		Fetch_Required_Enb_SW    Req_Enb_SW_ver=${SW_Ver_usr}    current_bts_SW_ver=${SW_Ver_lte}    is_trunk_build=${is_TrunkBuild1}
		Log to Console     \n --SW_Update Started-- \n
        coam.update_software    ${SW_DESTINATION}/${SW_Ver_usr}_release_BTSSM_downloadable_A54.zip
        ...    should_activate=True    timeout=1600    connection=lte_conn
		Log to console    \n--SW Activation completed, waiting for onAir--\n
		sleep    300s
        Wait for BTS OnAir    conn_1=lte_conn
        Log to console    \n--SW Download and Update Completed--\n
	ELSE IF    ("${SW_Ver_lte}" == "${SW_Ver_usr}" or "${SW_Ver_lte}" == "empty") and "${SW_Ver1}" != "${SW_Ver_usr}"
		IF    "${SW_Ver_lte}" == "empty"
			Log to console  \n LTE BTS SW update NOT selected by user lte_bts_upd: ${lte_bts_upd} \n
		ELSE
			Log to console  \n LTE BTS Already updated with the Target version: ${SW_Ver_lte} \n
		END
		Fetch_Required_Enb_SW    Req_Enb_SW_ver=${SW_Ver_usr}    current_bts_SW_ver=${SW_Ver1}    is_trunk_build=${is_TrunkBuild}
		Log to Console     \n --SW_Update Started-- \n
        coam.update_software    ${SW_DESTINATION}/${SW_Ver_usr}_release_BTSSM_downloadable_A54.zip
        ...    should_activate=True    timeout=1600    connection=default
		Log to console    \n--SW Activation completed, waiting for onAir--\n
		sleep    300s
        Wait for BTS OnAir
        Log to console    \n--SW Download and Update Completed--\n
	ELSE IF    "${SW_Ver1}" != "${SW_Ver_usr}" and ("${SW_Ver_lte}" != "${SW_Ver_usr}" and "${SW_Ver_lte}" != "empty")
	   	Fetch_Required_Enb_SW    Req_Enb_SW_ver=${SW_Ver_usr}    current_bts_SW_ver=${SW_Ver1}    is_trunk_build=${is_TrunkBuild}
	   	Fetch_Required_Enb_SW    Req_Enb_SW_ver=${SW_Ver_usr}    current_bts_SW_ver=${SW_Ver_lte}    is_trunk_build=${is_TrunkBuild1}
		Log to Console     \n --SW_Update Started-- \n
        coam.update_software    ${SW_DESTINATION}/${SW_Ver_usr}_release_BTSSM_downloadable_A54.zip
        ...    should_activate=True    timeout=1600    connection=default
		coam.update_software    ${SW_DESTINATION}/${SW_Ver_usr}_release_BTSSM_downloadable_A54.zip
        ...    should_activate=True    timeout=1600    connection=lte_conn
		Log to console    \n--SW Activation completed, waiting for onAir--\n
		sleep    300s
        Wait for BTS OnAir
        Wait for BTS OnAir    conn_1=lte_conn
        Log to console    \n--SW Download and Update Completed--\n
	END
    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    Integrate MRBTS from MantaRay
    coam.teardown_all_aliases_for_admin


BTS SW Download and Update old
    coam.setup_admin	bts_host=192.168.255.129
    ${SW_Ver}    coam.get_sw_version
    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${SW_Ver}      _9999_
    ${SW_Ver1}=     Run keyword if
    ...           ${is_Trunk_Build}==True        Replace String Using Regexp    ${SW_Ver}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...  ELSE     Set variable   ${SW_Ver}
    Log to console  \n BTS_SW_Ver_usr: ${SW_Ver1} \n
    Run Keyword If    "${SW_Ver1}" == "${SW_Ver_usr}"	Log to console  \n BTS Already updated with the Target version: ${SW_Ver_usr} \n
    ...    ELSE    Fetch_Required_Enb_SW    Req_Enb_SW_ver=${SW_Ver_usr}    current_bts_SW_ver=${SW_Ver1}
    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    Log to Console     \n --SW_Update Started-- \n
    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    coam.update_software   ${SW_DESTINATION}/${SW_Ver_usr}_release_BTSSM_downloadable.zip
    ...    should_activate=True    timeout=1600    connection=default    should_reset_radios=True
#    sleep    900s
#    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    Wait for BTS OnAir
    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    sleep    300s
    Wait for BTS OnAir
    Log to console    \n--SW Download and Update Completed--\n
    coam.teardown_admin
    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    Check and Intergrate MantaRay

LTE BTS SW Download and Update
    coam.setup_admin	bts_host=10.58.239.89
    ${SW_Ver}    coam.get_sw_version
    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${SW_Ver}      _9999_
    ${SW_Ver1}=     Run keyword if
    ...           ${is_Trunk_Build}==True        Replace String Using Regexp    ${SW_Ver}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...  ELSE     Set variable   ${SW_Ver}
    Log to console  \n BTS_SW_Ver_usr: ${SW_Ver1} \n
    Run Keyword If    "${SW_Ver1}" == "${SW_Ver_usr}"	Log to console  \n BTS Already updated with the Target version: ${SW_Ver_usr} \n
    ...    ELSE    Fetch_Required_Enb_SW    Req_Enb_SW_ver=${SW_Ver_usr}    current_bts_SW_ver=${SW_Ver1}
    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    Log to Console     \n --SW_Update Started-- \n
    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    coam.update_software   ${SW_DESTINATION}/${SW_Ver_usr}_release_BTSSM_downloadable.zip
    ...    should_activate=True    timeout=1600    connection=default    should_reset_radios=True
#    sleep    900s
#    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    Wait for BTS OnAir
    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    sleep    300s
    Wait for BTS OnAir
    Log to console    \n--SW Download and Update Completed--\n

    coam.teardown_admin

Integrate MRBTS from MantaRay
    Log to console      \n--Integrate MRBTS with MantaRay NM -- \n
    ###coam.setup_admin	bts_host=192.168.255.129    port=${btsport}    username=${bts_uname}    password=${bts_pwd}
    ###...    use_ssl=${True}    update_interval=5000    name=default

    ${nms_state}=    coam.get_nms_state    timeout=10    connection=default    detailed_output=${FALSE}
    Log to console   \n ${nms_state} \n
    ${v1}=    Get From List	${nms_state}	0
    ${state_check1}=    Get From Dictionary    ${v1}    uplinkToNMS
    ${state_check2}=    Get From Dictionary    ${v1}    downlinkFromNMS
    Log to console   \n--uplinkToNMS: ${state_check1} \n
    Log to console   \n--downlinkFromNMS: ${state_check2} \n

    ###coam.teardown_admin    connection=default
    Run Keyword If    '${state_check1}' != '${state}' and '${state_check2}' != '${state}'    Check and Intergrate MantaRay
    ...    ELSE    Log to console    \n-- MRBTS integrated with MantaRay NM --\n


Check and Intergrate MantaRay
    Log to console   --\nIntegrate MRBTS with MantaRay NM \n--
    ###coam.setup_admin	bts_host=192.168.255.129    port=${btsport}    username=${bts_uname}    password=${bts_pwd}
    ###...    use_ssl=${True}    update_interval=5000    name=default
    ${nms_state}=    coam.get_software_info    timeout=10    connection=default
    ${nms_state}=    coam.get_nms_state    timeout=10    connection=default    detailed_output=${FALSE}
    Log to console   \n ${nms_state} \n
    Log to console   --\n Open SSH to BTS & remove ne3s file \n--
    Open Connection    192.168.255.129
    ${output}=    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${output}=    SSHLibrary.Execute Command    rm /rom/config/ne3sadapt/configs/ne3sadaptdata.db
    ${output}=    SSHLibrary.Execute Command    exit
    Close Connection
    coam.reset    reset_coverage=Site    wait_for_reconnection=${TRUE}    timeout=300    connection=default
    Log to console   --\n waiting for BTS onair \n--
    Wait for BTS OnAir
    ${sw_version}=    coam.get_sw_version
    ${mo_release}=    Fetch From Left    ${sw_version}    _ENB
    MantaRay Precondition
    ${integration_output}=    Integrate MRBTS With Netact    release=${mo_release}
    ...    mr=MRC-COMMON1/MR-COMMON1
    ...    mrbts_address=${btshost}    dist_name=${DIST_NAME}
    ...    security_mode=no TLS    alias=${NETACT_NAME}
    #Log    \n${integration_output}    console=${TRUE}
    MantaRay Postcondition
    ###coam.teardown_admin    connection=default
    Log to console   --\n MRBTS integrated with MantaRay NM \n--

MantaRay Precondition
    Add Node    cmwas    ${NetAct_host}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}
    ${web_url}=    Detect WEB URL    alias=${NETACT_NAME}
    Add WEB URL    ${web_url}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}

MantaRay Postcondition
    Delete Node    cmwas    alias=${NETACT_NAME}
    Clean All    alias=${NETACT_NAME}

Wait for BTS OnAir
    [Arguments]    ${conn_1}=default
    Log to console      \nWaiting for BTS to be OnAir
    FOR    ${a}    IN RANGE    1    15
        ${bts_status}=    coam.get_bts_statuses    connection=${conn_1}
        Exit For Loop IF    '${bts_status["proceduralState"]}'=='OnAir'
        Sleep    2m    reason=Wait for BTS status OnAir
    END
    ${bts_status}    coam.get_bts_statuses    connection=${conn_1}
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}
