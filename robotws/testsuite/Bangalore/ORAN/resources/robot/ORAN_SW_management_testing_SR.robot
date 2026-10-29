*** Settings ***
Documentation
...   author: Sudarshan Kanapuram
...   contact: sudarshan.kanapuram@nokia.com
...   Description: CNI144906_O-RAN specific software management testing improvements in CRT for SR deployments
...                :Precondition of testbed: Current code is not implemented for DualCore, additional Netconf account.
...                :Please keep all SCF, swconfig and O-RU related builds(related to source Build) in mentioned paths.
...                :Update all variables correctly as per testline usage, remaining script is generalised.


Library     ./testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Resource    ./testsuite/Bangalore/ORAN/resources/robot/SetupReadinessWithIntelligentSoftwareUpdate.robot
Resource    ./testsuite/Bangalore/ORAN/resources/robot/OperationKeywords.robot
Resource     ./testsuite/Bangalore/ORAN/resources/robot/SetupReadinessVariables.robot


*** Keywords ***

RU_SW_upgrade_ODU_SW_upgrade
    [Arguments]
	...    ${btsId}=967
	...    ${SourceBuildId}=${EMPTY}
	...    ${TargetBuildId}=${EMPTY}
	...    ${Src_ScfPath}=${EMPTY}
	...    ${FJRFM_plugIn}=${EMPTY}
	...    ${Is_L3_call_test_required}=True


	Should Not Be Empty    ${SourceBuildId}    Source Build ID is EMPTY! Please check input.
	Should Not Be Empty    ${TargetBuildId}    Target Build ID is EMPTY! Please check input.
	Should Not Be Empty    ${Src_ScfPath}    Target Build ID is EMPTY! Please check input.
	Should Not Be Empty    ${FJRFM_plugIn}    Target Build ID is EMPTY! Please check input.
	Set global variable    ${bts_id}    ${btsId}
	Set global variable    ${sourcebasebuildavailable}    yes
	Set global variable    ${fullsourcebasebuild}    ${SourceBuildId}
	Set global variable    ${SWBuildID_UserChoice}    ${TargetBuildId}
	Set global variable    ${DownloadSWBuildbyUserChoice}    yes
	Set global variable    ${sourceScfpath}    ${Src_ScfPath}
	Set global variable    ${sourceRelease}    SBTS25R3
	Set global variable    ${rfmpluginpath}    /home/ute/${sourceRelease}/${FJRFM_plugIn}
	@{StrippedString}=    Split String    ${TargetBuildId}    _
	${targetRelease}    Set Variable    ${StrippedString}[0]
	IF   "${targetRelease}" == "SBTS00"
		Set global variable    ${targetRelease}    ${currentTrunk}
	    ELSE
		Set global variable    ${targetRelease}
    END
    Log to console    targetRelease: ${targetRelease}
	Set global variable    ${FILE_PREFIX}    ${TargetBuildId}
	Prepare SBTS with base SW build
	Set Global Variable    ${activesw}    ${targetRelease}
	Log to console    activesw: ${activesw}
	FJRadioReleaseCompatibilityCheck
	IF   ${Is_L3_call_test_required} == True
		L3 Call verification
    END
	#admin.reset_admin    connection=default
	Sleep    400s
	Counters collection and validation
	Download_Update_SW_Via_MantaRay
	IF   ${Is_L3_call_test_required} == True
		L3 Call verification
    END
	Sleep    400s
	Counters collection and validation
	admin.teardown_all_aliases_for_admin


ODU_SW_upgrade_RU_SW_upgrade
    [Arguments]
	...    ${btsId}=967
	...    ${SourceBuildId}=${EMPTY}
	...    ${TargetBuildId}=${EMPTY}
	...    ${Src_ScfPath}=${EMPTY}
	...    ${FJRFM_plugIn}=${EMPTY}
	...    ${Is_L3_call_test_required}=True


	Should Not Be Empty    ${SourceBuildId}    Source Build ID is EMPTY! Please check input.
	Should Not Be Empty    ${TargetBuildId}    Target Build ID is EMPTY! Please check input.
	Should Not Be Empty    ${Src_ScfPath}    Target Build ID is EMPTY! Please check input.
	Should Not Be Empty    ${FJRFM_plugIn}    Target Build ID is EMPTY! Please check input.
	Set global variable    ${bts_id}    ${btsId}
	Set global variable    ${sourcebasebuildavailable}    yes
	Set global variable    ${fullsourcebasebuild}    ${SourceBuildId}
	Set global variable    ${SWBuildID_UserChoice}    ${TargetBuildId}
	Set global variable    ${DownloadSWBuildbyUserChoice}    yes
	Set global variable    ${sourceScfpath}    ${Src_ScfPath}
	Set global variable    ${sourceRelease}    SBTS25R3
	Set global variable    ${rfmpluginpath}    /home/ute/${sourceRelease}/${FJRFM_plugIn}
	@{StrippedString}=    Split String    ${TargetBuildId}    _
	${targetRelease}    Set Variable    ${StrippedString}[0]
	IF   "${targetRelease}" == "SBTS00"
		Set global variable    ${targetRelease}    ${currentTrunk}
	    ELSE
		Set global variable    ${targetRelease}
    END
    Log to console    targetRelease: ${targetRelease}
	Set global variable    ${FILE_PREFIX}    ${TargetBuildId}
	Prepare SBTS with base SW build
	IF   ${Is_L3_call_test_required} == True
		L3 Call verification
    END
	Set Global Variable    ${activesw}    ${targetRelease}
	Log to console    activesw: ${activesw}
	Download_Update_SW_Via_MantaRay
	IF   ${Is_L3_call_test_required} == True
		L3 Call verification
    END
	Sleep    400s
	Counters collection and validation
	FJRadioReleaseCompatibilityCheck_SwMgt
	IF   ${Is_L3_call_test_required} == True
		L3 Call verification
    END
	Sleep    400s
	Counters collection and validation
	admin.teardown_all_aliases_for_admin


RU_SW_upgrade_NoACT_ODU_SW_upgrade
    [Arguments]
	...    ${btsId}=967
	...    ${SourceBuildId}=${EMPTY}
	...    ${TargetBuildId}=${EMPTY}
	...    ${Src_ScfPath}=${EMPTY}
	...    ${FJRFM_plugIn}=${EMPTY}
	...    ${Is_L3_call_test_required}=True


	Should Not Be Empty    ${SourceBuildId}    Source Build ID is EMPTY! Please check input.
	Should Not Be Empty    ${TargetBuildId}    Target Build ID is EMPTY! Please check input.
	Should Not Be Empty    ${Src_ScfPath}    Target Build ID is EMPTY! Please check input.
	Should Not Be Empty    ${FJRFM_plugIn}    Target Build ID is EMPTY! Please check input.
	Set global variable    ${bts_id}    ${btsId}
	Set global variable    ${sourcebasebuildavailable}    yes
	Set global variable    ${fullsourcebasebuild}    ${SourceBuildId}
	Set global variable    ${SWBuildID_UserChoice}    ${TargetBuildId}
	Set global variable    ${DownloadSWBuildbyUserChoice}    yes
	Set global variable    ${sourceScfpath}    ${Src_ScfPath}
	Set global variable    ${sourceRelease}    SBTS25R3
	Set global variable    ${rfmpluginpath}    /home/ute/${sourceRelease}/${FJRFM_plugIn}
	@{StrippedString}=    Split String    ${TargetBuildId}    _
	${targetRelease}    Set Variable    ${StrippedString}[0]
	IF   "${targetRelease}" == "SBTS00"
		Set global variable    ${targetRelease}    ${currentTrunk}
	    ELSE
		Set global variable    ${targetRelease}
    END
    Log to console    targetRelease: ${targetRelease}
	Set global variable    ${FILE_PREFIX}    ${TargetBuildId}
	Prepare SBTS with base SW build
	IF   ${Is_L3_call_test_required} == True
		L3 Call verification
    END
	Set Global Variable    ${activesw}    ${sourceRelease}
	Log to console    activesw: ${activesw}
	OFEGSA_Upgrade_To_Latest_Build_NoAct
	Download_Update_SW_Via_MantaRay
	IF   ${Is_L3_call_test_required} == True
		L3 Call verification
    END
	Sleep    400s
	Counters collection and validation
	admin.teardown_all_aliases_for_admin


Prepare SBTS with base SW build
    log    "Test Started"
    ${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
    ${CurrentDate}=    Convert to String     ${CurrentDate}
    os.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}/SoftwareUpdateLogs
    Set global variable    ${Date}    ${CurrentDate}
    Run Keywords     Login To Admin
    ${sourcePath}    Set Variable    toor4nsn@192.168.255.129:/ffs/run/swconfig.txt
    Log To Console    ----\nStart of Intelligent SW Update----
    Set global variable    ${sourcePath}
    ${output}=    os.Run    df -k .
    Log to console    Disk Space Before Test Execution is ${output}
    os.run    scp ${sourcePath} ${BTS_path}/${SUITE NAME}/${Date}/SoftwareUpdateLogs/swconfig.txt
    Start BTS logs
    Run keyword and continue on failure    Trigger_SoftwareUpdate
    Run Keyword and Ignore Error     Check ActiveFaultandAlarmID    @{faultslist}
    Collect Snapshot    snaptarget_file_name=${BTS_path}/${SUITE NAME}/${Date}/SoftwareUpdateLogs/Snapshot.zip
    CleanupBuilds
    Log to console    ----\nEnd of Intelligent SW Update----
    ${output}=    os.Run    df -k .
    Log to console    Disk Space After Test Execution is ${output}
    Run Keyword And Ignore Error    Stop BTS logs    btslog_target_dir=${BTS_path}/${SUITE NAME}/${Date}/SoftwareUpdateLogs

Trigger_SoftwareUpdate
    [Documentation]    Check source build in both partition and upgrade to TARGET build. Possible situations as:
	...                :Source build is in active > update to target
	...                :Source build is in passive > rollback and update directly to target
	...                :Source Build is not in both partition > Downgrade to source build and update to target
	...                :Source build is in active & Source Build same as Target Build > Directly update to target
    os.run    scp ${sourcePath} ${BTS_path}/${SUITE NAME}/${Date}/SoftwareUpdateLogs/swconfig.txt
    IF   "${sourcebasebuildavailable}" != "yes"
         DownloadSBTS_SourceBuild    ${sourceRelease}    ${SWpromTAG}
         Set Global Variable    ${SourceBuild_info}
         @{StrippedString}=    Split String    ${SourceBuild_info}    /
         @{StrippedBuild}=	   Split String    ${StrippedString}[5]    _release
         ${fullsourcebasebuild}    Set Variable    ${StrippedBuild}[0]
         Set Global Variable    ${fullsourcebasebuild}
         os.Run    mv ${SourceBuild_info} /home/ute/${sourceRelease}/${fullsourcebasebuild}_release_BTSSM_downloadable_A54.zip
         Log to console    \nSource Build Download completed
    END
    ${sourceSWpath}    Set Variable    /home/ute/${sourceRelease}/${fullsourcebasebuild}_release_BTSSM_downloadable_A54.zip
    Set Global Variable    ${sourceSWpath}
	${exists}=    Evaluate    os.path.exists(r'''${sourceSWpath}''')
	IF    not ${exists}
        Log    ❌ File missing
        ${SourceBuild_info}=     latestSbtsBuild   build_name=${fullsourcebasebuild}    branch=${sourceRelease}    typeOfReg=${SWpromTAG}
        os.Run    mv ${SourceBuild_info} /home/ute/${sourceRelease}/${fullsourcebasebuild}_release_BTSSM_downloadable_A54.zip
        Log to console    \nSource Build Download completed
	ELSE
	    Log to console    \nSource Build already exist
	END
    GetSoftwareInfo

    IF    "${SWactive}[0]" == "${currentTrunk}"
    	Set List Value    ${SWactive}    0    SBTS00
        ${SWactive}=    Evaluate    "_".join(${SWactive})
    	${setDecisionForSetupReadinessActive}=    Set Variable    SBTS00
    	ELSE
        ${setDecisionForSetupReadinessActive}=    Set Variable    ${SWactive}[0]
    	${SWactive}=    Evaluate    "_".join(${SWactive})
    END
    IF    "${SWpassive}[0]" == "${currentTrunk}"
    	Set List Value    ${SWpassive}    0    SBTS00
        ${SWpassive}=    Evaluate    "_".join(${SWpassive})
    	${setDecisionForSetupReadinessPassive}=    Set Variable    SBTS00
        ELSE
    	${setDecisionForSetupReadinessPassive}=    Set Variable    ${SWpassive}[0]
        ${SWpassive}=    Evaluate    "_".join(${SWpassive})
    END
	IF    '${SWactive}' == '${fullsourcebasebuild}'
		Log to Console     Setup is already at Latest Build, skipping Upgrade
	ELSE IF    '${SWpassive}' == '${fullsourcebasebuild}'
		RollbackSW_SwMgt
	ELSE IF    "${setDecisionForSetupReadinessActive}" != "${sourceRelease}" and "${setDecisionForSetupReadinessPassive}" != "${sourceRelease}"
		Check_SetupConfiguration_and_PerformDowngrade_SwMgt
	ELSE IF    "${setDecisionForSetupReadinessActive}" != "${sourceRelease}" and "${setDecisionForSetupReadinessPassive}" == "${sourceRelease}"
		RollbackSW_SwMgt
		Set Global Variable    ${build_info}    ${sourceSWpath}
		Updating_Latest_SW_without_download
	ELSE
		Set Global Variable    ${build_info}    ${sourceSWpath}
		Updating_Latest_SW_without_download
	END
    Run Keyword and Continue on Failure     CheckOperationalStateOfRadios
	CleanupBuilds

Check_SetupConfiguration_and_PerformDowngrade_SwMgt
    FetchingRadioDistnameAndRelatedRadioInfo
    CheckProtocol_SwMgt


CheckProtocol_SwMgt
    [Documentation]    Check protocol and differentiate legacy setup from O-RAN setup
    ${orancounter}      Set Variable    1
    ${prtlen}=    Get Length    ${protocols}
    FOR    ${i}    IN RANGE     ${prtlen}
        IF    "${protocols[${i}]}" == "O-RAN"
            ${orancounter}=    Evaluate    ${orancounter}+1
        END
    END
    Run Keyword If    "${orancounter}" == "1"    UpgradetosourceSWpathNonORAN
    Run Keyword If    "${orancounter}" > "1"     CheckORANtype_SwMgt

CheckORANtype_SwMgt
    [Documentation]    Check vendor codes and differentiate O-RAN radios.
    ${fjcounter}    Set Variable    1
    ${nkcounter}    Set Variable    1
    ${codelen}=    Get Length    ${vendorcodes}
    FOR    ${i}    IN RANGE     ${codelen}
        IF    "${vendorcodes[${i}]}" == "FJ"
            ${fjcounter}=    Evaluate    ${fjcounter}+1
        END
        IF    "${vendorcodes[${i}]}" == "NK"
            ${nkcounter}=    Evaluate    ${nkcounter}+1
        END
    END
    Run Keyword If    "${fjcounter}" == "1" and "${nkcounter}" > "1"    Log to Console    \nNK downgrade not supported
    Run Keyword If    "${fjcounter}" > "1" and "${nkcounter}" > "1"     Log to Console    \nNK downgrade not supported
    Run Keyword If    "${fjcounter}" > "1" and "${nkcounter}" == "1"    UpgradetosourceSWpathFJORAN_SwMgt

UpgradetosourceSWpathFJORAN_SwMgt
    Log to console    \nTestbed-with-FJT-Upgrade
    SBTSdowngrade_SwMgt
    Sleep    100s
    Configure Netconf Credentials    @{fjt_oru_creds}
    Sleep    100s
    Wait until keyword succeeds    20m    2m    admin.update_software
            ...    sw_package=${rfmpluginpath}    should_activate=True    timeout=1000
	    ...    connection=${connection}    should_reset_radios=true
    Sleep   400s
	FOR    ${key}    ${value}    IN    &{FJsw_compatibility}
        Run Keyword If    "${key}" == "${sourceRelease}"    UpgradeFJORU    ${value}    ${fullsourcebasebuild}
    END
	Wait until keyword succeeds    10m    20s    Check_BTS_State
    Check_BTS_Ping
    GetSoftwareInfo

SBTSdowngrade_SwMgt
    [Documentation]    SBTS downgrade to source release
    Log to console    \nTestbed-under-configReset
    admin.reset_configuration    remove_operator_certificates=False    remove_user_account_credentials=False
    ...    timeout=700    connection=None    detailed_output=False    reset_type=None
    admin.teardown_admin    connection=default
    Sleep    400s
    Check_BTS_Ping
    fdsw.connect_to     ip_address=${BTS_ADDRESS}    port=${port}    username=${btsusername}    password=${btspassword}
    ...    fdsw_version=${fdsw_version}    auto_discover=True     secure=True    connection=none
    fdsw.software_update    sw_pkg_path=${sourceSWpath}    timeout=1500    activate=true
    Sleep    100s
    Check_BTS_Ping
    admin.setup_admin    bts_host=${BTS_ADDRESS}    bts_port=${port}    username=${btsusername}
    ...    timeout=30    name=default        password=${btspassword}
    admin.perform_commissioning    bts_id=${bts_id}    scf_file=${sourceScfpath}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=300    connection=${connection}
    Sleep    100s
    Check_BTS_Ping
    Copy_swconfigFile    ${BTS_path}/${SUITE NAME}/${Date}/SoftwareUpdateLogs/swconfig.txt
    ...    ${ssh_username}@${BTS_ADDRESS}:/ffs/run


Updating_Latest_SW_without_download
    [Documentation]    Updating_Latest_SW_without_download
    UpdateSBTSswViaWebEM
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    ##If O-RAN:FJ, O-RAN:NK or Mix of Both, upgrade radios accordingly
    Check_FJT_NK_RU_Build_after_SBTS_Target_Upgrade
    Align_FJPC_bychecking_FJSN
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    GetSoftwareInfo

Download_Update_SW_Via_MantaRay
    Log To Console    \n---Start of Latest Upgrade---
	${cwd}    Set Variable    /home/ute/Downloads/Builds
	GetSoftwareInfo
	Set Global Variable    ${passivesw}    ${sourceRelease}
	IF    "${SWactive}[0]" == "${currentTrunk}"
    	Set List Value    ${SWactive}    0    SBTS00
        ${SWactive}=    Evaluate    "_".join(${SWactive})
    	${setDecisionForSetupReadinessActive}=    Set Variable    SBTS00
    	ELSE
        ${setDecisionForSetupReadinessActive}=    Set Variable    ${SWactive}[0]
    	${SWactive}=    Evaluate    "_".join(${SWactive})
    END
    IF    "${SWpassive}[0]" == "${currentTrunk}"
    	Set List Value    ${SWpassive}    0    SBTS00
        ${SWpassive}=    Evaluate    "_".join(${SWpassive})
    	${setDecisionForSetupReadinessPassive}=    Set Variable    SBTS00
        ELSE
    	${setDecisionForSetupReadinessPassive}=    Set Variable    ${SWpassive}[0]
        ${SWpassive}=    Evaluate    "_".join(${SWpassive})
    END
	IF    '${SWactive}' == '${SWBuildID_UserChoice}'
		Log to Console     Setup is already at Latest Build, skipping Upgrade
	ELSE IF    '${SWpassive}' == '${SWBuildID_UserChoice}'
		RollbackSW_SwMgt
	ELSE
		${build_info}    Set Variable    ${cwd}/${SWBuildID_UserChoice}_release_BTSSM_downloadable_A54.zip
		${exists}=    Evaluate    os.path.exists(r'''${build_info}''')
		IF    not ${exists}
			Log    ❌ File missing
			IF   "${DownloadSWBuildbyUserChoice}" == "no"
				${build_info}=     latestSbtsBuild   branch=${targetRelease}    typeOfReg=${SWpromTAG}
			ELSE
				${build_info}=     latestSbtsBuild   build_name=${SWBuildID_UserChoice}    branch=${targetRelease}    typeOfReg=${SWpromTAG}
			END
			Log to console    \n Target Build Download completed
		ELSE
			Log to console    \n Target Build already exist
		END
		Set Global Variable    ${build_info}
		Log To Console    Target build info: ${build_info}
		Run Keyword and Ignore Error     Teardown_MantaRay
		Setup_MantaRay
		${status}=    Run Keyword And Return Status    UpdateSBTSswViaMantaRay
		Run Keyword If    not ${status}    Log to console    \nSWupdate failed for Mantaray, updating via WEBEM
		Run Keyword If    not ${status}    UpdateSBTSswViaWebEM
		Run Keyword and Ignore Error     Teardown_MantaRay
	END
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    Run Keyword and Continue on Failure     CheckOperationalStateOfRadios
	CleanupBuilds


OFEGSA_Upgrade_To_Latest_Build_NoAct
    Configure Netconf Credentials    @{fjt_oru_creds}
    Wait until keyword succeeds    20m    20s    Check_BTS_State
    FOR    ${key}    ${value}    IN    &{FJsw_compatibility}
		IF    "${activesw}" == "${key}"
			${fjserial}=    Set Variable    ${value}
		END
    END
    ####Create and upload NMS file####
	Log    ${fjserial}
    ${NMS_File_to_netact}=    create_nms_file    username=na    password=na    auth_key=${FJTpasswd}
     ...    target_path=/home/ute/robotws/RU_SW   user=${FJTusername}    host=na    port=0    build=${FILE_PREFIX}
     ...    ru_link=https://artifactory-blr1.int.net.nokia.com/artifactory/mn-fujitsu-data-local/    radio="Fujitsu"
     ...    fjserial=${fjserial}    data={"requestId":100,"parameters":{"name":"generateNokiaCompliantORUSWPackage"}}
    ###UpgradeRadio###
	Log    /home/ute/robotws/RU_SW/${NMS_File_to_netact}[1]
    admin.update_software
    ...    sw_package=/home/ute/robotws/RU_SW/${NMS_File_to_netact}[1]    should_activate=True    timeout=1000
	...    connection=${connection}    should_reset_radios=False
    Wait until keyword succeeds    10m    20s    Check_BTS_State

FJRadioReleaseCompatibilityCheck_SwMgt
    Configure Netconf Credentials    @{fjt_oru_creds}
    Wait until keyword succeeds    20m    20s    Check_BTS_State
    GetSoftwareInfo
	Set Global Variable    ${activesw}    ${sourceRelease}
	Log to console    activesw: ${activesw}
    FOR    ${key}    ${value}    IN    &{FJsw_compatibility}
        Run Keyword If    "${activesw}" == "${key}"    OFEGSA_Upgrade_To_Latest_Build    ${value}
    END

L3 Call verification
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
    Log to console    \nStarting data transfer
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_dl}
    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_dl}
    ...     ${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl_udp}    deviation=${deviation_dl}

    ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_ul}
    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_ul}
    ...     ${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
    ...     thrughtput=${throughput_ul_udp}    deviation=${deviation_ul}
    Log to console    \n--L3 Call Testing Passed--\n

Counters collection and validation
    Log to console   \n-- Counter Verification from BTS Started--\n
    sleep    10s
	@{counter_list}=    Split String    ${counter_nos_01}    ,
	@{counter_list}=    Evaluate    [f"'{i}'" for i in ${counter_list}]

    ${result} =    admin.get_pm_counters    counter_ids=${counter_nos_01}    timeout=600    connection=default
    FOR    ${I}    IN    @{counter_list}
        ${values}=    Get Dictionary Values   ${result['BTS']['MRBTS-${btsId}']['NRBTS-${btsId}']['NRCELL-${NR_CELL_id}']['NRACH'][${I}]}
        ${last_value}=     Set Variable     ${values[-1]}
        ${float_value}=    Convert To Number    ${last_value}

        ${int_part}=       Evaluate    int(${float_value})
        Should Be True          ${int_part} >= ${counters_val_min} and ${int_part} <= ${counters_val_min}

    END

RollbackSW_SwMgt
    Log to console    \nRollback-Triggered
    FOR    ${key}    ${value}    IN    &{FJsw_compatibility}
        Run Keyword If    "${passivesw}" == "${key}"    UpgradeFJORU    ${value}    ${fullSWpassive}
    END
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    admin.rollback_software    timeout=500    detailed_output=False     connection=${connection}
    Sleep    300s
    Check_BTS_Ping
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    GetSoftwareInfo

