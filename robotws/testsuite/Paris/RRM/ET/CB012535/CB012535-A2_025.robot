*** Settings ***
Documentation      [SUITE PURPOSE]  Template of Test cases CB012535 feature
...                Test Case Scenario author   : laurent.puchelle@nokia.com
...
...                This Template need your attention on following part of this common database
...                Please modify as you need data value between # Modification block / # END Modification block

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
...     ListOfUeEngaged=${uelist}
...     PMdod=testsuite/Paris/RRM/ET/CB012535/resources/config/PM/CB012535_Constraints_A2_xxx.csv
...     GetTtiTraceTime=1s
...     Wait_RI_Alarm=720s
...     Wait_RI_Alarm_desapear=60s

# Modification block ==================================================================================================
# Cells important for the test check SIB arrival only on following cell
@{CellList}          1

# SCF delivery  ====== This part help to dertemine how iso level need to be done ======================================
&{ScfComposition}
# ...     jsonFile=${TestsJsonPath}/CB012535-SR-A1_005_Trigger_of_CB012535_A_1_UE_PLthr100_64_QAM_ET_FEATURE_NOT_ACTIVATED.json
...     jsonFile=${TestsJsonPath}/CB012535-SR-A2_UE_PLthr100_256_QAM_ET.json

&{actRimMitigationExtend_activ}
...     jsonFile=${TestsJsonPath}/CB01235_actRimMitigationExtend_true.json

&{actRimMitigationExtend_deactiv}
...     jsonFile=${TestsJsonPath}/CB01235_actRimMitigationExtend_false.json


#UE corner
&{UE_1_SA_TDD_UE_R15}
...     ueid=1
...     ue_nr_capabilities=${SA_TDD_UE_R15}
...     ue_release=${EMPTY}    #${EMPTY} => basic already tuned correctly
...     Target_cell=1          #${EMPTY} => basic already tuned correctly

@{uelist}    ${UE_1_SA_TDD_UE_R15}

#DOD Corner
@{DODlist}      # list empty for now will contain all DOD corner
${LoopNb}       10           #number of loop for robustness
# END Modification block ==============================================================================================

*** Test Cases ***

[1]CB012535_SR_A2_025_Robustness_Test_1_UE_Cell_Edge_RIM_Detection_ON_OFF_ET
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
    Critical Step                   Set_SCF_ConfigMarket     ${param.Scfdetails}
    Critical Step                   Restart TL

    BuiltIn.sleep                   20    #to avoid capture issue at cell_setup time
    Critical Step                   kwmkt_Cell_setup         ${CellList}
    Run Keyword If                  not ${tti} and ${EnSher}                Activate Sherpa


    BuiltIn.sleep                   20
    # Critical Step                   kwmkt_run_script_once    ${CURDIR}/resources/egCmd/egCmd_reteInterferenceOnVictime_ultraSoft_II.sce
    Critical Step                   kwmkt_run_script_once    ${CURDIR}/resources/egCmd/egCmd_reteInterferenceOnVictime_ultraSoft.sce


    #check every 30 sec if 7525 is reached and fail if not after "wait_RI_Alarm" seconds
    Wait Until Keyword Succeeds    ${param.Wait_RI_Alarm}    30s    Check_Alarm_List    7525
    Dated Log                      Check_Alarm_List done ok for alarm 7525

    #L3 call corner
    #as sometime is failing, a retry is eventually done again
    Run Keyword If                 ${userneed_PCAP}          kwmkt_Capture_Start    Attach
    ${status}=                     Run Keyword And Return Status
    ...                            kwmkt_run_script_once     ${CURDIR}/resources/egCmd/egCmd_L3call_1ue_DL2_UL1.sce
    ${status}=                     Run Keyword If           '${status}'=='False'    Run Keywords
    ...                                                      BuiltIn.sleep    10
    ...  AND                                                 kwmkt_run_script_once     ${CURDIR}/resources/egCmd/egCmd_L3call_1ue_DL2_UL1.sce
    Run Keyword If                '${status}'=='False'       Run Keywords
    ...                                                      kwmkt_Capture_Stop     Attach
    ...  AND                                                 FAIL                   L3call failed 2 attempts
    ...  ELSE                                                Dated Log              L3call done ok

    Run Keyword If                ${userneed_PCAP}           kwmkt_Capture_Stop     Attach

    #PAthloss Bler corner
    Critical Step                  kwmkt_run_script_once    ${CURDIR}/resources/egCmd/egCmd_Pathloss_105_2setAttachedUEinCellEdge.sce
    Critical Step                  kwmkt_run_script_once    ${CURDIR}/resources/egCmd/egCmd_10PcentULBlerOnFirstTransOnly.sce

    # pour info
    # Dated Log    dist_name- ${param}[Feat12535acivation]
    # dist_name- [{'dist_name': 'MRBTS-1/NRBTS-1/NRCELL-1/NRRIM_PROFILE-1', 'param': 'actRimMitigationExtend', 'value': 'true'}]

    # Set Global Variable           ${Dated Log}     LoopDatedLog
    #Loop for robustness
    FOR    ${cur_loop}             IN RANGE    0    ${LoopNb}
           ${Lnb}=                 Evaluate         ${cur_loop} + 1
           stepDisp                --- Rob loop number -- ${Lnb} --
           ${StepName}=            set Variable     1235_A2_025_loop${Lnb}

           1235_actRimMitigationExtend_false    loopstep=${StepName}_deact    p=${param.Feat12535deacivation}    tti=0    EnSher=0

           ${TTIpcap}              kwmkt_TTI_capt_pcap       tgtDir=${logsDir}/TTI_CB0012535_A2_025    suffix=loop${Lnb}_step1_deact    time=10s
           ${TTIjson}  ${TTIcsv}   kwmkt_TTI_convert_pcap    TTIpcap=${TTIpcap}
           ${nb1stTx1stSlot}    ${nbReTx1stSlot}    ${nb1stTx2ndSlot}    ${nbReTx2ndSlot}
           ...                     getUeUlSchedulingSlots    jsonPathName=${TTIjson}    frameStruct=1116_3ms
           Should Be True          ${nbReTx1stSlot} != 0 and ${nb1stTx1stSlot} != 0 and ${nb1stTx2ndSlot} != 0

           1235_actRimMitigationExtend_true     loopstep=${StepName}_act      p=${param.Feat12535acivation}    tti=0    EnSher=0

           ${TTIpcap}              kwmkt_TTI_capt_pcap       tgtDir=${logsDir}/TTI_CB0012535_A2_025    suffix=loop${Lnb}_step2_act    time=10s
           ${TTIjson}  ${TTIcsv}   kwmkt_TTI_convert_pcap    TTIpcap=${TTIpcap}
           ${nb1stTx1stSlot}    ${nbReTx1stSlot}    ${nb1stTx2ndSlot}    ${nbReTx2ndSlot}
           ...                     getUeUlSchedulingSlots    jsonPathName=${TTIjson}    frameStruct=1116_3ms
           Should Be True          ${nbReTx1stSlot} == 0 and ${nbReTx2ndSlot} != 0
           Should Be True          ${nb1stTx1stSlot} == 0 and ${nb1stTx2ndSlot} != 0
    END
    # Set Global Variable            ${Dated Log}     LoopDatedLog


    #Check if 7525 is still present
    ${res}                          Check_Alarm_List                 7525
    ${result}                       Set Variable if                 '${res}'!='Found'     False   True
    Append to List                  ${DODlist}    ${result}

    #PM counters
    #${PMdod} =	                    Run Keyword If      ${userneed_PM}    Run Keyword And Return Status    kwmkt_PM_general
    #Dated Log                       ${PMdod}
    #Append to List                  ${DODlist}    ${PMdod}

    #Stat on DOD list if requested
    Run Keyword If                  ${DodIsSet}         kwmkt_Check_For_False_In_${NL}    ${DODlist}
