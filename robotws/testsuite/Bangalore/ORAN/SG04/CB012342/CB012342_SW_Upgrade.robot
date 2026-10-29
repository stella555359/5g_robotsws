*** Settings ***

Documentation   ---SW Download & Update to BTS via WebEM/NMS---
Library    Process
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.nms.netact    WITH NAME    nms
Library    taf.selenium.sbts    WITH NAME    sbts
Library    ./testsuite/Bangalore/ORAN/SG04/resources/sg04_local_keywords.py
Library    String
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/collect_logs.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Library     Collections

#Variables      /home/ute/testsuite/Bangalore/ORAN/SG04/resources/TL02_parameters.py
#Variables    /home/ute/testsuite/Bangalore/ORAN/SG04/resources/CRT4_parameters.py
*** Variables ***
${SW_Ver_usr}=    SBTS00_ENB_9999_241018_000005
${SW_DESTINATION}=    /home/ute/Downloads
${ORU_SW}=    FJ-RU-ET1---------0202.FGF
${non_def_BTS_IP}=     192.168.255.129
${LTE_BTS_IP}=         10.58.239.89
${scf_pat}=    /home/ute/Downloads
${NETACT_NAME}=    srnclab1042
${NetAct_host}=    10.43.48.16
${NetAct_uname}=    omc
${NetAct_pwd}=    Medsql!_1893
${DIST_NAMES} =    PLMN-PLMN/MRBTS-970
${DIST_NAME2} =    PLMN-PLMN/MRBTS-969
${is_TrunkBuild}=    True
${ORU_SW_USR_VERSION}     FJ-RU-ET1---------0200.FGF_NMS
${resources_path}    /home/ute/robotws/testsuite/Bangalore/ORAN/SG04/resources
*** Test Cases ***
SW Download & Update to BTS via WebEM
    BTS SW Download and Update from WebEM
    Rollback To Passive SW
    SW Update from NMS
    ORU SW Update from NMS
    ORU SW Update from WebEM

*** Keywords ***

BTS SW Download and Update from WebEM
    coam.setup_admin	bts_host=${LTE_BTS_IP}

    ${SW_Ver}    coam.get_sw_version
    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${SW_Ver}      _9999_
    ${SW_Ver1}=     Run keyword if
    ...           ${is_TrunkBuild}==True        Replace String Using Regexp    ${SW_Ver}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...  ELSE     Set variable   ${SW_Ver}
    Log to console  \n BTS_SW_Ver_usr: ${SW_Ver1} \n
    Run Keyword If    "${SW_Ver1}" == "${SW_Ver_usr}"	Log to console  \n BTS Already updated with the Target version: ${SW_Ver_usr} \n
    ...    ELSE    Fetch_Required_Enb_SW    Req_Enb_SW_ver=${SW_Ver_usr}    current_bts_SW_ver=${SW_Ver1}    is_trunk_build=${is_TrunkBuild}
    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    Log to Console     \n --SW_Update Started-- \n
    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    coam.update_software
    ...    ${SW_DESTINATION}/${SW_Ver_usr}_release_BTSSM_downloadable_A54.zip
    ...    should_activate=True    timeout=1600    connection=default    should_reset_radios=True

    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    sleep    400s
    Log to console    \n--SW Download and Update Completed--\n

    coam.teardown_admin

ORU SW Update from WebEM
    coam.setup_admin	bts_host=${LTE_BTS_IP}
    Log to console    \n--ORU SW Update--\n

    ${runningSwVersion1}=	Get ORU Sw Version Before Provision
    Log to console	${runningSwVersion1}
    ${result}=    Get Substring    ${ORU_SW}    -7    -4
    ${RU_VER}=    Convert To Integer    ${result}
    Log to console    \n to update fjt: ${RU_VER}
    Run Keyword If    "${runningSwVersion1}" != "${RU_VER}"    coam.update_software
    ...    ${resources_path}/${ORU_SW}.zip
    ...    should_activate=True    timeout=1600    connection=default    should_reset_radios=True

    Run Keyword If    "${runningSwVersion1}" != "${RU_VER}"    sleep    400s
    #Check BTS is OnAir
    ${runningSwVersion2}=	Get ORU Sw Version After Provision
    Log to console	${runningSwVersion2}

    Log to console    \n--ORU-SW Update Completed--\n
    coam.teardown_admin

SW Update from NMS
    Log to console	\n SW Update from NMS STARTED \n
    coam.setup_admin	bts_host=${non_def_BTS_IP}
    Add Node    itsmwas    ${NetAct_host}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}
    ${SW_Ver}    coam.get_sw_version
    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${SW_Ver}      _9999_
    ${is_TrunkBuild_import}=     Run Keyword and Return Status    Should Contain      ${SW_Ver_usr}      _9999_
    ${sw_import_ver}=     Run keyword if
    ...           ${is_TrunkBuild_import}==True        Replace String Using Regexp    ${SW_Ver_usr}    ^SBTS[A-Za-z0-9]+_    SBTS25R1_
    ...  ELSE     Set variable   ${SW_Ver_usr}
    ${SW_Ver1}=     Run keyword if
    ...           ${is_TrunkBuild}==True        Replace String Using Regexp    ${SW_Ver}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...  ELSE     Set variable   ${SW_Ver}
    Log to console  \n BTS_SW_Ver_usr: ${SW_Ver1} \n
    Log to console   \n build import version : ${sw_import_ver} \n
    Run Keyword If    "${SW_Ver1}" == "${SW_Ver_usr}"	Log to console  \n BTS Already updated with the Target version: ${SW_Ver_usr}

    ${Build_status}=	Is Imported    ${sw_import_ver}    alias=${NETACT_NAME}

    Run Keyword If	${Build_status}==True    Log to console    \n-- BTS SW available in NMS --\n


    Run Keyword If	${Build_status}!=True    Log to console	\n SW Build not available in NMS... import SW build then Proceed!!\n
    Run Keyword If    ${Build_status} and "${SW_Ver1}" != "${SW_Ver_usr}"    nms.provision_sw    dist_names=${DIST_NAMES}
    ...    package_name=${sw_import_ver}
    ...    timeout=700    alias=${NETACT_NAME}


    Run Keyword If    "${SW_Ver1}" != "${SW_Ver_usr}"    sleep    400s
    Check BTS is OnAir
    Clean All    alias=${NETACT_NAME}
    Log to console	\n SW Update from NMS completed \n

ORU SW Update from NMS
    Log to console    \n--ORU SW Update from NMS--\n
    coam.setup_admin	bts_host=${LTE_BTS_IP}
    ${runningSwVersion1}=	Get ORU Sw Version Before Provision
    Log to console	\n ${runningSwVersion1} \n
    ${SW_VERSION}=
    ...     Run Keyword If    "${runningSwVersion1}"!="${ORU_SW_USR_VERSION}"    Set Variable    ${ORU_SW_USR_VERSION}
    ...     ELSE    Log to console    \n  ORU already in latest sw version
    Log to console	\n Initial SW Version to be used:    ${SW_VERSION}
    Add Node    itsmwas    ${NetAct_host}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}
    Run Keyword And Ignore Error    Delete Build    ${SW_VERSION}    mo_type=MRBTS    alias=${NETACT_NAME}
    ${Build_status}=	Is Imported    ${SW_VERSION}    alias=${NETACT_NAME}
    Log to console   --\n ORU SW version Build status: ${Build_status} \n--
    Run Keyword If	${Build_status}==True    Log to console    \n-- ORU SW available in NetAct skip SW import--\n
    ...    ELSE   Import Build    ${resources_path}/${SW_VERSION}.zip    mo_type=MRBTS	alias=${NETACT_NAME}
    Sleep	60s
    Log to console  \n--Performing SW Update from NetAct--\n
    ${operation_id}=    Start SWM Operation    operation_type=provision    dist_names=${DIST_NAME2}
    ...                                        package=${SW_VERSION}    alias=${NETACT_NAME}
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
    Log    \nProgress: ${progress}    console=${TRUE}
    #Wait For SWM Operation    ${operation_id}    timeout=1800    alias=${NETACT_NAME}
    Sleep	360s
    ${progress}=    Get Progress Of SWM Operation    ${operation_id}    alias=${NETACT_NAME}
    Log    \nProgress: ${progress}    console=${TRUE}
    Clean All    alias=${NETACT_NAME}
    ${progress1}=	Convert to Integer	${progress['Successful']}
    Log to console	\n SW Provision Successful Status: ${progress1}
    Should Be True    ${progress1}==1
    Log to console  \n--Wait for O-RUs to come UP --\n


    ${runningSwVersion2}=	Get ORU Sw Version After Provision
    Log to console	${runningSwVersion2}
    coam.teardown_admin
    Log to console  \n-- ORU SW Update from NMS PASSED --\n

Rollback To Passive SW
    Log to console    \n--Rollback to Passive SW--\n
    coam.setup_admin	bts_host=${LTE_BTS_IP}
    coam.rollback_software    timeout=300
    sleep    400s
    coam.teardown_admin
    Log to console    \n-- Rollback step completed -- \n

Check BTS is OnAir
    [Documentation]    Check the BTS current status
    ${bts_status}    coam.get_bts_statuses
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    OnAir
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}

Get ORU Sw Version Before Provision
    ${bts_info}=    coam.get_bts_info
    ${SwVersion_tmp1}=    Create List	${bts_info['radioModules']['rmod'][0]['swInfo']['runningSwVersion']}
    Log To Console	\n O-RU SW Version Before Provision: ${SwVersion_tmp1[0]}
    ${SwVersion_tmp2}=    Split string    ${SwVersion_tmp1[0]}     separator=_    max_split=3
    #${SwVersion_tmp3}=    Split string    ${SwVersion_tmp2[0]}     separator=-    max_split=2
    #${SwVersion_tmp4}=    Split String To Characters    ${SwVersion_tmp3[2]}
    ${runningSwVersion}=	Convert to Integer	${SwVersion_tmp2[1]}
    [Return]    ${runningSwVersion}

Get ORU Sw Version After Provision
    ${bts_info}=    coam.get_bts_info
    ${SwVersion_tmp1}=    Create List	${bts_info['radioModules']['rmod'][0]['swInfo']['runningSwVersion']}
    Log To Console	\n O-RU SW Version After Provision: ${SwVersion_tmp1[0]}
    ${SwVersion_tmp2}=    Split string    ${SwVersion_tmp1[0]}     separator=_    max_split=3
    #${SwVersion_tmp3}=    Split string    ${SwVersion_tmp2[0]}     separator=-    max_split=2
    #${SwVersion_tmp4}=    Split String To Characters    ${SwVersion_tmp3[2]}
    ${runningSwVersion}=	Convert to Integer	${SwVersion_tmp2[1]}
    [Return]    ${runningSwVersion}

