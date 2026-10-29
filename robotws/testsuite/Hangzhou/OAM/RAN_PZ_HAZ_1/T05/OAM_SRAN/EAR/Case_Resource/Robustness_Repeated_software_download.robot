*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/EAR.robot


*** Variables ***
${TIMES}    3
&{BTSsshConfig}          host_ip=192.168.255.129    ssh_port=22    ssh_username=toor4nsn    ssh_password=oZPS0POrRieRtu


*** Keywords ***
TC__Robustness_repeat_software_download
    [Documentation]
    ...  ********************
    ...  Test the background sw update can be successful.
    ...  ********************
    #[Timeout]    45 minutes
    Set Tags    CA-SWM    PHASE-CRT  FEATURE-LTE3332-b  SW-SBTS23R2
    Step1: Get active and passive SW version
    Step2: Prepare build T1
    FOR  ${i}  IN RANGE  1  ${TIMES}+1
    set test variable   ${i}
    Log to Console  ${i} times of ${TIMES}
    KW_single
    END


KW_single
    [Documentation]
    ...  ********************
    ...  Test the background sw update can be successful.
    ...  ********************
    Iteration Precondition    ${i}

    Step3: Repeated Background download
    Step4: Get active and passive SW version
    Step5: Check if sw has changed
    Step6: Get and check swdlReport and Targetbd
    Step7: Check that BTS has not been reseted
    Step8: Check final BTS state and alarm status
    Step9: Check passive is mounted as written
    [Teardown]    Iteration Postcondition    ${i}

Step${index}: Get active and passive SW version
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header  Step1: Get active and passive SW version
    ${enb_sw}    taf.sbts.oam.coam.admin.Get Software Info
    set test variable    ${pre_update_enb_sw}    ${enb_sw['Active SW version']}
    Log    Active SW: ${enb_sw['Active SW version']}    console=${TRUE}
    Log    Passive SW: ${enb_sw['Passive SW version']}    console=${TRUE}
    ${test_sw}  Create Dictionary
    ...  sw1=${release_list_1}  sw2=${release_list_2}
    set test variable    ${test_sw}
    set test variable    ${pre_update_enb_sw}  ${enb_sw['Active SW version']}

TC Teardown
    BuiltIn.Log to console    Test ended.

Step2: Prepare build T1
    [Documentation]    Short description.
    Log Step Header  Step2: Prepare build T1
    set test variable    ${destination_dir}    /home/ute/logs/
    ${active_build_T1}=  Prepare build ${destination_dir} ${test_sw['sw1']}
    Run keyword and ignore error    OperatingSystem.empty directory    /home/ute/btsauto/TARGET_SW_T1/
    Run keyword and ignore error    OperatingSystem.empty directory    /home/ute/btsauto/TARGET_SW/
    ${active_build_T2}=  Prepare build ${destination_dir} ${test_sw['sw2']}
    set test variable    ${active_build_T1}
    set test variable    ${active_build_T2}
    Run keyword and ignore error    OperatingSystem.empty directory    /home/ute/btsauto/TARGET_SW_T2/

Step3: Repeated Background download
    [Documentation]    Short description.
    Log Step Header  Step3: Repeated Background download
    Repeated Background download    ${active_build_T1}

Step5: Check if sw has changed
    [Documentation]    Short description.
    Log Step Header  Step5: Check if sw active partion has been changed after software download.
    ${post_enb_sw}    taf.sbts.oam.coam.admin.Get Software Info
    set test variable    ${post_enb_sw}    ${post_enb_sw['Active SW version']}
    Should be equal    ${pre_update_enb_sw}    ${post_enb_sw}

Step6: Get and check swdlReport and Targetbd
    [Documentation]    Short description.
    Log Step Header  Step6: Get and check swdlReport and Targetbd
    Setup Enb Fsm Access
    #Get eNB targetbd file     destination= ${BTSFiles}/targetbd.xml
    Get Enb File  source=/rom/config/SWDLreport.txt  destination=${BTSFiles}/
    ${passive_partition}=    Get Enb Partition Path    partition=passive   alias=default
    [Teardown]  Teardown Enb Fsm Access

Step7: Check that BTS has not been reseted
    [Documentation]    Short description.
    Log Step Header  Step7: Check that BTS has not been reseted
    set test variable  ${RESET_REQ_path}  /MRBTS-1/RAT-1/BTS_L-*/FUNC_L-1/RESET_REQ-*
    ute_admin_infomodel.Save infomodel log     filename=check_reset_infomodel.ims2     timeout=300
    ${change_sets} =  ute_admin_infomodel.get change sets
    ...    filename=check_reset_infomodel.ims2  event=create ${RESET_REQ_path}
    Should Be Empty      ${change_sets}

Step8: Check final BTS state and alarm status
    [Documentation]    Short description.
    Log Step Header  Step8: Check final BTS state and alarm status
    Wait until keyword succeeds  15min  10 sec  Verify BTS states
    Log Important Message  BTS is OnAir, all cells and modules are in expected states, no new alarm.

Step9: Check passive is mounted as written
    [Documentation]    Short description.
    Log Step Header  Step9: Check passive is mounted as written
    Check passive is mounted as written

Check passive is mounted as written
    [Documentation]    Short description.
    Setup Enb Fsm Access     alias=enb1
    ${passive_partition_path}=  Execute Command on Enb   ls -lai /ffs/stb | awk -F' ' '{print $12}'  alias=enb1
    ${mount_settings}=  Execute Command on Enb  grep "${passive_partition_path}" /etc/mtab  alias=enb1
    Should contain  ${mount_settings}  rw,
    [Teardown]  Teardown Enb Fsm Access  alias=enb1

Repeated Background download
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${limit}: <description>
    ...        ${active_build_T1}: <description>
    [Arguments]  ${active_build_T1}
    Background download ${active_build_T1}
    Background download ${active_build_T2}


Background download ${trunk_load}
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trunk_load}: <description>
	taf.sbts.oam.coam.admin.Update Software   sw_package=${trunk_load}   should_activate=False   timeout=3000
	Wait until eNB reaches configured state
	Sleep    600

Wait until eNB reaches configured state
    [Documentation]    Short description.
    set test variable  ${MRBTS_DN}  /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-1/LNBTS_M-*
    Wait Until Keyword Succeeds  500s  10s  ute_admin_infomodel.Query infomodel
    ...   query=${MRBTS_DN} is [stateInfo.proceduralState=regex"Configured|IntegratedToRan|OnAir"]    timeout=50

Prepare build ${destination_dir} ${current_build}
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${destination_dir}: <description>
    ...        ${current_build}: <description>
    ...
    ...    Returns:
    ...        ${T1_fullpackage_path}: <description>
    ${download_build}=    Run Keyword If
    ...  '9999' in '${current_build}'
    ...  Replace String Using Regexp    ${current_build}    SBTS\\d{2,2}\\w[0-9]?_    SBTS00_
    ...  ELSE    Set variable    ${current_build}
    ${t1_relative_url}=   Set Variable     ${download_build}_release_BTSSM_downloadable_testpackage_T1.zip
    ${download_relative_url}   Set Variable    ${t1_relative_url}
    ${T1_fullpackage_path}    Download_Specify_Build_By_Aria    ${download_build}    T1    ${destination_dir}
    [Return]  ${T1_fullpackage_path}

