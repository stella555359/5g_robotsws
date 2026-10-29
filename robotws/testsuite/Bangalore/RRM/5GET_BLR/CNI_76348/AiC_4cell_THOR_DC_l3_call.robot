***Settings***
#Force Tags          CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
#...                 CONFIGS_Bangalore/RRM/ET/custom/test_config.yaml

Documentation
...     author:         kiran.1.g@nokia.com
...     maintainer:     KIRAN G
...     INTRODUCTION:   AIC 4 Cell THOR NIC DC APoABIO Integration

Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource            ../resources/robot/Airphone.robot
Resource            ../resources/robot/WTS_Runner_Keywords.robot
Library             ../resources/python/IphyUpdate.py

Suite Setup             Run keywords        Test Suite Setup
...                     AND                 AIC Software Build Info
...                     AND                 Fetch Taf Library used in TL

suite teardown          Run keywords        Kill WTS processes Using WTS_Runner

***Variables***
#${gnb_index}        0
#${vdu_index}        0
${wts_cfg_file}      ${CURDIR}/config/2T_2F_Basic_HZ.cfg
#${WTS_DIR}          /opt/iphy/latest
${WTS_DIR}           /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}    1
${gw_ID}     1
${gw_ID2}     2
${gw_ID3}     3
${gw_ID4}     4
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${Pdu_session_ID}    1
${Pdu_session_ID2}    2
${Pdu_session_ID3}    3
${Pdu_session_ID4}    4
${epc_log_path}     /tmp/
${UE_ID}     1
${NSA_UE_ID}     101
${UE_ID2}     21
${NSA_UE_ID2}     121
${UE_ID3}     51
${NSA_UE_ID3}     151
${UE_ID4}     71
${NSA_UE_ID4}     171
${BEARER_ID}     2
${VDU_SCF_PATH}     ${CURDIR}/config/SBTS/vDU_DC_UTEWorking.xml
${VCU SCF PATH}     ${CURDIR}/config/SBTS/vCU_DC_UTEWorking.xml
${iphy_xml}         ${CURDIR}/config/iphy_2F_2T.xml
#${gscn_value}   2203

***Test Cases***
[1] AIC_4Cell_SANSA_Call_with_UL_DL_Traffic_Validation
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  REQUIREMENTS:

    [Setup]     Run keywords        Log to console     \n-----> Test Setup <-----
    ...         AND                 Testcase Setup
    ...         AND                 Verify RMODs Online Status      ${800}
    ...         AND                 Add WTS Ipaddr At VM
    ...         AND                 Start WTS Using WTS_Runner     ${wts_cfg_file}
    ...         AND                 X2AP Link Should be UP
    ...         AND                 Collect Alarms on AIC At Start of Test
        sleep   180s
        Log to console     UE Register for SA UE 1
        UE Register should be Successful     ue_id=${UE_ID}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}      gw_id=${gw_ID}
        Log to console     Start DL Traffic for SA UE 1
        Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps    dl_rate=10    pdu_id=${Pdu_session_ID}
		...    trf_id=${TRF_ID}    qfi_id=${QFI_ID}
        sleep   5s
        Log to console     Start UL Traffic for SA UE 1
        Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps    ul_rate=10    pdu_id=${Pdu_session_ID}
		...    trf_id=${TRF_ID2}    qfi_id=${QFI_ID}
	    sleep   5s
        Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=10     pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
        Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=10     pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
        sleep   5s
        Log to console     LTE UE Attach for NSA UE 101
        LTE Attach should be Successful     ${NSA_UE_ID}
        Log to console     5G UE Attach for NSA UE 101
        UE Attach should be Successful     ${NSA_UE_ID}
        Log to console     Start DL Traffic for NSA UE101
        Trigger DL Traffic for NSA    ue_id=${NSA_UE_ID}    Traffic_rate=mbps     dl_rate=10     id=${BEARER_ID}      trf_id=${TRF_ID}
        sleep   5s
        Log to console     Start UL Traffic for NSA UE101
        Trigger UL Traffic for NSA    ue_id=${NSA_UE_ID}    Traffic_rate=mbps     ul_rate=10     id=${BEARER_ID}      trf_id=${TRF_ID2}
	    sleep   5s
        Validate DL Traffic For NSA   ue_id=${NSA_UE_ID}     dl_rate=10     id=${BEARER_ID}
        Validate UL Traffic For NSA   ue_id=${NSA_UE_ID}     ul_rate=10     id=${BEARER_ID}
	    sleep   5s
        Log to console     UE Register for SA UE 21
        UE Register should be Successful     ue_id=${UE_ID2}    pdu_id=${Pdu_session_ID2}     nw_id=${nwslice_ID}      gw_id=${gw_ID2}
        Log to console     Start DL Traffic for SA UE 21
        Trigger DL Traffic for SA    ue_id=${UE_ID2}    Traffic_rate=mbps    dl_rate=10    pdu_id=${Pdu_session_ID2}
		...    trf_id=${TRF_ID3}    qfi_id=${QFI_ID}
        sleep   5s
        Log to console     Start UL Traffic for SA UE21
        Trigger UL Traffic for SA    ue_id=${UE_ID2}    Traffic_rate=mbps    ul_rate=10    pdu_id=${Pdu_session_ID2}
		...    trf_id=${TRF_ID4}    qfi_id=${QFI_ID}
	    sleep   5s
        Validate DL Traffic For SA   ue_id=${UE_ID2}     dl_rate=10     pdu_id=${Pdu_session_ID2}     qfi_id=${QFI_ID}
        Validate UL Traffic For SA   ue_id=${UE_ID2}     ul_rate=10     pdu_id=${Pdu_session_ID2}     qfi_id=${QFI_ID}
        sleep   5s
        Log to console     LTE UE Attach for NSA UE 121
        LTE Attach should be Successful     ${NSA_UE_ID2}
        Log to console     5G UE Attach for NSA UE 121
        UE Attach should be Successful     ${NSA_UE_ID2}
        Log to console     Start DL Traffic for NSA UE121
        Trigger DL Traffic for NSA    ue_id=${NSA_UE_ID2}    Traffic_rate=mbps     dl_rate=10     id=${BEARER_ID}      trf_id=${TRF_ID3}
        sleep   5s
        Log to console     Start UL Traffic for NSA UE121
        Trigger UL Traffic for NSA    ue_id=${NSA_UE_ID2}    Traffic_rate=mbps     ul_rate=10     id=${BEARER_ID}      trf_id=${TRF_ID4}
        sleep   5s
        Validate DL Traffic For NSA   ue_id=${NSA_UE_ID2}     dl_rate=10     id=${BEARER_ID}
        Validate UL Traffic For NSA   ue_id=${NSA_UE_ID2}     ul_rate=10     id=${BEARER_ID}
		sleep	5s
        Log to console     UE Register for SA UE 51
        UE Register should be Successful     ue_id=${UE_ID3}    pdu_id=${Pdu_session_ID3}     nw_id=${nwslice_ID}      gw_id=${gw_ID3}
        Log to console     Start DL Traffic for SA UE 51
        Trigger DL Traffic for SA    ue_id=${UE_ID3}    Traffic_rate=mbps    dl_rate=10    pdu_id=${Pdu_session_ID3}
		...    trf_id=${TRF_ID}    qfi_id=${QFI_ID}
        sleep   5s
        Log to console     Start UL Traffic for SA UE 51
        Trigger UL Traffic for SA    ue_id=${UE_ID3}    Traffic_rate=mbps    ul_rate=10    pdu_id=${Pdu_session_ID3}
		...    trf_id=${TRF_ID2}    qfi_id=${QFI_ID}
	    sleep   5s
        Validate DL Traffic For SA   ue_id=${UE_ID3}     dl_rate=10     pdu_id=${Pdu_session_ID3}    qfi_id=${QFI_ID}
        Validate UL Traffic For SA   ue_id=${UE_ID3}     ul_rate=10     pdu_id=${Pdu_session_ID3}    qfi_id=${QFI_ID}
        sleep   5s
        Log to console     LTE UE Attach for NSA UE 151
        LTE Attach should be Successful     ${NSA_UE_ID3}
        Log to console     5G UE Attach for NSA UE 151
        UE Attach should be Successful     ${NSA_UE_ID3}
        Log to console     Start DL Traffic for NSA UE151
        Trigger DL Traffic for NSA    ue_id=${NSA_UE_ID3}    Traffic_rate=mbps     dl_rate=10     id=${BEARER_ID}      trf_id=${TRF_ID}
        sleep   5s
        Log to console     Start UL Traffic for NSA UE151
        Trigger UL Traffic for NSA    ue_id=${NSA_UE_ID3}    Traffic_rate=mbps     ul_rate=10     id=${BEARER_ID}      trf_id=${TRF_ID2}
	    sleep   5s
        Validate DL Traffic For NSA   ue_id=${NSA_UE_ID3}     dl_rate=10     id=${BEARER_ID}
        Validate UL Traffic For NSA   ue_id=${NSA_UE_ID3}     ul_rate=10     id=${BEARER_ID}
	    sleep   5s
        Log to console     UE Register for SA UE 71
        UE Register should be Successful     ue_id=${UE_ID4}    pdu_id=${Pdu_session_ID4}     nw_id=${nwslice_ID}      gw_id=${gw_ID4}
        Log to console     Start DL Traffic for SA UE71
        Trigger DL Traffic for SA    ue_id=${UE_ID4}    Traffic_rate=mbps    dl_rate=10    pdu_id=${Pdu_session_ID4}
		...    trf_id=${TRF_ID4}    qfi_id=${QFI_ID}
        sleep   5s
        Log to console     Start UL Traffic for SA UE71
        Trigger UL Traffic for SA    ue_id=${UE_ID4}    Traffic_rate=mbps    ul_rate=10    pdu_id=${Pdu_session_ID4}
		...    trf_id=${TRF_ID4}    qfi_id=${QFI_ID}
	    sleep   5s
        Validate DL Traffic For SA   ue_id=${UE_ID4}     dl_rate=10     pdu_id=${Pdu_session_ID4}     qfi_id=${QFI_ID}
        Validate UL Traffic For SA   ue_id=${UE_ID4}     ul_rate=10     pdu_id=${Pdu_session_ID4}     qfi_id=${QFI_ID}
        sleep   5s
        Log to console     LTE UE Attach for NSA UE 171
        LTE Attach should be Successful     ${NSA_UE_ID4}
        Log to console     5G UE Attach for NSA UE 171
        UE Attach should be Successful     ${NSA_UE_ID4}
        Log to console     Start DL Traffic for NSA UE171
        Trigger DL Traffic for NSA    ue_id=${NSA_UE_ID4}    Traffic_rate=mbps     dl_rate=10     id=${BEARER_ID}      trf_id=${TRF_ID4}
        sleep   5s
        Log to console     Start UL Traffic for NSA UE171
        Trigger UL Traffic for NSA    ue_id=${NSA_UE_ID4}    Traffic_rate=mbps     ul_rate=10     id=${BEARER_ID}      trf_id=${TRF_ID4}
        sleep   5s
        Validate DL Traffic For NSA   ue_id=${NSA_UE_ID4}     dl_rate=10     id=${BEARER_ID}
        Validate UL Traffic For NSA   ue_id=${NSA_UE_ID4}     ul_rate=10     id=${BEARER_ID}		
	    log to console      start delay of 10 min
        Sleep    600s
        log to console      Stop delay
        Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=10     pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
        Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=10     pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
        Stop Data Traffic for SA     ue_id=${UE_ID}
        UE Deregister should be Successful   ue_id=${UE_ID}
        Validate DL Traffic For NSA   ue_id=${NSA_UE_ID}     dl_rate=10     id=${BEARER_ID}
        Validate UL Traffic For NSA   ue_id=${NSA_UE_ID}     ul_rate=10     id=${BEARER_ID}
        Stop Data Traffic for NSA     ue_id=${NSA_UE_ID}
        UE Detach should be Successful   ${NSA_UE_ID}
        Validate DL Traffic For SA   ue_id=${UE_ID2}     dl_rate=10     pdu_id=${Pdu_session_ID2}     qfi_id=${QFI_ID}
        Validate UL Traffic For SA   ue_id=${UE_ID2}     ul_rate=10     pdu_id=${Pdu_session_ID2}     qfi_id=${QFI_ID}
        Stop Data Traffic for SA     ue_id=${UE_ID2}
        UE Deregister should be Successful   ue_id=${UE_ID2}
        Validate DL Traffic For NSA   ue_id=${NSA_UE_ID2}     dl_rate=10     id=${BEARER_ID}
        Validate UL Traffic For NSA   ue_id=${NSA_UE_ID2}     ul_rate=10     id=${BEARER_ID}
        Stop Data Traffic for NSA     ue_id=${NSA_UE_ID2}
        UE Detach should be Successful   ${NSA_UE_ID2}
        Validate DL Traffic For SA   ue_id=${UE_ID3}     dl_rate=10     pdu_id=${Pdu_session_ID3}    qfi_id=${QFI_ID}
        Validate UL Traffic For SA   ue_id=${UE_ID3}     ul_rate=10     pdu_id=${Pdu_session_ID3}    qfi_id=${QFI_ID}
        Stop Data Traffic for SA     ue_id=${UE_ID3}
        UE Deregister should be Successful   ue_id=${UE_ID3}
        Validate DL Traffic For NSA   ue_id=${NSA_UE_ID3}     dl_rate=10     id=${BEARER_ID}
        Validate UL Traffic For NSA   ue_id=${NSA_UE_ID3}     ul_rate=10     id=${BEARER_ID}
        Stop Data Traffic for NSA     ue_id=${NSA_UE_ID3}
        UE Detach should be Successful   ${NSA_UE_ID3}
        Validate DL Traffic For SA   ue_id=${UE_ID4}     dl_rate=10     pdu_id=${Pdu_session_ID4}     qfi_id=${QFI_ID}
        Validate UL Traffic For SA   ue_id=${UE_ID4}     ul_rate=10     pdu_id=${Pdu_session_ID4}     qfi_id=${QFI_ID}
        Stop Data Traffic for SA     ue_id=${UE_ID4}
        UE Deregister should be Successful   ue_id=${UE_ID4}
        Validate DL Traffic For NSA   ue_id=${NSA_UE_ID4}     dl_rate=10     id=${BEARER_ID}
        Validate UL Traffic For NSA   ue_id=${NSA_UE_ID4}     ul_rate=10     id=${BEARER_ID}
        Stop Data Traffic for NSA     ue_id=${NSA_UE_ID4}
        UE Detach should be Successful   ${NSA_UE_ID4}
		
    [Teardown]  Suite Teardown

** Keywords **
Suite Teardown
    Log to Console    \n-----> Teardown Start <-----
    run keyword and ignore error        Kill WTS processes Using WTS_Runner
