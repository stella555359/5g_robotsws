*** Settings ***
Documentation      [SUITE PURPOSE]
...                Automation the test case CB012535-SR-C1_003_DFTS_OFDM_For_PUSCH_PC_1_UE_piBPSK_Capable_Middle_Cell_ET.
...
...                The main functionality of this suite is to perform a check on the scheduling behavior when DFTS_OFDM_For_PUSCH is enabled and
...                just after end of DFTS_OFDM_For_PUSCH. It verifies the presence or absence of retransmissions in the first and second slots.
...
...                [Test Case Scenario]
...                config setup for CB012535 in middle cell
...                cell_setup
...                set interference and wait 7425
...                perform a L3 SA call 0DL 5UL
...
...                loop1 with Pathloss incremantant (step 10) up to meet necessary mcs level do sched in DFTS_OFDM (piBPSK)
...                    *  check in eegate_console.log if DFTS_OFDM is set ("transformPrecoder enabled,")
...                    *  tti collecte and status regarding 12535 sched on this conditions
...                loop2 with Pathloss decrement (step 10) to exit DFTS_OFDM conditions
...                    *  tti collecte and status regarding 12535 sched on this conditions
...
...
...                Test Case Scenario author   : francois.tourlonnias@nokia.com


Library            taf.wts.runner    WITH NAME    wtsemu

Resource           ./resources/robot/CB012535_keywords_common.robot
Variables          ./resources/python/Constants.py

Suite Setup        CB012535_keywords_common.Suite Setup 12535
Suite Teardown     CB012535_keywords_common.Suite Teardown 12535
Test Teardown      CB012535_Test_Teardown

*** Variables ***
${recursion_limit}   1000   # 1000 is the default value
${NL}                Nested_List

&{A1}
...     Scfdetails=${ScfComposition}
...     Feat12535acivation=${actRimMitigationExtend_activ}
...     Feat12535deacivation=${actRimMitigationExtend_deactiv}
...     rad_param=${radList}
...     ListOfUeEngaged=${uelist}
...     PMdod=None
...     GetTtiTraceTime=500ms
...     Wait_RI_Alarm=720s
...     Wait_RI_Alarm_desapear=60s
...     dod=${AcceptanceCriteriaL1L2}
...     dod_cplt1=${AcceptanceCriteriaL1L2_DFTSOFDM_set}
...     dod_cplt2=${AcceptanceCriteriaL1L2_DFTSOFDM_Unset}
...     Pathloss=100    # set to middle cell vs cellEdgeUeDlPathlossThr value
...     cellEdgeUeDlPathlossThr=130

# Modification block ==================================================================================================
# Cells important for the test check SIB arrival only on following cell
@{CellList}          1

# SCF delivery  ====== This part help to dertemine how iso level need to be done ======================================
&{ScfComposition}
# ...     jsonFile=${TestsJsonPath}/CB012535-SR-A1_005_Trigger_of_CB012535_A_1_UE_PLthr100_64_QAM_ET_FEATURE_NOT_ACTIVATED.json
...     jsonFile=${TestsJsonPath}/CB012535-SR-C1_003.json

&{actRimMitigationExtend_activ}
...     jsonFile=${TestsJsonPath}/CB01235_actRimMitigationExtend_true.json

&{actRimMitigationExtend_deactiv}
...     jsonFile=${TestsJsonPath}/CB01235_actRimMitigationExtend_false.json

#swconfig Rad Parameters
@{radList}    @{EMPTY}
#Smallest MCS being used when shrinking PUSCH PRB in the ATB for UE scheduled with qam64LowSE-Index


#UE corner
&{UE_1_SA_TDD_UE_R15_HR_HALF_PI_BPSK}
...     ueid=1
...     ue_nr_capabilities=${SA_TDD_UE_R15_HALF_PI_BPSK}
...     ue_release=${EMPTY}    #${EMPTY} => basic already tuned correctly
...     Target_cell=1          #${EMPTY} => basic already tuned correctly

@{uelist}    ${UE_1_SA_TDD_UE_R15_HR_HALF_PI_BPSK}

#DOD Corner
@{DODlist}      # list empty for now will contain all DOD corner

@{AcceptanceCriteriaL1L2}    ${AC1}  ${AC2}
@{AcceptanceCriteriaL1L2_DFTSOFDM_set}    ${AC3}
@{AcceptanceCriteriaL1L2_DFTSOFDM_Unset}    ${AC4}

#            Trace Type           subcell_id       Message in Trace (Filter)         IE description
#...	     Requested Value
#                              (/!\  subcell_id0=Cell1)
#UE DMRS_SEQ_TYPE_1 or DMRS_SEQ_TYPE_2 for 7103-A on subcell_id=1:

&{AC1}       PcapType=L1L2       subcell_id=0     msg=uldata_puschreceivereq	      field=UlData_puschReceiveReqGrant_t.modulationOrder
...          value=na             dodtype=Extract_FirstValue    PercentTol=20
&{AC2}       PcapType=L1L2       subcell_id=0     msg=uldata_puschreceivereq	      field=UlData_puschReceiveReqGrant_t.mcs
...          value=na             dodtype=sum_2FirstValues    PercentTol=20
&{AC3}       PcapType=L1L2       subcell_id=0     msg=uldata_puschreceivereq	      field=UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
...          value=1              dodtype=ExactValueForall    PercentTol=20         #1 : enabled
&{AC4}       PcapType=L1L2       subcell_id=0     msg=uldata_puschreceivereq	      field=UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
...          value=0              dodtype=ExactValueForall    PercentTol=20         #1 : enabled

*** Test Cases ***

[1]CB012535-SR-C1_003_DFTS_OFDM_For_PUSCH_PC_1_UE_piBPSK_Capable_Middle_Cell_ET
    # [Tags]                      CLOUD_5G_I_LO_AP_LO, SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

    #Special Need for this test
    Set Suite Variable    ${userneed_PCAP}       ${True}   #bypassing a temporary issue on pcap collection ${True}
    Set Suite Variable    ${userneed_Btslog}     ${True}
    Set Suite Variable    ${userneed_PM}         ${True}    #/!\ PM is not yet available
    Set Suite Variable    ${DodIsSet}            ${True}

    CB012535_mainKW       ${A1}

*** Keywords ***

CB012535_mainKW
    [Documentation]                 CB012535-Base-
    [Arguments]                     ${param}
    kwmkt_dbg_log                   Global variable list DBGlogs: ${DBGlogs}          ##
    kwmkt_dbg_log                   info we are on KeepConfig: ${KeepConfig}           # these informative line to bypass Robot 5 new sanity :-)
    kwmkt_dbg_log                   info we are on NoSnap: ${NoSnap}                   #
    kwmkt_dbg_log                   info we are on egatelogoutput: ${egatelogoutput}   #
    kwmkt_dbg_log                   info we are on EnSher: ${EnSher}                   #
    kwmkt_dbg_log                   info we are on tti: ${tti}                         #
    kwmkt_dbg_log                   info we are on DodIsSet: ${DodIsSet}               #
    kwmkt_dbg_log                   recursion_limit: ${recursion_limit}                #
    kwmkt_dbg_log                   recursion_limit: ${LoopNb}                        ##

    Init Sequence                   ${param}
    Step                            kwmkt_Create_Test_Suite_Folder

    Critical Step                   Set_basic_context
    Critical Step                   Set_RadParameters

    # kwmkt_Block_SBTScell            2    #try to avoid alarm 4282 and 1868 on cell 1 before json cell1 modification
    # BuiltIn.sleep                   20

    Critical Step                   Set_SCF_ConfigMarket     ${param.Scfdetails}
    Critical Step                   Restart TL

    BuiltIn.sleep                   20    #to avoid capture issue at cell_setup time
    Critical Step                   kwmkt_Cell_setup         ${CellList}
    Run Keyword If                  not ${tti} and ${EnSher}                Activate Sherpa


    BuiltIn.sleep                   20

    Dated Log new line              ******** TC_C3_001_step1 ****** Interferences *************************************

    Critical Step                   kwmkt_run_script_once    ${CURDIR}/resources/egCmd/egCmd_reteInterferenceOnVictime_C1_03.sce

    #check every 30 sec if 7525 is reached and fail if not after "wait_RI_Alarm" seconds
    Wait Until Keyword Succeeds    ${param.Wait_RI_Alarm}    30s    Check_Alarm_List    7525
    Dated Log                       Check_Alarm_List done ok for alarm 7525


    #L3 call corner
    Dated Log new line              ******** TC_B4_004_step2 & step3 ****** SA L3 CALL uecapa R15 HALF_PI_BPSK **** no DL / 5mbps UL **************
    #as sometime is failing, a retry is eventually done again
    Run Keyword If                  ${userneed_PCAP}          kwmkt_Capture_Start    Attach
    ${status}=                      Run Keyword And Return Status
    ...                             kwmkt_run_script_once     ${CURDIR}/resources/egCmd/egCmd_L3call_1ue_noDL_UL5.sce
    ${status}=                      Run Keyword If           '${status}'=='False'    Run Keywords
    ...                                                       BuiltIn.sleep    10
    ...  AND                                                  kwmkt_run_script_once     ${CURDIR}/resources/egCmd/egCmd_L3call_1ue_noDL_UL5.sce
    Run Keyword If                 '${status}'=='False'       Run Keywords
    ...                                                       kwmkt_Capture_Stop     Attach
    ...  AND                                                  FAIL                   L3call failed 2 attempts
    ...  ELSE                                                 Dated Log              L3call done ok

    Run Keyword If                 ${userneed_PCAP}           kwmkt_Capture_Stop     Attach


    Dated Log new line              ******** TC_C3_001_step4 ****** UE moving pathloss ${param.Pathloss}-130 ******************
    ${pathloss_beg}=                Set Variable    ${param.Pathloss}
    ${pathloss_end}=                Set Variable    170    # The superior limit is exclusive

    FOR    ${Lnb}                   IN RANGE    ${pathloss_beg}    ${pathloss_end}    5  # 5 is the step
           stepDisp                 --- Pathloss value -- UpWard -- ${Lnb} --
           kwmkt_PathLoss_Set     1    ${Lnb}
           BuiltIn.sleep    10

           ${active_ues}               kwmkt_Get_IDs_of_Attached_UEs_From_Egate    state='ACTIVE'
           Dated Log                   active_ues >${active_ues}<
           Should Not Be Empty         ${active_ues}    No active UE found

           #BIP L1L2
           Dated log                   2s L1L2 Bip collection
           kwmkt_Capture_Start         Traff
           BuiltIn.sleep               2     #5ms
           ${pcappa}                   kwmkt_Capture_Stop                          Traff
           pcap2csv                    PcapType=L1L2    PcapLocation=${pcappa}    ParamItemValue_list=${param.dod}
           ${dod}                      CB012535_keywords_common.Check_in_pcap     PcapType=L1L2     PcapLocation=${pcappa}
           ...                                                                    ParamItemValue_list=${param.dod}

           #defence against empty list
           should not be empty         ${dod}    No data found in pcap

           ${first_element}=           Set Variable    ${dod}[0]
           ${second_element}=          Set Variable    ${dod}[1]

           Dated Log    Status done for ${pcappa} with ${dod}
           Run Keyword If              '${first_element}' == '${second_element}'    RunKeywords
           ...                                                                Dated log    we are on DFTS_OFDM For PUSCH so in piBPSK
           ...       AND                                                      Dated log    ${dod} mcs sufficient to schedule on Order1 => LoopBREAK
           ...       AND                                                      Exit For Loop
           ...       ELSE                                                         RunKeywords
           ...                                                                Dated log    ${dod} mcs not ready to schedule on Order1
           ...       AND                                                      Run Keyword If    ${Lnb} == 170
           ...                                                                Fail    msg= Pathloss max reached without DFTS_OFDM set
    END

    Dated Log new line              ******** TC_C3_001_step4Plus ****** Check if DFTS_OFDM is realy set
    pcap2csv                                   PcapType=L1L2    PcapLocation=${pcappa}    ParamItemValue_list=${param.dod_cplt1}
    CB012535_keywords_common.Check_in_pcap     PcapType=L1L2    PcapLocation=${pcappa}    ParamItemValue_list=${param.dod_cplt1}

    Dated Log new line              ******** TC_C3_001_step5 ****** Check transformPrecoder enabled in egate_console
    CallSetup.Flush Egate Console Buffer
    Traced sleep                    3s  msg=wait 3s to flush egate memory on egate_console.log
    Grep and check in file          host=${HOST_EPCSIM}             file=${tl.core.dir_path}/egate_console.log
    ...                             grep="transformPrecoder enabled,"          pattern=transformPrecoder enabled,

    Dated Log new line              ******** TC_C3_001_step6 ****** Check if CB0012535 is working OK under DFTS_OFDM
    12535_CellBehaviorCheck         TC_C3_001_step6    1116_0ms    middle_cell  #middle cell case
    Dated Log                       => its OK under DFTSOFDM we have correct transmissions and retransmission in the first and second slots
    Append to List                  ${DODlist}    True

    # 07/01/2024: replace pathloss decrease loop by ul_sinr TM desactivation
    #Dated Log new line              ******** TC_C3_001_step7 ****** UE moving pathloss back from ${Lnb}-${param.Pathloss} ******************
    Dated Log new line              ******** TC_C3_001_step7 ****** Desactivate pathloss ******************
    wtsemu.ue_testmode_set_nr       id=1    testmode=ul_sinr    profile_id=1    action=deactivate

    #${pathloss_beg}=                Set Variable    ${Lnb}-20
    #${pathloss_end}=                Set Variable    ${param.Pathloss}-20    # The superior limit is exclusive
    #FOR    ${Lnb}                   IN RANGE    ${pathloss_beg}    ${pathloss_end}    -10  # 10 is the step
    #       stepDisp                 --- Pathloss value -- DownWard --- ${Lnb} --
    #       kwmkt_PathLoss_Set       1   ${Lnb}
           BuiltIn.sleep            10

           ${active_ues}            kwmkt_Get_IDs_of_Attached_UEs_From_Egate    state='ACTIVE'
           Dated Log                active_ues >${active_ues}<
           Should Not Be Empty      ${active_ues}    No active UE found

           #BIP L1L2
           Dated log                2s L1L2 Bip collection
           kwmkt_Capture_Start      Traff
           BuiltIn.sleep            2     #5ms
           ${pcappa}                kwmkt_Capture_Stop                          Traff

           # 07/01/2024: following check doesn't detect DFTS_OFDM disabling anymore, now done by next TC_C3_001_step7Plus step only
           #pcap2csv                 PcapType=L1L2    PcapLocation=${pcappa}    ParamItemValue_list=${param.dod}
           #${dod}                   CB012535_keywords_common.Check_in_pcap     PcapType=L1L2     PcapLocation=${pcappa}
           #...                                                                 ParamItemValue_list=${param.dod}
           #${first_element}=        Set Variable    ${dod}[0]
           #${second_element}=       Set Variable    ${dod}[1]
           #Run Keyword If           '${first_element}' == '${second_element}'    RunKeywords
           #...                                                                   Dated log    ${dod} mcs sufficient to schedule on Order1
           #...       AND            Fail    msg= If Pathloss decrease the mcs should increase and Order1 may not be possible in these conditions
           #...       ELSE                                                        RunKeywords
           #...                                                               Dated log    we are not anymore on DFTS_OFDM For PUSCH
           #...       AND                                                  Dated log    ${dod} mcs sufficient to not schedule on Order1 => LoopBREAK
           #...       AND                                                      Exit For Loop
           #Dated Log                Status done for ${pcappa} with ${dod}

    #END

    Dated Log new line              ******** TC_C3_001_step7Plus ****** Check if DFTS_OFDM is really Unset
    pcap2csv                                   PcapType=L1L2    PcapLocation=${pcappa}    ParamItemValue_list=${param.dod_cplt2}
    CB012535_keywords_common.Check_in_pcap     PcapType=L1L2    PcapLocation=${pcappa}    ParamItemValue_list=${param.dod_cplt2}


    Dated Log new line              ******** TC_C3_001_step8 ****** CHECKs CB0013535 still working without DFTS_OFDM set **************************
    12535_CellBehaviorCheck         TC_C3_001_step8    1116_0ms    middle_cell  #middle cell case
    Dated Log                       => its OK back on no DFTSOFDM scheduling time, we have still correct trans and retrans in the 1st and sec slots
    Append to List                  ${DODlist}    True

    Dated Log new line             ******** END TC C3_001 **** Stat on DOD list if requested ******************************************************
    Run Keyword If                 ${DodIsSet}         kwmkt_Check_For_False_In_${NL}    ${DODlist}

