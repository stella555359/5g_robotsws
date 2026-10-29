*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SKIP_PARAM_RELATION_ERRORS}    ${False}    # Should relation errors be skipped (True, False)
${TestDataPath}    /home/ute/testline_configuration/10_5_UTESRAN1910/testdata/TestDataSet/DeltaCommission/CM__Prevent_Cell_Activation_via_Admin.yaml

*** Keywords ***
CM__Prevent_Cell_Activation_via_Admin
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   - Transfer from WRO1 case:SFE - LTE2442-A - Preventing cell activation
    ...  The main steps performed for the test are:
    ...    CaseSetUp
    ...    DeltaCommission via ADMIN API
    ...    ******************
    ...    History of changes
    ...    ******************
    ...  - 28.04.2021 - Commit to GIT
    ...  - 20.01.2022 - Modified by Kang Lixin  - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...                                         - Update according to status changes in CNI-61110
    ...  - 23.03.2022 - Modified by Kang Lixin  - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...                                         - Update case for switching ute_admin to taf.sbts.oam.coam.admin

    Set Tags    CA-CM    MAINTAINER-I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Case Precondition
    DeltaCommission via ADMIN API

DeltaCommission via ADMIN API
    Log    Excute delta commission using ${TEST_NAME}.yaml    console=True
    ${step_count}    Set Variable    ${0}
    FOR    ${data}    IN    @{TEST_DATA}
        ${step_count}    Set Variable    ${step_count+1}
        Log    Index of data is: ${step_count}    console=True
        Execute DeltaCommission Due To Json File    ${data}    ${SKIP_PARAM_RELATION_ERRORS}
        Check Other Cell Status
        Check LNCEL Status    ${data["admin_check"]}
        Check Parameter Has Expected Value    ${data["param_preventCellActivation"]}
        Check SBTS Site Reset Not Triggered
    END
    Wait Until Keyword Succeeds    5 min    10 sec    coam.Assert    LNCEL    ${CELL_MO}  operationalState=${_Disabled_}


Case SetUp
    Common Test Setup SBTS

Case Precondition
    Check SBTS SMOD RMOD Cells Alarms
    Get LNBTS Obj
    Get Random Cell Object    LNCEL
    ${test_data}    Get Test Data From Json    ${TestDataPath}
    ${count}    Get Length    ${test_data}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${datas}    Get Dictionary Values    ${test_data[${index}]}
    Set Suite Variable    ${TEST_DATA}    ${datas[:-1]}
    Set Suite Variable    ${RECOVER_DATA}    ${datas[-1]}
    Get Cell IDs for All RAT
    Remove Values From List    ${LTE_cell_ids}    ${CELL_MO}

Case TearDown
    Log    CaseTearDown    console=True
    Execute DeltaCommission Due To Json File    ${RECOVER_DATA}    ${SKIP_PARAM_RELATION_ERRORS}
    Run Keyword If Test Failed    Save Infomodel Log    filename=${BTS Files}/IM/${TEST_NAME}.ims2    timeout=600
    Wait Until Keyword Succeeds    5 min    10 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown SBTS    never

Check Other Cell Status
    FOR    ${cel}    IN    @{LTE_cell_ids}
         coam.Assert    LNCEL    ${cel}     ${cells_LTE_expected_state}
    END
    Run Keyword If    ${GSM_cell_ids}       coam.Assert Every    GNCEL    ${cells_GSM_expected_state}
    Run Keyword If    ${WCDMA_cell_ids}     coam.Assert Every    WNCEL    ${cells_WCDMA_expected_state}
    Run Keyword If    ${NR_cell_ids}        coam.Assert Every    NRCEL    ${cells_NR_expected_state}

Check LNCEL Status
    [Arguments]    ${list_query_string}
    FOR    ${q_str}    IN    @{list_query_string}
        coam.Assert    LNCEL   ${CELL_MO}     ${q_str}
    END

Check Parameter Has Expected Value
    [Arguments]    ${value}
    ${BTS_scf_content}=  coam.Get SCF
    ${scf_xml}=    XML.Parse xml    ${BTS_scf_content}
    ${current_result}=    XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="${CELL_CONFIG_ID}"]/p[@name="preventCellActivation"]
    Should Be Equal As Strings    ${value}   ${current_result}

Check SBTS Site Reset Not Triggered
    ${time}    Get Time    epoch
    Save infomodel log    ${BTS Files}/IM/reset_check_${time}.ims2
    Initialize ims2 validator    ${BTS Files}/IM/reset_check_${time}.ims2
    Add expected ims2 event    reset
    Run keyword and expect error    *    Validate ims2

Get Random Cell Object
    [Arguments]    ${cell_type}
    ${id_list}    coam.Get Ids For All    ${cell_type}
    ${cell_mo}    Evaluate    random.choice(${id_list})    random
    Set Global Variable    ${CELL_MO}    ${cell_mo}
    ${cell_id_mapping}    Fetch ID Mapping From Admin For Cells    LTE    ${CELL_MO}    internal
    ${CELL_CONFIG_ID}    Get From Dictionary    ${cell_id_mapping}     configuration
    Set Global Variable    ${CELL_CONFIG_ID}
    ${id}    Fetch From Right    ${CELL_CONFIG_ID}    -
    Set Global Variable    ${CELL_ID}    ${id}
