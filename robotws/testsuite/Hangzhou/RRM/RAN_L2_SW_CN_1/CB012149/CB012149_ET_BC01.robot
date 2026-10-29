*** Settings ***
Documentation    ...
Resource           ./CB012149_resource.robot
Resource           ./../CUDU_L2/common_setup_teardown.robot
Suite Setup        Common Suite Setup 2
Test Teardown      Common Test Teardown 2
Suite Teardown     Common Suite Teardown 2
Force Tags         CLOUD_5G_I_BOO_AP_LOO    SBTS00
...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

*** Variables ***
${SCF_PATH}                   ${CURDIR}/Config/SCF
${WTS_DIR}                    /opt/iphy/latest
${LOCAL_WTS_DIR}              ${CURDIR}/Config/WTS/
${gnb_swconfig}               ${CURDIR}/Config/SCF/swconfig_gnb_asrs.txt
${SWCONFIG_DA11}              0x4B000F=1;0x58012d=2;0x3F007C=1024
${UE_ID}                      1
${WTS_CFG_DA11}               wts_CB012149_BC01.cfg
${SCF_DA11}                   ${SCF_PATH}/CB012149_BC01.xml
${iphy_DA11}                  ${CURDIR}/Config/IPHY/iphy_BC01.xml
${SLIVLIST_1}                 ["0", "","27.0","41.0","53.0","49.0","255.0"]
${SLIVLIST_2}                 ["0", "","27.0","41.0","55.0","69.0","255.0"]
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB012149ET-BC01__Voice_over_NR_call_on_FDD_PCell_with_UL_Tx_Switching_configured
    [Documentation]
    ...    Precondition:
    ...      FDD 20M and pcell TDD with 1070 frame structure.
    ...      :with beam=4 and refine beam is enable
    ...    Test Steps:
    ...      Step1: UE1 attach to FDD cell as pcell, UE2 with UL2 layer and DL data transfer.
    ...      Step2: UE1 report A1 to trigger scells additon.UE1 send P SRS for TDD scell.
    ...      Step3: start UL data for non GBR to trigger Scell active.
    ...      Step4: PDU session modify to setup 5QI-5 and 5QI-1.
    ...      Step5: start UL and DL data for GBR call.
    ...      Step6: start DL data for non-GBR.
    ...      Step7: UE2 simulate lower SINR to trigger 2layer to one Layer and start ASRS.
    ...    Check point:
    ...      1. Verify after data transfer GNB schedule UL data on FDD Pcell which is not overlap with TDD scell and 2
    ...      layer on TDD cell at TDD UL slot.
    ...      2. Verify UE1 FDD pcell  PUSCH slot before or after FDD UL slot SLIV like this:
    ...      slot1 & 3&6&slot8: S=0, L=12(SLIV 55)when psrs off these slot and slot3 or slot0 & slot5 :S=2,L=12(SLIV 53)
    ...      other FDD UL schedule slot use normal 14 symbol like legacy.
    ...      3. After step5,Voice call 5QI1 schedule on pcell only successfully.Non-GBR data still on Pcell and scell.
    ...      4. After step 7,U2 UL data from layer 2 to layer 1.for UE1 FDD UL slot SLIV like this:
    ...      slot1 & 3&6&slot8: S=0,L=12(SLIV 55)when psrs off these slot.and slot0 & slot5 :S=2,L=12(SLIV 53)when UE2 asrs does not on slot5
    ...      other FDD UL schedule slot use normal 14 symbol like legacy.
    ...      5. No DTX/CRC NOK
    [Tags]    caseBC01    Manual_dguan   TA_dguan
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_DA11}
    ...        AND    Suite Setup Update GNB    scf_file=${SCF_DA11}    iphy_file=${iphy_DA11}    swconfig_param=${SWCONFIG_DA11}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
    #Step1&2
    SA Single UE Attach    3
    Start SA UE Big DL Traffic Internal    3    525
    Start SA UE Big UL Traffic Internal    3    175
    sleep    5s    #sleep for stable traffic
    SA Single UE Attach    2
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=2 meas_id=1 event=A1 srsrp_nr=75 srsrq_nr=60 phycell_id=52
    #Step3
    Start SA UE Big UL Traffic Internal    2    175
    sleep    15s    #sleep for stable traffic
    CUDU_L2 Capture And Decode TTitrace    1   2
    Check SLIV On Specific Slot In TTI    log_id=1    SLIV=55.0    slot=1    SLIVLIST=${SLIVLIST_1}
    Check SLIV On Specific Slot In TTI    log_id=1    SLIV=53.0    slot=0    SLIVLIST=${SLIVLIST_2}
    Check SLIV On Specific Slot In TTI    log_id=1    SLIV=53.0    slot=5    SLIVLIST=${SLIVLIST_2}
    #Step4&5
    Trigger VONR Establishment And Traffic    ue_id=2
    CUDU_L2 Capture And Decode TTitrace    2   4
#    Check 5qi1 On Specific cell In TTI    2    52
    CUDU_L2 Check UL DTXCRC Rate    2
    #Step6
    Start SA UE Big DL Traffic Internal    2    525
    sleep    5s    #sleep for stable traffic
    #Step7
    Send Commond To Trigger UE2 Lower Sinr    ue_id=3
    CUDU_L2 Capture And Decode TTitrace    3   2
    Check SLIV On Specific Slot In TTI    log_id=3    SLIV=55.0    slot=1    SLIVLIST=${SLIVLIST_1}
#    Check SLIV On Specific Slot In TTI    log_id=3    SLIV=67.0    slot=5    SLIVLIST=${SLIVLIST_1}


*** Keywords ***
Trigger VONR Establishment And Traffic
    [Arguments]    ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue\=${ue_id} pdu\=1 qosflows_to_add\=2 by\=amf
    Sleep    1s    reason=wait PDU session modify success
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue\=${ue_id} pdu\=1 qosflows_to_add\=3 by\=amf
    Sleep    1s    reason=wait PDU session modify success
    Log To Console    Start VONR UL/DL UDP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi=3 trf_id=1 dir=ul protocol=udp rtp_codec=amr_wb_15_85
    Sleep    5s    reason=wait DL/UL traffic is stable
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi=3 trf_id=1 dir=dl protocol=udp rtp_codec=amr_wb_15_85
    Sleep    5s    reason=wait DL/UL traffic is stable

Check 5qi1 On Specific cell In TTI
    [Arguments]    ${log_id}    ${physcellid}
    Log To Console    Check 5qi1 On cell ${physcellid} In TT
    @{list}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    ulFdSchedData.numOf5qi1Prb    physCellId    ["0", ""]    except    ${physcellid}    include    ulFdSchedData.numOf5qi1Prb    no
    Should Be True    len(${list})>0