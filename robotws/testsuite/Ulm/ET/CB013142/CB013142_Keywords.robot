*** Settings ***

Documentation
...    author: VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 04'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
...    Description: Keywords for CB013142-AA,-BA, A and -B

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library                      taf.config.wts        WITH NAME    wts_conf
Library                      ../../resources/Common/python/ltepat/ltepat_setup.py
Library                      ../../resources/Common/python/ltepat/ltepat_run.py
Library                      ../L2/libraries/parse_out_log.py    WITH NAME    parser
Resource                     ../resources/SQD65/sqd65_keywords.robot
Resource                     ../resources/SQD65/sqd65_commissioning.robot
Resource                     CB013142_Commissioning.robot
Resource                     CB013142_PM.robot

*** Variables ***

@{IP_LIST_eth3_add}         10.0.1.3  10.0.1.4  10.0.1.5  10.0.1.6  10.0.1.140  10.0.1.141  10.0.1.142  10.0.1.143  10.0.1.144
@{IP_LIST_eth4_add}         10.0.2.90

${skip_precheck}                    ${False}

${KPI_UE_COUNT}             40
${KPI_PM_INTERVAL}          15min
${KPI_LOOP_COUNT}           4
@{KPI_TC_IDENTIFIER}        _feat_OFF  _feat_ON

&{UE_IDs_to_index_mapping}
...    1=0
...    2=1
...    3=2
...    4=3
...    5=1
...    6=2
...    7=4

&{SCELL_default_DN_index_to_SCELL_DN_index_mapping}
...    0=3
...    1=2
...    2=1
...    3=4
...    4=0

#This UE Capability supports 5CC/2CC with DL: PCell band: 41 (Cell 1), SCell band: 41, 77, 71, 25 and UL: PCell band: 41 (Cell 1), SCell band: 71.
#Also, it does not supports powerclass2 with band combination n41&n71&66.
${UE_CAPAB_5CC_PC2_NOT_SUPPORT}          SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C05EE3614606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D4
...    73E618F28581C0E1E0B801FF800E000BE000C80000E0541B107582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000C8
...    0000E0551B137582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D88DAC1184341020F10780195B262AC
...    4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC00000640000702A0D831AC1184341020F10780195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E
...    070F09FFF000007FFC00000640000702A8D899AC1184341020E90780185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8003200003802CF0F134
...    0038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13400388C0000042C0AC5C46000E20800710400002858158B89A001C
...    41000E140000040B02B1713400388C001C46000004160542E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170A000388C
...    001C46000004160562E2680071180038500000102C0AC3C46000E230000030B02B1F0A0003850001C18000E208000070B02B1F0A0003830001C41000E230000080B02B1F0A000
...    3850001C18000E230000070B02B1F0A0003850001C41000E230000070B02B270A0003850001C4C000E208007118000048581593850001C28000E26000706000388C0000242C0A
...    C9C28000E14000713000388C001C41000012160564E1400070A0003898001C41000E0C0000090B020160234028809B010600C404C19400808485A14489B1CF870A244D8E7C385
...    1226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040
...    D8E7C0850206C73E0428103639F0214081B1CF810A040D8E7C0850206C73E0428103639F0214081B1CF810A040D8E7C00F8B0C6318C6318C6318C6318C6318C6F41B000F000A0
...    70500703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A008004010040100000C008000070040020000000800
...    0080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D04000025949010000196524040000
...    A594901000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B96524040003259490100003165240334AA2E9
...    54552A8BA55154162A82C55068AA531549A2A80C55028AA4D1541E286802F012A05028140A05028140A05028140A05028140A0502800484040300601002004202004010080600
...    C20100200404030060100C018202018030080600C201002004040300601002004402018030080600C020180304040080201002008602004008080100202018030080600C30100
...    200404030060100C018040300620080100202004008080B01202018030080600C3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828705A

${NSA_UE_NR_CAPAB}          SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C03EE3614606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D47
...    3E618F28581C0E1E0B801FF800E000BE000C80000E0541B107582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000C800
...    00E0551B137582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D88DAC1184341020F10780195B262AC487
...    3E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000006400007003DE1E26800710400000858081587850001C46000002160561E2300071040000185815878500
...    01C41000002160561E26800711800000858158B88C001C41000E208000050B02B0F0A000389A0000182C0AC5C4D000E2080070A000002058158B89A001C46000E230000020B02B
...    170A0003882001C46000004160562E1400071040038820000082C0AC5C4D000E20800711800001058158B850001C46000E230000020B02B1713400388C001C28000008160561E2
...    30007118000018581007011A014404D808232800BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204
...    081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E836001E00140E0A00E0601280380030
...    120020301F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E008004000000100001000800009004000018
...    020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012B022B07681A0800004B29202000032CA4A0800014B29202000072CA480800
...    024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669545D2AAAA55174AA2A82C55058A
...    A0D154A62A93455018AA051549AAA83C50D005E02540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C018402004008080600C020180
...    30404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414
...    951697A0A0C168


${NSA_UE_MRDC_CAPAB}          SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820000042C040BC4C0C03882001C4600000
...    2160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C041809A1682E41E24E8913639F0E24E8913639F0E24E8913639F0E24E89
...    13639F0E24E8912639F469D1224498E7D127448931CF80681C6318C631830082000080404008020100C01840001008080100202018030C0002010100C01804030060100C018400
...    0100808010040200401000000000

*** Keywords ***

Prepare TL for CB013142
    Sqd65 Common Setup    skip_precheck=${skip_precheck}
    Fetch Nidd Version From SCF File
    Prepare WTS Config
    Common Commissioning for all Sub-Features
    Bring Airphone TL to on Air status   cfg_file=basic_setup_CB013142.cfg
    Setup X2 Link
    #Add extra x2AP link with eNB5 to avoid interRAT measurement configuration on cell-1 freq
    ute_wtssim.execute egate command and wait for data
    ...   cmd=enb_x2_link_up enb=1 target=5   pass_regexp=X2AP Link .* is up   alias=ap_egate


Prepare UE List for CB013142-E
    ${KPI_UE_IDs_to_index_mapping}=    Create Dictionary
    ${DEFAULT_MA_SA_IDX}   Set Variable   1
    ${max_ue}=   Evaluate   101+${KPI_UE_COUNT}
    FOR    ${UE_ID}    IN RANGE    101    ${max_ue}    1
        Set To Dictionary    ${KPI_UE_IDs_to_index_mapping}    ${UE_ID}    ${DEFAULT_MA_SA_IDX}
    END
    ${UE_IDs_to_index_mapping}=    Copy Dictionary    ${KPI_UE_IDs_to_index_mapping}    deepcopy=True
    Set Suite Variable    ${UE_IDs_to_index_mapping}
    Set Suite Variable    ${KPI_UE_COUNT}

Perform Preconditions of Test Scenario
    Create Testcase Log Directory
    IF    '${PREV_TEST_STATUS}'=='FAIL'
        Perform Preconditions of Test Scenario in Case of Previous TC failed
    END
    ${log_dir}=                Get Testcase Log Directory
    ${SCF_TC_Setup}=           Get SCF from gNB  target_dir=${log_dir}  scf_name=scf_before_tc_execution.xml
    Start Logging
    Set Suite Variable  ${SCF_TC_Setup}


Perform Preconditions of Test Scenario in Case of Previous TC failed
    Teardown Egate Connection for Airphone
    Teardown Edaemon Connection for Airphone
    Bring Airphone TL to on Air status   cfg_file=basic_setup_CB013142.cfg


Perform Postconditions of Test Case
    run_keyword_and_warn_on_failure   Stop logging
    IF  '${TEST_MODE}' == 'auto'
        Collect AP Sos Report and Snapshots
    END
    Revert Delta Commissioning


Revert Delta Commissioning
    ${log_dir}=                 Get Testcase Log Directory
    ${curr_scf}=                Get SCF from gNB   target_dir=${log_dir}  scf_name=scf_after_tc_execution.xml
    ${revert_file}=             Set Variable   ${log_dir}/revert.json
    scf.calculate_delta_scf     ${SCF_TC_Setup}  ${curr_scf}  ${revert_file}
    Config gNB with delta scf   ${revert_file}


Fetch Nidd Version From SCF File
    [Documentation]    Author: MN RAN RD VRF ULM VT1
    ...    This keyword fetches the NIDD version of NRBTS from current SCF file and create a suite variable with this NIDD version
    [Arguments]
    ${scf_file}=          Get File   ${P_ORIG_SCF}
    ${nrbts_nidd_ver}=	  Get Lines Containing String   ${scf_file}	 com.nokia.srbts.nrbts:NRBTS
    ${nrbts_nidd_list}    Split String   ${nrbts_nidd_ver}     "
    ${NIDD_VERSION}=      Evaluate   "${nrbts_nidd_list}[5]".replace("'", "")
    Set Suite Variable    ${NIDD_VERSION}


Prepare WTS Config
    [Documentation]    Basic setup cfg file will be updated based on CB013142 needs using this keyword.
    [Arguments]
    wts_conf.load_wts_cfg   file_path=${P_ORIG_WTS_CONFIG}
    wts_conf.modify   set_amf_region id=1  modification=tac_list=7627107,100,788,200,400,0 plmn=311:489,311:488
    wts_conf.modify   set_gnb id=2  modification=plmnList=311:489,311:488 nssai=0x1:0xd143a5,0x1:0xd143a6
    wts_conf.modify   set_ue simulated id=1  modification=suci=0:311:488:0000:0:0:021645402
    IF    'CB013142-B' in '${SUITE NAME}'
          ${cell_id}   Set Variable   4
    ELSE IF    'CB013142-F-B9' in '${SUITE NAME}'
          ${cell_id}   Set Variable   6
    ELSE IF    'CB013142-F' in '${SUITE NAME}'
          ${cell_id}   Set Variable   5
    ELSE IF    'CB013142-H' in '${SUITE NAME}'
          ${cell_id}   Set Variable   4
    wts_conf.modify   command=set_cell id=2 gnb=2     modification=nr_arfcn=519000:519000 gscn=6486
    ELSE
          ${cell_id}   Set Variable   1
    END
    FOR   ${id}   IN RANGE   1   8
        wts_conf.modify   set_ue simulated id=${id}    modification=cell=${cell_id}
    END
    ${id}=    Set Variable    16
    WHILE   ${id} <= 20
        wts_conf.clone_and_modify   set_ue simulated id=2     id=${id} suci=0:311:489:0000:0:0:0216454${id}   after    ue_param id=${${id}-1}
        wts_conf.clone_and_modify   ue_param id=2     id=${id}   after    set_ue simulated id=${id}
        wts_conf.clone_and_modify   set_pdu_gateway id=2     id=${id} ue_nat_ip=72.23.0.${id}   after    set_pdu_gateway id=${${id}-1}
        ${id}=    Evaluate    ${id} + 1
    END
    wts_conf.modify    ue_param id=14    modification=ue_nr_capabilities=${NSA_UE_NR_CAPAB} ue_eutra_nr_capabilities=${NSA_UE_MRDC_CAPAB}
    ${id}=    Set Variable    21
    WHILE   ${id} <= 24
        wts_conf.clone_and_modify   set_ue simulated id=14     id=${id} imsi=311:489:2164540${${id}-16}   after    ue_param id=${${id}-1}
        wts_conf.clone_and_modify   ue_param id=14     id=${id}    after    set_ue simulated id=${id}
        wts_conf.clone_and_modify   set_pdu_gateway id=14     id=${id} ue_nat_ip=72.23.0.${id}   after    set_pdu_gateway id=${${id}-1}
        wts_conf.clone_and_modify   set_bearer id=2 ue=14     ue=${id} ip=4.7.254.2${${id}-1}   after    set_bearer id=2 ue=15
        ${id}=    Evaluate    ${id} + 1
    END
    # Add dummy eNB5 simulation to avoid interRAT measurement configuration on cell-1 freq
    wts_conf.clone_and_modify    set_enb id=1    id=5 s1=10.0.1.142 enb_id_macro=0x12348 x2=10.0.1.143 x2u=10.0.1.144    after    set_cell id=2 enb=1
    wts_conf.clone_and_modify    enb_param id=1    id=5    after    set_enb id=5
    wts_conf.clone_and_modify    set_cell id=1 enb=1    enb=5 eci=0x1234851 pci=5:2 proxy=$DAEMON_IP:12223|$DAEMON_IP:8890    after    enb_param id=5
    wts_conf.clone_and_modify    set_cell id=2 enb=1    enb=5 eci=0x1234855 pci=6:0 proxy=$DAEMON_IP:12225|$DAEMON_IP:8890
    ...    after    set_cell id=1 enb=5

    wts_conf.modify   set_ue simulated id=14  modification=imsi=311:488:21645403
    wts_conf.modify   nwslice_set id=2  modification=ue=1,2,3,4,5,6,7

    IF  'CB013142-E' in '${SUITE NAME}'
        ${max_ue}=   Evaluate   101+${KPI_UE_COUNT}
        ${id}=    Set Variable    101
        wts_conf.clone_and_modify   set_ue simulated id=3     id=${id} suci=0:311:489:0000:0:0:021645${id}   after    ue_param id=24
        wts_conf.clone_and_modify   ue_param id=3     id=${id}   after    set_ue simulated id=${id}
        wts_conf.clone_and_modify   set_pdu_gateway id=3     id=${id} ue_nat_ip=72.23.0.${id}   after    set_pdu_gateway id=24
        ${id}=    Evaluate    ${id} + 1
        WHILE   ${id} < ${max_ue}
            wts_conf.clone_and_modify   set_ue simulated id=3     id=${id} suci=0:311:489:0000:0:0:021645${id}   after    ue_param id=${${id}-1}
            wts_conf.clone_and_modify   ue_param id=3     id=${id}   after    set_ue simulated id=${id}
            wts_conf.clone_and_modify   set_pdu_gateway id=3     id=${id} ue_nat_ip=72.23.0.${id}   after    set_pdu_gateway id=${${id}-1}
            ${id}=    Evaluate    ${id} + 1
        END
    END

    wts_conf.save_wts_cfg   file_path=${tl.core.dir_path}/basic_setup_CB013142.cfg
    ${ts_conf_dir}=         Get Test Suite Config Directory
    Copy File               ${tl.core.dir_path}/basic_setup_CB013142.cfg  ${ts_conf_dir}


Setup for CB013142-AA-B4
    [Documentation]    Do delta commissioning for rsrpCombined testing
    Perform Preconditions of Test Scenario
    scf.load_scf        ${SCF_TC_Setup}
    Apply Configuration For A2 Measurement Based PCell Switch At NRCell    cell_id=1  a2_meas_quantity=rsrpCombined

    ${log_dir}=                 Get Testcase Log Directory
    ${modified_scf}=    Set variable    ${log_dir}/CB013142-AA-B4_SCF.xml
    scf.save_scf    ${modified_scf}
    ${CB013142-AA-B4_delta_SCF}=            Set Variable  ${log_dir}/CB013142-AA-B4_delta_SCF.json
    scf.calculate_delta_scf    target_scf_path=${modified_scf}    actual_scf_path=${SCF_TC_Setup}    delta_scf_path=${CB013142-AA-B4_delta_SCF}
    Config gNB with delta scf  ${CB013142-AA-B4_delta_SCF}


Setup for CB013142-A-B1
    [Documentation]    Do delta commissioning for power class as a criteria testing
    Perform Preconditions of Test Scenario
    scf.load_scf        ${SCF_TC_Setup}
    Apply Configuration For CB013142-A
    ${log_dir}=                 Get Testcase Log Directory
    ${modified_scf}=    Set variable    ${log_dir}/CB013142-A-B1_SCF.xml
    scf.save_scf    ${modified_scf}
    ${CB013142-A-B1_delta_SCF}=            Set Variable  ${log_dir}/CB013142-A-B1_delta_SCF.json
    scf.calculate_delta_scf    target_scf_path=${modified_scf}    actual_scf_path=${SCF_TC_Setup}    delta_scf_path=${CB013142-A-B1_delta_SCF}
    Config gNB with delta scf  ${CB013142-A-B1_delta_SCF}


Setup for CB013142-A-B3
    [Documentation]    Do delta commissioning for power class as a criteria testing
    Perform Preconditions of Test Scenario
    scf.load_scf        ${SCF_TC_Setup}
    Apply configuration for CB013142-A    a2_meas_quantity=rsrpCombined
    ${log_dir}=                 Get Testcase Log Directory
    ${modified_scf}=    Set variable    ${log_dir}/CB013142-A-B3_SCF.xml
    scf.save_scf    ${modified_scf}
    ${CB013142-A-B3_delta_SCF}=            Set Variable  ${log_dir}/CB013142-A-B3_delta_SCF.json
    scf.calculate_delta_scf    target_scf_path=${modified_scf}    actual_scf_path=${SCF_TC_Setup}    delta_scf_path=${CB013142-A-B3_delta_SCF}
    Config gNB with delta scf  ${CB013142-A-B3_delta_SCF}


Setup for CB013142-B-B1
    [Documentation]    Do delta commissioning for power class as a criteria testing
    Perform Preconditions of Test Scenario
    scf.load_scf        ${SCF_TC_Setup}
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1                                   actMeasurementProfReselForCA            pcInSaUlCaSupported        #CB013392 Feature Flag
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          actFullPwrMode                          true
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          actFullPwrMode                          true
    ...   MRBTS-1/NRBTS-1/NRCELL-4                          actFullPwrMode                          true
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          pMaxNROwnCell                           26
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          pMaxNROwnCell                           26
    ...   MRBTS-1/NRBTS-1/NRCELL-4                          pMaxNROwnCell                           26
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          a1MeasPCellSwitchEnabled                rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          a1MeasPCellSwitchEnabled                rsrp
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

    ${dist_name_NRMEASPR_MA_SA}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA
    Log To Console    remove list "snssaiList" from object "${dist_name_NRMEASPR_MA_SA}-9"
    scf.remove_list_from_scf       dist_name=${dist_name_NRMEASPR_MA_SA}-9        list_name=snssaiList

    Log To Console    Add list "pcCapabilityList" to object "${dist_name_NRMEASPR_MA_SA}-9"
    Set New List                    dist_name=${dist_name_NRMEASPR_MA_SA}-9      list_name=pcCapabilityList
    ${pcCapabilityList_dict}        Create dictionary           uePowerClass                      ue-PowerClass2
    scf.add_item_to_list      dist_name=${dist_name_NRMEASPR_MA_SA}-9      list_name=pcCapabilityList          elements=${pcCapabilityList_dict}
    ${pcCapabilityList_dict}        Create dictionary           uePowerClass                      ue-PowerClass1
    scf.add_item_to_list      dist_name=${dist_name_NRMEASPR_MA_SA}-9      list_name=pcCapabilityList          elements=${pcCapabilityList_dict}

    ${log_dir}=                 Get Testcase Log Directory
    ${modified_scf}=    Set variable    ${log_dir}/CB013142-B-B1_SCF.xml
    scf.save_scf    ${modified_scf}
    ${CB013142-B-B1_delta_SCF}=            Set Variable  ${log_dir}/CB013142-B-B1_delta_SCF.json
    scf.calculate_delta_scf    target_scf_path=${modified_scf}    actual_scf_path=${SCF_TC_Setup}    delta_scf_path=${CB013142-B-B1_delta_SCF}
    Config gNB with delta scf  ${CB013142-B-B1_delta_SCF}


Setup for CB013142-B-B2
    [Documentation]    Do delta commissioning for rsrpCombined testing
    Perform Preconditions of Test Scenario
    scf.load_scf        ${SCF_TC_Setup}
    Setup for CB013142-B-B1
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          a1MeasPCellSwitchEnabled                rsrpCombined
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

    ${log_dir}=                 Get Testcase Log Directory
    ${modified_scf}=    Set variable    ${log_dir}/CB013142-B-B2_SCF.xml
    scf.save_scf    ${modified_scf}
    ${CB013142-B-B2_delta_SCF}=            Set Variable  ${log_dir}/CB013142-B-B2_delta_SCF.json
    scf.calculate_delta_scf    target_scf_path=${modified_scf}    actual_scf_path=${SCF_TC_Setup}    delta_scf_path=${CB013142-B-B2_delta_SCF}
    Config gNB with delta scf  ${CB013142-B-B2_delta_SCF}


Setup for CB013142-BA-B4
    [Documentation]    Do delta commissioning for rsrpCombined testing
    Perform Preconditions of Test Scenario
    scf.load_scf        ${SCF_TC_Setup}
    FOR   ${dist_name}                          ${p_name}                       ${value}                       IN
    ...   MRBTS-1/NRBTS-1/NRCELL-1              a1MeasPCellSwitchEnabled        rsrpCombined
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    ${log_dir}=                 Get Testcase Log Directory
    ${modified_scf}=    Set variable    ${log_dir}/CB013142-BA-B4_SCF.xml
    scf.save_scf    ${modified_scf}
    ${CB013142-BA-B4_delta_SCF}=            Set Variable  ${log_dir}/CB013142-BA-B4_delta_SCF.json
    scf.calculate_delta_scf    target_scf_path=${modified_scf}    actual_scf_path=${SCF_TC_Setup}    delta_scf_path=${CB013142-BA-B4_delta_SCF}
    Config gNB with delta scf  ${CB013142-BA-B4_delta_SCF}


Setup for CB013142-C-B2
    [Documentation]    Do delta commissioning for rsrpCombined testing
    Perform Preconditions of Test Scenario
    scf.load_scf        ${SCF_TC_Setup}
    Apply configuration for CB013142-C    a2_meas_quantity=rsrpCombined
    ${log_dir}=                 Get Testcase Log Directory
    ${modified_scf}=    Set variable    ${log_dir}/CB013142-C-B2_SCF.xml
    scf.save_scf    ${modified_scf}
    ${CB013142-C-B2_delta_SCF}=            Set Variable  ${log_dir}/CB013142-C-B2_delta_SCF.json
    scf.calculate_delta_scf    target_scf_path=${modified_scf}    actual_scf_path=${SCF_TC_Setup}    delta_scf_path=${CB013142-C-B2_delta_SCF}
    Config gNB with delta scf  ${CB013142-C-B2_delta_SCF}


Setup for CB013142-D-B2
    [Documentation]    Do delta commissioning for rsrpCombined testing
    Perform Preconditions of Test Scenario
    scf.load_scf        ${SCF_TC_Setup}
    Set New List            dist_name=MRBTS-1/NRBTS-1/NRDU-1             list_name=carrierAggregationSupportList
    ${param_list}=    Create List    ca_Fdd_Any_Sa    ca_Fr1Tdd_Any_Sa    ca_Fr1Tdd_Fdd_Sa    ca_Fr1Tdd_Sa    ca_Fdd_Fr1Tdd_Sa
    ...    ca_Fdd_Fdd    ca_Fdd_Fr1Tdd_Sa_WithUl    ca_Fr1Tdd_Fdd_Sa_WithUl    ca_Fdd_Fr1Tdd_Nsa    ca_Fr1Tdd_Fdd_Nsa
    scf.add_elements_to_list        dist_name=MRBTS-1/NRBTS-1/NRDU-1      list_name=carrierAggregationSupportList   elements=${param_list}
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1                                   actMeasProfPowerCoordNSA                activated         #CB013392 Feature Flag
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          actFullPwrMode                          true
    ...   MRBTS-1/NRBTS-1/NRCELL-4                          actFullPwrMode                          true
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          pMaxNROwnCell                           29
    ...   MRBTS-1/NRBTS-1/NRCELL-4                          pMaxNROwnCell                           29
    ...   MRBTS-1/NRBTS-1/NRCELL-4/NRREL-1                  sCellOperationalMode                    dlOnly
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          a1MeasPCellSwitchEnabled                rsrpCombined
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    ${dist_name_NRMEASPR_MA_NSA}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA
    Log To Console    remove list "nrPlmnDNList" from object "${dist_name_NRMEASPR_MA_NSA}-12"
    scf.remove_list_from_scf       dist_name=${dist_name_NRMEASPR_MA_NSA}-12        list_name=nrPlmnDNList

    Log To Console    Add list "pcCapabilityList" to object "${dist_name_NRMEASPR_MA_NSA}-12"
    sqd65_commissioning.Set New List                    dist_name=${dist_name_NRMEASPR_MA_NSA}-12      list_name=pcCapabilityList
    ${pcCapabilityList_dict}        Create dictionary           uePowerClass                      ue-PowerClass2
    ...                                                         freqBandIndicatorNR               41
    scf.add_item_to_list      dist_name=${dist_name_NRMEASPR_MA_NSA}-12      list_name=pcCapabilityList          elements=${pcCapabilityList_dict}
    ${log_dir}=                 Get Testcase Log Directory
    ${modified_scf}=    Set variable    ${log_dir}/CB013142-D-B2_SCF.xml
    scf.save_scf    ${modified_scf}
    ${CB013142-D-B2_delta_SCF}=            Set Variable  ${log_dir}/CB013142-D-B2_delta_SCF.json
    scf.calculate_delta_scf    target_scf_path=${modified_scf}    actual_scf_path=${SCF_TC_Setup}    delta_scf_path=${CB013142-D-B2_delta_SCF}
    Config gNB with delta scf  ${CB013142-D-B2_delta_SCF}


Setup for CB013142-E-B1
    [Documentation]    Do delta commissioning for power class as a criteria testing
    Perform Preconditions of Test Scenario
    scf.load_scf        ${SCF_TC_Setup}
    Apply configuration for CB013142-A    a2_meas_quantity=rsrpCombined
    Apply configuration for CB013142-E
    ${log_dir}=                 Get Testcase Log Directory
    ${modified_scf}=    Set variable    ${log_dir}/CB013142-E-B1_SCF.xml
    scf.save_scf    ${modified_scf}
    ${CB013142-E-B1_delta_SCF}=            Set Variable  ${log_dir}/CB013142-E-B1_delta_SCF.json
    scf.calculate_delta_scf    target_scf_path=${modified_scf}    actual_scf_path=${SCF_TC_Setup}    delta_scf_path=${CB013142-E-B1_delta_SCF}
    Config GNB With Delta SCF  ${CB013142-E-B1_delta_SCF}    skip_relation_errors=False


Setup For CB013142-F-B5
    [Documentation]    Do delta commissioning for rsrpCombined testing
    Perform Preconditions of Test Scenario
    scf.Load Scf        ${SCF_TC_Setup}
    sqd65_commissioning.Set New List            dist_name=MRBTS-1/NRBTS-1/NRDU-1             list_name=carrierAggregationSupportList
    ${param_list}=    Create List    ca_Fdd_Any_Sa    ca_Fr1Tdd_Any_Sa    ca_Fr1Tdd_Fdd_Sa    ca_Fr1Tdd_Sa    ca_Fdd_Fr1Tdd_Sa
    ...    ca_Fdd_Fdd    ca_Fdd_Fr1Tdd_Sa_WithUl    ca_Fr1Tdd_Fdd_Sa_WithUl    ca_Fdd_Fr1Tdd_Nsa    ca_Fr1Tdd_Fdd_Nsa
    scf.add_elements_to_list        dist_name=MRBTS-1/NRBTS-1/NRDU-1      list_name=carrierAggregationSupportList   elements=${param_list}
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1                                   actBufferBasedSCellAddition             oneShot_Dl_Fr1         #CB008311 Feature Flag
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          pMaxNROwnCell                           29
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          pMaxNROwnCell                           29
    ...   MRBTS-1/NRBTS-1/NRCELL-3                          pMaxNROwnCell                           29
    ...   MRBTS-1/NRBTS-1/NRCELL-4                          pMaxNROwnCell                           29
    ...   MRBTS-1/NRBTS-1/NRCELL-5                          pMaxNROwnCell                           29
    ...   MRBTS-1/NRBTS-1/NRCELL-6                          pMaxNROwnCell                           29
    ...   MRBTS-1/NRBTS-1/NRCELL-3                          a1MeasSCellAddEnabled                   rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-5                          a1MeasSCellAddEnabled                   rsrpCombined
    ...   MRBTS-1/NRBTS-1/NRCELL-5                          mgta                                    ms0
    ...   MRBTS-1/NRBTS-1/NRCELL-5/NRREL-1                  sCellAdditionMethod                     covBasedA1
    ...   MRBTS-1/NRBTS-1/NRCELL-5/NRREL-2                  sCellAdditionMethod                     covBasedA1
    ...   MRBTS-1/NRBTS-1/NRCELL-5/NRREL-3                  sCellAdditionMethod                     covBasedA4
    ...   MRBTS-1/NRBTS-1/NRCELL-5/NRREL-3                  actA4ToA1BasedSCellFallbackNsa          false
    ...   MRBTS-1/NRBTS-1/NRCELL-5/NRREL-4                  sCellAdditionMethod                     covBasedA1
    ...   MRBTS-1/NRBTS-1/NRCELL-5/NRREL-4                  sCellOperationalMode                    dlOnly
    ...   MRBTS-1/NRBTS-1/NRCELL-5/NRHOIF-1                 a4MeasSCellAddEnabled                   rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-5/NRHOIF-1                 freqBandIndicatorNR                     77
    ...   MRBTS-1/NRBTS-1/NRCELL-5/NRHOIF-1                 ifhoSsbScs                              30 KHz
    ...   MRBTS-1/NRBTS-1/NRCELL-5/NRHOIF-1                 scs                                     30 KHz
    ...   MRBTS-1/NRBTS-1/NRCELL-5/NRHOIF-1                 ssbFrequency                            655968
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    sqd65_commissioning.Set New List                    dist_name=MRBTS-1/NRBTS-1/NRCELL-5      list_name=a4PeriodicMeasControlSA
    ${a4PeriodicMeasControlSA_dict}        Create dictionary           a4Fr1SupervisionTimer                      4000
    ...                                                                a4Fr2SupervisionTimer                      6000
    ...                                                                a4MeasActBlockTimer                        0
    ...                                                                a4MeasMaxNumber                            5
    ...                                                                a4RetryTimer                               10
    ...                                                                a4RetryTimerMultCa                         5
    scf.add_item_to_list      dist_name=MRBTS-1/NRBTS-1/NRCELL-5      list_name=a4PeriodicMeasControlSA    elements=${a4PeriodicMeasControlSA_dict}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-5      list_name=a1MeasSCellAddSsbRsrp
    ${a1MeasSCellAddSsbRsrp_dict_1}        Create dictionary           a1HysteresisSCellAddSsbRsrp                30
    ...                                                                a1ThresholdSCellAddSsbRsrpFDD              50
    ...                                                                a1ThresholdSCellAddSsbRsrpTDD              70
    ...                                                                a1TimeToTriggerSCellAddSsbRsrp             320ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-5    list_name=a1MeasSCellAddSsbRsrp
    ...                     elements=${a1MeasSCellAddSsbRsrp_dict_1}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-5      list_name=a1MeasSCellAddSsbRsrq
    ${a1MeasSCellAddSsbRsrq_dict_1}        Create dictionary           a1HysteresisSCellAddSsbRsrq                10
    ...                                                                a1ThresholdSCellAddSsbRsrq                 50
    ...                                                                a1TimeToTriggerSCellAddSsbRsrq             320ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-5    list_name=a1MeasSCellAddSsbRsrq
    ...                     elements=${a1MeasSCellAddSsbRsrq_dict_1}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-11      list_name=a1MeasSCellAddSsbRsrp
    ${a1MeasSCellAddSsbRsrp_dict_2}        Create dictionary           a1HysteresisSCellAddSsbRsrp                10
    ...                                                                a1ThresholdSCellAddSsbRsrpFDD              60
    ...                                                                a1ThresholdSCellAddSsbRsrpTDD              80
    ...                                                                a1TimeToTriggerSCellAddSsbRsrp             320ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-11    list_name=a1MeasSCellAddSsbRsrp
    ...                     elements=${a1MeasSCellAddSsbRsrp_dict_2}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-11      list_name=a1MeasSCellAddSsbRsrq
    ${a1MeasSCellAddSsbRsrq_dict_2}        Create dictionary           a1HysteresisSCellAddSsbRsrq                20
    ...                                                                a1ThresholdSCellAddSsbRsrq                 60
    ...                                                                a1TimeToTriggerSCellAddSsbRsrq             320ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-11    list_name=a1MeasSCellAddSsbRsrq
    ...                     elements=${a1MeasSCellAddSsbRsrq_dict_2}
    sqd65_commissioning.Set New List                    dist_name=MRBTS-1/NRBTS-1/NRCELL-5      list_name=measPrMaSAList
    ${measPrMaSAList_dict_1}        Create dictionary           measPrPriority         1
    ...                                                       nrMeasPrMaSADN         MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-11
    scf.add_item_to_list      dist_name=MRBTS-1/NRBTS-1/NRCELL-5      list_name=measPrMaSAList    elements=${measPrMaSAList_dict_1}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1  list_name=actMeasBasedSCellAdditionSa
    ${param_list}=    Create List    A1-based    A4-based
    scf.Add Elements To List    dist_name=MRBTS-1/NRBTS-1    list_name=actMeasBasedSCellAdditionSa    elements=${param_list}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-5/NRHOIF-1      list_name=a4MeasSCellAddSsbRsrp
    ${a4MeasSCellAddSsbRsrp_dict_1}        Create dictionary           a4HysteresisSCellAddSsbRsrp                0
    ...                                                                a4ThresholdSCellAddSsbRsrp                 34
    ...                                                                a4TimeToTriggerSCellAddSsbRsrp             ms40
    scf.Add Item To List    dist_name=MRBTS-1/NRBTS-1/NRCELL-5/NRHOIF-1    list_name=a4MeasSCellAddSsbRsrp
    ...                     elements=${a4MeasSCellAddSsbRsrp_dict_1}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IEF-11      list_name=a4MeasSCellAddSsbRsrp
    ${a4MeasSCellAddSsbRsrp_dict_2}        Create dictionary           a4HysteresisSCellAddSsbRsrp                4
    ...                                                                a4ThresholdSCellAddSsbRsrp                 40
    ...                                                                a4TimeToTriggerSCellAddSsbRsrp             ms40
    scf.Add Item To List    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IEF-11    list_name=a4MeasSCellAddSsbRsrp
    ...                     elements=${a4MeasSCellAddSsbRsrp_dict_2}
    sqd65_commissioning.Set New List                    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-11      list_name=nrMeasPrIefList
    ${nrMeasPrIefList_dict_1}        Create dictionary           nrMeasPrIefDN          MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IEF-11
    ...                                                          ssbFrequency01         655968
    scf.Add Item To List      dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-11      list_name=nrMeasPrIefList
    ...                       elements=${nrMeasPrIefList_dict_1}
    ${log_dir}=                 Get Testcase Log Directory
    ${modified_scf_f_b5}=    Set Variable    ${log_dir}/CB013142-F-B5_SCF.xml
    scf.Save Scf    ${modified_scf_f_b5}
    ${CB013142-F-B5_delta_SCF}=            Set Variable  ${log_dir}/CB013142-F-B5_delta_SCF.json
    scf.Calculate Delta Scf    target_scf_path=${modified_scf_f_b5}    actual_scf_path=${SCF_TC_Setup}    delta_scf_path=${CB013142-F-B5_delta_SCF}
    Config GNB With Delta Scf  ${CB013142-F-B5_delta_SCF}


Setup For CB013142-F-B9
    [Documentation]    Do delta commissioning for actHoOptimizationCa testing
    CB013142_Keywords.Perform Preconditions Of Test Scenario
    scf.Load Scf        ${SCF_TC_Setup}
    CB013142_Keywords.Setup For CB013142-F-B5
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-4      list_name=a2MeasSCellRelSsbRsrp
    ${a2MeasSCellRelSsbRsrp_dict_1}        Create dictionary           a2HysteresisSCellRelSsbRsrp                0
    ...                                                                a2ThresholdSCellRelSsbRsrp                 34
    ...                                                                a2TimeToTriggerSCellRelSsbRsrp             2560ms
    scf.Add Item To List    dist_name=MRBTS-1/NRBTS-1/NRCELL-4    list_name=a2MeasSCellRelSsbRsrp
    ...                     elements=${a2MeasSCellRelSsbRsrp_dict_1}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-6      list_name=a1MeashoSsbRsrpSA
    ${a1MeashoSsbRsrpSA_dict_1}        Create dictionary               a1HysteresishoSsbRsrpSA                0
    ...                                                                a1ThresholdhoSsbRsrpSA                 60
    ...                                                                a1TimeToTriggerhoSsbRsrpSA             ms480
    scf.Add Item To List    dist_name=MRBTS-1/NRBTS-1/NRCELL-6    list_name=a1MeashoSsbRsrpSA
    ...                     elements=${a1MeashoSsbRsrpSA_dict_1}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-6      list_name=a2MeasRedirectSsbRsrp
    ${a2MeasRedirectSsbRsrp_dict_1}        Create dictionary           a2HysteresisRedirectSsbRsrp            4
    ...                                                                a2ThresholdRedirectSsbRsrp             34
    ...                                                                a2TimeToTriggerRedirectSsbRsrp         ms480
    scf.Add Item To List    dist_name=MRBTS-1/NRBTS-1/NRCELL-6    list_name=a2MeasRedirectSsbRsrp
    ...                     elements=${a2MeasRedirectSsbRsrp_dict_1}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-6      list_name=a2MeashoSsbRsrpSA
    ${a2MeashoSsbRsrpSA_dict_1}        Create dictionary               a2HysteresishoSsbRsrpSA                0
    ...                                                                a2HysteresisHoSsbRsrpVoNr              4
    ...                                                                a2ThresholdhoSsbRsrpSA                 34
    ...                                                                a2ThresholdHoSsbRsrpVoNr               38
    ...                                                                a2TimeToTriggerhoSsbRsrpSA             ms480
    scf.Add Item To List    dist_name=MRBTS-1/NRBTS-1/NRCELL-6    list_name=a2MeashoSsbRsrpSA
    ...                     elements=${a2MeashoSsbRsrpSA_dict_1}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-6/NRHOIF-1
    sqd65_commissioning.Set Object    class_name=NRHOIF    dist_name=${dist_name}   version=${NIDD_VERSION}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-6/NRHOIF-1      list_name=a3MeasSsbRsrp
    ${a3MeasSsbRsrp_dict_1}        Create dictionary           a3HysteresisSsbRsrp                0
    ...                                                        a3OffsetSsbRsrp                    0
    ...                                                        a3TimeToTriggerSsbRsrp             ms40
    scf.Add Item To List    dist_name=MRBTS-1/NRBTS-1/NRCELL-6/NRHOIF-1    list_name=a3MeasSsbRsrp
    ...                     elements=${a3MeasSsbRsrp_dict_1}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-6/NRREL-5
    sqd65_commissioning.Set Object    class_name=NRREL    dist_name=${dist_name}   version=${NIDD_VERSION}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-6/NRREL-5      list_name=gnbPlmn
    ${gnbPlmn_dict_1}        Create dictionary           mcc                311
    ...                                                  mnc                489
    ...                                                  mncLength          3
    scf.Add Item To List    dist_name=MRBTS-1/NRBTS-1/NRCELL-6/NRREL-5    list_name=gnbPlmn
    ...                     elements=${gnbPlmn_dict_1}
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1                                   actBufferBasedSCellAddition             disabled
    ...   MRBTS-1/NRBTS-1                                   actHoOptimizationCa                     true
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          increasePUSCHPrepTimeULCA               false
    ...   MRBTS-1/NRBTS-1/NRCELL-4                          a2MeasSCellRelEnabled                   rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-5                          a1MeasSCellAddEnabled                   rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-6                          measGapSelectionSA                      favourUeThroughput
    ...   MRBTS-1/NRBTS-1/NRCELL-6                          a1MeashoEnabled                         rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-6                          a1MeashoEnabledSA                       rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-6                          a2MeasPCellSwitchEnabled                rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-6                          a2MeasRedirectEnabled                   rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-6                          a2MeasReleaseEnabled                    rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-6                          a2MeashoEnabled                         rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-6                          a2MeashoEnabledSA                       rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-6                          a3MeasEnabled                           rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-6                          a5MeasEnabled                           rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-6/NRREL-5                  gNbId                                   1
    ...   MRBTS-1/NRBTS-1/NRCELL-6/NRREL-5                  lcrId                                   5
    ...   MRBTS-1/NRBTS-1/NRCELL-6/NRHOIF-1                 a3MeasEnabled                           rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-6/NRHOIF-1                 cellDepType                             SA+NSA
    ...   MRBTS-1/NRBTS-1/NRCELL-6/NRHOIF-1                 deriveSsbIndexFromCell                  true
    ...   MRBTS-1/NRBTS-1/NRCELL-6/NRHOIF-1                 freqBandIndicatorNR                     66
    ...   MRBTS-1/NRBTS-1/NRCELL-6/NRHOIF-1                 ifhoSsbScs                              15KHz
    ...   MRBTS-1/NRBTS-1/NRCELL-6/NRHOIF-1                 ifhoSsbSmtcDuration                     sf2
    ...   MRBTS-1/NRBTS-1/NRCELL-6/NRHOIF-1                 ifhoSsbSmtcPeriodicity                  sf10
    ...   MRBTS-1/NRBTS-1/NRCELL-6/NRHOIF-1                 scs                                     15 KHz
    ...   MRBTS-1/NRBTS-1/NRCELL-6/NRHOIF-1                 ssbFrequency                            431090
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    scf.Remove List From Scf            dist_name=MRBTS-1/NRBTS-1    list_name=actMeasBasedSCellAdditionSa
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1    list_name=actMeasBasedSCellAdditionSa
    ${param_list}=    Create List    A1-based
    scf.Add Elements To List    dist_name=MRBTS-1/NRBTS-1    list_name=actMeasBasedSCellAdditionSa    elements=${param_list}
    sqd65_commissioning.Remove Object    dist_name=MRBTS-1/NRBTS-1/NRCELL-5/NRREL-1
    sqd65_commissioning.Remove Object    dist_name=MRBTS-1/NRBTS-1/NRCELL-5/NRREL-2
    sqd65_commissioning.Remove Object    dist_name=MRBTS-1/NRBTS-1/NRCELL-5/NRREL-3
    ${log_dir}=                 Get Testcase Log Directory
    ${modified_scf_f_b5}=    Set Variable    ${log_dir}/CB013142-F-B5_SCF.xml
    ${modified_scf_f_b9}=    Set Variable    ${log_dir}/CB013142-F-B9_SCF.xml
    scf.Save Scf    ${modified_scf_f_b9}
    ${CB013142-F-B9_delta_SCF}=            Set Variable  ${log_dir}/CB013142-F-B9_delta_SCF.json
    scf.Calculate Delta Scf    target_scf_path=${modified_scf_f_b9}    actual_scf_path=${modified_scf_f_b5}
    ...                        delta_scf_path=${CB013142-F-B9_delta_SCF}
    sqd65_keywords.Config GNB With Delta Scf  ${CB013142-F-B9_delta_SCF}


Setup For CB013142-J-B3
    [Documentation]    Do delta commissioning for rsrpCombined testing
    Perform Preconditions Of Test Scenario
    scf.load_scf        ${SCF_TC_Setup}
    Apply Configuration For CB013142-J
    ${log_dir}=                 Get Testcase Log Directory
    ${modified_scf}=    Set variable    ${log_dir}/CB013142-J-B3_SCF.xml
    scf.save_scf    ${modified_scf}
    ${CB013142-J-B3_delta_SCF}=            Set Variable  ${log_dir}/CB013142-J-B3_delta_SCF.json
    scf.calculate_delta_scf    target_scf_path=${modified_scf}    actual_scf_path=${SCF_TC_Setup}    delta_scf_path=${CB013142-J-B3_delta_SCF}
    Config gNB with delta scf  ${CB013142-J-B3_delta_SCF}


Setup for CB013142-H-B7
    [Documentation]    Do delta commissioning for rsrpCombined testing#
    Update iphy file for CB013142-H-B7
    Perform Preconditions of Test Scenario
    Log To Console    \n\n\n Changes to scf in Setup for...
    scf.load_scf        ${SCF_TC_Setup}
    FOR   ${dist_name}                          ${p_name}                       ${value}                       IN
    ...   MRBTS-1/NRBTS-1/NRCELL-2              gscnOrSsPbchArfcn               6486
    ...   MRBTS-1/NRBTS-1/NRCELL-2              nrarfcn                         519000
    ...   MRBTS-1/NRBTS-1                       actSCellSwapFr1                 a6BasedSa
    ...   MRBTS-1/NRBTS-1/NRCELL-1              a1MeasSCellAddEnabled           none
    ...   MRBTS-1/NRBTS-1/NRCELL-1              a2MeasSCellRelEnabled           rsrpCombined
    ...   MRBTS-1/NRBTS-1/NRCELL-1              a6MeasSCellSwapEnabled          rsrpCombined
    ...   MRBTS-1/NRBTS-1/NRCELL-1              reportAmountA6MeasSCellSwap     r8
    ...   MRBTS-1/NRBTS-1/NRCELL-1              reportIntervalA6MeasSCellSwap   ms1024
    ...   MRBTS-1/NRBTS-1/NRCELL-1              thresholdSCellSwapSourceRsrp    51
    ...   MRBTS-1/NRBTS-1/NRCELL-2              a2MeasSCellRelEnabled           rsrpCombined
    ...   MRBTS-1/NRBTS-1/NRCELL-2              a6MeasSCellSwapEnabled          rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-2              reportAmountA6MeasSCellSwap     r8
    ...   MRBTS-1/NRBTS-1/NRCELL-2              reportIntervalA6MeasSCellSwap   ms1024
    ...   MRBTS-1/NRBTS-1/NRCELL-2              thresholdSCellSwapSourceRsrp    46
    ...   MRBTS-1/NRBTS-1/NRCELL-3              a1MeasSCellAddEnabled           none
    ...   MRBTS-1/NRBTS-1/NRCELL-4/NRREL-1      lcrId                           5
    ...   MRBTS-1/NRBTS-1/NRCELL-4/NRREL-2      lcrId                           1
    ...   MRBTS-1/NRBTS-1/NRCELL-4/NRREL-2      sCellPrio                       1
    ...   MRBTS-1/NRBTS-1/NRCELL-4/NRREL-3      lcrId                           2
    ...   MRBTS-1/NRBTS-1/NRCELL-4/NRREL-3      sCellOperationalMode            dlOnly
    ...   MRBTS-1/NRBTS-1/NRCELL-4/NRREL-3      sCellPrio                       2
    ...   MRBTS-1/NRBTS-1/NRCELL-5              a1MeashoEnabled                 none
    ...   MRBTS-1/NRBTS-1/NRCELL-5              a2MeasSCellRelEnabled           rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-5              a2MeashoEnabled                 none
    ...   MRBTS-1/NRBTS-1/NRCELL-5              maxNumOfSCellAlloc              5
    ...   MRBTS-1/NRBTS-1/NRCELL-2              maxNumOfSCellAlloc              5
    ...   MRBTS-1/NRBTS-1/NRCELL-1              increasePUSCHPrepTimeULCA       false
    ...   MRBTS-1/NRBTS-1/NRCELL-2              increasePUSCHPrepTimeULCA       false
    ...   MRBTS-1/NRBTS-1/NRCELL-3              increasePUSCHPrepTimeULCA       false
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-3
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-4
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-5
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-6
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-2/NRREL-1
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-2/NRREL-2
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-2/NRREL-3
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-2/NRREL-4
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-2/NRREL-5
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-3/NRREL-1
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-3/NRREL-2
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-3/NRREL-3
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-3/NRREL-4
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-4/NRREL-4
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-3/NRREL-5
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-3/NRREL-6
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-5/NRREL-1
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-5/NRREL-2
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-5/NRREL-3
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-5/NRREL-4
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-6/NRREL-1
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-6/NRREL-2
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-6/NRREL-3
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-6/NRREL-4
    scf.remove_element_from_scf              dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-4    p_name=nrMeasPrSCellDefaultDN
    scf.remove_element_from_scf              dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-4    p_name=rfspIndex
    scf.remove_element_from_scf              dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-4    p_name=rfspIndexLast
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-1      list_name=a2MeasSCellRelSsbRsrp
    ${a2MeasSCellRelSsbRsrp_dict_1}        Create dictionary           a2HysteresisSCellRelSsbRsrp                2
    ...                                                                a2ThresholdSCellRelSsbRsrp                 64
    ...                                                                a2TimeToTriggerSCellRelSsbRsrp             480ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    list_name=a2MeasSCellRelSsbRsrp
    ...                     elements=${a2MeasSCellRelSsbRsrp_dict_1}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-1      list_name=a2MeasSCellRelSsbRsrq
    ${a2MeasSCellRelSsbRsrq_dict_1}        Create dictionary           a2HysteresisSCellRelSsbRsrq                3
    ...                                                                a2ThresholdSCellRelSsbRsrq                 65
    ...                                                                a2TimeToTriggerSCellRelSsbRsrq             320ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-1                  list_name=a2MeasSCellRelSsbRsrq
    ...                     elements=${a2MeasSCellRelSsbRsrq_dict_1}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-1      list_name=a6MeasSCellSwapSsbRsrp
    ${a6MeasSCellSwapSsbRsrp_dict_1}        Create dictionary          a6HysteresisSCellSwapSsbRsrp               2
    ...                                                                a6OffsetSCellSwapSsbRsrp                   15
    ...                                                                a6TimeToTrigSCellSwapSsbRsrp               ms640
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    list_name=a6MeasSCellSwapSsbRsrp
    ...                     elements=${a6MeasSCellSwapSsbRsrp_dict_1}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-1      list_name=a6MeasSCellSwapSsbRsrq
    ${a6MeasSCellSwapSsbRsrq_dict_1}        Create dictionary          a6HysteresisSCellSwapSsbRsrq               3
    ...                                                                a6OffsetSCellSwapSsbRsrq                   5
    ...                                                                a6TimeToTrigSCellSwapSsbRsrq               ms480
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    list_name=a6MeasSCellSwapSsbRsrq
    ...                     elements=${a6MeasSCellSwapSsbRsrq_dict_1}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-2      list_name=a2MeasSCellRelSsbRsrp
    ${a2MeasSCellRelSsbRsrp_dict_2}        Create dictionary           a2HysteresisSCellRelSsbRsrp                4
    ...                                                                a2ThresholdSCellRelSsbRsrp                 66
    ...                                                                a2TimeToTriggerSCellRelSsbRsrp             480ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-2    list_name=a2MeasSCellRelSsbRsrp
    ...                     elements=${a2MeasSCellRelSsbRsrp_dict_2}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-2      list_name=a2MeasSCellRelSsbRsrq
    ${a2MeasSCellRelSsbRsrq_dict_2}        Create dictionary           a2HysteresisSCellRelSsbRsrq                5
    ...                                                                a2ThresholdSCellRelSsbRsrq                 67
    ...                                                                a2TimeToTriggerSCellRelSsbRsrq             320ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-2                  list_name=a2MeasSCellRelSsbRsrq
    ...                     elements=${a2MeasSCellRelSsbRsrq_dict_2}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-2      list_name=a6MeasSCellSwapSsbRsrp
    ${a6MeasSCellSwapSsbRsrp_dict_2}        Create dictionary          a6HysteresisSCellSwapSsbRsrp               2
    ...                                                                a6OffsetSCellSwapSsbRsrp                   15
    ...                                                                a6TimeToTrigSCellSwapSsbRsrp               ms640
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-2    list_name=a6MeasSCellSwapSsbRsrp
    ...                     elements=${a6MeasSCellSwapSsbRsrp_dict_2}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRCELL-5      list_name=a2MeasSCellRelSsbRsrp
    ${a2MeasSCellRelSsbRsrp_dict_5}        Create dictionary           a2HysteresisSCellRelSsbRsrp                5
    ...                                                                a2ThresholdSCellRelSsbRsrp                 63
    ...                                                                a2TimeToTriggerSCellRelSsbRsrp             640ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-5    list_name=a2MeasSCellRelSsbRsrp
    ...                     elements=${a2MeasSCellRelSsbRsrp_dict_5}
    sqd65_commissioning.Set New List    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-11      list_name=a1MeashoPrefNRLayerSsbRsrp
    ${a1MeashoPrefNRLayerSsbRsrp_dict_1}        Create dictionary           a1HysteresisSsbRsrp                1
    ...                                                                     a1ThresholdhoSsbRsrp               45
    ...                                                                     a1TimeToTriggerhoSsbRsrp           ms40
    scf.add_item_to_list    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-11    list_name=a1MeashoPrefNRLayerSsbRsrp
    ...                     elements=${a1MeashoPrefNRLayerSsbRsrp_dict_1}

    sqd65_commissioning.Set New List    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-4      list_name=nrMeasPrSCellList
    ${nrMeasPrSCellList_dict}        Create dictionary           nrMeasPrSCellDN                MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1
    ...                                                          ssbFrequency01                 431090
    ${nrMeasPrSCellList_dict_1}        Create dictionary           nrMeasPrSCellDN                MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-2
    ...                                                            ssbFrequency01                 518910
    scf.add_item_to_list    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-4    list_name=nrMeasPrSCellList
    ...                     elements=${nrMeasPrSCellList_dict}
    scf.add_item_to_list    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-4    list_name=nrMeasPrSCellList
    ...                     elements=${nrMeasPrSCellList_dict_1}

    sqd65_commissioning.Set New List    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-4      list_name=snssaiList
    ${snssaiList_dict}        Create dictionary           snssaiDN                MRBTS-1/NRBTS-1/SNSSAI-2
    scf.add_item_to_list    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-4    list_name=snssaiList
    ...                     elements=${snssaiList_dict}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1      list_name=a2MeasSCellRelSsbRsrp
    ${a2MeasSCellRelSsbRsrp_dict_6}        Create dictionary           a2HysteresisSCellRelSsbRsrp                3
    ...                                                                a2ThresholdSCellRelSsbRsrp                 80
    ...                                                                a2TimeToTriggerSCellRelSsbRsrp             128ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1    list_name=a2MeasSCellRelSsbRsrp
    ...                     elements=${a2MeasSCellRelSsbRsrp_dict_6}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1      list_name=a2MeasSCellRelSsbRsrq
    ${a2MeasSCellRelSsbRsrq_dict_6}        Create dictionary           a2HysteresisSCellRelSsbRsrq                3
    ...                                                                a2ThresholdSCellRelSsbRsrq                 71
    ...                                                                a2TimeToTriggerSCellRelSsbRsrq             128ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1    list_name=a2MeasSCellRelSsbRsrq
    ...                     elements=${a2MeasSCellRelSsbRsrq_dict_6}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-2      list_name=a2MeasSCellRelSsbRsrp
    ${a2MeasSCellRelSsbRsrp_dict_7}        Create dictionary           a2HysteresisSCellRelSsbRsrp                3
    ...                                                                a2ThresholdSCellRelSsbRsrp                 70
    ...                                                                a2TimeToTriggerSCellRelSsbRsrp             128ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-2    list_name=a2MeasSCellRelSsbRsrp
    ...                     elements=${a2MeasSCellRelSsbRsrp_dict_7}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-2      list_name=a2MeasSCellRelSsbRsrq
    ${a2MeasSCellRelSsbRsrq_dict_7}        Create dictionary           a2HysteresisSCellRelSsbRsrq                3
    ...                                                                a2ThresholdSCellRelSsbRsrq                 73
    ...                                                                a2TimeToTriggerSCellRelSsbRsrq             128ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-2    list_name=a2MeasSCellRelSsbRsrq
    ...                     elements=${a2MeasSCellRelSsbRsrq_dict_7}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-2      list_name=a6MeasSCellSwapSsbRsrp
    ${a6MeasSCellSwapSsbRsrp_dict_3}        Create dictionary          a6HysteresisSCellSwapSsbRsrp               6
    ...                                                                a6OffsetSCellSwapSsbRsrp                   10
    ...                                                                a6TimeToTrigSCellSwapSsbRsrp               ms480
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-2    list_name=a6MeasSCellSwapSsbRsrp
    ...                     elements=${a6MeasSCellSwapSsbRsrp_dict_3}
    sqd65_commissioning.Set New List    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-2      list_name=a6MeasSCellSwapSsbRsrq
    ${a6MeasSCellSwapSsbRsrq_dict_3}        Create dictionary          a6HysteresisSCellSwapSsbRsrq               6
    ...                                                                a6OffsetSCellSwapSsbRsrq                   10
    ...                                                                a6TimeToTrigSCellSwapSsbRsrq               ms480
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-2    list_name=a6MeasSCellSwapSsbRsrq
    ...                     elements=${a6MeasSCellSwapSsbRsrq_dict_3}

    ${log_dir}=                 Get Testcase Log Directory
    ${modified_scf}=    Set variable    ${log_dir}/CB013142-H-B7_SCF.xml
    scf.save_scf    ${modified_scf}
    ${CB013142-H-B7_delta_SCF}=            Set Variable  ${log_dir}/CB013142-H-B7_SCF.json
    scf.calculate_delta_scf    target_scf_path=${modified_scf}    actual_scf_path=${SCF_TC_Setup}    delta_scf_path=${CB013142-H-B7_delta_SCF}
    Log To Console    \n\n\n Config gNB with delta scf in Setup for...
    Config gNB with delta scf  ${CB013142-H-B7_delta_SCF}
    Log to Console    \n\n\n Bring Airphone TL to on Air status in Setup for...
    Bring Airphone TL to on Air status    cfg_file=basic_setup_CB013142.cfg


Update iphy file for CB013142-H-B7
    [Documentation]    Reconfigure iphy.xml file to change the GSCN of Cell_2 to match the GSCN of Cell_1 only for the test instance H_B7
    [Arguments]
    Log to Console    \n\n\nUpdateiphy
    ${tc_conf_dir}       testline.Get Testcase Log Directory
    ${ap_alias}          Connect to Airphone Common Unit
    ssh.execute          cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ap_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml        ${tc_conf_dir}/new_iphy.xml           connection=${ap_alias}
    ${contents}          Get File          ${tc_conf_dir}/new_iphy.xml
    ${all_parts}         Split String      ${contents}     </vcell>
    ${update}            Replace String Using Regexp    ${all_parts}[1]      GSCN>.*<\/GSCN>   GSCN>6486<\/GSCN>
    ${new contents}      catenate         SEPARATOR=</vcell>   ${all_parts}[0]  ${update}  ${all_parts}[2]  ${all_parts}[3]  ${all_parts}[4]
    ...    ${all_parts}[5]  ${all_parts}[6]
    Create File          ${tc_conf_dir}/new_iphy_H_B7.xml    ${new contents}
    ssh.Upload File      ${tc_conf_dir}/new_iphy_H_B7.xml    /rom/simmode/new_iphy.xml   connection=${ap_alias}


Register and Establish PDU Session for Multiple UEs
    [Documentation]    Author: MN RAN RD VRF ULM VT1
    Register and Establish PDU Session   ue_id=1
    Register and Establish PDU Session   ue_id=2  rfsp=15
    Register and Establish PDU Session   ue_id=3  nwslice=2
    Register and Establish PDU Session   ue_id=4  default_qos=1  additional_qos=6
    Register and Establish PDU Session   ue_id=5  rfsp=27
    Register and Establish PDU Session   ue_id=6  nwslice=2
    Register and Establish PDU Session   ue_id=7


Register and Establish PDU Session
    [Documentation]    Author: MN RAN RD VRF ULM VT1
    ...    This keyword is used to register a UE. If RFSP index, Network Slice, Seperate QoS Flows provided as parameter, that also get updated.
    [Arguments]    ${ue_id}   ${nwslice}=1   ${default_qos}=2   ${additional_qos}=${EMPTY}   ${rfsp}=${EMPTY}    ${ue_nr_capabilities}=${EMPTY}
    IF    '${rfsp}' != '${EMPTY}'    Update RFSP parameter in Initial Context Setup  ue_id=${ue_id}  indexToRFSP=${rfsp}
    Send Egate Command and verify output    qosflow_modify ue=${ue_id} qos_flow=${default_qos} default=on
    IF    '${ue_nr_capabilities}' != '${EMPTY}'
        UE Register    ue_id=${ue_id}    nwslice=${nwslice}    ue_nr_capabilities=${ue_nr_capabilities}
    ELSE
        UE Register    ue_id=${ue_id}    nwslice=${nwslice}
    END

    Set traffic type   ue_id=${ue_id}  pdu_id=1  trf_type=internal
    IF    '${additional_qos}' != '${EMPTY}'    Send Egate Command and verify output
    ...   cmd=smf_param id=1 additional_qosflows_to_activate=${additional_qos}
    UE PDU Session Setup   ue_id=${ue_id}  pdu=1  nwslice=${nwslice}  gw=${ue_id}
    IF    '${additional_qos}' != '${EMPTY}'    Smf Param Reset


Register and Establish PDU Session Multiple UEs for E Subfeature
    [Documentation]    This keyword is used to register multiple UEs for KPI testing.
    FOR    ${ue_id}    IN    @{UE_IDs_to_index_mapping}
        Send Egate Command and verify output    qosflow_modify ue=${ue_id} qos_flow=2 default=on
        UE Register    ue_id=${ue_id}    nwslice=1
        Set traffic type   ue_id=${ue_id}  pdu_id=1  trf_type=internal
        UE PDU Session Setup   ue_id=${ue_id}  pdu=1  nwslice=1  gw=${ue_id}
    END


Attach Multiple UEs To LTE And Trigger LTE-NR Dual Connectivity
    [Documentation]    Attach Multiple UEs to LTE and trigger dual connectivity
    [Arguments]    ${target_cells}=1
    FOR   ${ue_id}    ${index}   IN   &{UE_IDs_to_index_mapping}
        IF    '${ue_id}'=='21' or '${ue_id}'=='22'    Set spid for UE    ue_id=${ue_id}     spid=12
        Attach single UE to LTE and Trigger LTE-NR Dual connectivity    ue_id=${ue_id}    target_cells=${target_cells}
    END


Attach single UE to LTE and Trigger LTE-NR Dual connectivity
    [Documentation]    Attach single UE to LTE and trigger dual connectivity
    [Arguments]    ${ue_id}=14    ${target_cells}=1
    ute_wtssim.execute egate command    cmd=enb_endc_param id=1 serving_cell_index_range_scg=5:31    alias=ap_egate
    sleep     1s

    Attach UE to LTE  ue_id=${ue_id}
    Trigger LTE-NR dual connectivity for bearers    ue_id=${ue_id}  target_cells=${target_cells}


Set spid for UE
    [Documentation]    [PRIVATE]    set spid before attach in wts
    [Arguments]     ${ue_id}     ${spid}
    ${cmd}   set variable   ue_enb_param id=${ue_id} spid=${spid}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate
    sleep     1s


Verify Whether UEs Are Configured With A1 Measurement For SCell Addition
    [Arguments]    ${carrier_freq}
    FOR   ${ue_id}    ${index}   IN   &{UE_IDs_to_index_mapping}
        Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    END


Initiate Both Uplink and Downlink Data Traffic On UEs E Subfeature
    [Arguments]   ${dl_data}   ${ul_data}    ${pdu}=1
    FOR   ${ue_id}    ${index}   IN   &{UE_IDs_to_index_mapping}
        Start Data Traffic In Egate  ue_id=${ue_id}  direction=dl  mbps=${dl_data}  pdu=${pdu}
        Start Data Traffic In Egate  ue_id=${ue_id}  direction=ul  mbps=${ul_data}  pdu=${pdu}
    END
    Sleep   10s  Reason=waiting for data traffic to get stabilized


Initiate Both Uplink and Downlink Data Traffic On UEs
    [Arguments]   ${dl_data}   ${ul_data}    ${pdu}=1    ${id}=${EMPTY}
    FOR   ${ue_id}    ${index}   IN   &{UE_IDs_to_index_mapping}
        IF    '${id}' == '${EMPTY}'
            Initiate Uplink and Downlink Data Traffic in Egate for single SA UE    ue_id=${ue_id}    dl_data=${dl_data}    ul_data=${ul_data}
            ...    pdu=${pdu}
        ELSE
            Initiate Uplink and Downlink Data Traffic in Egate for single NSA UE    ue_id=${ue_id}    dl_data=${dl_data}    ul_data=${ul_data}
            ...    id=${id}
        END
    END


Initiate Uplink and Downlink Data Traffic in Egate for single NSA UE
    [Arguments]   ${ue_id}    ${dl_data}   ${ul_data}    ${id}=2
        Start data traffic in egate    ue_id=${ue_id}    direction=dl    mbps=${dl_data}    id=${id}
        Start data traffic in egate    ue_id=${ue_id}    direction=ul    mbps=${ul_data}    id=${id}
    Sleep   10s  Reason=waiting for data traffic to get stabilized
    Display single UE traffic stats    ${ue_id}


Initiate Uplink and Downlink Data Traffic in Egate for single SA UE
    [Arguments]   ${ue_id}   ${dl_data}   ${ul_data}    ${pdu}=1
    Start data traffic in egate  ue_id=${ue_id}  direction=dl  mbps=${dl_data}  pdu=${pdu}
    Start data traffic in egate  ue_id=${ue_id}  direction=ul  mbps=${ul_data}  pdu=${pdu}
    Sleep   10s  Reason=waiting for data traffic to get stabilized
    Display single UE traffic stats    ${ue_id}


Display Multiple UEs Traffic Stats
    FOR   ${ue_id}    ${index}   IN   &{UE_IDs_to_index_mapping}
        Display single UE traffic stats    ${ue_id}
    END


Display single UE traffic stats
    [Arguments]   ${ue_id}
    wts_ue.Send Egate Command and verify output   cmd=ue_stats_nr id=${ue_id} type=pdsch scell=5,6,7,8
    Sleep   3s
    wts_ue.Send Egate Command and verify output   cmd=ue_stats_nr id=${ue_id} type=pusch scell=5,6,7,8
    Sleep   3s


Send A1 MR For SCell Addition And Verify Whether GNB Configures CA And Deconfigures A1 Measurement At The UE
    [Arguments]    ${carrier_freq}    ${meas_id}=2    ${ca_msg_verify}=@{CA_MSG_SEQ}
    ...            ${pass_regexp}=rrcReconfigurationComplete    ${srsrp_nr}=55    ${srsrq_nr}=55
    ${log_dir}=                 Get Testcase Log Directory
    FOR   ${ue_id}    ${index}   IN   &{UE_IDs_to_index_mapping}
        ${egate_log}  wts_ue.Send Egate Command And Verify Output
        ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
        ...    pass_regexp=${pass_regexp}
        ${Rrc_after_A1_based_scell_addition}    Set variable    ${log_dir}/Rrc_after_A1_based_scell_addition_UE_${ue_id}.log
        Create File    ${Rrc_after_A1_based_scell_addition}   ${egate_log}
        Verify Measurement ID is absent   event_type=A1  ue_id=${ue_id}  carrier_freq=${carrier_freq}
        util.Verify Sequence in File   ${Rrc_after_A1_based_scell_addition}  @{ca_msg_verify}
    END


Send A1 MR For SCell Addition And Verify Whether GNB Configures CA_A6
    [Arguments]    ${carrier_freq}    ${meas_id}=2    ${ca_msg_verify}=@{CA_MSG_SEQ}
    ...            ${pass_regexp}=rrcReconfigurationComplete    ${srsrp_nr}=60    ${srsrq_nr}=60
    Log To Console   \nCA_MSG_SEQ
    ${log_dir}=                 Get Testcase Log Directory
    FOR   ${ue_id}    ${index}   IN   &{UE_IDs_to_index_mapping}
        ${egate_log}  wts_ue.Send Egate Command And Verify Output
        ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
        ...    pass_regexp=${pass_regexp}
        ${Rrc_after_A1_based_scell_addition}    Set variable    ${log_dir}/Rrc_after_A1_based_scell_addition_UE_${ue_id}.log
        Create File    ${Rrc_after_A1_based_scell_addition}   ${egate_log}
        sqd65_keywords.Verify Measurement ID is absent   event_type=A1  ue_id=${ue_id}  carrier_freq=${carrier_freq}
        sqd65_keywords.Verify Measurement ID Is Configured   event_type=A6  ue_id=${ue_id}  carrier_freq=518910
        util.Verify Sequence in File   ${Rrc_after_A1_based_scell_addition}  @{ca_msg_verify}
    END

Send A6 MR For SCell Swap
    [Arguments]    ${meas_id}=6    ${ca_msg_verify}=@{SCELL_SWAP}
    ...            ${pass_regexp}=rrcReconfigurationComplete
    Log To Console   \nCA_MSG_SEQ
    ${log_dir}=                 Get Testcase Log Directory
    FOR   ${ue_id}    ${index}   IN   &{UE_IDs_to_index_mapping}
        ${egate_log}  wts_ue.Send Egate Command And Verify Output
        ...    cmd=ue_measurement_send_nr id=4 meas_id=${meas_id} event=A6 scell=1 scell_rsrp=40 scell_rsrq=20 phycell_id=51 nrsrp_nr=60 nrsrq_nr=90
        ...    pass_regexp=${pass_regexp}
        ${Rrc_after_A6_based_scell_swap}    Set variable    ${log_dir}/Rrc_after_A6_based_scell_swap_${ue_id}.log
        Create File    ${Rrc_after_A6_based_scell_swap}   ${egate_log}
        util.Verify Sequence in File   ${Rrc_after_A6_based_scell_swap}  @{ca_msg_verify}
    END


Verify whether UEs are configured with A2 Measurement event for the PCell Change
    [Documentation]    Author: MN RAN RD VRF ULM VT1
    [Arguments]    ${carrier_freq}    ${report_id}=3  ${measid}=3
    FOR    ${ue_id}    ${index}    IN    &{UE_IDs_to_index_mapping}
        Verify UE is configured with A2 Measurement event for the PCell Change
        ...    carrier_freq=${carrier_freq}
        ...    ue_id=${ue_id}
        ...    thresh=${IAF_a2MeasPCellSwitchSsbRsrp_a2Threshold[${index}]}
        ...    hyst=${IAF_a2MeasPCellSwitchSsbRsrp_a2Hysteresis[${index}]}
        ...    time_to_trig=ms${IAF_a2MeasPCellSwitchSsbRsrp_a2TimeToTrigger[${index}]}
        ...    report_id=${report_id}
        ...    measid=${measid}
    END


Verify UE is configured with A2 Measurement event for the PCell Change
    [Documentation]    Author: MN RAN RD VRF ULM VT1
    [Arguments]    ${carrier_freq}  ${ue_id}  ${thresh}  ${hyst}  ${time_to_trig}  ${report_id}=3  ${measid}=3  ${meas_event}=A2
    ...  ${meas_config}=rsrp
    Verify Measurement ID Is Configured  event_type=${meas_event}  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    # String to use as regex for report Config Id
    ${reportConfigId_str}=   Catenate    SEPARATOR=${empty}    reportConfigId\\s${report_id},(?:.|\\n)*?eventId\\sevent${meas_event}\\s:\\s\\n\\n
    ...    \\s+{\\n\\n\\s+a2-Threshold\\s${meas_config}\\s:\\s${thresh},(?:.|\\n)*?hysteresis\\s${hyst},\\n\\n\\s+timeToTrigger\\s${time_to_trig}\\n
    ${reportConfigId}=       Set Variable   ${reportConfigId_str}
    # String to use as regex for measurement add mod id
    ${measIdToAddMod_str}=   Catenate     SEPARATOR=${empty}       measIdToAddModList\\s\\n\\n\\s+{\\n\\n\\s+{\\n\\n\\s+measId\\s${measid},\\n\\n
    ...     .*measObjectId\\s1,\\n\\n\\s+reportConfigId\\s${report_id}\\n\\n\\s+}
    ${measIdToAddMod}=       Set Variable   ${measIdToAddMod_str}
    @{meas_Event_list}=            Create List    ${reportConfigId}   ${measIdToAddMod}
    ${log_dir}=                 Get Testcase Log Directory
    ${log_content}=          Get File       ${log_dir}/Rrc_after_A1_based_scell_addition_UE_${ue_id}.log
    FOR   ${event}    IN    @{meas_Event_list}
        ${event_present}=   Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${event}
        IF    ${event_present} == False    FAIL    Expected measurement params not present in RRC reconfiguration measurement config
    END


Verify Whether UEs Are Configured With A2 Measurement Event For The SCell Release
    [Documentation]    Author: MN RAN RD VRF ULM VT1
    [Arguments]    ${carrier_freq}    ${report_id}=2  ${measid}=2
    FOR    ${ue_id}    ${index}    IN    &{UE_IDs_to_index_mapping}
        Verify UE is configured with A2 Measurement event for the SCell Release
        ...    carrier_freq=${carrier_freq}
        ...    ue_id=${ue_id}
        ...    thresh=${SCELL_a2MeasSCellRelSsbRsrq_a2Threshold[${index}]}
        ...    hyst=${SCELL_a2MeasSCellRelSsbRsrq_a2Hysteresis[${index}]}
        ...    time_to_trig=ms${SCELL_a2MeasSCellRelSsbRsrq_a2TimeToTrigger[${index}]}
        ...    report_id=${report_id}
        ...    measid=${measid}
    END


Verify UE is configured with A2 Measurement event for the SCell Release
    [Documentation]    Author: MN RAN RD VRF ULM VT1
    [Arguments]    ${carrier_freq}  ${ue_id}  ${thresh}  ${hyst}  ${time_to_trig}  ${report_id}=2  ${measid}=2  ${meas_event}=A2
    ...  ${meas_config}=rsrp  ${meas_obj_id}=2
    Verify Measurement ID Is Configured  event_type=${meas_event}  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    # String to use as regex for report Config Id
    ${reportConfigId_str}=   Catenate    SEPARATOR=${empty}    reportConfigId\\s${report_id},(?:.|\\n)*?eventId\\sevent${meas_event}\\s:\\s\\n\\n
    ...    \\s+{\\n\\n\\s+a2-Threshold\\s${meas_config}\\s:\\s${thresh},(?:.|\\n)*?hysteresis\\s${hyst},\\n\\n\\s+timeToTrigger\\s${time_to_trig}\\n
    ${reportConfigId}=       Set Variable   ${reportConfigId_str}
    # String to use as regex for measurement add mod id
    ${measIdToAddMod_str}=   Catenate     SEPARATOR=${empty}       measIdToAddModList\\s\\n\\n\\s+{\\n\\n\\s+{\\n\\n\\s+measId\\s${measid},\\n\\n
    ...     \\s+measObjectId\\s${meas_obj_id},\\n\\n\\s+reportConfigId\\s${report_id}\\n\\n\\s+}
    ${measIdToAddMod}=       Set Variable   ${measIdToAddMod_str}
    @{meas_Event_list}=            Create List    ${reportConfigId}   ${measIdToAddMod}
    ${log_dir}=                 Get Testcase Log Directory
    ${log_content}=          Get File       ${log_dir}/Rrc_after_A1_based_scell_addition_UE_${ue_id}.log
    FOR   ${event}    IN    @{meas_Event_list}
        ${event_present}=   Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${event}
        IF    ${event_present} == False    FAIL    Expected measurement params not present in RRC reconfiguration measurement config
    END


Smf Param Reset
    [Documentation]    Reseting smf parameters to default values
    Send Egate Command and verify output   cmd=smf_param id=1 reset


Update RFSP parameter in Initial Context Setup
    [Documentation]    To update online changeable AMF Initial Context Setup RFSP parameter to send RFSP during context setup
    [Arguments]   ${ue_id}  ${indexToRFSP}
    wts_ue.Send Egate Command and verify output  cmd=amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=${indexToRFSP}


Send A2 MR and Verify PCELL switch did not happen
    [Arguments]   ${carrier_freq}    ${scell_1_meas}=scell=1 scell_rsrp=70 scell_rsrq=70
    ...    ${scell_2_meas}=scell=2 scell_rsrp=80 scell_rsrq=80    ${meas_id}=3
    FOR    ${ue_id}    ${index}    IN    &{UE_IDs_to_index_mapping}
        ${srsrp}    Evaluate    ${IAF_a2MeasPCellSwitchSsbRsrp_a2Threshold[${index}]}-${1}
        ${srsrq}    Evaluate    ${IAF_a2MeasPCellSwitchSsbRsrp_a2Threshold[${index}]}-${IAF_a2MeasPCellSwitchSsbRsrp_a2Hysteresis[${index}]}+${1}
        wts_ue.Send Egate Command and verify output
        ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=${srsrp} srsrq_nr=${srsrq} ${scell_1_meas} ${scell_2_meas}
        sleep     1s
        Verify Measurement ID Is Configured  event_type=A2  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    END


Send A2 MR and Verify PCELL switch happened
    [Arguments]   ${carrier_freq}    ${scell_1_meas}=scell=1 scell_rsrp=70 scell_rsrq=70
    ...    ${scell_2_meas}=scell=2 scell_rsrp=80 scell_rsrq=80    ${meas_id}=3    ${pass_regexp}=rrcReconfigurationComplete
    ${log_dir}=                 Get Testcase Log Directory
    FOR    ${ue_id}    ${index}    IN    &{UE_IDs_to_index_mapping}
        ${srsrp}    Evaluate    ${IAF_a2MeasPCellSwitchSsbRsrp_a2Threshold[${index}]}-${1}
        ${srsrq}    Evaluate    ${IAF_a2MeasPCellSwitchSsbRsrp_a2Threshold[${index}]}-${IAF_a2MeasPCellSwitchSsbRsrp_a2Hysteresis[${index}]}-${1}
        ${egate_log}    wts_ue.Send Egate Command and verify output
        ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=${srsrp} srsrq_nr=${srsrq} ${scell_1_meas} ${scell_2_meas}
        ...    pass_regexp=${pass_regexp}
        ${Rrc_after_A2_based_pcell_change}    Set Variable    ${log_dir}/Rrc_after_A2_based_pcell_change_UE_${ue_id}.log
        Create File    ${Rrc_after_A2_based_pcell_change}   ${egate_log}
        sleep     1s
        Verify Measurement ID is absent   event_type=A2  ue_id=${ue_id}  carrier_freq=${carrier_freq}
        util.Verify Sequence in File    ${Rrc_after_A2_based_pcell_change}    @{PCELL_SWITCH_MSG_SEQ}
        sleep     1s
        Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_4}
    END


Send A1 MR and Verify PCELL switch did not happen
    [Arguments]    ${meas_id}=3    ${scell}=1
    FOR    ${ue_id}    ${index}    IN    &{UE_IDs_to_index_mapping}
        ${scell_1_index}    ${scell_2_index}    Convert SCELL_default_DN_index value to scell number index value    ${index}
        ${srsrp}    Evaluate    ${SCELL_a1MeasPCellSwitchSsbRsrp_a1Threshold[${scell_1_index}]}-${1}
        ${srsrq}    Evaluate
        ...    ${SCELL_a1MeasPCellSwitchSsbRsrp_a1Threshold[${scell_1_index}]}+${SCELL_a1MeasPCellSwitchSsbRsrp_a1Hysteresis[${scell_1_index}]}-${1}
        wts_ue.Send Egate Command and verify output
        ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 scell=${scell} scell_rsrp=${srsrp} scell_rsrq=${srsrq}
        sleep     2s
        Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_1}
        Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_2}
    END


Send A1 MR and Verify PCELL switch happened
    [Arguments]    ${meas_id}=3    ${scell}=1    ${pass_regexp}=rrcReconfigurationComplete
    ${log_dir}=                 Get Testcase Log Directory
    FOR    ${ue_id}    ${index}    IN    &{UE_IDs_to_index_mapping}
        ${scell_1_index}    ${scell_2_index}    Convert SCELL_default_DN_index value to scell number index value    ${index}
        ${srsrp}    Evaluate    ${SCELL_a1MeasPCellSwitchSsbRsrp_a1Threshold[${scell_1_index}]}-${1}
        ${srsrq}    Evaluate
        ...    ${SCELL_a1MeasPCellSwitchSsbRsrp_a1Threshold[${scell_1_index}]}+${SCELL_a1MeasPCellSwitchSsbRsrp_a1Hysteresis[${scell_1_index}]}+${1}
        ${egate_log}    wts_ue.Send Egate Command and verify output
        ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 scell=${scell} scell_rsrp=${srsrp} scell_rsrq=${srsrq}
        ...    pass_regexp=${pass_regexp}
        sleep     2s
        ${Rrc_after_A1_based_pcell_change}    Set Variable    ${log_dir}/Rrc_after_A1_based_pcell_change_UE_${ue_id}.log
        Create File    ${Rrc_after_A1_based_pcell_change}   ${egate_log}
        sleep     2s
        Verify Measurement ID Is absent  event_type=A1  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_4}
        Verify Measurement ID Is absent  event_type=A1  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_2}
        util.Verify Sequence in File    ${Rrc_after_A1_based_pcell_change}    @{A1_BASED_PCELL_SWITCH_MSG_SEQ}
        sleep     2s
        Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_1}
    END


Send A1 MR and Verify PCELL switch did not happen for NSA UEs
    [Arguments]    ${meas_id}=2    ${scell}=6
    FOR    ${ue_id}    ${index}    IN    &{UE_IDs_to_index_mapping}
        ${srsrp}    Evaluate    ${SCELL_a1MeasPCellSwitchSsbRsrp_a1Threshold[${index}]}-${1}
        ${srsrq}    Evaluate
        ...    ${SCELL_a1MeasPCellSwitchSsbRsrp_a1Threshold[${index}]}+${SCELL_a1MeasPCellSwitchSsbRsrp_a1Hysteresis[${index}]}-${1}
        wts_ue.Send Egate Command and verify output
        ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 scell=${scell} scell_rsrp=${srsrp} scell_rsrq=${srsrq}
        sleep     2s
        Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_1}
    END


Send A1 MR and Verify PCELL switch happened for NSA UEs
    [Arguments]    ${meas_id}=2    ${scell}=6    ${pass_regexp}=rrcReconfigurationComplete
    ${log_dir}=                 Get Testcase Log Directory
    FOR    ${ue_id}    ${index}    IN    &{UE_IDs_to_index_mapping}
        ${srsrp}    Evaluate    ${SCELL_a1MeasPCellSwitchSsbRsrp_a1Threshold[${index}]}-${1}
        ${srsrq}    Evaluate
        ...    ${SCELL_a1MeasPCellSwitchSsbRsrp_a1Threshold[${index}]}+${SCELL_a1MeasPCellSwitchSsbRsrp_a1Hysteresis[${index}]}+${1}
        ${egate_log}    wts_ue.Send Egate Command and verify output
        ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 scell=${scell} scell_rsrp=${srsrp} scell_rsrq=${srsrq}
        ...    pass_regexp=${pass_regexp}
        ${Rrc_after_A1_based_pcell_change}    Set Variable    ${log_dir}/Rrc_after_A1_based_pcell_change_UE_${ue_id}.log
        Create File    ${Rrc_after_A1_based_pcell_change}   ${egate_log}
        sleep     2s
        Verify Measurement ID Is absent  event_type=A1  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_4}
        util.Verify Sequence in File    ${Rrc_after_A1_based_pcell_change}    @{A1_BASED_PCELL_SWITCH_MSG_SEQ}
        sleep     2s
        Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_1}
    END


Send A2 MR And Verify SCELL Release Did Not Happened
    [Arguments]    ${meas_id}=2    ${scell}=6
    FOR    ${ue_id}    ${index}    IN    &{UE_IDs_to_index_mapping}
        ${srsrp}    Evaluate    ${SCELL_a2MeasSCellRelSsbRsrq_a2Threshold[${index}]}-${1}
        ${srsrq}    Evaluate    ${SCELL_a2MeasSCellRelSsbRsrq_a2Threshold[${index}]}-${SCELL_a2MeasSCellRelSsbRsrq_a2Hysteresis[${index}]}+${1}
        wts_ue.Send Egate Command and verify output
        ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell} scell_rsrp=${srsrp} scell_rsrq=${srsrq}
        sleep     1s
        Verify Measurement ID Is Configured  event_type=A2  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_1}
    END


Send A2 MR and Verify SCELL Release Happened
    [Arguments]   ${meas_id}=2    ${scell}=6    ${pass_regexp}=rrcConnectionReconfigurationComplete
    ${log_dir}=                 Get Testcase Log Directory
    FOR    ${ue_id}    ${index}    IN    &{UE_IDs_to_index_mapping}
        ${srsrp}    Evaluate    ${SCELL_a2MeasSCellRelSsbRsrq_a2Threshold[${index}]}-${1}
        ${srsrq}    Evaluate    ${SCELL_a2MeasSCellRelSsbRsrq_a2Threshold[${index}]}-${SCELL_a2MeasSCellRelSsbRsrq_a2Hysteresis[${index}]}-${1}
        ${egate_log}    wts_ue.Send Egate Command and verify output
        ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell} scell_rsrp=${srsrp} scell_rsrq=${srsrq}
        ...    pass_regexp=${pass_regexp}
        ${Rrc_after_A2_based_scell_release}    Set Variable    ${log_dir}/Rrc_after_A2_based_scell_release_UE_${ue_id}.log
        Create File    ${Rrc_after_A2_based_scell_release}   ${egate_log}
        sleep     2s
        Verify Measurement ID is absent   event_type=A2  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_1}
        util.Verify Sequence in File    ${Rrc_after_A2_based_scell_release}    @{A2_BASED_SCELL_RELEASE_MSG_SEQ}
        sleep     2s
        Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_4}
    END


Stop Data transfer and Deregister All UEs
    [Documentation]    Thie keyword stops both DL and UL data traffic and de-register the UE from the network
    FOR   ${ue_id}    ${index}   IN   &{UE_IDs_to_index_mapping}
        Stop data traffic in egate  ue_id=${ue_id}  direction=dl
        Stop data traffic in egate  ue_id=${ue_id}  direction=ul
        UE Deregister  ue_id=${ue_id}  ue_deregister_type=switch_off
    END


Stop Data transfer And Detach NSA UEs From 5G And 4G
    [Documentation]    Thie keyword stops both DL and UL data traffic and detacch the NSA UEs from the network
    FOR   ${ue_id}    ${index}   IN   &{UE_IDs_to_index_mapping}
        Stop data traffic in egate  ue_id=${ue_id}  direction=dl  id=2
        Stop data traffic in egate  ue_id=${ue_id}  direction=ul  id=2
        UE Dual Connectivity Release  ue_id=${ue_id}  bearer=2  by=enb  cause=off
        Detach UE from LTE    ue_id=${ue_id}
    END


Update PM reference table with UE Count
    ${E_B1_PM}=    Create List
    ...    (MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRMASA-4)M55190C00001   ==  ${KPI_UE_COUNT}  SA_MEAS_PROFILE_SELECTED (Legacy CB008127)
    ...    (MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRMIAF-20)M55187C00001  ==  ${KPI_UE_COUNT}  IAF_MEAS_PROFILE_CONF_ATT (Legacy CB008127)
    ...    (MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRMIAF-20)M55187C00003  ==  ${KPI_UE_COUNT}  IAF_CA_MEAS_PROFILE_CONF_ATT (New counter CB013142)
    ...    (MRBTS-1/NRBTS-1/NRCELL-4/PLMN-PLMN/NRMASA-4)M55190C00001   ==  ${KPI_UE_COUNT}  SA_MEAS_PROFILE_SELECTED (Legacy CB008127)
    ...    (MRBTS-1/NRBTS-1/NRCELL-4/PLMN-PLMN/NRMSCL-67)M55205C00001  ==  ${KPI_UE_COUNT}  SCELL_MEAS_PROFILE_CONF_ATT (New counter CB013142)
    ...    (MRBTS-1/NRBTS-1/NRCELL-4/PLMN-PLMN/NRMSCL-1)M55205C00001   ==  ${KPI_UE_COUNT}  SCELL_MEAS_PROFILE_CONF_ATT (New counter CB013142)
    ...    @{E_B1_PM}
    Set Suite Variable    ${E_B1_PM}


Collect and Verify PM Counters
    [Arguments]   ${test_instance}  ${pm_collector_alias}=gnb_pm_counters    ${counter_extension}=${EMPTY}
    ${log_dir}=    testline.Get Testcase Log Directory
    ${pm_files}=   Collect PM Counters  collector_alias=${pm_collector_alias}${counter_extension}
    Run keyword and Continue on Failure    Verify PM Counter Reference table    reference_table=${${test_instance}_PM}  pm_dir=${pm_files}


Collect PM counters
    [Arguments]    ${collector_alias}
    ${log_dir}=    testline.Get Testcase Log Directory
    pmcounters.Wait until the current Measurement Period stops
    ${pm_files}=    pmcounters.Collect PM Counter    target_dir=${log_dir}    collector_alias=${collector_alias}
    RETURN  ${pm_files}


Collect and Verify PM Counters For KPI
    [Arguments]   ${test_instance}    ${tc_identifier}    ${pm_collector_alias}=gnb_pm_counters    ${counter_extension}=${EMPTY}
    ${log_dir}=    testline.Get Testcase Log Directory
    ${pm_files}=   Collect PM Counters  collector_alias=${pm_collector_alias}${counter_extension}
    IF    '${tc_identifier}' == '_feat_OFF'
        Run Keyword And Expect Error    *    pmcounters.Verify PM Counter Reference Table    reference_table=${${test_instance}_PM}
        ...    pm_dir=${pm_files}     meas_index=1
    ELSE
        Run Keyword And Continue On Failure    pmcounters.Verify PM Counter Reference Table    reference_table=${${test_instance}_PM}
        ...    pm_dir=${pm_files}     meas_index=1
    END

    ${scenario_name}    Set Variable
    ...    CB013142_E_ET_TC01_B1_SA_Secondary_measurement_on_PCell_using_UE_PC_based_meas_profile_during_A2_and_A1_MR_reception_for_PCell_change
    &{pm_file_scenario_dict}    parser.Get Pm File Scenario Dict    ts_log_dir=${log_dir}
    ...    kw_name=CB013142_Keywords.Perform CB013142-E Test Steps In Loop
    ...    scenario_list=${KPI_TC_IDENTIFIER}
    ...    pm_location=/../${scenario_name}/gnb_pm_counters
    ltepat_setup.Install Lte Pat
    ${scenario_names}    Collections.Get Dictionary Keys    ${pm_file_scenario_dict}
    FOR    ${scenario_name}    IN    @{scenario_names}
        &{runtime_options}    BuiltIn.Create Dictionary    @OutputDirectory=${log_dir}/PMC/kpi/${scenario_name}
        ${config_file_path}=    ltepat_run.Create Configuration File
        ...  pm_files=${pm_file_scenario_dict['${scenario_name}']['pm_file']}
        ...  suite_log_dir=${log_dir}
        ...  runtime_options=${runtime_options}
       ltepat_run.Run Ltepat    ${config_file_path}    ${log_dir}/ltepat_output_${scenario_name}.txt
    END


Verify whether UEs are configured with A1 Measurement event for the PCell Change
    [Documentation]    Author: MN RAN RD VRF ULM VT1
    FOR    ${ue_id}    ${SCELL_default_DN_index}    IN    &{UE_IDs_to_index_mapping}
        ${scell_1_index}    ${scell_2_index}    Convert SCELL_default_DN_index value to scell number index value    ${SCELL_default_DN_index}
        Verify UE is configured with A1 Measurement on SCell for the PCell Change
        ...    ue_id=${ue_id}
        ...    thresh_1=${SCELL_a1MeasPCellSwitchSsbRsrp_a1Threshold[${scell_1_index}]}
        ...    hyst_1=${SCELL_a1MeasPCellSwitchSsbRsrp_a1Hysteresis[${scell_1_index}]}
        ...    time_to_trig_1=ms${SCELL_a1MeasPCellSwitchSsbRsrp_a1TimeToTrigger[${scell_1_index}]}
        ...    thresh_2=${SCELL_a1MeasPCellSwitchSsbRsrp_a1Threshold[${scell_2_index}]}
        ...    hyst_2=${SCELL_a1MeasPCellSwitchSsbRsrp_a1Hysteresis[${scell_2_index}]}
        ...    time_to_trig_2=ms${SCELL_a1MeasPCellSwitchSsbRsrp_a1TimeToTrigger[${scell_2_index}]}
    END

Verify whether UEs are configured with A1 Measurement event for the PCell Change for E Subfeature
    [Documentation]    Author: MN RAN RD VRF ULM VT1
    FOR    ${ue_id}    ${SCELL_default_DN_index}    IN    &{UE_IDs_to_index_mapping}
        ${scell_1_index}    ${scell_2_index}    Convert SCELL_default_DN_index value to scell number index value    ${SCELL_default_DN_index}
        Verify UE is configured with A1 Measurement on SCell for the PCell Change
        ...    ue_id=${ue_id}
        ...    thresh_1=${SCELL_a1MeasPCellSwitchSsbRsrp_a1Threshold[${scell_1_index}]}
        ...    hyst_1=${SCELL_a1MeasPCellSwitchSsbRsrp_a1Hysteresis[${scell_1_index}]}
        ...    time_to_trig_1=ms${SCELL_a1MeasPCellSwitchSsbRsrp_a1TimeToTrigger[${scell_1_index}]}
        ...    thresh_2=${SCELL_a1MeasPCellSwitchSsbRsrp_a1Threshold[${scell_2_index}]}
        ...    hyst_2=${SCELL_a1MeasPCellSwitchSsbRsrp_a1Hysteresis[${scell_2_index}]}
        ...    time_to_trig_2=ms${SCELL_a1MeasPCellSwitchSsbRsrp_a1TimeToTrigger[${scell_2_index}]}
        ...    report_id_1=5   report_id_2=6
        ...    meas_obj_id_1=4    meas_obj_id_2=5
        ...    measid_1=6    measid_2=7
    END


Convert SCELL_default_DN_index value to scell number index value
    [Arguments]    ${SCELL_default_DN_index}
        ${SCELL_DN_index}    Get From Dictionary
        ...    ${SCELL_default_DN_index_to_SCELL_DN_index_mapping}    ${SCELL_default_DN_index}
        ${scell_1_index}    Set Variable If    ${NRMEASPR_SCELL_ssbFrequency[${SCELL_default_DN_index}]}==${CARRIER_FREQ_1}
        ...    ${SCELL_DN_index}    ${SCELL_default_DN_index}
        ${scell_2_index}    Set Variable If    ${NRMEASPR_SCELL_ssbFrequency[${SCELL_default_DN_index}]}==${CARRIER_FREQ_1}
        ...    ${SCELL_default_DN_index}    ${SCELL_DN_index}
    RETURN    ${scell_1_index}    ${scell_2_index}


Verify UE is configured with A1 Measurement on SCell for the PCell Change
    [Documentation]    Author: MN RAN RD VRF ULM VT1
    [Arguments]  ${ue_id}  ${thresh_1}  ${hyst_1}  ${time_to_trig_1}  ${thresh_2}  ${hyst_2}  ${time_to_trig_2}  ${report_id_1}=3  ${report_id_2}=4
    ...          ${meas_obj_id_1}=2  ${meas_obj_id_2}=3  ${measid_1}=3  ${measid_2}=4  ${meas_event}=A1  ${meas_config_1}=rsrp  ${meas_config_2}=rsrp
    # String to use as regex for report Config Id
    ${reportConfigId_str}=   Catenate    SEPARATOR=${empty}    reportConfigId\\s${report_id_1},(?:.|\\n)*?eventId\\sevent${meas_event}\\s:\\s\\n\\n
    ...    \\s+{\\n\\n\\s+a1-Threshold\\s${meas_config_1}\\s:\\s${thresh_1},(?:.|\\n)*?hysteresis\\s${hyst_1},\\n\\n\\s+timeToTrigger\\s
    ...    ${time_to_trig_1}\\n(?:.|\\n)*?reportConfigId\\s${report_id_2},(?:.|\\n)*?eventId\\sevent${meas_event}\\s:\\s\\n\\n\\s+{\\n\\n\\s+
    ...    a1-Threshold\\s${meas_config_2}\\s:\\s${thresh_2},(?:.|\\n)*?hysteresis\\s${hyst_2},\\n\\n\\s+timeToTrigger\\s${time_to_trig_2}\\n
    ${reportConfigId}=       Set Variable   ${reportConfigId_str}
    # String to use as regex for measurement add mod id
    ${measIdToAddMod_str}=   Catenate     SEPARATOR=${empty}       measIdToAddModList\\s\\n\\n\\s+{\\n\\n\\s+{\\n\\n\\s+measId\\s${measid_1},\\n\\n
    ...     \\s+measObjectId\\s${meas_obj_id_1},\\n\\n\\s+reportConfigId\\s${report_id_1}\\n\\n\\s+},\\n\\n\\s+{\\n\\n\\s+measId\\s${measid_2},\\n\\n
    ...     \\s+measObjectId\\s${meas_obj_id_2},\\n\\n\\s+reportConfigId\\s${report_id_2}\\n\\n\\s+}
    ${measIdToAddMod}=       Set Variable   ${measIdToAddMod_str}
    @{meas_Event_list}=            Create List    ${reportConfigId}   ${measIdToAddMod}
    ${log_dir}=                 Get Testcase Log Directory
    ${log_content}=          Get File       ${log_dir}/Rrc_after_A1_based_scell_addition_UE_${ue_id}.log
    FOR   ${event}    IN    @{meas_Event_list}
        ${event_present}=   Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${event}
        IF    ${event_present} == False    FAIL    Expected measurement params not present in RRC reconfiguration measurement config
    END


Verify whether UEs are configured with A1 Measurement event for the PCell Change for NSA UEs
    [Documentation]    Author: MN RAN RD VRF ULM VT1
    [Arguments]    ${carrier_freq}    ${report_id}=2  ${measid}=2
    FOR    ${ue_id}    ${index}    IN    &{UE_IDs_to_index_mapping}
        Verify UE is configured with A1 Measurement event for the PCell Change for NSA UEs
        ...    carrier_freq=${carrier_freq}
        ...    ue_id=${ue_id}
        ...    thresh=${SCELL_a1MeasPCellSwitchSsbRsrp_a1Threshold[${index}]}
        ...    hyst=${SCELL_a1MeasPCellSwitchSsbRsrp_a1Hysteresis[${index}]}
        ...    time_to_trig=ms${SCELL_a1MeasPCellSwitchSsbRsrp_a1TimeToTrigger[${index}]}
        ...    report_id=${report_id}
        ...    measid=${measid}
    END


Verify UE is configured with A1 Measurement event for the PCell Change for NSA UEs
    [Documentation]    Author: MN RAN RD VRF ULM VT1
    [Arguments]      ${carrier_freq}  ${ue_id}  ${thresh}  ${hyst}  ${time_to_trig}  ${report_id}=2  ${measid}=2  ${meas_event}=A1
    ...  ${meas_config}=rsrp    ${meas_obj_id}=2
    Verify Measurement ID Is Configured  event_type=${meas_event}  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    # String to use as regex for report Config Id
    ${reportConfigId_str}=   Catenate    SEPARATOR=${empty}    reportConfigId\\s${report_id},(?:.|\\n)*?eventId\\sevent${meas_event}\\s:\\s\\n\\n
    ...    \\s+{\\n\\n\\s+a1-Threshold\\s${meas_config}\\s:\\s${thresh},(?:.|\\n)*?hysteresis\\s${hyst},\\n\\n\\s+timeToTrigger\\s${time_to_trig}\\n
    ${reportConfigId}=       Set Variable   ${reportConfigId_str}
    # String to use as regex for measurement add mod id
    ${measIdToAddMod_str}=   Catenate     SEPARATOR=${empty}       measIdToAddModList\\s\\n\\n\\s+{\\n\\n\\s+{\\n\\n\\s+measId\\s${measid},\\n\\n
    ...     \\s+measObjectId\\s${meas_obj_id},\\n\\n\\s+reportConfigId\\s${report_id}\\n\\n\\s+}
    ${measIdToAddMod}=       Set Variable   ${measIdToAddMod_str}
    @{meas_Event_list}=            Create List    ${reportConfigId}   ${measIdToAddMod}
    ${log_dir}=                 Get Testcase Log Directory
    ${log_content}=          Get File       ${log_dir}/Rrc_after_A1_based_scell_addition_UE_${ue_id}.log
    FOR   ${event}    IN    @{meas_Event_list}
        ${event_present}=   Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${event}
        IF      ${event_present} == False    FAIL    Expected measurement params not present in RRC reconfiguration measurement config
    END

Verify whether UEs are Configured with A1 Measurement Event for SCell Addition
    [Arguments]    ${ue_id}   ${carrier_freq}
    Verify Measurement ID Is Configured  event_type=A1  ue_id=${ue_id}  carrier_freq=${carrier_freq}


Send A1 Measurement Report and Verify whether gNB Configures CA and Removes A1 Meas Event at the UE
    [Arguments]   ${ue_id}   ${carrier_freq}
    ${log_dir}=   Get Testcase Log Directory
    ${meas_id}    Get NR Measurement IDs   event_type=A1  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    ${egate_log}  wts_ue.Send Egate Command and verify output
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id}[0] event=A1 srsrp_nr=55 srsrq_nr=55  pass_regexp=rrcReconfigurationComplete
    ${Rrc_after_A1_based_scell_addition}    Set variable    ${log_dir}/Rrc_after_A1_based_scell_addition_UE_${ue_id}.log
    Create File    ${Rrc_after_A1_based_scell_addition}   ${egate_log}
    Verify Measurement ID is absent   event_type=A1  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    util.Verify Sequence in File   ${Rrc_after_A1_based_scell_addition}  @{CA_MSG_SEQ}


Verify whether UEs are Configured with A2 Meas for SCell Release and then send A2 MR and Verify whether gNB Releases SCell
    [Arguments]    ${ue_id}
    ${log_dir}=                 Get Testcase Log Directory
    FOR  ${scell_id}   IN RANGE  1  3
        Verify Measurement ID Is Configured  event_type=A2  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_${scell_id}}
        ${measurement_id}    Get NR Measurement IDs   event_type=A2  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_${scell_id}}
        ${meas_id}=    Evaluate   int(${measurement_id}[0])
        ${egate_log}  wts_ue.Send Egate Command and verify output
        ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=30 scell_rsrq=45
        ...    pass_regexp=rrcReconfigurationComplete
        ${A2_based_scell_release}    Set variable    ${log_dir}/UE-${ue_id}_A2_based_scell_${scell_id}_release.log
        Create File    ${A2_based_scell_release}   ${egate_log}
        Verify the gNB Triggers SCell Release Procedure at the UE   ue_id=${ue_id}  scell=${scell_id}
        IF    ${scell_id} == 1
            Verify Measurement ID is absent  event_type=A1  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_4}
        END
        Verify Measurement ID is absent  event_type=A2  ue_id=${ue_id}  carrier_freq=${CARRIER_FREQ_${scell_id}}
    END


Stop Data Traffic and Deregister the UE
    [Documentation]    Thie keyword stops both DL and UL data traffic and de-register the UE from the network
    [Arguments]    ${ue_id}
    Stop data traffic in egate  ue_id=${ue_id}  direction=dl
    Stop data traffic in egate  ue_id=${ue_id}  direction=ul
    UE Deregister  ue_id=${ue_id}  ue_deregister_type=switch_off


Verify the gNB Triggers SCell Release Procedure at the UE
    [Documentation]    This keyword can be used to verify the Scell release procedure. Only that SCell for UE sends A2 MR will be released.
    [Arguments]    ${ue_id}   ${scell}
    ${log_dir}=                 Get Testcase Log Directory
    ${pattern_scell1}=          Set Variable  sCellToReleaseList\\s\\n\\s+{\\n\\s+1\\n\\s+
    ${pattern_scell2}=          Set Variable  sCellToReleaseList\\s\\n\\s+{\\n\\s+2\\n\\s+
    ${log_content}=    Get File    ${log_dir}/UE-${ue_id}_A2_based_scell_${scell}_release.log
    ${scell1_release}=          Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${pattern_scell1}
    ${scell2_release}=          Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${pattern_scell2}
    IF    ${scell} == 1 and ${scell1_release} and not ${scell2_release}
    ...    Log      The gNB Released SCell-${scell} at UE-${ue_id} via RRC Reconfiguration message.
    ...    ELSE IF    ${scell} == 2 and not ${scell1_release} and ${scell2_release}
    ...    Log      The gNB Released SCell-${scell} at UE-${ue_id} via RRC Reconfiguration message.
    ...    ELSE     Fail   The gNB does not trigger SCell-${scell} release procedure at UE-${ue_id}!

Send A1 MR For Scell Addition And Verify Whether GNB Configures CA And Deconfigures A4 Measurement At The UE
    [Arguments]    ${carrier_freq}    ${meas_id}=2    ${pass_regexp}=rrcReconfigurationComplete
    ...    ${srsrp_nr}=55    ${srsrq_nr}=55
    ${log_dir}=                 Get Testcase Log Directory
    FOR   ${ue_id}    ${index}   IN   &{UE_IDs_to_index_mapping}
        ${egate_log}  wts_ue.Send Egate Command And Verify Output
        ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
        ...    pass_regexp=${pass_regexp}
        ${Rrc_after_A1_based_scell_addition}    Set Variable    ${log_dir}/Rrc_after_A1_based_scell_addition_UE_${ue_id}.log
        OperatingSystem.Create File    ${Rrc_after_A1_based_scell_addition}   ${egate_log}
        Verify Measurement ID Is Absent   event_type=A4  ue_id=${ue_id}  carrier_freq=${carrier_freq}
        util.Verify Sequence In File   ${Rrc_after_A1_based_scell_addition}  @{CA_MSG_SEQ}
    END

Send A1 MR For Scell Addition And Verify Whether A1 And A4 Measurements Are Still Configured At The UE
    [Arguments]    ${carrier_freq_1}    ${carrier_freq_2}    ${meas_id}=2    ${pass_regexp}=rrcReconfigurationComplete
    ...    ${srsrp_nr}=55    ${srsrq_nr}=55
    ${log_dir}=                 Get Testcase Log Directory
    FOR   ${ue_id}    ${index}   IN   &{UE_IDs_to_index_mapping}
        ${egate_log}  wts_ue.Send Egate Command And Verify Output
        ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
        ...    pass_regexp=${pass_regexp}
        ${Rrc_after_A1_based_scell_addition}    Set variable    ${log_dir}/Rrc_after_A1_based_scell_addition_UE_${ue_id}.log
        OperatingSystem.Create File    ${Rrc_after_A1_based_scell_addition}   ${egate_log}
        Verify Measurement ID Is Configured    event_type=A1  ue_id=${ue_id}  carrier_freq=${carrier_freq_1}
        Verify Measurement ID Is Configured    event_type=A4  ue_id=${ue_id}  carrier_freq=${carrier_freq_2}
        util.Verify Sequence In File   ${Rrc_after_A1_based_scell_addition}  @{CA_MSG_SEQ}
    END

Send A1 MR for scell addition and Verify whether A1 Measurement is still configured at the UE
    [Arguments]    ${carrier_freq}    ${meas_id}=2    ${pass_regexp}=rrcReconfigurationComplete
    ...    ${srsrp_nr}=55    ${srsrq_nr}=55
    ${log_dir}=                 Get Testcase Log Directory
    FOR   ${ue_id}    ${index}   IN   &{UE_IDs_to_index_mapping}
        ${egate_log}  wts_ue.Send Egate Command And Verify Output
        ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
        ...    pass_regexp=${pass_regexp}
        ${Rrc_after_A1_based_scell_addition}    Set variable    ${log_dir}/Rrc_after_A1_based_scell_addition_UE_${ue_id}.log
        OperatingSystem.Create File    ${Rrc_after_A1_based_scell_addition}   ${egate_log}
        Verify Measurement ID Is Configured    event_type=A1  ue_id=${ue_id}  carrier_freq=${carrier_freq}
        util.Verify Sequence In File   ${Rrc_after_A1_based_scell_addition}  @{CA_MSG_SEQ}
    END

Verify Whether UEs Are Configured With A4 Measurement For SCell Addition
    [Arguments]    ${carrier_freq}
    FOR   ${ue_id}    ${index}   IN   &{UE_IDs_to_index_mapping}
        Verify Measurement ID Is Configured  event_type=A4  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    END

Verify Whether gNB Deconfigures A4 Measurement At The UE
    [Arguments]    ${carrier_freq}
    FOR   ${ue_id}    ${index}   IN   &{UE_IDs_to_index_mapping}
        Verify Measurement ID Is Absent  event_type=A4  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    END

Perform CB013142-E Test Steps In Loop
    FOR    ${loop_ctr}    IN RANGE    1    ${KPI_LOOP_COUNT}+1    1
        Register And Establish PDU Session Multiple UEs For E Subfeature
        Initiate Both Uplink And Downlink Data Traffic On UEs E Subfeature   dl_data=20  ul_data=10
        Send A1 MR For SCell Addition And Verify Whether GNB Configures CA And Deconfigures A1 Measurement At The UE
        ...    carrier_freq=${CARRIER_FREQ_1}
        Send A2 MR And Verify PCELL Switch Happened   carrier_freq=${CARRIER_FREQ_1}
        Update SCell Allocation
        Send A1 MR For SCell Addition And Verify Whether GNB Configures CA And Deconfigures A1 Measurement At The UE
        ...    carrier_freq=${CARRIER_FREQ_4}
        ...    meas_id=5
        ...    ca_msg_verify=${CA_MSG_SEQ_1}
        Send A1 MR And Verify PCELL Switch Happened   meas_id=6
        Stop Data Transfer And Deregister All UEs
        Update SCell Allocation    scell_count=0
        Wait Until The Next Measurement Period Starts
    END
