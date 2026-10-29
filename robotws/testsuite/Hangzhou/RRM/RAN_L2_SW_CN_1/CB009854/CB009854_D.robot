*** Settings ***
Resource    ./../CUDU_L2/common_setup_teardown.robot
Resource           ./CB009854_resource.robot
Suite Setup        Common Suite Setup 2
Test Teardown      Common Test Teardown 2
Suite Teardown     Common Suite Teardown 2
Force Tags         CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1
...                RAN_5G    RAN_5G_TDD
*** Variables ***
${SCF_PATH}                    ${CURDIR}/config/SCF
${LOG_PATH}                    ${OUTPUT DIR}
${LOCAL_WTS_DIR}               ${CURDIR}/config/WTS
${WTS_DIR}                     /opt/iphy/latest
${scf_ca_fdd_tdd}              ${SCF_PATH}/scf_CB009854_3F3T.xml
${iphy_CB009854_3F4T}          ${CURDIR}/config/IPHY/iphy_CB009854_3F4T.xml
${scf_D_014}                   ${SCF_PATH}/scf_CB009854_D014.xml
${WTS_CFG_CA}                  wts_CB009854.cfg
${SWCONFIG_D_005}              0x4B000F=1;0x3F007C=1024;0x58012d=4;
${UE3_ID}                      3
${5CC_3F2T_SCELL}             ('1', '51', '25'), ('2', '52', '66'), ('3', '54', '41'), ('4', '55', '41')
${5CC_2F3T_SCELL}             ('1', '51', '25'), ('2', '54', '41'), ('3', '55', '41'), ('4', '56', '77')
@{5CC_scell_index}            1    2    3    4
${egate_console_log}          /opt/wts/latest/egate_console.log
${Egatelog_path}              ${CURDIR}
${scf_ca_D010}                ${SCF_PATH}/SCF_9854_D10.xml 
${iphy_CB009854_D010}         ${CURDIR}/config/IPHY/iphy_CB009854_D10.xml
${WTS_CFG_CA_D010}            wts_CB009854_D10.cfg
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}


*** Test Cases ***
#CB009854D-ET-005_Layer_chang_and_beam_switch_2F3T_Loki_gnb_pcsi_bunding_per_CC_enable_on_FDD_pcell
#    [Documentation]
#    ...    Precondition:
#    ...      2FDD+3TDD
#    ...      Frame structure=1070
#    ...    Test Steps:
#    ...      Step1: UE3 attach to FDD cell as pcell
#    ...      Step2: start big data for TDD pcell
#    ...      Step3: UE send max UCI 34 bit include 19 bit UCI for CQI and 15 bit for beam report and 4 bit ACK and 1SR
#    ...      Step4: UE send RI=0 to change to 1 layer and beam switch from beam 0 to beam
#    ...      Step5: stop ul data transfer
#    ...      Step6: wating litter time,UE send RI=3 to change to 4 layer
#    ...      Step7: UE report A2 UL+DL scell release.
#    ...      Step8: Start UL data transfer 
#    ...      Step9: Release call.
#    ...    Check Points:
#    ...      1)After step1, Verify Scell addditon successfully.
#    ...      2)After step2,  Scell addition successfully. 
#    ...      3)After step3, Data transfer on pcell and scell correctly for each.Verfiy 34bit on Pcell pusch successfully,not DTX and RACK
#    ...      4)After step4,check the layer from 2 to 1 ,beam switch from 0 to 1
#    ...      5)After step6, check the 34 bit on Pcell pucch,layer from 1 to 4
#    ...      6)After step7, check the 34 bit on Pcell pusch
#    ...      7)After step8, UE releases
#    [Tags]     case_D005    Manual_suqian    TA_suqian   CRT    AP_REG
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CA}
#    ...        AND    Suite Setup Update GNB    scf_file=${scf_ca_fdd_tdd}    swconfig_param=${SWCONFIG_D_005}    iphy_file=${iphy_CB009854_3F4T}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2

#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_D005.xml
#    Delta Commission With SCF File    ${json_file}
#    CB009854_resource.Start WTS And Check OnAir
#    #step1
#    UE Beamforming Profile For 6 Beams
#    SA Single UE Attach    ${UE3_ID}
#    Get And Check Scell Infos    ${5CC_2F3T_SCELL}
#    #step2
#    Start SA UE Big DL Traffic Internal    ${UE3_ID}    1000
#    Start SA UE Big UL Traffic Internal    ${UE3_ID}    100
#    Sleep    5s    reason=Wait for traffic stable
#    #step3
#    Check UL And DL DTX From Ttitrace    log_id=1    duration=2
#    #step4
#    Send Ri0 And Beam switch Then Check Bip    1
#    #step5
#    SA Stop Data Traffic Internal    ue_id=${UE3_ID}    pdu_id=1    dir=ul 
#    #step6
#    Send Ri3 And Check Csi On Pucch    2
#    Check UL And DL DTX From Ttitrace    log_id=2    duration=2
#    #step7
#    Start SA UE Big UL Traffic Internal    ${UE3_ID}    100
#    Sleep    5s    reason=Wait for traffic stable
#    Check Bip For Csi Multiplexing On Pusch    3
#    #step8
#    SA 5G Detach    ${UE3_ID}   

#CB009854D-ET-003_3F2T_Loki_gnb_pcsi_bunding_per_CC_enable_on_FDD_pcell
#    [Documentation]
#    ...    Precondition:
#    ...      3FDD+2TDD
#    ...      Frame structure=1116 3ms 8beam
#    ...    Test Steps:
#    ...      Step1: UE attach to FDD cell as pcell
#    ...      Step2: UEs report A1 to trigger TDD scell additon.
#    ...      Step3: Start UL and DL data transfer.
#    ...      Step4: UE report A2 to trigger one of FDD scell release
#    ...      Step5: UE report A2 to trigger another of FDD scell release
#    ...      Step6: UE report A2 to trigger  one of TDD scell release
#    ...      Step7: UE report A2 to trigger another  of TDD scell release
#    ...      Step8: UE report A1 to trigger TDD scell additon
#    ...      Step9:UE release
#    ...    Check Points:
#    ...      1)UE register successfully
#    ...      2)Verify Scell addditon successfully
#    ...      3)data transfer on pcell and scells DL and UL correctly
#    ...      4)Verfiy 39 bit Pcsi and HARQ on Pcell pusch successfully,no DTX and NACK found.
#    ...      5)After step4,one of FDD scell release.check Pcsi and HARQ on Pcell pusch successfully,no DTX and NACK found.
#    ...      6)After step5,another of FDD scell release.check Pcsi and HARQ on Pcell pusch successfully,no DTX and NACK found.
#    ...      7)After step6,one of TTD scell release,check Pcsi and HARQ on Pcell pusch successfully,no DTX and RACK found.
#    ...      8)After step7,all the TDD scell release.
#    ...      9)After step8,scell aad again,check bunding Pcsi and HARQ on Pcell pusch successfully,no DTX and NACK found
#    ...      10)Call release successfully.
#    [Tags]     case_AB01    Manual_dguan    TA_dguan   CRT    AP_REG
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CA}
#    ...        AND    Suite Setup Update GNB    scf_file=${scf_ca_fdd_tdd}    swconfig_param=${SWCONFIG_D_005}    iphy_file=${iphy_CB009854_3F4T}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2

#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_D03.xml
#    Delta Commission With SCF File    ${json_file}
#    CB009854_resource.Start WTS And Check OnAir
#    #step1
#    SA Single UE Attach    ${UE3_ID}
#    #step2
#    Trigger A1 Scell Addition    ${UE3_ID}    85    53
#    Get And Check Scell Infos    ${5CC_3F2T_SCELL}
#    #step3
#    Start SA UE Big DL Traffic Internal    ${UE3_ID}    1000
#    Start SA UE Big UL Traffic Internal    ${UE3_ID}    200
#    Sleep    5s    reason=Wait for traffic stable
#    Check UL And DL DTX From Ttitrace    log_id=1    duration=2
#    CUDU_L2 Capture And Decode TTitrace    log_id=1    duration=2
#    Check NumOfUciCsiPart1Bits On Specific Scell    1    54    39
#    Check NumOfUciCsiPart1Bits On Specific Scell    1    55    39
#    Check ULchannel On Specific Scell    1    54    PUSCH
#    Check ULchannel On Specific Scell    1    55    PUSCH
#    #step4
#    Trigger A2 Scell Release    ${UE3_ID}    1    20    51    2
#    #step5
#    Trigger A2 Scell Release    ${UE3_ID}    2    20    52    3
#    #step6
#    Trigger A2 Scell Release    ${UE3_ID}    3    20    54    4
#    #step7
#    Trigger A2 Scell Release    ${UE3_ID}    4    20    55    5
#    #Check UL And DL DTX From Ttitrace    log_id=5    duration=2
#    #step8
#    Trigger A1 Scell Addition    ${UE3_ID}    75    53
#    #Check UL And DL DTX From Ttitrace    log_id=6    duration=2
#    CUDU_L2 Capture And Decode TTitrace    log_id=6    duration=2
#    Check NumOfUciCsiPart1Bits On Specific Scell    6    54    39
#    Check NumOfUciCsiPart1Bits On Specific Scell    6    55    39
#    Check ULchannel On Specific Scell    6    54    PUSCH
#    Check ULchannel On Specific Scell    6    55    PUSCH

#CB009854D-ET-006_DRX_enable_on_gnb_pcsi_bunding_per_CC_enable_on_FDD_pcell
#    [Documentation]
#    ...    Precondition:
#    ...      2FDD+3TDD
#    ...      Frame structure=1208
#    ...    Test Steps:
#    ...      Step1: UE3 attach to FDD cell as pcell
#    ...      Step2: start big data for TDD pcell
#    ...      Step3: UE send correct UCI bit for CQI and for beam report for cells
#    ...      Step4: Stop DL and UL data to trigger UE enter to DRX sleep status
#    ...      Step5: Start UL data transfer 
#    ...      Step6: Start DL data transfer 
#    ...      Step7: Release call.
#    ...    Check Points:
#    ...      1)After step1, Verify Scell addditon successfully.
#    ...      2)After step2,  Scell addition successfully. 
#    ...      3)After step3, Data transfer on pcell and scell correctly for each.Verfiy bit size on Pcell pusch successfully,not DTX and RACK
#    ...      4)After step4, UE enter to DRX sleep status. pcsi on DRX onduration
#    ...      5)After step5, ,check UL data schedule successfully. Pcsi and HARQ on Pcell pusch successfully, not DTX and RACK found.
#    ...      7)After step7, UE release
#    [Tags]     case_D006    Manual_qianwu    TA_qianwu   CRT    AP_REG
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CA}
#    ...        AND    Suite Setup Update GNB    scf_file=${scf_ca_fdd_tdd}    swconfig_param=${SWCONFIG_D_005}    iphy_file=${iphy_CB009854_3F4T}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2

#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_D006.xml
#    Delta Commission With SCF File    ${json_file}
#    Verify Coam Site Is Ready
#    CB009854_resource.Start WTS And Check OnAir
#    #step1
#    SA Single UE Attach    ${UE3_ID}
#    Sleep    3s    reason=Wait for egate log
#    Get And Check Scell Infos    ${5CC_2F3T_SCELL}
#    #step2
#    Start SA UE Big DL Traffic Internal    ${UE3_ID}    1000
#    Start SA UE Big UL Traffic Internal    ${UE3_ID}    100
#    Sleep    5s    reason=Wait for traffic stable
#    #step3
#    #Check D006 Ucibits For Pusch    log_id=1
#    Check UL And DL DTX From Ttitrace    log_id=1    duration=2
#    Check NumOfUciCsiPart1Bits For D006    log_id=1
#    #step4
#    SA Stop Data Traffic Internal    ue_id=${UE3_ID}    pdu_id=1    dir=bi
#    Check EXITDRX In TTitrace    log_id=2
#    #step5
#    Start SA UE Big UL Traffic Internal    ${UE3_ID}    100
#    Sleep    5s    reason=Wait for traffic stable
#    Check UL And DL DTX From Ttitrace    log_id=3    duration=2
#    Check NumOfUciCsiPart1Bits For D006    log_id=3
#    #step6	
#    Start SA UE Big DL Traffic Internal    ${UE3_ID}    1000
#    #step7
#    SA 5G Detach    ${UE3_ID}   

#CB009854D-ET-009_3T2F_pcsi_bunding_and_scell_release
#    [Documentation]
#    ...    Precondition:
#    ...      2FDD+3TDD
#    ...      Frame structure=1116_3ms
#    ...    Test Steps:
#    ...      Step1: UE3 attach to FDD cell as pcell.
#    ...      Step2: UE send A1 measurement report and start big data.
#    ...      Step3: UE send max UCI 32 bits for TDD Scell1.
#    ...             UE send max UCI 32 bits for TDD Scell2.
#    ...             UE send max UCI 36 bits for TDD Scell3.
#    ...      Step4-Step7: UE report A2 to release TDD Scell1/Scell2/Scell3.
#    ...      Step8: UE report A1 to add TDD Scell1/Scell2/Scell3.
#    ...      Step9: Stop UL data transfer.
#    ...      Step10: Release call.
#    ...    Check Points:
#    ...      1)After step2, check Scells added and activated successfully.
#    ...      2)After step3, check data scheduled correctly on Pcell and each Scell, no DTX and NACK.
#    ...      3)After step4-step7, check Scell1/Scell2/Scell3/Scell4 is released, no DTX and NACK.
#    ...      4)After step8, check all Scells are added and activated, no DTX and NACK.
#    ...      5)After step9, after UL data stopped,no DTX and NACK.
#    ...      6)After step10, UE is deregistered successfully.

#    [Tags]     case_D009    Manual_lading    TA_lading   CRT
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CA}
#    ...        AND    Suite Setup Update GNB    scf_file=${scf_ca_fdd_tdd}    swconfig_param=${SWCONFIG_D_005}    iphy_file=${iphy_CB009854_3F4T}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2

#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_D009.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    CB009854_resource.Start WTS And Check OnAir
#    #step1
#    SA Single UE Attach    ${UE3_ID}
#    #step2
#    Trigger A1 Scell Addition    ${UE3_ID}    85    53
#    Get And Check Scell Infos    ${5CC_2F3T_SCELL}
#    #step3
#    Start SA UE Big DL Traffic Internal    ${UE3_ID}    1000
#    Start SA UE Big UL Traffic Internal    ${UE3_ID}    175
#    Sleep    5s    reason=Wait for traffic stable
#    Check UL And DL DTX From Ttitrace    log_id=1    duration=2
#    Check NumOfUciCsiPart1Bits On Specific Scell    1    54    32
#    Check NumOfUciCsiPart1Bits On Specific Scell    1    55    32
#    Check NumOfUciCsiPart1Bits On Specific Scell    1    56    36
#    Check ULchannel On Specific Scell    1    54    PUSCH
#    Check ULchannel On Specific Scell    1    55    PUSCH
#    Check ULchannel On Specific Scell    1    56    PUSCH
#    #step4
#    Trigger A2 Scell Release    ${UE3_ID}    1    50    51    2
#    Check UL And DL DTX From Ttitrace    log_id=2    duration=2
#    #step5
#    Trigger A2 Scell Release    ${UE3_ID}    2    50    54    3
#    Check UL And DL DTX From Ttitrace    log_id=3    duration=2
#    #step6
#    Trigger A2 Scell Release    ${UE3_ID}    3    50    55    4
#    Check UL And DL DTX From Ttitrace    log_id=4    duration=2
#    #step7
#    Trigger A2 Scell Release    ${UE3_ID}    4    50    56    5
#    Check UL And DL DTX From Ttitrace    log_id=5    duration=2
#    #step8
#    Trigger A1 Scell Addition    ${UE3_ID}    80    53    8
#    Check UL And DL DTX From Ttitrace    log_id=6    duration=2
#    Check NumOfUciCsiPart1Bits On Specific Scell    1    54    32
#    Check NumOfUciCsiPart1Bits On Specific Scell    1    55    32
#    Check NumOfUciCsiPart1Bits On Specific Scell    1    56    36
#    Check ULchannel On Specific Scell    1    54    PUSCH
#    Check ULchannel On Specific Scell    1    55    PUSCH
#    Check ULchannel On Specific Scell    1    56    PUSCH
#    #step9
#    SA Stop Data Traffic Internal    ${UE3_ID}    1    ul
#    Check UL And DL DTX From Ttitrace    log_id=7    duration=2
#    #step10
#    SA 5G Detach    ${UE3_ID}

CB009854D-ET-014_Gnb_pcsi_bunding_and_acsi_enable
    [Documentation]
    ...    Precondition:
    ...      2FDD+3TDD
    ...      Frame structure=1208，1070，1116-0ms
    ...    Test Steps:
    ...      Step1: UE attach to FDD cell as pcell
    ...      Step2: TDD scell1&2&3 and FDD scell add to active set.Start UL and DL data transfer.
    ...      Step3: UE send acsi for FDD pcell and pcsi for each TDD scell.
    ...      Step4: stop data,ue enter to DRX sleep.
    ...      Step5: Start UL &DL data transfer 
    ...      Step6: Release call.

    ...    Check Points:
    ...      1)After step1, Verify Scell addditon successfully.
    ...      2)After step2, Data transfer on pcell and scell correctly for each. 
    ...      3)After step3, Verfiy pcsi bunding and UCI bit
    ...      4)After step4, UE enter to DRX sleep status
    ...      5)After step5, Verfiy pcsi bunding and UCI bit
    ...      6)After step6, UE release
    [Tags]     case_D014    Manual_yaling    TA_qianwu   CRT
    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CA}
    ...        AND    Suite Setup Update GNB    scf_file=${scf_D_014}    swconfig_param=${SWCONFIG_D_005}    iphy_file=${iphy_CB009854_3F4T}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    CB009854_resource.Start WTS And Check OnAir
    #step1
    SA Single UE Attach    ${UE3_ID}
    Get And Check Scell Infos    ${5CC_2F3T_SCELL}
    #step2
    Start SA UE Big DL Traffic Internal    ${UE3_ID}    550
    Start SA UE Big UL Traffic Internal    ${UE3_ID}    100
    #step3
    Check UL And DL DTX From Ttitrace    log_id=1    duration=2
    Check NumOfUciCsiPart1Bits On Specific Scell    1    54    24
    Check NumOfUciCsiPart1Bits On Specific Scell    1    55    34
    Check NumOfUciCsiPart1Bits On Specific Scell    1    56    20
    Check Throughput For CB009854
    #step4
    SA Stop Data Traffic Internal    ue_id=${UE3_ID}    pdu_id=1    dir=bi
    Check EXITDRX In TTitrace    log_id=2
    #step5
    Start SA UE Big DL Traffic Internal    ${UE3_ID}    550
    Start SA UE Big UL Traffic Internal    ${UE3_ID}    100
    CUDU_L2 Capture And Decode TTitrace    3    2
    Check Throughput For CB009854
    #step6
    SA 5G Detach    ${UE3_ID}

#CB009854D-ET-010_Gnb_pcsi_bunding_and_scell_swape
#    [Documentation]
#    ...    Precondition:
#    ...      3FDD+2TDD
#    ...      Frame structure=1116_0ms and 1208
#    ...    Test Steps:
#    ...      Step1: UE3 attach to FDD cell as pcell
#    ...      Step2: start big data for TDD pcell
#    ...      Step3: UE send pcsi for each scell
#    ...      Step4: UE report A6 for TDD scell1 to trigger scell swap
#    ...      Step5: UE report A6 for TDD scell2 to trigger scell swap
#    ...      Step6: Release call
#    ...    Check Points:
#    ...      1)After step1, Verify Scell addditon successfully.
#    ...      2)After step2, TDD Scell1&2&3 and one FDD scell addition successfully. 
#    ...      3)After step3, Data transfer on pcell and scell correctly for each,Mux UCI 34 bit for TDD scell1, 30 bit for TDD scell2
#    ...      4)After step4, scell1 swap to TDD scell3 , 30 bit for TDD scell2  and 22 for tdd scell3bit for TDD scell4
#    ...      5)After step5, scell2 swap to TDD scell4 , 22 bit for TDD scell3  and 20 bit for tdd scell4
#    ...      6)After step6, UE releases
#    [Tags]     case_D010    Manual_suqian    TA_suqian   CRT
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CA_D010}
#    ...        AND    Suite Setup Update GNB    scf_file=${scf_ca_D010}    swconfig_param=${SWCONFIG_D_005}    iphy_file=${iphy_CB009854_D010}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    #step1
#    CB009854_resource.Start WTS And Check OnAir
#    SA Single UE Attach    ${UE3_ID}
#    Trigger A1 Scell Addition    ${UE3_ID}    85    53
#    Get And Check Scell Infos    ${5CC_3F2T_SCELL}
#    #step2
#    Start SA UE Big DL Traffic Internal    ${UE3_ID}    1000
#    Start SA UE Big UL Traffic Internal    ${UE3_ID}    100
#    Sleep    5s    reason=Wait for traffic stable
#    #step3
#    Check UL And DL DTX From Ttitrace    log_id=1    duration=2
#    Check NumOfUciCsiPart1Bits On Specific Scell    1    54    34
#    Check NumOfUciCsiPart1Bits On Specific Scell    1    55    30
#    Check ULchannel On Specific Scell    1    54    PUSCH
#    Check ULchannel On Specific Scell    1    55    PUSCH
#    #step4
#    Trigger A6 Scell Swape    3    2    3    56
#    Check UL And DL DTX From Ttitrace    log_id=2    duration=2
#    Check NumOfUciCsiPart1Bits On Specific Scell    2    56    22
#    Check NumOfUciCsiPart1Bits On Specific Scell    2    55    30
#    Check ULchannel On Specific Scell    2    56    PUSCH
#    Check ULchannel On Specific Scell    2    55    PUSCH	
#    #step5
#    Trigger A6 Scell Swape    3    3    4    57
#    Check UL And DL DTX From Ttitrace    log_id=3    duration=2
#    Check NumOfUciCsiPart1Bits On Specific Scell    3    56    22
#    Check NumOfUciCsiPart1Bits On Specific Scell    3    57    20
#    Check ULchannel On Specific Scell    3    56    PUSCH
#    Check ULchannel On Specific Scell    3    57    PUSCH	
#    #step6
#    SA 5G Detach    ${UE3_ID}
    
*** Keywords ***

	
