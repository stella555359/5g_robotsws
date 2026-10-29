*** Settings ***
Documentation      CB012149ET-CA16
Resource           ./CB012149_resource.robot
Resource           ./../CUDU_L2/common_setup_teardown.robot
Library           ./Resources/python_keyword_counter.py
Suite Setup        Common Suite Setup 2
Test Teardown      Common Test Teardown 2    check_tl=False
Suite Teardown     Common Suite Teardown 2
Force Tags         CLOUD_5G_I_BOO_AP_LOO    SBTS00    AP_REG
...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

*** Variables ***
${SCF_PATH}                   ${CURDIR}/Config/SCF
${WTS_DIR}                    /opt/iphy/latest
${WTS_CFG_CA16}               wts_CB012149_CA16.cfg
${LOCAL_WTS_DIR}              ${CURDIR}/Config/WTS/
${SCF_CA16}                   ${SCF_PATH}/CB012149_CA16.xml
${iphy_CA16}                  ${CURDIR}/Config/IPHY/iphy_CA16.xml
${SWCONFIG_CA01}              0x4B000F=1;
${UE_ID}                      1
${1T1F_SCELLS}                ('1', '51', '25')
${1070_0DL_SLOT}              [0, 1, 2, 5, 6, 7, 10, 11, 12, 16, 17]
${1070_0UL_SLOT}              [4, 8, 9, 14, 18, 19]
${FDD_MUTE_SLOT}              [0, 1, 3, 4, 5, 6, 8, 9]
${FDD_UNMUTE_SLOT}            [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB012149ET-CA16_Multi_Ues_call_when_UL_AC_UE_mixed_with_other_Ues
    [Documentation]
    ...    Precondition:
    ...      FDD 20M and pcell TDD with 1070 frame structure.
    ...      with beam=4 and refine beam is enable
    ...      sCellAdditionMethod =1:covBasedA1
    ...      RREL sCellOperationalMode =1(dlAndUl)
    ...      NRBTS/NRCELL-maxNumOfUlCaUeParallelTx=2
    ...      NRBTS/NRCELL/maxNumPuschAllocationPerSlot=16.
    ...      NRBTS/NRCELL/actDlSrsBm=true.
    ...      NRBTS/NRCELL/actUlSrsBm=true
    ...     --NRULCG_PROFILE.maxNumPrbs=48
    ...     --NRBTS/NRCELL.actulcgtype2=true
    ...     --NRBTS/NRCELL/ulConfiguredGrantType2.ulCgPrbStartOffset=0
    ...     --NRBTS/NRCELL/ulConfiguredGrantType2.ulCgMaxNumPrbs=48
    ...     --NRBTS/NRCELL/ulConfiguredGrantType2.ulCgMaxNumUeUl=4
    ...     --NRULCG_PROFILE.grantedPacketSize=800
    ...     --NRULCG_PROFILE.periodicity=ms1

    [Tags]    caseCA16    Manual_Yalsun    TA_Yalsun
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_CA16}
    ...        AND    Suite Setup Update GNB    scf_file=${SCF_CA16}    iphy_file=${iphy_CA16}    swconfig_param=${SWCONFIG_CA01}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
    #Step1: 2 Configured Grant Type 2 UE as background UE, non full buffer data transfer is performed in the UL
    CG UEs Attach And Send Ul Traffic
    Start Ttitrace With Streaming Mode
    #Step2: R15 UL CA capable UE1 and UE2  attach to TDD pcell
    R15 UEs Attach And Send Scell Addition And Send Ul Traffic
    #Step3:4 UEs  perform UE attach at same PRACH slot.
    Perform UE Attach At Same PRACH Slot
    #Step4:perfrom 2 Voice call UEs with 5QI1 data transfer.
    SA 5G Detach    1-14
    Sleep    2s
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
    Sleep    60s
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
    Sleep    60s
    #Checkpoint 1
    Check AllowList In TTI    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv
    Check Slot For FDD    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv     ulFdSchedData.numOfPrb    51    ${FDD_UNMUTE_SLOT}
    #checkpoint 2
    CUDU_L2 Check DTXNACK Rate    1
    CUDU_L2 Check UL DTXCRC Rate    1
    #checkpoint 3
    Sleep    300s
    Get and Check RD Counter After UE detach    ${TEST_LOG_DIRECTORY}/counter    ACC_NUM_UL_CA_TDD_AL
    Get and Check RD Counter After UE detach    ${TEST_LOG_DIRECTORY}/counter    ACC_NUM_UL_CA_TDD_AL_FAIL_SCHD

*** Keywords ***
Perform UE Attach At Same PRACH Slot
    Log To Console   perform UE attach at same PRACH slot
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ue_register id\=5-9    pass_regexp=REGISTRATION COMPLETE|Registration    timeout=1s
    Sleep    2s
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ue_register id\=10-14    pass_regexp=REGISTRATION COMPLETE|Registration    timeout=1s
    Sleep    2s

CG UEs Attach And Send Ul Traffic
    Log To Console    2 Configured Grant Type 2 UE as background UE, non full buffer data transfer is performed in the UL
    FOR    ${ue}    IN RANGE    3    4
        SA Single UE Attach    ${ue}
        SA Start UL Traffic Internal    ue_id=${ue}    pdu_id=1    mbps=2    trf_id=1
    END

R15 UEs Attach And Send Scell Addition And Send Ul Traffic
    Log To Console    R15 UL CA capable UE1 and UE2  attach to TDD pcell
     FOR    ${ue}    IN RANGE    1    2
        SA Single UE Attach    ${ue}
        CB012149_resource.Trigger A1 Scell Addition    ${ue}    1    120
        Sleep    2s
        Get And Check Scell Infos    ${1T1F_SCELLS}
        SA Start UL Traffic Internal    ue_id=${ue}    pdu_id=1    mbps=120    trf_id=1
    END

Realse ALL UEs
     FOR    ${ue}    IN RANGE    1    14
        SA 5G Detach    ${ue}
    END

Get and Check RD Counter After UE detach
    [Arguments]    ${log_id}     ${counter}
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/RD.BTS* ${log_id}
    Sleep    10s    wait counter file generated stable.
    ${ret1}   find_non_zero_acc_num_in_gz_files    ${log_id}    ${counter}
    Should Not Be Empty    ${ret1}
