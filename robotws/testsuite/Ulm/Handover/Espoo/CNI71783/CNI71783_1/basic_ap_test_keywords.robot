*** Settings ***
Documentation    Test keyword resource file for CNI71783_1

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource        ../../../../resources/Common/wts_ue.robot

Library     ta5g_commissioning
Library     ta5g_enb
Library     ta5g_iphy
Library     ta5g_tshark
Library     ta5g_cell_operations
Library     taf.transport.ssh           WITH NAME    ssh


Library          ute_tshark



*** Variables ***
${SSH_OAM_AUTHENTICATION_TIMEOUT}       10 min
${SSH_AUTHENTICATION_RETRY_INTERVAL}    5 s
${SSH_AUTHENTICATION_TIMEOUT}           5 min



*** Keywords ***
Enable CP runtime logging
    Log To Console  Enable CP runtime logging..

    ${gNBCommUnit_alias}    wait until keyword succeeds
    ...    ${SSH_AUTHENTICATION_TIMEOUT}   ${SSH_AUTHENTICATION_RETRY_INTERVAL}
    ...    Connect to Node Common Unit
    ${cmd}  set variable  echo "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
    ssh.Send Command    command=${cmd}    timeout=60s     get_pty=True   connection=${gNBCommUnit_alias}

Send Swconfig for AP
    [Arguments]    ${ap_swconfig_path}
    Log to console  Send Swconfig for AP: ${ap_swconfig_path}..
    Setup Wts Fsm Access
    Put Wts File    ${ap_swconfig_path}    /ffs/run/swconfig.txt    partition=active
    Execute Command On Wts    crasign /ffs/run/swconfig.txt
    Execute Command On Wts    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    Teardown Wts Fsm Access

Add AP RadParam
    Log To Console  Adding AP RadParam to swconfig...
    ${ap_flags}  create list   0x580493=0x1
    Update SW Config file on AP System Module   param_list=${ap_flags}


AMFSim Configure MRL Basic
    Execute Egate Command  cmd=amf_mobility_restriction_list_param reset id=1
    Execute Egate Command  cmd=amf_mobility_restriction_list_param id=1 sa_plmn=311:489 fa_plmn=123:321 forbidden_tacs=123
    Execute Egate Command  cmd=amf_mobility_restriction_list_param
    ...                    pass_regexp=123:321
    ...                    timeout=10
    Execute Egate Command  cmd=amf_ue_ics_param id=1 ue=all mobility_restriction_list_id=1

AMFSim Reset MRL
    Execute Egate Command  cmd=amf_mobility_restriction_list_param reset id=1
    Execute Egate Command  cmd=amf_ue_ics_param reset id=1 ue=all
    Sleep    1

UE Register With Selected PLMN
    [Arguments]    ${UE}  ${selected_plmn}
    Execute Egate Command  cmd=ue_change_location id=${UE} enb=2 cell=1
    Sleep    1
    Execute Egate Command  cmd=ue_register id=${UE} selected_plmn=${selected_plmn}
    ...                    pass_regexp=UE now in NG RM Registered state
    ...                    timeout=10

UE PDU Session With A2 Event Verification
    [Arguments]    ${UE}    ${A2_Event}
    Execute Egate Command  cmd=ue_pdu_session_setup ue=${UE} pdu=1 nwslice=1 gw=1
    ...                    pass_regexp=Initial Context Setup Successful for UE
    ...                    timeout=10
    Sleep    1
    IF  "${A2_Event}"=="True"    Verify A2 Event IS Activated For UE    UE=${UE}
    ...  ELSE IF  "${A2_Event}"=="False"    Verify No A2 Event IS Activated For UE    UE=${UE}

Verify A2 Event IS Activated For UE
    [Arguments]    ${UE}
    # could switch to ta5g_ue_measurements usage when working
    #get ue measurement configuration    ue_id=${UE}  alias=UE_A2
    #verify that specified events are active on given frequencies    event_list=EventA2  frequencies=633312  alias=UE_A2
    Execute Egate Command  cmd=ue_meas_cfg_disp id=${UE}
    ...                    pass_regexp=EventA2
    ...                    timeout=2

Verify No A2 Event IS Activated For UE
    [Arguments]    ${UE}
    Execute Egate Command  cmd=ue_meas_cfg_disp id=${UE}
    ...                    fail_regexp=EventA2
    ...                    timeout=2

UE A2 Measurements With B2 Event Verification
    [Arguments]    ${UE}  ${ShouldContain}  ${ShouldNotContain}=False
    Execute Egate Command  cmd=ue_measurement_send_nr id=${UE} meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...                    pass_regexp=rrcReconfigurationComplete
    ...                    timeout=10
    Sleep    2
    # could switch to ta5g_ue_measurements usage when working
    #get ue measurement configuration    ue_id=${UE}  alias=UE_B2
    #verify that specified events are active on given frequencies    event_list=EventB2  frequencies=2  alias=UE_B2
    ${egate_output}=    Execute Egate Command  cmd=ue_meas_cfg_disp id=${UE}
    ...                    pass_regexp=UE${UE} NR MEASUREMENT IDENTITIES
    ...                    timeout=10
    IF  "${ShouldContain}"!="False"
    ...    Check That Egate Output Contains Items    egate_output=${egate_output}  ShouldContain=${ShouldContain}
    IF  "${ShouldNotContain}"!="False"
    ...    Check That Egate Output Does Not Contain Items    egate_output=${egate_output}  ShouldNotContain=${ShouldNotContain}
    Sleep    1

Check That Egate Output Contains Items
    [Arguments]    ${egate_output}  ${ShouldContain}
    FOR  ${i}  IN   @{ShouldContain}
        Should Contain    ${egate_output}    ${i}
    END

Check That Egate Output Does Not Contain Items
    [Arguments]    ${egate_output}  ${ShouldNotContain}
    FOR  ${i}  IN   @{ShouldNotContain}
        Should Not Contain    ${egate_output}    ${i}
    END

IRAT Handover to LTE With Handover Required Content Verification
    [Arguments]    ${UE}    ${eutran_cell}
    ${tshark_alias_ngap}=       Start Tshark For S1 Mme Interface
    ...                         log_dirpath=${OUTPUT_DIR}${/}${TEST_NAME}${/}tshark_irat_ho
    ...                         log_filename_prefix=irat_ho
    Sleep    2
    IF  "${eutran_cell}"=="1"    Send B2 Measurement And Verify IRAT HO for EUTRAN Cell 1    UE=${UE}
    ...  ELSE IF  "${eutran_cell}"=="2"    Send B2 Measurement And Verify IRAT HO for EUTRAN Cell 2    UE=${UE}
    Sleep    2
    Teardown Tshark    alias=${tshark_alias_ngap}
    Sleep    2
    Move File   ${OUTPUT_DIR}${/}${TEST_NAME}${/}tshark_irat_ho/irat_ho_*    ${OUTPUT_DIR}${/}${TEST_NAME}${/}irat_ho_${eutran_cell}.pcap
    Verify Pcap For ${eutran_cell}


Verify Pcap For ${eutran_cell}
    [Documentation]    Verify Pcap For cell1 or 2, check content of mcc and mnc
    ...       :Autor: Sylvia Schneider
    ${expected_mnc}    Set Variable IF  ${eutran_cell}==1    489   490
    ute_tshark.setup tshark    eth1
    ute_tshark.read_pcap_and_save_to_file
    ...   filename=${OUTPUT_DIR}${/}${TEST_NAME}${/}irat_ho_${eutran_cell}.xml
    ...   packet_filter=(ngap.radioNetwork == 17)
    ...   output_type=pdml
    ...   pcap_file_path=${OUTPUT_DIR}${/}${TEST_NAME}${/}irat_ho_${eutran_cell}.pcap
    ute_tshark.teardown tshark
    ${pdml_xml}    Parse Xml    ${OUTPUT_DIR}${/}${TEST_NAME}${/}irat_ho_${eutran_cell}.xml
    Log To Console    verify that ngap.pLMNIdentity contains correct mcc 311 and mnc 489
    Run Keyword And Continue On Failure   Element Attribute Should Match    ${pdml_xml}
    ...    show
    ...    311
    ...    xpath=.//field[@name="ngap.pLMNIdentity"]/field[@name="e212.mcc"]
    Run Keyword And Continue On Failure   Element Attribute Should Match    ${pdml_xml}
    ...    show
    ...    489
    ...    xpath=.//field[@name="ngap.pLMNIdentity"]/field[@name="e212.mnc"]

    Log To Console    verify that ngap.selected_EPS_TAI_element contains correct mcc 311 and mnc ${expected_mnc}
    Run Keyword And Continue On Failure   Element Attribute Should Match    ${pdml_xml}
    ...    show
    ...    311
    ...    xpath=.//field[@name="ngap.selected_EPS_TAI_element"]/field[@name="ngap.pLMNIdentity"]/field[@name="e212.tai.mcc"]
    Run Keyword And Continue On Failure   Element Attribute Should Match    ${pdml_xml}
    ...    show
    ...    ${expected_mnc}
    ...    xpath=.//field[@name="ngap.selected_EPS_TAI_element"]/field[@name="ngap.pLMNIdentity"]/field[@name="e212.tai.mnc"]

    Log To Console    verify that s1ap.targetCell_ID_element contains correct mcc 311 and mnc 489
    Run Keyword And Continue On Failure   Element Attribute Should Match    ${pdml_xml}
    ...    show
    ...    311
    ...    xpath=.//field[@name="s1ap.targetCell_ID_element"]/field[@name="e212.ecgi.mcc"]
    Run Keyword And Continue On Failure   Element Attribute Should Match    ${pdml_xml}
    ...    show
    ...    489
    ...    xpath=.//field[@name="s1ap.targetCell_ID_element"]/field[@name="e212.ecgi.mnc"]


Send B2 Measurement And Verify IRAT HO for EUTRAN Cell 1
    [Arguments]    ${UE}
    ${cmd}    Catenate    ue_measurement_send_nr id=${UE} meas_id=3 event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...                   phycell_id=11 nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    Execute Egate Command  cmd=${cmd}
    ...                    pass_regexp=UE${UE}: IRAT Handover from NR to EUTRA completed
    ...                    timeout=10

Send B2 Measurement And Verify IRAT HO for EUTRAN Cell 2
    [Arguments]    ${UE}
    ${cmd}    Catenate    ue_measurement_send_nr id=${UE} meas_id=3 event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...                   phycell_id=12 nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    Execute Egate Command  cmd=${cmd}
    ...                    pass_regexp=UE${UE}: IRAT Handover from NR to EUTRA completed
    ...                    timeout=10

UE Deregister And Verify Detached
    [Arguments]    ${UE}=1
    Execute Egate Command  cmd=ue_deregister id=${UE} by=ue ue_deregister_type=switch_off
    ...                    pass_regexp=UE${UE}: detached
    ...                    timeout=10
    Sleep    1

Deregister UEs
    UE Deregister And Verify Detached    UE=1
    UE Deregister And Verify Detached    UE=2
    UE Deregister And Verify Detached    UE=3
    UE Deregister And Verify Detached    UE=4
    UE Deregister And Verify Detached    UE=5
