*** Settings ***
Documentation
...    author: Tang Lixia
...    contact: lixia.tang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG


Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Variables    TLConfigration_7499.py


*** Variables ***
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${dist}                     MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1

*** Keywords ***
Online Modify 7449 Parameters
    log to console   \n*** Online Modify 7449 Parameters ***
    vDU Login
    &{modify_parameter_dict}    Create Dictionary
    &{7449_modify_parameter_dict}    Create Dictionary    actLongPucchPhase2=true    pucchModeSelect=longPucch
    ...    basicBeamSet=beamSet_4    numberOfTransmittedSsBlocks=4    msg1FrequencyStart=19    srPeriodicity=slots40
    ...    frameStructureType=tdLte    lteToNrFrameShift=3ms    guardPeriodSymbols=6Symbols    prachConfigurationIndex=196
    ...    actPerCsiReportBundlingTddFr1=true    reqMinNumPuschPrb=233    actIncreasedFdmUsersPerSlot=true
    ...    actFdmEnhancedScheduling=true    actFdmScheduling=true    dlMimoMode=8x4 Closed Loop Spatial Multiplexing
    FOR    ${para_name}    IN    @{7449_modify_parameter_dict}
        ${value}=    Online Get VDU Parameter Value    ${dist}    ${para_name}
        run keyword if    "${value}" != "${7449_modify_parameter_dict}[${para_name}]"
        ...    Set to Dictionary    ${modify_parameter_dict}    ${para_name}    ${7449_modify_parameter_dict}[${para_name}]
    END
    log to console   \n*** Modify Parameters ***
    Run Keyword If  &{modify_parameter_dict} != &{Empty}    Modify 7449 Parameters
    ...    dist=${dist}   updated_paras_dict=${modify_parameter_dict}    wait_vdu_up=True
    [Teardown]    Run Keyword And Ignore Error    vDU Logout

Modify 7449 Parameters
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
    Run Keyword And Ignore Error    robot_common_operations.Common case setup


One UE Attach
    log to console      "Prepare UE"
    Run Keyword And Ignore Error    power_ue.Prepare UE
    ...    ue_type=sigspark_multiUE    multiue_traffic_config=${TLCommonConfig["MultiUECFG"]}
    log to console      "UE Attach"
    power_ue.UE Attach     ue_type=sigspark_multiUE

UE Start Traffic
    log to console      "UE Start Traffic"
    power_ue.Start traffic    ue_type=sigspark_multiUE    direction=dl
    power_ue.Start traffic    ue_type=sigspark_multiUE    direction=ul

UE Check Bi Tput
    log to console      "UE Check Tput"
    power_ue.Check Bi Tput    ue_type=sigspark_multiUE

UE Stop Traffic
    log to console      "UE Stop Traffic"
    power_ue.Stop traffic     ue_type=sigspark_multiUE    direction=dl
    power_ue.Stop traffic     ue_type=sigspark_multiUE    direction=ul

One UE Detach
    log to console      "UE Detach"
    power_ue.UE Detach        ue_type=sigspark_multiUE

Test Case Teardown
    Run Keyword And Ignore Error    UE Stop Traffic
    Run Keyword And Ignore Error    One UE Detach
    Run Keyword And Ignore Error    robot_common_operations.Common case Teardown
 


