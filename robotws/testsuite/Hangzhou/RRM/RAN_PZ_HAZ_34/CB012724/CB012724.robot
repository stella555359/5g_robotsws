*** Settings ***
Documentation    author: xudeng
...              Group: RAN_PZ_HAZ3_SG02
...              contact: xueqin.deng@nokia-sbell.com

Resource          Resources/common_keyword.robot

Suite Setup    CB012724_Suite_Setup
Suite Teardown    CB012724_Suite_Teardown

*** Test Cases ***
[1]CB012724_A_1_HARQ_statistics_for_SRB_SA_intragnb_HO_initialtrans
    [Setup]    case_common_setup
	${counter_id_list}    create list    M55393C00001    M55393C00002    M55393C00003    M55393C00004    M55393C00005    M55393C00006
    update_scf    scfpath=${12724_A_scf}
    sleep    180s
    ${SRB_counters_dict_src}    COAM get pm counters dict via admin    counter_id_list=${counter_id_list}
	${start_time}    Get counter latest update time from dict
    ...    counters_dict=${SRB_counters_dict_src}    BTS_or_TRS=BTS    full_path=${M55393C00001_full_path}
    set suite variable    ${start_time}
	${ue_prach_list}    Create List    1
    MultiUE Prepare    ue_list=${ue_prach_list}
	MultiUE Attach    ue_list=${ue_prach_list}
    sleep    12min
    ${SRB_counters_dict}    COAM get pm counters dict via admin    counter_id_list=${counter_id_list}
	set suite variable    ${SRB_counters_dict}
	${M55393C00001_values}    Get counter values after start time from dict
    ...    counters_dict=${SRB_counters_dict}    BTS_or_TRS=BTS    full_path=${M55393C00001_full_path}    start_time=${start_time}
	${M55393C00002_values}    Get counter values after start time from dict
    ...    counters_dict=${SRB_counters_dict}    BTS_or_TRS=BTS    full_path=${M55393C00002_full_path}    start_time=${start_time}
	${M55393C00003_values}    Get counter values after start time from dict
    ...    counters_dict=${SRB_counters_dict}    BTS_or_TRS=BTS    full_path=${M55393C00003_full_path}    start_time=${start_time}
	${initialtrans_counters_values}    Combine Lists    ${M55393C00001_values}    ${M55393C00002_values}    ${M55393C00003_values}
    ${sum_initialtrans_counters}    get_counters_values_sum    counters_values=${initialtrans_counters_values}
	should be true    ${sum_initialtrans_counters}>0    initialtrans counters are not update.
    [Teardown]    case_common_teardown

[1]CB012724_A_2_HARQ_statistics_for_SRB_SA_intragnb_HO_finaltrans
    [Setup]    case_common_setup
	${M55393C00004_values}    Get counter values after start time from dict
    ...    counters_dict=${SRB_counters_dict}    BTS_or_TRS=BTS    full_path=${M55393C00004_full_path}    start_time=${start_time}
	${M55393C00005_values}    Get counter values after start time from dict
    ...    counters_dict=${SRB_counters_dict}    BTS_or_TRS=BTS    full_path=${M55393C00005_full_path}    start_time=${start_time}
	${M55393C00006_values}    Get counter values after start time from dict
    ...    counters_dict=${SRB_counters_dict}    BTS_or_TRS=BTS    full_path=${M55393C00006_full_path}    start_time=${start_time}
	${finaltrans_counters_values}    Combine Lists    ${M55393C00004_values}    ${M55393C00005_values}    ${M55393C00006_values}
    ${sum_finaltrans_counters}    get_counters_values_sum    counters_values=${finaltrans_counters_values}
	should be true    ${sum_finaltrans_counters}>0    finaltrans counters are not update.
    [Teardown]    case_common_teardown

[1]CB012724_C_5_PDSCH_allocation_failure_PDSCH_ALLOC_ATT_REJ_PRB_RAT1
    [Setup]    case_common_setup
    update_scf    scfpath=${12724_C_scf}
    sleep    180s
    ${ue_list}    Create List    1    3
    &{ues_dltput}    Create Dictionary    1=1600MKbits/sec    3=0MKbits/sec
    &{ues_ultput}    Create Dictionary    1=100MKbits/sec    3=100MKbits/sec
    MultiUE Prepare    ue_list=${ue_list}
	MultiUE Attach    ue_list=${ue_list}
    MultiUE Start dlul traffic    ue_list=${ue_list}    apn=${apn0}    ues_dltput=${ues_dltput}
    ...    ues_ultput=${ues_ultput}
    Wait Until Next Counter Update
    ${counter_id_list}    create list    M55308C00150    M55308C00151    M55308C00152    M55308C00153    M55308C00154
    ...    M55308C00156    M55308C00157    M55308C00158    M55308C00160
    ${PxSCH_REJ_counters_dict}    COAM get pm counters dict via admin    counter_id_list=${counter_id_list}
    set suite variable    ${PxSCH_REJ_counters_dict}
    ${M55308C00150_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00150_full_path}
    ${M55308C00151_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00151_full_path}
    ${M55308C00152_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00152_full_path}
    ${M55308C00153_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00153_full_path}
    ${M55308C00154_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00154_full_path}
    ${M55308C00156_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00156_full_path}
    ${M55308C00157_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00157_full_path}
	should be true    ${M55308C00150_value}>0    PDSCH_ALLOC_ATT are not update.
	${dl_rej_values}    create list    ${M55308C00151_value}    ${M55308C00152_value}    ${M55308C00153_value}
    ...    ${M55308C00154_value}    ${M55308C00156_value}    ${M55308C00157_value}
    ${sum_dl_rej_counters}    get_counters_values_sum    counters_values=${dl_rej_values}
    should be true    ${sum_dl_rej_counters}>0    PDSCH_ALLOC_ATT_REJ_x are not update.
    [Teardown]    run keywords    MultiUE Stop traffic    ue_list=${ue_list}    apn=${apn0}    AND    case_common_teardown

[1]CB012724_C_10_PUSCH_allocation_failure_PUSCH_ALLOC_ATT_REJ_PRB
    [Setup]    case_common_setup
    ${M55308C00158_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00158_full_path}
    ${M55308C00160_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00160_full_path}
	should be true    ${M55308C00158_value}>0    PUSCH_ALLOC_ATT are not update.
    should be true    ${M55308C00160_value}>0    PUSCH_ALLOC_ATT_REJ_PRB are not update.
    [Teardown]    case_common_teardown

[1]CB012724_E_4_BIN_distribution_for_CQI_measurement_per_RANK4
    [Setup]    case_common_setup
	${counter_id_list_G}    create list    M55308C00165    M55308C00166    M55308C00169    M55308C00170
	${legacy_counter_id_list_G}    create list    M55308C10001    M55308C10003
    update_scf    scfpath=${12724_E_scf}
    sleep    180s
    ${ue_list}    Create List    1
    &{ues_dltput}    Create Dictionary    1=1600MKbits/sec
    &{ues_ultput}    Create Dictionary    1=100MKbits/sec
    MultiUE Prepare    ue_list=${ue_list}
  	MultiUE Attach    ue_list=${ue_list}
	sleep    5min
	Wait Until Next Counter Update
    ${12724_G_counters_dict_attach}    COAM get pm counters dict via admin    counter_id_list=${counter_id_list_G}
	set suite variable    ${12724_G_counters_dict_attach}
    ${legacy_counters_dict_attach}    COAM get pm counters dict via admin    counter_id_list=${legacy_counter_id_list_G}
	set suite variable    ${legacy_counters_dict_attach}
    MultiUE Start dlul traffic    ue_list=${ue_list}    apn=${apn0}    ues_dltput=${ues_dltput}
    ...    ues_ultput=${ues_ultput}
    sleep    5min
	Wait Until Next Counter Update
	${counter_id_list}    create list    M55301C00095    M55301C00094    M55301C00093    M55301C00092    M55301C00091    M55301C00090
    ${CQI_rank4_counters_dict}    COAM get pm counters dict via admin    counter_id_list=${counter_id_list}
	set suite variable    ${CQI_rank4_counters_dict}
	${M55301C00095_value}    Get counter latest value from dict
    ...    counters_dict=${CQI_rank4_counters_dict}    BTS_or_TRS=BTS    full_path=${M55301C00095_full_path}
	${M55301C00094_value}    Get counter latest value from dict
    ...    counters_dict=${CQI_rank4_counters_dict}    BTS_or_TRS=BTS    full_path=${M55301C00094_full_path}
	${M55301C00093_value}    Get counter latest value from dict
    ...    counters_dict=${CQI_rank4_counters_dict}    BTS_or_TRS=BTS    full_path=${M55301C00093_full_path}
	${M55301C00092_value}    Get counter latest value from dict
    ...    counters_dict=${CQI_rank4_counters_dict}    BTS_or_TRS=BTS    full_path=${M55301C00092_full_path}
	${M55301C00091_value}    Get counter latest value from dict
    ...    counters_dict=${CQI_rank4_counters_dict}    BTS_or_TRS=BTS    full_path=${M55301C00091_full_path}
	${M55301C00090_value}    Get counter latest value from dict
    ...    counters_dict=${CQI_rank4_counters_dict}    BTS_or_TRS=BTS    full_path=${M55301C00090_full_path}
	${initialtrans_counters_values}    create list
    ...    ${M55301C00095_value}    ${M55301C00094_value}    ${M55301C00093_value}    ${M55301C00092_value}
    ...    ${M55301C00091_value}    ${M55301C00090_value}
	${sum_initialtrans_counters}    get_counters_values_sum    counters_values=${initialtrans_counters_values}
	should be true    ${sum_initialtrans_counters}>0    initialtrans counters are not update.
    ${counter_id_list_C}    create list    M55308C00150    M55308C00151    M55308C00152    M55308C00153    M55308C00154
    ...    M55308C00156    M55308C00157    M55308C00158    M55308C00160
    ${PxSCH_REJ_counters_dict}    COAM get pm counters dict via admin    counter_id_list=${counter_id_list_C}
    set suite variable    ${PxSCH_REJ_counters_dict}
    ${M55308C00150_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00150_full_path}
    ${M55308C00151_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00151_full_path}
    ${M55308C00152_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00152_full_path}
    ${M55308C00153_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00153_full_path}
    ${M55308C00154_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00154_full_path}
    ${M55308C00156_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00156_full_path}
    ${M55308C00157_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00157_full_path}
	should be true    ${M55308C00150_value}>0    PDSCH_ALLOC_ATT are not update.
	${dl_rej_values}    create list    ${M55308C00151_value}    ${M55308C00152_value}    ${M55308C00153_value}
    ...    ${M55308C00154_value}    ${M55308C00156_value}    ${M55308C00157_value}
    ${sum_dl_rej_counters}    get_counters_values_sum    counters_values=${dl_rej_values}
    should be true    ${sum_dl_rej_counters}>0    PDSCH_ALLOC_ATT_REJ_x are not update.
    ${M55308C00158_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00158_full_path}
    ${M55308C00160_value}    Get counter latest value from dict
    ...    counters_dict=${PxSCH_REJ_counters_dict}    BTS_or_TRS=BTS    full_path=${M55308C00160_full_path}
	should be true    ${M55308C00158_value}>0    PUSCH_ALLOC_ATT are not update.
    run keyword and ignore error    should be true    ${M55308C00160_value}>0    PUSCH_ALLOC_ATT_REJ_PRB are not update.
    ${12724_G_counters_dict_traffic}    COAM get pm counters dict via admin    counter_id_list=${counter_id_list_G}
	set suite variable    ${12724_G_counters_dict_traffic}
    ${legacy_counters_dict_traffic}    COAM get pm counters dict via admin    counter_id_list=${legacy_counter_id_list_G}
	set suite variable    ${legacy_counters_dict_traffic}
    ${M55308C10001_value_attach}    Get counter latest value from dict
    ...    counters_dict=${legacy_counters_dict_attach}    BTS_or_TRS=BTS    full_path=${M55308C10001_full_path}
    ${M55308C10001_value_traffic}    Get counter latest value from dict
    ...    counters_dict=${legacy_counters_dict_traffic}    BTS_or_TRS=BTS    full_path=${M55308C10001_full_path}
	Log To Console    \n ***M55308C10001 attach: ${M55308C10001_value_attach}; M55308C10001 traffic: ${M55308C10001_value_traffic}
    ${M55308C00166_value_attach}    Get counter latest value from dict
    ...    counters_dict=${12724_G_counters_dict_attach}    BTS_or_TRS=BTS    full_path=${M55308C00166_full_path}
    ${M55308C00166_value_traffic}    Get counter latest value from dict
    ...    counters_dict=${12724_G_counters_dict_traffic}    BTS_or_TRS=BTS    full_path=${M55308C00166_full_path}
	Log To Console    \n ***M55308C00166 attach: ${M55308C00166_value_attach}; M55308C00166 traffic: ${M55308C00166_value_traffic}
    should be true    0<=${M55308C00166_value_attach}<${M55308C00166_value_traffic}<=16380000
	should be true    ${M55308C00166_value_attach}<${M55308C10001_value_attach}
    ...    and ${M55308C00166_value_traffic}<${M55308C10001_value_traffic}
    ${M55308C00169_value_attach}    Get counter latest value from dict
    ...    counters_dict=${12724_G_counters_dict_attach}    BTS_or_TRS=BTS    full_path=${M55308C00169_full_path}
    ${M55308C00169_value_traffic}    Get counter latest value from dict
    ...    counters_dict=${12724_G_counters_dict_traffic}    BTS_or_TRS=BTS    full_path=${M55308C00169_full_path}
	Log To Console    \n ***M55308C00169 attach: ${M55308C00169_value_attach}; M55308C00169 traffic: ${M55308C00169_value_traffic}
    should be true    0<${M55308C00169_value_attach}<=${M55308C00169_value_traffic}<=4
    ${M55308C00170_value_attach}    Get counter latest value from dict
    ...    counters_dict=${12724_G_counters_dict_attach}    BTS_or_TRS=BTS    full_path=${M55308C00170_full_path}
    ${M55308C00170_value_traffic}    Get counter latest value from dict
    ...    counters_dict=${12724_G_counters_dict_traffic}    BTS_or_TRS=BTS    full_path=${M55308C00170_full_path}
	Log To Console    \n ***M55308C00170 attach: ${M55308C00170_value_attach}; M55308C00170 traffic: ${M55308C00170_value_traffic}
    should be true    0<=${M55308C00170_value_attach}<=${M55308C00170_value_traffic}<=2
    [Teardown]    run keywords    MultiUE Stop traffic    ue_list=${ue_list}    apn=${apn0}    AND    case_common_teardown

[1]CB012724_F_1_UE_Context_modification_Required_Successful_transformPrecoder_Enable_SA
    [Setup]    case_common_setup
    update_scf    scfpath=${12724_F_scf}
    sleep    180
 	Set PA value    modify_list=${PA_value_25}      port_num=${4}
	sleep    10s
    ${ue_list}    Create List    1
    &{ues_dltput}    Create Dictionary    1=160MKbits/sec
    &{ues_ultput}    Create Dictionary    1=100MKbits/sec
    MultiUE Prepare    ue_list=${ue_list}
  	MultiUE Attach    ue_list=${ue_list}
    MultiUE Start dlul traffic    ue_list=${ue_list}    apn=${apn0}    ues_dltput=${ues_dltput}
    ...    ues_ultput=${ues_ultput}
	Set PA value    modify_list=${PA_value_65}      port_num=${4}
	sleep    3s
	Set PA value    modify_list=${PA_value_25}      port_num=${4}
	sleep    3s
	Set PA value    modify_list=${PA_value_65}      port_num=${4}
	sleep    3s
	Set PA value    modify_list=${PA_value_25}      port_num=${4}
	sleep    3s
	Wait Until Next Counter Update
	${counter_id_list}    create list    M55113C00019    M55113C00020    M55113C00021    M55113C00022
    ${trans_Pre_counters_dict}    COAM get pm counters dict via admin    counter_id_list=${counter_id_list}
	set suite variable    ${trans_Pre_counters_dict}
	${M55113C00019_value}    Get counter latest value from dict
    ...    counters_dict=${trans_Pre_counters_dict}    BTS_or_TRS=BTS    full_path=${M55113C00019_full_path}
	${M55113C00020_value}    Get counter latest value from dict
    ...    counters_dict=${trans_Pre_counters_dict}    BTS_or_TRS=BTS    full_path=${M55113C00020_full_path}
	${M55113C00021_value}    Get counter latest value from dict
    ...    counters_dict=${trans_Pre_counters_dict}    BTS_or_TRS=BTS    full_path=${M55113C00021_full_path}
	${M55113C00022_value}    Get counter latest value from dict
    ...    counters_dict=${trans_Pre_counters_dict}    BTS_or_TRS=BTS    full_path=${M55113C00022_full_path}
	${transformPre_counters_values}    create list
    ...    ${M55113C00019_value}    ${M55113C00020_value}    ${M55113C00021_value}    ${M55113C00022_value}
	${sum_transformPre_counters}    get_counters_values_sum    counters_values=${transformPre_counters_values}
	should be true    ${sum_transformPre_counters}>0    initialtrans counters are not update.
	[Teardown]    run keywords    MultiUE Stop traffic    ue_list=${ue_list}    apn=${apn0}    AND    case_common_teardown

[1]CB012724_G_1_Available_DL_PRB_in_special_slot
    [Setup]    case_common_setup
	${counter_id_list}    create list    M55308C00165    M55308C00166    M55308C00169    M55308C00170
	${legacy_counter_id_list}    create list    M55308C10001    M55308C10003
    update_scf    scfpath=${12724_G_scf}
    sleep    180s
    ${ue_list}    Create List    1    3
    &{ues_dltput}    Create Dictionary    1=1600MKbits/sec    3=0MKbits/sec
    &{ues_ultput}    Create Dictionary    1=100MKbits/sec    3=100MKbits/sec
    MultiUE Prepare    ue_list=${ue_list}
	MultiUE Attach    ue_list=${ue_list}
	sleep    5min
	Wait Until Next Counter Update
    ${12724_G_counters_dict_attach}    COAM get pm counters dict via admin    counter_id_list=${counter_id_list}
	set suite variable    ${12724_G_counters_dict_attach}
    ${legacy_counters_dict_attach}    COAM get pm counters dict via admin    counter_id_list=${legacy_counter_id_list}
	set suite variable    ${legacy_counters_dict_attach}
	MultiUE Start dlul traffic    ue_list=${ue_list}    apn=${apn0}    ues_dltput=${ues_dltput}
    ...    ues_ultput=${ues_ultput}
	sleep    5min
    Wait Until Next Counter Update
    ${12724_G_counters_dict_traffic}    COAM get pm counters dict via admin    counter_id_list=${counter_id_list}
	set suite variable    ${12724_G_counters_dict_traffic}
    ${legacy_counters_dict_traffic}    COAM get pm counters dict via admin    counter_id_list=${legacy_counter_id_list}
	set suite variable    ${legacy_counters_dict_traffic}
    ${M55308C00165_value_attach}    Get counter latest value from dict
    ...    counters_dict=${12724_G_counters_dict_attach}    BTS_or_TRS=BTS    full_path=${M55308C00165_full_path}
    ${M55308C00165_value_traffic}    Get counter latest value from dict
    ...    counters_dict=${12724_G_counters_dict_traffic}    BTS_or_TRS=BTS    full_path=${M55308C00165_full_path}
	Log To Console    \n ***M55308C00165 attach: ${M55308C00165_value_attach}; M55308C00165 traffic: ${M55308C00165_value_traffic}
    ${M55308C10003_value_attach}    Get counter latest value from dict
    ...    counters_dict=${legacy_counters_dict_attach}    BTS_or_TRS=BTS    full_path=${M55308C10003_full_path}
    ${M55308C10003_value_traffic}    Get counter latest value from dict
    ...    counters_dict=${legacy_counters_dict_traffic}    BTS_or_TRS=BTS    full_path=${M55308C10003_full_path}
	Log To Console    \n ***M55308C10003 attach: ${M55308C10003_value_attach}; M55308C10003 traffic: ${M55308C10003_value_traffic}
	should be true    ${M55308C00165_value_attach}==16380000 and ${M55308C00165_value_traffic}==16380000
	should be true    ${M55308C10003_value_attach}==130095000 and ${M55308C10003_value_traffic}==130095000
    [Teardown]    run keywords    MultiUE Stop traffic    ue_list=${ue_list}    apn=${apn0}    AND    case_common_teardown

[1]CB012724_G_3_Used_DL_PRB_in_special_slot_multiUE_RAT1
    [Setup]    case_common_setup
    ${M55308C10001_value_attach}    Get counter latest value from dict
    ...    counters_dict=${legacy_counters_dict_attach}    BTS_or_TRS=BTS    full_path=${M55308C10001_full_path}
    ${M55308C10001_value_traffic}    Get counter latest value from dict
    ...    counters_dict=${legacy_counters_dict_traffic}    BTS_or_TRS=BTS    full_path=${M55308C10001_full_path}
	Log To Console    \n ***M55308C10001 attach: ${M55308C10001_value_attach}; M55308C10001 traffic: ${M55308C10001_value_traffic}
    ${M55308C00166_value_attach}    Get counter latest value from dict
    ...    counters_dict=${12724_G_counters_dict_attach}    BTS_or_TRS=BTS    full_path=${M55308C00166_full_path}
    ${M55308C00166_value_traffic}    Get counter latest value from dict
    ...    counters_dict=${12724_G_counters_dict_traffic}    BTS_or_TRS=BTS    full_path=${M55308C00166_full_path}
	Log To Console    \n ***M55308C00166 attach: ${M55308C00166_value_attach}; M55308C00166 traffic: ${M55308C00166_value_traffic}
    should be true    0<=${M55308C00166_value_attach}<${M55308C00166_value_traffic}<=16380000
	should be true    ${M55308C00166_value_attach}<${M55308C10001_value_attach} and ${M55308C00166_value_traffic}<${M55308C10001_value_traffic}
	[Teardown]    case_common_teardown

[1]CB012724_G_8_Average_of_Maximum_number_of_layers_per_DL_slot_SUMIMO
    [Setup]    case_common_setup
    ${M55308C00169_value_attach}    Get counter latest value from dict
    ...    counters_dict=${12724_G_counters_dict_attach}    BTS_or_TRS=BTS    full_path=${M55308C00169_full_path}
    ${M55308C00169_value_traffic}    Get counter latest value from dict
    ...    counters_dict=${12724_G_counters_dict_traffic}    BTS_or_TRS=BTS    full_path=${M55308C00169_full_path}
	Log To Console    \n ***M55308C00169 attach: ${M55308C00169_value_attach}; M55308C00169 traffic: ${M55308C00169_value_traffic}
    should be true    0<${M55308C00169_value_attach}<=${M55308C00169_value_traffic}<=4
	[Teardown]    case_common_teardown

[1]CB012724_G_10_Average_of_Maximum_number_of_layers_per_UL_slot_SUMIMO
    [Setup]    case_common_setup
    ${M55308C00170_value_attach}    Get counter latest value from dict
    ...    counters_dict=${12724_G_counters_dict_attach}    BTS_or_TRS=BTS    full_path=${M55308C00170_full_path}
    ${M55308C00170_value_traffic}    Get counter latest value from dict
    ...    counters_dict=${12724_G_counters_dict_traffic}    BTS_or_TRS=BTS    full_path=${M55308C00170_full_path}
	Log To Console    \n ***M55308C00170 attach: ${M55308C00170_value_attach}; M55308C00170 traffic: ${M55308C00170_value_traffic}
    should be true    0<=${M55308C00170_value_attach}<=${M55308C00170_value_traffic}<=2
	[Teardown]    case_common_teardown