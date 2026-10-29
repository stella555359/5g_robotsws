*** Settings ***
Suite Setup       Common Suite Setup And Setup BTS Env for LMI
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown

Documentation    Suite description
...   author:      Flora Du
...   contact:     Flora.du@nokia-sbell.com
...   squad group: MMW_SG7
...   Feature:     None

Force Tags    5G_RRM
...   PY39

Resource    ./resource/Common.robot

*** Variables ***
${tl_info}    7_5_UTE5G402T2452
${TLSCF_path}    /home/ute/MN/UTE/robotws/commissionings/HGZ/7_5_UTE5G402T2452/SBTS00/

${DEBUG}    ${True}
${SYSCOM_FLAG}    ${True}
${EMIL_FLAG}    ${False}
${AUTO_ANALYSIS_FLAG}    ${False}
${SNAPSHOT_FLAG}    pass:False,fail:False
${GNB_BIP_FLAG}    ${False}
${RESOURCES_LEAKAGE_FLAG}    ${False}
${RECREATE_WIRESHARK_FLAG}    ${False}

${LMI_DEBUG}    ${False}
${LOOP}    2
${power_num}    2
#${testline}    gnb_0

*** Test Cases ***
StabilityTest_01_RMOD_BBMOD_GNB_reset_and_power_on_off_With_LMI
    [Documentation]
    ...    1. The purpose of this test case is for stability test
    ...    2. Test Case Steps:
    ...      case step:
    ...         a. cell onair, create UE and send traffic
    ...         b. GNB site reset, some cells are still not on air state
    ...         c. Reset BB mode, waiting cell onair, create UE and send traffic
    ...         d. Power off and Power on GNB for multi times, create UE and send traffic
     ...        e. UE detach
    ...      case result:
    ...         a. UE attaches successfully, traffic normal.
    ...         b. Reset SMOD mode successfully, some cells are still not on air state
    ...         c. Reset BB mode successfully, cell onair, UE attaches successfully, traffic normal
    ...         d. GNB Power off and Power on successfully, cell onair, UE attaches successfully, traffic normal
    ...         e. UE detach successfully, no hanging resource, no abnormal alarm
    [Tags]        QC_
    UUF Truck Roll Check
    #UE attach and send traffic
    FOR    ${id}    IN RANGE    1    ${LOOP}
        BuiltIn.Log    LOOP ${id}...    console=${True}
        GNB Site Reset And Wait RMOD
        BBMODs Reset And Wait Cell Onair
        #UE attach and send traffic
        Power Off And Power On GNB For Multi Times
        #UE attach and send traffic
        #Stop Traffic With Power UE     ue_index=${0}    is_detach=True
    END

*** Keywords ***
Common Suite Setup And Setup BTS Env for LMI
    Setup BTS env and set keyword prority
    Get UUF Related Info

Common Test Setup
    Common Test Setup And Start To Capture Logs
    Set Test Variable    ${TS_CASE_LOG_PATH}     ${TEST_LOG_DIR}

Common Test Teardown
    Run Keyword If Test Failed    Power On The GNB
    Common Test Teardown And Stop Capture Logs

Get UUF Related Info
    UUF Get Variables From Backup SCF
    UUF Get Variables From Others
    UUF Get Testline Type
    UUF Check Env Testline
    Set Suite Variable    ${testline}    ${ALL_GNB_LIST}[0]

btslog_start
    Execute Egate Command    sshenb;lxc-attach -n 0x1018;ssh serviceuser@172.22.0.26;sudo lmi-eth on

Power Off And Power On GNB For Multi Times
    BuiltIn.Log    Power Off And Power On GNB For Multi Times...    console=${True}
    FOR    ${id}    IN RANGE    1    ${power_num}
        Power On And Power Off GNB
    END
    wait until keyword succeeds    5m    20s   COAM Login   bts_host=${webem_addr}
    ...   username=${webem_username}   password=${webem_password}   alias=${testline}
    UUF Testline Wait RMOD    testline=${testline}
    Wait Until Keyword Succeeds    900s    10s    Cells Should Be OnAir
    Wait For Host Ssh    ${FCT_IP}    timeout=600
    Start To Capture Wireshark Log

Power On And Power Off GNB
    Power Off The GNB
    Power On The GNB
    sleep    5
    #Cells Should Be OnAir

Power Off The GNB
    BuiltIn.Log    Power Off The GNB...    console=${True}
    [Documentation]   GNB power off
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${unit_index}=${0}
    ...    ${model}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
    BuiltIn.Log    GNB Power off start
    ${gnb_pdu_ip}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
    ${gnb_pdu_port}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${gnb_pdu_ip}    alias=gnb_pdu
    pdu.power_off    port=${gnb_pdu_port}    pdu_device=gnb_pdu
    Wait Until Keyword Succeeds    120s    5s    Ping Should As Excepted    ip_addr=${FTM_IP}    regrx_string=Destination Host Unreachable
    BuiltIn.Log    GNB Power off done.

Ping Should As Excepted
    BuiltIn.Log    Ping Should As Excepted...    console=${True}
    [Arguments]    ${ip_addr}=${FTM_IP}    ${regrx_string}=Destination Host Unreachable
    ${result}    run    command=ping ${ip_addr} -c 3
    Should Contain    ${result}    ${regrx_string}

Power On The GNB
    BuiltIn.Log    Power On The GNB...    console=${True}
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

UE attach and send traffic
    Start UE Attach With Power UE    ue_index=${0}    4G_check=false
    Start L3 Call With Power UE    ue_index=${0}    ul_data_transfer=20000    dl_data_transfer=30M
    @{direction_component_list}    Create List   UL_L2LO    DL_L2LO
    Check Tput With Power UE    expect_ul_tput=${0}    expect_dl_tput=${0}    duration=10
    ...    direction_component_list=@{direction_component_list}

BBMODs Reset And Wait Cell Onair
    BuiltIn.Log    BBMODs Reset And Wait Cell Onair...    console=${True}
    BBMODs Reset
    Cells Should Be OnAir

BBMODs Reset And Wait For 2s
    BBMODs Reset
    sleep    2s

BBMODs Reset
    BuiltIn.Log    BBMODs Reset...    console=${True}
    ${coam_conn}    coam.Connect To
    ${fbb_info}=    coam.Get fbb info    connection=${coam_conn}
    FOR    ${fbb}    IN    @{fbb_info}
        coam.Reset Unit    ${fbb['id']['internal']}    reset_type=Warm    timeout=${300}    connection=${coam_conn}
    END
   [Teardown]    coam.Teardown    ${coam_conn}

RMOD Reset
    BuiltIn.Log    RMOD Reset...    console=${True}
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

GNB Site Reset And Wait RMOD
    BuiltIn.Log    GNB Site Reset And Wait RMOD...    console=${True}
    GNB Site Reset
    sleep    30s
    wait until keyword succeeds    5m    20s   COAM Login   bts_host=${webem_addr}
    ...   username=${webem_username}   password=${webem_password}   alias=${testline}
    UUF Testline Wait RMOD    testline=${testline}
    sleep    50s

GNB Site Reset
    BuiltIn.Log    GNB Site Reset...    console=${True}
    ${coam_conn}    coam.Connect To
    ${smod_info}=    coam.Reset Site    connection=${coam_conn}
    log    ${smod_info}
    #FOR    ${smod}    IN    @{smod_info}
    #    taf.sbts.oam.coam.admin.Reset Unit    ${fbb['id']['internal']}    reset_type=Warm    timeout=${300}    connection=${coam_conn}
    #END
   [Teardown]    coam.Teardown    ${coam_conn}
