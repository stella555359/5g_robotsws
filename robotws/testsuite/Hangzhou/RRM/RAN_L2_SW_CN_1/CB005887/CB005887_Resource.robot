*** Settings ***
Library     taf.transport.ssh    WITH NAME    ssh
Resource    ../CUDU_L2/common_setup_teardown.robot

*** Keywords ***
Hard Reboot TL If Coam Site Not Ready
    ${coam_site}    Run Keyword And Return Status    Verify Coam Site Is Ready
    run keyword if    "${coam_site}"!="True"    Do Hard Reboot TL And Check Coam Again

Do Hard Reboot TL And Check Coam Again
    Hard Reboot Testline
    ${coam_site_hard_reboot}    Run Keyword And Return Status    Verify Coam Site Is Ready

Set AP RD Parameters Per gNB Release Build
    Get Software Version
    ${RD_PARAM_AP}=    Set Variable If
	...    "${SW_BRANCH}"=="SBTS22R4"    0x70649=12;0x70005=140;0x70690=1;0x420028=0;0x20124=4;0x10057=1
	...    "${SW_BRANCH}"=="SBTS23R1"    0x70649=13;0x70005=160;0x70690=1;0x420028=0;0x20124=4;0x10057=1
	...     0x70690=1;0x420028=0;0x20124=4;0x10057=1
    Set Suite Variable    ${RD_PARAM_AP}
    Log    ${RD_PARAM_AP}
    Log    0x70649 and 0x70005 parameters need to adjust in l1bypass mode per gNB branch build
	Log    0x420028=0 for Deploy L2RT in container; 0x20124=4 for syscom to work over SCTP; 0x10057=1 for AaSysComMsgRerouteEnable

Delete AP RD Parameters
    [Arguments]    ${rd_del}=0x70649;0x70005
    ${rd_path_ap}    Get Swconfig File From Airphone    ${OUTPUT_DIR}
    Delete Swconfig File Parameters    ${rd_path_ap}    ${rd_del}
    Send Swconfig File To Airphone    ${rd_path_ap}

Config Endc Parameter
    [Arguments]    ${CC_Num}=4
    ute_wtssim.Execute Egate Command
    ...    cmd=enb_endc_param id=1 serving_cell_index_range_scg=1:${CC_Num}

NSA Start Large Dl Traffic
    [Arguments]    ${ue_id}=16
    : For    ${trf_id}    IN RANGE    1    11
    \    NSA Start DL Traffic    ${ue_id}    2    150    ${trf_id}
    \    Sleep    2s    reason=wait for traffic stable

NSA Stop Large Dl Traffic
    [Arguments]    ${ue_id}=16
    : For    ${trf_id}    IN RANGE    1    11
    \    NSA Stop Traffic    ${ue_id}    2    dl    ${trf_id}
    \    Sleep    2s    reason=wait for traffic stop

NSA Start Large Ul Traffic
    [Arguments]    ${ue_id}=16
    : For    ${trf_id}    IN RANGE    1    5
    \    NSA Start UL Traffic    ${ue_id}    2    100    ${trf_id}
    \    Sleep    2s    reason=wait for traffic stable

Egate Console Confirm Scell Activated Success
    [Arguments]    ${CC_Num}=4
    ute_wtssim.Execute Egate Command    sim_log_set flush
    OperatingSystem.Run    cp /opt/iphy/latest/egate_console.log ${output_dir}/egate_console.log
    : For    ${scell_index}    IN RANGE    2    ${CC_Num}+1
    \    ${egate_scell_activate_tag}    OperatingSystem.Grep File    ${output_dir}/egate_console.log
    ...    SCellIndex ${scell_index} activated successfully at airphone
    \    Should Not Be Empty    ${egate_scell_activate_tag}

Check CA Scell And Pcell DL Tput
    [Arguments]    ${scf_file}    ${syslog}    ${CC_Num}=4
    ${temp_dl_tput}    Set Variable    0
    : For    ${scell_index}    IN RANGE    1    ${CC_Num}+1
    \    ${nrCellIdentity}    Get NrCellIdentity From SCF    ${scf_file}    ${scell_index}
    \    ${dl_tput}    Get Scell DL Latest Tput From Syslog    ${syslog}    ${nrCellIdentity}
    \    ${temp_dl_tput}    Evaluate    ${temp_dl_tput}+${dl_tput}
    \    Should Be True    ${dl_tput} >= 0
    Should Be True    ${temp_dl_tput} >= 700

Check CA Scell And Pcell UL Tput
    [Arguments]    ${scf_file}    ${syslog}    ${CC_Num}=4
    ${temp_ul_tput}    Set Variable    0
    : For    ${scell_index}    IN RANGE    1    ${CC_Num}+1
    \    ${nrCellIdentity}    Get NrCellIdentity From SCF    ${scf_file}    ${scell_index}
    \    ${ul_tput}    Get Scell UL Latest Tput From Syslog    ${syslog}    ${nrCellIdentity}
    \    ${temp_ul_tput}    Evaluate    ${temp_ul_tput}+${ul_tput}
    \    Should Be True    ${ul_tput} >= 0
    Should Be True    ${temp_ul_tput} >= 300

Capture Syslog
    Start GNB Syslog    log_dir=${TEST_LOG_DIRECTORY}
    Sleep    10s    reason=capture gnb syslog
    ${syslog}    Stop And Collect GNB Syslog    log_dir=${TEST_LOG_DIRECTORY}
    [Return]    ${syslog}

Check NSA CA UE Secondary Cells UL Or DL Throughput
    [Arguments]    ${ue_id}    ${dir}    ${Target_tput}    ${CC_Num}
	Comment    CC_Num for NSA is NR side scell number, for SA is Pcell+Scell Number, and scell=0 check is for pcell
    Wait Until Keyword Succeeds    1min    6s    Check CA Cell Sum Average Throughput    ${ue_id}    ${dir}    ${Target_tput}    ${CC_NUM}+1
    
Verify BTS Is Commissioned
    [Documentation]    This keyword is to check the state of gNB is Commissioned
    Log To Console    verify BTS is configured...
    Run Keyword And Ignore Error    COAM.Setup Admin
    ${bts_state}    COAM.Get Mrbts State
    Log To Console    [INFO] BTS STATE : ${bts_state}
    Should Contain Any    ${bts_state}    Commissioned    ignore_case=True
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
