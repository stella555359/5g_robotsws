*** Settings ***

Documentation    **********SW Download & Update to BTS via WebEM/NMS***********
Library    Process
Library    String
Library    Collections
Library    OperatingSystem    WITH NAME     os
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.nms.netact    WITH NAME    nms
Library    taf.selenium.sbts    WITH NAME    sbts
Library     taf.fdsw.rc  WITH NAME   fdsw
Library	   ./testsuite/Bangalore/ORAN/resources/python/downloadwftpackage.py

*** Keywords ***

Suite setup
    coam.setup_admin	${bts_host}    name=${alias}
	${BTS_details}    coam.get_bts_info    timeout=30    connection=${alias}
	${SOFTWARE_VERSIONS}=    coam.get_software_info    timeout=300    connection=${alias}
    Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    ${activeswversion}=    Convert to String    ${SOFTWARE_VERSIONS['Active SW version']}
    ${passiveswversion}=    Convert to String    ${SOFTWARE_VERSIONS['Passive SW version']}
    @{SW1}=    Split String    ${activeswversion}    _
    @{SW2}=    Split String    ${passiveswversion}    _
    ${activesw} =    Set Variable    ${SW1}[0]
    ${passivesw} =    Set Variable    ${SW2}[0]
    Set Global Variable    ${activesw}
    Set Global Variable    ${passivesw}
    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${activeswversion}      _9999_
    ${BTSSW_ver}=    Run Keyword If    ${is_TrunkBuild}==True
    ...    Replace String Using Regexp    ${activeswversion}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...    ELSE
    ...    Set Variable    ${activesw}
    Set Global Variable     ${BTSSW_ver}
    coam.get_current_scf_file    local_dir_path=/home/ute/Documents    file_name=${25R2_SCF_name}    timeout=10    connection=${alias}
	BTS SW version

Suite Teardown
    coam.teardown          connection=${alias}

Get_BTS_SW_version
    [Documentation]     Fetched current SBTS build and return SBTS00 or branch
    ${SW_Ver}=	coam.get_sw_version   connection=${alias}
    log    ${SW_Ver}
    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${SW_Ver}      _9999_
    ${BTSSW_ver}=    Run Keyword If    ${is_TrunkBuild}==True
    ...    Replace String Using Regexp    ${SW_Ver}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...    ELSE
    ...    Set Variable    ${SW_Ver}
    Log to console  \n Current SW version on BTS is: ${BTSSW_ver} \n
    Set global variable    ${BTSSW_ver}
    [Return]  ${BTSSW_ver}

Get_SBTS_build_type
    [Documentation]     Fetch current SBTS build and return SBTS00 or branch
    &{a}=	coam.get_software_info   connection=${alias}
    log    ${a}
    ${value}=    Get From Dictionary	${a}	Active SW version
    ${SBTStype}=	Fetch From Left    ${value}    _
    IF    '${SBTS_type}' == 'SBTS25R3'
		${SBTS_type}=    Set Variable    SBTS00
	END
	log    ${SBTS_type}
	Set Global Variable    ${SBTS_type}
    [Return]  ${SBTS_type}


Get_SBTS_build_type_target_build
    [Documentation]     Fetch target SBTS build and return SBTS00 or branch
    ${a}    Set Variable    ${target_build_name}
	Log to console    \n Target build is : ${target_build_name}\n
    ${targetSBTStype}=	Fetch From Left    ${a}     _
    Set global variable    ${targetSBTStype}
    log to console    \n Target BTS build type is : ${targetSBTStype}
    [Return]  ${targetSBTStype}

Get_SBTS_build_type_source_build
    [Documentation]     Fetch target SBTS build and return SBTS00 or branch
    ${a}    Set Variable    ${source_SBTS_buildname}
	Log to console    \n Source build as precondition is : ${source_SBTS_buildname}\n
    ${source_SBTS_buildtype}=	Fetch From Left    ${a}     _
    Set global variable    ${source_SBTS_buildtype}
    log to console    ${source_SBTS_buildtype}
    [Return]  ${source_SBTS_buildtype}

BTS SW version
    Get_BTS_SW_version
	${SBTS_type}=    Get_SBTS_build_type
    Get_SBTS_build_type_target_build
    Get_SBTS_build_type_source_build

SW download and upgrade to target build
    Log to console    \n Start target SW download \n
    ${sw_path}=    latestSbtsBuild    build_name=${target_build_name}    downloadable_type=A54
    log    ${sw_path}
	coam.update_software
    ...    sw_package=${sw_path}    override_ru_software=None    independent_sw_update_type=None
    ...    should_activate=True    timeout=1200    connection=${alias}    should_reset_radios=False
	sleep    540s
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    #Run Keyword and Continue on Failure    Check ActiveFaultandAlarmID    @{faultslist}
    GetSoftwareInfo    connection=${alias}

RollbackSW
	Log to console    \n Start SW Rollback \n
    coam.rollback_software    timeout=300    detailed_output=False     connection=${alias}
	sleep    300s
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    GetSoftwareInfo    connection=${alias}

BTS SW upgrade from 25R1 to 26R1
	Get_BTS_SW_version
	Run Keyword If    '${target_build_name}' != '${BTSSW_ver}' and '${source_SBTS_buildtype}' == 'SBTS25R1'
	...     Log to console    \n Downgrade required to desired build \n
	...    Downgrade BTS to 25R1

Intra-release
    IF    '${target_build_name}' == '${BTSSW_ver}'
        Log to console    \n BTS Already updated with the Target version: ${target_build_name} \n
    ELSE
        IF    '${SBTS_type}' == 'SBTS00' and '${targetSBTStype}' == 'SBTS00'
			IF    '${source_SBTS_buildtype}' == '${SBTS_type}'
				Log to console    Direct download and upgrade
				SW download and upgrade to target build
			ELSE
				Log to console    Source build download and upgrade
			END
        END
    END

BTS SW upgrade from 25R2 to 25R3
	IF    '${BTSSW_ver}' == '${target_build_name}'
		Log to console    \n No SW upgrade required
	ELSE
        IF    '${BTSSW_ver}' == '${source_SBTS_buildname}'
            Log to console    \n Current version matches source_SBTS_buildname
			SW download and upgrade to target build
        ELSE
            ${is_match}=    Evaluate    '${SBTS_type}' == '${source_SBTS_buildtype}'
            IF    '${is_match}' == 'True'
                Log to console    \n Switching to source build and upgrading to target
                Switch To Source
                sleep    540s
                SW download and upgrade to target build
            ELSE
                Log to console     \n Downgrading to source build and upgrading to target
                SBTSdowngrade
                sleep    540s
                SW download and upgrade to target build
            END
        END
    END

Updatesourcebuild
   Log to console    \n Start source build download \n
	${source_path}=    latestSbtsBuild    build_name=${source_SBTS_buildname}    downloadable_type=A54
    log    ${source_path}
	coam.update_software
    ...    sw_package=${sw_path}    override_ru_software=None    independent_sw_update_type=None
    ...    should_activate=True    timeout=1200    connection=${alias}    should_reset_radios=False
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    Run Keyword and Continue on Failure    Check ActiveFaultandAlarmID    @{faultslist}
    GetSoftwareInfo    connection=${alias}

SBTSdowngrade
    [Documentation]    SBTS downgrade to source release
    ${source_path}=    latestSbtsBuild    build_name=${source_SBTS_buildname}    downloadable_type=A54
    log    ${source_path}
    coam.reset_configuration    remove_operator_certificates=False    remove_user_account_credentials=False
    ...    timeout=500    connection=${alias}    detailed_output=False    reset_type=None
    Sleep    300s
    coam.teardown_all_aliases_for_admin
    fdsw.connect_to     ip_address=${bts_host}    port=${port}    username=${btsusername}    password=${btspassword}
    ...    fdsw_version=${fdsw_version}    auto_discover=True     secure=True    connection=none
    fdsw.software_update    sw_pkg_path=${source_path}    timeout=1500    activate=true
    Sleep    300s
    coam.setup_admin    bts_host=${bts_host}    bts_port=${port}    username=${btsusername}    password=${btspassword}
    ...    timeout=30    name=${alias}
    coam.perform_commissioning    bts_id=${bts_id}    scf_file=${source_SCF}/${25R2_SCF_name}
    ...    skip_parameter_relation_errors=False    should_activate=True    timeout=300    connection=${alias}
    #Copy_swconfigFile

Copy_swconfigFile
    os.run    scp ${source_SCF}/swconfig.txt toor4nsn@192.168.255.129:/ffs/run
    SSHLibrary.Open Connection    host=${BTS_ADDRESS}
    SSHLibrary.Login   username=toor4nsn     password=oZPS0POrRieRtu    delay=10
    SSHLibrary.write    cd /ffs/run
    SSHLibrary.read     delay=3s
    SSHLibrary.write    crasign swconfig.txt
    SSHLibrary.read     delay=3s
    SSHLibrary.write    craverify swconfig.txt*
    SSHLibrary.read     delay=3s
    SSHLibrary.write    reboot
    SSHLibrary.read     delay=3s
    SSHLibrary.Close Connection
    Sleep    180s

Check_BTS_State
    ${bts_state}=    coam.get_mrbts_state    connection=${alias}
    BuiltIn.Log                   [INFO] BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    onAir    ignore_case=${TRUE}

CheckFJTparamtersAfterTargetUpgrade
    FetchingRadioDistnameAndRelatedInfo
    ${vclen}=    Get Length    ${vendorcodes}
    FOR    ${i}    IN RANGE     ${vclen}
        IF    "${vendorcodes[${i}]}" == "${FJ}"
            ${fjcounter2}=    Evaluate    ${fjcounter2}+1
        END
    END
	Run Keyword If    "${fjcounter2}" > "1"    FJRadioBuildCheck
    Run Keyword If    "${fjcounter2}" == "1"   Log    "Legacy radios do not need any additonal checks"

UpdateORUsoftware
    [Arguments]    ${sw_package}
    Log    ${sw_package}
    admin.update_software
    ...    sw_package=${sw_package}    should_activate=True    timeout=1000
	...    connection=${alias}    should_reset_radios=true
    Wait until keyword succeeds    10m    20s    Check_BTS_State


Check ActiveFaultandAlarmID
    #[Arguments]    @{fault_list}
    ${alr}=     coam.get_active_alarms    connection=${alias}
    log     ${alr}
    ${alr_num}=     coam.get_active_alarms_number    connection=${alias}
    Log    ${alr_num}
    FOR    ${i}    IN RANGE   ${alr_num}
        Log    ${alr}[${i}][faultName]
        ${Alrstring}=    Convert To String    ${alr}[${i}][alarmId]
        ${fltstring}=    Convert To String    ${alr}[${i}][faultId]
        run keyword and continue on failure    should contain any    ${fltstring}    @{fault_list}
        run keyword and continue on failure    should contain any    ${Alrstring}    @{fault_list}
    END

FetchingRadioDistnameAndRelatedRadioInfo
    ${listofradios}=    admin.get_radio_list    timeout=60    detailed_output=False    connection=${alias}
    ${a}=     Get Length    ${listofradios}[radioModules][rmod]
    FOR    ${i}    IN RANGE    ${a}
        FetchRU_VendorCodeAndProtocol    ${listofradios}[radioModules][rmod][${i}][id][configuration]
    END

FetchRU_VendorCodeAndProtocol
   [Arguments]    ${configvalues}
   ${radioparams}=  admin.get_parameter_by_distname    dist_name=${configvalues}
       ...    parameter_list=none    include_children=None    timeout=60
	   ...    detailed_output=False    connection=${alias}
   FOR    ${i}    IN    @{radioparams}
        Run keyword and ignore error     Append to list    ${vendorcodes}    ${i['parameters']['vendorCode']}
        Run keyword and ignore error     Append to list    ${protocols}    ${i['parameters']['protocol']}
   END
   Set Global variable    ${vendorcodes}
   Set Global variable    ${protocols}

CheckProtocol
    [Documentation]    Check protocol and differentiate legacy setup from O-RAN setup
    ${orancounter}      Set Variable    1
    ${prtlen}=    Get Length    ${protocols}
    FOR    ${i}    IN RANGE     ${prtlen}
        IF    "${protocols[${i}]}" == "O-RAN"
            ${orancounter}=    Evaluate    ${orancounter}+1
        END
    END
    Run Keyword If    "${orancounter}" == "1"    UpgradetosourceSWpathNonORAN
    Run Keyword If    "${orancounter}" > "1"     CheckORANtype

Configure Netconf Credentials
    admin.configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=${alias}
    ...    accounts=@{sudo_list}

Switch To Source
    Log to console    \n Start source build download \n
    ${source_path}=    latestSbtsBuild    build_name=${source_SBTS_buildname}    downloadable_type=A54
    log    ${source_path}
	coam.update_software
    ...    sw_package=${source_path}    override_ru_software=None    independent_sw_update_type=None
    ...    should_activate=True    timeout=1200    connection=${alias}    should_reset_radios=False
	sleep    300s
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    Run Keyword and Continue on Failure    Check ActiveFaultandAlarmID
    GetSoftwareInfo    connection=${alias}