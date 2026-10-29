*** Settings ***
Documentation      [SUITE PURPOSE]  Template of Test cases CB012535 feature
...                Test Case Scenario author   : francois.tourlonnias@nokia.com
...
...                This Template need your attention on following part of this common database
...                Please modify as you need data value between # Modification block / # END Modification block

...                Follow up to be erased:
...                Ue_capa           =======>   done
...                scf configuration =======>   done
...                Pathloss evolution  =====>   on going


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
...     PMdod=testsuite/Paris/RRM/ET/CB012535/resources/config/PM/CB012535-SR-B2_004_ATB_HR_CASE_UE_scheduled_on_both_UL_slots_1116_ET.csv
...     GetTtiTraceTime=500ms
...     Wait_RI_Alarm=720s
...     Wait_RI_Alarm_desapear=60s

# Modification block ==================================================================================================
# Cells important for the test check SIB arrival only on following cell
@{CellList}          1

# SCF delivery  ====== This part help to dertemine how iso level need to be done ======================================
&{ScfComposition}
# ...     jsonFile=${TestsJsonPath}/CB012535-SR-A1_005_Trigger_of_CB012535_A_1_UE_PLthr100_64_QAM_ET_FEATURE_NOT_ACTIVATED.json
...     jsonFile=${TestsJsonPath}/CB012535-SR-B2_004.json

&{actRimMitigationExtend_activ}
...     jsonFile=${TestsJsonPath}/CB01235_actRimMitigationExtend_true.json

&{actRimMitigationExtend_deactiv}
...     jsonFile=${TestsJsonPath}/CB01235_actRimMitigationExtend_false.json

#swconfig Rad Parameters
@{radList}    ${radDic_58072d}
${rdSmallestMcsATBLowSEValue}    6
&{radDic_58072d}     field=0x58072d    value=${rdSmallestMcsATBLowSEValue}
#Smallest MCS being used when shrinking PUSCH PRB in the ATB for UE scheduled with qam64LowSE-Index


#UE corner
&{UE_1_SA_TDD_UE_R15_HR}
...     ueid=1
...     ue_nr_capabilities=${SA_TDD_UE_R15_High_Reliability_PDSCH_PUSCH}
...     ue_release=${EMPTY}    #${EMPTY} => basic already tuned correctly
...     Target_cell=1          #${EMPTY} => basic already tuned correctly

@{uelist}    ${UE_1_SA_TDD_UE_R15_HR}

#DOD Corner
@{DODlist}      # list empty for now will contain all DOD corner
${LoopNb}        1           #number of loop for robustness
# END Modification block ==============================================================================================

*** Test Cases ***

[1]CB012535-SR-B2_004_ATB_HR_CASE_UE_scheduled_on_both_UL_slots_1116_ET
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

    Critical Step                   Set_SCF_ConfigMarket     ${param.Scfdetails}
    Critical Step                   Restart TL

    BuiltIn.sleep                   20    #to avoid capture issue at cell_setup time
    Critical Step                   kwmkt_Cell_setup         ${CellList}
    Run Keyword If                  not ${tti} and ${EnSher}                Activate Sherpa


    BuiltIn.sleep                   20

    Dated Log new line              ******** TC_B2_004_step1 ****** Interferences *************************************

    # Critical Step                   kwmkt_run_script_once    ${CURDIR}/resources/egCmd/egCmd_reteInterferenceOnVictime_ultraSoft.sce
    # Critical Step                   kwmkt_run_script_once    ${CURDIR}/resources/egCmd/egCmd_reteInterferenceOnVictime_Laurent.sce
    Critical Step                   kwmkt_run_script_once    ${CURDIR}/resources/egCmd/egCmd_reteInterferenceOnVictime_B2_04.sce

    #check every 30 sec if 7525 is reached and fail if not after "wait_RI_Alarm" seconds
    Wait Until Keyword Succeeds    ${param.Wait_RI_Alarm}    30s    Check_Alarm_List    7525
    Dated Log                       Check_Alarm_List done ok for alarm 7525



    # Dated Log new line              ******** TC_B2_004_step2 ****** 12535 DEactivation ********************************
    # 12535 DEactivation is cancelled in the CRT test
    # set actRimMitigationExtend to false
    # Set_SCF_ConfigMarket           ${param.Feat12535deacivation}

    # FAIL        Test blocked at this point, we are on B2_004 test condition



    #L3 call corner
    Dated Log new line              ******** TC_B2_004_step3 & step4 ****** SA L3 CALL uecapa R15 HR **** no DL / 5mbps UL **************
    #as sometime is failing, a retry is eventually done again
    Run Keyword If                 ${userneed_PCAP}          kwmkt_Capture_Start    Attach
    ${status}=                     Run Keyword And Return Status
    ...                            kwmkt_run_script_once     ${CURDIR}/resources/egCmd/egCmd_L3call_1ue_noDL_UL5.sce
    ${status}=                     Run Keyword If           '${status}'=='False'    Run Keywords
    ...                                                      BuiltIn.sleep    10
    ...  AND                                                 kwmkt_run_script_once     ${CURDIR}/resources/egCmd/egCmd_L3call_1ue_noDL_UL5.sce
    Run Keyword If                '${status}'=='False'       Run Keywords
    ...                                                      kwmkt_Capture_Stop     Attach
    ...  AND                                                 FAIL                   L3call failed 2 attempts
    ...  ELSE                                                Dated Log              L3call done ok

    Run Keyword If                ${userneed_PCAP}           kwmkt_Capture_Stop     Attach

    #check with TTI trace or BIP message that UL first transmissions and UL retransmissions occur in both first (Slot 8/18)
    #and second (Slot 9/19) UL slots.
    Run Keyword If                 ${tti} and not ${EnSher}            kwmkt_TTI_capt    ${param.GetTtiTraceTime}    Step4control


    Dated Log new line              ******** TC_B2_004_step5 ****** UE moving pathloss 80-110 10by10 ******************
    ${pathloss_beg}=    Set Variable    80
    ${pathloss_end}=    Set Variable    120    # The superior limit is exclusive
    FOR    ${Lnb}                  IN RANGE    ${pathloss_beg}    ${pathloss_end}    10  # 10 is the step
           stepDisp                --- Pathloss value -- ${Lnb} --
           kwmkt_PathLoss_Set      1    ${Lnb}
           BuiltIn.sleep    10
           # try to change the interference level according to the pathloss
           # Run Keyword If          ${Lnb} == 100
           #...                     kwmkt_run_script_once    ${CURDIR}/resources/egCmd/egCmd_reteInterferenceOnVictime_Laurent_Plus10.sce
    END

    ${active_ues}                  kwmkt_Get_IDs_of_Attached_UEs_From_Egate    state='ACTIVE'
    Dated Log                      active_ues >${active_ues}<
    Should Not Be Empty           ${active_ues}    No active UE found

    Run Keyword If                 ${tti} and not ${EnSher}            kwmkt_TTI_capt    ${param.GetTtiTraceTime}    Step5control
    #when Pasthloss campain is done, feature activation is done


    Dated Log new line              ******** TC_B2_004_step6 ****** 12535 ON ******************************************

    # Dated Log    BREAKPOINT
    # FAIL         Test blocked at this point, we are on B2_004 test conditions but there is a UE_release when 12535 is back to ON

    1235_actRimMitigationExtend_true_tti     Step6_12535_act      ${param.Feat12535acivation}      ${tti}    ${EnSher}

    #Run Keyword If                 ${tti} and not ${EnSher}            kwmkt_TTI_capt    ${param.GetTtiTraceTime}    Step6control


    Dated Log new line              ******** TC_B2_004_step7 ****** CHECKs ******************************************

    ${TTIpcap}              kwmkt_TTI_capt_pcap       tgtDir=${logsDir}/TTI_CB0012535_B2_004    time=10s
    ${TTIjson}  ${TTIcsv}   kwmkt_TTI_convert_pcap    TTIpcap=${TTIpcap}

    ${nb1stTx1stSlot}    ${nbReTx1stSlot}    ${nb1stTx2ndSlot}    ${nbReTx2ndSlot}
    ...                     getUeUlSchedulingSlots    jsonPathName=${TTIjson}    frameStruct=1116_0ms

    ${ATBcheckStatus}       checkATB_HRUE_B02_004     jsonPathName=${TTIjson}    smallestMcsATBLowSE=${rdSmallestMcsATBLowSEValue}

    Should Be True          ${nbReTx1stSlot} == 0 and ${nb1stTx1stSlot} != 0 and ${ATBcheckStatus} != 0

    #PM counters
    ${PMdod} =                      Run Keyword If      ${userneed_PM}    Run Keyword And Return Status    kwmkt_PM_general
    Dated Log                       ${PMdod}
    Append to List                  ${DODlist}    ${PMdod}

    Dated Log new line              ******** END TC B2_04 *************************************************************
    #Stat on DOD list if requested   voir DOD plus tard
    Run Keyword If                 ${DodIsSet}         kwmkt_Check_For_False_In_${NL}    ${DODlist}
