** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Deepthi A
                 ...              :contact      : deepthi.a@nokia.com
                 ...              :Description  : Contains Keyword needed for CB014817
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,10.08.2025,deepthi.a@nokia.com

Resource    ../../../../resources/Keywords/general_common_keywords.robot
Resource    ../Variables/CB012299_Variables.robot
Library     ../Python/extract_uestats.py
Library      ta5g_pm_counters
Library     ta_a2a.interface

Library    BuiltIn
Library    SeleniumLibrary
Library    String
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin         WITH NAME    admin
#Library    ta5g_commissioning              WITH NAME    tcom
Library    Collections
Library    ute_fsmaccess
Library    taf.analyzer.pcap    WITH NAME    cap
#Library         ../../../resources/PythonLib/UTILS.py
#Library     ../Keywords/table.py


*** Keywords ***
L3 Suite Setup
     Log to console      "suite setup"

L3 Suite Teardown
     Log to console      "suite teardown"

UE Register and PDU Session
     Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}       return_output=False
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

RRC reestablishment cause - reconfigurationFailure
    Exe egate cmd         cmd=${ReconfigurationFailure}

RRC reestablishment cause - handoverFailure
    Exe egate cmd         cmd=${HandoverFailure}

RRC reestablishment cause - otherFailure
    Exe egate cmd         cmd=${otherFailure}

RRC reestablishment cause - spare1
    Exe egate cmd         cmd=${spare1}

Send 800mbps DATA TRAFIC wait for SCELL activation
    Exe egate cmd         cmd=${DATA TRF 1}
    Sleep      10
    Exe egate cmd         cmd=${DATA TRF 2}
    Sleep      10
    Exe egate cmd         cmd=${DATA TRF 3}
    Sleep      10
    Exe egate cmd         cmd=${DATA TRF 4}
    Sleep      10
    Exe egate cmd         cmd=${DATA TRF 5}
    Sleep      10
    Exe egate cmd         cmd=${DATA TRF 6}
    Sleep      10
    Exe egate cmd         cmd=${DATA TRF 7}
    Sleep      10
    Exe egate cmd         cmd=${DATA TRF 8}
    Sleep      10
    Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_SCELL_1_ACTIVATED}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
Deregister UE
         Exe egate cmd         cmd=${UE_DEREGISTER}
Send 800mbps DATA TRAFIC
    Exe egate cmd         cmd=${DATA TRF 1}
    Sleep      10
    Exe egate cmd         cmd=${DATA TRF 2}
    Sleep      10
    Exe egate cmd         cmd=${DATA TRF 3}
    Sleep      10
    Exe egate cmd         cmd=${DATA TRF 4}
    Sleep      10
    Exe egate cmd         cmd=${DATA TRF 5}
    Sleep      10
    Exe egate cmd         cmd=${DATA TRF 6}
    Sleep      10
    Exe egate cmd         cmd=${DATA TRF 7}
    Sleep      10
    Exe egate cmd         cmd=${DATA TRF 8}
    Sleep      10

Validate Data Rate
     Exe egate cmd      cmd=${CM_UE_1_STATS}
     Sleep      5
     ${value}      extract_uestats.Extract Numeric Value From Log     file_path=/opt/wts/latest/egate_console.log
     Should Be True      ${value}>500

Transition from Nominal to Limited BW
    [Arguments]         ${lock_element}=MRBTS-1/NRBTS-1/NRCELL-1
    [Documentation]     This Keyword modifies the NIDD parameter semiDynamicBwSize to limited BW
    Log to Console      semiDynamicBwSize Set to Limited Band Width
    admin.Setup admin
    Online NIDD parameter change    paramName=semiDynamicBwSize            paramValue=limitedBandwidth
    ...                             paramDst=${lock_element}
    sleep               60s
    [Teardown]          admin.Teardown admin

Transition from Limited to Nominal BW
    [Arguments]         ${lock_element}=MRBTS-1/NRBTS-1/NRCELL-1
    [Documentation]     This Keyword modifies the NIDD parameter semiDynamicBwSize to Nominal BW
    Log to Console      semiDynamicBwSize Set to Nominal Band Width
    admin.Setup admin
    Online NIDD parameter change    paramName=semiDynamicBwSize            paramValue=nominalBandwidth
    ...                             paramDst=${lock_element}
    sleep               60s
    [Teardown]          admin.Teardown admin

Verifying the Counter for CB012299_C_limited_bw
     Log to Console      Fetching the PM Counter\n
     Wait For Next Full Pm Interval
     Sleep       180
     ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
     Verify Last Counters In File
     ...     M55166C00001     1     NRRC_RRC_RECONF_BWP1_SENT
     ...     M55166C00025     1     NUM_RU_ATT_RCFG_BWP
     ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
     ...     file_path=${pm_counter_file}

Verifying the Counter for CB012299_C_nominal_bw
     Log to Console      Fetching the PM Counter\n
     Wait For Next Full Pm Interval
     Sleep         180
     ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
     Verify Last Counters In File
     ...     M55166C00001     1     NRRC_RRC_RECONF_BWP2_SENT
     ...     M55166C00025     1     NUM_RU_ATT_RCFG_BWP
     ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
     ...     file_path=${pm_counter_file}

PM Check passing dictionary validate
    Log to Console       PM Check passing dictionary started\n
    FOR     ${counter_id}     ${counter_name}     IN     &{COUNTER_CHECKS}
       Log    Key: ${counter_id}, Value: ${counter_name}
       ${COUNTER_FILE}=      Get Latest Unpacked Full Pm Counters File
       Verify Last Counters In File
       ...     ${counter_id}      1      ${counter_name}
       ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-2
       ...     file_path=${COUNTER_FILE}

PM Check passing dictionary
    Log to Console       PM Check passing dictionary started\n
    FOR     ${counter_id}     ${counter_name}     IN     &{COUNTER_CHECKS}
       Log    Key: ${counter_id}, Value: ${counter_name}
    END

Verifying the Counter for CB012299_D
     Log to Console      Fetching the PM Counter\n
     Wait For Next Full Pm Interval
     ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
     Verify Last Counters In File
     ...     M55139C04511     1     GNB_DU_SCELL_ADM_BWP1_SUCC
     ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-2
     ...     file_path=${pm_counter_file}

