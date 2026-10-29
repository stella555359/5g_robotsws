*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs 
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  RAN_5G_FDD  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-SG2
...  owner-dan.liu  release-19A
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SWCONFIG}    ${rdForceUeCapaCsiReportWithoutPmi}=0    
${rdForceUeCapaCsiReportWithoutPmi}    0x59006a
#0x59006a--rdForceUeCapaCsiReportWithoutPmi  0 : use UE capa , 1 : force supported, 2 : force not supported [default]

${csi-ReportWithoutPMI}    SEPARATOR=
...    E5A00000074E5A031E000380A03C1268C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E1DE3
...    8720C38002064F1F570004F001C0013C002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001
...    C0013C002A3626EB04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012C
...    B2898087AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D0301C020227B058060005038080E0
...    600B00E000D040080000007C0000000000001CA9A0002000012CB2A00695550103800580000002004008C589800081018202
...    83038405880889098C909293139425 

${no_csi-ReportWithoutPMI}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E
...    1DE38720C38002064F1F570004F001C0013C002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F57
...    0004F001C0013C002A3626EB04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A3627
...    6B04050D012CB2898087AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D0301C020227B0
...    58060005038080E0600B00E000D07C0000000000001CA9A0002000012CB2A00695550103800580000002004008C58980
...    008101820283038405880889098C909293139425

*** Test Cases ***
5GC000752_EDA165_PR578834_Verify_PDSCHMIMOlayer_is_0
    [Documentation]
    ...    1. The purpose to verify 5GC000752_EDA, set pdschmimolayer is 0,verify ue capa no_withoutpmi and withoupmi support.
    ...    2. Test Case Step:
    ...        a, UE-1 and UE-2 attach success 
    ...        b, check ue1,ue2 CSI-ReportConfig.reportQuantity  is 1 or 4 by ue capability.

    [Tags]    QC_81269
    SA UE Attach and check   1
    SA UE Attach and check   2
    Check Wireshark Log    ${CURDIR}${/}a2a_752rd0${/}a2a_rd0.ini    wait_string=UEContextModificationResponse::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
  Update Cfg  ue_param id=1 ue_nr_capabilities=${csi-ReportWithoutPMI} 
  Update Cfg  ue_param id=2 ue_nr_capabilities=${no_csi-ReportWithoutPMI}  

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_register id=${ue_id}    is now Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    Initial Context Setup Successful

SA UE Deregister From GNB
    [Arguments]  ${ue_id}=1
    Execute Egate Command  ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached

SA UE Attach and check
    [Arguments]    ${ue_id}=1
    SA UE attach    ue_id=${ue_id}
    traffic should be ok    ue_id=${ue_id}    type=SA
    [Teardown]    SA UE Deregister From GNB    ue_id=${ue_id}
