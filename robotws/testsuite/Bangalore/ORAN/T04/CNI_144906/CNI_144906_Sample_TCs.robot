*** Settings ***
Documentation
...   author: Sudarshan Kanapuram
...   contact: sudarshan.kanapuram@nokia.com
...   Description: CNI144906_O-RAN specific software management testing improvements in CRT for SR deployments
...                :Precondition of testbed: Current code is not implemented for DualCore, additional Netconf account.
...                :Please keep all SCF, swconfig and O-RU related builds(related to source Build) in mentioned paths.
...                :Update all variables correctly as per testline usage, remaining script is generalised.
...                :KW: RU_SW_upgrade_ODU_SW_upgrade for scenario1 in FTS of CNI144906
...                :KW: ODU_SW_upgrade_RU_SW_upgrade for scenario2 in FTS of CNI144906
...                :KW: RU_SW_upgrade_NoACT_ODU_SW_upgrade for scenario3 in FTS of CNI144906
...                :Do not delete any of the variables in this test suite, when you are creating separate suite.

Resource    ./testsuite/Bangalore/ORAN/resources/robot/ORAN_SW_management_testing_SR.robot

*** Variables ***

#BTSRelatedParameters
${bts_id}=                xxx
${Source_build_Id}=                SBTS25R3_ENB_0000_000507_000000
${Target_build_Id}=                	SBTS00_ENB_9999_250911_000008
${Src_Scfpath}=                /home/ute/SCF/SCF_25R3.xml
### RFM plug in name to be used in path:/home/ute/<source release, ex:SBTS25R3>
${FJRFM_plugIn}=                RFMPlugin_O-RU_FJ_TA08029-B311-01_0004.zip

${clab_netact}=    		srnclab1042
${fm_cm_itsmwas_hostIp}=   	10.43.48.16
${node_Username_fmwas}=	        omc
${node_password_fmwas}=         Medsql!_1893
${NETACT_NAME}=                 netact


@{udpcalltype}    UDP
@{throughput_dl_udp}    300
@{throughput_ul_udp}    100
@{deviation_dl}    90
@{deviation_ul}    90
@{capabilities}    Legacy_3
@{UE_alias}    UE3
@{direction_ul}    ul
@{direction_dl}    dl
@{data_transfer_protocol}    udp
@{timeout}    100


${Is_L3_call_test_required}=                False

${counter_nos_01}	M55306C00001,M55306C00002,M55306C00003,M55306C00004,M55306C03001,M55306C06001,M55306C06002
${counters_list}	M55306C00001,M55306C00002,M55306C00003,M55306C00004,M55306C03001,M55306C06001,M55306C06002
${counters_val_min}    0
${counters_val_max}    380
${NR_CELL_id}         0



*** Test Cases ***
RU_SW_upgrade_ODU_SW_upgrade_test1
    [Tags]    CNI144906_1    QCD_MN_RAN    QCP_RAN_VRF
    Log to console   --\n Suite check started \n--
    RU_SW_upgrade_ODU_SW_upgrade    ${bts_id}    ${Source_build_Id}    ${Target_build_Id}    ${Src_Scfpath}    ${FJRFM_plugIn}
    ...    ${Is_L3_call_test_required}
	Run Keyword And Ignore Error    admin.teardown_all_aliases_for_admin
RU_SW_upgrade_ODU_SW_upgrade_test2
    [Tags]    CNI144906_2    QCD_MN_RAN    QCP_RAN_VRF
    Log to console   --\n Suite check started \n--
    ODU_SW_upgrade_RU_SW_upgrade    ${bts_id}    ${Source_build_Id}    ${Target_build_Id}    ${Src_Scfpath}    ${FJRFM_plugIn}
    ...    ${Is_L3_call_test_required}
    Run Keyword And Ignore Error    admin.teardown_all_aliases_for_admin

RU_SW_upgrade_ODU_SW_upgrade_test3
    [Tags]    CNI144906_3    QCD_MN_RAN    QCP_RAN_VRF
    Log to console   --\n Suite check started \n--
    RU_SW_upgrade_NoACT_ODU_SW_upgrade    ${bts_id}    ${Source_build_Id}    ${Target_build_Id}    ${Src_Scfpath}    ${FJRFM_plugIn}
    ...    ${Is_L3_call_test_required}
    Run Keyword And Ignore Error    admin.teardown_all_aliases_for_admin
