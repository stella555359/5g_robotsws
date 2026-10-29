# *** Settings ***
# Documentation     author: Cai Wenjuan
# ...               contact: wenjuan.cai@nokia-sbell.com
# ...               squad group: SG_01
# ...               feature : 5GC007326-1008
# Suite Setup       Setup 1008 case suite
# Suite Teardown    Teardown Suite For 1008
# Force Tags        
# ...    PY36
# Resource        ../5GC001008/Resources/5GC001008_Resources.robot
# #Resource        ../5GC001008/Resources/5GC001008_FDD_Resources.robot
# 
# *** Test Cases ***
# [1][2.0] 5GC001008_PC_7_CellBarred alarm raised after lock the enabled slice
#     [Documentation]
#     ...    Step1: gNB configured with Two cell in different tac
#     ...    Step2: tac1 configured: snssai-1：sst=1, sd=13714341, tac2 configured: snssai-2：sst=128, sd=1, both of them are supported by AMF
#     ...    Step3: start tcpdump in cpif port
#     ...    Step4: lock snssai1
#     ...    Step5: check alram and pcap
#     [Tags]     CRT_TRUNK    CRT_22R1
#     [Setup]    Setup Case
#     [Teardown]    Teardown 1008 case
#     TC.5GC001008_PC_7_CellBarred alarm raised after lock the enabled slice
# 
# [1][1.0] 5GC001008_PC_8_CellBarred alarm cleared after unlock the slice supported by AMF
#     [Documentation]    Main test Steps:
#     ...   Step1: configure gnb in 2cell SA mode: TAC1: locked snssai-1：sst=128，sd=1; TAC2: unlocked snssai-1：sst=1, sd=13714341;
#     ...   Step2: check slice operational status via webui
#     ...   Step3: unlock snssai-1 via webui
#     ...   Step4: alarm "7105:EFaultId_AllCellsOfTacBarredDueSlicingCriteriaAl" should not exist
#     ...   Step5: check slice operational status via webui
#     [Tags]
#     [Setup]    Setup Case
#     [Teardown]    Teardown 1008 case
#     TC.5GC001008_PC_8_CellBarred alarm cleared after unlock the slice supported by AMF
# 
# [1][1.0] 5GC001008_PC_10_Unsucessful SNSSAI modification before lock the SNSSAI
#     [Documentation]    it's a unsuccessful case that customer cannot change the value of network slice before lock it.
#     ...   Step1: gNB configured with TAC1, at least one slice(slice-X) in TAC1
#     ...   Step2: modify sst and sd of slice-X
#     ...   Step3: plan validation from WebUI. it will be reject with "not allowed to modify slice(s) which is unlocked"
#     ...   Step4: check the value and status of snssai-X, it not changed
#     [Tags]
#     [Setup]    Setup Case
#     [Teardown]    Teardown 1008 case
#     TC.5GC001008_PC_10_Unsucessful SNSSAI modification before lock the SNSSAI
# 
# [1][1.0] 5GC001008_PD_10_Verify MEAS_PERIOD_NR_PDCP_SLICE when gNB configured with sst=1 sd=null and AMF configured with sst=1 sd = 0xffffff
#     [Documentation]
#     ...   Step1: gNB configured with sst=1 sd=null and AMF configured with sst=1 sd = 0xffffff
#     ...   Step2: check counter MEAS_PERIOD_NR_PDCP_SLICE, it should be increase 1 per second
#     [Tags]
#     [Setup]    Setup Case
#     [Teardown]    Teardown 1008 case
#     TC.5GC001008_PD_10_Verify MEAS_PERIOD_NR_PDCP_SLICE when gNB configured with sst=1 sd=null and AMF configured with sst=1 sd = 0xffffff
# 
# [1][1.0] 5GC001008_EA_6_Unable to online delete SNSSAI that in enabled state
#     [Documentation]  enabled slice cannot be deleted in an existing TAC
#     ...   Step1: gNB configured multipul slice, at leat one of them (slice-X)is in enabled state
#     ...   Step2: operator try to deletes slice-X from the list of configured SNSSAIs of TAC
#     ...   Step3: validate reject with feedback "not allowed to delete slice(s) which is/are in state operational state enabled"
#     [Tags]
#     [Setup]    Setup Case
#     [Teardown]    Teardown 1008 case
#     TC.5GC001008_EA_6_Unable to online delete SNSSAI that in enabled state
# 
# [1][1.0] 5GC001008_EA_8_Unable to delete the last SNSSAI of TAC
#     [Documentation]  when a TAC has only one SNSSAI, customer cannot delete it
#     ...   Step1: gNB is only configured one slice-X: sst = 128, sd = 1. and it's in enabled status
#     ...   Step2: delete slice-X, PDL validation will fail, error raised: at least one slice need to be configured per TAC
#     ...   Step3: check the statu of slice-X, it should be enabled
#     [Tags]
#     [Setup]    Setup Case
#     [Teardown]    Teardown 1008 case
#     TC.5GC001008_EA_8_Unable to delete the last SNSSAI of TAC
# 
# [1][1.0] 5GC001008_EA_10_cell change from barred to unbarred after a new snssai addion in TAC which is supported by AMF
#     [Documentation]  cell barred alarm will dispired after online addition a slice, and this slice is supported by AMF
#     ...   Step1: gNB configured with two cells, two TACs. slice in TAC1 has no slice in enabled status, slice in TAC2
#     ...          has at least one in common with AMF
#     ...   Step2: check cell status of TAC1, it should be barred
#     ...   Step3: online add slice-X into TAC1. slice-X is unlocked and supported by AMF
#     ...   Step4: check cell status of TAC2, it should be change to unbarred status
#     [Tags]
#     [Setup]    Setup Case
#     [Teardown]    Teardown 1008 case
#     TC.5GC001008_EA_10_cell change from barred to unbarred after a new snssai addion in TAC which is supported by AMF
# 
# [1][1.0] 5GC001008_PD_11_Verify NUMBER_OF_SA_SLICE_USERS and SA_NGBR_DRB_CU_SUCC_SLICE in PDU session setup procedure
#     [Documentation]    To verify slice users related counter when UE attach to gNB
#     ...   Step1: gNB configured with slice-X
#     ...   Step2: trigger UE attach and PDU session establish done
#     ...   Step3: check counter NUMBER_OF_SA_SLICE_USERS and SA_NGBR_DRB_CU_SUCC_SLICE, they will be increased 1 for slice-X
#     [Tags]
#     [Setup]    Setup Case
#     [Teardown]    Teardown 1008 case
#     TC.5GC001008_PD_11_Verify NUMBER_OF_SA_SLICE_USERS and SA_NGBR_DRB_CU_SUCC_SLICE in PDU session setup procedure
# 
# [1][1.0] 5GC001008_K_1_Successful initial context setup with one PDU session in L3Call
#     [Documentation]    To verify UE's PDU session use the correctly slice type
#     ...   Step1: gNB configured with slice-X
#     ...   Step2: trigger UE attach and PDU session establish done
#     ...   Step3: check counter NUMBER_OF_SA_SLICE_USERS and SA_NGBR_DRB_CU_SUCC_SLICE, they will be increased 1 for slice-X
#     [Tags]     CIT_TRUNK
#     [Setup]    Setup Case
#     [Teardown]    Teardown 1008 case
#     TC.5GC001008_K_1_Successful initial context setup with one PDU session in L3Call
# 
# [1][1.0] 5GC001008_E_11_Successful snssai modification in an existing TAC
#     [Documentation]    To verify operators can online modify the value of snssai
#     ...   Step1: gNB configured at least two SNSSAI
#     ...   Step2: lock one of them, slice-X
#     ...   Step3: change slice-X to slice-Y, for example sst:128 sd:1 to sst:255 sd:1
#     ...   Step4: Validate and active
#     ...   Step5: unlock slice-Y
#     ...   Step6: check the operationalState of slice-Y, it should be enabled
#     [Tags]
#     [Setup]    Setup Case
#     [Teardown]    Teardown 1008 case
#     TC.5GC001008_E_11_Successful snssai modification in an existing TAC