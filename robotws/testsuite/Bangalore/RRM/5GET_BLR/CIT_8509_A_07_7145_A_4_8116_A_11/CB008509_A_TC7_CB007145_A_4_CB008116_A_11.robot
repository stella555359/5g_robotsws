*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD     5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Resource         ./CB008509_Resource.robot
Resource         ../resources/ECEcommon/common_setup_teardown.robot
Resource         ./CB007145_Resource.robot
Resource         ./basic_resource.robot
Library          SSHLibrary

Documentation
...
...             author:            Navin Kumar Ray, navin.kumar_ray@nokia
...             maintainer:        Navin Kumar Ray, navin.kumar_ray@nokia
...
...             INTRODUCTION:     This scenario covers counter verification of Artificial Load on PDSCH symbols in a
...                               cell when PRB pooling is deactivated, beam forming is disabled and 5GC002558 is enabled

...             TEST SET NAME:    CB008509-A_TC7_covers counter verification of Artificial Load on PDSCH symbols in a
...                               cell when PRB pooling is deactivated, beam forming is disabled and 5GC002558 is enabled
...             TESTING SPLIT:    See CB008509 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB8509 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_19130,CB_FIM_35029

*** Variables ***
${wts_cfg_file_1}     ${CURDIR}/config/wts/basic_setup_tmo.cfg
${wts_cfg_file_2}     ${CURDIR}/config/wts/basic_setup_n28_40MHZ_band.cfg
#${wts_cfg_file_3}     ${CURDIR}/config/wts/basic_setup_gen.cfg
${wts_cfg_file_3}   ${CURDIR}/config/wts/basic_setup_gen_rjio.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${1}
${TEST_NAME}     TC7
${DL_SLOTS_BELOW_TGT_LOAD}    M55308C00043
${DL_SLOTS_ARTIFICIAL_LOAD}    M55308C00044
${DL_PRB_ARTIFICIAL_LOAD}    M55308C00045
${TRS_SLOTS}    M55308C00046
${SS_BURST_SLOTS}    M55308C00003
${DL_DATA_SLOTS}     M55308C00001
${PRB_USED_PDSCH}     M55308C10001
${MAX_LOAD_PERCENT}    50

${SCFC}=        ${CURDIR}/config/SCF/CIT_A_11_US3_UPIP_TDD_scf.xml
${AP_XML}=      ${CURDIR}/config/SCF/CIT_A_11_US3_UPIP_TDD_iphy.xml
&{ciph}         nea0=1      nea1_128=2  nea2_128=4  nea3_128=3
&{intgr}        nia0=1      nia1_128=2  nia2_128=4  nia3_128=3
${ip_prof}      null
${ip_prof1}      snow3g
${ip_prof2}      aes
${ip_prof3}      zuc
&{ue_profile}    ${1}=${ip_prof2}    ${2}=${ip_prof2}  ${3}=${ip_prof2}  ${4}=${ip_prof3}
...              ${5}=${ip_prof}+${ip_prof1}  ${6}=${ip_prof3}+${ip_prof2}  ${7}=${ip_prof1}+${ip_prof3}
&{ip_ie}    ${1}=required       ${2}=required     ${3}=required   ${4}=required       ${5}=required
&{max_ip_rate}    ${1}=maximum-UE-rate      ${2}=maximum-UE-rate     ${3}=maximum-UE-rate   ${4}=maximum-UE-rate       ${5}=maximum-UE-rate
&{max_ip_rate_dl}    ${1}=maximum-UE-rate     ${2}=maximum-UE-rate     ${3}=maximum-UE-rate    ${4}=maximum-UE-rate       ${5}=maximum-UE-rate
&{ip_result}      ${1}=performed     ${2}=performed     ${3}=performed    ${4}=not-performed       ${5}=not-performed

${st_ue_id_1}      ${1}
${en_ue_id_1}      ${2}
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

@{QOS_Prof1}                1
@{QOS_Prof1_speed_ul}       1
@{QOS_Prof1_speed_dl}       1
@{QOS_Prof1_unit}           kbps

@{QOS_Prof2}                1           20
@{QOS_Prof2_speed_ul}       1           5
@{QOS_Prof2_speed_dl}       1           5
@{QOS_Prof2_unit}           kbps        mbps

@{QOS_Prof3}               1
@{QOS_Prof3_speed_ul}      10
@{QOS_Prof3_speed_dl}      10
@{QOS_Prof3_unit}          mbps

@{QOS_Prof7}               1        2          3                20
@{QOS_Prof7_speed_ul}      5       32         amr_wb_18_25     3
@{QOS_Prof7_speed_dl}      5       32         amr_wb_18_25     3
@{QOS_Prof7_unit}          mbps    kbps        rtp_codec        mbps

${nsa_st_ue_id}      ${151}
${nsa_en_ue_id}      ${155}

${sa_st_ue_id}      ${51}
${sa_en_ue_id}      ${55}
${AP_XML_8509}      ${CURDIR}/config/SCF/IPHY_CIT_8509_TMO.xml
${IPHY_FILE}        ${CURDIR}/config/SCF/IPHY_CIT_8509_TMO.xml

${radparam}                SEPARATOR=${EMPTY}    0x890073=0

*** Test Cases ***
[1][1.0] CB008509-A_TC7_Counter_Validation_Generating_Dummy_load_on_PDSCH_without_PRB_pooling_FDD_non_BF_5GC002558
    [Tags]     TC01
    [Setup]             Run keywords     Suite setup from scratch
    ...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
    ...                 AND     sleep   60s
    ...                 AND     Update bsr package_TMO_65
    ...                 AND     sleep   180s
    ...                 AND     Add RD Parameters To GNB Swconfig File    ${radparam}
    ...                 AND     Enable CPRT Debug Log
    ...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_tmo.json
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Sleep   360s    reason=wait for RMOD- to comeup
    ...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file_1}

    X2AP Link Should be UP
    ${header}     Create list    type    3gpp.subcellid    3gpp.sfn    3gpp.slot     3gpp.rnti    DlData_PdschGrant.numOfPrb
    ...           DlData_PdschGrant.rat0Bitmap   DlData_PdschGrant.mcs    DlData_PdschGrant.mcsTable

    ${targetload}    Calculate Target Load Sector Beam    ${106}    ${1}    ${50}    nbrOfBlankedPRBsHighEdgeDL=${4}
    ...    nbrOfBlankedPRBsLowEdgeDL=${4}
    log to console    targetload-${targetload}
    Wait until the next Measurement Period starts  additional_time=${0}
    Start Log    biptaf
    sleep    1s
    ${scen1}     Stop Log     biptaf    test_scenario=cell_idle
    ${CsvPath1}     Convert PCAP to CSV    ${scen1}[biptaf]   dldata_pdschsendreql1sw    dldata_pdschsendreql1sw    @{header}
    sleep    300s
    Wait until the current Measurement Period stops
    CB008509 Collect PM Counters New
    Get buffer counters and validate    ${DL_SLOTS_BELOW_TGT_LOAD}    ${DL_SLOTS_ARTIFICIAL_LOAD}
    ...    ${DL_PRB_ARTIFICIAL_LOAD}    ${TRS_SLOTS}    ${SS_BURST_SLOTS}    ${DL_DATA_SLOTS}    ${PRB_USED_PDSCH}
    ...    ${MAX_LOAD_PERCENT}    1    ${targetload}
#Step-2: attach 1 UE, UE-1
#    ${crnti_list_1}=      MultiUE Register should be Successful    81   81    pdu_id=1     nw_id=1

#Step-3: start data transfer from UE-1 so that no of PRBs used by UE-1(e.g. Y-PRBS) is less than PRB defined by
#        targetTotalLoadSectorBeam (X-PRBs)
    Wait until the next Measurement Period starts  additional_time=${0}
    ${crnti_list_1}=      MultiUE Register should be Successful    81   81    pdu_id=1     nw_id=1
    MultiUE Trigger DL Traffic for SA    81  81    Traffic_rate=mbps     dl_rate=2     pdu_id=1    trf_id=1       qfi_id=1
    MultiUE Trigger UL Traffic for SA    81  81    Traffic_rate=mbps     ul_rate=2     pdu_id=1    trf_id=1       qfi_id=1
    sleep    120s
    Start Log    biptaf
    sleep    1s
    ${scen2}     Stop Log     biptaf    test_scenario=with_1_real_ue
    ${CsvPath2}     Convert PCAP to CSV    ${scen2}[biptaf]    dldata_pdschsendreql1sw    dldata_pdschsendreql1sw    @{header}

    Wait until the current Measurement Period stops
    CB008509 Collect PM Counters New
    Get buffer counters and validate    ${DL_SLOTS_BELOW_TGT_LOAD}    ${DL_SLOTS_ARTIFICIAL_LOAD}
    ...    ${DL_PRB_ARTIFICIAL_LOAD}    ${TRS_SLOTS}    ${SS_BURST_SLOTS}    ${DL_DATA_SLOTS}    ${PRB_USED_PDSCH}
    ...    ${MAX_LOAD_PERCENT}    2    ${targetload}

    Wait until the next Measurement Period starts  additional_time=${0}
    MultiUE Trigger DL Traffic for SA    81  81    Traffic_rate=mbps     dl_rate=175     pdu_id=1    trf_id=1       qfi_id=1
    MultiUE Trigger DL Traffic for SA    81  81    Traffic_rate=mbps     dl_rate=150     pdu_id=1    trf_id=2       qfi_id=1
    MultiUE Trigger UL Traffic for SA    81  81    Traffic_rate=mbps     ul_rate=150     pdu_id=1    trf_id=1       qfi_id=1

    Start Log    biptaf
    sleep    1s
    ${scen3}     Stop Log     biptaf    test_scenario=with_1_real_ue
    ${CsvPath3}     Convert PCAP to CSV    ${scen3}[biptaf]    dldata_pdschsendreql1sw    dldata_pdschsendreql1sw    @{header}
    sleep    800s
    Wait until the current Measurement Period stops  additional_time=${1200}
    CB008509 Collect PM Counters New
    Get buffer counters and validate    ${DL_SLOTS_BELOW_TGT_LOAD}    ${DL_SLOTS_ARTIFICIAL_LOAD}
    ...    ${DL_PRB_ARTIFICIAL_LOAD}    ${TRS_SLOTS}    ${SS_BURST_SLOTS}    ${DL_DATA_SLOTS}    ${PRB_USED_PDSCH}
    ...    ${MAX_LOAD_PERCENT}    3    ${targetload}

    sleep    60s
    Stop MultiUE Data Traffic for SA     81  81
    MultiUE Deregister should be Successful   81  81

	[Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     Kill WTS processes Using WTS_Runner
    ...             AND     Run Keyword and Ignore Error     Link SCOUT SCF to Configuration ID for Reporting

[1]CB007145_A#4_SgNBAdditionSuccess_ULandDLDataSuccess_of_FDD_40Mhz_n28RU_Long PUCCH_Multi_UE
    [Tags]     TC02
	[Setup]             Run keywords     Suite setup from scratch
    ...                 AND     Change IPHY File Value AP ABIO      AHPH       1954
#	...                 AND     Change CFG File Value   ${wts_cfg_file2}       145100     156440    ${sa_nr_cap_band28}
#	...                 ${nsa_nr_cap_band28}     ${nsa_nr_mrdc_band28}
	...                 AND     Perform SCF Delta Commissioning with Delta_config_40MHZ_2CC_n28_AHPH.json
	...                 AND     sleep    10
	...                 AND     Reboot gNB System Module from Console and check Airscale is ready
#	...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
	...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file_2}

#Starting CPRT Trace Capturing
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    log to console   UE attach trigerring now...

    MultiUE Attach for NSA_7145    ${nsa_st_ue_id}    ${nsa_en_ue_id}
    MultiUE DL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    10    id=2    trf_id=1
    MultiUE UL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    10    id=2    trf_id=1

    sleep   180s

    MultiUE Validate DL Traffic For NSA     ${nsa_st_ue_id}     ${nsa_en_ue_id}     2       10
    MultiUE Validate UL Traffic For NSA     ${nsa_st_ue_id}     ${nsa_en_ue_id}     2       10

    MultiUE DL Traffic Stop for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    2    1
    MultiUE UL Traffic Stop for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    2    1
    MultiUE Detach for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}

	[Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     Kill WTS processes Using WTS_Runner
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

[1]CB007145_A#5_SAUEAttachSuccess_ULandDLDataSuccess_of_FDD_40Mhz_n28RU_Long PUCCH_Multi_UE
    [Tags]     TC03
    set test variable      ${LOG_PATH}
#    X2AP Link Should be UP
    log to console   UE attach trigerring now...

    MultiUE Register should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}    pdu_id=1    nw_id=1

    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  10  pdu_id=1  trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  10  pdu_id=1  trf_id=1    qfi_id=1

    sleep   180s

    Validate DL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_en_ue_id}     dl_rate=10   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_en_ue_id}     ul_rate=10   pdu_id=1   qfi_id=1

    MultiUE Deregister should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}

	[Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     Kill WTS processes Using WTS_Runner
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting


[1]CB008116_A_11_US3_UPIP_traffic_Two_UEs_with_same_UPIPAlgos_UE1-Req-AES_UE2-Req-AES-MaxUERate-DL_5QI9_TDD_LN
    [Tags]     TC04
#	[Setup]             Run keywords     Prepare TL with all config files
#    ...                 AND     Suite setup from scratch
#    ...                 AND     update_delta_and_create.update_and_gen    ${CURDIR}/config/SBTS25R3/basic_delta.json   ${intgr}    ${ciph}
#    ...                 AND     Sleep       10
#    ...                 AND     gnb.Perform gNB reboot
#    ...                 AND     Sleep   360s    reason=wait for RMOD- to comeup
#    ...                 AND     update_delta_and_create.update_cfg  ${CURDIR}/config/wts/basic_setup_2CC_tdd_ref.cfg      ${ue_profile}
#    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
    [Setup]             Run keywords     Suite setup from scratch
     ...                 AND     Add RadParam to swconfig      ${radparam}
    ...                 AND     Update bsr package
    ...                 AND     Perform SCF Delta Commissioning with 8116_a_11_rjio.json
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Sleep   360s    reason=wait for RMOD- to comeup
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file3}

    Set Suite Variable    ${ip_ie}      &{ip_ie}
    Set Suite Variable    ${max_ip_rate}      &{max_ip_rate}
    Set Suite Variable    ${max_ip_rate_dl}      &{max_ip_rate_dl}
    Set Suite Variable    ${ip_result}      &{ip_result}
    Set Suite Variable    ${ue_profile}      &{ue_profile}
    Increase Buffer Size for VM and IPHY
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof3}              ${2}=${QOS_Prof3}
    ...     ${3}=${QOS_Prof3}                ${4}=${QOS_Prof2}      ${5}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof3_speed_ul}     ${2}=${QOS_Prof3_speed_ul}
    ...     ${3}=${QOS_Prof3_speed_ul}     ${4}=${QOS_Prof2_speed_ul}     ${5}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof3_speed_dl}     ${2}=${QOS_Prof3_speed_dl}
    ...     ${3}=${QOS_Prof3_speed_dl}     ${4}=${QOS_Prof2_speed_dl}   ${5}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof3_unit}         ${2}=${QOS_Prof3_unit}
    ...     ${3}=${QOS_Prof3_unit}            ${4}=${QOS_Prof2_unit}       ${5}=${QOS_Prof2_unit}

    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom      ${st_ue_id}    ${en_ue_id}   pdu_session_setup   ${ip_ie}
    ...      ${max_ip_rate}     pdu_id=1    nw_id=1

    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    180
    ${trf_id}      Set Variable    ${1}
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${duration}s

    Check Integrity failure count
    ${nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr    ${st_ue_id}    ${en_ue_id}    ${duration}    both   ${trf_id}
    ...    ${qos_profile_unit}    ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}


	[Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     Kill WTS processes Using WTS_Runner
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    admin.setup admin
    ${ret}     admin.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    admin.teardown admin


Add RadParam to swconfig
    [Documentation]    This keyword will append the flags to swconfig.txt file.
    ...      Usage: Add RadParam to swconfig     "0x58057f=50"    "0x58057a=50"      IP=192.168.255.129
    [Arguments]    @{flag_list}
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    192.168.255.129
    SSHLibrary.login    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    FOR    ${flag}    IN    @{flag_list}
    SSHLibrary.execute command    echo "${flag}" >> /ffs/run/swconfig.txt
    END
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection
