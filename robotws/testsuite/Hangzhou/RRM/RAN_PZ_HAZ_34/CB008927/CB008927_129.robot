*** Settings ***
Documentation    author: Deng Xueqin
...              Group: RAN_PZ_HAZ3_SG02
...              contact: xueqin.deng@nokia-sbell.com

Resource          Resources/common_keyword.robot

Suite Setup    CB008927_Suite_Setup
Suite Teardown    CB008927_Suite_Teardown

*** Test Cases ***
[1][1.0] CB008927-G_16_check cell-edge UEs TP with NBR and DL RAT 1 activated with VoNR GBR and non-GBR
    [Setup]    case_common_setup
    ${ue1_ch}    Create List    1    5    9    13
    set test variable    ${ue1_ch}
	${nongbr_ue}    Create List    0
    ${gbr_ue}    Create List    1
	${allues}    Create List    7    1    0
	&{nongbr_ue_tput}    Create Dictionary    0=360MKbits/sec
    &{gbr_ue_tput}    Create Dictionary    1=40MKbits/sec
    &{gbr_ue_exp}    Create Dictionary    1=18
    MultiUE Prepare    ue_list=${allues}
    sleep    20s
    MultiUE Attach    ue_list=${allues}
    sleep    5s
    set_haojin_pa    ch_list=${ue1_ch}    value=80
    sleep    5s
    MultiUE Start dl traffic    ue_list=${nongbr_ue}    apn=${apn0}    ues_tput=${nongbr_ue_tput}
    sleep    10s
    log to console    "Start GBR Traffic"
    MultiUE Start GBR dl traffic    ue_list=${gbr_ue}    ues_tput=${gbr_ue_tput}
    sleep    10s
    Perform and Check Vonr Call    mo_ueindex=0    mt_ueindex=7
    sleep    10s
	MultiUE Check throughput    ue_list=${gbr_ue}    ues_exp=${gbr_ue_exp}
    ${nongbr_ue_tput_nbr_on}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m    ue_index=0
	MultiUE Stop dl traffic    ue_list=${nongbr_ue}    apn=${apn0}
	MultiUE Stop GBR dl traffic    ue_list=${gbr_ue}
	modify actNbrForNonGbrBearers    attr_value=false
	log to console    disable NBR and check l3 call
    MultiUE Detach    ue_list=${allues}
    sleep    5s
    MultiUE Attach    ue_list=${allues}
    sleep    5s
    MultiUE Start dl traffic    ue_list=${nongbr_ue}    apn=${apn0}    ues_tput=${nongbr_ue_tput}
    sleep    10s
    log to console    "Start GBR Traffic"
    MultiUE Start GBR dl traffic    ue_list=${gbr_ue}    ues_tput=${gbr_ue_tput}
    sleep    10s
    Perform and Check Vonr Call    mo_ueindex=0    mt_ueindex=7
    sleep    10s
	MultiUE Check throughput    ue_list=${gbr_ue}    ues_exp=${gbr_ue_exp}
    ${nongbr_ue_tput_nbr_off}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m    ue_index=0
    log to console    	nongbr ue tput with nbr on: ${nongbr_ue_tput_nbr_on}, nbr off: ${nongbr_ue_tput_nbr_off}
    should be true    ${nongbr_ue_tput_nbr_on}[1]>${nongbr_ue_tput_nbr_off}[1]
    [Teardown]    run keywords    MultiUE Stop dl traffic    ue_list=${nongbr_ue}    apn=${apn0}
    ...    AND    MultiUE Stop GBR dl traffic    ue_list=${gbr_ue}
    ...    AND    set_haojin_pa    ch_list=${ue1_ch}    value=30
    ...    AND    case_common_teardown

[1][1.0] CB008927-G_26_check CA activation and deactivation with intra-band CA SCell selection FDD RAT0- FDD RAT1 on SA
    [Setup]    case_common_setup
    update_scf    scfpath=${g26_scf}
    sleep    120s
    ${ue_list}    Create List    7    0
    set test variable    ${ue_list}
    &{ues_tput}    Create Dictionary    0=200MKbits/sec    7=200MKbits/sec
    ${dltput_exp_pcell_scell}    Create List    90    60
    &{ues_exp}    Create Dictionary    0=${dltput_exp_pcell_scell}    7=${dltput_exp_pcell_scell}
    MultiUE Prepare    ue_list=${ue_list}
    sleep    10s
    MultiUE Attach    ue_list=${ue_list}
    sleep    10s
    MultiUE Start dl traffic    ue_list=${ue_list}    apn=${apn0}    ues_tput=${ues_tput}
    sleep    180s
    ${dltput}    MultiUE Get dl tput on spark with 2CC CA    ue_list=${ue_list}
    MultiUE Check dl tput with 2CC CA    ue_list=${ue_list}    dltput=${dltput}    ues_exp=${ues_exp}
    [Teardown]    run keywords    MultiUE Stop dl traffic    ue_list=${ue_list}    apn=${apn0}
    ...    AND    case_common_teardown

[1][1.0] CB008927-G_30_check configured RG quotas convergence with Dynamic slice-aware scheduler and DL RAT1 activated on CA and VoNR in SA
    [Setup]    case_common_setup
    g30_configuration_prepare
    sleep   30s
    ${ue_list}    Create List    7    0
    set test variable    ${ue_list}
    &{ues_tput}    Create Dictionary    0=240MKbits/sec    7=120MKbits/sec
    ${dltput_exp_pcell_scell_1}    Create List    100    80
	${dltput_exp_pcell_scell_2}    Create List    50    40
    &{ues_exp}    Create Dictionary    0=${dltput_exp_pcell_scell_1}    7=${dltput_exp_pcell_scell_2}
    MultiUE Prepare    ue_list=${ue_list}
    sleep    20s
    MultiUE Attach    ue_list=${ue_list}
    sleep    10s
    Perform and Check Vonr Call    mo_ueindex=0    mt_ueindex=7
    sleep    10s
    MultiUE Start dl traffic    ue_list=${ue_list}    apn=${apn0}    ues_tput=${ues_tput}
    sleep    180s
    ${dltput}    MultiUE Get dl tput on spark with 2CC CA    ue_list=${ue_list}
    MultiUE Check dl tput with 2CC CA    ue_list=${ue_list}    dltput=${dltput}    ues_exp=${ues_exp}
    [Teardown]    run keywords    MultiUE Stop dl traffic    ue_list=${ue_list}    apn=${apn0}
    ...    AND    case_common_teardown

[1][1.0] CB008927-G_19_check PRB slice-aware admission control respect with Dynamic slice-aware scheduler and DL RAT 1 activated with GBR traffic
    [Setup]    case_common_setup
	update_scf    scfpath=${g19_scf}
	sleep    120s
	${ue_list}    Create List    7    0
    set test variable    ${ue_list}
	${ue_GBR_list}    Create List    1
	&{ues_tput}    Create Dictionary    0=200MKbits/sec    7=200MKbits/sec
	${ues_gbr_tput}    Create Dictionary    1=30MKbits/sec
    &{ues_exp}    Create Dictionary    0=70    7=175
	&{ues_gbr_exp}    Create Dictionary    1=30MKbits/sec
    MultiUE Prepare    ue_list=${ue_list}
    sleep    10s
    MultiUE Attach    ue_list=${ue_list}
    sleep    5s
	MultiUE Start dl traffic    ue_list=${ue_list}    apn=${apn0}    ues_tput=${ues_tput}
    MultiUE Check throughput    ue_list=${ue_list}    ues_exp=${ues_exp}
    log to console    "Start GBR Traffic"
    MultiUE Prepare    ue_list=${ue_GBR_list}
    sleep    10s
    MultiUE Attach    ue_list=${ue_GBR_list}
    sleep    5s
	MultiUE Start GBR dl traffic    ue_list=${ue_GBR_list}    apn=${apn_mdrb_nokia}    ues_tput=${ues_gbr_tput}
    #MultiUE Check throughput    ue_list=${ue_GBR_list}    ues_exp=${ues_gbr_exp}
	MultiUE Check throughput    ue_list=${ue_list}    ues_exp=${ues_exp}
    sleep    10s
    [Teardown]    run keywords    MultiUE Stop dl traffic    ue_list=${ue_list}    apn=${apn0}
    ...    AND    UE Stop dl traffic    ue_index=1    apn=${apn_mdrb_nokia}
    ...    AND    case_common_teardown

[1][1.0] CB008927-G_11_check GBR addition rejected with Dynamic slice-aware scheduler and DL RAT 1 activated with GBR services
    [Setup]    case_common_setup
    update_scf    scfpath=${g11_scf}
	sleep    120s
	${ue_GBR_list}    Create List    1
	${ues_gbr_tput}    Create Dictionary    1=30MKbits/sec
	Start_BTS_Logs
    MultiUE Prepare    ue_list=${ue_GBR_list}
    sleep    10s
    MultiUE Attach    ue_list=${ue_GBR_list}
	MultiUE Start dl traffic    ue_list=${ue_GBR_list}    apn=${apn_mdrb_nokia}    ues_tput=${ues_gbr_tput}
	${ue_list_2}    Create List    0
    MultiUE Prepare    ue_list=${ue_list_2}
    sleep    10s
    MultiUE Attach    ue_list=${ue_list_2}
	Stop_BTS_Logs
    Check_GBR_Addition_Rejected_from_BTSLOG
	[Teardown]    run keywords    UE Stop dl traffic    ue_index=1   apn=${apn_mdrb_nokia}
    ...    AND    case_common_teardown


