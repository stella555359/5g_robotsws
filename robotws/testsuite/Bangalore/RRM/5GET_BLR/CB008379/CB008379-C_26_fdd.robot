*** Settings ***
Force Tags      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS22R3    SBTS23R1    CONFIGURED
#...             CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD

Resource         ./CB008379_Resource.robot
Library          ./resources/python/l1b_tag_gnb.py
Resource         ./resources/common/common_setup_teardown.robot
Library          ./resources/python/read_csv.py
Library          ../resources/python/ssh_command.py     WITH NAME       ssh_cmd
Resource         ../resources/robot/common_log_collection.robot

#Suite Setup         Run keywords     Suite setup from scratch
#...                 AND      Change IPHY File Value AP ABIO    AHPF    1931
Suite Setup         Run keywords    Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     sleep    420s
#...                 AND      Change Testline From Fullstack To L1bypass
#...                 AND     add_l1bypass_sic_address_in_gnb     ${GNB_ASIK.ip}      ${port}    ${GNB_ASIK.username}     ${GNB_ASIK.password}
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
#...                 AND     Perform SCF Delta Commissioning with c26_scf.json
#...                 AND     Perform SCF Delta Commissioning with Delta_Conf_8379_C26-SANSA-FDD.json
#...                  AND      Send IPHY XML to AP       ap_iphy=${iphy}
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            akhil.k_p@nokia.com
...             maintainer:        akhil.k_p@nokia.com
...
...             INTRODUCTION:     This feature introduces the support of GBR services for the standardized 5QI values 2, 3, 4, 71, 72, 76
...             as well as operator defined 5QI values in the range [128..254].
...            The gNB takes the GFBR (Guaranteed Flow Bit Rate), signaled via the NG-C interface from the AMF or in case of handover from
...             the related XnAP or NGAP messages, into account for the radio resource management.The maximum accepted guaranteed
...            flow bit rate is operator configurable with maximum limit at 30Mbps for downlink and 30Mbps for uplink.

...             TEST SET NAME:    CB008379-C_26_Verify_SA_FDD_UE_supports_2_different_bandwidth_of_LBWP_and_SBWP_enabled.
...                               This scenario is verify the UE supporting different bandwidth ie LargeBandwidth &  SmallBandWidth
...                                are supported simultaneously & UE are still able to acheive the configured Gbr values

...             TESTING SPLIT:     See CB008379 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008379 CFAM
...             Requirement ID: 5G_RAN_USR_RRM_14716,5G_RAN_USR_RRM_14807,5G_RAN_USR_RRM_14808,CB_FIM_4238

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/c26_scf.xml
${AP_XML}=      ${CURDIR}/config/SCF/c26_iphy.xml
${wts_cfg_file}     ${CURDIR}/config/wts/c26.cfg
${WTS_DIR}          /opt/iphy/latest
${iphy}             ${CURDIR}/config/Conf_8379_C26-FDD-iphy.xml
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${4}

&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50

@{QOS_Prof1}                1       2       3                 4
@{QOS_Prof1_speed_ul}       2       32      amr_wb_18_25      30
@{QOS_Prof1_speed_dl}       2       32      amr_wb_18_25      30
@{QOS_Prof1_unit}           mbps    kbps    rtp_codec         mbps


@{QOS_Prof2}               1      2       3                   6
@{QOS_Prof2_speed_dl}      2      32     amr_wb_18_25          20
@{QOS_Prof2_speed_ul}      2      32     amr_wb_18_25          20
@{QOS_Prof2_unit}          mbps   kbps    rtp_codec           kbps

@{QOS_Prof3}               1
@{QOS_Prof3_speed_ul}      20
@{QOS_Prof3_speed_dl}      20
@{QOS_Prof3_unit}          mbps

@{QOS_Prof4}               1       4       5
@{QOS_Prof4_speed_ul}      2       1       3
@{QOS_Prof4_speed_dl}      2       1       3
@{QOS_Prof4_unit}          mbps    mbps    mbps

@{QOS_Prof5}               1       5           3                   6
@{QOS_Prof5_speed_ul}      2       1           32                  amr_wb_18_25
@{QOS_Prof5_speed_dl}      2       1           32                  amr_wb_18_25
@{QOS_Prof5_unit}          mbps    mbps        kbps                rtp_codec

@{QOS_Prof6}               1       13          14      15
@{QOS_Prof6_speed_ul}      2       1           1       1
@{QOS_Prof6_speed_dl}      2       1           1       1
@{QOS_Prof6_unit}          mbps    kbps        kbps    kbps

@{QOS_Prof7}               1       13          14      15           2           3               4
@{QOS_Prof7_speed_ul}      2       1           1       1           32           amr_wb_18_25    500
@{QOS_Prof7_speed_dl}      2       1           1       1           32           amr_wb_18_25    500
@{QOS_Prof7_unit}          mbps    kbps        kbps    kbps        kbps         rtp_codec       kbps

@{QOS_Prof8}               1       13          14      15       5
@{QOS_Prof8_speed_ul}      2       1           1       1        1
@{QOS_Prof8_speed_dl}      2       1           1       1        1
@{QOS_Prof8_unit}          mbps    kbps        kbps    kbps     mbps
*** Test Cases ***
[1]CB008379-C_26_Verify_SA_FDD_UE_supports_2_different_bandwidth_of_LBWP_and_SBWP_enabled
#    [Tags]     QC_169041    QC_172083    QC_201807      QCD_MN_RAN    QCP_RAN_ET
    ${TTI_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${TTI_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...

    set qos profiles for the test case

    ${Rnti_list}     create list
    set suite variable      ${Rnti_list}
    Attach ue and verify bwp configured     1     28875   #small bwp ue
    Attach ue and verify bwp configured     2     28875   #small bwp ue
    Attach ue and verify bwp configured     3     32174   #large bwp ue
    Attach ue and verify bwp configured     4     32174   #large bwp ue

    ${duration}      Set Variable    20
    ${trf_id}      Set Variable    ${1}


    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${duration}s
    ${nongbr_tp_read}=     Verify data transfer and get tp      ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}
    ...     ${qos_profile_unit}  ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}

    ${trf_id}      Set Variable    ${2}
    Reset Bearer Stats     ${st_ue_id}    ${en_ue_id}
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}

    sleep   ${duration}s
    ${gbr_nongbr_tp_read}=     Verify data transfer and get tp      ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}
    ...     ${qos_profile_unit}  ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}

    utility.compare_tp  ${wts_cfg_file}     ${st_ue_id}     ${nongbr_tp_read}      ${gbr_nongbr_tp_read}    ${qos_profile}
    ...     ${qos_profile_speed_ul}    ${qos_profile_speed_dl}      ${vonr_codec_rate}    ${qos_profile_unit}    dirct=both

    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

*** Keywords ***
set qos profiles for the test case
   ${qos_profile}            Create Dictionary   ${1}=${QOS_Prof1}   ${2}=${QOS_Prof1}   ${3}=${QOS_Prof1}
    ...      ${4}=${QOS_Prof1}   ${5}=${QOS_Prof5}   ${6}=${QOS_Prof1}    ${7}=${QOS_Prof2}   ${8}=${QOS_Prof3}
    ...       ${9}=${QOS_Prof4}     ${10}=${QOS_Prof5}

   ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}   ${2}=${QOS_Prof1_speed_ul}   ${3}=${QOS_Prof1_speed_ul}
    ...     ${4}=${QOS_Prof1_speed_ul}   ${5}=${QOS_Prof1_speed_ul}   ${6}=${QOS_Prof6_speed_ul}
    ...     ${7}=${QOS_Prof1_speed_ul}   ${8}=${QOS_Prof1_speed_ul}   ${9}=${QOS_Prof7_speed_ul}     ${10}=${QOS_Prof7_speed_ul}

    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}   ${2}=${QOS_Prof1_speed_dl}   ${3}=${QOS_Prof1_speed_dl}
    ...     ${4}=${QOS_Prof1_speed_dl}   ${5}=${QOS_Prof1_speed_dl}   ${6}=${QOS_Prof6_speed_dl}
    ...     ${7}=${QOS_Prof1_speed_dl}   ${8}=${QOS_Prof1_speed_dl}   ${9}=${QOS_Prof7_speed_dl}     ${10}=${QOS_Prof7_speed_dl}

    ${qos_profile_unit}       Create Dictionary   ${1}=${QOS_Prof1_unit}   ${2}=${QOS_Prof1_unit}     ${3}=${QOS_Prof1_unit}
    ...     ${4}=${QOS_Prof1_unit}   ${5}=${QOS_Prof1_unit}   ${6}=${QOS_Prof6_unit}          ${7}=${QOS_Prof1_unit}
    ...     ${8}=${QOS_Prof1_unit}   ${9}=${QOS_Prof7_unit}     ${10}=${QOS_Prof7_unit}
    set suite variable  ${qos_profile}
    set suite variable  ${qos_profile_speed_ul}
    set suite variable  ${qos_profile_speed_dl}
    set suite variable  ${qos_profile_unit}

Send IPHY XML to AP
    [Arguments]    ${ap_iphy}
    [Documentation]    This keyword is used to put iphy.xml to Airphone.
    ...    | Input Parameters | Man. | Description |
    ...    | ${ap_iphy} | Yes | iphy.xml with absolute path |
    ...
    ...    Examples:
    ...    | Send IPHY XML for AP | ${CURDIR}/config_files/iphy.xml |
    ute_fsmaccess.Setup Wts Fsm Access
    ute_fsmaccess.Put Wts File    ${ap_iphy}    /ffs/run/simmode/new_iphy.xml
    ute_fsmaccess.Teardown Wts Fsm Access

Verify bwp ids from tti trace
    sleep       5s
    Start Ttitrace With Streaming Mode
    sleep       10s
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv        ${TTI_PATH}/ttitrace_streaming/
    Convert Tti To Csv Mode          ${TTI_PATH}/ttitrace_streaming
    set test variable    ${rnti_bwp2)   ${Rnti_list}[:2]
    set test variable    ${rnti_bwp1)   ${Rnti_list}[:-2]
    ${result1}   check_bwpid_per_rnti        ${TTI_PATH}/ttitrace_streaming/output_ul_formated.csv      ${rnti_bwp2)   ${2}
    ${result2}   check_bwpid_per_rnti        ${TTI_PATH}/ttitrace_streaming/output_ul_formated.csv      ${rnti_bwp1)   ${1}
    ${result3}   check_bwpid_per_rnti        ${TTI_PATH}/ttitrace_streaming/output_dl_formated.csv      ${rnti_bwp2)   ${2}
    ${result4}   check_bwpid_per_rnti        ${TTI_PATH}/ttitrace_streaming/output_dl_formated.csv      ${rnti_bwp1)   ${1}
    ${result1}=  convert to string   ${result1}
    ${result2}=  convert to string   ${result2}
    ${result3}=  convert to string   ${result3}
    ${result4}=  convert to string   ${result4}
    should be equal     ${result1}  pass
    should be equal     ${result2}  pass
    should be equal     ${result3}  pass
    should be equal     ${result4}  pass


Change IPHY File Value AP ABIO
    [Arguments]    ${RU_TYPE}   ${GSCN}
#    ${OUTPUT_DIR}   Set variable    /home/ute/robotws
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}

    ${targetbd_fn}=    Run      ssh toor4nsn@192.168.255.129 ls -ltr /ffs/run/|grep TargetBD.*xml$|awk '{ print $9 }'
    Run     scp toor4nsn@192.168.255.129:/ffs/run/${targetbd_fn} ${OUTPUT_DIR}
    Should Exist    ${OUTPUT_DIR}/${targetbd_fn}
    ${target_bd_path}    Set Variable    ${OUTPUT_DIR}/${targetbd_fn}

    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "card"|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
    Run    ${c1}${c2}

    ${c1}    Set Variable    grep -m 1 ${RU_TYPE}|awk -F resourceSWVersion= '{print $2}'|sed 's/"//g;s/>//g'
    ${new_version}    Run   cat ${target_bd_path}|${c1}
    log to console     ${new_version}
    ${c1}    Set Variable    cat ${file_path}|grep -m 1 '<version>'|awk -F '<version>' '{print $2}'|awk -F '</version>' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${new_version}/' ${file_path}
    Run     ${c1}${c2}

    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "GSCN"|awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}

    ${x}   ${y}    get_board_type    192.168.200.1   22    toor4nsn    oZPS0POrRieRtu
    Run Keyword if    '${x}'=='ASIL' and '${y}'=='ABIO'
    ...    update_iphy_7145    ${file_path}
    sleep   4s
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  125s
