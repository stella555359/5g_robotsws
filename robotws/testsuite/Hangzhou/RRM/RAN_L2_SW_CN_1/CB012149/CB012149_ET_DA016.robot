*** Settings ***
Documentation    ...
#Resource           ./CB012149_resource.robot
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup        Common Suite Setup 2
##Test Teardown      Common Test Teardown 2
##Suite Teardown     Common Suite Teardown 2
#Force Tags         CLOUD_5G_I_BOO_AP_LOO    SBTS00
#...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
#
#*** Variables ***
#${SCF_PATH}                   ${CURDIR}/Config/SCF
#${WTS_DIR}                    /opt/iphy/latest
#${LOCAL_WTS_DIR}              ${CURDIR}/Config/WTS/
#${gnb_swconfig}               ${CURDIR}/Config/SCF/swconfig_gnb_asrs.txt
#${SWCONFIG_DA11}              0x4B000F=1;0x58012d=2;0x3F007C=1024
#${UE_ID}                      1
#${WTS_CFG_DA11}               wts_CB012149_DA016.cfg
#${SCF_DA11}                   ${SCF_PATH}/CB012149_DA016.xml
#${iphy_DA11}                  ${CURDIR}/Config/IPHY/iphy_DA016.xml
#${SLIVLIST_1}                 ["0", "","27.0","41.0","53.0","55.0","255.0"]
#${SLIVLIST_2}                 ["0", "","27.0","41.0","55.0","69.0","255.0"]
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB012149ET-DA016__Activate_adaptive_retransmission_for_1060_0_frame_structure
#    [Documentation]
#    ...    Precondition:
#    ...      2F+3T TDD with 1116 0ms frame structure.
#    ...      :with beam=4 and refine beam is enable
#    ...    Test Steps:
#    ...      Step1: UE1 and UE2  attach to FDD cell as pcell, UE3 without UL CA capability attach to FDD cell
#    ...      Step2: UE1 report A1 to trigger scells additon.
#    ...      Step3: Start big UL and DL data for UE2 and UE3.
#    ...      Step4: UE3 simulate bad SINR to trigger UL RANK from 2 to 1.
#    ...      Step5: UE1 start UL and DL data to trigger scell data transfer.
#    ...      Step6: UE1 simulate UL Retx
#    ...      Step7: UE3 simulate good SINR to trigger UE use UL 2 layer again.
#    ...    Check point:
#    ...      1. Afte step4 UE3 UL Layer from 2 to 1 and ASRS trigger.
#    ...      2. After step5, UE1 and UE2 TDD scell actived Verify UE1 FDD pcell PUSCH slot before or after TDD UL slot
#    ...      SLIV like this: slot5 ,9 :S=0, L=13 (SLIV 41),slot3 & slot8:S=2, L=12 (SLIV 53) and slot6 :S=0, L=11 (SLIV 69)
#    ...      3. After step6 ,Verify UL reTX successfully.
#    ...      4. After step7 ,UE3 schedule with FDD UL 2layer again , Verify UE1 FDD pcell PUSCH slot before or
#    ...      after TDD UL slot SLIV like this: slot5,9 :S=0, L=14 (SLIV 27),slot3 & slot8:S=2, L=12(SLIV 53) and slot6:S=0,L=11(SLIV 69)
#    ...      Verify UL reTX successfully
#    ...      other FDD UL schedule slot use normal 14 symbol like legacy.
#    ...      5. No DTX/CRC NOK
#    [Tags]    caseBC01    Manual_dguan   TA_dguan
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_DA11}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_DA11}    iphy_file=${iphy_DA11}    swconfig_param=${SWCONFIG_DA11}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    #Step1&2
#    SA Single UE Attach    1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=75 srsrq_nr=60 phycell_id=52
#    sleep    2s
#    SA Single UE Attach    2
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=2 meas_id=1 event=A1 srsrp_nr=75 srsrq_nr=60 phycell_id=52
#    sleep    2s
#    SA Single UE Attach    3
#    #Step3
#    Start SA UE Big UL Traffic Internal    3    100
#    Start SA UE Big DL Traffic Internal    2    400
#    Start SA UE Big UL Traffic Internal    2    100
#    sleep    5s
#    #Step4
#    Send Commond To Trigger UE2 Lower Sinr    ue_id=3
#    Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=135
#    sleep    5s
#    #Step5
#    Start SA UE Big DL Traffic Internal    1    400
#    Start SA UE Big UL Traffic Internal    1    100
#    sleep    5s
#    CUDU_L2 Capture And Decode TTitrace    3   1.5
#    Check SLIV Of UL In TTI    3    41.0
#    Check SLIV Of UL In TTI    3    53.0
#    Check SLIV Of UL In TTI    3    69.0
#    #Step6
#    Set Value For UL BLER testmode    1
#    sleep    5s
#    CUDU_L2 Capture And Decode TTitrace    4   1.5
#    CUDU_L2 Check Rate    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]    4    0.1
#    #Step7
#    Execute Egate Command    cmd=ue_testmode_set_nr id=3 testmode=ul_sinr action=deactivate profile_id=1
#    sleep    5s
#    CUDU_L2 Capture And Decode TTitrace    5   1.5
#    Check SLIV Of UL In TTI    5    53.0
#    Check SLIV Of UL In TTI    5    69.0
#    CUDU_L2 Check Rate    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]    5    0.1
#
#*** Keywords ***
#Check SLIV Of UL In TTI
#    [Arguments]    ${log_id}    ${sliv}
#    ${list}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
#    ...    ulFdSchedData.dciFormat    ulFdSchedData.SLIV    ["0", ""]    except    ${sliv}    include    ulFdSchedData.SLIV
#    Should Be True    len(${list})>0
#
#Check AdaptRetxStatus Of UL In TTI
#    [Arguments]    ${log_id}
#    ${list}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
#    ...    ulFdSchedData.dciFormat    ulFdSchedData.adaptRetxStatus    ["0", ""]    except    APPLY    include    ulFdSchedData.adaptRetxStatus
#    Should Be True    len(${list})>0
