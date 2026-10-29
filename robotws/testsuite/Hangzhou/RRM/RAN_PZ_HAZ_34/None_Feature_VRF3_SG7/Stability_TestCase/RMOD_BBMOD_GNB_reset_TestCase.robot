*** Settings ***
Suite Setup    Setup BTS env and set keyword prority
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Power on and Common Test Teardown And Stop Capture Logs

Documentation    Suite description
...   author:      Flora Du
...   contact:     Flora.du@nokia-sbell.com
...   squad group: MMW_SG7
...   Feature:     None

Force Tags    5G_RRM
...   PY39

Resource    ./resource/Stability_TestCase_keywords.robot

*** Variables ***
@{HO_PARAMS}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true

${LOOP}    1

*** Test Cases ***
SMOD_BBMOD_GNB_Reset_TestCase
    [Documentation]
    ...    1. The purpose of this test case is for stability test
    ...    2. Test Case Steps:
    ...      case step:
    ...         a. cell onair, create UE and send traffic
	...         b. Reset BB mode, waiting for cell onair, create UE and send traffic
    ...         c. Reset RMOD mode, waiting for cell onair, create UE and send traffic
    ...         d. GNB site reset, waiting for cell onair, create UE and send traffic
    ...         e. Power off and Power on GNB, cell onair, create UE and send traffic
    ...        e. UE detach
    ...      case result:
    ...         a. UE attaches successfully, traffic normal.
	...         b. Reset BB mode successfully, cell onair, UE attaches successfully, traffic normal
    ...         c. Reset RMOD mode successfully, cell onair, UE attaches successfully, traffic normal
    ...         d. GNB site reset successfully, cell onair, UE attaches successfully, traffic normal
    ...         e. Power off and Power on GNB, cell onair, UE attaches successfully, traffic normal
    ...         e. UE detach successfully, no hanging resource
    [Tags]    D012    QC_
    Set test variable    ${TS_CASE_LOG_PATH}     ${TEST_LOG_DIR}
    FOR    ${id}    IN RANGE    0    ${LOOP}
        BBmode reset and cell onair
        UE attach and send traffic
        Rmode reset and cell onair
        UE attach and send traffic
        GNB site reset and cell onair
        UE attach and send traffic
        Power on and power off GNB
        UE attach and send traffic 
        Stop Traffic With Power UE     ue_index=${0}    is_detach=True
    END

*** Keywords ***
Power on and Common Test Teardown And Stop Capture Logs
   Run Keyword If Test Failed    Power on the GNB
   Common Test Teardown And Stop Capture Logs

Power on and power off GNB
   Power off the GNB
   Power on the GNB
   Cells Should Be OnAir

Power off the GNB
    [Documentation]   GNB power off
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${unit_index}=${0}
    ...    ${model}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
    BuiltIn.Log    GNB Power off start
    ${gnb_pdu_ip}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
    ${gnb_pdu_port}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${gnb_pdu_ip}    alias=gnb_pdu
    pdu.power_off    port=${gnb_pdu_port}    pdu_device=gnb_pdu
    Wait Until Keyword Succeeds    60s    5s    ping should as excepted    ip_addr=${FTM_IP}    regrx_string=Destination Host Unreachable
    BuiltIn.Log    GNB Power off done.

ping should as excepted
    [Arguments]    ${ip_addr}=${FTM_IP}    ${regrx_string}=Destination Host Unreachable
    ${result}    run    command=ping ${ip_addr} -c 3
    Should Contain    ${result}    ${regrx_string}

Power on the GNB
    [Documentation]   GNB Power on
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${unit_index}=${0}
    ...    ${model}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
    BuiltIn.Log    GNB Power on start
    ${gnb_pdu_ip}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
    ${gnb_pdu_port}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${gnb_pdu_ip}    alias=gnb_pdu
    pdu.power_on    port=${gnb_pdu_port}    pdu_device=gnb_pdu
    Wait Until Keyword Succeeds    600s    5s    ping should as excepted    ip_addr=${FTM_IP}    regrx_string=3 received
    BuiltIn.Log    GNB Power on done.
    sleep    300s

UE attach and send traffic
    Start UE Attach With Power UE    ue_index=${0}    4G_check=false
    Start L3 Call With Power UE    ue_index=${0}    ul_data_transfer=20000    dl_data_transfer=30M
    @{direction_component_list}    Create List   UL_L2LO    DL_L2LO
    Check Tput With Power UE    expect_ul_tput=${0}    expect_dl_tput=${0}    duration=10
    ...    direction_component_list=@{direction_component_list}

BBmode reset and cell onair
    Reset BBMODs
    Cells Should Be OnAir

Reset BBMODs
    ${coam_conn}    coam.Connect To
    ${fbb_info}=    coam.Get fbb info    connection=${coam_conn}
    FOR    ${fbb}    IN    @{fbb_info}
        coam.Reset Unit    ${fbb['id']['internal']}    reset_type=Warm    timeout=${300}    connection=${coam_conn}
    END
   [Teardown]    coam.Teardown    ${coam_conn}

Rmode reset and cell onair
    Reset RMOD
    Cells Should Be OnAir

Reset RMOD
    ${coam_conn}    coam.Connect To
    Set test variable    ${MRBTS_ID}    ${tl.gnbs[0].instance_id}
    ${ru_index_list}    Get All RU Index    connection=${coam_conn}
    FOR    ${ru_index}    IN    @{ru_index_list}
        log to console    \n***RF Module index ${ru_index} Reset via admin**
        ${RU_index}    Convert To Integer    ${ru_index}
        coam.reset_unit    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}
        ...    force_radio_reset=${True}    timeout=${300}    connection=${coam_conn}
    END
   [Teardown]    coam.Teardown    ${coam_conn}

GNB site reset and cell onair
    GNB Reset Site
    Cells Should Be OnAir

GNB Reset Site
    ${coam_conn}    coam.Connect To
    ${smod_info}=    coam.Reset Site    connection=${coam_conn}
    log    ${smod_info}
    #FOR    ${smod}    IN    @{smod_info}
    #    taf.sbts.oam.coam.admin.Reset Unit    ${fbb['id']['internal']}    reset_type=Warm    timeout=${300}    connection=${coam_conn}
    #END
   [Teardown]    coam.Teardown    ${coam_conn}
