*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      CB008246-LB72-OnlineModification_Cell1-2X2_cell2-4X4-TDD.robot
...                                This test case checks the IWK of CB008246 with FDM DMRS in both DL and UL
...                                Expectation is when UE is in HR or BR lamode, it should select cdm as 1 whenevr the
...                                MCS thresholds for the respective lamode are met.
...                                After Online modification of these thresholds, newly added UEs should start respecting
...                                the new thresholds while the UEs connected before the online modification should continue
...                                using the old one.
...             TEST SET NAME:     CB008246-LB72-OnlineModification_Cell1-2X2_cell2-4X4-TDD.robot
...             TESTING SPLIT:     See CB008246-L testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-L CFAM

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008246_resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py

Suite Setup         Run keywords
...                 Log To console  SuiteSetup
...                 AND     Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     Configure in VM for RANK-4
...                 AND     Add RD Parameters To GNB Swconfig File      0x590004=4  #rdDlMimoLayerCapabilityRadParam
#...                 AND     Perform SCF Delta Commissioning with LB72_TDD_2x2MIMO_Cell1_4x4MIMO_Cell2.json
...                 AND     sleep    180s
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Start Log    btslog
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Log    btslog
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/LB72-Online_scf.xml
${AP_XML}=      ${CURDIR}/config/SCF/LB72_iphy.xml

${wts_cfg_file}    ${CURDIR}/config/wts/basic_cfg-LB72-TDD.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${TEST_NAME}        test_case

*** Test Cases ***
[1]CB008246_LB72_OnlineModification_Cell1-2x2_Cell2-4x4-TDD
    log to console   UE attach trigerring now...
    X2AP Link Should be UP
    ${crnti_list1}    Before modification HR SA BR NSA UEs attached to 2x2 cell-1 and BR SA HR NSA UEs to 4x4 cell-2
    ${path_TTITrace_onlyTraffic1}   Stop log   ttitrace   test_scenario=TTITrace_onlyTraffic1
    Perform SCF Delta Commissioning with Modify_Online_thresholds_to_activate_DL_and_UL_dataDmrsFdm.json
    sleep       60s
    ${crnti_list2}    After modification HR SA BR NSA UEs attached to 2x2 cell-1 and BR SA HR NSA UEs to 4x4 cell-2
    ${path_TTITrace_onlyTraffic2}   Stop log   ttitrace   test_scenario=TTITrace_onlyTraffic2
    Decode all collected ttitraces
    Very FDM DMRS IWK with CB008246 in DL    ${path_TTITrace_onlyTraffic1}[ttitrace]    ${crnti_list1}
    Very FDM DMRS IWK with CB008246 in DL after online modify    ${path_TTITrace_onlyTraffic2}[ttitrace]
    ...                                                          ${crnti_list1}    ${crnti_list2}
    Very FDM DMRS IWK with CB008246 in UL   ${path_TTITrace_onlyTraffic1}[ttitrace]    ${crnti_list1}
    Very FDM DMRS IWK with CB008246 in UL after online modify    ${path_TTITrace_onlyTraffic2}[ttitrace]
    ...                                                          ${crnti_list1}    ${crnti_list2}
    [Teardown]       Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Before modification HR SA BR NSA UEs attached to 2x2 cell-1 and BR SA HR NSA UEs to 4x4 cell-2
    ${pattern}   Set Variable     location
    wtsrunner.ue_change_location     id=1     enb=2    cell=1
    Read WTS Output Until Pattern Matches    ${pattern}    ${10}
    wtsrunner.ue_change_location     id=2     enb=2    cell=2
    Read WTS Output Until Pattern Matches    ${pattern}    ${10}
    sleep    1s
    ${crnti_list1}=      MultiUE Register should be Successful fixed    1    2    Initial Context Setup Successful
    ${nsa_hr_rnti}=      MultiUE Attach for NSA     11     11     2
    ${nsa_br_rnti}=      MultiUE Attach for NSA     12     12     1
    start log     ttitrace
    MultiUE Trigger DL Traffic for SA    1    2    Traffic_rate=mbps   dl_rate=1   trf_id=1
    MultiUE Trigger UL Traffic for SA    1    2    Traffic_rate=mbps   ul_rate=1   trf_id=1
    MultiUE DL Traffic Start for NSA     11     12     mbps    10     id=2    trf_id=1
    MultiUE UL Traffic Start for NSA     11     12     mbps    10     id=2    trf_id=1
    sleep    1s
    [return]    ${crnti_list1}    ${nsa_hr_rnti}   ${nsa_br_rnti}

After modification HR SA BR NSA UEs attached to 2x2 cell-1 and BR SA HR NSA UEs to 4x4 cell-2
    ${pattern}   Set Variable     location
    wtsrunner.ue_change_location     id=1     enb=2    cell=1
    Read WTS Output Until Pattern Matches    ${pattern}    ${10}
    wtsrunner.ue_change_location     id=2     enb=2    cell=2
    Read WTS Output Until Pattern Matches    ${pattern}    ${10}
    sleep    1s
    ${crnti_list2}=      MultiUE Register should be Successful fixed    3    4     Initial Context Setup Successful
    ${nsa_hr_rnti}=      MultiUE Attach for NSA     13     13     2
    ${nsa_br_rnti}=      MultiUE Attach for NSA     14     14     1
    start log     ttitrace
    MultiUE Trigger DL Traffic for SA    3    4    Traffic_rate=mbps   dl_rate=1   trf_id=1
    MultiUE Trigger UL Traffic for SA    3    4    Traffic_rate=mbps   ul_rate=1   trf_id=1
    MultiUE DL Traffic Start for NSA     13     14     mbps    10     id=2    trf_id=1
    MultiUE UL Traffic Start for NSA     13     14     mbps    10     id=2    trf_id=1
    sleep    1s
    [return]    ${crnti_list2}    ${nsa_hr_rnti}   ${nsa_br_rnti}

Stop SA and NSA UEs
    Stop MultiUE Data Traffic for SA     1    4
    MultiUE Deregister should be Successful     1    4
    MultiUE DL Traffic Stop for NSA    11    14
    MultiUE UL Traffic Stop for NSA    11    14
    MultiUE Detach for NSA    11    14

Decode all collected ttitraces
    Decode TTI Trace    TTITrace_onlyTraffic1
    sleep       5s
    Decode TTI Trace    TTITrace_onlyTraffic2
    sleep       5s

Read BIP log
    [Arguments]    ${file}
    ${f1}=    set variable     itf_L2Log_Du_Ps_Events_UlFdSchedData_UlFdSchedData_t.numCdmGroupNoData == 0x01
    ${f2}=    set variable     itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.numCdmGroupNoData == 0x01
    ${pdmlFile}=      analyzer.pcap_to_pdml        ${file}     ${f1}

    ${numCdmGroupNoData_ul}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                   packetName=itf_l2log_du_ps_events_ulfdscheddata_ulfdscheddata
    ...                                                   path=numCdmGroupNoData
    ...                                                  endPacket=${10}

    ${pdmlFile}=      analyzer.pcap_to_pdml        ${file}     ${f2}
    ${numCdmGroupNoData_dl}      analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                   packetName=itf_l2log_du_ps_events_dlfdscheddata_dlfdscheddata
    ...                                                   path=numCdmGroupNoData
    ...                                                  endPacket=${10}

Very FDM DMRS IWK with CB008246 in DL
    [Arguments]   ${FolderName}    ${UE_crnti_list}
    ${chk_attrs}   Create List  sfn  slot  rnti  physCellId  aggregationLevel    laMode  mcsTable
    ...                         rrmDlUsedMcs   numCdmGroupNoData   numOfLayers
     #verify_fdm_dmrs(file, event, attrs,43734, 1, 1, 2, 1)
     # def verify_fdm_dmrs(file,event,attrs,rnti,rank,expected_cdm,nidd_value,hr_rnti=1):
    verify_fdm_dmrs     ${FolderName}/output_dl_formated.csv   dlFdSchedData    ${chk_attrs}
    ...                 ${UE_crnti_list[${0}]}[${0}]  ${2}    ${1}    ${13}    ${1}

    verify_fdm_dmrs     ${FolderName}/output_dl_formated.csv   dlFdSchedData    ${chk_attrs}
    ...                 ${UE_crnti_list[${0}]}[${1}]  ${4}    ${2}    ${1}    ${0}

    verify_fdm_dmrs     ${FolderName}/output_dl_formated.csv   dlFdSchedData    ${chk_attrs}
    ...                 ${UE_crnti_list[${1}]}[${0}]  ${4}    ${2}    ${1}    ${1}

    verify_fdm_dmrs     ${FolderName}/output_dl_formated.csv   dlFdSchedData    ${chk_attrs}
     ...                 ${UE_crnti_list[${2}]}[${0}]  ${2}    ${1}    ${20}    ${0}

Very FDM DMRS IWK with CB008246 in DL after online modify
    [Arguments]   ${FolderName}    ${UE_crnti_list1}    ${UE_crnti_list2}
    ${chk_attrs}   Create List  sfn  slot  rnti  physCellId  aggregationLevel    laMode  mcsTable
    ...                         rrmDlUsedMcs   numCdmGroupNoData   numOfLayers
     #verify_fdm_dmrs(file, event, attrs,43734, 1, 1, 2, 1)
     # def verify_fdm_dmrs(file,event,attrs,rnti,rank,expected_cdm,nidd_value,hr_rnti=1):
    verify_fdm_dmrs     ${FolderName}/output_dl_formated.csv   dlFdSchedData    ${chk_attrs}
    ...                 ${UE_crnti_list1[${0}]}[${0}]  ${2}    ${1}    ${13}    ${1}

    verify_fdm_dmrs     ${FolderName}/output_dl_formated.csv   dlFdSchedData    ${chk_attrs}
    ...                 ${UE_crnti_list1[${0}]}[${1}]  ${4}    ${2}    ${1}    ${0}

    verify_fdm_dmrs     ${FolderName}/output_dl_formated.csv   dlFdSchedData    ${chk_attrs}
    ...                 ${UE_crnti_list1[${1}]}[${0}]  ${4}    ${2}    ${1}    ${1}

    verify_fdm_dmrs     ${FolderName}/output_dl_formated.csv   dlFdSchedData    ${chk_attrs}
     ...                 ${UE_crnti_list1[${2}]}[${0}]  ${2}    ${1}    ${20}    ${0}

    verify_fdm_dmrs     ${FolderName}/output_dl_formated.csv   dlFdSchedData    ${chk_attrs}
    ...                 ${UE_crnti_list2[${0}]}[${0}]  ${2}    ${1}    ${5}    ${1}

    verify_fdm_dmrs     ${FolderName}/output_dl_formated.csv   dlFdSchedData    ${chk_attrs}
    ...                 ${UE_crnti_list2[${0}]}[${1}]  ${4}    ${2}    ${1}    ${0}

    verify_fdm_dmrs     ${FolderName}/output_dl_formated.csv   dlFdSchedData    ${chk_attrs}
    ...                 ${UE_crnti_list2[${1}]}[${0}]  ${4}    ${2}    ${1}    ${1}

    verify_fdm_dmrs     ${FolderName}/output_dl_formated.csv   dlFdSchedData    ${chk_attrs}
     ...                 ${UE_crnti_list2[${2}]}[${0}]  ${2}    ${1}    ${12}    ${0}

Very FDM DMRS IWK with CB008246 in UL
    [Arguments]   ${FolderName}    ${UE_crnti_list}
    ${chk_attrs}   Create List  sfn  slot  rnti  physCellId  aggregationLevel    laMode  mcsTable
    ...                         rrmUlUsedMcs   numCdmGroupNoData   numOfLayers
     #verify_fdm_dmrs(file, event, attrs,43734, 1, 1, 2, 1)
     # def verify_fdm_dmrs(file,event,attrs,rnti,rank,expected_cdm,nidd_value,hr_rnti=1):
    verify_fdm_dmrs     ${FolderName}/output_ul_formated.csv   ulFdSchedData    ${chk_attrs}
    ...                 ${UE_crnti_list[${0}]}[${0}]  ${1}    ${1}    ${13}    ${1}

    verify_fdm_dmrs     ${FolderName}/output_ul_formated.csv   ulFdSchedData    ${chk_attrs}
     ...                 ${UE_crnti_list[${2}]}[${0}]  ${1}    ${1}    ${20}    ${0}

Very FDM DMRS IWK with CB008246 in UL after online modify
    [Arguments]   ${FolderName}    ${UE_crnti_list1}    ${UE_crnti_list2}
    ${chk_attrs}   Create List  sfn  slot  rnti  physCellId  aggregationLevel    laMode  mcsTable
    ...                         rrmUlUsedMcs   numCdmGroupNoData   numOfLayers
     #verify_fdm_dmrs(file, event, attrs,43734, 1, 1, 2, 1)
     # def verify_fdm_dmrs(file,event,attrs,rnti,rank,expected_cdm,nidd_value,hr_rnti=1):
    verify_fdm_dmrs     ${FolderName}/output_ul_formated.csv   ulFdSchedData    ${chk_attrs}
    ...                 ${UE_crnti_list1[${0}]}[${0}]  ${1}    ${1}    ${13}    ${1}

    verify_fdm_dmrs     ${FolderName}/output_ul_formated.csv   ulFdSchedData    ${chk_attrs}
     ...                 ${UE_crnti_list1[${2}]}[${0}]  ${1}    ${1}    ${20}    ${0}

    verify_fdm_dmrs     ${FolderName}/output_ul_formated.csv   ulFdSchedData    ${chk_attrs}
    ...                 ${UE_crnti_list2[${0}]}[${0}]  ${1}    ${1}    ${5}    ${1}

    verify_fdm_dmrs     ${FolderName}/output_ul_formated.csv   ulFdSchedData    ${chk_attrs}
     ...                 ${UE_crnti_list2[${2}]}[${0}]  ${1}    ${1}    ${12}    ${0}
