*** Settings ***
Library     keywords_CNI80040.py

Documentation
...    author:      Paweł Konieczny
...    maintainer:  Marcin Kotuła (marcin.kotula@nokia.com)
...    testline:    CLOUD_5G_I_LO_AP_LO
...    release:     23R4

*** Variables ***
${TRAFFIC_DURATION_SEC}=   300s

*** Keywords ***
CNI80040_Proactive_Resenting_Rlc_Pdus_From_Delayed_Ca_Cell_To_Other_Ca_Cell_One_Ca_Ue_With_Bler_For_Delay
    Attach 2CC CA UE
    Start High Dl Tput
    Add Bler For Needed Delay
    Display Traffic Stats And Wait For Another Pm Package
    Check If Proportion Between M55311C06006 And M55311C01006 Is Better Than Without Cni80040
    Deregister Ue    ue_id=1

Update Scf And Ap
    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_1c_CA_FDD.xml
    Fix And Send Full Commissioning With Given Scf Filepath    scfc_filepath=${CURDIR}/config/SBTS00/full_scf_1CA_FDD.xml

Enable Ca Fdd
      Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Carrier_Aggregation/delta_enable_FDD_CA.json

Enable Cni-80040
      Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Carrier_Aggregation/delta_enable_CNI80040_and_set_blind_CA.json

Attach 2CC CA UE
    Execute Egate Command    cmd=sim_debug_log level=6
    Set Internal Traffic Type To UEs    ue_id=1   pdu_id=1
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_FOR_2CC_FDD}
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1   pdu_id=1    gw_id=1

Start High Dl Tput
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul kbps=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=120 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=120 trf_id=2

Add Bler For Needed Delay
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 dl_bler=200,1000,1000,1000,1000,1000,1000,1000
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 profile_id=1 testmode=bler action=activate

Display Traffic Stats
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 trf_id=1 dir=dl
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 trf_id=2 dir=dl
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pdsch scell=0,1
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pusch scell=0,1

Display Traffic Stats And Wait For Another Pm Package
    Sleep    10s
    Display Traffic Stats
    Sleep    ${TRAFFIC_DURATION_SEC}    Time For Traffic
    Wait For Next Full Pm Interval
    Display Traffic Stats
