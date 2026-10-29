*** Settings ***
Documentation    CNI131778_Verification of OFEGSA RU is getting detected by the BTS with new product code
Library     OperatingSystem     WITH NAME    os
Library     Collections
Library     taf.sbts.oam.coam.admin    WITH NAME    COAM
Library     taf.analyzer.netconf
Library     taf.collectors.simple    WITH NAME    simple
Library     taf.collectors.core    WITH NAME    CORE
Library     DateTime
Library     taf.sw.dcap.rd   WITH NAME   rd
Library     taf.config.scf.interface.scf     WITH NAME    scf
Library     taf.sw.scout    WITH NAME    scout
Library     taf.fdsw.rc  WITH NAME   fdsw
Library     taf.transport.ssh


Library     ./testsuite/Bangalore/ORAN/SG04/resources/deletefiles.py
Library     ./testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library     ./testsuite/Bangalore/ORAN/SG04/resources/sg04_local_keywords_CNI.py
Library     ./testsuite/Bangalore/ORAN/SG04/resources/Common_script.py

Resource    ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/alarm.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/Common_resource.robot

Variables   ./testsuite/Bangalore/ORAN/SG04/resources/CRT4_parameters.py

Test Setup      Preconditions
Test Teardown   Test teardown

*** Variables ***
&{[1]Verify RU is detected by the BTS with new FJT SW and new BTS SW which are upgraded via WebEM.}
...    QC_ID_FL00=QC_130985    QC_ID_SBTS25R2=QC_140916

@{capabilities}    	    	   Legacy_3
@{UE_alias}       		       UE3
@{direction_ul}    		       ul
@{direction_dl}    		       dl
@{data_transfer_protocol}          UDP
&{default_user}=    defaultNetconfAccountName=fjncuser0
...                 defaultNetconfAccountPwd=ncCl2fjRu+autH0
&{authentication}=        id=1    defaultNetconfAccount=&{default_user}
@{sudo_list}=        &{authentication}

*** Test Cases ***
[1]Verify RU is detected by the BTS with new FJT SW and new BTS SW which are upgraded via WebEM.
    [Tags]    TRUNK_SG04	CNI131    QCD_MN_RAN    QCP_RAN_VRF
    [Teardown]    run keywords
     ...      Test teardown        AND    Set QC_Tag
    Link SCOUT SCF to Configuration ID for Reporting    tl_name_only=${scout_id2}
    Step5:FJT Software upgrade to newPC without O-RU reset
    Step7:Verify NewProdCode and FJT SW version
    Step8:Verify BBMOD LANE and ORU Lock Unlock

*** Keywords ***

Preconditions
    Log to console    \n --Test setup started--\n
    COAM.setup_admin	bts_host=${LTE_BTS_IP}
    Check BTS is OnAir
	delete_files_netconf    host=${LTE_BTS_IP}
    Log to console   \n--DCAP Started --\n
    #${trace_id}    DCAP Start
    #Set global variable    ${trace_id}
    Log to console    \n --Alarm Validation Started--\n
    ${Pre_Active_Alarm}=    taf.sbts.oam.coam.admin.Get Active alarms
    ${allowed_alarms}=    Expected_alarm
    Verify Active Alarm Is In List    ${Pre_Active_Alarm}    ${allowed_alarms}
    Log To Console    ${Pre_Active_Alarm}
    Log to console    \n --Alarm Validation Done--\n
    Log to console    \n--Test Setup finished--\n

Step1:FJT Software downgrade to oldPC
    Log to console    \n--Step1:RU Downgrade to OldPC --\n
    ${runningSwVersion1}=	Get ORU Sw Version Before Provision
    Log to console	${runningSwVersion1}
    ${result}=    Get Substring    ${RU_ver_24R3}    -7    -4
    ${RU_VER}=    Convert To Integer    ${result}
    Log to console    \n to update fjt: ${RU_VER}
    Run Keyword If    "${runningSwVersion1}" != "${RU_VER}"    COAM.update_software
    ...    ${resources_path}/${RU_ver_24R3}.zip
    ...    should_activate=True    timeout=1600    connection=default    should_reset_radios=true
    sleep    60s
    Check BTS is OnAir
    ${runningSwVersion2}=	Get ORU Sw Version After Provision
    Log to console	${runningSwVersion2}
    Log to console    \n--Step1:Passed--\n

Step2:Download oldPC BTS SW
    Log to console    \n--Step2:Download oldPC BTS SW --\n
    delete_files_netconf_opc
    ${SW_Ver}    COAM.get_sw_version
    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${SW_Ver}      _9999_
    ${SW_Ver1}=     Run keyword if
    ...           ${is_TrunkBuild}==True        Replace String Using Regexp    ${SW_Ver}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...  ELSE     Set variable   ${SW_Ver}
    Log to console  \n BTS_SW_Ver_usr: ${SW_Ver1} \n
    Run Keyword If    "${SW_Ver1}" == "${SW_Ver_usr1}"	Log to console  \n BTS Already updated with the Target version: ${SW_Ver_usr1} \n
    ...    ELSE    Fetch_Required_Enb_SW    Req_Enb_SW_ver=${SW_Ver_usr1}    current_bts_SW_ver=${SW_Ver1}
    Log to console    \n--Step2:Passed--\n

Step3:Configuration reset and install SW to oldPC release
    Log to console    \n--Step3:Configuration reset and install SW to oldPC release --\n
    COAM.reset_configuration    remove_operator_certificates=False    remove_user_account_credentials=False
    ...    timeout=700    connection=None    detailed_output=False    reset_type=None
    Sleep    400s
    fdsw.connect_to     ip_address=${LTE_BTS_IP}    port=${btsport}    username=${bts_uname}    password=${bts_pwd}
    ...    auto_discover=True    connection=default
    ${active_sw}=    fdsw.get_active_sw_partition    timeout=10    connection=default
    Log to console   --\n active_sw_partition=${active_sw} \n--
    ${sw_slot}=    Convert To Integer    ${active_sw}
    fdsw.software_update    sw_pkg_path=${SW_DESTINATION}/${SW_Ver_usr1}_release_BTSSM_downloadable_A54.zip
    ...    sw_slot_id=${sw_slot}    timeout=2500    activate=true
    #fdsw.teardown     connection=default
    Sleep    400s
    Run Keyword And Ignore Error    COAM.Teardown All Aliases For Admin
    Run Keyword And Ignore Error    COAM.setup_admin    bts_host=${LTE_BTS_IP}    name=default
    COAM.perform_commissioning    bts_id=${btsid2}    scf_file=${scf_cni}
    ...    skip_parameter_relation_errors=False    should_activate=True    timeout=500    connection=default
    Sleep    400s
    COAM.update_software    ${resources_path}/${RFMPlugin}
    ...    should_activate=True    timeout=1600    connection=default    should_reset_radios=true
    Sleep    30s
    COAM.configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=default
    ...    accounts=@{sudo_list}
    Sleep    60s
    Log to console    \n--Step3:Passed--\n

Step4:Verify OldProdCode and FJT SW version
    Log to console    \n--Step4:Verify OldProdCode and FJT SW version--\n
    Run Keyword And Ignore Error    os.Remove Directory     ${location}/coredump    recursive=True
    Run Keyword And Ignore Error    os.Remove file     ${location}/RMOD*
    Netconf File Collection
    Netconf Message validation for OldPC
    ${runningSwVersion2}=    Get ORU Sw Version After Provision
    Run Keyword And Ignore Error    os.Remove file     ${scf_pat}/${SW_Ver_usr1}*.zip
    Log to console    \n--Step4:Passed--\n

Step5:FJT Software upgrade to newPC without O-RU reset
    Log to console    \n--Step5:RU upgrade to newPC --\n
    #delete_files_netconf_opc
    ${runningSwVersion1}=	Get ORU Sw Version Before Provision
    Log to console	${runningSwVersion1}
    ${result}=    Get Substring    ${trunk_RU_ver}    -7    -4
    ${RU_VER}=    Convert To Integer    ${result}
    Log to console    \n to update fjt: ${RU_VER}
    Run Keyword If    "${runningSwVersion1}" != "${RU_VER}"    COAM.update_software
    ...    ${resources_path}/${trunk_RU_ver}.zip
    #...    should_activate=True    timeout=1600    connection=default    should_reset_radios=false
    ...    should_activate=True    timeout=1600    connection=default    should_reset_radios=true
    sleep    100s
    Check BTS is OnAir
    Log to console    \n--Step5:Passed--\n

Step6:BTS Software upgrade to newPC release
    Log to console    \n--Step6:BTS SW upgrade to newPC --\n

    ${SW_Ver}    COAM.get_sw_version
    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${SW_Ver}      _9999_
    ${SW_Ver1}=     Run keyword if
    ...           ${is_TrunkBuild}==True        Replace String Using Regexp    ${SW_Ver}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...  ELSE     Set variable   ${SW_Ver}
    Log to console  \n BTS_SW_Ver_usr: ${SW_Ver1} \n
    Run Keyword If    "${SW_Ver1}" == "${SW_Ver_usr}"	Log to console  \n BTS Already updated with the Target version: ${SW_Ver_usr} \n
    ...    ELSE    Fetch_Required_Enb_SW    Req_Enb_SW_ver=${SW_Ver_usr}    current_bts_SW_ver=${SW_Ver1}
    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    Log to Console     \n --SW_Update Started-- \n
    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    COAM.update_software
    ...    ${SW_DESTINATION}/${SW_Ver_usr}_release_BTSSM_downloadable_A54.zip
    ...    should_activate=True    timeout=2500    connection=default    should_reset_radios=true
    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    sleep    600
    Log to console    \n--Step6:Passed--\n

Step7:Verify NewProdCode and FJT SW version
    Log to console    \n--Step7:Verify NewProdCode and FJT SW version--\n
    Run Keyword And Ignore Error    os.Remove Directory     ${location}/coredump    recursive=True
    Run Keyword And Ignore Error    os.Remove file     ${location}/RMOD*
    Netconf File Collection
    Netconf Message validation for NewPC
    ${runningSwVersion2}=    Get ORU Sw Version After Provision
    Log to console	${runningSwVersion2}
    Run Keyword And Ignore Error    os.Remove file     ${scf_pat}/${SW_Ver_usr}*.zip
    ${dcap_log_status}=    Set Variable    1.0
    Set suite variable    ${dcap_log_status}
    Log to console    \n--Step7:Passed--\n

Step8:Verify BBMOD LANE and ORU Lock Unlock
    Log to console    \n--Step8:Verify BBMOD LANE Lock Unlock--\n
    FOR    ${a}    IN RANGE    1    6
        Log to console      \nPerforming LANE Lock Iteration: ${a}
        LANE Lock
        Sleep	40s
        Log to console      \nPerforming LANE Unlock Iteration: ${a}
        LANE Unlock
        Wait for BTS OnAir
        ${Pre_Active_Alarm}=    taf.sbts.oam.coam.admin.Get Active alarms
        ${allowed_alarms}=    Expected_alarm
        Verify Active Alarm Is In List    ${Pre_Active_Alarm}    ${allowed_alarms}
        Log to console    \n --Alarm Validation Done--
        Exit For Loop IF    ${a}==5
    END
    FOR    ${a}    IN RANGE    1    6
        Log to console      \nPerforming ORU Lock Iteration: ${a}
        ORU Lock
        Sleep	10s
        Log to console      \nPerforming ORU Unlock Iteration: ${a}
        ORU Unlock
        Wait for BTS OnAir
        ${Pre_Active_Alarm}=    taf.sbts.oam.coam.admin.Get Active alarms
        ${allowed_alarms}=    Expected_alarm
        Verify Active Alarm Is In List    ${Pre_Active_Alarm}    ${allowed_alarms}
        Log to console    \n --Alarm Validation Done--
        Exit For Loop IF    ${a}==5
    END
    Log to console    \n--Step8:Passed--\n

L3 Call verification
    Log to console    \n--L3 Call Testing Started--\n
    COAM.Unlock    dist_name=${cell1}    timeout=120
    COAM.lock    dist_name=${cell2}    timeout=120
    COAM.lock    dist_name=${cell3}    timeout=120
    COAM.lock    dist_name=${cell4}    timeout=120
    Connect Ultracaller
    Downlink and uplink data transfer
    COAM.Unlock    dist_name=${cell2}    timeout=120
    COAM.Unlock    dist_name=${cell3}    timeout=120
    COAM.Unlock    dist_name=${cell4}    timeout=120
    Log to console    \n--L3 call testing Passed--\n

Test teardown
    Log to console   --\n Test teardown Started\n--
    ${curr_sw}    COAM.get_sw_version
    ${is_24R3}=    Run Keyword and Return Status    Should Contain    ${curr_sw}    24R3
    #Run keyword if    ${is_24R3}==True    Rollback To Passive SW
    Check BTS is OnAir
    Log to console    \n --Alarm Validation Started--\n
    ${Pre_Active_Alarm}=    taf.sbts.oam.coam.admin.Get Active alarms
    ${allowed_alarms}=    Expected_alarm
    Verify Active Alarm Is In List    ${Pre_Active_Alarm}    ${allowed_alarms}
    Log To Console    ${Pre_Active_Alarm}
    Log to console    \n --Alarm Validation Done--\n
    #Log to console	DCAP_LOG_STATUS: ${dcap_log_status}
    #Run Keyword If    ${dcap_log_status} == 1.0    Abort DCAP Trace    ${trace_id}
    #...    ELSE    DCAP Stop with log Transfer    ${trace_id}
    RP Settings
    COAM.Teardown All Aliases For Admin
    interface.Common step trigger
    Log to console   --\n Test teardown COMPLETED \n--

Connect Ultracaller
    Log to console    \nStarting Ultracaller
    Start NAA application
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console      \nExecuting testcase in UE : ${capabilities}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}

Verify Active Alarm Is In List
   [Arguments]    ${alarm}    ${list}
   ${result} =    Run Keyword And Return Status    List Should Not Contain Value    ${list}    ${alarm}
   Should Be True    ${result}

Start NAA application
    @{Devices}   Get active devices
    taf.transport.ssh.Connect_to    ${UE_PC_IP}    ${Windows_user}    ${Windows_pass}    alias=UE_PC
    FOR    ${Device}    IN    @{Devices}
        ${cmd}    set variable    adb -s ${Device} shell monkey -p com.nokia.android.application 1
        ${output}    taf.transport.ssh.Execute    ${cmd}    connection=UE_PC
        LOG    ${output}
    END
    Sleep       30
    start_proxy     ${UE_PC_IP}     ${Windows_user}     ${Windows_pass}     ${Proxy_path}
    taf.transport.ssh.Execute    cd ${Proxy_path} && START proxy.exe   connection=UE_PC
    Sleep       1m
    taf.transport.ssh.Disconnect    connection=UE_PC
Get active devices
    taf.transport.ssh.Connect_to    ${UE_PC_IP}    ${Windows_user}    ${Windows_pass}    alias=UE_PC
    ${output}    taf.transport.ssh.Execute    adb devices    connection=UE_PC
    @{output}    Split To Lines    ${output}
    @{Devices}    Create List
    FOR    ${line}    IN    @{output}
        ${b}    Split String From Right    ${line}    ${space}    -1
        Append To List    ${Devices}    ${b}[0]
    END
    taf.transport.ssh.Disconnect    connection=UE_PC
    [return]    @{Devices}

Downlink and uplink data transfer
    Log to console    \nStarting ${direction_dl} data transfer
    ta_ultracaller.start_data_transfer    ${UE_alias}    ${data_transfer_protocol}    direction=@{direction_dl}
    Log to console    \nStarting ${direction_ul} data transfer
    ta_ultracaller.start_data_transfer    ${UE_alias}    ${data_transfer_protocol}    direction=${direction_ul}
    sleep    180
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_dl}    ${timeout}
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_ul}    ${timeout}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}

UnLock LTE Site
    Log to console    \n-- Unlocking LTE RAT for eNODEB --\n

    Wait until keyword succeeds   1min   2s    COAM.unblock_rat    rat=LTE    connection=${connection1}
    COAM.teardown_admin    connection=${connection1}

Netconf Message validation for OldPC

    @{entries}=    Get NETCONF Log Entries
    ...    file_path=${d_dump}
    @{rpcreply_sw}=    create List
    FOR    ${entry}    IN    @{entries}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//product-code")}' =='FJRU-N75N3N1-G'
        ...    Append To List    ${rpcreply_sw}    ${entry.message.xml.findtext(".//product-code")}
    END
    Log to Console    ${rpcreply_sw}
    Should Contain    ${rpcreply_sw}    ${old_pc}

Netconf Message validation for NewPC

    @{entries}=    Get NETCONF Log Entries
    ...    file_path=${d_dump}
    @{rpcreply_sw}=    create List
    FOR    ${entry}    IN    @{entries}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//product-code")}' =='TA08029-B311/01'
        ...    Append To List    ${rpcreply_sw}    ${entry.message.xml.findtext(".//product-code")}
    END
    Log to Console    ${rpcreply_sw}
    Should Contain    ${rpcreply_sw}    ${new_pc}

Get ORU Sw Version Before Provision
    ${bts_info}=    COAM.get_bts_info
    ${SwVersion_tmp1}=    Create List	${bts_info['radioModules']['rmod'][0]['swInfo']['runningSwVersion']}
    Log To Console	\n RU_SW version: ${SwVersion_tmp1[0]}
    ${SwVersion_tmp2}=    Split string    ${SwVersion_tmp1[0]}     separator=_    max_split=3
    #${SwVersion_tmp3}=    Split string    ${SwVersion_tmp2[0]}     separator=-    max_split=2
    #${SwVersion_tmp4}=    Split String To Characters    ${SwVersion_tmp3[2]}
    ${runningSwVersion}=	Convert to Integer	${SwVersion_tmp2[1]}
    [Return]    ${runningSwVersion}

Get ORU Sw Version After Provision
    Run Keyword And Ignore Error    COAM.Teardown All Aliases For Admin
    Run Keyword And Ignore Error    COAM.setup_admin    bts_host=${LTE_BTS_IP}
    ${bts_info}=    COAM.get_bts_info
    ${SwVersion_tmp1}=    Create List	${bts_info['radioModules']['rmod'][0]['swInfo']['runningSwVersion']}
    Log To Console	\n O-RU SW Version After Provision: ${SwVersion_tmp1[0]}
    ${SwVersion_tmp2}=    Split string    ${SwVersion_tmp1[0]}     separator=_    max_split=3
    #${SwVersion_tmp3}=    Split string    ${SwVersion_tmp2[0]}     separator=-    max_split=2
    #${SwVersion_tmp4}=    Split String To Characters    ${SwVersion_tmp3[2]}
    ${runningSwVersion}=	Convert to Integer	${SwVersion_tmp2[1]}
    [Return]    ${runningSwVersion}

Rollback To Passive SW
    Log to console    \n--Rollback to Passive SW--\n
    COAM.setup_admin	bts_host=${LTE_BTS_IP}
    COAM.rollback_software    timeout=300
    sleep    400s
    COAM.teardown_admin
    Log to console    \n-- Rollback step completed -- \n

Wait for BTS OnAir
    Log to console      \nWaiting for BTS to be OnAir
    FOR    ${a}    IN RANGE    1    10
        ${bts_status}=    taf.sbts.oam.coam.admin.get_bts_statuses
        Exit For Loop IF    '${bts_status["proceduralState"]}'=='OnAir'
        Sleep    1m    reason=Wait for BTS status OnAir
    END
    ${bts_status}    taf.sbts.oam.coam.admin.get_bts_statuses
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}

LANE Lock
   taf.sbts.oam.coam.admin.Perform Parameter Recommissioning    dist_name=MRBTS-${btsid2}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1
   ...                                        parameter=administrativeState
   ...                                        operation=update
   ...                                        value=Locked

LANE Unlock
   taf.sbts.oam.coam.admin.Perform Parameter Recommissioning    dist_name=MRBTS-${btsid2}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1
   ...                                        parameter=administrativeState
   ...                                        operation=update
   ...                                        value=Unlocked

ORU Lock
    ${RMODS}  taf.sbts.oam.coam.admin.get_ids_for_all  RMOD
    FOR    ${RMOD}    IN  @{RMODS}
      taf.sbts.oam.coam.admin.lock    dist_name=${RMOD}    timeout=300s
    END

ORU Unlock
    ${RMODS}  taf.sbts.oam.coam.admin.get_ids_for_all  RMOD
    FOR    ${RMOD}    IN  @{RMODS}
      taf.sbts.oam.coam.admin.unlock    dist_name=${RMOD}    timeout=300s
    END
