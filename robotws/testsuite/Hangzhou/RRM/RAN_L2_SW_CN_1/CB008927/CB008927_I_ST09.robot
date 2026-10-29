*** Settings ***
Suite Teardown    Common Suite Teardown 2
Test Teardown     Common Test Teardown 2
Force Tags        CLOUD_5G_I_LO_AP_LO
...               SBTS00    SBTS24R3    Pz4_12    CB008927   RAN_5G    RAN_5G_TDD    #CRT
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./Resources/CB008927_resource.robot


*** Variables ***
${SCF_PATH}                       ${CURDIR}/Config
${FULL_SCF_ST09}                  scfc_CB008927_ST_09.xml
${WTS_LOCAL}                      ${CURDIR}/Config
${IPHY_FILE_ST09}                 ${WTS_LOCAL}/iphy_CB008927_ST_09.xml
${WTS_CFG_ST09}                   basic_setup_8927_I_ST09.cfg
${RD}                             0x4B000F=1;0x580839=1;0x580345=1;0x58090b=1;0x580954=1;0x58066a=0
${ttiPath1}                       ttitrace1
${ttiPath2}                       ttitrace2
${ttitraceFilter}                 generate_ttitrace_profile_CB008927.txt
${bip_csv}                        bip_gnb.csv


&{VENDOR_PARAMS_DICT}           maxNumLayerPrbL1Sp=450    maxNumStreamPrbL1Sp=450    maxNumWbStreamPrbL1Sp=225
${list_name}                    bbL1SpPrbInitCapacity
${ref_value1}                    ABIO48DLNR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
&{vendor_change_dict1}           params_dict=&{VENDOR_PARAMS_DICT}    list_name=${list_name}    ref_value=${ref_value1}
@{vendor_change_list}            ${vendor_change_dict1}
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}


*** Test Cases ***
CB008927_09_TDD_pscell_change_to_TDD_enable_to_disable_PRB_Pooling
    [Documentation]
    ...    Precondition:
    ...      CB008927 is enabled: NRBTS/NRCELL.actRat1Alloc = true
    ...      NRBTS/actFdmScheduling = true, NRBTS/NRCELL/actFdmSchedulingInitialBWP = true, actNonVoNRGBRService = true
    ...      actBeamforming = true, ueConnectionEstablishmentMode = dedicated, actAdaptiveReTxResMcs = true,
    ...      source cell dlDMRSAdditionalPosition = 1, target cell dlDMRSAdditionalPosition = 0
    ...    Test Steps:
    ...      Step1: Attach UE102 on TDD cell 1 with RAT1, staring full DL/UL traffic
    ...      Step2: Attach UE103 on TDD cell 3 with RAT0, staring full DL/UL traffic
    ...      Step3: UE102 HO from cell 1 to cell 3
    ...    Check point:
    ...      1. 
    ...      2. 
    ...      3. Check counters.

    [Tags]    case_I_ST09    Manual_coliu    TA_lilidong
    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_ST09}
    ...        AND    Suite Setup Update GNB    scf_file=${FULL_SCF_ST09}    iphy_file=${IPHY_FILE_ST09}    swconfig_param=${RD}
    ...               vendor_change_list=${vendor_change_list}
    ...        AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
    ...        AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
    ...        AND    Common Test Setup 2

    ###Set egate rrc log 'off'
    ${bip}    Capture BIP for'1s' to logDir'BIP_GNB'and convert to csv'${bip_csv}' with filter'${filter}' and'${column_name}'
    NSA UE Attach And DLUL Traffic    ue_id=102    gnb_id=2    cell_id=1    bearer_id=2    dl_mbps=500    ul_mbps=100
    Sleep    5s
    Get Egate log and check 'RESOURCEALLOCATIONTYPE1'
    NSA Check Average Traffic Bigger Than Target    ue_id=102    bearer_id=2    dir=dl    tp_rate=300
    NSA UE Attach And DLUL Traffic    ue_id=103    gnb_id=2    cell_id=3    bearer_id=2    dl_mbps=500    ul_mbps=100
    Sleep    5s
    Get Egate log and check 'RESOURCEALLOCATIONTYPE0'
    NSA Check Average Traffic Bigger Than Target    ue_id=103    bearer_id=2    dir=dl    tp_rate=280
    ${tti1}    Capture Ttitrace for duration '1s' to log dir '${ttiPath1}'
    Run Keyword And Continue On Failure    Verify ttitrace bler should not high than '0.01' in path '${ttiPath1}'
    Verify PRB schedule as expected in log bip '${bip}' and ttitrace '${tti1}' before HO

    Trigger A2 Event on UE '102' srsrp_nr '11' srsrq_nr '11' of meas_id '2'
    Trigger A3 Event on UE '102' For interFreqHO on meas_id '4' to physcellID '62'
    ${tti2}    Capture Ttitrace for duration '1s' to log dir '${ttiPath2}'
    Run Keyword And Continue On Failure    Verify ttitrace bler should not high than '0.01' in path '${ttiPath2}'
    Verify PRB schedule as expected in log bip '${bip}' and ttitrace '${tti2}' after HO

    NSA UE '102'-'103' Detach


*** Keywords ***
NSA UE Attach And DLUL Traffic
    [Arguments]    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}    ${dl_mbps}    ${ul_mbps}
    NSA LTE Attach    ${ue_id}
    NSA 5G Attach    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}
    NSA Start DL Big Traffic Internal    ${ue_id}    ${bearer_id}    ${dl_mbps}
    NSA Start UL Traffic    ${ue_id}    ${bearer_id}    ${ul_mbps}

Verify PRB schedule as expected in log bip '${bip}' and ttitrace '${tti}' before HO
    ${Data}    Generate Data From Bip'${bip}' TTitrace'${tti}' FrameType'1116_0ms' physCellId'60' when ignoreNotFullBufferSlot'Y'
    Check PrbNum'>=50' Should not Lower Percentage'0.9' on SlotType'D' in Data'${Data}'
    Check PrbNum'>=50' Should not Lower Percentage'0.9' on SlotType'SIB/OSI' in Data'${Data}'
    Check PrbNum'>=50' Should not Lower Percentage'0.9' on SlotType'SSB' in Data'${Data}'
    Check PrbNum'>=50' Should not Lower Percentage'0.9' on SlotType'TRS' in Data'${Data}'

Verify PRB schedule as expected in log bip '${bip}' and ttitrace '${tti}' after HO
    ${Data}    Generate Data From Bip'${bip}' TTitrace'${tti}' FrameType'1116_0ms' physCellId'62' when ignoreNotFullBufferSlot'Y'
    Check PrbNum'>=50' Should not Lower Percentage'0.9' on SlotType'D' in Data'${Data}'
    Check PrbNum'>=50' Should not Lower Percentage'0.9' on SlotType'SIB/OSI' in Data'${Data}'
    Check PrbNum'>=50' Should not Lower Percentage'0.9' on SlotType'SSB' in Data'${Data}'
    Check PrbNum'>=50' Should not Lower Percentage'0.5' on SlotType'TRS' in Data'${Data}'
