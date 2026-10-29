*** Settings ***

Force Tags    CLOUD_5G_I_LO_AP_LO
...           CONFIGURED    RAN_5G_TDD    RAN_5G    SBTS00
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Dan Moldovan
...              :contact:


Resource     CNI-87165_Variables_And_Keywords.robot

Suite Setup     Run Keywords    log to console    SS start
...             AND             Update And Put Iphy Xml    input_filepath=${custom-iphy}
#...             AND             With Swconfig Flags   flags=@{FLAGS_LIST}
...             AND             Setup Custom SCF    scf=${custom-scf}
...             AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Start Xn And Ng Interfaces For Second Gnb
...          AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_TDD_2Cells_SANSA_n41_n79_cell2capabil.lua
...          AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs


Test Setup        Run Keywords     log to console    TS start
...               AND              Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords     log to console    TT start
...               AND             UE Multiple Deregister    1    10

Suite Teardown    Run Keywords     log to console    ST start
...               AND              Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***

${rdMaxNumUeTdDl}=  0x5800CA=6
${rdMaxNumUeTDUl}=  0x5800CB=6
@{FLAGS_LIST}=  ${rdMaxNumUeTdDl}    ${rdMaxNumUeTDUl}

*** Test Cases ***
T1_CNI87165_Multi_UE_CA_DL_data_transmission_with_gNB_restart
     [Tags]    CRT
    [Documentation]     This test case validates the effect of the enhanced Estimated Throughput (eTh) calculation designed to reduce
     ...    the volatility of the eTh due to spikes in the CS1 list size. It helps to mitigate issues with RLC delays/retransmissions
     ...    caused by such spikes on any of the Cells where a CA UE is active.

    #UE1,2,3
    FOR    ${i}    IN RANGE    1    4
        Attach Ue And Establish PDU Session    ue_id=${i}    pdu_id=${i}   gw_id=${i}    mbps=50
    END
    FOR    ${i}    IN RANGE    1    4
        Check trafic    ue_id=${i}   pdu_id=${i}    scell=0
    END

    #UE4,5,6
    FOR    ${i}    IN RANGE    4    7
        Attach Ue And Establish PDU Session    ue_id=${i}    pdu_id=${i}   gw_id=${i}   mbps=50
    END
#
    #UE7,8,9
    FOR    ${i}    IN RANGE    7    10
        Attach Ue And Establish PDU Session Cell1    ue_id=${i}    pdu_id=${i}   gw_id=${i}    mbps=50
    END
    FOR    ${i}    IN RANGE    1    10
        Check trafic    ue_id=${i}   pdu_id=${i}    scell=0
    END
### Step 2 - increase traffic

    FOR    ${i}    IN RANGE    1    10
#        ${t} =    Evaluate    ${i}+1
        Start Traffic    ue_id=${i}   pdu_id=${i}   dir=dl    mbps=150    trf_id=2
    END
    sleep    60
# Check traffic and calculate average
    ${average}    Evaluate     0

    FOR    ${i}    IN RANGE    1    10
        Check trafic    ue_id=${i}   pdu_id=${i}    scell=0

        ${average}    Evaluate     ${average} + ${out}
        log to console   av${i}:${average}

    END

    ${av1}  Evaluate    ${average}/${i}
    log to console    Totalav:${av1}

    #Step 3
    #Deregister
    log to console    Deregister
    FOR    ${i}    IN RANGE    1    10
        UE Deregister    ue_id=${i}
    END

    log to console    Activate feature:87165
     Perform Parameter Commissioning    parameter=actEnhancedFlowControlETh   value=true    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
     Perform Parameter Commissioning    parameter=actEnhancedFlowControlETh   value=true    dist_name=MRBTS-1/NRBTS-1/NRCELL-2
#     Trigger Site Reset
    Reset Site And Reconnect
     Wait for all cells to be enabled    timeout=600

#     #Step 3
    log to console    Perform again first 2 steps
       #UE1,2,3
    FOR    ${i}    IN RANGE    1    4
        Attach Ue And Establish PDU Session    ue_id=${i}    pdu_id=${i}   gw_id=${i}    mbps=50
    END

    #UE4,5,6
    FOR    ${i}    IN RANGE    4    7
        Attach Ue And Establish PDU Session    ue_id=${i}    pdu_id=${i}   gw_id=${i}   mbps=50
    END
#
    #UE7,8,9
    FOR    ${i}    IN RANGE    7    10
        Attach Ue And Establish PDU Session Cell1    ue_id=${i}    pdu_id=${i}   gw_id=${i}    mbps=50
    END
    FOR    ${i}    IN RANGE    1    10
        Check trafic    ue_id=${i}   pdu_id=${i}    scell=0
    END
### Step 2 - increase traffic

    FOR    ${i}    IN RANGE    1    10
#        ${t} =    Evaluate    ${i}+1
        Start Traffic    ue_id=${i}   pdu_id=${i}   dir=dl    mbps=150    trf_id=2
    END
# Check traffic and calculate average
    sleep    60
    ${average}    Evaluate     0

    FOR    ${i}    IN RANGE    1    10
        Check trafic    ue_id=${i}   pdu_id=${i}    scell=0

        ${average}    Evaluate     ${average} + ${out}
        log to console   av${i}:${average}

    END


    ${av2}  Evaluate    ${average}/${i}
    log to console    Totalav:${av2}

    ${Diffav}    Evaluate    ${av1}-${av2}
    log to console    Difference of average is:${Diffav}
    ${absDiffav}    Evaluate    abs(${Diffav})
    #${margin}  Evaluate  ${av1}/10
    ${margin}  Evaluate  50000000/7
    Run Keyword If    ${absDiffav} <= ${margin}
    ...    log to console  ${Diffav} is smaler than margin:${margin}
    ...    ELSE
    ...    Fail     msg=${Diffav} is bigger than margin:${margin}

    #Deregister
#    log to console    Deregister
#    FOR    ${i}    IN RANGE    1    10
#        UE Deregister    ue_id=${i}
#    END
