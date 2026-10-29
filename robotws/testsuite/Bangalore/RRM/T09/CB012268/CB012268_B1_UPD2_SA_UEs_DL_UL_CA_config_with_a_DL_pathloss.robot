*** Settings ***
Force Tags        CLOUD_5G_I_BOO_AP_LOO     VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD_GMC
...               RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation
...  INTRODUCTION    :   Verify that for a UE with a DL pathloss less than cellNearUeDlPathlossThrPmCount, the DL/UL traffic volume
...                      and PRB usage are correctly accounted for in the 'Cell Near' category counters.
...  TEST SET NAME   :   CB012268_B1_UPD2_SA_UEs_DL&UL_CA_config_with_a_DL_pathloss_Verify_Cell_Throughput_Radio_Link_Quality_Counters_not_pegged_
...                      when_cell_is_acting_as_SCell_for_any_UEs
...  TESTING SPLIT   :   Split-B
...  REFERENCES      :   CB012268-CFAM
...  REQUIREMENT ID  :  12653046

Library          taf.transport.ssh           WITH NAME    taf_ssh
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../../../resources/robot/counter_benchmark_resource.robot
Library          ta5g_enb
Library          ta5g_pm_counters
Library          taf.sw.scout    WITH NAME     scout

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Prepare TL with all config files
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1    2


Test Teardown    Run keywords       Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/wts/basic_setup_UPD2_CA.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${UE_ID}        1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${TRF_ID}    1
${Q_O_ADD1}    1
${Timeout_NSA}    300
${epc_log_path}    /tmp/
${SCFC}=                  ${CURDIR}/config/SCF/Scf_UPD2_CA.xml
${AP_XML}=                ${CURDIR}/config/SCF/iphy_UPD2_CA.xml


*** Test Cases ***
[1][2.0] CB012268_B1_UPD2_SA_UEs_DL&UL_CA_with_a_DL_pathloss_Verify_Cell_Tp_Radio_Link_quality_Counters_not_pegged_when_cell_is_acting_scell
    Set test variable      ${LOG_PATH}
	Start Log   btslog
	Create pathloss profile

    Register UE and Send High Data
    Check Near Counters for Pcell and Scell

    Activate MIDDLE pathloss profile
    Check MIDDLE Counters for Pcell and Scell

    Activate EDGE pathloss profile
    Check EDGE Counters for Pcell and Scell

    Find Scfc And Send Delta Commissioning    scfc_filename=Delta_config_set_cellUeDlPathlossThrPmCount.json
    Check Near Counters for Pcell and Scell
    wts_sim_keywords.MultiUE Deregister should be Successful    1   1

*** Keywords ***
Register UE and Send High Data
    ${rnti}    wts_sim_keywords.UE Register should be Successful And Fetch RNTI    ue_id=1
    FOR    ${trf}    IN RANGE   ${1}   ${5}
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=1      Traffic_rate=mbps     dl_rate=175     pdu_id=1   trf_id=${trf}
    END
    wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=1      Traffic_rate=mbps     ul_rate=125     pdu_id=1   trf_id=1
    wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=1      Traffic_rate=mbps     ul_rate=125     pdu_id=1   trf_id=2

    sleep    40s
    ${ue_stats}	SET VARIABLE	ue_stats_nr id=1 type=pdsch,pusch scell=0-20
	${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${ue_stats}		pass_regexp=CellIndex
    ...    timeout=${Timeout_NSA}
    Log to Console    ${output}
    sleep    10s
    Verify DL Tput For CC TDD CA

Create pathloss profile
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=1 pcmax=20 pathloss=110
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=2 pcmax=20 pathloss=130

Activate MIDDLE pathloss profile
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=1

Activate EDGE pathloss profile
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=2

Check Near Counters for Pcell and Scell
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55394C00002    >50000      PDSCH_INI_VOL_CELL_NEAR_UE
    ...     M55394C00005    >50000      PUSCH_INI_VOL_CELL_NEAR_UE
    ...     M55394C00008    >50000      PRB_USED_PDSCH_CELL_NEAR_UE
    ...     M55394C00011    >50000      PRB_USED_PUSCH_CELL_NEAR_UE
	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
	...     file_path=${pm_counter_file}
	Verify Last Counters In File
    ...     M55394C00002    0      PDSCH_INI_VOL_CELL_NEAR_UE
    ...     M55394C00005    0      PUSCH_INI_VOL_CELL_NEAR_UE
    ...     M55394C00008    0      PRB_USED_PDSCH_CELL_NEAR_UE
    ...     M55394C00011    0      PRB_USED_PUSCH_CELL_NEAR_UE
	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-2
	...     file_path=${pm_counter_file}
	Verify Last Counters In File
    ...     M55394C00002    0      PDSCH_INI_VOL_CELL_NEAR_UE
    ...     M55394C00005    0      PUSCH_INI_VOL_CELL_NEAR_UE
    ...     M55394C00008    0      PRB_USED_PDSCH_CELL_NEAR_UE
    ...     M55394C00011    0      PRB_USED_PUSCH_CELL_NEAR_UE
	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-3
	...     file_path=${pm_counter_file}
	Verify Last Counters In File
    ...     M55394C00002    0      PDSCH_INI_VOL_CELL_NEAR_UE
    ...     M55394C00005    0      PUSCH_INI_VOL_CELL_NEAR_UE
    ...     M55394C00008    0      PRB_USED_PDSCH_CELL_NEAR_UE
    ...     M55394C00011    0      PRB_USED_PUSCH_CELL_NEAR_UE
	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-4
	...     file_path=${pm_counter_file}

Check MIDDLE Counters for Pcell and Scell
   Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55394C00003    >50000         PDSCH_INI_VOL_CELL_MIDDLE_UE
    ...    M55394C00006    >50000         PUSCH_INI_VOL_CELL_MIDDLE_UE
    ...    M55394C00009    >50000         PRB_USED_PDSCH_CELL_MIDDLE_UE
    ...    M55394C00012    >50000         PRB_USED_PUSCH_CELL_MIDDLE_UE
    ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-1
	...    file_path=${pm_counter_file}
	Verify Last Counters In File
    ...    M55394C00003    0         PDSCH_INI_VOL_CELL_MIDDLE_UE
    ...    M55394C00006    0         PUSCH_INI_VOL_CELL_MIDDLE_UE
    ...    M55394C00009    0         PRB_USED_PDSCH_CELL_MIDDLE_UE
    ...    M55394C00012    0         PRB_USED_PUSCH_CELL_MIDDLE_UE
	...    local_moid=MRBTS-1/NRBTS-1/NRCELL-2
	...    file_path=${pm_counter_file}
	Verify Last Counters In File
    ...    M55394C00003    0         PDSCH_INI_VOL_CELL_MIDDLE_UE
    ...    M55394C00006    0         PUSCH_INI_VOL_CELL_MIDDLE_UE
    ...    M55394C00009    0         PRB_USED_PDSCH_CELL_MIDDLE_UE
    ...    M55394C00012    0         PRB_USED_PUSCH_CELL_MIDDLE_UE
	...    local_moid=MRBTS-1/NRBTS-1/NRCELL-3
	...    file_path=${pm_counter_file}
	Verify Last Counters In File
    ...    M55394C00003    0         PDSCH_INI_VOL_CELL_MIDDLE_UE
    ...    M55394C00006    0         PUSCH_INI_VOL_CELL_MIDDLE_UE
    ...    M55394C00009    0         PRB_USED_PDSCH_CELL_MIDDLE_UE
    ...    M55394C00012    0         PRB_USED_PUSCH_CELL_MIDDLE_UE
	...    local_moid=MRBTS-1/NRBTS-1/NRCELL-4
	...    file_path=${pm_counter_file}

Check EDGE Counters for Pcell and Scell
   Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55394C00001    >50000         PDSCH_INI_VOL_CELL_EDGE_UE
    ...    M55394C00004    >50000         PUSCH_INI_VOL_CELL_EDGE_UE
    ...    M55394C00007    >50000         PRB_USED_PDSCH_CELL_EDGE_UE
    ...    M55394C00010    >50000         PRB_USED_PUSCH_CELL_EDGE_UE
 	...    local_moid=MRBTS-1/NRBTS-1/NRCELL-1
	...    file_path=${pm_counter_file}
	Verify Last Counters In File
    ...    M55394C00001    0         PDSCH_INI_VOL_CELL_EDGE_UE
    ...    M55394C00004    0         PUSCH_INI_VOL_CELL_EDGE_UE
    ...    M55394C00007    0         PRB_USED_PDSCH_CELL_EDGE_UE
    ...    M55394C00010    0         PRB_USED_PUSCH_CELL_EDGE_UE
 	...    local_moid=MRBTS-1/NRBTS-1/NRCELL-2
	...    file_path=${pm_counter_file}
	Verify Last Counters In File
    ...    M55394C00001    0         PDSCH_INI_VOL_CELL_EDGE_UE
    ...    M55394C00004    0         PUSCH_INI_VOL_CELL_EDGE_UE
    ...    M55394C00007    0         PRB_USED_PDSCH_CELL_EDGE_UE
    ...    M55394C00010    0         PRB_USED_PUSCH_CELL_EDGE_UE
 	...    local_moid=MRBTS-1/NRBTS-1/NRCELL-3
	...    file_path=${pm_counter_file}
	Verify Last Counters In File
    ...    M55394C00001    0         PDSCH_INI_VOL_CELL_EDGE_UE
    ...    M55394C00004    0         PUSCH_INI_VOL_CELL_EDGE_UE
    ...    M55394C00007    0         PRB_USED_PDSCH_CELL_EDGE_UE
    ...    M55394C00010    0         PRB_USED_PUSCH_CELL_EDGE_UE
 	...    local_moid=MRBTS-1/NRBTS-1/NRCELL-4
	...    file_path=${pm_counter_file}
Verify DL Tput For CC TDD CA
    ${pcell_tput}=    wts_sim_keywords.Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
    ${scell_tput}=    wts_sim_keywords.Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=2    unit=Mbps
    ${scell1_tput}=    wts_sim_keywords.Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=1    unit=Mbps
    ${scell2_tput}=    wts_sim_keywords.Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=3    unit=Mbps
    ${scell3_tput}=    wts_sim_keywords.Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=4    unit=Mbps

    Should Be True    ${pcell_tput} > ${50}
    Should Be True    ${scell_tput} > ${50}
    Should Be True    ${scell1_tput} > ${10}
    Should Be True    ${scell2_tput} > ${5}
    Should Be True    ${scell3_tput} > ${5}

