*** Settings ***
Documentation
...    author:  ruifang.zhu@nokia-sbell.com
...    contact: ruifang.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv_tmo_65    ue_count=100
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS26R2    tl-CLOUD_5G_I_LOO_AP_LOOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot
*** Variables ***
${SYSCOM_FLAG}    true
@{FAULTS_EXCLUDED_CHECKING}    8000

@{PARAMS_IN_SWCONFIG}
...    ${rdPCsiPoolHkfPeriod_min}
...    ${rdHkfMinPCsiResPerSlot}
...    ${rdHkfMinPCsiRepPeriod}
...    ${rdHkfPCsiPoolMaxRCUsFactor}
...    ${uplane_6878}
${rdPCsiPoolHkfPeriod_min}    0x5901A6=1
${rdHkfMinPCsiResPerSlot}    0x5901A7=4
${rdHkfMinPCsiRepPeriod}    0x5901A8=40
${rdHkfPCsiPoolMaxRCUsFactor}    0x5901A9=60
${uplane_6878}    0x5901AB=1

${HKF}    SEPARATOR=
...    (f1ap.procedureCode == 8) && (nr-rrc.pucch_ResourceId == 8) &&
...    (f1ap.radioNetwork == 7)

*** Test Cases ***
CB013151_C004_Verify SRCX expansion and release with trigger HKF SR resource reconfiguration
    [Documentation]
    ...    This user scenario verifies that the SRCX region is released when the required SR capacity of the cell
    ...    diminishes due to the decreasing number of UEs camped in the cell.
    ...    It verify HKF trigger SR resource reconfigure.
    ...    It verifies as well that the unused PRBs of SRCX and pCSI are allocated to PUSCH when those PRBs
    ...    are adjacent to the PUSCH region
    ...    CELL-1 60M, Single dedicated BWP, framestructure 1116_3ms
    ...    pucchF1ResOccConf=1-1-0_OCCs
    ...    actAdaptiveSr=true
    ...    [step]:
    ...       a. 59 SA UEs attach to cell-1, SRCX configured
    ...       b. release UE1-UE24, HKF trigger
    ...       c. release UE25-UE48, SRCX release
    ...       d. setup UE1-48 to cell-1, SRCX configured
    ...       f. repeat step b-d for 2 times,release UE1-UE49
    ...       g. add ul traffic for UE49, check the expansion of the PUSCH region over the PRBs of PUCCH
    [Tags]    C005
    Multi SA Call Setup Successfully    cell_id=1    ue_id_start=1    ue_id_end_before=60
    HKF and SRCX expansion release    round=1
	Multi SA Call Setup Successfully    cell_id=1    ue_id_start=1    ue_id_end_before=49
    HKF and SRCX expansion release    round=2
	Multi SA Call Setup Successfully    cell_id=1    ue_id_start=1    ue_id_end_before=49
    HKF and SRCX expansion release    round=3
    Check the PUSCH region
    Release UEs    ue_type=all

*** Keywords ***
Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

HKF and SRCX expansion release
    [Arguments]    ${round}
    Multi SA release to trigger HKF    ue_start=1    ue_end_before=12    round=${round}
    Multi SA release to trigger SRCX release   ue_start=12    ue_end_before=49
    sleep    10s

SA Call Setup Successfully
  [Arguments]    ${ue_id}    ${cell_id}=1    ${pdu_id}=1    ${gw_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    ${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id}    QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=10 trf_id=1    UE ${ue_id}: UDP DL
#  Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=1 trf_id=1    UE ${ue_id}: UDP UL
    sleep    5s
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0 type=pusch
    Execute Egate Command    bearer_stats ue=${ue_id} pdu=1 qfi=1 dir=ul

Multi SA Call Setup Successfully
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        SA Call Setup Successfully    ${ue_id}    ${cell_id}
        sleep    1s
    END
    sleep    10s

Multi SA release to trigger HKF
    [Arguments]    ${ue_start}    ${ue_end_before}    ${round}
    Start To Capture Wireshark Log    Round${round}_HKF
    FOR    ${ue_idr}    IN RANGE    ${ue_start}    ${ue_end_before}
        ${ue_idr}   convert to string    ${ue_idr}
        Execute Egate Command    trf_data_stop ue=${ue_idr} pdu=1 qfi=1 dir=dl
        Execute Egate Command    trf_data_stop ue=${ue_idr} pdu=1 qfi=1 dir=ul
        Release UEs    ue_type=sa    ue_id=${ue_idr}
    END
    sleep    120s
    stop capture wireshark log    Round${round}_HKF
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark_Round${round}_HKF.pcap    ${HKF}
    Run Keyword If    ${round}==1    Should Be True    ${number}==11
    Run Keyword If    ${round}==2    Should Be True    ${number}==9
    Run Keyword If    ${round}==3    Should Be True    ${number}==9

Multi SA release to trigger SRCX release
    [Arguments]    ${ue_start}    ${ue_end_before}
    FOR    ${ue_idr}    IN RANGE    ${ue_start}    ${ue_end_before}
        ${ue_idr}   convert to string    ${ue_idr}
        Execute Egate Command    trf_data_stop ue=${ue_idr} pdu=1 qfi=1 dir=dl
        Execute Egate Command    trf_data_stop ue=${ue_idr} pdu=1 qfi=1 dir=ul
        Release UEs    ue_type=sa    ue_id=${ue_idr}
    END
    sleep    60s

Check the PUSCH region
    Execute Egate Command    trf_data_start ue=49 pdu=1 qfi=1 dir=ul mbps=100 trf_id=2
  	Execute Egate Command    trf_data_start ue=49 pdu=1 qfi=1 dir=ul mbps=100 trf_id=3
  	sleep   15s
  	Execute Egate Command    ue_stats_nr id=49 scell=0 type=pusch
    Execute Egate Command    bearer_stats ue=49 pdu=1 qfi=1 dir=ul
    Start To Capture Gnb Ttitrace    tag=Test_N1    cell_id=1
    sleep   15s
    Stop Capture Gnb Ttitrace    tag=Test_N1
    sleep    10s
