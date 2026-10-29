*** Settings ***
Documentation    This is for TMO common keywords.
...              Please do not modify the file without notification to author
...              Author: xiangsheng.chu@nokia-sbell.com

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    DateTime
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Variables   ./TMO_Data.py
Library   ./4GL3call.py



*** Variables ***
${BASIC_SCF}    tmo_basic.xml
@{customers}             TMO US

*** Keywords ***

Counter 8311
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM  ${Pcell_index}=301   ${BTS_or_TRS}=BTS    ${gnb_id}=${0}
    ...            ${conuter_list_num}=0     ${scell_index}=311    ${file_kpi_name}=8311_kpi   ${kpi_version}=0
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
#    sleep   300s
	${active_version}    coam.get_sw_version    timeout=60    connection=${connection}
	create_file    ${remote_log_path}/8311_kpi_${kpi_version}.txt
    create_file    ${remote_log_path}/8311_counter_${kpi_version}.txt
    Append to file   ${remote_log_path}/8311_counter_${kpi_version}.txt   testline=${tl_prefix}\r\n
    Append to file   ${remote_log_path}/8311_counter_${kpi_version}.txt   gnb version=${active_version}\r\n
    ${all_counters_info} =    coam.get_counters_info    connection=${connection}    timeout=1800
    ${all_counter_groups} =    Get From Dictionary    ${all_counters_info}    BTS
    ${counter_group_keys}     create list
    ${gnb_version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
    Run keyword If    '${gnb_version}'=='master' or '${gnb_version}'=='24R2'
    ...                append to list     ${counter_group_keys}    MRBTS-${tl.gnbs[0].instance_id}
    Run keyword If    '${gnb_version}'=='master' or '${gnb_version}'=='24R2'
    ...                append to list     ${counter_group_keys}    NRBTS-${tl.gnbs[0].instance_id}
    Run keyword If    '${gnb_version}'=='23R4' or '${gnb_version}'=='24R1'
    ...                append to list     ${counter_group_keys}    CELLS
    append to list     ${counter_group_keys}    NRCELL-${Pcell_index}
    FOR    ${group}    IN     @{counter_group_keys}
        ${all_counter_groups} =    Get From Dictionary    ${all_counter_groups}    ${group}
    END
    ${5757a}     ${5759a}      ${5760a}     ${5761a}    ${5762a}    ${5763a}    ${5773a}     ${5848a}    ${5525a}    ${5527a}
    ...           KPI_NCAC_5757_5759_5760_5761_5762_5763a_5773a_5848a_5525a_5527a    ncac_counter_groups=${all_counter_groups}
    ...           spe_kpi_version=${kpi_version}
    ${5160a}     ${5167a}       KPI_5160_5167    nrrcc_counter_groups=${all_counter_groups}    spe_kpi_version=${kpi_version}
    ${1474a}     ${1511a}       KPI_1474_1511    rsadu_counter_groups=${all_counter_groups}     spe_kpi_version=${kpi_version}
    ${M55351C00001}     ${M55351C00002}      ${M55351C01001}     ${M55351C01002}
    ...          M55351C00001_M55351C00002_M55351C01001_M55351C01002     dbwp_counter_groups=${all_counter_groups}    spe_kpi_version=${kpi_version}
    ${M55316C09000}     ${M55316C09001}     M55316C09000_M55316C09001       ncadu_counter_groups=${all_counter_groups}
    ...            spe_kpi_version=${kpi_version}
    ${5012a}     ${5013a}      ${M55306C06001}    KPI_5012_5013     nrach_counter_groups=${all_counter_groups}    spe_kpi_version=${kpi_version}
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt   gnb version=${active_version}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt   [5757a] 5G SA Overall SCell Release Success Ratio=${5757a}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt
    ...              [5759a] 5G SA SCell Release Distribution Ratio due to A2 measurement report of SCell=${5759a}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt
    ...              [5760a] 5G SA SCell Release Distribution Ratio due to prolonged inactivity in the PCell=${5760a}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt
    ...              [5761a] 5G SA SCell Release Distribution Ratio due to inactivity while UE is overheating in the PCell=${5761a}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt
    ...              [5762a] 5G SA SCell Release Distribution Ratio due to bad SCell radio link quality in the PCell=${5762a}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [5763a] 5G SA UL 1 SCell Release Success Ratio=${5763a}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [5773a] 5G SA DL 1 SCell Release Success Ratio=${5773a}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [5848a] 5G SA DL 1 ext-SCell Release Success Ratio=${5848a}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [5525a] SA DL CA SCell Addition Success Ratio for 1 Scell=${5525a}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [5527a] SA DL CA SCell Addition Success Ratio for 2 Scel=${5527a}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [5160a] SA RRC connection establishment attempts=${5160a}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [5167a] 5G SA RRC connection establishment success ratio=${5167a}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [1474a] SA SCell admission success ratio for 1 SCell in Pcel=${1474a}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [1511a] SA SCell admission success ratio for 2 SCell in Pcell=${1511a}\r\n
#    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [M55351C00001] MAX_UE_ACTIVE_PWR_SAVING_BWP=${M55351C00001}\r\n
#    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [M55351C00002] AVG_UE_ACTIVE_PWR_SAVING_BWP=${M55351C00002}\r\n
#    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [M55351C01001] MAX_UE_CONFIG_2BWP=${M55351C01001}\r\n
#    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [M55351C01002] AVG_UE_CONFIG_2BWP=${M55351C01002}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [167a] OEM NR CAP Number of SCell activations=${M55316C09000}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt
    ...              [168a] OEM NR CAP Number of SCell deactivations due to buffer status=${M55316C09001}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [5012a] 5G Contention based RACH setup attempts=${5012a}\r\n
    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [5013a] 5G Contention based RACH setup success ratio=${5013a}\r\n
#    Append to file   ${remote_log_path}/8311_kpi_${kpi_version}.txt    [M55306C06001] RA msg3 receptions=${M55306C06001}\r\n
    [Teardown]    Run Keyword And Ignore Error     COAM Teardown gnb connections    connection=${connection}

KPI_NCAC_5757_5759_5760_5761_5762_5763a_5773a_5848a_5525a_5527a
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${ncac_counter_groups}   ${spe_kpi_version}   ${Pcell_index}=301
    ${M55118C06502_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/A2MEAS_REL1DLSCELL_SUCC_SA
    ${M55118C10004_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/A2MEAS_REL1ULSCELL_SUCC_SA
    ${M55118C10512_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/INA_PRO_REL_SCELL_SUC_SA
    ${M55118C10514_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/INA_OVHT_REL_SCELL_SUC_SA
    ${M55118C10516_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/BAD_RLQ_REL_SCELL_SUC_SA
    ${M55118C06501_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/A2MEAS_REL1DLSCELL_ATT_SA
    ${M55118C10003_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/A2MEAS_REL1ULSCELL_ATT_SA
    ${M55118C10511_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/INA_PRO_REL_SCELL_ATT_SA
    ${M55118C10513_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/INA_OVHT_REL_SCELL_ATT_SA
    ${M55118C10515_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/BAD_RLQ_REL_SCELL_ATT_SA
    ${M55118C10506_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/UL_RRC_1SCELL_REL_SUC_SA
    ${M55118C10505_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/UL_RRC_1SCELL_REL_ATT_SA
    ${M55118C10504_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/DL_RRC_1SCELL_REL_SUC_SA
    ${M55118C10503_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/DL_RRC_1SCELL_REL_ATT_SA
    ${M55118C10508_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/DL_RRC_1EXTSCELL_REL_SUC_SA
    ${M55118C10507_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/DL_RRC_1EXTSCELL_REL_ATT_SA
    ${M55118C05506_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/RRC_RECONF_ADD1DLSCELL_SUCC_SA
    ${M55118C05505_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/RRC_RECONF_ADD1DLSCELL_ATT_SA
    ${M55118C07003_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/RRC_RECONF_ADD2DLSCELL_SUCC_SA
    ${M55118C07004_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCAC/RRC_RECONF_ADD2DLSCELL_ATT_SA
    ${special_counter_groups}     Get From Dictionary    ${ncac_counter_groups}    NCAC
    ${M55118C06502}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C06502
    ...                counter_version=${spe_kpi_version}
    ${M55118C10004}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C10004
    ...                counter_version=${spe_kpi_version}
    ${M55118C10512}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C10512
    ...                counter_version=${spe_kpi_version}
    ${M55118C10514}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C10514
    ...                counter_version=${spe_kpi_version}
    ${M55118C10516}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C10516
    ...                counter_version=${spe_kpi_version}
    ${M55118C06501}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C06501
    ...                counter_version=${spe_kpi_version}
    ${M55118C10003}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C10003
    ...                counter_version=${spe_kpi_version}
    ${M55118C10511}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C10511
    ...                counter_version=${spe_kpi_version}
    ${M55118C10513}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C10513
    ...                counter_version=${spe_kpi_version}
    ${M55118C10515}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C10515
    ...                counter_version=${spe_kpi_version}
    ${M55118C10506}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C10506
    ...                counter_version=${spe_kpi_version}
    ${M55118C10505}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C10505
    ...                counter_version=${spe_kpi_version}
    ${M55118C10504}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C10504
    ...                counter_version=${spe_kpi_version}
    ${M55118C10503}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C10503
    ...                counter_version=${spe_kpi_version}
    ${M55118C10508}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C10508
    ...                counter_version=${spe_kpi_version}
    ${M55118C10507}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C10507
    ...                counter_version=${spe_kpi_version}
    ${M55118C05506}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C05506
    ...                counter_version=${spe_kpi_version}
    ${M55118C05505}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C05505
    ...                counter_version=${spe_kpi_version}
    ${M55118C07003}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C07003
    ...                counter_version=${spe_kpi_version}
    ${M55118C07004}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55118C07004
    ...                counter_version=${spe_kpi_version}
    ${NR_KPI_5757a_0}   Evaluate   ${M55118C06502}+${M55118C10004}+${M55118C10512}+${M55118C10514}+${M55118C10516}
    ${NR_KPI_5757a_1}   Evaluate   ${M55118C06501}+${M55118C10003}+${M55118C10511}+${M55118C10513}+${M55118C10515}
    ${NR_KPI_5757a}     Run Keyword If    ${NR_KPI_5757a_1}==0     Set Variable   0
    ...                 ELSE      Calculate kpi   KPI_dividend=${NR_KPI_5757a_0}     kpi_divisor=${NR_KPI_5757a_1}
    ${NR_KPI_5759a_0}    Evaluate     ${M55118C06502}+${M55118C10004}
    ${NR_KPI_5759a_1}    Evaluate     ${M55118C06502}+${M55118C10004}+${M55118C10512}+${M55118C10514}+${M55118C10516}
    ${NR_KPI_5759a}     Run Keyword If    ${NR_KPI_5759a_1}==0     Set Variable   0
    ...                 ELSE      Calculate kpi   KPI_dividend=${NR_KPI_5759a_0}     kpi_divisor=${NR_KPI_5759a_1}
    ${NR_KPI_5760a_1}    Evaluate     ${M55118C06502}+${M55118C10004}+${M55118C10512}+${M55118C10514}+${M55118C10516}
    ${NR_KPI_5760a}     Run Keyword If    ${NR_KPI_5760a_1}==0     Set Variable   0
    ...                 ELSE      Calculate kpi   KPI_dividend=${M55118C10512}     kpi_divisor=${NR_KPI_5760a_1}
    ${NR_KPI_5761a_1}    Evaluate     ${M55118C06502}+${M55118C10004}+${M55118C10512}+${M55118C10514}+${M55118C10516}
    ${NR_KPI_5761a}     Run Keyword If    ${NR_KPI_5761a_1}==0     Set Variable   0
    ...                 ELSE      Calculate kpi   KPI_dividend=${M55118C10514}     kpi_divisor=${NR_KPI_5761a_1}
    ${NR_KPI_5762a_1}    Evaluate     ${M55118C06502}+${M55118C10004}+${M55118C10512}+${M55118C10514}+${M55118C10516}
    ${NR_KPI_5762a}     Run Keyword If    ${NR_KPI_5762a_1}==0     Set Variable   0
    ...                 ELSE      Calculate kpi   KPI_dividend=${M55118C10516}     kpi_divisor=${NR_KPI_5762a_1}
    ${NR_KPI_5763a}     Run Keyword If    ${M55118C10505}==0     Set Variable   0
    ...                 ELSE      Calculate kpi   KPI_dividend=${M55118C10506}     kpi_divisor=${M55118C10505}
    ${NR_KPI_5773a}     Run Keyword If    ${M55118C10503}==0     Set Variable   0
    ...                 ELSE      Calculate kpi   KPI_dividend=${M55118C10504}     kpi_divisor=${M55118C10503}
    ${NR_KPI_5848a}     Run Keyword If    ${M55118C10507}==0     Set Variable   0
    ...                 ELSE      Calculate kpi   KPI_dividend=${M55118C10508}     kpi_divisor=${MM55118C10507}
    ${NR_KPI_5525a}     Run Keyword If    ${M55118C05505}==0     Set Variable   0
    ...                 ELSE      Calculate kpi   KPI_dividend=${M55118C05506}     kpi_divisor=${M55118C05505}
    ${NR_KPI_5527a}     Run Keyword If    ${M55118C07004}==0     Set Variable   0
    ...                 ELSE      Calculate kpi   KPI_dividend=${M55118C07003}     kpi_divisor=${M55118C07004}
    [Return]    ${NR_KPI_5757a}     ${NR_KPI_5759a}      ${NR_KPI_5760a}     ${NR_KPI_5761a}    ${NR_KPI_5762a}    ${NR_KPI_5763a}
    ...         ${NR_KPI_5773a}     ${NR_KPI_5848a}    ${NR_KPI_5525a}     ${NR_KPI_5527a}

KPI_5160_5167
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${nrrcc_counter_groups}     ${spe_kpi_version}     ${Pcell_index}=301
    ${special_counter_groups}     Get From Dictionary    ${nrrcc_counter_groups}    NRRCC
    ${M55124C01031_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRRCC/NRRCC_RRC_STPSUCC_TOT
    ${M55124C01031}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55124C01031
    ...                counter_version=${spe_kpi_version}
    ${M55124C01001_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRRCC/NRRCC_RRC_STPREQ_MO_SIGNALLING
    ${M55124C01001}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55124C01001
    ...                counter_version=${spe_kpi_version}
    ${M55124C01002_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRRCC/NRRCC_RRC_STPREQ_MO_DATA
    ${M55124C01002}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55124C01002
    ...                counter_version=${spe_kpi_version}
    ${M55124C01003_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRRCC/NRRCC_RRC_STPREQ_MT_ACCESS
    ${M55124C01003}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55124C01003
    ...                counter_version=${spe_kpi_version}
    ${M55124C01004_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRRCC/NRRCC_RRC_STPREQ_EMERGENCY
    ${M55124C01004}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55124C01004
    ...                counter_version=${spe_kpi_version}
    ${M55124C01005_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRRCC/NRRCC_RRC_STPREQ_HIPRIO_ACCESS
    ${M55124C01005}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55124C01005
    ...                counter_version=${spe_kpi_version}
    ${M55124C01006_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRRCC/NRRCC_RRC_STPREQ_MO_VOICECALL
    ${M55124C01006}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55124C01006
    ...                counter_version=${spe_kpi_version}
    ${M55124C01014_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRRCC/NRRCC_RRC_STPREQ_MO_SMS
    ${M55124C01014}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55124C01014
    ...                counter_version=${spe_kpi_version}
    ${M55124C01015_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRRCC/NRRCC_RRC_STPREQ_MPS
    ${M55124C01015}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55124C01015
    ...                counter_version=${spe_kpi_version}
    ${M55124C01016_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRRCC/NRRCC_RRC_STPREQ_MCS
    ${M55124C01016}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55124C01016
    ...                counter_version=${spe_kpi_version}
    ${M55124C01017_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRRCC/NRRCC_RRC_STPREQ_MO_VIDEOCAL
    ${M55124C01017}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55124C01017
    ...                counter_version=${spe_kpi_version}
    ${NR_KPI_5160a_0}    Evaluate    ${M55124C01001}+${M55124C01002}+${M55124C01003}+${M55124C01004}+${M55124C01005}+${M55124C01006}
    ${NR_KPI_5160a_1}    Evaluate    ${M55124C01014}+${M55124C01015}+${M55124C01016}+${M55124C01017}
    ${NR_KPI_5160a}      Evaluate    ${NR_KPI_5160a_0}+${NR_KPI_5160a_1}
    ${NR_KPI_5167a}     Run Keyword If    ${NR_KPI_5160a}==0     Set Variable   0
    ...                 ELSE      Calculate kpi   KPI_dividend=${M55124C01031}     kpi_divisor=${NR_KPI_5160a}
    [Return]     ${NR_KPI_5160a}      ${NR_KPI_5167a}

KPI_1474_1511
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${rsadu_counter_groups}    ${spe_kpi_version}     ${Pcell_index}=301
    ${special_counter_groups}     Get From Dictionary    ${rsadu_counter_groups}    RSADU
    ${M55139C01004_path}    set variable    CELLS/NRCELL-${Pcell_index}/RSADU/GNB_DU_SCELL_1_ADMI_SUCC_SA
    ${M55139C01004}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55139C01004
    ...                counter_version=${spe_kpi_version}
    ${M55139C01003_path}    set variable    CELLS/NRCELL-${Pcell_index}/RSADU/GNB_DU_SCELL_1_ADMI_REQ_SA
    ${M55139C01003}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55139C01003
    ...                counter_version=${spe_kpi_version}
    ${M55139C01502_path}    set variable    CELLS/NRCELL-${Pcell_index}/RSADU/GNB_DU_SCELL_2_ADMI_SUCC_SA
    ${M55139C01502}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55139C01502
    ...                counter_version=${spe_kpi_version}
    ${M55139C01501_path}    set variable    CELLS/NRCELL-${Pcell_index}/RSADU/GNB_DU_SCELL_2_ADMI_REQ_SA
    ${M55139C01501}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55139C01501
    ...                counter_version=${spe_kpi_version}
    ${NR_KPI_1474a}     Run Keyword If    ${M55139C01003}==0     Set Variable   0
    ...                 ELSE      Calculate kpi   KPI_dividend=${M55139C01004}     kpi_divisor=${M55139C01003}
    ${NR_KPI_1511a}     Run Keyword If    ${M55139C01501}==0     Set Variable   0
    ...                 ELSE      Calculate kpi   KPI_dividend=${M55139C01502}     kpi_divisor=${M55139C01501}
    [Return]    ${NR_KPI_1474a}      ${NR_KPI_1511a}


M55351C00001_M55351C00002_M55351C01001_M55351C01002
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${dbwp_counter_groups}    ${spe_kpi_version}     ${Pcell_index}=301
    ${special_counter_groups}     Get From Dictionary    ${dbwp_counter_groups}    DBWP
    ${M55351C00001_path}    set variable    CELLS/NRCELL-${Pcell_index}/DBWP/MAX_UE_ACTIVE_PWR_SAVING_BWP
    ${M55351C00001}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55351C00001
    ...                counter_version=${spe_kpi_version}
    ${M55351C00002_path}    set variable    CELLS/NRCELL-${Pcell_index}/DBWP/AVG_UE_ACTIVE_PWR_SAVING_BWP
    ${M55351C00002}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55351C00002
    ...                counter_version=${spe_kpi_version}
    ${M55351C01001_path}    set variable    CELLS/NRCELL-${Pcell_index}/DBWP/MAX_UE_CONFIG_2BWP
    ${M55351C01001}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55351C01001
    ...                counter_version=${spe_kpi_version}
    ${M55351C01002_path}    set variable    CELLS/NRCELL-${Pcell_index}/DBWP/AVG_UE_CONFIG_2BWP
    ${M55351C01002}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55351C01002
    ...                counter_version=${spe_kpi_version}
    [Return]   ${M55351C00001}     ${M55351C00002}     ${M55351C01001}    ${M55351C01002}


M55316C09000_M55316C09001
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${ncadu_counter_groups}    ${spe_kpi_version}     ${Pcell_index}=301
    ${special_counter_groups}     Get From Dictionary    ${ncadu_counter_groups}    NCADU
    ${M55316C09000_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCADU/SCELL_ACTIVATIONS
    ${M55316C09000}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55316C09000
    ...                counter_version=${spe_kpi_version}
    ${M55316C09001_path}    set variable    CELLS/NRCELL-${Pcell_index}/NCADU/SCELL_DEACT_BUFFER_STATUS
    ${M55316C09001}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55316C09001
    ...                counter_version=${spe_kpi_version}
    [Return]     ${M55316C09000}      ${M55316C09001}

Calculate kpi
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${KPI_dividend}      ${kpi_divisor}
    ${NR_KPI_tmp}    Evaluate    ${KPI_dividend}/${kpi_divisor}
    ${NR_KPI}    Evaluate    100*${NR_KPI_tmp}
    ${NR_KPI}    Convert To Number    ${NR_KPI}
    ${NR_KPI}    Evaluate    round(${NR_KPI},2)
    [Return]     ${NR_KPI}


KPI_5012_5013
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${nrach_counter_groups}     ${spe_kpi_version}      ${Pcell_index}=301
    ${special_counter_groups}     Get From Dictionary    ${nrach_counter_groups}    NRACH
    ${M55306C00001_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_00
    ${M55306C00002_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_01
    ${M55306C00003_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_02
    ${M55306C00004_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_03
    ${M55306C00005_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_04
    ${M55306C00006_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_05
    ${M55306C00007_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_06
    ${M55306C00008_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_07
    ${M55306C00009_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_08
    ${M55306C00010_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_09
    ${M55306C00011_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_10
    ${M55306C00012_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_11
    ${M55306C00013_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_12
    ${M55306C00014_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_13
    ${M55306C00015_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_14
    ${M55306C00016_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_15
    ${M55306C00017_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_16
    ${M55306C00018_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_17
    ${M55306C00019_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_18
    ${M55306C00020_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_19
    ${M55306C00021_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_20
    ${M55306C00022_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_21
    ${M55306C00023_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_22
    ${M55306C00024_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_23
    ${M55306C00025_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_24
    ${M55306C00026_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_25
    ${M55306C00027_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_26
    ${M55306C00028_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_27
    ${M55306C00029_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_28
    ${M55306C00030_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_29
    ${M55306C00031_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_30
    ${M55306C00032_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_31
    ${M55306C00033_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_32
    ${M55306C00034_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_33
    ${M55306C00035_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_34
    ${M55306C00036_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_35
    ${M55306C00037_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_36
    ${M55306C00038_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_37
    ${M55306C00039_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_38
    ${M55306C00040_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_39
    ${M55306C00041_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_40
    ${M55306C00042_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_41
    ${M55306C00043_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_42
    ${M55306C00044_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_43
    ${M55306C00045_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_44
    ${M55306C00046_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_45
    ${M55306C00047_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_46
    ${M55306C00048_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_47
    ${M55306C00049_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_48
    ${M55306C00050_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_49
    ${M55306C00051_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_50
    ${M55306C00052_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_51
    ${M55306C00053_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_52
    ${M55306C00054_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_53
    ${M55306C00055_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_54
    ${M55306C00056_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_55
    ${M55306C00057_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_56
    ${M55306C00058_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_57
    ${M55306C00059_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_58
    ${M55306C00060_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_59
    ${M55306C00061_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_60
    ${M55306C00062_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_61
    ${M55306C00063_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_62
    ${M55306C00064_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_ATT_CONT_A_PRMBL_SSB_63
    ${M55306C06001_path}    set variable    CELLS/NRCELL-${Pcell_index}/NRACH/RA_MSG3_RECEP
    ${M55306C06001}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C06001
    ...                counter_version=${spe_kpi_version}
    ${M55306C00001}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00001
    ...                counter_version=${spe_kpi_version}
    ${M55306C00002}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00002
    ...                counter_version=${spe_kpi_version}
    ${M55306C00003}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00003
    ...                counter_version=${spe_kpi_version}
    ${M55306C00004}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00004
    ...                counter_version=${spe_kpi_version}
    ${M55306C00005}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00005
    ...                counter_version=${spe_kpi_version}
    ${M55306C00006}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00006
    ...                counter_version=${spe_kpi_version}
    ${M55306C00007}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00007
    ...                counter_version=${spe_kpi_version}
    ${M55306C00008}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00008
    ...                counter_version=${spe_kpi_version}
    ${M55306C00009}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00009
    ...                counter_version=${spe_kpi_version}
    ${M55306C00010}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00010
    ...                counter_version=${spe_kpi_version}
    ${M55306C00011}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00011
    ...                counter_version=${spe_kpi_version}
    ${M55306C00012}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00012
    ...                counter_version=${spe_kpi_version}
    ${M55306C00013}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00013
    ...                counter_version=${spe_kpi_version}
    ${M55306C00014}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00014
    ...                counter_version=${spe_kpi_version}
    ${M55306C00015}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00015
    ...                counter_version=${spe_kpi_version}
    ${M55306C00016}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00016
    ...                counter_version=${spe_kpi_version}
    ${M55306C00017}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00017
    ...                counter_version=${spe_kpi_version}
    ${M55306C00018}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00018
    ...                counter_version=${spe_kpi_version}
    ${M55306C00019}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00019
    ...                counter_version=${spe_kpi_version}
    ${M55306C00020}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00020
    ...                counter_version=${spe_kpi_version}
    ${M55306C00021}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00021
    ...                counter_version=${spe_kpi_version}
    ${M55306C00022}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00022
    ...                counter_version=${spe_kpi_version}
    ${M55306C00023}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00023
    ...                counter_version=${spe_kpi_version}
    ${M55306C00024}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00024
    ...                counter_version=${spe_kpi_version}
    ${M55306C00025}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00025
    ...                counter_version=${spe_kpi_version}
    ${M55306C00026}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00026
    ...                counter_version=${spe_kpi_version}
    ${M55306C00027}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00027
    ...                counter_version=${spe_kpi_version}
    ${M55306C00028}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00028
    ...                counter_version=${spe_kpi_version}
    ${M55306C00029}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00029
    ...                counter_version=${spe_kpi_version}
	${M55306C00030}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00030
	...                counter_version=${spe_kpi_version}
	${M55306C00031}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00031
	...                counter_version=${spe_kpi_version}
	${M55306C00032}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00032
	...                counter_version=${spe_kpi_version}
	${M55306C00033}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00033
	...                counter_version=${spe_kpi_version}
	${M55306C00034}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00034
	...                counter_version=${spe_kpi_version}
	${M55306C00035}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00035
	...                counter_version=${spe_kpi_version}
	${M55306C00036}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00036
	...                counter_version=${spe_kpi_version}
	${M55306C00037}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00037
	...                counter_version=${spe_kpi_version}
	${M55306C00038}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00038
	...                counter_version=${spe_kpi_version}
	${M55306C00039}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00039
	...                counter_version=${spe_kpi_version}
	${M55306C00040}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00040
	...                counter_version=${spe_kpi_version}
	${M55306C00041}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00041
	...                counter_version=${spe_kpi_version}
	${M55306C00042}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00042
	...                counter_version=${spe_kpi_version}
	${M55306C00043}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00043
	...                counter_version=${spe_kpi_version}
	${M55306C00044}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00044
	...                counter_version=${spe_kpi_version}
	${M55306C00045}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00045
	...                counter_version=${spe_kpi_version}
	${M55306C00046}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00046
	...                counter_version=${spe_kpi_version}
	${M55306C00047}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00047
	...                counter_version=${spe_kpi_version}
	${M55306C00048}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00048
	...                counter_version=${spe_kpi_version}
	${M55306C00049}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00049
	...                counter_version=${spe_kpi_version}
	${M55306C00050}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00050
	...                counter_version=${spe_kpi_version}
	${M55306C00051}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00051
	...                counter_version=${spe_kpi_version}
	${M55306C00052}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00052
	...                counter_version=${spe_kpi_version}
	${M55306C00053}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00053
	...                counter_version=${spe_kpi_version}
	${M55306C00054}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00054
	...                counter_version=${spe_kpi_version}
	${M55306C00055}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00055
	...                counter_version=${spe_kpi_version}
	${M55306C00056}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00056
	...                counter_version=${spe_kpi_version}
	${M55306C00057}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00057
	...                counter_version=${spe_kpi_version}
	${M55306C00058}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00058
	...                counter_version=${spe_kpi_version}
	${M55306C00059}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00059
	...                counter_version=${spe_kpi_version}
	${M55306C00060}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00060
	...                counter_version=${spe_kpi_version}
	${M55306C00061}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00061
	...                counter_version=${spe_kpi_version}
	${M55306C00062}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00062
	...                counter_version=${spe_kpi_version}
	${M55306C00063}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00063
	...                counter_version=${spe_kpi_version}
	${M55306C00064}    Get counter special value   special_counter_groups=${special_counter_groups}    counter_id=M55306C00064
	...                counter_version=${spe_kpi_version}
	${NR_5012a_list}   create list       ${M55306C00001}    ${M55306C00002}    ${M55306C00003}   ${M55306C00004}
	...                 ${M55306C00005}     ${M55306C00006}     ${M55306C00007}     ${M55306C00008}     ${M55306C00009}
    ...                 ${M55306C00010}     ${M55306C00011}     ${M55306C00012}     ${M55306C00013}     ${M55306C00014}
    ...                 ${M55306C00015}     ${M55306C00016}     ${M55306C00017}     ${M55306C00018}     ${M55306C00019}
    ...                 ${M55306C00020}     ${M55306C00021}     ${M55306C00022}     ${M55306C00023}     ${M55306C00024}
    ...                 ${M55306C00025}     ${M55306C00026}     ${M55306C00027}     ${M55306C00028}     ${M55306C00029}
    ...                 ${M55306C00030}     ${M55306C00031}		${M55306C00032}		${M55306C00033}	    ${M55306C00034}
    ...                 ${M55306C00035}		${M55306C00036}		${M55306C00037}		${M55306C00038}     ${M55306C00039}
    ...                 ${M55306C00040}		${M55306C00041}		${M55306C00042}		${M55306C00043}     ${M55306C00044}
    ...                 ${M55306C00045}		${M55306C00046}		${M55306C00047}		${M55306C00048}		${M55306C00049}
    ...                 ${M55306C00050}		${M55306C00051}		${M55306C00052}		${M55306C00053}		${M55306C00054}
    ...                 ${M55306C00055}		${M55306C00056}		${M55306C00057}		${M55306C00058}		${M55306C00059}
    ...                 ${M55306C00060}		${M55306C00061}		${M55306C00062}		${M55306C00063}		${M55306C00064}
    ${NR_5012a}     Set Variable   0
    FOR    ${i}    IN RANGE     0   ${64}
           ${NR_5012a}    Evaluate      ${NR_5012a}+${NR_5012a_list[${i}]}
    END
    ${NR_5013a}     Run Keyword If    ${NR_5012a}==0     Set Variable   0
    ...                 ELSE      Calculate kpi   KPI_dividend=${M55306C06001}     kpi_divisor=${NR_5012a}
    [Return]     ${NR_5012a}       ${NR_5013a}    ${M55306C06001}