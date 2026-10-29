*** Settings ***
Documentation
...     author:                Chaithnya
...     maintainer:            Chaithnya
...     conatact maintainer:   chaithanya.h_s@nokia.com
...     Feature:               CB009567

Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource            resource/9567_resource.robot

Suite Setup         Run keywords  Test Suite Setup
...                 AND           AIC Software Build Info
...                 AND           Fetch Taf Library used in TL
...                 AND           Log to console    vDU delta commissioning
...                 AND           Fast Delta Commission vDU With Delta XML File      ${delta_vdu}
...                 AND           Run keyword and Ignore error   Verify RMODs Online Status   ${800}
...                 AND           log to console   loading cfg file....
...                 AND           Configure UTE ETH3 IPs
...                 AND           Start WTS Using WTS_Runner      ${wts_cfg_file}


Suite Teardown         Run keywords        Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}    ${CURDIR}/config/basic_setup_2cell_working_scf_SANSA_TDD_8DL4UL.cfg
${delta_vdu}     ${CURDIR}/config/SBTS23R4/Delta_configuration_vDU_9567_2cell_TDD.xml
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}    1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${Trf_rate_SA}  mbps
${scell_id}   0
${START_UE_SA_cell1}   1
${END_UE_SA_cell1}     1
${START_UE_SA_cell2}   2
${END_UE_SA_cell2}     2
${START_UE_NSA_cell1}   11
${END_UE_NSA_cell1}     11
${START_UE_NSA_cell2}   12
${END_UE_NSA_cell2}     12
${Trgt_cell_NSA_cell1}   1
${Trgt_cell_NSA_cell2}   2
${DL_RATE}   100
${UL_RATE}   100
${DL_RATE_NSA}  100
${UL_RATE_NSA}  60
${start_DL_trfids}  1
${end_DL_trfids}    14
${NSA_start_DL_trfids}  1
${NSA_end_DL_trfids}    8
${Trf_rate_NSA}  mbps

@{Queuegroup1_core_to_evo_mapping}  Queue Group L2RtPool0_Group_DlFd1Sched created on core 3
...  Queue Group L2RtPool0_Group_PatternCfg created on core 3
...  Queue Group L2RtPool0_Group_UlSch created on core 4  Queue Group L2RtPool0_Group_SrsBm created on core 4

@{Queuegroup2_core_to_evo_mapping}  Queue Group L2RtPool0_Group_DlFd2Sched created on core 4
...  Queue Group L2RtPool0_Group_PatternCfg2 created on core 4
...  Queue Group L2RtPool0_Group_Ul2Sch created on core 3  Queue Group L2RtPool0_Group_SrsBm2 created on core 3

*** Test Cases ***
[1][1.0] CB009567_C1_To_Verify_SA_L3_call_on_2TDD_cells_per_RINLINE1_with_100MHz_bandwidth_with_8DL_4UL_streams_for_D-RAN
    [setup]  Testcase Setup
    Stop and Collect Syslog Monitoring
    Queuegroup1 2L2PS Cores to evos mapped Deployment should be Successful
    Queuegroup2 2L2PS Cores to evos mapped Deployment should be Successful
    sleep  2s
    log to console   ue registration is trigerring now...
    Multiple UEs SA L3 should be successful for Cell1
    Multiple UEs SA L3 should be successful for Cell2
    Sleep  20s
    MultiUE Deregister should be Successful    1   2
    Multiple UEs NSA L3 should be successful for Cell1
    Multiple UEs NSA L3 should be successful for Cell2


*** Keywords ***
Multiple UEs SA L3 should be successful for Cell1
    Multiple UEs SA L3 should be successful  ${START_UE_SA_cell1}  ${END_UE_SA_cell1}  ${DL_RATE}  ${UL_RATE}  ${start_DL_trfids}
    ...  ${end_DL_trfids}  ${Pdu_session_ID}  ${QFI_ID}  ${Trf_rate_SA}  ${scell_id}
Multiple UEs SA L3 should be successful for Cell2
    Multiple UEs SA L3 should be successful  ${START_UE_SA_cell2}  ${END_UE_SA_cell2}  ${DL_RATE}  ${UL_RATE}  ${start_DL_trfids}
    ...  ${end_DL_trfids}  ${Pdu_session_ID}  ${QFI_ID}  ${Trf_rate_SA}  ${scell_id}

Multiple UEs NSA L3 should be successful for Cell1
    Multiple UEs NSA L3 should be successful  ${START_UE_NSA_cell1}  ${END_UE_NSA_cell1}  ${Trgt_cell_NSA_cell1}  ${DL_RATE_NSA}  ${UL_RATE_NSA}
    ...    ${Trf_rate_NSA}   ${NSA_start_DL_trfids}  ${NSA_end_DL_trfids}
Multiple UEs NSA L3 should be successful for Cell2
    Multiple UEs NSA L3 should be successful  ${START_UE_NSA_cell2}  ${END_UE_NSA_cell2}  ${Trgt_cell_NSA_cell2}  ${DL_RATE_NSA}  ${UL_RATE_NSA}
    ...    ${Trf_rate_NSA}   ${NSA_start_DL_trfids}  ${NSA_end_DL_trfids}


Queuegroup1 2L2PS Cores to evos mapped Deployment should be Successful
    Check Parameter in syslog  @{Queuegroup1_core_to_evo_mapping}

Queuegroup2 2L2PS Cores to evos mapped Deployment should be Successful
    Check Parameter in syslog  @{Queuegroup2_core_to_evo_mapping}








