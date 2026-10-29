***Settings***
#Force Tags          CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...                 CONFIGS_Bangalore/RRM/ET/custom/test_config.yaml

Documentation
...     author:         kiran.1.g@nokia.com
...     maintainer:     KIRAN G
...     INTRODUCTION:   AIC 2 cell 1 ABIO Integration

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
${wts_cfg_file}      ${CURDIR}/config/Basic_wts_NSAOnly_2cellFDD.cfg
#${WTS_DIR}          /opt/iphy/latest
${WTS_DIR}           /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}    1
${gw_ID}     1
${gw_ID2}     2
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${Pdu_session_ID}    1
${Pdu_session_ID2}    2
${epc_log_path}     /tmp/
${UE_ID}     1
${NSA_UE_ID}     11
${UE_ID2}     2
${NSA_UE_ID2}     12
${BEARER_ID}     2
${VDU_SCF_PATH}     ${CURDIR}/config/SBTS/vRAN4.0_vDU_FDD_NSA_2cell_SCF
${VCU SCF PATH}     ${CURDIR}/config/SBTS/vRAN4.0_vCU_FDD_NSA_2cell_SCF
${iphy_xml}         ${CURDIR}/config/iphy.xml
${gscn_value}   2203

***Test Cases***
[1] AIC_2Cell_SANSA_Call_with_UL_DL_Traffic_Validation
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  REQUIREMENTS:

    [Setup]     Run keywords        Log to console     \n-----> Test Setup <-----
    ...         AND                 Testcase Setup
    ...         AND                 Verify RMODs Online Status      ${800}
    ...         AND                 Clear WTS     ${WTS_DIR}
    ...         AND                 Add WTS Ipaddr At VM
    ...         AND                 Start WTS Using WTS_Runner     ${wts_cfg_file}
    ...         AND                 X2AP Link Should be UP
    ...         AND                 Collect Alarms on AIC At Start of Test
        sleep   180s
#        Log to console     UE Register
#        UE Register should be Successful     ue_id=${UE_ID}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}      gw_id=${gw_ID}
#        Log to console     Start DL Traffic for SA UE1
#        Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps    dl_rate=5    pdu_id=${Pdu_session_ID}
#		...    trf_id=${TRF_ID}    qfi_id=${QFI_ID}
#        sleep   5s
#        Log to console     Start UL Traffic for SA UE1
#        Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps    ul_rate=5    pdu_id=${Pdu_session_ID}
#		...    trf_id=${TRF_ID2}    qfi_id=${QFI_ID}
#	    sleep   5s
#       Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=5     pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
#        Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=5     pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
#        sleep   5s
        Log to console     LTE UE Attach
        LTE Attach should be Successful     ${NSA_UE_ID}
        Log to console     5G UE Attach
        UE Attach should be Successful     ${NSA_UE_ID}
        Log to console     Start DL Traffic for NSA UE11
        Trigger DL Traffic for NSA    ue_id=${NSA_UE_ID}    Traffic_rate=mbps     dl_rate=5     id=${BEARER_ID}      trf_id=${TRF_ID}
        sleep   5s
        Log to console     Start UL Traffic for NSA UE11
        Trigger UL Traffic for NSA    ue_id=${NSA_UE_ID}    Traffic_rate=mbps     ul_rate=5     id=${BEARER_ID}      trf_id=${TRF_ID2}
	    sleep   5s
       Validate DL Traffic For NSA   ue_id=${NSA_UE_ID}     dl_rate=5     id=${BEARER_ID}
        Validate UL Traffic For NSA   ue_id=${NSA_UE_ID}     ul_rate=5     id=${BEARER_ID}
	    sleep   5s
#        Log to console     UE Register
#        UE Register should be Successful     ue_id=${UE_ID2}    pdu_id=${Pdu_session_ID2}     nw_id=${nwslice_ID}      gw_id=${gw_ID2}
#        Log to console     Start DL Traffic for SA UE2
#        Trigger DL Traffic for SA    ue_id=${UE_ID2}    Traffic_rate=mbps    dl_rate=5    pdu_id=${Pdu_session_ID2}
#		...    trf_id=${TRF_ID3}    qfi_id=${QFI_ID}
#        sleep   5s
#        Log to console     Start UL Traffic for SA UE2
#        Trigger UL Traffic for SA    ue_id=${UE_ID2}    Traffic_rate=mbps    ul_rate=5    pdu_id=${Pdu_session_ID2}
#		...    trf_id=${TRF_ID4}    qfi_id=${QFI_ID}
#	    sleep   5s
#        Validate DL Traffic For SA   ue_id=${UE_ID2}     dl_rate=5     pdu_id=${Pdu_session_ID2}     qfi_id=${QFI_ID}
#        Validate UL Traffic For SA   ue_id=${UE_ID2}     ul_rate=5     pdu_id=${Pdu_session_ID2}     qfi_id=${QFI_ID}
#        sleep   5s
        Log to console     LTE UE Attach
        LTE Attach should be Successful     ${NSA_UE_ID2}
        Log to console     5G UE Attach
       UE Attach should be Successful     ${NSA_UE_ID2}
        Log to console     Start DL Traffic for NSA UE12
        Trigger DL Traffic for NSA    ue_id=${NSA_UE_ID2}    Traffic_rate=mbps     dl_rate=5     id=${BEARER_ID}      trf_id=${TRF_ID3}
       sleep   5s
        Log to console     Start UL Traffic for NSA UE12
        Trigger UL Traffic for NSA    ue_id=${NSA_UE_ID2}    Traffic_rate=mbps     ul_rate=5     id=${BEARER_ID}      trf_id=${TRF_ID4}
        sleep   5s
        Validate DL Traffic For NSA   ue_id=${NSA_UE_ID2}     dl_rate=5     id=${BEARER_ID}
        Validate UL Traffic For NSA   ue_id=${NSA_UE_ID2}     ul_rate=5     id=${BEARER_ID}
	    log to console      start delay of 10 min
        Sleep    600s
        log to console      Stop delay
#        Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=5     pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
#        Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=5     pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
#        Stop Data Traffic for SA     ue_id=${UE_ID}
#        UE Deregister should be Successful   ue_id=${UE_ID}
        Validate DL Traffic For NSA   ue_id=${NSA_UE_ID}     dl_rate=5     id=${BEARER_ID}
        Validate UL Traffic For NSA   ue_id=${NSA_UE_ID}     ul_rate=5     id=${BEARER_ID}
        Stop Data Traffic for NSA     ue_id=${NSA_UE_ID}
        UE Detach should be Successful   ${NSA_UE_ID}
#        Validate DL Traffic For SA   ue_id=${UE_ID2}     dl_rate=5     pdu_id=${Pdu_session_ID2}     qfi_id=${QFI_ID}
#        Validate UL Traffic For SA   ue_id=${UE_ID2}     ul_rate=5     pdu_id=${Pdu_session_ID2}     qfi_id=${QFI_ID}
#        Stop Data Traffic for SA     ue_id=${UE_ID2}
#        UE Deregister should be Successful   ue_id=${UE_ID2}
        Validate DL Traffic For NSA   ue_id=${NSA_UE_ID2}     dl_rate=5     id=${BEARER_ID}
        Validate UL Traffic For NSA   ue_id=${NSA_UE_ID2}     ul_rate=5     id=${BEARER_ID}
        Stop Data Traffic for NSA     ue_id=${NSA_UE_ID2}
        UE Detach should be Successful   ${NSA_UE_ID2}

    [Teardown]  Suite Teardown

** Keywords **
Suite Teardown
    Log to Console    \n-----> Teardown Start <-----
    run keyword and ignore error        Kill WTS processes Using WTS_Runner
