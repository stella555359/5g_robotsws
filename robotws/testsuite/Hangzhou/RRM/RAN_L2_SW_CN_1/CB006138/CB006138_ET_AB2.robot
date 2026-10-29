*** Settings ***
Documentation    ...
#Suite Setup      Log To Console    Start cases ABB2003, ABB3001.
#Test Teardown    Run Keywords    Common Test Teardown
#...              AND    Teardown All Connections
#...              AND    Teardown All Aliases For Wts
#Force Tags       CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    FR1    Owner_JSHEN    SBTS00    SBTS23R1    SBTS22R4
#...              RAN_5G    RAN_5G_TDD
#Resource         ./CB006138_Resource.robot
#Variables        ./CB006138_ET.yaml
#
#*** Variables ***
#${FULL_FILE}         basic_2T4F_SCFC.xml
#${IPHY_2T4F_FILE}    ${CURDIR}/Resource/wts/iphy_2T4F.xml
#${LOCAL_WTS_DIR}     ${CURDIR}/Resource/wts
#${WTS_CFG}           basic_2T4F.cfg
#${WTS_AP_XML}        basic_2T4F.xml
#${SCF_PATH}          ${CURDIR}/Resource/Config
#
#*** Test Cases ***
#CB006138_ET_ABB2003_Verify_A1_MR_Based_Scell_Should_Be_Released_Due_To_A2_Measurement_Based_Scell_Release_Is_Enabled
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${FULL_FILE}    iphy_file=${IPHY_2T4F_FILE}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    ...    AND    Delta Commission With SCF File    ${ABB2003['DELTA_FILE']}
#    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ${UE_ID_3}
#    Trigger A1 Scell Addition    ${UE_ID_3}    ${ABB2003['SRSRP_NR']}    ${ABB2003['PHYCELL_ID_PCELL']}
#    Check Scells Are Added    physCellId 52    physCellId 50    physCellId 51
#    Trigger A2 Scell Release    ${UE_ID_3}    ${ABB2003['SCELL_ID']}    ${ABB2003['SCELL_RSRP']}    ${ABB2003['PHYCELL_ID_SCELL']}
#    Check Scell1 Is Released
#
#CB006138_ET_ABB3001_Verify_A1_MR_Based_SCell_Addition_And_RLQ_Based_SCell_Deactivation_With_BF_Enabled_And_Buffer_Based_Scell_Activation
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${FULL_FILE}    iphy_file=${IPHY_2T4F_FILE}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    ...    AND    Delta Commission With SCF File    ${ABB3001['DELTA_FILE']}
#    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ${UE_ID_3}
#    Trigger A1 Scell Addition    ${UE_ID_3}    ${ABB3001['SRSRP_NR']}    ${ABB3001['PHYCELL_ID_PCELL']}
#    SA Start DL Traffic Internal    ${UE_ID_3}    ${PDU_ID}    175    1
#    SA Start DL Traffic Internal    ${UE_ID_3}    ${PDU_ID}    175    2
#    SA Start UL Traffic Internal    ${UE_ID_3}    ${PDU_ID}    10    ${TRF_ID}
#    Verify Scells Are Activation    2
#    Check Scell1 Tput    ${UE_ID_3}    dl    scell    1
#    Moving UE To SCell Bad Coverage Area    ${UE_ID_3}
#    Get And Check PM Counter After SCELL Deactivation
#	Check Scell Active Status    1    deactivated    pass
#
#*** Keywords ***
#Moving UE To SCell Bad Coverage Area
#    [Arguments]    ${ue_id}
#    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id=1 target_mcs=5 num_dl_pkts=10000
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id\=${ue_id} scell=1 testmode=bler action=activate profile_id=1
#    Sleep    30s    reason=wait DL traffic is stable
#
#Check Scell1 Tput
#    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
#    ${scell1_tput_result}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
#    ${scell1_tput}    Set Variable    ${scell1_tput_result}
#    Should Be True    "${scell1_tput}">"0"
#
#Get And Check PM Counter After SCELL Deactivation
#    [Documentation]    scell throughput pm counter: M55310C01006
#    #<p name="reportingIntervalPm">5min</p>
#    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
#    Log To Console    to reach next pm counter update time, need to wait ${time}...
#    Sleep    ${time}    wait for pm counter file updated.
#    Sleep    320s    wait next pm counter file generated stable.
#    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
#    ${pcell_dl_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C01006    cell_id=3
#    Should Be True    "${pcell_dl_tp}">"0"
#	${scell_2_dl_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C01006    cell_id=2
#    Should Be True    "${scell_2_dl_tp}">"0"
#	${scell_1_dl_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55310C01006    cell_id=1
#    Should Be True    "${scell_1_dl_tp}"=="0"
#
