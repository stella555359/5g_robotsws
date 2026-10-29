*** Settings ***
Documentation     CB0013709 case
...
Test Timeout      180 minutes
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_BLLL_AP_LOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G

Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

Resource    ./Resource/13709_keyword.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}          SCFC_ABIL_TMO.xml
${AIRPHONE_NAME}      IPHY_ABIL_TMO.xml
${WTS_NAME}           WTS_ABIL_TMO.cfg


${UE_ID}          1
${PDU_ID1}         1
${GW_ID1}          1
${SLICE_ID}       1
${UE_NUM_SA}               15
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

@{LOG_NAME_LIST}    gnb_snapshot    egatelog
@{Rdparameter}    0x420062:1  0x800057:0
${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60

@{Common_Rdparameter}    0x9D0000:15

@{13709_A_Rdparameter}    0x5808A6:1 #rdEnableOverloadErrMsg    0x5800CA:4004004 #rdMaxNumUeTdDl    0x5800CB:4004004 #rdMaxNumUeTdUl
...    0x580822:30030030 #rdMinAdaptiveSlotProcessingRatio_perCent

@{13709_CB56_Rdparameter}    0x5808F9:9005 #rdRrcTriggeredOlcDlPerCent    0x5808FA:9005 #rdRrcTriggeredOlcUlPerCent
...    0x5808FC:9005 #rdL2PoolSigOvlSuspPsProcOlcPerCent    0x5901CF:4096 #rdStateHistoryBufferRuntimeSize
...    0x5807EC:9005 #tddrdMaxNumUeTdDl    0x5807ED:9005 #tddrdMaxNumUeTdUl

@{13709_ABIL_Rdparameter}    0x58052E:1 #rdExtLoadCtrlOnAbil

@{13709_D_Rdparameter}    0x5902CA:1 #rdEnableCB013709DUpd001#CPRT    0x5902BA:1 #rdEnableCB013709#CPRT
...    0x6601F0:1 #rdEnableCB013709DUpd001#CPRT    0x6601EF:1 #rdEnableCB013709#CPNRT


@{13709_F_Rdparameter}    0x58014D:3003 #rdSlotDurationSwitchingOlcPerCent    0x58012D:2 #rdK2min
...    0x580179:3003 #rdPDSCHSkipSpecialSlotOlcPerCent

@{13709_CB1_CA_Rdparameter}    0x5808E4:1 #rdExtendedOlcReleaseFlagForCa    0x5808ed:4003 #rdCaSusipendRelFddPerCent
...    0x5808ee:4003 #rdCaSuspendRelTddPerCent    0x5808ef:5004 #rdCaForbidScellActOlcFddDlPerCent
...    0x5808f0:5004 #rdCaForbidScellActOlcTddDlPerCent    0x5808f1:5004 #rdCaForbidScellActOlcFddUlPerCent
...    0x5808f2:5004 #rdCaForbidScellActOlcTddUlPerCent    0x5808f3:4003 #rdCaScellStopDataOlcFddDlPerCent
...    0x5808f4:4003 #rdCaScellStopDataOlcTddDlPerCent    0x5808f5:4003 #rdCaScellStopDataOlcFddUlPerCent
...    0x5808f6:4003 #rdCaScellStopDataOlcTddUlPerCent    0x5808f7:4003 #rdCaPcellStopDataOlcFddUlPerCent
...    0x5808f8:4003 #rdCaPcellStopDataOlcTddUlPerCent    0x5808FD:4003 #rdCoreSoftRtNrtStopScellActOlcPerCent
...    0x5901CF:4096 #rdStateHistoryBufferRuntimeSize

@{13709_CB_MU_Rdparameter}   0x5805D6:1001 #rdMuMimoRedvUeLowOlcDlPerCent    0x5805D7:2002 #rdMuMimoRedvUeMedOlcDlPerCent
...    0x5805D8:3003 #rdMuMimoRedvUeHighOlcDlPerCent    0x5805D9:4004 #rdMuMimoDeactOlcDlPerCent
...    0x5805D2:1001 #rdMuMimoRedvUeLowOlcUlPerCent    0x5805D3:2002 #rdMuMimoRedvUeMedOlcUlPerCent
...    0x5805D4:3003 #rdMuMimoRedvUeHighOlcUlPerCent    0x5805D5:4004 #rdMuMimoDeactOlcUlPerCent


*** Test Cases ***
CB013709_26R1Drop15-TMO-CVR-2_Verification
   Step1:Commission configuration for onair
   Step2:Trigger TDD cell everity metrics for high load and check counter
   Attach one UE '20' should be RRC Reject for OverLoad
   Step3:Change tmpActFeat1 feature disable
   Step4:Change tmpActFeat1 feature enable


*** Keywords ***
Step1:Commission configuration for onair
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Add GNB swconfig    @{Common_Rdparameter}
    Add GNB swconfig    @{13709_A_Rdparameter}
    Add GNB swconfig    @{13709_CB56_Rdparameter}
    Add GNB swconfig    @{13709_ABIL_Rdparameter}
    Get and Update BSR File    par_of_bsr_name=BSR_AEQV_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Prepare gnb onair    multi_cells=True


Step2:Trigger TDD cell everity metrics for high load and check counter
    Log To Console   \n----------Step2:Trigger TDD cell everity metrics for a high load-------
    Start capture gnb and ap syslog in 'step2_highload' file
    Attach UEs and Check 13079_A PM counters
    [Teardown]  Stop capture gnb and ap syslog in 'step2_highload' file

Attach one UE '${ue_id}' should be RRC Reject for OverLoad
   Log To Console   \n----------Attach one UE fail for OverLoad -------
   #Run Keyword And Expect Error     *RRC Reject was received*    Airphone SA Attach    ue_id=${ue_id}
   airphone_sa_attach_rrc_reject    ue_id=${ue_id}
   Run Keyword And Ignore Error     Airphone SA Detach    ue_id=${ue_id}

Attach UEs and Check 13079_A PM counters
    Attach '${UE_NUM_SA}' SA UE'${UE_TDD_ID}'
    Send data to SA UE    low_ue_id=${UE_TDD_ID}
    Wait '60s' for stabible
    Check 13079_A TDD cell PM counters    cell_grp_id=0
    #    Start collect ttitrace
#    Wait for '1s' to stop ttitrace with name'tti_tdd'

Attach one UE with id '${ue_id}'
    Log To Console   \n----------Attach one UE -------
    Airphone SA Attach    ue_id=${ue_id}
    Wait '2s' for stabible
    Airphone Set Traffic Type    ue_id=${ue_id}    pdu_id=1    type=internal
    Wait '2s' for stabible
    Airphone Pdu Session Setup    ue_id=${ue_id}   pdu_id=1   nwslice_id=1   gw_id=2
    Wait '2s' for stabible
    Airphone SA Start Data Traffic    ue_id=${ue_id}    direction=DL   throughput=130M   pdu_id=1   duration=3600   trf_id=1
    Wait '2s' for stabible
    Airphone SA Detach    ue_id=${ue_id}
    #Start collect ttitrace
    #Wait for '1s' to stop ttitrace with name'tti_fdd'


Online change actOvlProtL2Sched to '${flag}'
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-1    actOvlProtL2Sched    ${flag}    online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    TAF_ADMIN.teardown admin    connection=online

Online change actOvlProtL2Sig to '${flag}'
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-1    actOvlProtL2Sig    ${flag}    online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    TAF_ADMIN.teardown admin    connection=online

Change tmpActFeat1 to '${flag}'
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-1    tmpActFeat1    ${flag}    online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    Wait '30s' for stabible
    TAF_ADMIN.teardown admin    connection=online

Step3:Change tmpActFeat1 feature disable
    Log To Console   \n----------Step3:Change tmpActFeat1 feature disable -------
    Start capture only gnb syslog in 'step3_tmpActFeat1_dis' file
    Change tmpActFeat1 to '1'
    Airphone Detach'${UE_TDD_ID}'SA UE'${UE_NUM_SA}'
    Attach UEs and Check 13079_A PM counters

    Attach one UE with id '20'
    [Teardown]  Stop capture gnb and ap syslog in 'step3_tmpActFeat1_dis' file

Step4:Change tmpActFeat1 feature enable
    Log To Console   \n----------Step4:Change tmpActFeat1 feature enable -------
    Start capture only gnb syslog in 'step4_tmpActFeat1_en' file
    Change tmpActFeat1 to '0'
    Airphone Detach'${UE_TDD_ID}'SA UE'${UE_NUM_SA}'
    Attach UEs and Check 13079_A PM counters

    Attach one UE '20' should be RRC Reject for OverLoad
    [Teardown]  Stop capture gnb and ap syslog in 'step4_tmpActFeat1_en' file

Add 13079_C RD parameter
    Add GNB swconfig    0x5808F9:9005 #rdRrcTriggeredOlcDlPerCent
    Add GNB swconfig    0x5808FA:9005 #rdRrcTriggeredOlcUlPerCent
    Add GNB swconfig    0x5808FC:9005 #rdL2PoolSigOvlSuspPsProcOlcPerCent
    Add GNB swconfig    0x5901CF:4096 #rdStateHistoryBufferRuntimeSize


Add 13079_C ABIL RD parameter
    Add GNB swconfig    0x58052E:1 #rdExtLoadCtrlOnAbil

Add 13079_A RD parameter
    #13709 overload control
    Add GNB swconfig    0x5808A6:1 #rdEnableOverloadErrMsg
    #13709-rt
    Add GNB swconfig    0x5800CA:4004004 #rdMaxNumUeTdDl
    Add GNB swconfig    0x5800CB:4004004 #rdMaxNumUeTdUl
    #13709-nrt
    Add GNB swconfig    0x580932:5 #rdNbProcedureContextsMaxLimit
    Add GNB swconfig    0x580933:1 #rdNbProcedureContextsLow
    #0x580934 = 2 #rdNbProcedureContextsHigh
    #13709-core
    #0x580821 = 30030030 #rdMaxAdaptiveSlotProcessingRatio_perCent
    Add GNB swconfig    0x580822:65065065 #rdMinAdaptiveSlotProcessingRatio_perCent

Add 13079_D RD parameter
	Add GNB swconfig    0x5902CA:1 #rdEnableCB013709DUpd001#CPRT
    Add GNB swconfig    0x5902BA:1 #rdEnableCB013709#CPRT
    Add GNB swconfig    0x6601F0:1 #rdEnableCB013709DUpd001#CPRT
    Add GNB swconfig    0x6601EF:1 #rdEnableCB013709#CPNRT
#    Add GNB swconfig    0x5A0614:1 #rdDebugBearerManagement#L2HICU
#    Add GNB swconfig    0x5A0605:1 #rdDebugBufferConsumption #L2HIDU
#    Add GNB swconfig    0x5A0616:1  #rdDebugPacketRetention#L2HICU
#    Add GNB swconfig    0x5B0615:1  #rdDebugDlDataLimiter#L2HICU
#    Add GNB swconfig    0x5a008f:1 #rdBufferCongestionTracingEnabled#L2HICU
#    Add GNB swconfig    0x5B0615:1  #rdDebugPacketRetention#L2HIDU

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

Check 13079_A TDD cell PM counters
    [Arguments]    ${cell_grp_id}=0
    Wait '60s' for stabible
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
    Check 13709_A TDD cell DL_NRT_CORE_SVT_METRIC    ${PM_counter_file}    cell_grp_id=${cell_grp_id}

Check 13709_A TDD cell DL_NRT_CORE_SVT_METRIC
     [Arguments]    ${counter_file}    ${cell_grp_id}=0
    ${M55208C00001_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00001    cell_grp_id=0
    ${M55208C00002_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00002    cell_grp_id=0
    ${M55208C00003_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00003    cell_grp_id=0
    ${M55208C00004_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00004    cell_grp_id=0
    ${M55208C00005_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00005    cell_grp_id=0
    ${M55208C00006_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00006    cell_grp_id=0
    ${M55208C00007_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00007    cell_grp_id=0
    ${M55208C00008_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00008    cell_grp_id=0
    ${M55208C00009_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00009    cell_grp_id=0
     ${M55208C00010_MIN_DL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00010    cell_grp_id=0
     ${M55208C00011_MAX_DL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00011    cell_grp_id=0
     ${M55208C00012_AVGE_DL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00012    cell_grp_id=0
     ${M55208C00013_MIN_UL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00013    cell_grp_id=0
     ${M55208C00014_MAX_UL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00014    cell_grp_id=0
     ${M55208C00015_AVGE_UL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00015    cell_grp_id=${cell_grp_id}
    should be true    ${M55208C00001_value}>=0 and ${M55208C00001_value}<100
    should be true    ${M55208C00002_value}>0 and ${M55208C00002_value}<100
    should be true    ${M55208C00003_value}>0 and ${M55208C00003_value}<100
    should be true    ${M55208C00004_value}>=0 and ${M55208C00004_value}<100
    should be true    ${M55208C00005_value}>0 and ${M55208C00005_value}<100
    should be true    ${M55208C00006_value}>0 and ${M55208C00006_value}<100
    should be true    ${M55208C00007_value}==0 and ${M55208C00007_value}<100
    should be true    ${M55208C00008_value}==0 and ${M55208C00008_value}<100
    should be true    ${M55208C00009_value}==0 and ${M55208C00009_value}<100
    Should Be True    ${M55208C00010_MIN_DL_NRT_CORE_SVT_METRIC}==0 and ${M55208C00010_MIN_DL_NRT_CORE_SVT_METRIC}<100
    Should Be True    ${M55208C00011_MAX_DL_NRT_CORE_SVT_METRIC}==0 and ${M55208C00011_MAX_DL_NRT_CORE_SVT_METRIC}<100
    Should Be True    ${M55208C00012_AVGE_DL_NRT_CORE_SVT_METRIC}==0 and ${M55208C00012_AVGE_DL_NRT_CORE_SVT_METRIC}<100
    Should Be True    ${M55208C00013_MIN_UL_NRT_CORE_SVT_METRIC}==0 and ${M55208C00013_MIN_UL_NRT_CORE_SVT_METRIC}<100
    Should Be True    ${M55208C00014_MAX_UL_NRT_CORE_SVT_METRIC}==0 and ${M55208C00014_MAX_UL_NRT_CORE_SVT_METRIC}<100
    Should Be True    ${M55208C00015_AVGE_UL_NRT_CORE_SVT_METRIC}==0 and ${M55208C00015_AVGE_UL_NRT_CORE_SVT_METRIC}<100

Check SA UE throughput
    Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput

Verify multi SA UEs throughput
    FOR    ${num}    IN RANGE    1    8+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        Run Keyword If    ${num}!=${7} and ${num}!=${8}    should_be_true    ${dl_throughput_pcell}>200000
    END

Airphone Detach'${LOW_UE_ID}'SA UE'${UE_NUM_SA}'
     FOR    ${num}    IN RANGE    ${LOW_UE_ID}    ${LOW_UE_ID}+${UE_NUM_SA}+1
        Run Keyword And Ignore Error    Airphone SA Detach    ue_id=${num}
     END

Attach '${UE_NUM_SA}' SA UE'${LOW_UE_ID}'
     FOR    ${num}    IN RANGE    ${LOW_UE_ID}    ${LOW_UE_ID}+${UE_NUM_SA}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
       Airphone SA Attach    ue_id=${num}
       Wait '1s' for stabible
       Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${gw_pdu_r}    type=internal
       Wait '1s' for stabible
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${gw_pdu_r}   nwslice_id=1   gw_id=${gw_pdu_r}
       Wait '1s' for stabible
     END

Send data to SA UE
    [Arguments]  ${ue_num}=${UE_NUM_SA}    ${dl_tput}=150M   ${ul_tput}=150M    ${low_ue_id}=${UE_ID}
     FOR    ${num}    IN RANGE    ${low_ue_id}    ${low_ue_id}+${ue_num}+1
        ${gw_pdu_r}    evaluate    ${num}%10+1
        SA send mutiple trf dl data    ${num}    2   ${dl_tput}    ${gw_pdu_r}
        SA send mutiple trf ul data    ${num}    1   ${ul_tput}   ${gw_pdu_r}
     END
