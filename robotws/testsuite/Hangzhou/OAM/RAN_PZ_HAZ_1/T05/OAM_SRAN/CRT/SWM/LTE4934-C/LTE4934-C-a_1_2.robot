*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot


*** Variables ***
${SW Upgrade Timeout}                          25m


*** Keywords ***
TC_LTE4934-C-a_1_2_Execute SWUpload successfully when a SWDownload operation is in process
    [Documentation]    Short description.
    step1: Check active and passive sw version
    step2: Netact and software prepartion
    step3: Upload during software download
    step4: veriry sw software feedback

step1: Check active and passive sw version
    [Documentation]    Short description.
    Log step header    Step 1: Check active and passive sw version
    ${active_sw_before_master}    ${passive_sw_before_master}=    Infomodel Get SW Versions    module=MSM
    set test variable  ${active_sw_before_master}
    set test variable  ${passive_sw_before_master}
    ${release_NUM}=    should match regexp    ${active_sw_before_master}    SBTS\\d+..
    set test variable    ${release_NUM}

step2: Netact and software prepartion
    Log step header    Step 2: Netact and software prepartion
    [Documentation]    choose the target package to upgrade, first import to netact, then upgrade by netact
    ${target_path}=    Common_Find SW name    ${Target SW dir}
    set test variable  ${target_path}
    ${package name}    OperatingSystem.List files in directory    ${Target SW dir}
    ${package name}    set variable    ${package_name[0]}
    ${package_release}=    Find release version    ${package name}    ${release_list_1}    ${release_list_2}
    ...    ${release_list_3}
    ${package_release_changed}    run keyword if    '${target_release}'=='SBTS00'
    ...    Replace String Using Regexp    ${package_release}    SBTS\\d{2}[A-Z]?[0-9]?    ${release_NUM}
    ...    ELSE    set variable    ${package_release}
    set test variable    ${package_release_changed}
    set test variable    ${target_download}  ${package_release_changed}

step3: Upload during software download
    [Documentation]    Short description.
    Log step header    step3: Upload during NMS software download
    Precondition Netact with TAF
    taf.sbts.oam.coam.admin.Run Keyword In Background
    ...    update software    sw_package=${target_path}    should_activate=False    timeout=${SW Upgrade Timeout}
    ${distName_pattern}  Set variable  /MRBTS-1/RAT-1/URI-*/SESSION-*/SW_UPDATE_IND-*
    ${object}  Query Infomodel  get object ${distName_pattern} is [actionType="Download"]  timeout=5m
    Log  SW download started.  console=${TRUE}
    ${upload_status}=  taf.nms.netact.Upload SW  PLMN-PLMN/${BTS_INFO.MRBTS}
    ${result}  Query Infomodel
    ...  get object ${object['dist_name']}/SW_UPDATE_RESULT-* is [result="Successful"]  timeout=50m
    Log  SW download finished.  console=${TRUE}
    taf.nms.netact.Upload SW  PLMN-PLMN/${BTS_INFO.MRBTS}
    ${status}=    taf.nms.netact.Get MO Status    PLMN-PLMN/${BTS_INFO.MRBTS}
    set test variable    ${status}
    Log    Status: ${status}    console=${TRUE}
    [Teardown]    Run keyword and ignore error    Postcondition Netact with TAF

step4: veriry sw software feedback
    [Documentation]    Short description.
    Log step header  step4: veriry sw software feedback
    ${MO}  set variable  PLMN-PLMN/${BTS_INFO.MRBTS}
    Should be equal  ${active_sw_before_master}  ${status['${MO}']['active_sw']}
    Should be equal  ${passive_sw_before_master}  ${status['${MO}']['passive_sw']}
    #Should be equal  ${target_download}  ${status['${MO}']['planned_sw']}

Common_Find SW name
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${SW_PATH}: <description>
    ...
    ...    Returns:
    ...        ${SW_PATH_package}: <description>
    [Arguments]    ${SW_PATH}
    ${package name}    OperatingSystem.List files in directory    ${SW_PATH}
    should not be empty    ${package name}    Required package not present in ${SW_PATH}
    ${SW_PATH_package}=    Join Path    ${SW_PATH}    ${package name[0]}
    OperatingSystem.File should exist    ${SW_PATH_package}
    [Return]    ${SW_PATH_package}
