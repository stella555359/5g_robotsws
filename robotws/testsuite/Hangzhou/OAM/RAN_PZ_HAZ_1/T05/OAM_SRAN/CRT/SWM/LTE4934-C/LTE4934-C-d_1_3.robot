*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot


*** Keywords ***
TC_LTE4934-C-d_1_3_Cancel Download Software successful when the download of provision operation is in progress
    [Documentation]    Short description.
    step1: Check active and passive sw version
    step2: Netact and software prepartion
    step3: NMS software download
    step4: Veriry download result

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
    ${package name}    OperatingSystem.List files in directory    ${Target SW dir}
    ${package name}    set variable    ${package_name[0]}
    ${package_release}=    Find release version    ${package name}
    ...    ${release_list_1}    ${release_list_2}    ${release_list_3}
    ${package_release_changed}    run keyword if
    ...    '${target_release}'=='SBTS00'    Replace String Using Regexp
    ...    ${package_release}    SBTS\\d{2}[A-Z]?[0-9]?    ${release_NUM}
    ...    ELSE    set variable    ${package_release}
    set test variable    ${package_release_changed}
    set test variable    ${target_download}  ${package_release_changed}
    Log  Check build in Netact otherwise Import
    ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}=  Choose_Mid_Server4Netact  ${NETACT_SERVER_INFO.IP}
    build_download_upload_on_remote_server_and_import_to_Netact  target_sw=${package_release}
                                                            ...  release_NUM=${release_NUM}
                                                            ...  remote_ip=${Mid_Server}
                                                            ...  remote_usr=${Mid_Server_usr}
                                                            ...  remote_pwd=${Mid_Server_pwd}

step3: NMS software download
    [Documentation]    Short description.
    Precondition Netact with TAF
    ${operation_id}=    taf.nms.netact.Start SWM Operation    operation_type=download    dist_names=PLMN-PLMN/${BTS_INFO.MRBTS}
    ...                                        package=${package_release_changed}
    sleep  30s
    ${progress}=    taf.nms.netact.Get Progress Of SWM Operation    ${operation_id}
    Log    \nProgress: ${progress}    console=${TRUE}
    Cancel operation by command on netact  ${operation_id}
    sleep  60s
    Wait until keyword succeeds  5m  10s  taf.nms.netact.Upload SW    PLMN-PLMN/${BTS_INFO.MRBTS}
    ${status}=    taf.nms.netact.Get Mo Status    PLMN-PLMN/${BTS_INFO.MRBTS}
    set test variable  ${status}
    Log    Status: ${status}    console=${TRUE}
    [Teardown]    Run keyword and ignore error    Postcondition Netact with TAF

Cancel operation by command on netact
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${operation_id}: <description>
    [Arguments]  ${operation_id}
    Open Connection    ${NETACT_SERVER_INFO.IP}
    Login    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    Set Client Configuration    timeout=10min
    set test variable  ${commands_cancel}  swmCLI.sh -op cancel -id ${operation_id}
    SSHLibrary.Write    ${commands_cancel}
    ${result}    SSHLibrary.Read Until    Cancelled.
    sleep  30s
    log    ${operation_id} status: ${result}

step4: Veriry download result
    [Documentation]    Short description.
    Log step header  step4: veriry sw software feedback after download from netact
    ${MO}  set variable  PLMN-PLMN/${BTS_INFO.MRBTS}
    Should be equal  ${active_sw_before_master}  ${status['${MO}']['active_sw']}
    Should be equal  ${passive_sw_before_master}  ${status['${MO}']['passive_sw']}
    Should be equal  ${status['${MO}']['planned_sw']}  ${EMPTY}

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
