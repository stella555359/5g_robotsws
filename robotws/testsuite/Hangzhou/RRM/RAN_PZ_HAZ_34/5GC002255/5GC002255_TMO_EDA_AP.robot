*** Settings ***
Documentation
...    author:  kang xiang
...    contact: kang.xiang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env  tl_type=fddtdd_sansa_cmwv/2cells_1T1F_TMO  ue_count=100
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs With Check Scell
Force Tags        release-SBTS00    tl-CLOUD_5G_I_LO_AP_LO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot


*** Variables ***
@{pass_regexp_scell_addition}
...    pcid:52, scellIdx:1
...    pcid:50, scellIdx:0
#...    SCellIndex 1 activated successfully at airphone

@{pass_regexp_scell}
...    CellIndex-1
...    CellIndex-0


*** Test Cases ***
TMO_EDA_04173522
    [Documentation]
    ...   [purpose]: The purpose of this case is to verify TMO EDA scenario of 04173522
    ...   Scell addition fails due to no Radio Resources Available
    ...   DLmimomode/CSIRS/CDRX configure align with TMO
    FOR    ${ue_id}    IN RANGE    1    101
        Log to console  UE_ID:${ue_id}
        Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
        Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
        Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=QoS Routing Table
        ...    sleep_time=1
        Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=4 event=A1 srsrp_nr=120 srsrq_nr=52
        ...    pass_regexp=${pass_regexp_scell_addition}    timeout=30
        Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    pass_regexp=${pass_regexp_scell}
        sleep    2s
    END


*** Keywords ***
Common Test Teardown And Stop Capture Logs With Check Scell
    Check Scell For Each UE
    sleep    60s
    Common Test Teardown And Stop Capture Logs

Check Scell For Each UE
    FOR    ${ue_id}    IN RANGE    1    101
        Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    pass_regexp=${pass_regexp_scell}
        sleep    1s
    END