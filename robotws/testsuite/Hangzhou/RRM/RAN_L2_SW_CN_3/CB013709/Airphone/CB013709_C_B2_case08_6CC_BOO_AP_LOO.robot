*** Settings ***
Documentation     CB0013709 case
...
Test Timeout      180 minutes
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G

Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}          SCFC_CB013709_CB2_6CC_BOO_AP_LOO.xml
${AIRPHONE_NAME}      IPHY_CB013709_CB2_6CC_6CC_BOO_AP_LOOO.xml
${WTS_NAME}           wts_CB2_6cc_refine.lua
@{LOG_NAME_LIST}      gnb_snapshot    egatelog

${UE_1}                     1
${UE_3}                     3
${PDU_ID}         1
${MCC}                      311
${MNC}                      489
${AMF1_REGION}              1:2:2
${AMF2_REGION}              2:3:3

${UE_ID}          1
${PDU_ID1}         1
${GW_ID1}          1
${SLICE_ID}       1
${UE_NUM_SA}               26
${UE_NUM_SA_BEARER}         5
${UE_NUM_NSA}        2
${UE_NUM_NSA_ID}        12
${UE_TDD_ID}          1
${UE_FDD_ID}          401
${UE_NUM_FDD_BEARER}         5
${UE_NUM_FDD}                20
${CHECK_COUNTER_NUM}        6
${CHECK_COUNTER_TIMES}      4
${LOW_UE_ID}                1
${EGATE_TAG}      MUmimo
${TTI_TAG}      tti
${TTI_TAG_BLER}      tti_bler

${6CC_NUM}                  6
@{6CC_DL_TPUT}         120    40    80    120    120    120
@{2CC_UL_TPUT_LIST}         11    30
@{6CC_SCELL_PCI_3T3F}       51    52    53    54    55

${A2_COMMAND}   ue_measurement_send_nr  id\=3 meas_id\=9 event\=A2 srsrp_nr\=11 srsrq_nr\=11 scell\=5 scell_rsrp\=100 scell_rsrq\=100
...    scell\=4 scell_rsrp\=60 scell_rsrq\=60


*** Test Cases ***
CB013709_C_B2_CA
   Step1:Commission configuration for onair
   #Single Ue Attach and Scell Add    ${UE_1}    ${AMF1_REGION}


*** Keywords ***
Step1:Commission configuration for onair
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Configure IP For UEC2
    Add Common RD parameter
    Add 13079_A RD parameter
    #Add 13079_C ABIL RD parameter
    #Add 13079_C RD parameter
    Add 13079_CB2 TDD FDD CA RD parameter
    #Add 13079_CB2 DL CA RD parameter
    Add 13079_CB2 UL CA RD parameter
    Prepare gnb onair    multi_cells=True
    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true

Configure IP For UEC2
    OperatingSystem.Run    sudo ip addr add 10.0.2.3/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.61/24 dev eth3

Single Ue Attach and Scell Add
    [Arguments]    ${ue_id}    ${amf_region}=1:2:2
    Log To Console    UE${ue_id} Start Attach...
    SA 5G Attach    ue_id=${ue_id}
    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${PDU_ID}
    ute_wtssim.Execute Egate Command    cmd=ue_nr_rrc_setup_param id\=${ue_id} registered_amf\=${MCC}:${MNC}|${amf_region}
    #Sleep    0.5s    reason=wait for taking effect
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup pdu=${PDU_ID} ue=${ue_id} nwslice=1
    ...    pass_regexp=setup/reestablishment complete    timeout=3minutes
    Send A1 Report    ${ue_id}    srsrp_nr=120    phycell_id=56    meas_id=1
    ute_wtssim.Execute Egate Command    sim_log_set flush

Send A1 report
    [Arguments]    ${ue_id}    ${srsrp_nr}=70    ${phycell_id}=50    ${meas_id}=${EMPTY}
    [Documentation]    This keyword is to trigger A1 scell added.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | the id of ue |
    ...    | srsrp_nr | Yes | the value of srsrp_nr |
    ...    | phycell_id | Yes | phycell id of the cell |
    ...
    ...    Examples:
    ...    | Send A1 report | 1 | 70 | 50 |
    ...
    ${meas_id_from_egate}    _Get Measurement Id From Egate Log    A1    ${ue_id}
    ${measida1}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
    ${ret}    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${measida1} event=A1 srsrp_nr=${srsrp_nr} phycell_id=${phycell_id}
    ...    pass_regexp=EGATE    timeout=1min
    [Return]    ${ret}

_Get Measurement Id From Egate Log
    [Arguments]    ${event_tag}    ${ue_id}=1
    Sleep    2s
    ute_wtssim.Execute Egate Command    cmd=ue_meas_cfg_disp id=${ue_id}
    ${reportconfigidregex}=    Set Variable    reportConfigId (?P<report_id>\\d+)[\\s\\S]{1,150}eventId event${event_tag}
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportconfigidregex}    report_id
    ${report_id}=    Set Variable    ${report_id_list[-1]}
    ${measidregex}=    Set Variable    measId (?P<measId>\\d+)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measid_list}=    String.Get Regexp Matches    ${content}    ${measidregex}    measId
    [Return]    ${measid_list[-1]}

Add 13079_A RD parameter
    #13709 overload control
    Add GNB swconfig    0x5808A6:1 #rdEnableOverloadErrMsg
    #13709-rt
    Add GNB swconfig    0x5800CA:4004004 #rdMaxNumUeTdDl
    Add GNB swconfig    0x5800CB:4004004 #rdMaxNumUeTdUl
    #13709-nrt
    Add GNB swconfig    0x580932:60 #rdNbProcedureContextsMaxLimit
    Add GNB swconfig    0x580933:1 #rdNbProcedureContextsLow
    #0x580934 = 2 #rdNbProcedureContextsHigh
    #13709-core
    #0x580821 = 30030030 #rdMaxAdaptiveSlotProcessingRatio_perCent
    #Add GNB swconfig    0x580822:65065065 #rdMinAdaptiveSlotProcessingRatio_perCent

Add 13079_C RD parameter
    Add GNB swconfig    0x5808F9:9005 #rdRrcTriggeredOlcDlPerCent
    Add GNB swconfig    0x5808FA:9005 #rdRrcTriggeredOlcUlPerCent
    Add GNB swconfig    0x5808fc:9005 #rdL2PoolSigOvlSuspPsProcOlcPerCent
    Add GNB swconfig    0x5901cf:4096 #rdStateHistoryBufferRuntimeSize

Add 13079_C ABIL RD parameter
    Add GNB swconfig    0x58052e:1 #rdExtLoadCtrlOnAbil

Add 13079_CB2 TDD FDD CA RD parameter
    Add GNB swconfig    0x5808E4:1 #rdExtendedOlcReleaseFlagForCa
    Add GNB swconfig    0x5808ED:80075 #rdCaSuspendRelFddPerCent
    Add GNB swconfig    0x5808EE:76070 # dCaSuspendRelTddPerCent
    Add GNB swconfig    0x5808FD:100080 # rdCoreSoftRtNrtStopScellActOlcPerCent

Add 13079_CB2 DL CA RD parameter
    Add GNB swconfig    0x5808EF:10005 #rdCaForbidScellActOlcFddDlPerCent
    Add GNB swconfig    0x5808F0:10005 #rdCaForbidScellActOlcTddDlPerCent
    Add GNB swconfig    0x5808F3:10005 #rdCaScellStopDataOlcFddDlPerCent
    Add GNB swconfig    0x5808F4:10005 #rdCaScellStopDataOlcTddDlPerCent

Add 13079_CB2 UL CA RD parameter
    Add GNB swconfig    0x5808F1:10005 #rdCaForbidScellActOlcFddUlPerCent
    Add GNB swconfig    0x5808F2:10005 #rdCaForbidScellActOlcTddUlPerCent
    Add GNB swconfig    0x5808F5:10005 #rdCaScellStopDataOlcFddUlPerCent
    Add GNB swconfig    0x5808F6:10005 #rdCaScellStopDataOlcTddUlPerCent
    Add GNB swconfig    0x5808F7:10005 #rdCaPcellStopDataOlcFddUlPerCent
    Add GNB swconfig    0x5808F8:10005 #rdCaPcellStopDataOlcTddUlPerCent

Add Common RD parameter
     Add GNB swconfig    0x9D0000:15
     #CP-RT log level (default 1 in 19B, 2 in 20A, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x590072:1
     #CP-NRT log level (avaiable after 19B, default = 2, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x41001b:1
     #CP-RT log level (default 1 in 19B, 2 in 20A, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x590072:1
     #CP-NRT log level (default = 2, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x66001b:1
     #CP-NB log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890001:1
     #CP-SB log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890002:1
     #CP-UE log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890003:1
     #CP-CL log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890004:1
     #CP-IF log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890005:1
     #CP-SCTP log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890006:1

 Step2:Trigger TDD cell everity metrics for high load and check counter
    Log To Console   \n----------Step2:Trigger TDD cell everity metrics for a high load-------
    Start capture gnb and ap syslog in 'step2_highload' file
    Attach '${UE_NUM_SA}' SA UE'${UE_TDD_ID}'
    Send data to SA UE    low_ue_id=${UE_TDD_ID}
    Wait '60s' for stabible
    Check 13079_A TDD cell PM counters    cell_grp_id=0
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_tdd'
    [Teardown]  Stop capture gnb and ap syslog in 'step2_highload' file


 Send data to SA UE
    [Arguments]  ${ue_num}=${UE_NUM_SA}    ${dl_tput}=150M   ${ul_tput}=150M    ${low_ue_id}=${UE_ID}
     FOR    ${num}    IN RANGE    ${low_ue_id}    ${low_ue_id}+${ue_num}+1
        ${gw_pdu_r}    evaluate    ${num}%10+1
        SA send mutiple trf dl data    ${num}    2   ${dl_tput}    ${gw_pdu_r}
        SA send mutiple trf ul data    ${num}    1   ${ul_tput}   ${gw_pdu_r}
     END