*** Settings ***
Documentation
...    author: VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 4'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007_GMS <OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com>'
...    Description: Robot SE TCs for  CB010559:RRC connection re-establishment to an unprepared gNB.
...    CLOUD_5G_I_[MP][MP]_AP_[LOOO]+VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource               CB010559-Keywords.robot
Resource               CB010559-Commissioning-2realGnb.robot

Suite Setup            CB010559-2realGnb Setup
#Suite Teardown         CB010559 Teardown

Test Setup             Perform Precondition Of Test Scenario
Test Teardown	       CB010559-Keywords.Perform Postconditions Of Test Scenario

*** Variables ***
${TEST_MODE}           manual
${EGATE_CONSOLE_LOG}   /opt/iphy/latest/egate_console.log

${SIM_GNB_SET}      type=simulated plmn=311:489 ng=$GNB4_NG_ADDR gnb_id=0x${SIM_GNB}:22 daemon=$SERVER_IP:$DAEMON_PORT s1u=$GNB4_S1U_ADDR
...                 x2=$GNB4_X2_ADDR:36422 x2_peers=none xn=$GNB4_XN_ADDR nssai=0x1:0xd143a5 amf=1 plmnList=311:489
${SIM_GNB_PARAM}    x2_listening_socket=1 sib1_period=40 send_xn_setup=false measEvent=A3
...                 ng_data_forwarding_HO=on gbr_data_forwarding_HO=on sa_ho=xn_based
...                 ciphering_algorithm=nea2 integrityprotection_algorithm=nia2
${SIM_CELL1_SET}    gnb=${SIM_GNB} pci=18:0 tac=200 nrci=0xa tdd_cell=off proxy=$GNB4_NG_ADDR:5556 nr_arfcn=145000:156000
...                 mandatory_for_activation=off gscn=1947
${SIM_CELL2_SET}    gnb=${SIM_GNB} pci=18:0 tac=200 nrci=0xb tdd_cell=off proxy=$GNB4_NG_ADDR:5557 nr_arfcn=136100:126900
...                 mandatory_for_activation=off gscn=1584

@{msg_list_I_B2}
...                    c1 : rrcReestablishmentRequest
...                    RetrieveUEContextRequest
...                    RetrieveUEContextResponse
...                    c1 : rrcReestablishment
...                    c1 : rrcReestablishmentComplete
...                    PATH SWITCH REQUEST: gNB=4
...                    value UEContextRelease

@{HO_PREP_CNC_COUNTERS}
...                    M55125C07516  ==  0  NG_HO_PREP_CNC_SRC
...                    M55125C07517  ==  0  NG_HO_PREP_CNC_ACK_SRC
...                    M55143C00030  ==  0  XN_HO_PREP_CNC_IAF_S_VONR
...                    M55143C00036  ==  0  XN_HO_PREP_CNC_IEF_S_VONR
...                    M55209C00006  ==  0  NG_HO_PREP_CNC_IAF_S_VONR
...                    M55209C00012  ==  0  NG_HO_PREP_IEF_CNC_S_VONR
...                    M55143C00003  ==  1  XN_HO_CANCEL_SENT
...                    M55143C00007  ==  0  XN_HO_CANCEL_RECEIVED

*** Test Cases ***

CB010559_I_SE_TC02_B2_UE_Ctxt_is_found_on_Src_HO_gNB_during_NG_HO_Prep_phase
    [Documentation]  This user scenario describes the scenarios that UE context is found on Src HO gNB during Xn HO Prep phase.
    ...              HO Tgt: Sim/Oth
    [Tags]    I_B2
    Set Suite Variable  ${SRC_GNB}           ${GNB1}        # Last Serving
    Set Suite Variable  ${TGT_GNB}           ${GNB3}        # RRE Target
    Set Suite Variable  ${OTH_GNB}           ${GNB2}        # HO TGT
    No Response To HO Request
    Activate NG HO
    CB010559-Keywords.Setup SimGnb To Trigger RetrieveUeContextReq
    CB010559-Keywords.UE Attach And Start Traffic
    Send Egate Command And Verify Output                 cmd=ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A2
    ...            pass_regexp=rrcReconfigurationComplete
    Inter GNB HO                                          carrier_freq=${OTH_GNB['ssbfreq']}
    ...            pass_regexp=HandoverRequest for UE with AMF UE ID ${UE_ID} and RAN UE ID \\d+ will not be sent
    CB010559-Keywords.RRC Reestablishment Request
    Verify Msgs In Egate Console Log         ${msg_list_I_B2}


*** Keywords ***

Perform Precondition Of Test Scenario
    IF    '${PREV_TEST_STATUS}'=='FAIL'    Bring Airphone TL To On Air Status
    Start TCE Tracing
    Run Keyword And Ignore Error           UE Deregister
#    Enable Prepared Cell
    Start Logging                          pmcounter_enabled=${TRUE}
    Get Resources Taken Before Test
    Send Egate Command And Verify Output   cmd=ue_nr_rrc_reconf_param id=1 reset
    Set Suite Variable                     @{5qi1_list}      ${3}

Inter GNB HO
    [arguments]   ${pass_regexp}=XnHANDOVER_REQUEST rejected due to action NO_RSP   ${carrier_freq}=155790
    ${meas_ids}                            sqd65_keywords.Get NR Measurement IDs     event_type=A3  ue_id=${UE_ID}  carrier_freq=${carrier_freq}
    Send Egate Command And Verify Output
    ...    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_ids}[0] event=A3 srsrp_nr=19 phycell_id=${OTH_GNB['pci']} nrsrp_nr=100
    ...                                    pass_regexp=${pass_regexp}


No Response To HO Request
    Send Egate Command And Verify Output    cmd=gnb_xn_handover_preparation_param id=${SIM_GNB['apId']} action=drop
    Send Egate Command And Verify Output    cmd=gnb_xn_handover_preparation_param id=${SIM_GNB['apId']}
    Send Egate Command And Verify Output    cmd=amf_ue_ng_handover_param id=1 action=no_response
    Send Egate Command And Verify Output    cmd=amf_ue_ng_handover_param id=1

Activate NG HO
    ${current_scf}=           Load Current SCF   gnb_id=${SRC_GNB['node']}
    Set Element               dist_name=MRBTS-1/NRBTS-${SRC_GNB['nrBtsId']}/NRCELL-1/NRREL-2  p_name=handoverAllowedSA    value=XnHoNotAllowed
    Apply Delta SCF           ${current_scf}  activateNgHo_${SRC_GNB['node']}    gnb_id=${SRC_GNB['node']}

Trigger RRE During HO Completion Phase
    ${params}   Catenate                   if_contains=any action=reestablish_after_reconf_complete
    ...                                    delay_sending_rrc_reestablishment_req=2 gnb=${TGT_GNB['apId']}
    ...                                    cell=${TGT_CELL['cellId']} crnti=source cause=otherFailure
    Send Egate Command And Verify Output   ue_nr_rrc_reconf_param id=${UE_ID} {params}
    Send Egate Command And Verify Output   cmd=ue_nr_rrc_reconf_param id=${UE_ID}


Verify Fallback Counters
    [Arguments]   ${node}=${TGT_NODE}
    Set Suite Variable  ${TGT_NODE}          ${node}    # WA
    ${pm_files}=                             Collect PM Counters From Target GNB
    Verify PM Counter Reference Table        reference_table=${FALLBACK_COUNTERS}       pm_dir=${pm_files}   distname_suffix=NRCELL-${TGT_CELL}
    Verify PM Counter Reference Table        reference_table=${FAILURE_COUNTERS_DU}     pm_dir=${pm_files}   distname_suffix=NRDU-1
    Set Suite Variable  ${TGT_NODE}          ${1}    # reset

Verify PREP CNC Counters
    ${pm_files_src}  ${pm_files_tgt}         Collect PM Counters From Both GNBs
    Verify PM Counter Reference Table        reference_table=${HO_PREP_CNC_COUNTERS}       pm_dir=${pm_files_src}
    ...    distname_suffix=NRCELL-${SRC_GNB['nrci']}
    Set Counter Value                        ref_table=${HO_PREP_CNC_COUNTERS}             counter_name=XN_HO_CANCEL_SENT           value=0
    Set Counter Value                        ref_table=${HO_PREP_CNC_COUNTERS}             counter_name=XN_HO_CANCEL_RECEIVED       value=1
    Set Counter Value                        ref_table=${HO_PREP_CNC_COUNTERS}             counter_name=XN_HO_PREP_CNC_IEF_S_VONR   value=0
#    Verify PM Counter Reference Table        reference_table=${HO_PREP_CNC_COUNTERS}       pm_dir=${pm_files_tgt}
#    distname_suffix=NRCELL-${OTH_CELL1}  # HO TGT
