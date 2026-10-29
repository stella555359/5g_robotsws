*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
#Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_syve.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
#Library           hran_tools
Library             ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library           taf.sbts.oam.coam.admin
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py


*** Variables ***
${TARGET_SW_NAME}       ${None}                     # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}    /home/ute/btsauto/TARGET_SW/    # Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW'
${UPDATE_TIMEOUT}       1500                        # Timeout for Download and Activation [sec]
${SW Download Timeout}    1800
${SW Activation Timeout}                      150  # Given in seconds; That is a timeout for SW download and activation (without reset)
${Ping loss timeout}                          420  # Timeout for ping loss during reset
${Ping regain timeout}                        600  # Timeout for ping regain during reset
${BTS_OnAir_Timeout}                          15  # Timeout for BTS on Air (in minutes)
${Test_Timeout}                               30  # Test timeout (in minutes)
${onAir Check Number}                         60  # Number of checks for proceduralStatus: onAir after RMODs reset is complete; check interval = 10s


*** Keywords ***
SWM_eNB_reboot_during_SWDL
    [Documentation]    ********************
    ...    1. Basic information
    ...    ********************
    ...
    ...    ***********************************************************
    ...    2. Description
    ...    ***********************************************************
    ...    Main purpose of this test is to verified unsingned package update
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    [Timeout]    100 minutes
    Set Tags    CA-SWM    PHASE-CRT    SW-SBTS22R2    FEATURE-LTE3340

    Check if BTS onAir
    Check active and passive sw version
    Netact and software prepartion
    Reboot during NMS software download
    Check BTS is stable after reset
    Check if BTS onAir

Check active and passive sw version
    [Documentation]    Short description.
    Log step header    Step 1: Check active and passive sw version
    ${active_sw_before_master}    ${passive_sw_before_master}=    Infomodel Get SW Versions    module=MSM
    set test variable  ${active_sw_before_master}
    set test variable  ${passive_sw_before_master}
    ${release_NUM}=    RUN KEYWORD IF    '${target_release}'=='SBTS00'     set variable    SBTS26R2
    ...    ELSE    should match regexp    ${active_sw_before_master}    SBTS\\d+..
    set test variable    ${release_NUM}

Netact and software prepartion
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

Reboot during NMS software download
    [Documentation]    Short description.
    Precondition Netact with TAF
    ${operation_id}=    taf.nms.netact.Start SWM Operation    operation_type=download    dist_names=PLMN-PLMN/${BTS_INFO.MRBTS}
    ...                                        package=${package_release_changed}
    ${progress}=    taf.nms.netact.Get Progress Of SWM Operation    ${operation_id}
    sleep  4min
    Log    \nProgress: ${progress}    console=${TRUE}
    [Teardown]    Run keyword and ignore error    Postcondition Netact with TAF
    Reboot BTS During SW Update

Reboot BTS During SW Update
    [Documentation]    Short description.
    Log    Reset will be performed after 10 sec    console=true
    Sleep    10
    Setup hran compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Verify SSH connection and enable if necessary
    Log  Will now trigger bts reboot  console=${TRUE}
    Set Connection Parameters  ip=${SMOD1['TRS_IP']}   user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
    ${run_output}  Run Remote Linux Command  ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    Sleep    2s
    Log    Reset was performed    console=true

Check BTS is stable after reset
    [Documentation]    Short description.
    log to console with time  Check if reset is performed
    ${ping_loss}  Run keyword and return status  Wait for target to be not reachable  hostname=192.168.255.129  timeout=480
    log to console with time  Reset completed. Waiting for eNB to be pingable...
    Run keyword if    not ${ping_loss}  Fail  Activation reset was not performed.
    Log  Waiting for ping return  console=${TRUE}
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=240
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    Log  Waiting for reset  console=${TRUE}
    ${ping_status}  Check If Target Is Stable  192.168.255.129  min_uptime=360  max_downtime=420  timeout=1500
    Run keyword if    not ${ping_status}  Fail  BTS is not stable after Reset
    Log  BTS is stable after Reset.  console=${TRUE}

Check if BTS onAir
    [Documentation]    Short description.
    Log  Will now check if BTS is OnAir, timeout=${BTS_OnAir_Timeout}min, interval=10sec  console=${TRUE}
    Wait until keyword succeeds  ${BTS_OnAir_Timeout} min  10 sec  Check SBTS SOAM cells and modules
    Log Important Message  BTS is OnAir, all cells and modules are in expected states

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

Find release version
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${package name}: <description>
    ...        ${release_1}: <description>
    ...        ${release_2}: <description>
    ...        ${release_3}: <description>
    ...
    ...    Returns:
    ...        ${release}: <description>
    [Arguments]    ${package name}    ${release_1}    ${release_2}    ${release_3}
    ${release}=    set variable if    '${release_1}' in '${package name}'    ${release_1}    '${release_2}' in '${package name}'    ${release_2}
    ...    '${release_3}' in '${package name}'    ${release_3}
    [Return]    ${release}
