*** Settings ***
Documentation
...    author: Tang Lixia
...    contact: lixia.tang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot


*** Variables ***
${MRBTS_ID}                 ${tl.gnbs[0].dus[0].instance_id}
${dist}                     MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1

*** Keywords ***
Online Modify 1849 Parameters
    log to console   \n*** Online Modify 1849 Parameters ***
    vDU Login
    &{modify_parameter_dict}    Create Dictionary
    &{1849_modify_parameter_dict}    Create Dictionary    actBeamforming=true    actExternalAntennaBF=longPucch
    ...    externalAntennaType=4_column_0_5_lambda    basicBeamSet=beamSet_2    leftEdgeAngle=45    rightEdgeAngle=45
    ...    dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing    actDl256Qam=true    chBw=100MHz
    FOR    ${para_name}    IN    @{1849_modify_parameter_dict}
        ${value}=    Online Get VDU Parameter Value    ${dist}    ${para_name}
        run keyword if    "${value}" != "${1849_modify_parameter_dict}[${para_name}]"
        ...    Set to Dictionary    ${modify_parameter_dict}    ${para_name}    ${1849_modify_parameter_dict}[${para_name}]
    END
    log to console   \n*** Modify Parameters ***
    Run Keyword If  &{modify_parameter_dict} != &{Empty}    Modify 1849 Parameters
    ...    dist=${dist}   updated_paras_dict=${modify_parameter_dict}    wait_vdu_up=True
    [Teardown]    Run Keyword And Ignore Error    vDU Logout

Modify 1849 Parameters
    [Arguments]    ${dist}   ${updated_paras_dict}    ${wait_vdu_up}=False
    ${uni_id}   Get Unique Id
	${delta_plan_name}    get unique id    prefix=TA_delta_plan    precise=LOW
	log to console   \n*** Generate Delta Plan ***
	${plan_id}    ${action_id}    Generate Delta Plan    plan_name=${delta_plan_name}    plan_description=TA
	log to console   \n*** Update Delta Plan Parameter ***
	Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${dist}   updated_paras_dict=${updated_paras_dict}   operation=replace
    log to console   \n*** Validate Delta Plan By REST ***
    Validate Delta Plan By REST   ${plan_id}
    ${scf_path}  Get A Directory  SCF
    ${delta_filename}  Set Variable   add_route_${uni_id}.xml
    log to console   \n*** Save Delta Plan File ***
    ${delta_scf_fullpath}   vdu.Save Delta Plan File   local_path=${scf_path}   local_filename=${delta_plan_name}
    log to console   \n*** Activate Delta Plan By REST ***
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${wait_vdu_up}

OAM Precondition Cell Should Be Onair
    wait until keyword succeeds    600   30   vDU Verify All Cells Status Should Be Onair

Online Get VDU Parameter Value
    [Arguments]    ${mo_dn}    ${para_name}    ${timeout}=60
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.search_parameter_of_current_plan   mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}
    [Return]  ${out}

Test Case Setup
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}

Start DL UL Traffic
    [Arguments]    ${dl_tput}    ${ul_tput}
    power_ue.UE Attach     ue_index=${0}    ue_type=${ue_type}
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${dl_tput}    duration=600
    ...    ue_type=${ue_type}   process_num=1
    power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=${ul_tput}    duration=600
	...    ue_type=${ue_type}   iperf_type=via_command   data_amount=2M
	sleep    5s

Check Tput Result
    [Arguments]    ${dltp_expected}    ${ultp_expected}
    log to console    \n*** Check Tput Result ***
    ${handle}    vDU Begin K8s Log
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix
	sleep    60s
	${local_l2rt_file}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
	Set Suite Variable    ${local_l2rt_file}
	${cell_identify}=    Evaluate     16384*${tl.gnbs[0].dus[0].instance_id}+1
    ${cell_identify}   convert to string   ${cell_identify}
    @{list_of_cell}     Create List         ${cell_identify}
    ${ul_tp}    Run keyword and continue on failure    power_ue.Check Tput     ue_type=${ue_type}    direction=UL
    ...    log=${local_l2rt_file}    cells=@{list_of_cell}    target_throughput=${ultp_expected}    target_avg_percent=0.9
    ${dl_tp}    Run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=DL
    ...    log=${local_l2rt_file}    cells=@{list_of_cell}    target_throughput=${dltp_expected}    target_avg_percent=0.9

Stop DL UL Traffic
    log to console      \n*** Stop traffic ***
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}

Test Case Teardown
     Run Keyword And Ignore Error    Stop DL UL Traffic
     Run Keyword And Ignore Error    power_ue.UE Detach     ue_index=${0}    ue_type=${ue_type}

