*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB008662 step AC
...
...               Test Case Scenario author   : yann.ah.herve@nokia.com
...               Test Case Scenario contact  : yann.ah.herve@nokia.com
...               Test Case automation author : yann.ah.herve@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...               Creation Date               : 26-September-2022
...               Last Modified by            : vincent.boulet@nokia.com
...               Modification:
...                       26-September-2022   | Creation
...                       10-October-2023     | Move to LO_LO topology (replace bit error TM with legacy UL SINR TM)
...                                           | and remove ABIL dependency (ABIL no more available)
...                       22-February-2023    | martial.hummel@nokia.com
...                       17-May-2024         | Parity testing to introduce dRNIC RINLINE2 CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
#vbo#obsolete#

Resource                         ./CB008662_keywords.robot
Resource                         ../../../resources/common/TtiTrace/ttitrace.robot
Resource                         ../../../../../resources/SWENG/robot/WtsXmlConfig.robot
Resource                         ../../../../../resources/SWENG/robot/WtsCfgConfig.robot
Resource                         ../../../../../resources/SWENG/robot/Counters.robot
Resource                         ../../../../../resources/SWENG/robot/KPIs.robot
Library                          ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME     coam_parameter
Library                          taf.sbts.oam.coam.admin           WITH NAME   sbts_coam
Library                          ../python/CB008662_CheckTTITraceDL.py


*** Variables ***
${GP_period}                     300
${UL_traffic_duration}           300
${UL_trace_duration}             10
${UL_troughput}                  50

${TputVolMargin}                 5

${gnb_alias}                     gnb_under_test
${ps_bwp_delta_file}             testsuite/Paris/RRM/ET/CB008662/config/Delta_Configuration_scf_Enable_Adaptive_ReTX_UL.json
${CONSTRAINTS_FILE}              testsuite/Paris/RRM/ET/CB008662/config/CB008662_AC_06_Constraints.csv
${CONSTRAINTS_FILE_VDU}          ${CURDIR}/../../config/CB008662_AC_06_Constraints_VDU.csv

${MaxAdaptiveReTxErrorRatio}     3

# To be able to perform RANK2 in UL and check M55303C01031 (PUSCH transmissions in Rank2 with CP-OFDM and 64QAM MCS table)
# maxNumberSRS-Ports-PerResource => change to n2 from n1
# maxNumberMIMO-LayersCB-PUSCH => chage to “twoLayers” from “oneLayer”
# maxNumberSRS-ResourcePerSet =>change to 2 from 1
# UE capa suitable for band n71 for test over ABIP and band n1 for test over ABIO + ORAN variant
${UE_CAPA_MIMO_UL_2_LAYERS}       SEPARATOR=
...                     "E1A01000014F5E0302C0020840009041B38987C284804D8041FF9863CA160704C060188A0300A63004A0F88DAC31B
...                      47498A823F96524CA0D00416C9824060C78C7FE618F28581C0E1E026761D86761D8283E006B0C6D1D262A08FE5949
...                      328340105B260901831E31FF9863CA160703878099D87619D87600C006000000000E2300000000380000000001041
...                      808D00039343E01C8200000148200000548200000949280000D300B81B791B5BA4014100000965250400006594941
...                      0000296525040000E594941000049652524000154B292809A075748EAE8554D2AA8AED40B003C00D0080400000000
...                      00100200420"
${UE_CAPA_MIMO_UL_2_LAYERS_VR}    SEPARATOR=
...                      "018000000109000400C0410000800000027FE9FF80801C04000000F000000000000020300004000000000400403A
...                       000002004008"

${cell_noise_level}                             -710
${sinr_target}                                  -210

#vbo#obsolete#### Counters to check in case of VRAN (check via constraint csv file not available with VRAN topology at the moment)
#vbo#obsolete## M55302C05031: Successful PUSCH transmissions by any transmission with CP-OFDM and 64QAM MCS table
#vbo#obsolete#&{dict_M55302C05031}       counter=M55302C05031       obj=NRCELL    objId=1       min=24300        max=29700
#vbo#obsolete## M55302C03031: Unsuccessful PUSCH transmissions by last HARQ reTx with CP-OFDM and 64QAM MCS table
#vbo#obsolete#&{dict_M55302C03031}       counter=M55302C03031       obj=NRCELL    objId=1       min=0            max=5
#vbo#obsolete## M55303C01031: PUSCH transmissions in Rank2 with CP-OFDM and 64QAM MCS table
#vbo#obsolete#&{dict_M55303C01031}       counter=M55303C01031       obj=NRCELL    objId=1       min=24300        max=29700
#vbo#obsolete## M55303C01031: Initial and retransmission volume on PUSCH with CP-OFDM and 64QAM MCS table
#vbo#obsolete#&{dict_M55304C04031}       counter=M55304C04031       obj=NRCELL    objId=1       min=466200000    max=541000000
#vbo#obsolete## M55314C05006 :  Total number of uplink data volume sent over F1-U at gNB-DU for QoS Group 6
#vbo#obsolete#&{dict_M55314C05006}       counter=M55314C05006       obj=NRDU      objId=1                  min=1780000      max=1980000
#vbo#obsolete#
#vbo#obsolete#
#vbo#obsolete#@{dict_countersToCheck}
#vbo#obsolete#...              ${dict_M55314C05006}
#vbo#obsolete#...              ${dict_M55302C05031}
#vbo#obsolete#...              ${dict_M55302C03031}
#vbo#obsolete#...              ${dict_M55303C01031}
#vbo#obsolete#...              ${dict_M55304C04031}

*** Keywords ***

CB008662_CellSetup
    [Documentation]               Dedicated KW to add adaptive retransmission configuration
    ...                           by using a delta JSON file.
    ...                           !!! Dist names are hardcoded inside JSON file. To be improved ???

    # Open connection towards cOAM
    sbts_coam.connect_to          name=${gnb_alias}

    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${ps_bwp_delta_file}
    ...                           connection=${gnb_alias}
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    sbts_coam.teardown            connection=${gnb_alias}

    # Set MIMO layers inside UE capabilities
    Modify Field in WtsEmu Cfg File     field=ue_nr_capabilities    value=${UE_CAPA_MIMO_UL_2_LAYERS}

    Dated Log new line            ${trcColor}--- Restart TL ${defColor}
    Restart TL
    Dated Log new line            ${trcColor}--- WTS setup SA ${defColor}
    Setup Wtsemu SA               nbUe=1       nbSaUe=1     shouldUseLua=${True}


CB008662_CellSetup_for_AiC
    [Arguments]    ${target_cell}

    Dated Log New Line              ${trcColor}---> Start cell setup for AiC ${defColor}
    # Set MIMO layers inside UE capabilities
    Modify Field in WtsEmu Cfg File     field=ue_nr_capabilities    value=${UE_CAPA_MIMO_UL_2_LAYERS_VR}

    ${SCF_PATH_DU_8662}             OAM Get SCF File                oam=${GNB_DU.oam}        file=SCF_DU_8662_VR.xml
    SCF StartSession                scf_file=${SCF_PATH_DU_8662}

    # Set parameters for TC
    ${current_id}     Evaluate    ${target_cell} - 1
    ${NRCELLitem}     Run Keyword If    not ${isAic}    set variable    @{NRCELL_DN_LIST}[0]
    ...                           ELSE                  Set Variable    ${NRCELL_DN_LIST[${current_id}]}
    SCF Set element                 dist_name=${NRCELLitem}
    ...                             element_name=actDl256Qam
    ...                             element_value=false
    ...                             aicListEntity=vdu    scope=both

    SCF Set element                 dist_name=${NRCELLitem}
    ...                             element_name=actUl256Qam
    ...                             element_value=false
    ...                             aicListEntity=vdu    scope=both

    SCF Set element                 dist_name=${NRCELLitem}
    ...                             element_name=actAdaptiveReTxResMcs
    ...                             element_value=true
    ...                             aicListEntity=vdu    scope=both

    SCF Set element                 dist_name=${NRCELLitem}
    ...                             element_name=ullaBlerTarget
    ...                             element_value=30
    ...                             aicListEntity=vdu    scope=both

    SCF Add element                 dist_name=${NRCELLitem}
    ...                             element_name=minPctResourceReservedMcsDl
    ...                             element_value=50
    ...                             aicListEntity=vdu    scope=both

    SCF Add element                 dist_name=${NRCELLitem}
    ...                             element_name=minPctResourceReservedMcsUl
    ...                             element_value=50
    ...                             aicListEntity=vdu    scope=both

    SCF Add element                 dist_name=${NRCELLitem}
    ...                             element_name=targetPctResourceReservedMcsDl
    ...                             element_value=100
    ...                             aicListEntity=vdu    scope=both

    SCF Add element                 dist_name=${NRCELLitem}
    ...                             element_name=targetPctResourceReservedMcsUl
    ...                             element_value=95
    ...                             aicListEntity=vdu    scope=both

    SCF StopSession                 scf_file=${SCF_PATH_DU_8662}
    OAM Perform Full Commissioning  scf_file=${SCF_PATH_DU_8662}

    Wait Vcu And Vdu Available

    Clean PM on Aic TL

    Dated Log new line            ${trcColor}--- WTS setup SA ${defColor}
    Setup Wtsemu SA               nbUe=1    nbSaUe=1


CB008662_TC_AC_06_UL_HARQ_Retrans_When_above target_Min_50_Target_90
    [Documentation]                 This test aims at checking retransmission configuration when number of
    ...                             requested REs is below the ones needed for initial transmission,
    ...                             but they are not available.
    ...                             targetPctResourceReservedMcsUls set to 95 % to exceed number of PRB available
    ...                             inside PRACH slots.
    ...                             This test case also cover UL counters check ([1]CB008662_AB_06_Check_UL_64QAM_Counters_MCS_31)

    ${current_ue_setting}           Copy Dictionary      ${BASIC_UE_SA}
    Run keyword if    ${isAic}      Set To Dictionary    ${current_ue_setting}    ue              51    #SA FDD id corresponding to target cell#
    Set To Dictionary                                    ${current_ue_setting}    target_gnb      2
    Set To Dictionary                                    ${current_ue_setting}    target_cells    ${FDD_Cell_list[0].nrCellId}
    Set To Dictionary                                    ${current_ue_setting}    pdu             1
    Dated Log New Line              ===> current_ue_setting is ${current_ue_setting}

    # Customise SCF, restart TL and perform cell setup
    Run keyword if                  not ${isAic}
    ...                             CB008662_AC_keywords.CB008662_CellSetup
    ...       ELSE                  CB008662_AC_keywords.CB008662_CellSetup_for_AiC    target_cell=${current_ue_setting.target_cells}

    # Check gNB Modem Board Type (ABIL or ABIP)
    ${gNBmodemtype}       Set Variable If    not ${isAic}    ${TGNB_DU[0].bb[0].M.boardType}    ${None}
    Set Suite Variable    ${gNBmodemtype}
    ${console_msg}        Evaluate     "The Board Type used on gNB is ${gNBmodemtype}"
    Dated Log             ${console_msg}

    # Add background cell noise:
    wtsemu.ul_cell_noise_testmode_nr      profile_id=1
    ...                                   noise_pusch=${cell_noise_level}

    wtsemu.cell_testmode_set_nr           cell_id=${current_ue_setting.target_cells}
    ...                                   gnb=${current_ue_setting.target_gnb}
    ...                                   testmode=ul_cell_noise
    ...                                   profile_id=1
    ...                                   action=activate

    # Define UL SINR profile
    wtsemu.ul_sinr_testmode_nr            profile_id=1
    ...                                   sinr_target_pusch=${sinr_target}

    UE Register                     ue=${current_ue_setting.ue}
    Launch PDU Session              ue=${current_ue_setting.ue}    pdu=${current_ue_setting.pdu}    gw=1

    # TTI capture configuration
    ${TTIdir}                       Get TTI Trace Path                 dir_suffix=AC_06

    ${timeStartTraffic}             Get Current Date
    Dated Log New Line              ${trcColor}=== Start packets sending at ${timeStartTraffic} ${defColor}
    Traffic UE UL                   ueSetting=${current_ue_setting}
    ...                             throughput=${UL_troughput}
    ...                             shouldBeStop=False
    ...                             shouldBeCheck=False
    ...                             duration=20s
    ...                             deviation=5

    # Enable UL SINR test mode
    Dated Log                       ${trcColor}=== Decreasing SINR to add UL BLER ${defColor}
    wtsemu.ue_testmode_set_nr             id=${current_ue_setting.ue}
    ...                                   testmode=ul_sinr
    ...                                   profile_id=1
    ...                                   action=activate

    Traced Sleep                    5 seconds

    # Increase additional delay to ensure PM files are properly generated in VRAN
    ${zoi}                          ZOI Start    pmAvailDelay=80

    # start TTI capture
    Dated Log New Line              ${trcColor}=== Start TTI traces capture ${defColor}
    ${cell_id_for_streaming}           Create List    ${current_ue_setting.target_cells}    #vbo#WA for streaming target_cells using defaut SWENG#
    Run Keyword If    not ${isAic}     Start TTI Traces in Streaming mode    src_ip=10.0.1.2
    ...          ELSE                  Start TTI Traces in Streaming mode    src_ip=10.0.1.2    nrcell_id_list_aic=${cell_id_for_streaming}

    Traced Sleep                    ${UL_trace_duration}               msg=UL traffic capture

    # stop TTI capture
    ${TTIpcap}                      Stop TTI Traces in Streaming mode       tti_trace_path=${TTIdir}
    ...                                                                     tti_trace_filename=TTITrace_AC_06

    Dated Log New Line              ${trcColor}=== Convert TTItrace to json and csv ${defColor}
    ${TTIjson}                      Convert TTItrace from pcap to others        input_file_path=${TTIpcap}

    Dated Log New Line              ${trcColor}=== Check retransmission PRB and adaptive MCS in TTI trace ${defColor}
    ${checksResults}                checkAdaptiveFDDUL     jsonPathName=${TTIjson}     gNBmodemtype=${gNBmodemtype}

    Dated log New Line              ${trcColor}=== Starting collecting PM ${defColor}
    ZOI Wait End                    zoi=${zoi}

    # get counter files
    ${pm_dir}                       Set Variable    ${LOG_PATH}/pm_files
    ${pm_path}    Run Keyword if    not ${isAic}    Collect PM files from BTS    ${pm_dir}
    ...                       ELSE    Collect PM files from BTS    ${pm_dir}    optional_files=${True}    posProcess=${True}    node='vdu'

#vbo#obsolete#    ${cntVranStatus}    Run Keyword if       ${isAic}
#vbo#obsolete#    ...                 CB008662_AC_keywords.CB008662_checkCounters_for_AiC    target_cell=${current_ue_setting.target_cells}
#vbo#obsolete#    ...       ELSE      set variable         ${False}

    # BLER profile deactivation
    wtsemu.ue_testmode_set_nr       id=${current_ue_setting.ue}
    ...                             testmode=bler
    ...                             profile_id=1
    ...                             action=deactivate

    ${timeStopTraffic}              Get Current Date
    Dated Log New Line              ${trcColor}=== Stop packets sending and detach UE at ${timeStopTraffic} ${defColor}
    Traffic Stop                    ueSetting=${current_ue_setting}    dir=ul    #vbo#ueSetting=${UE_SIMPLE} is inappropriated in case SA#

    UE Deregister                   id=${current_ue_setting.ue}

    # Max 3 % error
    Dated Log New Line              Error percentage is ${checksResults}[ErrorRatio] % < ${MaxAdaptiveReTxErrorRatio}

    Dated log                       Reserved MCS detected: ${checksResults}[reservedMcsDetected]
    Dated Log                       Unexpected MCS detected: ${checksResults}[unexpectedMcsDetected]
    Dated Log                       Unexpected PRB detected: ${checksResults}[unexpectedPRBDetected]

    Should Be True                  ${checksResults}[ErrorRatio] < ${MaxAdaptiveReTxErrorRatio}

    ${currentConstraintsFile}    Run Keyword If    not ${isAic}    Set Variable    ${CONSTRAINTS_FILE}
    ...                                       ELSE                 Set Variable    ${CONSTRAINTS_FILE_VDU}
    KPI Evaluate    pmFile=${pm_path}    constraintsFile=${currentConstraintsFile}    failOnError=${True}
#vbo#obsolete#
#vbo#obsolete#
#vbo#obsolete#CB008662_checkCounters_for_AiC
#vbo#obsolete#    [Arguments]    ${target_cell}
#vbo#obsolete#
#vbo#obsolete#    Dated Log New Line              ${trcColor}---> Check counters for AiC ${defColor}
#vbo#obsolete#    ${Status}                       set variable         ${True}
#vbo#obsolete#    FOR    ${counter_dict}    IN    @{dict_countersToCheck}
#vbo#obsolete#         Dated Log new line         ${trcColor}=== check ${counter_dict.counter} ${defColor}
#vbo#obsolete#         ${counter_dict.objId}      Run Keyword If    ${isAic} and '${counter_dict.obj}' == 'NRCELL'    Set Variable    ${target_cell}
#vbo#obsolete#         ...    ELSE                                                    Set Variable    ${counter_dict.objId}
#vbo#obsolete#         ${cntValue}                Retrieve Latest Single Counter Value From Pm Files For Object and Id on vDU
#vbo#obsolete#         ...                        &{counter_dict}
#vbo#obsolete#
#vbo#obsolete#         ${cntStatus}  ${Status}    Run Keyword if       ${cntValue} >= ${counter_dict}[min] and ${cntValue} <= ${counter_dict}[max]
#vbo#obsolete#         ...                        set variable         PASSED    ${Status}
#vbo#obsolete#         ...     ELSE               set variable         FAILED    ${False}
#vbo#obsolete#
#vbo#obsolete#    Dated Log New Line    ${trcColor}- Value: ${cntValue} min: ${counter_dict.min} max: ${counter_dict.max} - ${cntStatus} ${defColor}
#vbo#obsolete#    END
#vbo#obsolete#    [Return]                        ${Status}
#vbo#obsolete#