*** Settings ***
Force Tags      CLOUD_5G_I_LOO_AP_LOOO
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 lavanya.t_v@nokia.com
...             maintainer:             lavanya.t_v@nokia.com
...
...             INTRODUCTION:      CB013468
...             TEST SET NAME:     CB013468
...             TESTING SPLIT:     See CB013468 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB013468 CFAM

#Library          Dialogs
Resource         ./CB013468_Resource.robot
#Resource         ../../../resources/robot/WTS_Runner_Keywords.robot

Suite Setup         Run keywords    Log To console  Suitesetup
...                 AND     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with delta_set_IWK_precondition.json
#...                 AND     Perform SCF Delta Commissioning with delta_set_ScellAlloc_0.json
...                 AND     sleep   5s
#...                 AND     Add RD Parameters To GNB Swconfig File    ${radparam}
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Enhanced Buffer Size for VM and IPHY
...                 AND     Load CFG and verify cell status TMO     ${wts_cfg_file}		${cell_list}
...                 AND     NSA X2AP Link Should be UP    ${eNB_ID}		${eNB_target}

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Stop log     cprt   btslog    test_scenario=ue_suite_tear_sgnb_modify
...                 AND     Stop Log     snapshot   sosreport

Test Teardown       Run keywords
...                 Run Keyword and Ignore Error   NSA Multi UE Detach should be Successful    ${st_nsa_ue}     ${en_nsa_ue}
...                 AND      Stop log     cprt   btslog    test_scenario=ue_test_tear_sgnb_modify
...                 AND      Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_FR71_5_6.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}     /tmp/

${nwslice_ID}           ${1}
${Pdu_session_ID}       ${1}
${eNB_ID}               ${1}
${eNB_target}           ${2}
${start_cell}           1
@{cell_list}            1
${TEST_NAME}            CB013468_DB12
${radparam}             SEPARATOR=${EMPTY}    0x890073=0;0x590072=1;0x8900B0=1;0x590089=0

#${ue_eutra_nr_cap}        SEPARATOR=
#...
${ue_eutra_nr_cap}          SEPARATOR=
...         a107c588868201d03000c8181903032060640c0c818190303206000002219a080740ce3b2067640c0c818190303206000102219a080740c
...         0032067640cec818190303206000202219a080740c61b2063640c0c818190303206000102219a080740c0032063640c6c818190303206000202215a080740cf3b20
...         67640c0c818190300018110ad0403a0671d9033f2060640c0c8180010088568201d03000c819f9033b2060640c000a0442b4100e819c7640cec819d903032060006
...         02215a080740c0032067640cec819d903000381108d0403a0671d9033b2067640ce010044234100e818e3640c7c8181903000481108d0403a060019031f2063e40c0014
...         044234100e818c3640c6c818d903180401106d0403a0681d9033f206000b0220da080740cf3b2068640c00180441b4100e81800640d0c819e0340887682009043a06001
...         903032060640c0c818190300070110ad0401208740c61b2063640c0c818003c0885682009043a060019031b2063640c00200441b41004821d031c6c818e044088260c00
...         8183a006100480801c10382000182088804062a2d4274e9d3a74e9d3a76cf1e5cc9d3a74e9d3a76cf1e5cc9d3a74e9d3a76cf1e5cc9d3a74e9d3a76cf1e5cc9d3a74e9d
...         3a76cf1e5ca9d3a74e9d3b678f2e54e9d3a74e9db3c7972a74e9d3a74ed9e3cb953a74e9d3a76cf1e5ca9d3a74e9d3b678f2e44e9d3a74ed9e3cb913a74e9d3b678f2e4
...         4e9d3a74ed9e3cb913a74e9d3b678f2e34e9d3a76cf1e5c69d3a74ed9e3cb8d3a74e9db3c7973a74e9d3a74e9d3b678f2e54e9d3a74e9db3c7972a74e9d3a74ed9e3cb8
...         d3a74e9db3c7971274e9db3c79610124000080202038038080e00002038000080e00002038000080e00002038000080e0006000100404078060101e00004070000101c0
...         0004070000101c000c0002008080e00e0203c000080f00002038000080e0000203800140004010102001804078000101c00004070000101c000a0002008080f00c02040
...         000080e00002038000080e0005000100404070070102000004078000101c0000407000280008020203c030080f0000203c000080e0000203800140004010101c01c0407
...         8000101e00004078000101c00080002008080f00c0203c000080f0000203c00100004010102001804080000101c00004070002000080202038038081000002040000080
...         e0003000100404088060102000004070001800080202040030081100002038000c0004010101c01c040880001020000e000200800080002038038080e00002038000080
...         e00002038000080e000500010040004000101e01804078000101c0000407000280008020002000080e00e0203c000080f00002038000c00040100010000408006010200
...         0040002008000800020480300

${ue_nr_cap}          SEPARATOR=
...         ef201000074f5e13020002044009049830004c1a0e00c4034026010188a0300a6105aa0d89dac1184341020f940a0b2d931543439f11c7a067d813e31cf9863ca1607038
...         782e00000003800000001a000e0541b137582308682041f2814165b262a86873e238f40cfb027c639f30c7942c0e070f05c0013c0070004f00034001c0a836266b04610d
...         04083e50282cb64c550d0e7c471e819f604f9473e618f28581c0e1e0b80000000e000000006800381507c46d608c21a08107ca050496c98aa0a1cf88e3c639f30c7942c0
...         e070f027f0000001fc0000000d000702a0f883ac1184341020f940a092d931541439f11c78c73e618f28581c0e1e04fe0000003f80000001a000e0741b0a303582308682
...         041f2814165b262a86873e238f40cfb027c639f30c7942c0e070f05c0012c0070004b00034001c0a83e0deb04610d04083e502824b64c55050e7c471e31cf9863ca16070
...         387813fa000000fe80000006800381507c18d608c21a08107ca050496c98aa0a1cf88e3c639f30c7942c0e070f027f0000001fc0000000d000702a0f80dac1184341020f
...         940a092d931541439f11c78c73e618f28581c0e1e04fe0000003f80000001a000e0541f00b582308682041f2814125b262a82873e238f18e7cc31e50b0381c3c09fc0000
...         007f000000034001c0a83e00eb04610d04083e502824b64c55050e7c471e31cf9863ca16070387813f8000000fe00000006800381507c00d608c21a08107ca050496c98a
...         a0a1cf88e3c639f30c7942c0e070f027f6000001fd8000000d000702a05a07bc718438005479f8a0a08fdb31552003c78010e208308a8147efe40dc6e306400301502d00
...         de38c21c002a3cfc505047ed98aa9001e3c0087104184540a3f7f206e37183200180a81680ef1c610e00151e7e282823f6cc554800f1e00438820c22a051fbf90370b841
...         9000c0541b0bf582308682041f2814165b262a86873e238f40cfb027c639f30c7942c0e070f09c001200070004800034001c0a83613eb04610d04083e50282cb64c550d0
...         e7c471e819f604f8c73e618f28581c0e1e1380007800e0001e0006800381506c25d608c21a08107ca050596c98aa1a1cf88e3d033ec09f18e7cc31e50b0381c3c2700040
...         001c00100000d000702a0f827ac1184341020f940a092d931541439f11c78c73e618f28581c0e1e04fe0000003f80000001a000e0541f037582308682041f2814125b262
...         a82873e238f18e7cc31e50b0381c3c09f00000007c000000034001c0a83e05eb04610d04083e502824b64c55050e7c471e31cf9863ca16070387813f0000000fc0000000
...         6800381507c07d608c21a08107ca050496c98aa0a1cf88e3c639f30c7942c0e070f027f0000001fc0000000d000702a0f809ac1184341020f940a092d931541439f11c78
...         c73e618f28581c0e1e04fe0000003f80000001a000e0001820001bd04c00e000a070500603009401c0018030140140a00400000041c04d0001cf9863ca16060500200100
...         0640e026a00021c41021150203e0b0020000000100000200800002004000018020000100100000b24a00406018b925000031724a00c0601806018b9250040300c031724a
...         014060180601806018b9250080300c0300c031724a01c06018060180601806018b925000030724a0040601839250040300c030724a00c0601806018392500e0300c0300c
...         0300c0300c180200001c01000010008000090040000500200002c0b654de54d6065606d60a560cd6e91933594b591b5809581140f04000025949410000196525040000a5
...         949010000396524040001259490100c05014050165949410000596525040001a5949010040601a594901000079652404000225949010000996524040002a5949010000b9
...         652404000325949010000d965240354aaae95555038aa0b1541a2abb515d88a55174aa2a93455298aa47154062a814507039016a050381c0e07008040201008040201008
...         040201028140a0703800314060682848c8

*** Test Cases ***
CB013468D#B71_UE_in_ENDC_mode_SgNB_Mod_Request_with_the_same_allowedBC-ListMRDC_and_diff_CapabilityInfo_IE_and_Meas_Gaps_change_received
    [tags]    DB12

    ${st_nsa_ue}     Set Variable             ${11}
    ${en_nsa_ue}     Set Variable             ${12}
    ${st_nsa_ue1}     Set Variable             ${13}
    ${en_nsa_ue1}     Set Variable             ${14}
    ${st_nsa_ue2}     Set Variable             ${15}
    ${en_nsa_ue2}     Set Variable             ${16}
    ${Target_Cell_fdd}     Set Variable        ${1}
    #Attach NSA UE for FDD
    ${crnti_list_nsa_fdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=23:1,2|22:1,2

    ${crnti_list_nsa_fdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${en_nsa_ue}    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=23:1,2|22:1,2
    ${crnti_list_nsa_fdd3}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue1}    ${st_nsa_ue1}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=23:1,2|22:1,2

    ${crnti_list_nsa_fdd4}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${en_nsa_ue1}    ${en_nsa_ue1}    meas_gap_config=off   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=23:1,2|22:1,2

     ${crnti_list_nsa_fdd5}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue2}    ${st_nsa_ue2}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=23:1,2|22:1,2

    ${crnti_list_nsa_fdd6}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${en_nsa_ue2}    ${en_nsa_ue2}    meas_gap_config=off   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=23:1,2|22:1,2

    ${crnti_list_nsa_fdd_1} 	Combine Lists   ${crnti_list_nsa_fdd1}    ${crnti_list_nsa_fdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_fdd_1}

    ${crnti_list_nsa_fdd_2} 	Combine Lists   ${crnti_list_nsa_fdd3}    ${crnti_list_nsa_fdd4}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_fdd_2}

     ${crnti_list_nsa_fdd_3} 	Combine Lists   ${crnti_list_nsa_fdd5}    ${crnti_list_nsa_fdd6}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_fdd_3}
    sleep   5s
    ${avg_data_pre}    Create List
    ${avg_dl_pre}    Create Dictionary   11=${avg_data_pre}   12=${avg_data_pre}    13=${avg_data_pre}   14=${avg_data_pre}
    ...     15=${avg_data_pre}   16=${avg_data_pre}
    ${avg_ul_pre}    Create Dictionary   11=${avg_data_pre}   12=${avg_data_pre}    13=${avg_data_pre}   14=${avg_data_pre}
    ...     15=${avg_data_pre}   16=${avg_data_pre}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     75     id=2    trf_id=1
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     75     id=2    trf_id=2
#    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     75     id=2    trf_id=3
#    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     75     id=2    trf_id=4
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     50     id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     50     id=2    trf_id=2

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue1}    ${en_nsa_ue1}   mbps     75     id=2    trf_id=1
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue1}    ${en_nsa_ue1}   mbps     75     id=2    trf_id=2
#    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue1}    ${en_nsa_ue1}   mbps     75     id=2    trf_id=3
#    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue1}    ${en_nsa_ue1}   mbps     75     id=2    trf_id=4
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue1}    ${en_nsa_ue1}   mbps     50     id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue1}    ${en_nsa_ue1}   mbps     50     id=2    trf_id=2

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue2}    ${en_nsa_ue2}   mbps     75     id=2    trf_id=1
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue2}    ${en_nsa_ue2}   mbps     75     id=2    trf_id=2
#    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue2}    ${en_nsa_ue1}   mbps     75     id=2    trf_id=3
#    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue2}    ${en_nsa_ue1}   mbps     75     id=2    trf_id=4
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue2}    ${en_nsa_ue2}   mbps     50     id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue2}    ${en_nsa_ue2}   mbps     50     id=2    trf_id=2

    sleep   10s
    ${pre_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_pre}    pscell=8     scell=15
    log to console    pre_avg_data_dl-${pre_avg_data_dl}
    ${pre_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_pre}   pscell=8     scell=10
    log to console    pre_avg_data_ul-${pre_avg_data_ul}

    ${cmd1}  Set Variable
    ...   ue_sgnb_mod_addl_param id=${st_nsa_ue} include_ue_capabilities=on ue_nr_capabilities=${ue_nr_cap}
    ...     ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    log to console  executing_command-${cmd1}
    ute_wtssim.Execute Egate Command    ${cmd1}

    ${cmd2}  Set Variable
    ...   ue_sgnb_mod_addl_param id=${en_nsa_ue} include_ue_capabilities=on ue_nr_capabilities=${ue_nr_cap}
    ...     ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    log to console  executing_command-${cmd2}
    ute_wtssim.Execute Egate Command    ${cmd2}
    sleep   1s
    Wait until the next Measurement Period starts  additional_time=${0}
    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    23:1,2|22:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue}    ${en_nsa_ue}
    ...    23:1,2|22:1,2   measFreq=on

    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue1}    ${st_nsa_ue1}
    ...    23:1,2|2:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue1}    ${en_nsa_ue1}
    ...    23:1,2|2:1,2   measFreq=on

    Perform SCF Delta Commissioning with Set_maxNumOfSCellAlloc_to_0_0_0_cell-2_4_1.json
    Perform SCF Delta Commissioning with delta_Activate_CDRX.json
    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue2}    ${st_nsa_ue2}
    ...    22:1,2|2:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue2}    ${en_nsa_ue2}
    ...    22:1,2|2:1,2   measFreq=on
    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}
    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC
    Collect PM Counter  target_dir=${counterPath}
    ${avg_data_post}    Create List
    ${avg_dl_post}    Create Dictionary   11=${avg_data_post}   12=${avg_data_post}      13=${avg_data_post}   14=${avg_data_post}
    ...     15=${avg_data_post}   16=${avg_data_post}
    ${avg_ul_post}    Create Dictionary   11=${avg_data_post}   12=${avg_data_post}      13=${avg_data_post}   14=${avg_data_post}
    ...     15=${avg_data_post}   16=${avg_data_post}

    ${post_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_post}     pscell=8     scell=15
    log to console    avg_data_dl-${post_avg_data_dl}
    ${post_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_post}     pscell=8     scell=10
    log to console    avg_data_ul-${post_avg_data_ul}

    Validation of Data before and After PSCell Change   ${pre_avg_data_dl}   ${post_avg_data_dl}
    Validation of Data before and After PSCell Change   ${pre_avg_data_ul}   ${post_avg_data_ul}

    #pcap validation follow the same sequence
#    ${sCellIndex}   Create List  9  10  11  12  13  14  15
#    ${profile_setup}    Create Dictionary
#    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=22     sCellIndex=${sCellIndex}
#
#    ${profile_release}    Create Dictionary
#    ...     measGapConfig=0     bandCombinationIndex=22     sCellIndex=${sCellIndex}
#
    ${sCellIndex1}   Create List  9  10  11  12  13  14  15
    ${profile_setup1}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=23     sCellIndex=${sCellIndex1}

    ${profile_release1}    Create Dictionary
    ...     measGapConfig=0     bandCombinationIndex=23     sCellIndex=${sCellIndex1}

    ${sCellIndex2}   Create List  9  10  11  12
    ${profile_setup2}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=22     sCellIndex=${sCellIndex2}    drx_Config=0

    ${profile_release2}    Create Dictionary
    ...     measGapConfig=0     bandCombinationIndex=22     sCellIndex=${sCellIndex2}        drx_Config=1

    ${measConfigVal}    Create Dictionary   13=${profile_release1}   14=${profile_setup1}
    ...     15=${profile_release2}   16=${profile_setup2}

    log to console    ${measConfigVal}
    Validation of measConfigMN    ${measConfigVal}

    #Create Dictionary of counter and expected value
    sleep   5s

    ${counter}      Create Dictionary
    ...     M55112C04001=${6}    M55112C04002=${6}    M55112C04003=${0}     M55112C04004=${0}
    ...     M55112C00022=${3}    M55112C00023=${3}    M55112C00029=${6}     M55112C00030=${6}
    ...     M55112C00041=${3}    M55112C00042=${3}    M55308C11001=${0}     M55118C02012=${4}
    ...     M55118C02006=${2}    M55118C02003=${6}

    Run Keyword And Continue On Failure     Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-1     ${counter}

