*** Settings ***

Documentation
...   author: Kuldeep Kastuv and Rubina Nath and Rajarshi Mandal
...   contact: kuldeep.kastuv@nokia.com or rubina.nath@nokia.com or rajarshi.mandal@nokia.com
...   Description: Test Suite for Smart Software Update in Legacy and O-RAN Customer Testlines
...                General Information for Test Suite
...                :Precondition of testbed: Current code is not implemented for DualCore, additional Netconf account.
...                :Please keep all SCF, swconfig and O-RU related builds(related to source Build) in mentioned paths.
...                :Update all variables correctly as per testline usage, remaining script is generalised.

Library     SSHLibrary
Library     BuiltIn
Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem     WITH NAME    os
Library     taf.nms.netact    WITH NAME    netact
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     taf.collectors.core   WITH NAME   core
Library     taf.collectors.btslog  WITH NAME   btslog
Library     taf.fdsw.rc  WITH NAME   fdsw

Library      testsuite/Bangalore/ORAN/resources/python/downloadwftpackage.py

*** Variables ***

#BTSRelatedParameters
${bts_id}=                111111
${BTS_ADDRESS} =          192.168.255.129
${btsusername}=           Nemuadmin
${btspassword}=           nemuuser
${ssh_username}=          toor4nsn
${ssh_password}=          oZPS0POrRieRtu
${connection}=            default
${BTS_path}=              /home/ute/logs
${port}=                  443
@{faultslist}=            61652    61649    4681    4655    4654    61524

#BuildRelatedParameters#
###Precondition to create a folder with base build name (eg. SBTS25R2 or SBTS24R3)###
###Precondition to keep base release SCF and RFM plugin in the path###
###If dedicated base build is available for downgrade variable is yes,
...    else Mention it as "no" to download a new base build###

###Source Software ###
${sourcebasebuildavailable}=     yes
${fullsourcebasebuild}=          SBTS25R2_ENB_0000_000562_000000   #Build name if a dedicated base build is available#
${sourceRelease}=                SBTS00     #SourceRelease#
${sourceScfpath}=                /home/ute/${sourceRelease}/SCF.xml   #Path of base build SCF#
${rfmpluginpath}=                /home/ute/${sourceRelease}/RFMPlugin_O-RU_FJ_TA08029-B311-01_0003.zip    #RFM plugin for FJT#
${fdsw_version}=                 FDSW25A
###Example: FDWS25A is the FDWS for SBTS25R2 release builds,find it in sub-builds section of WFT link for base release build###

###Target Software ###
${targetRelease}=         SBTS00    #TargetRelease#
${SWpromTAG}=             REGRESSION     #TagtoDownloadBuildfromCoops(eg.REGRESSION/CDRT)#
${currentTrunk}=          SBTS26R1       #SetCurrentTrunk,example:"SBTS00"NowEquals"SBTS26R1"
### Update below parameters for your Choice of Build to Download
### yes : Download the build by the choice of user
### no  : download latest released build from coops link ###
${DownloadSWBuildbyUserChoice}=        no  ##If yes, provide Build in ${SWBuildID_UserChoice}##
${SWBuildID_UserChoice}=               SBTS00_ENB_9999_250722_000005

#O-RANRelatedParameters
&{FJsw_compatibility}=    SBTS24R3=02
...                       SBTS25R1=03
...                       SBTS25R2=04
...                       SBTS25R3=05
...                       SBTS26R1=06
${FJTusername}=           ca_fujitsu_nok
${FJTpasswd}=             Fujitsu@123
${AWHusername}=           nath
${AWHpasswd}=             cmVmdGtuOjAxOjE4MTI1NDQ2NTE6cGtNbGRDNldJWkdvd0NKZ05wamF6T05pRExK
@{vendorcodes}=           @{EMPTY}
@{protocols}=             @{EMPTY}

#NetconfCredentialsRelatedParameters
&{default_user_fj}=    	  defaultNetconfAccountName=fjncuser0
...                    	  defaultNetconfAccountPwd=ncCl2fjRu+autH0
&{authenticationfj}  	  id=1    defaultNetconfAccount=&{default_user_fj}
@{fjt_oru_creds}=      	  &{authenticationfj}
&{default_user_nk}=    	  defaultNetconfAccountName=nkoranuser
...                    	  defaultNetconfAccountPwd=FZYYERJkStMK7LQWwjHerkbldhO03LPb47NQtkftbm9Z
&{authenticationnk}  	  id=2    defaultNetconfAccount=&{default_user_nk}
@{NK_oru_creds}=      	  &{authenticationnk}
@{mix_oru_creds}=         &{authenticationfj}    &{authenticationnk}

#Mantaray Operations Variables
${mo_id}=    			PLMN-PLMN/MRBTS-${bts_id}/MNL-1
${mo_dist_name}=	        PLMN-PLMN/MRBTS-${bts_id}
${actual_plan1}=     		Plan_SWUpload_MantaRay${bts_id}
${BackupPlan}=    		BackupPlan_SWUpload_MantaRay${bts_id}
${PLAN_DESCRIPTION}=    	requestedSW_test
${web_url}=    			https://${clab_netact}lbwas.srnblr.nsn-rdnet.net/authentication/Login
${web_user}=   			test2
${web_pwd}=    			Qwer_1234
${clab_netact}=    		srnclab1042
${fm_cm_itsmwas_hostIp}=   	10.43.48.16
${node_Username_fmwas}=	        omc
${node_password_fmwas}=         Medsql!_1893
${NETACT_NAME}=                 netact

*** Keywords ***

Trigger_Setup_Readiness_With_Intelligent_SoftwareUpdate
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
    ${latBuild}=     downloadwftpackage.getlatest_build_from_coop    ${targetRelease}    ${SWpromTAG}
    Log to console    \nTarget Build Downloaded
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
    IF  "${DownloadSWBuildbyUserChoice}" == "no"
        IF    '${SWactive}' == '${latBuild}'
            Log to Console     Setup is already at Latest Build, skipping Upgrade
        ELSE IF    '${SWpassive}' == '${latBuild}'
            RollbackSW
        ELSE IF    "${setDecisionForSetupReadinessActive}" != "${sourceRelease}" and "${setDecisionForSetupReadinessPassive}" != "${sourceRelease}"
            Check_SetupConfiguration_and_PerformDowngrade
        ELSE IF    "${setDecisionForSetupReadinessActive}" != "${sourceRelease}" and "${setDecisionForSetupReadinessPassive}" == "${sourceRelease}"
            RollbackSW
            Updating_Latest_SW_Via_MantaRay
        ELSE
            Updating_Latest_SW_Via_MantaRay
        END
    ELSE
        @{availableBuildList}=    Split String    ${SWBuildID_UserChoice}    _
        IF    '${SWactive}' == '${SWBuildID_UserChoice}'
            Log to Console     Setup is already at Latest Build, skipping Upgrade
        ELSE IF    '${SWpassive}' == '${SWBuildID_UserChoice}'
            RollbackSW
        ELSE IF    "${setDecisionForSetupReadinessActive}" != "${sourceRelease}" and "${setDecisionForSetupReadinessPassive}" != "${sourceRelease}"
            Check_SetupConfiguration_and_PerformDowngrade
        ELSE IF    "${setDecisionForSetupReadinessActive}" != "${sourceRelease}" and "${setDecisionForSetupReadinessPassive}" == "${sourceRelease}"
            RollbackSW
            Updating_Latest_SW_Via_MantaRay
        ELSE
            Updating_Latest_SW_Via_MantaRay
        END
    END
    Run Keyword and Continue on Failure     CheckOperationalStateOfRadios
	CleanupBuilds

GetSoftwareInfo
    [Documentation]    Get Software information from BTS in both partition
    ${SOFTWARE_VERSIONS}=    admin.get_software_info    timeout=300    connection=${connection}
    ${fullSWactive}=    Convert to String    ${SOFTWARE_VERSIONS['Active SW version']}
    ${fullSWpassive}=    Convert to String    ${SOFTWARE_VERSIONS['Passive SW version']}
    @{SWactive}=    Split String    ${fullSWactive}    _
    @{SWpassive}=    Split String    ${fullSWpassive}    _
    ${activesw} =    Set Variable    ${SWactive}[0]
    ${passivesw} =    Set Variable    ${SWpassive}[0]
    Set Global Variable    ${SWpassive}
    Set Global Variable    ${SWactive}
    Set Global Variable    ${fullSWactive}
    Set Global Variable    ${fullSWpassive}
    Set Global Variable    ${activesw}
    Set Global Variable    ${passivesw}

CheckOperationalStateOfRadios
    ${listofradios}=    admin.get_radio_list    timeout=60    detailed_output=False    connection=${connection}
    ${a}=     Get Length    ${listofradios}[radioModules][rmod]
    FOR    ${i}    IN RANGE    ${a}
        Wait until keyword succeeds    2m    5s    Should Contain Any
        ...    ${listofradios}[radioModules][rmod][${i}][status][operationalState]    enabled    ignore_case=${TRUE}
    END

CleanupBuilds
    Log to console    \nClean-up-Builds-in-VM
    Remove Directory    /home/ute/Downloads/Builds     recursive
    Remove Directory    /home/ute/robotws/RU_SW     recursive
    Remove Directory    /home/ute/robotws/FJ_SW     recursive
    Remove Directory    /home/ute/Downloads/SourceBuild     recursive

DownloadSBTS_SourceBuild
    [Documentation]    "Tester needs to define release and promotion tag before starting the scenario."
    [Arguments]    ${Release}    ${ptag}
    ${SourceBuild_info}=    latestSbtsBuild_minus1    branch=${Release}    typeOfReg=${ptag}
    Set Global Variable    ${SourceBuild_info}

Check_BTS_Ping
    FOR    ${i}    IN RANGE    60
        ${output}=     os.run    ping 192.168.255.129 -c 10
        ${contains}=    Evaluate   "64 bytes from 192.168.255.129" in """${output}"""
        EXIT FOR LOOP IF     "${contains}" == "True"
    END

Setup_MantaRay
    Log   \n--Setup_netact--\n
    netact.Add WEB URL    ${web_url}    ${web_user}    ${web_pwd}    alias=${NETACT_NAME}
    Set Suite Variable    ${Netact}     Netact
    Log   \n--Add_cmwas_node--\n
    netact.Add Node    cmwas    ${fm_cm_itsmwas_hostIp}
    ...                         ${node_Username_fmwas}
    ...                         ${node_password_fmwas}
    ...                         alias=${NETACT_NAME}

Teardown_MantaRay
    Delete Node    cmwas    alias=${NETACT_NAME}
    Clean All    alias=${NETACT_NAME}

FJRadioReleaseCompatibilityCheck
    Configure Netconf Credentials    @{fjt_oru_creds}
    Wait until keyword succeeds    20m    20s    Check_BTS_State
    GetSoftwareInfo
    FOR    ${key}    ${value}    IN    &{FJsw_compatibility}
        Run Keyword If    "${activesw}" == "${key}"    OFEGSA_Upgrade_To_Latest_Build    ${value}
    END

OFEGSA_Upgrade_To_Latest_Build
    [Arguments]    ${value}
    ####Create and upload NMS file####
    ${NMS_File_to_netact}=    create_nms_file    username=na    password=na    auth_key=${FJTpasswd}
     ...    target_path=/home/ute/robotws/RU_SW   user=${FJTusername}    host=na    port=0    build=${FILE_PREFIX}
     ...    ru_link=https://artifactory-blr1.int.net.nokia.com/artifactory/mn-fujitsu-data-local/    radio="Fujitsu"
     ...    fjserial=${value}    data={"requestId":100,"parameters":{"name":"generateNokiaCompliantORUSWPackage"}}
    ${ZippedNMSFile}=    Set Variable    ${NMS_File_to_netact}[0]
    Set Global Variable    ${ZippedNMSFile}
    ###UpgradeRadio###
    ${status}=    Run Keyword And Return Status    AutomaticSoftwareupdateviaMantaRayORU
    Run Keyword If    not ${status}    Log to console    \nORU-SWupdate failed from Mantaray, updating via WEBEM
    Run Keyword If    not ${status}    UpdateORUsoftware    /home/ute/robotws/RU_SW/${NMS_File_to_netact}[1]

AutomaticSoftwareupdateviaMantaRayORU
    ${NMS_File_name}=    Remove string    ${ZippedNMSFile}    .zip
    ####Import build ORU####
    Log    Import Build
    netact.get_list_of_imported_builds    mo_type=MRBTS    alias=${NETACT_NAME}
    netact.import_build    build_or_file_path=/home/ute/robotws/RU_SW/${ZippedNMSFile}
    ...    version_id=${NMS_File_name}    alias=${NETACT_NAME}
    sleep    10
    netact.get_list_of_imported_builds    mo_type=MRBTS    alias=${NETACT_NAME}
    ####Create_Activate_Plan_For_RU_SW####
    Log   \n--Create_Activate_Plan_Netact--\n
    netact.add_web_url    ${web_url}    ${web_user}    ${web_pwd}    alias=${NETACT_NAME}
    ${meta_class}     ${meta_version}=    Get Actual Configuration MO Data   ${mo_id}
    log     ${meta_class}
    netact.Provision SW    ${mo_dist_name}    ${NMS_File_name}    timeout=3000    alias=${NETACT_NAME}
    #netact.download_sw    ${mo_dist_name}    ${NMS_File_name}    timeout=3000    alias=${NETACT_NAME}
    #netact.activate_sw    ${mo_dist_name}    ${NMS_File_name}    timeout=3000    alias=${NETACT_NAME}
    Wait until keyword succeeds    10m    20s    Check_BTS_State

Updating_Latest_SW_Via_MantaRay
    Log To Console    \n---Start of Latest Upgrade---
    IF   "${DownloadSWBuildbyUserChoice}" == "no"
        ${build_info}=     latestSbtsBuild   branch=${targetRelease}    typeOfReg=${SWpromTAG}
        Set Global Variable    ${build_info}
    ELSE
        ${build_info}=     latestSbtsBuild   build_name=${SWBuildID_UserChoice}    branch=${targetRelease}    typeOfReg=${SWpromTAG}
        Set Global Variable    ${build_info}
    END
    Setup_MantaRay
    ${status}=    Run Keyword And Return Status    UpdateSBTSswViaMantaRay
    Run Keyword If    not ${status}    Log to console    \nSWupdate failed for Mantaray, updating via WEBEM
    Run Keyword If    not ${status}    UpdateSBTSswViaWebEM
    admin.teardown_all_aliases_for_admin
    admin.setup_admin    bts_host=${BTS_ADDRESS}    bts_port=${port}    username=${btsusername}
    ...    timeout=30    name=default    password=${btspassword}
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    ##If O-RAN:FJ, O-RAN:NK or Mix of Both, upgrade radios accordingly
    Check_FJT_NK_RU_Build_after_SBTS_Target_Upgrade
    Align_FJPC_bychecking_FJSN
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    Teardown_MantaRay
    GetSoftwareInfo

UpdateSBTSswViaWebEM
    Wait until keyword succeeds    25m    2m    admin.update_software
    ...    sw_package=${build_info}    override_ru_software=None    independent_sw_update_type=None
    ...    should_activate=True    timeout=1500    connection=${connection}    should_reset_radios=False
    Sleep    120s
    Check_BTS_Ping

UpdateSBTSswViaMantaRay
    ####Get File Name From Path####
    ${filename}=    Evaluate    os.path.basename(r'''${build_info}''')    modules=os
    ${basename}=    Evaluate    os.path.splitext('''${filename}''')[0]    modules=os
    ${parts}=       Split String     ${basename}    _r
    ${prefix}=      Get From List    ${parts}    0
    Set Global Variable    ${FILE_PREFIX}    ${prefix}
    Get Actual Configuration MO Data    ${mo_id}
    ####Import build####
    netact.get_list_of_imported_builds    mo_type=MRBTS    alias=${NETACT_NAME}
    netact.import build     ${build_info}    version_id=${FILE_PREFIX}    alias=${NETACT_NAME}
    sleep    10
    netact.get_list_of_imported_builds    mo_type=MRBTS    alias=${NETACT_NAME}
    Log   \n--Create_Activate_Plan_Netact--\n
    netact.add_web_url    ${web_url}    ${web_user}    ${web_pwd}    alias=${NETACT_NAME}
    ${meta_class}     ${meta_version}=    Get Actual Configuration MO Data   ${mo_id}
    log     ${meta_class}
    netact.Provision SW    ${mo_dist_name}    ${FILE_PREFIX}    timeout=3000    alias=${NETACT_NAME}
    #netact.download_sw    ${mo_dist_name}    ${NMS_File_name}    timeout=3000    alias=${NETACT_NAME}
    #netact.activate_sw    ${mo_dist_name}    ${NMS_File_name}    timeout=3000    alias=${NETACT_NAME}

Check_FJT_NK_RU_Build_after_SBTS_Target_Upgrade
    FetchingRadioDistnameAndRelatedRadioInfo
    ${nkcount}    Set Variable    1
    ${fjcount}    Set Variable    1
    ${vclen}=    Get Length    ${vendorcodes}
    FOR    ${i}    IN RANGE     ${vclen}
        IF    "${vendorcodes[${i}]}" == "FJ"
            ${fjcount}=    Evaluate    ${fjcount}+1
        END
        IF    "${vendorcodes[${i}]}" == "NK"
            ${nkcount}=    Evaluate    ${nkcount}+1
        END
    END
    Run Keyword If    "${nkcount}" > "1" and "${fjcount}" == "1"    UpgradeNKORU
    Run Keyword If    "${nkcount}" == "1" and "${fjcount}" > "1"    FJRadioReleaseCompatibilityCheck
    Run Keyword If    "${nkcount}" > "1" and "${fjcount}" > "1"     UpgradeNK_FJORU

Align_FJPC_bychecking_FJSN
    ${listofradios}=    admin.get_radio_list    timeout=60    detailed_output=False    connection=${connection}
    ${rmod_in_setup}=     Get Length    ${listofradios}[radioModules][rmod]
    FOR    ${i}    IN RANGE    ${rmod_in_setup}
        ${radiodistname}=    Set Variable    ${listofradios}[radioModules][rmod][${i}][id][configuration]
        ${serialnumber}=    Set Variable    ${listofradios}[radioModules][rmod][${i}][serialNumber]
        ${match}=    Get substring    ${serialnumber}    0    3
        Run Keyword If     "${match}" == "900" or "${match}" == "000"
        ...    Perform Parameter Recommissioning    ${radiodistname}    prodCodePlanned    TA08029-B311/01
        Run Keyword If     "${match}" == "004"
        ...    Perform Parameter Recommissioning    ${radiodistname}     prodCodePlanned      TA08029-B312/01
    END

UpgradeNKORU
    Log to console    \nTestbed-with-NokiaORU-Upgrade
    Configure Netconf Credentials    @{NK_oru_creds}
    DownloadLatestBuild_NK

DownloadLatestBuild_NK
    downloadlatestRU    user=${AWHusername}    auth_key=${AWHpasswd}
    os.run    mv ${AWHBuildPath} ${AWHBuildName}
    ${awhqn_sw}    Set Variable    ${AWHBuildName}
    Set Global Variable    ${awhqn_sw}
    UpdateORUsoftware    ${awhqn_sw}

UpgradeNK_FJORU
    Log to console    \nTestbed-with-NK&FJ-Upgrade
    Configure Netconf Credentials    @{mix_oru_creds}
    DownloadLatestBuild_NK
    FJRadioReleaseCompatibilityCheck

UpdateORUsoftware
    [Arguments]    ${sw_package}
    Log    ${sw_package}
    admin.update_software
    ...    sw_package=${sw_package}    should_activate=True    timeout=1000
	...    connection=${connection}    should_reset_radios=true
    Wait until keyword succeeds    10m    20s    Check_BTS_State

RollbackSW
    Log to console    \nRollback-Triggered
    FOR    ${key}    ${value}    IN    &{FJsw_compatibility}
        Run Keyword If    "${passivesw}" == "${key}"    UpgradeFJORU    ${value}    ${fullSWpassive}
    END
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    admin.rollback_software    timeout=500    detailed_output=False     connection=${connection}
    Sleep    300s
    Check_BTS_Ping
    admin.teardown_all_aliases_for_admin
    admin.setup_admin    bts_host=${BTS_ADDRESS}    bts_port=${port}    username=${btsusername}
    ...    timeout=30    name=default    password=${btspassword}
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    GetSoftwareInfo

UpgradeFJORU
    [Arguments]    ${fjserialnumber}    ${build_name}
    ${NMS_File_to_netact}=    create_nms_file    auth_key=${FJTpasswd}    fjserial=${fjserialnumber}    host=na
    ...    target_path=/home/ute/robotws/FJ_SW   user=${FJTusername}    password=na    username=na    port=0
    ...    ru_link=https://artifactory-blr1.int.net.nokia.com/artifactory/mn-fujitsu-data-local/    radio="Fujitsu"
    ...    data={"requestId":100,"parameters":{"name":"generateNokiaCompliantORUSWPackage"}}    build=${build_name}
    UpdateORUsoftware    /home/ute/robotws/FJ_SW/${NMS_File_to_netact}[1]

Check_SetupConfiguration_and_PerformDowngrade
    FetchingRadioDistnameAndRelatedRadioInfo
    CheckProtocol
    Updating_Latest_SW_Via_MantaRay

FetchingRadioDistnameAndRelatedRadioInfo
    ${listofradios}=    admin.get_radio_list    timeout=60    detailed_output=False    connection=${connection}
    ${a}=     Get Length    ${listofradios}[radioModules][rmod]
    FOR    ${i}    IN RANGE    ${a}
        FetchRU_VendorCodeAndProtocol    ${listofradios}[radioModules][rmod][${i}][id][configuration]
    END

FetchRU_VendorCodeAndProtocol
   [Arguments]    ${configvalues}
   ${radioparams}=  admin.get_parameter_by_distname    dist_name=${configvalues}
       ...    parameter_list=none    include_children=None    timeout=60
	   ...    detailed_output=False    connection=${connection}
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

CheckORANtype
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
    Run Keyword If    "${fjcounter}" > "1" and "${nkcounter}" == "1"    UpgradetosourceSWpathFJORAN

UpgradetosourceSWpathFJORAN
    Log to console    \nTestbed-with-FJT-Upgrade
    FOR    ${key}    ${value}    IN    &{FJsw_compatibility}
        Run Keyword If    "${key}" == "${sourceRelease}"    UpgradeFJORU    ${value}    ${fullsourcebasebuild}
    END
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    SBTSdowngrade
    Sleep    100s
    Configure Netconf Credentials    @{fjt_oru_creds}
    Sleep    100s
    ######Upgrade for legacy radios######
    Wait until keyword succeeds    25m    1m    admin.update_software
    ...    sw_package=${sourceSWpath}    override_ru_software=None    independent_sw_update_type=None
    ...    should_activate=True    timeout=1800    connection=${connection}    should_reset_radios=False
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    Wait until keyword succeeds    20m    2m    admin.update_software
            ...    sw_package=${rfmpluginpath}    should_activate=True    timeout=1000
	    ...    connection=${connection}    should_reset_radios=true
    Sleep   120s
    Check_BTS_Ping
    GetSoftwareInfo

UpgradetosourceSWpathNonORAN
    Log to console    \nTestbed-with-NokiaLegacyRadios-Upgrade
    SBTSdowngrade
    ######Upgrade for legacy radios######
    admin.update_software
    ...    sw_package=${sourceSWpath}    override_ru_software=None    independent_sw_update_type=None
    ...    should_activate=True    timeout=1500    connection=${connection}    should_reset_radios=False
    Wait until keyword succeeds    10m    20s    Check_BTS_State
    GetSoftwareInfo

SBTSdowngrade
    [Documentation]    SBTS downgrade to source release
    Log to console    \nTestbed-under-configReset
    admin.reset_configuration    remove_operator_certificates=False    remove_user_account_credentials=False
    ...    timeout=700    connection=None    detailed_output=False    reset_type=None
    admin.teardown_all_aliases_for_admin
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
    ...    skip_parameter_relation_errors=False    should_activate=True    timeout=300    connection=${connection}
    Sleep    100s
    Check_BTS_Ping
    Copy_swconfigFile    ${BTS_path}/${SUITE NAME}/${Date}/SoftwareUpdateLogs/swconfig.txt
    ...    ${ssh_username}@${BTS_ADDRESS}:/ffs/run

Copy_swconfigFile
    [Arguments]    ${sourcepath}    ${targetpath}
    os.run    scp ${sourcepath} ${targetpath}
    SSHLibrary.Open Connection    host=${BTS_ADDRESS}
    SSHLibrary.Login   username=${ssh_username}     password=${ssh_password}    delay=20
    SSHLibrary.write    cd /ffs/run\n
    SSHLibrary.read     delay=3s
    SSHLibrary.write    crasign swconfig.txt\n
    SSHLibrary.read     delay=3s
    SSHLibrary.write    craverify swconfig.txt*\n
    SSHLibrary.read     delay=3s
    SSHLibrary.write    reboot\n
    SSHLibrary.read     delay=3s
    SSHLibrary.Close Connection
    Sleep    100s
    Check_BTS_Ping
