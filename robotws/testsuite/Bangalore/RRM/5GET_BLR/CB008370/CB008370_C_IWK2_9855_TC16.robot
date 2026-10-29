*** Settings ***
Force Tags        CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED    TOOLS_PROFILE_TTI_LEGACY

Documentation
...  AUTHOR          :   shekhar
...  MAINTAINER      :   shekhar.vijay_barewar@nokia.com
...  INTRODUCTION    :   CB008370 PDSCH shared with PDCCH in first OFDM symbol
...  The PDCCH symbol can be shared with PDSCH for a UE if the DL DCI scheduling the PDSCH remains inside the scheduled PDSCH.
...  The following figure illustrated such scenario, where the scheduled PDSCH includes PDCCH symbol, and the DCI scheduling
...  the PDSCH is inside the PDSCH. The UE shall rate match around the DL DCI

Resource   resources/CB008370_resources.robot

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND    Run Keyword and Ignore Error   Suite setup from scratch
...                 AND    Perform SCF Delta Commissioning with Delta_configuration_8370_9855_initial.json
...                 AND    Configure eth3 IP
...                 AND    Load CFG and verify cell status   ${wts_cfg_file}    1    6
...                 AND    Check gNB Bulid

Test Teardown       Link SCOUT SCF to Configuration ID for Reporting

Suite Teardown      Run Keywords    Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

*** Variable ***
${wts_cfg_file}    ${CURDIR}/config/basic_setup_IWK_CB008370_9855.cfg
&{WTS}         Ip=127.0.0.1        Username=ute        Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}    1
${QFI_ID}    1
${TRF_ID}    1
${Trf_rate_SA}  mbps
@{ca_UE_list}    2
@{scell_PhyId_list}    50    51    53    54
@{scell_PhyId_list_8370_9855}     ${scell_PhyId_list}
${CC_NUMBER}            5
@{expected_DL_TP_list_before_flag}  570  65   65   360   65
@{expected_UL_TP_list_before_flag}  80   14
@{expected_DL_TP_list_after_flag}  580  65   65   375   65
@{expected_UL_TP_list_after_flag}  80   14
${Pcell}     6
${Scell}     4
${Pcell_Phy_Id}    ${55}
${Scell_Phy_Id}    ${53}
${REORDERING_WINDOW_SIZE}    500
${REORDERING_TIMER}    300
${DL_RATE}   100
${UL_RATE}   100
${start_DL_trfids}  1
${end_DL_trfids}    12
@{PDSCH_SLIVs}=    ${98}   ${85}   ${57}   ${70}   ${56}   ${43}   ${27}   ${41}   ${55}   ${83}   ${97}
${SCFC}=           ${CURDIR}/config/SCF/scfc_IWK_CB008370_9855.xml
${AP_XML}=         ${CURDIR}/config/SCF/iphy_IWK_CB008370_9855.xml

*** Test Cases ***
[1]CB008370-C#IWK2_TC16_Sharing PDSCH and PDCCH in the same symbol and interaction with FR1 TDD + FDD DL 5CCs with TDD as Pcell
    [Tags]    QC_363674      QCD_MN_RAN    QCP_RAN_ET
    [Documentation]    This user scenario describes the successful operation of sharing PDSCH and PDCCH in the same symbol in
    ...    primary and secondary cells in presence of CA.
    ...    CA relations are defined with multiple FDD and
    ...    TDD cells as Scells and TDD cell as Pcell Verification steps
    ...    1) All Scells are added , data is running on all scells
    ...    2) Tput of PCell1 after flag >  Tput of PCell1 before flag
    ...    3) Counters for pdcch shared symbol should peg in pcell and scel
    ...    4) TTI event the Special SLIVS should be present after flag
     Set Test Variable    ${LOG_PATH}
     SA UE Regristation With Scell Blind Addition with CB008370 flag disabled and DL UL high Traffic
     Sleep    10s
     Verify single UE DLUL CA Tput before 8370 flag OFF
     ${Pcell_DLTPUT_Before8370_flag}   Run Keyword and Continue on failure  Check CA UE Pcell Scell Cell TPut On Target
     ...    ue_id=2    dir=dl    cell_type=pcell    scell_index=0    target_tp=570
     ${Scell3_DLTPUT_Before8370_flag}   Run Keyword and Continue on failure  Check CA UE Pcell Scell Cell TPut On Target
     ...    ue_id=2    dir=dl    cell_type=scell    scell_index=3    target_tp=375
     Sleep    10s
     log      ${Pcell_DLTPUT_Before8370_flag}     ${Scell3_DLTPUT_Before8370_flag}
     log to console    Pcell Tput ${Pcell_DLTPUT_Before8370_flag} and Scell Tput ${Scell3_DLTPUT_Before8370_flag}
     Counters pegging Check before 8370 flag enabled
     Perform SCF delta for enabling 8370 feature flag
     SA UE Regristation With Scell Blind Addition with CB008370 flag enabled and DL UL high Traffic
     Sleep    10s
     Verify single UE DLUL CA Tput after 8370 flag ON
     ${Pcell_DLTPUT_After_8370_flag}   Run Keyword and Continue on failure  Check CA UE Pcell Scell Cell TPut On Target
     ...    ue_id=2    dir=dl    cell_type=pcell    scell_index=0    target_tp=570
     ${Scell3_DLTPUT_After_8370_flag}   Run Keyword and Continue on failure  Check CA UE Pcell Scell Cell TPut On Target
     ...    ue_id=2    dir=dl    cell_type=scell    scell_index=3    target_tp=375
     log   ${Pcell_DLTPUT_After_8370_flag}    ${Scell3_DLTPUT_After_8370_flag}
     log to console    Pcell Tput ${Pcell_DLTPUT_After_8370_flag} and Scell Tput ${Scell3_DLTPUT_After_8370_flag}
     Run keyword and Continue on failure    should be true    ${Pcell_DLTPUT_After_8370_flag} > ${Pcell_DLTPUT_Before8370_flag}
     Sleep    10s
     Counters pegging Check after 8370 flag enabled
     Collect TTI trace and check 8370_PDSCH SLIVs present in PCell and Scell  ${LOG_PATH}  ${PDSCH_SLIVs}  ${Pcell_Phy_Id}  ${Scell_Phy_Id}
*** Keywords ***
SA UE Regristation With Scell Blind Addition with CB008370 flag disabled and DL UL high Traffic
    [Arguments]  ${ca_ue_list}=${ca_UE_list}  ${DL_Rate}=${DL_RATE}  ${UL_Rate}=${UL_RATE}  ${start_trf_id}=${start_DL_trfids}
    ...   ${end_trf_id}=${end_DL_trfids}  ${pdu}=${Pdu_session_ID}  ${qfi}=${QFI_ID}  ${Traffic_rate_SA}=${Trf_rate_SA}
    ...   ${scell_pci_list}=${scell_PhyId_list_8370_9855}   ${cc_num}=${CC_NUMBER}
    #Set UEC Reordering Timer and Window size
    FOR    ${UE}    ${scell_physicalid}    IN ZIP    ${ca_ue_list}    ${scell_pci_list}
        log to console   ${UE}th  UE reg triggering now...
        UE Register should be Successful And Fetch RNTI and TDRA list    ${UE}   gw_id=1    8370_flag=0
        sleep   2s
        Verify SA All Scell PCIs With UE ID    ${UE}    ${scell_physicalid}    ${cc_num}
        Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}  pdu_id=${pdu}  qfi_id=${qfi_id}
        ...  Traffic_rate=${Traffic_rate_SA}  ul_rate=${UL_Rate}
        Trigger DL Non Bursty Data Traffic for SA with multi trfids per ue    ${UE}
        ...    ${start_trf_id}    ${end_trf_id}   ${Traffic_rate_SA}  ${DL_Rate}  ${pdu}
        sleep   2s
    END
    log to console  ${qfi}
SA UE Regristation With Scell Blind Addition with CB008370 flag enabled and DL UL high Traffic
    [Arguments]  ${ca_ue_list}=${ca_UE_list}  ${DL_Rate}=${DL_RATE}  ${UL_Rate}=${UL_RATE}  ${start_trf_id}=${start_DL_trfids}
    ...   ${end_trf_id}=${end_DL_trfids}  ${pdu}=${Pdu_session_ID}  ${qfi}=${QFI_ID}  ${Traffic_rate_SA}=${Trf_rate_SA}
    ...   ${scell_pci_list}=${scell_PhyId_list_8370_9855}   ${cc_num}=${CC_NUMBER}
    #Set UEC Reordering Timer and Window size
    FOR    ${UE}    ${scell_physicalid}    IN ZIP    ${ca_ue_list}    ${scell_pci_list}
        log to console   ${UE}th  UE reg triggering now...
        UE Register should be Successful And Fetch RNTI and TDRA list    ${UE}   gw_id=1    8370_flag=1
        sleep   2s
        Verify SA All Scell PCIs With UE ID    ${UE}    ${scell_physicalid}    ${cc_num}
        Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}  pdu_id=${pdu}  qfi_id=${qfi_id}
        ...  Traffic_rate=${Traffic_rate_SA}  ul_rate=${UL_Rate}
        Trigger DL Non Bursty Data Traffic for SA with multi trfids per ue    ${UE}
        ...    ${start_trf_id}    ${end_trf_id}   ${Traffic_rate_SA}  ${DL_Rate}  ${pdu}
        sleep   2s
    END
    log to console  ${qfi}
Counters pegging Check after 8370 flag enabled
    ${PCell_M55308C03001_8370_enabled_C1}  ${Pcell_M55308C03005_8370_enabled_C2}  ${SCell_M55308C03001_8370_enabled_C1}
    ...  ${Scell_M55308C03005_8370_enabled_C2}  ${PCell_M55335C02019_8370_enabled_C3}  ${Pcell_M55335C02020_8370_enabled_C4}
    ...  ${SCell_M55335C02019_8370_enabled_C3}  ${Scell_M55335C02020_8370_enabled_C4}
    ...  Collect Legacy and New Counters Pcell Scell  ${Pcell}  ${Scell}
    Set Variable    ${PCell_M55308C03001_8370_enabled_C1}
    Set Variable    ${Pcell_M55308C03005_8370_enabled_C2}
    Set Variable    ${SCell_M55308C03001_8370_enabled_C1}
    Set Variable    ${Scell_M55308C03005_8370_enabled_C2}
    Set Variable    ${PCell_M55335C02019_8370_enabled_C3}
    Set Variable    ${Pcell_M55335C02020_8370_enabled_C4}
    Set Variable    ${SCell_M55335C02019_8370_enabled_C3}
    Set Variable    ${Scell_M55335C02020_8370_enabled_C4}
    Run Keyword and Continue on failure    Should Be True    ${PCell_M55308C03001_8370_enabled_C1} > 0
    Run Keyword and Continue on failure    Should Be True    ${Pcell_M55308C03005_8370_enabled_C2} > 0
    Run Keyword and Continue on failure    Should Be True    ${SCell_M55308C03001_8370_enabled_C1} > 0
    Run Keyword and Continue on failure    Should Be True    ${Scell_M55308C03005_8370_enabled_C2} > 0
    Run Keyword and Continue on failure    Should Be True    ${PCell_M55335C02019_8370_enabled_C3} > 20000
    Run Keyword and Continue on failure    Should Be True    ${Scell_M55335C02019_8370_enabled_C3} > 20000
Counters pegging Check before 8370 flag enabled
    ${PCell_M55308C03001_8370_disabled_C1}  ${PCell_M55308C03005_8370_disabled_C2}  ${Scell_M55308C03001_8370_disabled_C1}
    ...  ${Scell_M55308C03005_8370_disabled_C2}  ${PCell_M55335C02019_8370_disabled_C3}  ${Pcell_M55335C02020_8370_disabled_C4}
    ...  ${SCell_M55335C02019_8370_disabled_C3}  ${Scell_M55335C02020_8370_disabled_C4}
    ...  Collect Legacy and New Counters Pcell Scell  ${Pcell}  ${Scell}
    Set Variable    ${PCell_M55308C03001_8370_disabled_C1}
    Set Variable    ${PCell_M55308C03005_8370_disabled_C2}
    Set Variable    ${Scell_M55308C03001_8370_disabled_C1}
    Set Variable    ${Scell_M55308C03005_8370_disabled_C2}
    Set Variable    ${PCell_M55335C02019_8370_disabled_C3}
    Set Variable    ${Pcell_M55335C02020_8370_disabled_C4}
    Set Variable    ${SCell_M55335C02019_8370_disabled_C3}
    Set Variable    ${Scell_M55335C02020_8370_disabled_C4}
    Run Keyword and Continue on failure    Should Be True     ${PCell_M55308C03001_8370_disabled_C1} > 0
    Run Keyword and Continue on failure    Should Be True     ${PCell_M55308C03005_8370_disabled_C2} > 0
    Run Keyword and Continue on failure    Should Be True     ${Scell_M55308C03001_8370_disabled_C1} > 0
    Run Keyword and Continue on failure    Should Be True     ${Scell_M55308C03005_8370_disabled_C2} > 0
    Run Keyword and Continue on failure    Should Be True     ${PCell_M55335C02019_8370_disabled_C3} == 0
    Run Keyword and Continue on failure    Should Be True     ${PCell_M55335C02020_8370_disabled_C4} == 0
    Run Keyword and Continue on failure    Should Be True     ${Scell_M55335C02019_8370_disabled_C3} == 0
    Run Keyword and Continue on failure    Should Be True     ${SCell_M55335C02020_8370_disabled_C4} == 0

Perform SCF delta for enabling 8370 feature flag
    Log To Console    Starting delta_commissioning CB008370_enable
    Perform SCF Delta Commissioning with Delta_Configuration_scf_8370_9855.json
    sleep  60s
    Log To Console    Done delta_commissioning CB008370_enabled.
Trigger DL Non Bursty Data Traffic for SA with multi trfids per ue
    [Arguments]   ${ue_id}  ${start_trf_id}   ${end_trf_id}  ${Traffic_rate}  ${DL_Rate}  ${pdu_id}=${Pdu_session_ID}
#    ...   ${qf_id}=${QFI_ID}
    FOR   ${trfid}  IN RANGE   ${start_trf_id}   ${end_trf_id}+1
        Trigger DL Data Traffic for SA  ue_id=${ue_id}  Traffic_rate=${Traffic_rate}  dl_rate=${DL_Rate}  pdu_id=${pdu_id}  trf_id=${trfid}
#            ...   Traffic_rate=${Traffic_rate}   dl_rate=${DL_Rate}   trf_id=${trfid}
        sleep   2s
    END
Trigger DL Traffic for NSA multi tfids per ue
    [Arguments]    ${ue_id}  ${dl_start_trf_id_NSA}  ${dl_end_trf_id_NSA}  ${Traffic_rate}  ${dl_rate}
    FOR   ${trfid}  IN RANGE   ${dl_start_trf_id_NSA}   ${dl_end_trf_id_NSA}+1
        Trigger DL Traffic for NSA  ue_id=${ue_id}  Traffic_rate=${Traffic_rate}  dl_rate=${dl_rate}  trf_id=${trfid}
    END
Verify SA All Scell PCIs With UE ID
    [Arguments]    ${ue_id}    ${scell_physicalid_list}    ${cc_num}
    [Documentation]    This keyword is to check all scell physicall id of single ue once.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | YES |  id of ue |
    ...    | ${scell_physicalid_list} | yes | the list for scell physicall id of ue |
    ...    | ${cc_num} | yes | the num for how many cc |
    ...
    ...    Examples:
    ...    | ${ue_id} |  | 1 |
    ...    | @{scell_physicalid_list} |  | 51 | 52 |
    ...    | Verify SA All Scell PCIs With UE ID | ${ue_id} | ${scell_physicalid_list} | 3 |
    ...
    ${for_num}    Evaluate    ${cc_num}-1
    FOR    ${id}    IN RANGE    ${for_num}
        ${index}    Evaluate    ${id}+1
        Verify single SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid_list}[${id}]    ${index}
    END
Verify single SA Scell PhysicalID With UE ID
    [Arguments]    ${ue_id}    ${scell_physicalid}    ${scell_index}    ${log_path}=${LOG_PATH}
    [Documentation]    This keyword is to check scell physicallid as the same as the expected one which
    ...         got from egate log with scell index
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | yes | the id of ue |
    ...    | ${scell_physicalid} | yes | the expected physicalid |
    ...    | ${scell_index} | yes | the scell index of ue need to check |
    ...    | ${log_path} | No | the path saved egate log |
    ...
    ...    Examples:
    ...    | Verify single SA Scell PhysicalID With UE ID | 1 | 51 | 1 |
    ...
#    Save Egate Log    log_path=${log_path}
    ute_wtssim.Execute Egate Command    sim_log_set flush
    OperatingSystem.Copy Files    /opt/iphy/latest/egate_console.log*    ${log_path}
    ${t_scell_id}    Fetch PhysCellId With UE Id From Egate Log    ${ue_id}    ${scell_index}    ${log_path}/egate_console.log
    Should Be True    "${scell_physicalid}"=="${t_scell_id}"
    ...    msg=the PhysicalID of ScellId${scell_index} for UE${ue_id} is ${t_scell_id}, not as the expected one ${scell_physicalid}.
Fetch PhysCellId With UE Id From Egate Log
    [Arguments]    ${ue_id}    ${scellindex}    ${egate_Log}
    [Documentation]    This keyword is to get physCellId from egate conscole Log according to sCellIndex.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id, such as 1,2,3... |
    ...    | ${scellindex} | Yes | the index for scell, such as 1,2,3... |
    ...    | ${egate_Log} | Yes | the egate console Log path |
    ...
    ...    Example:
    ...    | ${egate_Log} | Set Variable | ${CURDIR}/egate_console2.Log |
    ...    | ${physcellid_list} | Fetch PhysCellId With UE Id From Egate Log | 88 | 1 | ${egate_Log} |
    ...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}    OperatingSystem.Get File    ${egate_Log}
    ${patt}    Catenate    SEPARATOR=    UE${ue_id}\\[NR-RRC\\]: <- (DL-DCCH-NR)?[\\s\\S]*?
    ...    sCellIndex\\s${scellindex}\[\\s\\S\]*?physCellId\\s+(?P<physCellId>\\d+)[\\s\\S]*?
    ${physcellid}    String.Get Regexp Matches    ${content}    ${patt}    physCellId
    Log To Console    Get PhysCellId is ${physcellid[-1]} for UE${ue_id}
    [Return]    ${physcellid[-1]}
Set UEC Reordering Timer and Window size
    [Arguments]    ${uec_id}=1
    [Documentation]    This keyword is to set reordering timer which will impact the throughput before UE attach
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | uec_id | No | id of UEC, the default value is 1 |
    ...
    ...    Examples:
    ...    | Set Reordering Timer | 1 |  |
    ${cmd_reordering}    Catenate    SEPARATOR=${space}    uec_param id\=${uec_id}
    ...    reordering_window_size\=${REORDERING_WINDOW_SIZE} reordering_timer\=${REORDERING_TIMER}
    ute_wtssim.Execute Egate Command    cmd=${cmd_reordering}
Verify single UE DLUL CA Tput before 8370 flag OFF
        Wait Until Keyword Succeeds    60s    3sec    Verify Multi UE All DLCA And 2CCULCA tput    ${ca_UE_list}
        ...    ${expected_UL_TP_list_before_flag}   ${expected_DL_TP_list_before_flag}  ${CC_NUMBER}

Verify single UE DLUL CA Tput after 8370 flag ON
        Wait Until Keyword Succeeds    60s    3sec    Verify Multi UE All DLCA And 2CCULCA tput    ${ca_UE_list}
        ...    ${expected_UL_TP_list_after_flag}  ${expected_DL_TP_list_after_flag}  ${CC_NUMBER}

Verify Multi UE All DLCA And 2CCULCA tput
    [Arguments]    ${ue_id_list}    ${exp_ul_tput_list}    ${exp_dl_tput_list}   ${dl_cc_num}
    [Documentation]    This keyword is to check all dl Pcell Scell TP of multi ue at the same time.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id_list} | YES | the list of ue id |
    ...    | ${exp_ul_tput_list} | yes | the list for UL expected tput of ue pcell ,scell |
    ...    | ${exp_dl_tput_list} | yes | the list for DL expected tput of ue pcell ,scell |
    ...    | ${cc_num} | yes | the num for how many cc for dl CA |
    ...
    ...    Examples:
    ...    | @{ue_id} |  | 1 | 2 | 4 |
    ...    | @{exp_ul_tput_list} |  | 5 | 5 |
    ...    | @{exp_dl_tput_list} |  | 200 | 100 | 100 |
    ...    | Verify Multi UE All DLCA And 2CCULCA tput | ${ue_id} | ${exp_ul_tput_list} | ${exp_dl_tput_list} | 3 |
    ...
    FOR    ${ue_id}    IN    @{ue_id_list}
        Run Keyword And Continue On Failure    Verify Single UE UE DL All Pcell Scell TP    ${ue_id}    ${exp_dl_tput_list}    ${dl_cc_num}
        Run Keyword And Continue On Failure    Verify Single UE 2CCUL Pcell Scell TP    ${ue_id}    ${exp_ul_tput_list}    ${dl_cc_num}
    END
Verify Single UE UE DL All Pcell Scell TP
    [Arguments]    ${ue_id}    ${exp_dl_tput_list}    ${cc_num}
    [Documentation]    This keyword is to check all dl Pcell Scell TP of single ue once.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | YES |  id of ue |
    ...    | ${exp_dl_tput_list} | yes | the list for DL expected tput of ue pcell ,scell |
    ...    | ${cc_num} | yes | the num for how many cc |
    ...
    ...    Examples:
    ...    | ${ue_id} |  | 1 |
    ...    | @{exp_dl_tput_list} |  | 200 | 100 | 100 |
    ...    | Verify Single UE UE DL All Pcell Scell TP | ${ue_id} | ${exp_dl_tput_list} | 3 |
    ...
    FOR    ${id}    IN RANGE    ${cc_num}
        Run Keyword If    ${id}==${0}    Run Keyword And Continue On Failure   Check CA UE Pcell Scell Cell TPut On Target
        ...    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${exp_dl_tput_list[0]}

        ...    ELSE    Run Keyword And Continue On Failure   Check CA UE Pcell Scell Cell TPut On Target
        ...    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=${id}    target_tp=${exp_dl_tput_list[${id}]}
    END
Verify Single UE 2CCUL Pcell Scell TP
    [Arguments]    ${ue_id}    ${exp_ul_tput_list}    ${dl_cc_num}
    [Documentation]    This keyword is to check all ul Pcell Scell TP of single ue once.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | YES |  id of ue |
    ...    | ${exp_ul_tput_list} | yes | the list for UL expected tput of ue pcell ,scell |
    ...    | ${dl_cc_num} | yes | the num for how many cc for dl CA |
    ...
    ...    Examples:
    ...    | ${ue_id} |  | 1 |
    ...    | @{exp_ul_tput_list} |  | 20 | 10 |
    ...    | Check UE 2CCUL Pcell Scell TP On Target For Single UE | ${ue_id} | ${exp_dl_tput_list} | 3 |
    ...
    FOR    ${id}    IN RANGE    2
        Run Keyword If    ${id}==${0}    Run Keyword And Continue On Failure    Check CA UE Pcell Scell Cell TPut On Target
        ...    ue_id=${ue_id}    dir=ul    cell_type=pcell    scell_index=0    target_tp=${exp_ul_tput_list[0]}
        ...    ELSE    Run Keyword And Continue On Failure    Check ULCA Scell L1 Cell Tput On Target
        ...    ue_id=${ue_id}    dl_cc_num=${dl_cc_num}    target_tp=${exp_ul_tput_list[1]}
    END
Check CA UE Pcell Scell Cell TPut On Target
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}    ${target_tp}
    ${tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
    Should Be True    ${tput}>=${target_tp}
    ...    msg=UE${ue_id} ${cell_type}${scell_index} tput is '${tput}'' not on target'${target_tp}'Mb
    Log To Console    \nUE${ue_id} ${cell_type} ${scell_index} ${dir} tput ${tput}Mb is on target: ${target_tp}Mb
    [RETURN]    ${tput}

Check ULCA Scell L1 Cell Tput On Target
    [Arguments]    ${ue_id}    ${dl_cc_num}    ${target_tp}
    ${tput}    Get ULCA SCell L1 Average Throughput    ${ue_id}    ${dl_cc_num}
    Should Be True    ${tput}>=${target_tp}
    ...    msg=UE${ue_id} UL scell tput is '${tput}'' not on target'${target_tp}'Mb
    Log To Console    \nUE${ue_id} UL scell tput ${tput} is on target: ${target_tp}Mb
Get CA Cell Average Throughput
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
    [Documentation]    This keyword is to get Pcell/Scell Average throughput,1Mbps=1000Kbps
    ...    The unit of return throughput is Mbps.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id |
    ...    | ${dir} | Yes | dl/ul |
    ...    | ${cell_type} | Yes | pcell/scell |
    ...    | ${scell_index} | Yes | 1/2/3...|
    ...
    ...    | Examples: |
    ...    | ${pcell_tput} | Get CA Cell Average Throughput | 1 | dl | pcell | 0 |
    ...    | ${scell1_tput} | Get CA Cell Average Throughput | 1 | dl | scell | 1 |
    ...    | ${scell2_tput} | Get CA Cell Average Throughput | 1 | ul | scell | 2 |
    ...
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=${type} scell\=${scell_index}
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    ${cell_tp}=    Evaluate    sum(map(float,${avg_tp_list}))
    ${cell_tp}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
    ${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
    ${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
    Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
    ${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
    ${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
    ...                                     '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
    ...                                     ${cell_tp}
    [Return]    ${cell_tput_Mbps}
