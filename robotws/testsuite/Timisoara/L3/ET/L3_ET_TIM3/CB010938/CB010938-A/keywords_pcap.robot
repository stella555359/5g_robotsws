*** Settings ***
Documentation    :copyright: Nokia
...              :Moldovan Dan

Library      ../../resources/python/mcshark_stuff.py
Library      ../../resources/python/csvanalyzer.py

Resource    ../../resources/collectors.robot

*** Variables ***

${Test_pcap_dir}    /home/ute/Test10938_A_B

${filter_nrrc}       nr-rrc.ueCapabilityEnquiry_element || nr-rrc.ueCapabilityInformation_element
${filter_ngap}       ngap && nr-rrc.c1 == 0
${pcap_file_path}       ${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
#${preferences}          ${CURDIR}/config/preferencesA_B1_3



*** Keywords ***
#####  A_B1 ####
Check NR RRC

#	Copy trace  tshark     ${filename_f1_e1}
#    Setup wireshark
    Prepare csv file NRRRC    ${filename_f1_e1}
    Check values empty    2   3     ${output_csv_rrc}
    Check values empty   3   3      ${output_csv_rrc}
    Check values non empty   4   9      ${output_csv_rrc}
    Check values non empty   5   9      ${output_csv_rrc}


Check NGAP

#    ${ngap_file}  Run    cd ${OUTPUT_DIR}/${TEST_NAME}/tshark;ls core*
#    Set Test Variable  ${filename_ngap}    ${ngap_file}

#	Copy trace  tshark    ${filename_ngap}
#    Setup wireshark
    Prepare csv file NGAP   ${filename_ngap}
    Check values empty    2   3    ${output_csv_ngap}

    Check values ngap vs nrrrc  3    9





Prepare NR RRC columns A_B1_3
    @{NR_RRC_columns}  Create List

    Append To List  ${NR_RRC_columns}  nr-rrc.ca_BandwidthClassDL_EUTRA
    Append To List  ${NR_RRC_columns}  nr-rrc.ca_BandwidthClassUL_EUTRA
    Append To List  ${NR_RRC_columns}  nr-rrc.bandEUTRA

    Set test variable  @{NR_RRC_columns}



Prepare NGAP columns A_B1_3
    @{NGAP_columns}  Create List

    Append To List  ${NGAP_columns}  nr-rrc.ca_BandwidthClassDL_EUTRA
    Append To List  ${NGAP_columns}  nr-rrc.ca_BandwidthClassUL_EUTRA
    Append To List  ${NGAP_columns}  nr-rrc.bandEUTRA
    Set test variable  @{NGAP_columns}

Check values empty
    [Arguments]       ${j}    ${c}  ${output_csv}

    FOR  ${i}  IN RANGE  0  ${c}


        ${valueline}  get value  ${output_csv}   ${j}  ${i}
        log to console    vv:${valueline}
        Exit For Loop If    '${valueline}' != '${EMPTY}'


    END
    Run Keyword If    ${i} == ${c}-1
        ...    log to console  UE-1 does not contain Infra Info
        ...    ELSE
        ...    Fail     msg=UE-1 contain Infra Info

Check values non empty
    [Arguments]       ${j}    ${c}  ${output_csv}

    FOR  ${i}  IN RANGE  0  ${c}


        ${valueline}  get value  ${output_csv}   ${j}  ${i}
        log to console    vv:${valueline}
        Exit For Loop If    '${valueline}' == '${EMPTY}'
        log to console    valoare i :${i}

    END
    Run Keyword If    ${i} == ${c}-1
        ...    log to console  UE-2 contains Infra Info
        ...    ELSE
        ...    Fail     msg=UE-2 does not contains Infra Info

Check values ngap vs nrrrc
    [Arguments]       ${j}    ${c}

    ${r}=    Evaluate    ${j}+1
    ${n}=    Evaluate    ${j}
    FOR  ${i}  IN RANGE  0  ${c}


        ${value_rrc}  get value  ${output_csv_rrc}   ${r}  ${i}
        ${value_ngap}  get value  ${output_csv_ngap}   ${n}  ${i}
        log to console    rrc:${value_rrc}
        log to console    ngap:${value_ngap}

          Run Keyword If    ${value_rrc} == ${value_ngap}
        ...    log to console  UE-2 ngap value the with rrc value
        ...    ELSE
        ...    Fail     msg=UE-2 ngap value different from rrc value

    END

#####  A_B2    ####
Check NR RRC A_B2

#	Copy trace  tshark     ${filename_f1_e1}
#    Setup wireshark
    Prepare csv file NRRRC    ${filename_f1_e1}
#    Check values empty    2   3     ${output_csv_rrc}
#    Check values empty   3   3      ${output_csv_rrc}
    Check values non empty   2   9      ${output_csv_rrc}
    Check dummy supported   ${output_csv_rrc}    3    9
    Check dummy4 values   ${output_csv_rrc}    3    10
#    Check values non empty   5   9      ${output_csv_rrc}


Prepare NR RRC columns A_b2
    @{NR_RRC_columns}  Create List

    Append To List  ${NR_RRC_columns}  nr-rrc.ca_BandwidthClassDL_EUTRA
    Append To List  ${NR_RRC_columns}  nr-rrc.ca_BandwidthClassUL_EUTRA
    Append To List  ${NR_RRC_columns}  nr-rrc.bandEUTRA
    Append To List  ${NR_RRC_columns}  nr-rrc.mAC_ParametersCommon.dummy
    Append To List  ${NR_RRC_columns}  nr-rrc.maxSimultaneousResourceSetsPerCC
    Append To List  ${NR_RRC_columns}  nr-rrc.maxConfiguredResourceSetsPerCC
    Append To List  ${NR_RRC_columns}  nr-rrc.maxConfiguredResourceSetsAllCC
    Append To List  ${NR_RRC_columns}  nr-rrc.c1
    Set test variable  @{NR_RRC_columns}


Check NGAP A_B2

    Prepare csv file NGAP   ${filename_ngap}

    Check dummy supported   ${output_csv_ngap}    3    9
    Check dummy4 values   ${output_csv_ngap}    3    10

    #Check UERadioCapabilityInfoIndication
    Check message type   ${output_csv_ngap}    2    25    44

    #Check InitialContextSetupReq
    Check message type   ${output_csv_ngap}    3    25    14
#    Check values ngap vs nrrrc
#    Check values empty    2   3    ${output_csv_ngap}
    Check values ngap vs nrrrc  2    9

Prepare NGAP columns A_B2
    @{NGAP_columns}  Create List

    Append To List  ${NGAP_columns}  nr-rrc.ca_BandwidthClassDL_EUTRA
    Append To List  ${NGAP_columns}  nr-rrc.ca_BandwidthClassUL_EUTRA
    Append To List  ${NGAP_columns}  nr-rrc.bandEUTRA
    Append To List  ${NGAP_columns}  nr-rrc.mAC_ParametersCommon.dummy
    Append To List  ${NGAP_columns}  nr-rrc.maxSimultaneousResourceSetsPerCC
    Append To List  ${NGAP_columns}  nr-rrc.maxConfiguredResourceSetsPerCC
    Append To List  ${NGAP_columns}  nr-rrc.maxConfiguredResourceSetsAllCC
    Append To List  ${NGAP_columns}  ngap.procedureCode
    Set test variable  @{NGAP_columns}

#####  A_B2_1   ####
Check NR RRC A_B2_4

    Prepare csv file NRRRC    ${filename_f1_e1}
    Check message type   ${output_csv_rrc}    2    13    6
    Check message type   ${output_csv_rrc}    4    13    6
    Compare nrrrc infra info values    2    9    ${output_csv_rrc}

    Check dummy supported   ${output_csv_rrc}    3    9
    Check dummy4 empty values   ${output_csv_rrc}    3    10

Check NGAP A_B2_4

    Prepare csv file NGAP   ${filename_ngap}

    #Check 2 x UERadioCapabilityInfoIndication
    Check message type   ${output_csv_ngap}    2    22    44
    Check message type   ${output_csv_ngap}    4    22    44

    Check dummy supported   ${output_csv_ngap}    3    9
    Check dummy4 empty values   ${output_csv_ngap}    3    10

#####  A_B4_1    ####
Check NR RRC A_B4_1
#    #1
    Prepare csv file NRRRC    ${filename_f1_e1}
    Check message type   ${output_csv_rrc}    2    13    6
    Check message type   ${output_csv_rrc}    4    13    6
    Check message type   ${output_csv_rrc}    6    7    6
    Check nrrrc infra info correct values    ${output_csv_rrc}    2
    Check nrrrc infra info correct values    ${output_csv_rrc}    4


#    #2
    Check message type   ${output_csv_rrc}    3    19    9
    Check message type   ${output_csv_rrc}    5    19    9
    Check message type   ${output_csv_rrc}    7    16    9

    Check values empty    3   3     ${output_csv_rrc}
    Check values empty    5   3     ${output_csv_rrc}

    Check dummy supported   ${output_csv_rrc}    3    3
    Check dummy supported   ${output_csv_rrc}    5    3
    Check dummy supported   ${output_csv_rrc}    7    3
    Check dummy4 values   ${output_csv_rrc}    3    4
    Check dummy4 values   ${output_csv_rrc}    5    4

Check NGAP A_B4_1

    Prepare csv file NGAP   ${filename_ngap}

    #Check 3 x UERadioCapabilityInfoIndication
    Check message type   ${output_csv_ngap}    2    19    44
    Check message type   ${output_csv_ngap}    3    19    44
    Check message type   ${output_csv_ngap}    5    16    44

    Check dummy supported   ${output_csv_ngap}    2    3
    Check dummy supported   ${output_csv_ngap}    3    3
    Check dummy4 empty values   ${output_csv_ngap}    5    4

    #Check 1 x Initial Context Setup Request
    Check message type   ${output_csv_ngap}    4    19    14
    Check dummy supported   ${output_csv_ngap}    4    3
    Check dummy4 values   ${output_csv_ngap}    4    4

    ${lenght}  get csv line len  ${output_csv_ngap}
     log to console    NUMBER OF MESSAGES:${lenght}
     Should be true    ${lenght}    5

  #####  A_B8    ####
Check NR RRC A_B8
#    #1
    Prepare csv file NRRRC    ${filename_f1_e1}
    Check message type   ${output_csv_rrc}    2    13    6
    Check message type   ${output_csv_rrc}    4    13    6

    Check nrrrc infra info correct values    ${output_csv_rrc}    2
    Check nrrrc infra info correct values    ${output_csv_rrc}    4


#    #2
    Check message type   ${output_csv_rrc}    3    19    9
    Check message type   ${output_csv_rrc}    5    19    9

    Check values empty    3   3     ${output_csv_rrc}
    Check values empty    5   3     ${output_csv_rrc}

    Check dummy supported   ${output_csv_rrc}    3    3
    Check dummy supported   ${output_csv_rrc}    5    3

    Check dummy4 values   ${output_csv_rrc}    3    4
    Check dummy4 values different   ${output_csv_rrc}    5    4

Check NGAP A_B8

    Prepare csv file NGAP   ${filename_ngap}

    #Check 2 x UERadioCapabilityInfoIndication
    Check message type   ${output_csv_ngap}    2    19    44
    Check message type   ${output_csv_ngap}    3    19    44

    Check dummy supported   ${output_csv_ngap}    2    3
    Check dummy supported   ${output_csv_ngap}    3    3

    #Dummy4 different values

    Check dummy4 values   ${output_csv_ngap}    2    4
    Check dummy4 values different   ${output_csv_ngap}    3    4

    #UERadioCapability missing
    ${lenght}  get csv line len  ${output_csv_ngap}
     log to console    NUMBER OF MESSAGES:${lenght}
     Should be true    ${lenght}    3
############### Common #############

Copy trace
    [Arguments]       ${pcap_logs_dir}    ${filename}
    log to console  Copy trace
    ${outdir}    Run  mkdir -p ${Test_pcap_dir}
    Should Not Contain  ${outdir}   cannot create directory

    Run  cp ${OUTPUT_DIR}/${TEST_NAME}/${pcap_logs_dir}/${filename} ${Test_pcap_dir}

    Run  ls ${Test_pcap_dir}

Setup wireshark
    [Arguments]       ${preferences}
    Run  chmod 777 /home/ute/.config/wireshark/preferences
    ${output1}  Run  cp -f ${preferences} /home/ute/.config/wireshark/preferences
    Should Not Contain  ${output1}  No such file or directory

Prepare csv file NRRRC
    [Arguments]       ${filename}
#    Prepare NR RRC columns
    Set Test Variable    ${filename_path}    ${Test_pcap_dir}/${filename}

    Convert BIP logs pcap to csv
    ...  pcap_path=${filename_path}
    ...  filter=${filter_nrrc}
    ...  dir_path=${Test_pcap_dir}
    ...  columns=@{NR_RRC_columns}
    ...  csv_log_name=NR_RRC_columns.csv

    Set Test Variable  ${output_csv_rrc}  ${Test_pcap_dir}/NR_RRC_columns.csv

Prepare csv file NGAP
    [Arguments]       ${filename}
#    Prepare NGAP columns
    Set Test Variable    ${filename_path}    ${Test_pcap_dir}/${filename}

    Convert BIP logs pcap to csv
    ...  pcap_path=${filename_path}
    ...  filter=${filter_ngap}
    ...  dir_path=${Test_pcap_dir}
    ...  columns=@{NGAP_columns}
    ...  csv_log_name=NGAP_columns.csv

    Set Test Variable  ${output_csv_ngap}  ${Test_pcap_dir}/NGAP_columns.csv

Check message type
    [Arguments]        ${output_csv}    ${line}    ${column}    ${type}

    ${valueline}  get value  ${output_csv}   ${line}  ${column}
     log to console    vv:${valueline}
     Run Keyword If    ${valueline} == ${type}
        ...    log to console  msg ok :${type}
        ...    ELSE
        ...    Fail     msg= Msg not match!

Check dummy supported
    [Arguments]        ${output_csv}    ${line}    ${column}
    ${valueline}  get value  ${output_csv}   ${line}  ${column}
     log to console    vv:${valueline}
     Run Keyword If    ${valueline} == 0
        ...    log to console  dummy=supported
        ...    ELSE
        ...    Fail     msg= dummy=supported missing
Compare nrrrc infra info values
       [Arguments]       ${j}    ${c}  ${output_csv}

    ${n}=    Evaluate    ${j}+2

    FOR  ${i}  IN RANGE  0  ${c}


        ${valueline}  get value  ${output_csv}   ${j}  ${i}
        ${valueline_next}  get value  ${output_csv}   ${n}  ${i}
        log to console    vv:${valueline}
        log to console    vv:${valueline_next}
        Exit For Loop If    '${valueline}' != '${valueline_next}'
        log to console    valoare i :${i}

    END
    Run Keyword If    ${i} == ${c}-1
        ...    log to console  UE-1,2 contains the same Infra Info
        ...    ELSE
        ...    Fail     msg=UE-1,2 does not contains the sameInfra Info

Check nrrrc infra info correct values
    [Arguments]       ${output_csv}    ${line}
    Value line    ${output_csv}    ${line}   0    0
    Value line    ${output_csv}    ${line}   1    0
    Value line    ${output_csv}    ${line}   2    0
    Value line    ${output_csv}    ${line}   3    3
    Value line    ${output_csv}    ${line}   4    4
    Value line    ${output_csv}    ${line}   5    3
#    Value line    ${output_csv}    ${line}   4    5
#    Value line    ${output_csv}    ${line}   5    5
    Value line    ${output_csv}    ${line}   6    200
    Value line    ${output_csv}    ${line}   7    201
    Value line    ${output_csv}    ${line}   8    202

Value line
    [Arguments]    ${output_csv}     ${line}    ${c}    ${v}
    ${valueline}  get value  ${output_csv}   ${line}  ${c}

        Run Keyword If    ${valueline} == ${v}
        ...    log to console  UE correct Infra Info
        ...    ELSE
        ...    Fail     msg=UE incorrect Infra Info

Check dummy4 values
    [Arguments]        ${output_csv}    ${line}    ${c}

    ${c2}=    Evaluate    ${c}+5
    ${c3}=    Evaluate    ${c}+10
    ${first}  get value  ${output_csv}   ${line}  ${c}
    ${second}  get value  ${output_csv}   ${line}  ${c2}
    ${third}  get value  ${output_csv}   ${line}  ${c3}
    log to console    dummy4:${first},${second},${third}
    should be equal    ${first}   5     msg=dummy4 value ok,
    should be equal    ${second}  1     msg=dummy4 value ok,
    should be equal    ${third}   1    msg=dummy4 value ok

Check dummy4 values different
    [Arguments]        ${output_csv}    ${line}    ${c}

    ${c2}=    Evaluate    ${c}+5
    ${c3}=    Evaluate    ${c}+10
    ${first}  get value  ${output_csv}   ${line}  ${c}
    ${second}  get value  ${output_csv}   ${line}  ${c2}
    ${third}  get value  ${output_csv}   ${line}  ${c3}
    log to console    dummy4:${first},${second},${third}
    should be equal    ${first}   5     msg=dummy4 value ok,
    should be equal    ${second}  3     msg=dummy4 value ok,
    should be equal    ${third}   3    msg=dummy4 value ok

Check dummy4 empty values
    [Arguments]        ${output_csv}    ${line}    ${c}
    ${c2}=    Evaluate    ${c}+4
    ${c3}=    Evaluate    ${c}+8
    ${first}  get value  ${output_csv}   ${line}  ${c}
    ${second}  get value  ${output_csv}   ${line}  ${c2}
    ${third}  get value  ${output_csv}   ${line}  ${c3}
    log to console    dummy4:${first},${second},${third}
    should be equal    ${first}   2     msg=dummy4 value ok,
    should be equal    ${second}  16     msg=dummy4 value ok,
    should be equal    ${third}   32    msg=dummy4 value ok



