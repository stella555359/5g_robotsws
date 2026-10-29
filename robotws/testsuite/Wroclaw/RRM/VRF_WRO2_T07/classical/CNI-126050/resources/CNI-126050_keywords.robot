*** Settings ***
Documentation
...   author:        Marcin Wolczynski
...   contact:       marcin.wolczynski@nokia.com
...   Description:   Feature CNI-126050

Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CNI-126050/resources/test_specific_keywords_126050.robot
Library        taf.ue
Library        taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CNI-126050/resources/test_specific_keywords_126050.py

Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CNI-126050/resources/test_specific_keywords_126050.py

*** Variables ***
${UE_1}             REAL_UE_SA
${UE_1_alias}       UE_1
${UE_2}             REAL_UE_NSA
${UE_2_alias}       UE_2
${CellFilter}           1
@{cou_s_avg}     M55360C00001
@{cou_e_avg}     M55360C00078
@{cou_s_max}     M55360C01001
@{cou_e_max}     M55360C01078
@{counter_group_avg}    M55360C000
@{counter_group_max}    M55360C010



*** Keywords ***
[1]CNI-126050_Verification_of_different_interference_low_enabledWithPrach_pucch_SA
	[Documentation]   This test case is for 8409 feature with interferences
	AdminUtils.unlock_all_cells
    AdminUtils.trigger_site_reset_and_wait_for_on_air
    preparing for counters time setting CNI 126050
    lock cell 126050 2
    Attach Ue            ${UE_2_alias}
    Data Transfer procedure 126050      ${UE_2_alias}
    QRX lev min and attenuation for cell
    attenuation 126050 attach cell 1
    Unlock Cell for test
    start logging pcap 126050
    Attach Ue            ${UE_1_alias}
    Data Transfer procedure 126050      ${UE_1_alias}
    stop logging pcap 126050
    Wait for next counter interval 126050
    Data transfer check procedure 126050    ${UE_1_alias}   ${UE_2_alias}
    Wait for next counter interval 126050
    Data Transfer Stop procedure 126050     ${UE_1_alias}   ${UE_2_alias}
    Verify counters with interferences 126050   ${cou_s_avg}   ${cou_e_avg}  ${TEST_NAME}
    ...     ${counter_group_avg}    ${cou_s_max}   ${cou_e_max}   ${counter_group_max}
    Bip and pcap check 126050   ${LOG_PATH}    ${filter_bip1}  ${filter_bip2}
