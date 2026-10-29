*** Settings ***

Documentation
...   author: Suhas Rajesh
...   contact suhas.rajesh@nokia.com
...   Description: Test Suite for CB007814

Force Tags      CRT  SBTS24R1    FL00    QCD_MN_RAN   QCP_RAN_ST
...             RAN_5G_TDD__WITH__SBTS00
...             RAN_5G__WITH__SBTS00
...             RAN_5G__WITH__SBTS24R1
...             FT_CB007814

Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog  WITH NAME   btslog
Library    ./testsuite/Bangalore/ORAN/resources/python/Tshark_Validation.py
Library    SSHLibrary
Library    Process
Library    taf.transport.ssh        WITH NAME    ssh
Library        OperatingSystem     WITH NAME    os
Library        String      WITH NAME   str
Library        taf.ue    WITH NAME    ue
Library      testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_uc
Resource       ./testsuite/Bangalore/ORAN/resources/python/Macro/bts/gnb.robot
Resource    ./testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot
Library        ute_ue
Library           OperatingSystem
Library           String
Library           Collections
Library           DateTime
Library    ./testsuite/Bangalore/ORAN/resources/python/Macro/Python/bts/common/bbu.py
Library    ./testsuite/Bangalore/ORAN/resources/python/Macro/Python/bts/common/log.py
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library    ./testsuite/Bangalore/ORAN/resources/python/SysValidation.py

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Variables ***
${CELL_ID}          1
@{LOG_NAME_LIST}    btslog    snapshot
@{capabilities}    Legacy_1   Legacy_2
@{throughput_dl}=   75   75
@{throughput_ul}=   20   20
@{dt_name}=   iperf_dl_test
@{UE_alias}=  UE1   UE2
@{direction_dl}=  dl   dl
@{direction_ul}=  ul   ul
@{duration}=  200s      200s
@{timeout}      180     180
@{tcpcalltype}=    TCP    TCP
@{udpcalltype}=    UDP    UDP
@{deviation_dl}=  20
@{deviation_ul}=  10
${packet_size}=  1400     1400
${tput}=   100Mbits/sec      100Mbits/sec
${ASP_BOARD_TYPE}     ABIO0
${SCF_PATH}         ${CURDIR}/resources/
${DELTA_FILE}       ${CURDIR}/resources/Configuration_scf_MRBTS-990.xml
${scf_file}=        ${DELTA_FILE}
${CONFIG_PATH}      /home/ute/testline_configuration_5G/Bangalore/7_2_UTE5GTLBTS9/ta_ue_config.yaml
${port_val_list}     9
${counter_initial_value_1}      M55301C

*** Variables ***

${LTE_CELL_ID}                                 # ID of DSS LTE cell which will be tested
${PHYS_LTE_CELL_ID}                            # Physical ID of tested LTE cells (needed for syscomdump filters)
${NR_CELL_ID}                                  # ID of DSS NR cell which will be tested
${SYSCOMDUMP_FILTER}      ${NONE}              # Filetr used during collecting syscomdump, e.g. -i any msg_id=='0x761b'. Default value: ${NONE}
${LTE_MSISDN}                                  # number for volte call to dial
${BLANKED_PUCCH}                               # Value for blankedPucch
${NR_EXPECTED_DL_TPUT_MBPS}                    # [Mbit/sec] Value of expected throughput in NR DSS cell and LTE anchor cell
${LTE_EXPECTED_DL_TPUT_MBPS}                   # [Mbit/sec] Value of expected throughput in LTE DSS cell
#modify QC ID during execution as per the path in QC.

*** Test Cases ***
CB010277_Verification of DL data transmission in shared cell-5GC002063
    #[Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
    #[Teardown]    run keywords
    # ...      Set QC_Tag     Test Teardown
    #coam.setup_admin
    #Set Scfc file path
    #Perform Commissioning2
    Step1: Start the NR and LTE call



*** Keywords ***
Perform Commissioning2
    gnb_scf.Perform Full Commissioning On GNB    scf_file=${scfc_file}m
    Sleep    400
    Run Keyword And Continue On Failure      Verify gNB is onAir

Set Scfc file path
     Set Suite Variable    ${scfc_file}    /home/ute/robotws/commissionings/Krakow/7_2_5GBTS9/TRUNK/SCF_256QAM.xml

Test Setup
    btslog.create_btslog_collector
    ...    name=btslog
    ...    log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.set_suite_alias      btslog
    core.start_collectors      names=btslog
    Sleep  10


Test Teardown
    Log to console   --Test teardown--
    interface.Common step trigger
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog         target_dir=/home/ute/results/
    core.teardown_collectors      names=btslog

Step1: Start the NR and LTE call
    ta_uc.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_uc.Detach UE    ue_alias=${UE_alias}     #UE detach step
    Log to console    \nSwitching Aeroplane Mode On/OFF
    sleep      200
    ta_uc.Attach UE    ue_alias=${UE_alias}     #UE attach step
    sleep     60
    ta_uc.start_data_transfer    ${UE_alias}   ${udpcalltype}    direction=${direction_dl}
    sleep    310

    ta_uc.start_data_transfer    ${UE_alias}   ${udpcalltype}    direction=${direction_ul}
    sleep    310

   ${output1}=       Run Keyword and Continue on Failure       ta_uc.calculate_thrughtput        ue_alias=${UE_alias}    direction=${direction_dl}
   ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}
   ${output2}=      Run Keyword and Continue on Failure       ta_uc.calculate_thrughtput        ue_alias=${UE_alias}    direction=${direction_ul}
    ...     thrughtput=${throughput_Ul}    deviation=${deviation_Ul}
    log to console     ${output1['UE_1']['tputvalue']}
    log to console     ${output2['UE_2']['tputvalue']}
    #${result}=    validate_syslog_file_contents
    #${length}=    Get Length    ${result}
    #log    ${result}
    #log    ${length}
    #Should Not Be Empty    ${result}

#   ta_uc.start_data_transfer    ${UE_alias}   ${udpcalltype}    direction=${direction_dl}
#    sleep    310

#    ta_uc.start_data_transfer    ${UE_alias}   ${udpcalltype}    direction=${direction_ul}
#    sleep    310
#   ${output3}=       Run Keyword and Continue on Failure       ta_uc.calculate_thrughtput        ue_alias=${UE_alias}    direction=${direction_dl}
#   ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}
#   ${output4}=      Run Keyword and Continue on Failure       ta_uc.calculate_thrughtput        ue_alias=${UE_alias}    direction=${direction_ul}
#    ...     thrughtput=${throughput_Ul}    deviation=${deviation_Ul}
#    log to console     ${output3['UE_1']['tputvalue']}
    log to console     ${output4['UE_2']['tputvalue']}
    #${result}=    validate_syslog_file_contents
    #${length}=    Get Length    ${result}
    #log    ${result}
    #log    ${length}
    #Should Not Be Empty    ${result}

#    log to console     ${output["UE_1"]["tp
utvalue"]}
#    log to console     ${output["UE_2"]["tputvalue"]}
#    ta_uc.start_data_transfer     ${UE_alias}   ${udpcalltype}    direction=${direction_ul}
#    sleep    310
#    ${output1}=        Run Keyword And Continue On Failure    ta_uc.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
#    ...     thrughtput=${throughput_ul}    deviation=${deviation_ul}
#    log to console     ${output1["UE_1"]["tputvalue"]}
#    log to console     ${output1["UE_2"]["tputvalue"]}
#    #${dl_tput}=       Set Variable     ${output1["result"]["averageDL"]}
#    #log to console     ${dl_tput}
#    #${ul_tput}=       Set Variable     ${output1["result"]["averageUL"]}
#    #log to console     ${ul_tput}


Step4: Wait For CRM Message In Syslog
    Log  \n==== Step 4: Wait For CRM Message In Syslog ====  console=True
    Sleep  60s  Reason=Wait for CRM Message In Syslog
    ${syslog_msg} =  Run Keyword And Continue On Failure  Wait For Message In Syslog File
    ...  regexp=CRMexe.*CRM\\/${DSS_STRING}\\/(Init|Alloc|Initial)
    ...                                               timeout=30s
    ...                                               alias=eNB
    ${syslog_msg} =  Run Keyword And Continue On Failure  Wait For Message In Syslog File
    ...  regexp=CRMexe.*CRM\\/${DSS_STRING}\\/(Init|Alloc|Initial)\\s(\\[([0-9]+|,|:|\\s)+\\]){15,30}
    ...                                               timeout=30s
    ...                                               alias=eNB
    Set Test Variable  ${SYSLOG_MSG}  ${syslog_msg}






