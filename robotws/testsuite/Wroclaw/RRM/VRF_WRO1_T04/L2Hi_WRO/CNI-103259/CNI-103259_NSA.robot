*** Settings ***
Variables    CNI-103259_variables.py

Documentation
...    author: Paweł Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 24R3

*** Keywords ***
CNI-103259_Transfer_Of_Data_Between_Menb_And_Sgnb_Pdu_Type_1
    Add Invalid Content In Protocol Messages For X2u
    Attach Ue To Enb    ue_id=11
    Start 50 Mbps Dl Data Traffic
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats
    Check Pm Counter For Counting Number Of Times Incorrect X2-u Ul Up Message Is Received In Cu
    Detach Ue    ue_id=11

Set Dldatasplit To X2U
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_set_DlDataSplit_To_X2U.json

Start 50 Mbps Dl Data Traffic
    Start Data Traffic  ues=11    bearer_id=2    direction=dl    throughput=50mbps

Add Invalid Content In Protocol Messages For X2u
    Execute Egate Command    cmd=gnb_endc_param id=3 scg_dl_dist_percent=50
    Execute Egate Command    cmd=uec_param id=1 scg_ul_dist_percent=50
    Execute Egate Command    cmd=gnb_endc_param id=3 use_nr_ran_cont=true
    Execute Egate Command    cmd=enb_endc_param id=1 use_nr_ran_cont=true
    Execute Egate Command    cmd=${UE_ENB_ERROR_GTPU_HEADER_CONFIG_FOR_NSA}
    Sleep    2s

Display Bearer Stats
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2

Check Pm Counter For Counting Number Of Times Incorrect X2-u Ul Up Message Is Received In Cu
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DISC_WRG_MSG_X2U_UL}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
