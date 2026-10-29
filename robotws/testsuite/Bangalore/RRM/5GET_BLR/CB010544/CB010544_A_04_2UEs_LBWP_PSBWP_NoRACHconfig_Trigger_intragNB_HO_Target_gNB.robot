*** Settings ***
#Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Bhabani
...              :contact: bhabani.sankar_rout@nokia.com
...         The feature removes restrictions concerning the feature 5GC000937 allowing
...         PRACH frequency position outside the Power Saving Bandwidth Part (PS-BWP)
...         This user scenario describes Multiple UE moves to LBWP & PSBWP ,
...         Trigger intra gNBHO(intra frq) to target cell(CB10544 activated on only source cell)
...         UEs are attached to configured Band 78 on Pcell.
...         UEs are configured with the large (100MHz) dedicated BWP &  PSBWP (40MHz)
...         On high UL/DL data UE1 will move to LBWP & On low data UE2 will move to PSBWP
...         After  IntraFrequency-Ho UEs should move to target cell
...         Post intra fre HO back to source, UE moves to LBWP and UE2 moves to PSBWP.


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_intragnbHO.cfg
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}            1
${nwslice_ID}       1
${gw_ID}            1
${Pdu_session_ID}   1
${QFI_ID}           1
${TRF_ID}           1
${TRF_ID2}          2
${largebwp_id}      1
${psbwp_id}         2
${epc_log_path}     /tmp/
#${SCFC}=            Bangalore/RRM/ET/CB010544/CB010544_A2A3_TC4_scf.xml
${AP_XML}=          Bangalore/RRM/ET/CB010544/CB010544_A2A3_TC4_iphy.xml


*** Keywords ***
CB010544_A_04_2UEs_LBWP_PSBWP_NoRACHconfig_Trigger_intragNB_HO_Target_gNB
    ${bwpid}    Create List     ${psbwp_id}
    Register UE and verify initial bwp through tti trace   UE=1     bwp=${bwpid}
    Start low DL data and verify psbwp through tti trace   UE=1     bwp=${bwpid}
    Trigger A3 measurement for Intragnb HO and verify UE moves to PSBWP using tti trace    UE_ID=1   Cellid=51
    Trigger A3 measurement for Intragnb HO and verify UE moves to PSBWP using tti trace    UE_ID=1   Cellid=50
    Check BWP After Handover Psbwp
	Stop Data Traffic for SA     ue_id=1
    UE Deregister should be Successful   ue_id=1
    ${bwpid1}    Create List    2
	Register UE and verify initial bwp through tti trace  UE=2     bwp=${bwpid1}
	${bwpid1}    Create List    1
    Start HIgh DL data and verify lbwp through tti trace  UE=2     bwp=${bwpid1}
	Trigger A3 measurement for Intragnb HO and verify UE moves to PSBWP using tti trace    UE_ID=2   Cellid=51
    Trigger A3 measurement for Intragnb HO and verify UE moves to PSBWP using tti trace    UE_ID=2   Cellid=50
    Check BWP After Handover Large
	Stop Data Traffic for SA     ue_id=2
    UE Deregister should be Successful   ue_id=2

Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Register UE and verify initial bwp through tti trace
    [Arguments]   ${UE}    ${bwp}
    log to console   UE attach trigerring now...
    Start Log     btslog    cprt
    UE Registered Successfully & Rach validation    ${UE}
	${UE_CRNTI}   Create List
    Set Suite Variable    ${UE_CRNTI}
    Sleep    10s
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}   initial${UE}   ${UE_CRNTI}    ${bwp}    ${Branch_22R1}
    Stop log  btslog  cprt  test_scenario=attach${UE}

Start low DL data and verify psbwp through tti trace
    [Arguments]   ${UE}    ${bwp}
    Start Log     btslog    cprt
 #   Trigger DL Traffic for SA    ue_id=${UE}    Traffic_rate=kbps     dl_rate=10       trf_id=${TRF_ID}      qfi_id=${QFI_ID}
    Trigger UL Traffic for SA    ue_id=${UE}    Traffic_rate=kbps     ul_rate=10       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    sleep   5s
    sleep   5s    reason=Wait for successful BWP switch
    Stop Log     btslog    cprt       test_scenario=data${UE}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata${UE}    ${UE_CRNTI}     ${bwp}    ${Branch_22R1}

Start HIgh DL data and verify lbwp through tti trace
    [Arguments]   ${UE}    ${bwp}
    Start Log     btslog    cprt
    sleep   8s
    Trigger DL Traffic for SA    ue_id=${UE}  Traffic_rate=mbps     dl_rate=100       trf_id=${TRF_ID}      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE}    Traffic_rate=mbps     ul_rate=100       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful BWP switch
    Stop Log     btslog    cprt      test_scenario=datahigh${UE}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    highdata${UE}    ${UE_CRNTI}    ${bwp}    ${Branch_22R1}

Trigger A3 measurement for Intragnb HO and verify UE moves to PSBWP using tti trace
    [Arguments]   ${UE_ID}   ${Cellid}
    Start Log     btslog    cprt    bip
   	Get Configured Measurements of UE${UE_ID}
	WTS_Runner_BF_CA_HO_Keywords.TriggerA3 RsrpAndRsrq Measurement for intragnb HO    ${UE_ID}    1    ${Cellid}
    Stop Log     btslog    cprt   bip    test_scenario=bip${UE_ID}

TriggerA3 RsrpAndRsrq Measurement for intragnb HO
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}=50
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=30    nrsrq_nr=20
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output1}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    BuiltIn.Should Match Regexp     ${output}
    ...     bwp-Id\\s2.*\\n.*bwp-Common.*\\n.*\\n.*genericParameters.*\\n.*\\n.*\\n.*\\n.*\\n.*pdcch-ConfigCommon.*
    Log to Console    ${output}

Check BWP After Handover Psbwp
    ${bwpid}    Create List     2
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    afterhoue1    ${UE_CRNTI}    ${bwpid}    ${Branch_22R1}

Check BWP After Handover Large
    ${bwpid}    Create List     1
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    afterhoue2    ${UE_CRNTI}    ${bwpid}    ${Branch_22R1}

UE Registered Successfully & Rach validation
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    .*REGISTRATION COMPLETE.*    ${Timeout_SA}
    Log to Console    --->.*REGISTRATION COMPLETE.*
    Initial Success Message for UE Register and Rere gister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    ${output}    wtsrunner.read_wtsemu_output_until_re   expected=Initial Context Setup Successful    timeout=240
    BuiltIn.Should Match Regexp     ${output}
    ...     bwp-Id\\s2.*\\n.*bwp-Common.*\\n.*\\n.*genericParameters.*\\n.*\\n.*\\n.*\\n.*\\n.*pdcch-ConfigCommon.*
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}
