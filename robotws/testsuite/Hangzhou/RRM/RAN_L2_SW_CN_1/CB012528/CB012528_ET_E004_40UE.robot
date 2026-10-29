*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONF}
...               vendor_change_list=${VENDOR_CHANGE_LIST}
...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
Suite Teardown    Common Suite Teardown
Force Tags        CLOUD_5G_I_MP_AP_LOOO    CRT    RAN_5G    RAN_5G_TDD    Owner_molyang
...               CN1_SG6    CB012528    SBTS00
Resource          ./../CUDU_L2/common_setup_teardown.robot

Documentation
...     CB012528_ET_E004_40UE_Attach_ABIP

*** Variables ***
${SCF_PATH}                ${CURDIR}/Config/
${SWCONF}                  0x58083A=1
${SCF_FILE}                Configuration_scf_ABIP_12F.xml
${IPHY_FILE}               ${CURDIR}/Config/wts/iphy_12cell_ABIP.xml
${LOCAL_WTS_DIR}           ${CURDIR}/Config/wts/
${WTS_CFG}                 12cell40ueprecell.lua
${PDU_ID}                  1
@{EXP_DL_TPUT_LIST_OUT}    1    1    1    0.8
${EXP_UL_TPUT_OUT}         10
&{XML_PARAMS_DICT1}        actDPAOverloadControl=true    actTwoCoresL2DeploymentFddFr1=true
&{VENDOR_CHANGE_DICT1}     list_name=${EMPTY}    ref_value=${EMPTY}    params_dict=${XML_PARAMS_DICT1}
@{VENDOR_CHANGE_LIST}      ${VENDOR_CHANGE_DICT1}
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB012528_ET_E004_40UE_Attach_ABIP
    [Setup]    Run Keywords    Suite Setup Start WTS And Check OnAir
    ...    AND    Common Test Setup
    Cell1 Ue Attach
    Cell3 Ue Attach
    Cell5 Ue Attach
    Cell11 Ue Attach
    Cell1 Ue Start DL UL Traffic
    Cell3 Ue Start DL UL Traffic
    Cell5 Ue Start DL UL Traffic
    Cell11 Ue Start DL UL Traffic
    Check All Ue Tput
    Check Cell1 Each UE Tput
    Check Cell3 Each UE Tput
    Check Cell5 Each UE Tput
    Check Cell11 Each UE Tput
    Capture Convert Format Ttitrace With Streaming Mode    0.5s    log_dir=${test_log_directory}/ttitrace/1
    CUDU L2 Check DTXNACK Rate    log_id=1    expect_rate=0.02
    CUDU L2 Check UL DTXCRC Rate    log_id=1    expect_rate=0.02
    [Teardown]    Run Keywords    Common Test Teardown
    ...    AND    Stop Edaemon Egate

*** Keywords ***
Cell1 Ue Attach
    FOR    ${ue_id}    IN RANGE    1    11
         Single Ue Attach    ${ue_id}
    END

Cell3 Ue Attach
    FOR    ${ue_id}    IN RANGE    81    91
         Single Ue Attach    ${ue_id}
    END

Cell5 Ue Attach
    FOR    ${ue_id}    IN RANGE    161    171
         Single Ue Attach    ${ue_id}
    END

Cell11 Ue Attach
    FOR    ${ue_id}    IN RANGE    401    411
        Single Ue Attach    ${ue_id}
    END

Cell1 Ue Start DL UL Traffic
    FOR    ${ue_id}    IN RANGE    1    11
         SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    30    trf_id=1
         SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    20    trf_id=1
    END
    Sleep    5s

Cell3 Ue Start DL UL Traffic
    FOR    ${ue_id}    IN RANGE    81    91
         SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    30    trf_id=1
         SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    20    trf_id=1
    END
    Sleep    5s

Cell5 Ue Start DL UL Traffic
    FOR    ${ue_id}    IN RANGE    161    171
         SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    30    trf_id=1
         SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    20    trf_id=1
    END
    Sleep    5s

Cell11 Ue Start DL UL Traffic
    FOR    ${ue_id}    IN RANGE    401    411
         SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    30    trf_id=1
         SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    20    trf_id=1
    END
    Sleep    5s

Check All Ue Tput
    FOR    ${id}    IN RANGE    1    3
         ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=1-10 type=pusch,pdsch scell=0-3    pass_regexp=EGATE>
         Sleep    60s    #wait for egate console
         ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=81-90 type=pusch,pdsch scell=0-3    pass_regexp=EGATE>
         Sleep    60s    #wait for egate console
         ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=161-170 type=pusch,pdsch scell=0-3    pass_regexp=EGATE>
         Sleep    60s    #wait for egate console
         ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=401-410 type=pusch,pdsch scell=0-3    pass_regexp=EGATE>
         Sleep    60s    #wait for egate console
    END

Single Ue Attach
    [Arguments]    ${ue_id}    ${pdu_id}=1
    Log To Console    UE${ue_id} Start Attach...
    SA 5G Attach    ue_id=${ue_id}
    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${pdu_id}
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1
    ...    pass_regexp=setup/reestablishment complete    timeout=3minutes

Check Cell1 Each UE Tput
    FOR    ${ue_id}    IN RANGE    1    11
    Check UE DL All Pcell Scell TP On Target For Single UE    ${ue_id}    ${EXP_DL_TPUT_LIST_OUT}    4
    Check CA UE Pcell Scell Cell TPut On Target    ${ue_id}    ul    pcell    0    ${EXP_UL_TPUT_OUT}
    END

Check Cell3 Each UE Tput
    FOR    ${ue_id}    IN RANGE    81    91
    Check UE DL All Pcell Scell TP On Target For Single UE    ${ue_id}    ${EXP_DL_TPUT_LIST_OUT}    4
    Check CA UE Pcell Scell Cell TPut On Target    ${ue_id}    ul    pcell    0    ${EXP_UL_TPUT_OUT}
    END

Check Cell5 Each UE Tput
    FOR    ${ue_id}    IN RANGE    161    171
    Check UE DL All Pcell Scell TP On Target For Single UE    ${ue_id}    ${EXP_DL_TPUT_LIST_OUT}    4
    Check CA UE Pcell Scell Cell TPut On Target    ${ue_id}    ul    pcell    0    ${EXP_UL_TPUT_OUT}
    END

Check Cell11 Each UE Tput
    FOR    ${ue_id}    IN RANGE    401    411
    Check UE DL All Pcell Scell TP On Target For Single UE    ${ue_id}    ${EXP_DL_TPUT_LIST_OUT}    4
    Check CA UE Pcell Scell Cell TPut On Target    ${ue_id}    ul    pcell    0    ${EXP_UL_TPUT_OUT}
    END

