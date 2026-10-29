*** Settings ***
Documentation
...	author/contact:  jose.suarez@nokia.com
...
...	Keywords defined for test cases to verify Frame Structure and TPut with enabled 5GC002516.
...     for 1 UE on 1CC. UE supports simultaneous HARQ ACK + CSI.
...	It uses some common setup/teardown keywords

Resource          resources/common/common_setup_teardown.robot
Resource          resources/common/common_log_capture.robot
Resource          resources/common/common_ue_command.robot
Resource          5GC002516_Expected_slot_type.robot

*** Variables ***

${SCF_PATH}            ${CURDIR}/config
${UE_ID}               11
${PROFILE_ID}          1
${GNB_ID}              2
${CELL_ID}             1
${BEARER_ID}           2
@{LOG_NAME_LIST}       btslog    snapshot    bip
${COUNT}               0
${LOG_PATH}            ${OUTPUT DIR}

# It defines needed extra r&d flags on gNB side
${RD_PARAM}            0x58000E=0x00020;0x580017=2;0x10041=5

# It defines swconfig file
${SWCONFIG_PATH_FILE}    ${CURDIR}/swconfig.txt


# It defines needed SCF config change on GNB side for each test
${DELTA_FILE_TC5}      ${CURDIR}/TC5_Delta_Conf_5GC002516-TDD_NSA.json
${DELTA_FILE_TC6}      ${CURDIR}/TC6_Delta_Conf_5GC002516-TDD_NSA.json
${DELTA_FILE_TC8}      ${CURDIR}/TC8_Delta_Conf_5GC002516-TDD_NSA.json

# It defines the UE config with enabled simultaneous HARQ ACK + CSI
${UE_NR_CAP_TDD}                  01000000010800040004D100008100000BC00000000000008A8000100000000010010AA8
@{UE_NR_PATT}      ue_nr_capabilities=[0-9a-zA-Z]+
@{UE_NR_VAL}       ue_nr_capabilities=${UE_NR_CAP_TDD}

#It defines slot_type for each test
@{slot_type_TC5}           @{slottype_list_5GC002516_TC5}
@{slot_type_TC6}           @{slottype_list_5GC002516_TC6}
@{slot_type_TC8}           @{slottype_list_5GC002516_TC8}

# It defines the expected DL/UL TPut for each test
${expected_dl_TC5}         70
${expected_ul_TC5}         15
${expected_dl_TC6}         59.5
${expected_ul_TC6}         17.8
${expected_dl_TC8}         56
${expected_ul_TC8}         9.7

*** Keywords ***
5GC002516_Coordination_of_TDD_Deployment
    [Documentation]     This keyword performs UE attach, start DL/UL data and verify the expected TPut
    [Arguments]    ${expected_dl}    ${expected_ul}
    common_ue_command.NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
    common_ue_command.NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    common_ue_command.NSA Verify If Attach Passed
    common_ue_command.NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
    common_ue_command.NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
    ${dl_tp}=    common_ue_command.NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    dl
    log    DL Troughput is ${dl_tp}    console=True
    ${ul_tp}=    common_ue_command.NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    ul
    log    UL Troughput is ${ul_tp}    console=True
    common_ue_command.NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    ${expected_dl}
    common_ue_command.NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    ${expected_ul}
    common_ue_command.NSA LTE Detach    ${UE_ID}



Verify 5GC002516 SYSLOG
    [Documentation]     This keyword performs the verification of actual frame structure extracted
	...                 from GNB_Syslog VS the expected one defined under slot_type.
    [Arguments]    ${slot_type}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    tar -xzvf ${SUITE_LOG_DIRECTORY}/Gnb_syslog.tar.gz --directory ${SUITE_LOG_DIRECTORY}
    ${grep_command}    Catenate    sed -n -r 's#SlotTypeSelectorBase#SlotTypeSelectorBase#g; t found; d; :found s#.*(Slot:)
    ...    +([0-9]+),.*(SLOT_TYPE_.+), k1:.*#\\1\\2 \\3#g; t processed; d; :processed p;'
    ...    ${SUITE_LOG_DIRECTORY}/${output} > ${SUITE_LOG_DIRECTORY}/5GC002516_Result
    ${rc}    ${line}    OperatingSystem.Run And Return Rc And Output    ${grep_command}
    FOR    ${sub}    IN    @{slot_type}
        Log to console    ${sub}
        ${line.strip()}    Evaluate    ${line.strip()}+1
        ${rc}     ${content}    OperatingSystem.Run And Return Rc And Output    sed -n '${line.strip()}p' ${SUITE_LOG_DIRECTORY}/5GC002516_Result
        ${match_result}    Should Match Regexp    ${content}    ${sub}
    END