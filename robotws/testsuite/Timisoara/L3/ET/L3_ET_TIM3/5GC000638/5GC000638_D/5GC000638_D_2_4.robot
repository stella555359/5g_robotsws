*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    PY36    CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Ilona Kondel, Anna Roskosz
...              :contact: ilona.kondel@nokia.com, anna.roskosz@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_pm_counters
Library      ta5g_cell_operations
Library      638_D_Keywords.py

Suite Setup    Run Keywords    Reach Onair And Collect Logs
    ...                        lua_cfg=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...                        output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...        AND             Set Counter Collecting Interval To Five Minutes

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${AMF_CONFIG_UPDATE_GUAMI_LIST_2}=    ${NGAP_AMF_CONFIGURATION_UPDATE} && ngap.ServedGUAMIList == 2
${AMF_CONFIGURATION_UPDATE_FAILURE}=    ngap.AMFConfigurationUpdateFailure_element
${AMF_CONFIG_UPDATE_PLMN_LIST_2}=    ${NGAP_AMF_CONFIGURATION_UPDATE} && ngap.PLMNSupportList == 2
${NUBMER_OF_RAN_CONF_MESSAGES_SENT}=    6
${TIME_OF_SENDING_RAN_CONF_UPD_MESSAGES}=  5
${ngSetupRespTmr}=    1

*** Test Cases ***
5GC000638_D_TC2_AMF_Configuration_Update_Failure
    [Documentation]    This test case describes AMF Configuration Update Failure
    ...                5G_RAN_USR_RRM_1244
    ...                Test case checks:
    ...                - if counter NG_CU_AMF_CONFIG_UPD_FAIL_SENT is incremented properly
    ...                author:    Anna Roskosz
    ...                contact:   anna.roskosz@nokia.com

    Invoke AMF Configuration Update Failure By GUAMI Update
    Verify Ngap Messages       packet_filter=${AMF_CONFIG_UPDATE_GUAMI_LIST_2}
    Verify Ngap Messages       packet_filter=${AMF_CONFIGURATION_UPDATE_FAILURE}
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55119C00025     +1   NG_CU_AMF_CONFIG_UPD_FAIL_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}

    [Teardown]    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5G000638_D_TC4_RAN_Configuration_Update_Failure
    [Documentation]    This test case describes RAN Configuration Update Failure
    ...                5G_RAN_USR_RRM_1245
    ...                Test case checks:
    ...                - if time of sending Ran Configuration Update messages is correct
    ...                - if counter NG_CU_RAN_CONFIG_UPD_NO_RSP is incremented properly
    ...                author:    Ilona Kondel
    ...                contact:   ilona.kondel@@nokia.com

    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1   parameter=ngSetupRespTmr     value=${ngSetupRespTmr}
    Ignore Ran Conf Update By AMF
    Lock Single Cell    cell_id=1
    Lock Single Cell    cell_id=2
    Unlock Single Cell    cell_id=1    timeout=50
    sleep    ${TIME_OF_SENDING_RAN_CONF_UPD_MESSAGES}     Waiting for Ran_Conf_Update
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55119C00024     +${NUBMER_OF_RAN_CONF_MESSAGES_SENT}   NG_CU_RAN_CONFIG_UPD_NO_RSP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}
    Verify Ngap Messages       packet_filter=${NGAP_RAN_CONFIGURATION_UPDATE_ACKNOWLEDGE}    number_of_messages=0
    Verify Ngap Messages       packet_filter=${NGAP_RAN_CONFIGURATION_UPDATE}     number_of_messages=${NUBMER_OF_RAN_CONF_MESSAGES_SENT}
    Verify Timestamps Related NG Setup Resp Tmr

    [Teardown]    Run Keywords    Unlock Single Cell    cell_id=2    timeout=50
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Invoke AMF Configuration Update Failure By GUAMI Update
    Execute Egate Command    cmd=amf_config_update id=1 amfi=1:1:1,1:2:2

Ignore Ran Conf Update By AMF
    Execute Egate Command    cmd=amf_ran_config_update_param id=1 action=ignore ntimes=indefinite

Verify Timestamps Related NG Setup Resp Tmr
    ${list_of_timestamps}=   Get List of Timestamps From Tshark Messages   packet_filter=${NGAP_RAN_CONFIGURATION_UPDATE} && ngap.protocolIEs == 1
    ...                                                                     output_pdml_filepath=${OUTPUT_DIR}/converted_pcap.pdml
    Check If All Time Differences Are Equal NG Setup Resp Tmr    times_table=${list_of_timestamps}    ng_setup_resp_tmr=${ngSetupRespTmr}
