*** Settings ***
Documentation
...         author: Ulm SQD 65
...         Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...         Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...         Description: Keywords for CN-88819

Resource    ../../resources/SQD65/sqd65_keywords.robot
Resource    ../../resources/SQD65/sqd65_commissioning.robot

Library     taf.config.wts       WITH NAME    wts_conf

*** Variables ***

${FEATURE}                  CNI-88819
${TEST_MODE}                auto
${EGATE_CONSOLE_LOG}        /opt/iphy/latest/egate_console.log
${PR643936_CFG}             false
${NIDD_VERSION}             SBTS23R2_2223_100
${GNB_NUM}                  2
${CELL_NUM}                 4
${SCF_0}
${SCF_1}

# !!! duplicated info: from wts cfg and scf !!!
&{NRBTS_1_NRCELL_1}=
...    physCellId=11
...    lcrid=1
...    nrarfcn=645000
...    ssbFrequency=644928
...    ap_gnb_cell_id=2.1

&{NRBTS_1_NRCELL_2}=
...    physCellId=12
...    lcrid=2
...    nrarfcn=645000
...    ssbFrequency=644928
...    ap_gnb_cell_id=2.2

&{NRBTS_2_NRCELL_1}=
...    physCellId=21
...    lcrid=3
...    nrarfcn=636666
...    ssbFrequency=636576
...    ap_gnb_cell_id=3.3

&{NRBTS_2_NRCELL_2}=
...    physCellId=22
...    lcrid=4
...    nrarfcn=645000
...    ssbFrequency=644928
...    ap_gnb_cell_id=3.4

@{CELL_LST}=  ${NRBTS_1_NRCELL_1}  ${NRBTS_1_NRCELL_2}  ${NRBTS_2_NRCELL_1}  ${NRBTS_2_NRCELL_2}


@{IP_LIST_eth3_add}         10.0.1.200
@{IP_LIST_eth4_add}

*** Keywords ***

Perform Preconditions of Test Scenario
    Create Testcase Log Directory
    IF    '${PREV_TEST_STATUS}'=='FAIL'
    ...               Perform Preconditions of Test Scenario in Case of Previous TC failed
    Start Logging     pmcounter_enabled=${FALSE}

Perform Postconditions of Test Scenario
    Deregister UEs
    IF    '${TEST_MODE}'=='auto'        Collect AP Sos Report and Snapshots
    Run Keyword And Warn On Failure                 Stop Logging
    IF    '${PR643936_CFG}'=='false'
        Revert Delta Commissioning
        Revert Delta Commissioning   gnb_id=1
    END
    Wait until all gNBs to be onair state           timeout=900s

Prepare TL
    Sqd65 Common Setup
    Bring Airphone TL onair
    ${SCF_0}=             gnb.Get SCF from gNB    gnb_id=0
    Set Suite Variable    ${SCF_0}
    ${SCF_1}=             gnb.Get SCF from gNB    gnb_id=1
    Set Suite Variable    ${SCF_1}

Bring Airphone TL onair
    FOR  ${loop}    IN RANGE  1  3
        ${status}=  Run Keyword And Return Status  Run Keywords
        ...  Bring up WTS
        ...  AND  Wait until all gNBs to be onair state
        ...  AND  Verify Airphone Cell Setup completed
        IF  ${status}   RETURN
        Bring Airphone TL in State for Cell Setup
    END
    Fail  AP TL onair failed

Bring up WTS
    Kill WTS Services
    Start WTS for Airphone
    Config WTS for Airphone    pass_regexp=SimMode is ready now  timeout=300

Verify Airphone Cell Setup completed
    FOR  ${cell}  IN   @{CELL_LST}
       Wait Until Keyword Succeeds    1 min    20 sec  Check Airphone Cell Setup  ${cell}[lcrid]
    END

Check Airphone Cell Setup
    [Arguments]                ${cell_id}=1
    Send Egate Command and verify output           set_log flush
    ${find}=     Grep File  ${EGATE_CONSOLE_LOG}   Cell Setup completed for ?CELL_ID:${cell_id}?
    IF  "${find}" == "${EMPTY}"        Fail  Airphone Cell Setup not found : ${cell_id}

Bring Airphone TL in State for Cell Setup
    Kill WTS Services
    Run Keyword and Ignore Error   Run  sudo ip link delete tunUPF
    Reset Airphone Testline
    Wait For Minimum Required State For Cell Setup for all gNBs

Perform Preconditions of Test Scenario in Case of Previous TC failed
    Bring Airphone TL in State for Cell Setup
    Execute full commissioning    gnb_id=0    scf_path=${SCF_0}
    Execute full commissioning    gnb_id=1    scf_path=${SCF_1}
    Bring Airphone TL onair

Revert Delta Commissioning
    [Arguments]                ${gnb_id}=0
    ${log_dir}=                Get Testcase Log Directory
    ${curr_scf}=               Get SCF from gNB  target_dir=${log_dir}  gnb_id=${gnb_id}
    ${revert_file}=            Set Variable  ${log_dir}/revert-gNB${gnb_id}.json
    scf.calculate_delta_scf    ${SQD_ORIG_SCF_${gnb_id}}  ${curr_scf}  ${revert_file}
    Config gNB with delta scf  ${revert_file}  gnb_id=${gnb_id}

Register UE
    [Arguments]                  ${ue_id}=1  ${pdu_id}=1  ${pass_regexp}=Initial Context Setup Successful
    Send Egate Command and verify output   cmd=ue_change_location id=${ue_id} enb=2 cell=1
    ...                                    pass_regexp=(location updated to eNB-2 cell 1)|(already there)
    Set Traffic Type             ue_id=${ue_id}  pdu_id=${pdu_id}  trf_type=internal
    UE Register                  ue_id=${ue_id}
    UE PDU Session Setup         ue_id=${ue_id}     pdu=${pdu_id}    gw=${ue_id}   pass_regexp=${pass_regexp}
    Start data traffic in egate  ue_id=${ue_id}  pdu=${pdu_id}    direction=dl
    Start data traffic in egate  ue_id=${ue_id}  pdu=${pdu_id}    direction=ul
    Sleep                        2s
    Send Egate Command and verify output   state_sim_disp         pass_regexp=EGATE>

Apply Config for PR642370
    ${current_scf}=           Load current SCF
    Set Element               dist_name=MRBTS-1/NRBTS-1/NRCELL-1            p_name=actVoNR               value=true
    Set Element               dist_name=MRBTS-1/NRBTS-1/NRCELL-1            p_name=blockHoTimer          value=0
    Set Element               dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2    p_name=handoverAllowedSA     value=XnHoNotAllowed
    Apply Delta SCF           ${current_scf}  scf_PR642370-gNB0

Apply Config for PR643936
    IF    '${PR643936_CFG}' == 'true'   RETURN
    Kill WTS Services
    Setup 2nd PLMN            bts_id=1          gnb_id=0
    Setup 2nd PLMN            bts_id=2          gnb_id=1
    Wait For Minimum Required State For Cell Setup for all gNBs
    Bring Airphone TL onair
    FOR    ${gnb_id}    IN RANGE    ${GNB_NUM}
       Start F1AP capturing   gnb_id=${gnb_id}
    END
    Disable XnLink            bts_id=1          gnb_id=0
    Disable XnLink            bts_id=2          gnb_id=1
    Set Suite Variable        ${PR643936_CFG}   true

Setup 2nd PLMN
    [Arguments]                   ${bts_id}=1  ${gnb_id}=0
    ${current_scf}=               Load current SCF  gnb_id=${gnb_id}  scf_name=before_2nd_plmn_gNB${gnb_id}.xml
    Add NRPLMN                    bts_id=${bts_id}  id=2
    Update NRPLMN                 dist_name=NRBTS-${bts_id}/NRCELL-1/NRPLMNSET_SA-1  nrplmn=MRBTS-1/NRBTS-${bts_id}/NRPLMN-2
    Update NRPLMN                 dist_name=NRBTS-${bts_id}/NRCELL-2/NRPLMNSET_SA-1  nrplmn=MRBTS-1/NRBTS-${bts_id}/NRPLMN-2
    Update NRPLMN                 dist_name=NRBTS-${bts_id}/SNSSAI-1                 nrplmn=MRBTS-1/NRBTS-${bts_id}/NRPLMN-2
    Add ADJ_NRPLMNSET_SA          bts_id=${bts_id}
    ${log_dir}=                   Get Testcase Log Directory
    ${new_scf}=                   Set Variable  ${log_dir}/2nd_plmn_gNB${gnb_id}.xml
    scf.save_scf                  ${new_scf}
    Execute full commissioning    gnb_id=${gnb_id}    scf_path=${new_scf}

Add NRPLMN
    [Arguments]               ${bts_id}=1  ${id}=1
    ${dist_name}=             Set Variable             NRBTS-${bts_id}/NRPLMN-${id}
    Set Object                dist_name=${dist_name}   class_name=NRPLMN
    Set Element               dist_name=${dist_name}   p_name=mcc         value=1
    Set Element               dist_name=${dist_name}   p_name=mnc         value=1
    Set Element               dist_name=${dist_name}   p_name=mncLength   value=2

Add ADJ_NRPLMNSET_SA
    [Arguments]               ${bts_id}=1  ${fiveGsTac}=200  ${nrplmn}=2  ${nradjnrcell}=1
    ${dist_name}=             Set Variable                                      NRBTS-${bts_id}/NRADJNRCELL-${nradjnrcell}
    Set Object                dist_name=${dist_name}/ADJ_NRPLMNSET_SA-1         class_name=ADJ_NRPLMNSET_SA
    Set Element               dist_name=${dist_name}/ADJ_NRPLMNSET_SA-1         p_name=cellReservedForOperatorUse                value=notReserved
    Set Element               dist_name=${dist_name}/ADJ_NRPLMNSET_SA-1         p_name=fiveGsTac                                 value=${fiveGsTac}
    Update NRPLMN             dist_name=${dist_name}/ADJ_NRPLMNSET_SA-1         nrplmn=MRBTS-1/NRBTS-${bts_id}/NRPLMN-${nrplmn}
    Remove Element            dist_name=${dist_name}                            p_name=fiveGsTac

Update NRPLMN
    [Arguments]               ${dist_name}  ${nrplmn}
    @{nrplmn_lst}=            Create List   ${nrplmn}
    Set New List              dist_name=${dist_name}   list_name=nrPlmnDNList
    scf.add_elements_to_list  dist_name=${dist_name}   list_name=nrPlmnDNList      elements=${nrplmn_lst}

Disable XnLink
    [Arguments]               ${bts_id}=1  ${gnb_id}=0
    ${dist_name}=             Set Variable                     NRBTS-${bts_id}/NRADJGNB-1
    ${current_scf}=           Load current SCF                 before_disable_xnlink_gNB${gnb_id}.xml  gnb_id=${gnb_id}
    Set Element               dist_name=${dist_name}           p_name=administrativeState              value=Locked
    Remove Element            dist_name=${dist_name}           p_name=xnLinkRef
    Remove Object             dist_name=MRBTS-1/NRBTS-1/XNLINK-1
    Apply Delta SCF           ${current_scf}                   after_disable_xnlink_gNB${gnb_id}       gnb_id=${gnb_id}

Inter freq inter gNB NG HO
    [Arguments]   ${ue_id}=1  ${phycell_id}=${NRBTS_2_NRCELL_1.physCellId}  ${carrier_freq}=${NRBTS_2_NRCELL_1.ssbFrequency}
    ...     ${pass_regexp}=Inter-eNB handover from EXT_ENB-${NRBTS_1_NRCELL_1.ap_gnb_cell_id} to EXT_ENB-${NRBTS_2_NRCELL_1.ap_gnb_cell_id} performed
    Send NR Measurement Report    event=A3  ue_id=${ue_id}  meas_values=phycell_id=${phycell_id}  carrier_freq=${carrier_freq}
    ...                           pass_regexp=${pass_regexp}

Intra freq inter gNB NG HO
    [Arguments]   ${ue_id}=1  ${phycell_id}=${NRBTS_2_NRCELL_2.physCellId}
    ...     ${pass_regexp}=Inter-eNB handover from EXT_ENB-${NRBTS_1_NRCELL_1.ap_gnb_cell_id} to EXT_ENB-${NRBTS_2_NRCELL_2.ap_gnb_cell_id} performed
    Send NR Measurement Report    event=A3  ue_id=${ue_id}  meas_values=phycell_id=${phycell_id}  carrier_freq=${NRBTS_2_NRCELL_2.ssbFrequency}
    ...                           pass_regexp=${pass_regexp}

Inter freq intra gNB HO
    [Arguments]   ${ue_id}=1
    Send NR Measurement Report    event=A3  ue_id=${ue_id}  meas_values=phycell_id=${NRBTS_2_NRCELL_2.physCellId}
    ...                           carrier_freq=${NRBTS_2_NRCELL_2.ssbFrequency}
    ...        pass_regexp=Intra-eNB handover from EXT_ENB-${NRBTS_2_NRCELL_1.ap_gnb_cell_id} to EXT_ENB-${NRBTS_2_NRCELL_2.ap_gnb_cell_id} performed

Serving becomes worse than threshold
    [Arguments]   ${ue_id}=1  ${carrier_freq}=${NRBTS_1_NRCELL_1.ssbFrequency}
    Send NR Measurement Report    event=A2  ue_id=${ue_id}  carrier_freq=${carrier_freq}    pass_regexp=rrcReconfigurationComplete
    Sleep                         2

Enable VoNR
    [Arguments]               ${bts_id}=1  ${gnb_id}=0
    ${current_scf}=           Load current SCF   gnb_id=${gnb_id}
    Set Element               dist_name=MRBTS-1/NRBTS-${bts_id}/NRCELL-1    p_name=actVoNR         value=true
    Apply Delta SCF           ${current_scf}  scf_vonr-${gnb_id}  gnb_id=${gnb_id}

Setup Voice Call
    Send Egate Command and verify output   ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf
    ...                                    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID \\d+ handled successfully

Apply Config for PR642964
    ${current_scf}=           Load current SCF   gnb_id=1
    Set Element               dist_name=MRBTS-1/NRBTS-2/NRCELL-2/NRREL-2    p_name=handoverAllowedSA         value=XnHoNotAllowed
    Apply Delta SCF           ${current_scf}  scf_PR642964-gNB1    gnb_id=1

    ${current_scf}=           Load current SCF   gnb_id=0
    Set Element               dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-3    p_name=handoverAllowedSA         value=XnHoNotAllowed
    Apply Delta SCF           ${current_scf}  scf_PR642964-gNB0    gnb_id=0

    Cfg Data Forwarding

Cfg Data Forwarding
    Send Egate Command and verify output   upf_param id=1 end_markers_delay=1000
    Send Egate Command and verify output   amf_timer T_Local=4000 T_NotifyProcessing=2500
    Send Egate Command and verify output   amf_param id=1 intra5gs_data_forwarding=on

Add Qosflows
    [Arguments]   ${ue_id}=1
    Send Egate Command and verify output   ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3,4 by=amf
    ...                                    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID \\d+ handled successfully
    Send Egate Command and verify output   trf_data_start ue=${ue_id} pdu=1 qfi=1 pdu=1 qfi=2 pdu=1 qfi=3 dir=dl trf_id=1 mbps=1 size=1000
    ...                                    pass_regexp=Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:1 Qfi:3 TrfId:1

Apply Config for 02554471
    ${current_scf}=           Load current SCF   gnb_id=0
    Add Trackingarea
    Add ADJ_NRPLMNSET_SA      fiveGsTac=0     nrplmn=1
    Add ADJ_NRPLMNSET_SA      fiveGsTac=200   nrplmn=1  nradjnrcell=2
    Set Element               dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1  p_name=trackingAreaDN        value=MRBTS-1/NRBTS-1/TRACKINGAREA-0
    Set Element               dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1         p_name=handoverAllowedSA     value=XnHoNotAllowed
    Apply Delta SCF           ${current_scf}  scf_02554471-gNB0    gnb_id=0

    ${current_scf}=           Load current SCF   gnb_id=1
    Add Trackingarea          bts_id=2
    Add ADJ_NRPLMNSET_SA      bts_id=2  fiveGsTac=0     nrplmn=1
    Add ADJ_NRPLMNSET_SA      bts_id=2  fiveGsTac=200   nrplmn=1  nradjnrcell=2
    Set Element               dist_name=MRBTS-1/NRBTS-2/NRCELL-1/NRPLMNSET_SA-1  p_name=trackingAreaDN        value=MRBTS-1/NRBTS-2/TRACKINGAREA-0
    Set Element               dist_name=MRBTS-1/NRBTS-2/NRCELL-1/NRREL-1         p_name=handoverAllowedSA     value=XnHoNotAllowed
    Apply Delta SCF           ${current_scf}  scf_02554471-gNB1    gnb_id=1

    Kill WTS Services
    Wait For Minimum Required State For Cell Setup for all gNBs
    Bring Airphone TL onair
    Cfg Data Forwarding

Add Trackingarea
    [Arguments]               ${bts_id}=1
    ${dist_name}=             Set Variable                   NRBTS-${bts_id}/TRACKINGAREA-0
    Set Object                dist_name=${dist_name}         class_name=TRACKINGAREA
    Set Element               dist_name=${dist_name}         p_name=fiveGsTac       value=0
    ${snssaiList}             Create Dictionary              snssaiDN=MRBTS-1/NRBTS-${bts_id}/SNSSAI-1
    Set New List              dist_name=${dist_name}         list_name=snssaiList
    scf.add_item_to_list      dist_name=${dist_name}         list_name=snssaiList    elements=${snssaiList}

Get Active UEs
    ${configured_ues}=        Send Egate Command and verify output     ue_disp  pass_regexp=IsUEInCusMode
    ${ue_ids}=                Get Regexp Matches    ${configured_ues}  (\\d+)\\s+INT {3}ACTIVE.*  1
    RETURN  ${ue_ids}

Deregister UEs
    ${ue_ids}=                Get Active UEs
    FOR  ${ue_id}  IN  @{ue_ids}
         UE Deregister        ${ue_id}
    END
