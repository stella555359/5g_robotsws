*** Settings ***
Documentation
...    author: Yan Susana
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F_2N78_2N41_N66_N71
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS24R3    release-SBTS25R1    tl-CLOUD_5G_I_BOO_AP_LOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SWCONFIG}
...    0x340002=1
...    0x340006=55139

${NRCELL-1_Freq}    636000

@{Pcell-1_4Scells_expect}
...    pcid:50, scellIdx:0
...    pcid:52, scellIdx:2
...    pcid:60, scellIdx:3
...    pcid:61, scellIdx:4
...    SCellIndex 4 activated successfully at airphone

#@{PcellChangeFromCell1ToCell12_expect}
#24R3 and 25R1 are diff, please refer to CNI128106_CNI125505-ET-A006_AP_var.py

@{PcellChangeTo_Cell-1_expect}
...    pcid:52, scellIdx:2
...    pcid:61, scellIdx:4
...    pcid:60, scellIdx:3
...    pcid:51, scellIdx:1
...    SCellIndex 4 activated successfully at airphone

@{RRE_cause}     handoverFailure    otherFailure

@{expect_Resume}
...    rrcResumeRequest1
...    rrcResume
...    rrcResumeComplete
...    radioLinkMonitoringConfig setup
...    beamFailureInstanceMaxCount n3
...    beamFailureDetectionTimer pbfd2

@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    nextHopChainingCount
...    t380
...    NR_RRC_INACTIVE
...    Is INACTIVE

@{ueRegister}
...    QoS Routing Table

@{RRE_withoutRdioLinkMonitoringConfig}
...    rrcReestablishmentRequest
...    NR RRC Reestablishment sucessfully completed

@{RRE_withRdioLinkMonitoringConfig}
...    radioLinkMonitoringConfig setup
...    beamFailureInstanceMaxCount n3
...    beamFailureDetectionTimer pbfd2

#5CC CA_n41A-n66(2A)-n71A-n78(2A) support HRDRB
${CB009855_A_Capa_5CC_n78_n78_n41_n66_n71}    SEPARATOR=
...    EDA09000575F5A13160003C5A0000B0498B800CE1E86801364D873E618F28581C130180623807DC6C28C0D608C21A081074844
...    006D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE000E80000381506C41D608C21A081
...    07884400656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000001D00000702A8D89BAC1184341
...    020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001D00000702B8F88DAC1184341
...    020F9422002AB64C55850E7C471E300000000000000000010387809FFF000007FFC000007400001C01078789A001C410000021
...    6020541E14000711800000858158788C001C41000006160561E14000710400000858158789A001C46000002160562E23000710
...    40038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C0000082C0AC5C28000
...    E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800388C0000082C0
...    AC5C4D000E2300070A000002058158788C001C46000006160565E140007104003882001C46000E268007134000038585C01C04
...    68051013602091A00019A10851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28103639F
...    022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F0214081B1CF
...    812A0408102040D96BC303220318C6318C6318C6318C603D08C000F000A070500703009401C0018090010180A0000000000D00
...    080183E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001
...    C010008000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D
...    64CD602D606D6025604560ED0341000009652504000065949410000296524040000E5949010000496524040001659490100006
...    96524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2
...    E95455058AA0B1541A2A94C55268AA031540A2A93555078A22002F012A05028140A05028140A05028140A05028140A05028003
...    84040300601002004202004010080600C20100200404030060100C018202018030080600C20100200404030060100200440201
...    8030080600C020180304040080201002008A02004008080600C02018030080600C0200400808010023543E00020406080C0E14
...    16181A2022242628303236383A3E424A4C4E5052545A5E828305A0

${UTE_WIRESHARK_FLAG}    ${False}

*** Test Cases ***
CNI128106_CNI125505-ET-A006_Verify Success Pcell Switch with FAF On
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    UE RRC resume/reestablishment and pcell swtich with FAF on successfully.
    ...    2. [Configuration]:
    ...        CNI128106-24R3
    ...        NRCELL:tmpActFeat2 configure and bit24=1 (selected from value list)
    ...        NRCELL:actRrcReconfigAtBeamSwitch=false
    ...        CNI125505-25R1
    ...        NRCELL.disableUeBeamFailureRecovery = true
    ...        NRCELL:actRrcReconfigAtBeamSwitch=false
    ...    3. Test Case Steps:
    ...        Step a. SA UE81 attach to Cell2 and start traffic.
    ...        Step b. Online Change NRCELL-1 FAF off
    ...                24R3: NRCELL-1.tmpActFeat2 configure and bit24=0 (not selected from value list)
    ...                25R1: NRCELL-1:disableUeBeamFailureRecovery=false
    ...        Step c. SA UE81 trigger intra gnb rrc reestablish to Cell2.
    ...        Step d. SA UE81 Trigger Release To RRC_INACTIVE State
    ...        Step e. SA UE81 Trigger RRC resume to Cell1.
    ...        Step f. SA UE81 Send A1 Trigger Scell Addition
    ...        Step g. SA UE81 Trigger Pcell Change From TDD Cell-1 To FDD Cell-12
    ...        Step h. SA UE81 Trigger Pcell Change From TDD Cell-12 To FDD Cell-1
    ...        Step i. SA UE81 deregister With Traffic Stop And Pdu Session Release
    ...    4. Expected Results:
    ...        Step a:
    ...               1) UE attach succesfully. Check on BWP-DownlinkDedicated - radioLinkMonitoringConfig is not configured.
    ...               2) Stable DL throughput is achieved
    ...        Step b: Param online change successfully.
    ...        Step c: RRC reestablish successfully.
    ...                Check on BWP-DownlinkDedicated - radioLinkMonitoringConfig is not configured in rrc reestablishment request.
    ...        Step d: UE change to RRC_INACTIVE State
    ...        Step e: SA UE81 rrc resume successfully to Cell1.
    ...                check on RRC Resume Request, BWP-DownlinkDedicated - radioLinkMonitoringConfig is configured in rrc resume request
    ...        Step f: A1 scellAddition successfully with CA_T1_T2T3F11F12
    ...                check on RRC message BWP-DownlinkDedicated - radioLinkMonitoringConfig is neither configured for pcell nor scell.
    ...                NOTE: 25R1 will release radioLinkMonitoringConfig after handover, 24R3 not release.
    ...        Step g: A1 Pcell Change To F12, CA_F12_F11T1T2T3
    ...                check on RRC message BWP-DownlinkDedicated - radioLinkMonitoringConfig is neither configured for pcell nor scell.
    ...        Step h: A1 Pcell Change To T1, CA_T1_T2T3F11F12
    ...                check on RRC message BWP-DownlinkDedicated - radioLinkMonitoringConfig is configured for pcell.
    ...        Step i. SA UE81 deregister With Traffic Stop And Pdu Session Release successfully.
    [Tags]    A005    A006
    Delta Commission Parameters    ${FAFAllon}
    Ue Register And Pdu Session Setup    ue_id=81    cellid=2
    Send And Verify Throughput    ue_id=81
    Delta Commission Parameters    ${FAFcell1off}
    UE Trigger Intra gNB RRC Reestablish    ue_id=81    targetCell_id=2    pass_regexp=${RRE_withoutRdioLinkMonitoringConfig}
    ...    fail_regexp=radioLinkMonitoringConfig setup
    UE Trigger Release To RRC_INACTIVE State    ue_id=81
    UE Trigger RRCResume    ue_id=81    targetCell_id=1    pass_regexp=${expect_Resume}
    UE Send A1 Trigger Scell Addition    cellfreq=${NRCELL-1_Freq}    pass_regexp=${Pcell-1_4Scells_expect}    ue_id=81
    Trigger Pcell Change From TDD Cell-1 To FDD Cell-12    scell_index=4    cellfreq=${NRCELL-1_Freq}
    ...    pass_regexp=${PcellChangeFromCell1ToCell12_expect}    fail_regexp=radioLinkMonitoringConfig setup
    Trigger Pcell Change From FDD Cell-12 To TDD Cell-1    scell_index=1    cellfreq=${NRCELL-1_Freq}
    ...    pass_regexp=${PcellChangeTo_Cell-1_expect}    pass_regexp=radioLinkMonitoringConfig setup
    Ue Deregister With Traffic Stop And Pdu Session Release

*** Keywords ***
Modify Cfg
    Update Cfg    ue_param id=81 ue_nr_capabilities=${CB009855_A_Capa_5CC_n78_n78_n41_n66_n71}

Ue Register And Pdu Session Setup
    [Arguments]    ${ue_id}=81    ${cellid}=11
    BuiltIn.Log    UE${ue_id} Register and Setup pdu session...    console=${True}
    ${Set_AMF_Send_CNAI_In_UE_ICS}    catenate
    ...    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${Set_AMF_Send_CNAI_In_UE_ICS}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=${cellid}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${ueRegister}

UE Trigger Intra gNB RRC Reestablish
    [Arguments]    ${ue_id}=81    ${targetCell_id}=1    ${pass_regexp}=${None}    ${fail_regexp}=${None}
    BuiltIn.Log    UE${ue_id} Trigger Intra gNB RRC Reestablish...    console=${True}
    Get Random RRE Cause
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${TargetCell_id} cause=${random_RRE_cause}
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=20s
    sleep    5s    #wait trace session in source cell be cleared
    Execute Egate Command    ue_disp    pass_regexp=Configured UEs
    Verify Throuput SA    ue_id=${ue_id}

Get Random RRE Cause
    ${random_RRE_cause}    Evaluate    random.choice(${RRE_cause})    random
    Set Test Variable    \${random_RRE_cause}

Verify Throuput SA
    [Arguments]    ${ue_id}=81    ${qfi}=1    ${sleep_time}=10s    ${Tput_dl}=12    ${Tput_ul}=8
    sleep    ${sleep_time}    #wait trf stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${Tput_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

UE Trigger Release To RRC_INACTIVE State
    [Arguments]    ${ue_id}=81
    BuiltIn.Log    UE${ue_id} Trigger Release To RRC_INACTIVE State...    console=${True}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=inactive    pass_regexp=@{INACTIVE_check}        timeout=60s
    Execute Egate Command    ue_disp    pass_regexp=Configured UEs

UE Trigger RRCResume
    [Arguments]    ${ue_id}=81    ${targetCell_id}=1    ${pass_regexp}=${None}    ${fail_regexp}=${None}
    BuiltIn.Log    UE${ue_id} Trigger RRCResume To Type2 Cell${targetCell_id}...    console=${True}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${targetCell_id}
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Send And Verify Throughput    ue_id=${ue_id}

UE Send A1 Trigger Scell Addition
    [Arguments]    ${cellfreq}    ${pass_regexp}=${None}    ${ue_id}=81
    BuiltIn.Log    UE${ue_id} Trigger A1 Scell Addition...    console=${True}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=120 srsrq_nr=52
    ...    pass_regexp=${pass_regexp}
    Verify Throughput When 4 Scells    ue_id=${ue_id}    Tput_dl=5

Send And Verify Throughput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=15    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=15    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=15    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=6 mbps=10    UE ${ue_id}: UDP UL
    Verify Throughput    ue_id=${ue_id}

Verify Throughput
    [Arguments]    ${ue_id}=81    ${Tput_dl}=40    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Throughput Check
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=1    ${sleep_time}=15s    ${CC_num}=5
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${alldl_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${id}    type=pdsch    rate_type=ave
        ${alldl_tput}    Evaluate    ${alldl_tput}+${scell_tput}
    END
    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}

Verify Throughput When 4 Scells
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_num}=5
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_num=${CC_num}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch    pass_regexp=CellIndex-4

Trigger Pcell Change From FDD Cell-12 To TDD Cell-1
    [Arguments]    ${scell_index}    ${cellfreq}    ${pass_regexp}=${None}    ${fail_regexp}=${None}    ${ue_id}=81
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${cmd}    catenate
    ...    ue_measurement_send_nr id=${ue_id} event=A1 meas_id=${measid} srsrp_nr=11 srsrq_nr=11 scell=${scell_index}
    ...    scell_rsrp=127 scell_rsrq=127
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Verify Throughput When 4 Scells    ue_id=${ue_id}    Tput_dl=5

Trigger Pcell Change From TDD Cell-1 To FDD Cell-12
    [Arguments]    ${scell_index}    ${cellfreq}    ${pass_regexp}=${None}    ${fail_regexp}=${None}    ${ue_id}=81
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    ${A2_Pcell_change_T_To_F}    catenate
    ...    ue_measurement_send_nr id=${ue_id} event=A2 meas_id=${measid} srsrp_nr=11 srsrq_nr=11 scell=${scell_index}
    ...    scell_rsrp=127 scell_rsrq=127
    Execute Egate Command    ${A2_Pcell_change_T_To_F}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Verify Throughput When 4 Scells    ue_id=${ue_id}    Tput_dl=5

Ue Deregister With Traffic Stop And Pdu Session Release
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1
    ...    Stopped Downlink Internal traffic on Ue:${ue_id} UpfId:1 Pdu:1 Qfi:1
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE CONTEXT RELEASE COMPLETE
