*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SKIP_PARAM_RELATION_ERRORS}    ${False}    # Should relation errors be skipped (True, False)
#${TestDataPath}    TestDataSet/DeltaCommission/${TEST_NAME}.yaml      # The location of the test data

*** Keywords ***
CM__RF_Diagnostics_via_Admin
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************

    ...   - Transfer from WRO1 case: SFE - LTE1634 - RF diagnostic test
    ...  The main steps performed for the test are:
    ...    CaseSetUp
    ...    DeltaCommission via ADMIN API
    ...    ******************
    ...    History of changes
    ...    ******************
    ...  - 28.04.2021 - Commit to GIT
    ...  - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    Set Tags    CA-CM    OWNER-lixin.kang@nokia-sbell.com    MAINTAINER-lixin.kang@nokia-sbell.com    AUTHOR-bin.7.liu@nokia-sbell.com
    ...    PHASE-CRT    SW-SBTS21B    GROUP_IN_CHARGE-SRAN_PROD_HZ1
    LOG    ${TEST_NAME} start.    console=${True}
    CaseSetUp
    DeltaCommission via ADMIN API

DeltaCommission via ADMIN API
    Log    Excute delta commission using ${TEST_NAME}.yaml    console=True
    ${step_count}    Set Variable    ${0}
    FOR    ${data}    IN    @{TEST_DATA}
        ${step_count}    Set Variable    ${step_count+1}
        Log    Index of data is: ${step_count}    console=True
        Execute DeltaCommission Due To Json File    ${data}    ${SKIP_PARAM_RELATION_ERRORS}
        Check_SBTS_Site_Reset_Not_Triggered
        Check_SBTS_SMOD_RMOD_Cells_Alarms
    END
    Check_Parameter

CaseSetUp
    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Get LNBTS Obj
    ${test_data}    Get Test Data From Json    ${TestDataPath}
    ${count}    Get Length    ${test_data}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${datas}    Get Dictionary Values    ${test_data[${index}]}
    Set Suite Variable    ${TEST_DATA}    ${datas[:-1]}
    Set Suite Variable    ${RECOVER_DATA}    ${datas[-1]}

CaseTearDown
    Log    CaseTearDown    console=True
    Execute DeltaCommission Due To Json File    ${RECOVER_DATA}    ${SKIP_PARAM_RELATION_ERRORS}
    Run Keyword If Test Failed    Save Infomodel Log    filename=${BTS Files}/IM/${TEST_NAME}.ims2    timeout=600
    Wait Until Keyword Succeeds    5 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Common Test Teardown SBTS    never

Check_Parameter
    ${BTS_scf_content}=  coam.Get SCF    export_type=configurationAndRuntimeObjects
    ${scf_xml}=    XML.Parse xml    ${BTS_scf_content}
    ${current_result}=    XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="${MRBTS}/MNL-1/MNLENT-1/TEST-1/RFREQ-222/RFRES-1"]/p[@name="result"]
    Should Be Equal As Strings    success   ${current_result}

Check_SBTS_Site_Reset_Not_Triggered
    ${time}    Get Time    epoch
    Save infomodel log    ${BTS Files}/IM/reset_check_${time}.ims2
    Initialize ims2 validator    ${BTS Files}/IM/reset_check_${time}.ims2
    Add expected ims2 event    reset
    Run keyword and expect error    *    Validate ims2