*** Settings ***

Documentation    CB008127-E_CRT_Keywords

*** Keywords ***

SA Verify A2 Measurement RSRP From PDML
    [Arguments]  ${file}=.  ${threshold}=.  ${hysteresis}=.  ${trigger}=.

    ${event_found}=  Set Variable    ${False}
    ${pdml_xml_doc}=  Parse Xml    ${file}

    ${eventA2_element}   Get Elements    ${pdml_xml_doc}    xpath=.//field[@name="nr-rrc.eventA2_element"]
    BuiltIn.Should Not Be Empty    ${eventA2_element}

    @{lst_eventA2}    create list
    FOR  ${i}  IN   @{eventA2_element}
        ${element1}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.a2_Threshold"]
        ${element2}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.measTriggerQuantity.rsrp"]
        ${element3}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.hysteresis"]
        ${element4}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.timeToTrigger"]

        IF  "${element1}[0]"=="PASS"  Append To List   ${lst_eventA2}   ${element1}[1]
        IF  "${element2}[0]"=="PASS"  Append To List   ${lst_eventA2}   ${element2}[1]
        #IF  "${element2}[0]"=="PASS"  Log Element    ${i}    INFO
        IF  "${element3}[0]"=="PASS"  Append To List   ${lst_eventA2}   ${element3}[1]
        IF  "${element4}[0]"=="PASS"  Append To List   ${lst_eventA2}   ${element4}[1]
    END
    BuiltIn.Should Not Be Empty    ${lst_eventA2}
    @{lst_A2_attributes}       Create List

    FOR  ${i}  IN   @{lst_eventA2}
        ${value}    Get Element Attribute    ${i}    showname
        # Log Element    ${i}    INFO
        Append To List   ${lst_A2_attributes}   ${value}
    END

    ${j}=  Set Variable    0
    FOR  ${i}  IN   @{lst_A2_attributes}
        ${j}=  Evaluate    ${j} + 1
        Log To Console  \n## A2 attribute ${j}: ${i}
        IF  ${j}==1  Should Contain  ${i}  rsrp  msg=ERR: No match for a2MeashoEnabledSA
        ...  ELSE IF  ${j}==2  Should Contain  ${i}  ${threshold}  msg=ERR: No match for a2ThresholdhoSsbRsrpSA
        ...  ELSE IF  ${j}==3  Should Contain  ${i}  ${hysteresis}  msg=ERR: No match for a2HysteresishoSsbRsrp
        ...  ELSE IF  ${j}==4  Should Contain  ${i}  ${trigger}  msg=ERR: No match for a2TimeToTriggerhoSsbRsrp
    END
    ${event_found}=  Set variable  ${True}
    RETURN    ${event_found}

SA Verify A2 Measurement RSRQ From PDML
    [Arguments]  ${file}=.  ${threshold}=.  ${hysteresis}=.  ${trigger}=.

    ${event_found}=  Set Variable    ${False}
    ${pdml_xml_doc}=  Parse Xml    ${file}

    ${eventA2_element}   Get Elements    ${pdml_xml_doc}    xpath=.//field[@name="nr-rrc.eventA2_element"]
    BuiltIn.Should Not Be Empty    ${eventA2_element}

    @{lst_eventA2}    create list
    FOR  ${i}  IN   @{eventA2_element}
        ${element1}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.a2_Threshold"]
        ${element2}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.measTriggerQuantity.rsrq"]
        ${element3}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.hysteresis"]
        ${element4}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.timeToTrigger"]

        IF  "${element1}[0]"=="PASS"  Append To List   ${lst_eventA2}   ${element1}[1]
        IF  "${element2}[0]"=="PASS"  Append To List   ${lst_eventA2}   ${element2}[1]
        #IF  "${element2}[0]"=="PASS"  Log Element    ${i}    INFO
        IF  "${element3}[0]"=="PASS"  Append To List   ${lst_eventA2}   ${element3}[1]
        IF  "${element4}[0]"=="PASS"  Append To List   ${lst_eventA2}   ${element4}[1]
    END
    BuiltIn.Should Not Be Empty    ${lst_eventA2}
    @{lst_A2_attributes}       Create List

    FOR  ${i}  IN   @{lst_eventA2}
        ${value}    Get Element Attribute    ${i}    showname
        # Log Element    ${i}    INFO
        Append To List   ${lst_A2_attributes}   ${value}
    END

    ${j}=  Set Variable    0
    FOR  ${i}  IN   @{lst_A2_attributes}
        ${j}=  Evaluate    ${j} + 1
        Log To Console  \n## A2 attribute ${j}: ${i}
        IF  ${j}==1  Should Contain  ${i}  rsrq  msg=ERR: No match for a2MeashoEnabledSA
        ...  ELSE IF  ${j}==2  Should Contain  ${i}  ${threshold}  msg=ERR: No match for a2ThresholdhoSsbRsrqSA
        ...  ELSE IF  ${j}==3  Should Contain  ${i}  ${hysteresis}  msg=ERR: No match for a2HysteresishoSsbRsrq
        ...  ELSE IF  ${j}==4  Should Contain  ${i}  ${trigger}  msg=ERR: No match for a2TimeToTriggerhoSsbRsrq
    END
    ${event_found}=  Set variable  ${True}
    RETURN    ${event_found}

SA Verify A3 Measurement RSRP From PDML
    [Arguments]  ${file}=.  ${offset}=.  ${hysteresis}=.  ${trigger}=.

    ${event_found}=  Set Variable    ${False}
    ${pdml_xml_doc}=  Parse Xml    ${file}

    ${eventA3_element}   Get Elements    ${pdml_xml_doc}    xpath=.//field[@name="nr-rrc.eventA3_element"]
    BuiltIn.Should Not Be Empty    ${eventA3_element}

    @{lst_eventA3}    create list
    FOR  ${i}  IN   @{eventA3_element}
        ${element1}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.hysteresis"]
        ${element2}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.timeToTrigger"]
        IF  "${element1}[0]"=="PASS"  Append To List   ${lst_eventA3}   ${element1}[1]
        IF  "${element2}[0]"=="PASS"  Append To List   ${lst_eventA3}   ${element2}[1]
        #IF  "${element2}[0]"=="PASS"  Log Element    ${i}    INFO
    END
    BuiltIn.Should Not Be Empty    ${lst_eventA3}

    @{lst_A3_attributes}       Create List
    FOR  ${i}  IN   @{lst_eventA3}
        ${value}    Get Element Attribute    ${i}    showname
        #Log Element    ${i}    INFO
        Append To List   ${lst_A3_attributes}   ${value}
    END

    ${j}=  Set Variable    0
    FOR  ${i}  IN   @{lst_A3_attributes}
        ${j}=  Evaluate    ${j} + 1
        #Log To Console  \n## A3 attribute ${j}: ${i}
        IF  ${j}==1  Should Contain  ${i}  ${hysteresis}  msg=ERR: No match for a3HysteresisSsbRsrp
        ...  ELSE IF  ${j}==2  Should Contain  ${i}  ${trigger}  msg=ERR: No match for a3TimeToTriggerSsbRsrp
    END

    ${eventA3_offset_element}    Get Elements    ${pdml_xml_doc}    xpath=.//field[@name="nr-rrc.a3_Offset"]
    BuiltIn.Should Not Be Empty    ${eventA3_offset_element}

    @{lst_eventA3_offset}    create list
    FOR  ${i}  IN   @{eventA3_offset_element}
        ${element1}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.measTriggerQuantityOffset.rsrp"]
        IF  "${element1}[0]"=="PASS"  Append To List   ${lst_eventA3_offset}   ${element1}[1]
    END
    BuiltIn.Should Not Be Empty    ${lst_eventA3_offset}

    # rsrp: 5.0dB (10)
    # A3 parameter: a3OffsetSsbRsrp 10

    @{lst_A3_offset_attributes}       Create List
    FOR  ${i}  IN   @{lst_eventA3_offset}
        ${value}    Get Element Attribute    ${i}    showname
        #Log Element    ${i}    INFO
        Append To List   ${lst_A3_offset_attributes}   ${value}
    END
    BuiltIn.Should Not Be Empty    ${lst_A3_offset_attributes}

    ${j}=  Set Variable    0
    FOR  ${i}  IN   @{lst_A3_offset_attributes}
        ${j}=  Evaluate    ${j} + 1
        Log To Console  \n## A3 offset attribute ${j}: ${i}
        IF  ${j}==1
            Should Contain  ${i}  rsrp  msg=ERR: No match for a3MeasSsbRsrp
            Should Contain  ${i}  ${offset}  msg=ERR: No match for a3OffsetSsbRsrp
        END
    END

    ${event_found}=  Set variable  ${True}
    RETURN    ${event_found}

SA Verify A5 Measurement RSRP From PDML
    [Arguments]  ${file}=.  ${threshold1}=.  ${threshold2}=.  ${hysteresis}=.  ${trigger}=.

    ${event_found}=  Set Variable    ${False}
    ${pdml_xml_doc}=  Parse Xml    ${file}

    ${eventA5_element}   Get Elements    ${pdml_xml_doc}    xpath=.//field[@name="nr-rrc.eventA5_element"]
    BuiltIn.Should Not Be Empty    ${eventA5_element}

    @{lst_eventA5}    create list
    FOR  ${i}  IN   @{eventA5_element}
        ${element1}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.hysteresis"]
        ${element2}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.timeToTrigger"]
        IF  "${element1}[0]"=="PASS"  Append To List   ${lst_eventA5}   ${element1}[1]
        IF  "${element2}[0]"=="PASS"  Append To List   ${lst_eventA5}   ${element2}[1]
        #IF  "${element2}[0]"=="PASS"  Log Element    ${i}    INFO
    END
    BuiltIn.Should Not Be Empty    ${lst_eventA5}

    @{lst_A5_attributes}       Create List
    FOR  ${i}  IN   @{lst_eventA5}
        ${value}    Get Element Attribute    ${i}    showname
        #Log Element    ${i}    INFO
        Append To List   ${lst_A5_attributes}   ${value}
    END

    ${j}=  Set Variable    0
    FOR  ${i}  IN   @{lst_A5_attributes}
        ${j}=  Evaluate    ${j} + 1
        # Log To Console  \n## A5 attribute ${j}: ${i}
        IF  ${j}==1  Should Contain  ${i}  ${hysteresis}  msg=ERR: No match for a5HysteresisSsbRsrp
        ...  ELSE IF  ${j}==2  Should Contain  ${i}  ${trigger}  msg=ERR: No match for a5TimeToTriggerSsbRsrp
    END

    ${eventA5_Threshold1_element}    Get Elements    ${pdml_xml_doc}    xpath=.//field[@name="nr-rrc.a5_Threshold1"]
    BuiltIn.Should Not Be Empty    ${eventA5_Threshold1_element}

    @{lst_eventA5_Threshold1}    create list
    FOR  ${i}  IN   @{eventA5_Threshold1_element}
      ${element1}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.measTriggerQuantity.rsrp"]
      IF  "${element1}[0]"=="PASS"  Append To List   ${lst_eventA5_Threshold1}   ${element1}[1]
    END
    BuiltIn.Should Not Be Empty    ${lst_eventA5_Threshold1}

    # rsrp: -105dBm &lt;= SS-RSRP &lt; -104dBm (52)
    # A5 parameter: a5Threshold1SsbRsrp 52

    @{lst_A5_Threshold1_attributes}       Create List
    FOR  ${i}  IN   @{lst_eventA5_Threshold1}
        ${value}    Get Element Attribute    ${i}    showname
        #Log Element    ${i}    INFO
        Append To List   ${lst_A5_Threshold1_attributes}   ${value}
    END
    BuiltIn.Should Not Be Empty    ${lst_A5_Threshold1_attributes}
    ${j}=  Set Variable    0
    FOR  ${i}  IN   @{lst_A5_Threshold1_attributes}
        ${j}=  Evaluate    ${j} + 1
        Log To Console  \n## A5 Threshold1 attribute ${j}: ${i}
        IF  ${j}==1
            Should Contain  ${i}  rsrp  msg=ERR: No match for a5MeasSsbRsrp
            Should Contain  ${i}  ${threshold1}  msg=ERR: No match for a5Threshold1SsbRsrp
        END
    END

    ${eventA5_Threshold2_element}    Get Elements    ${pdml_xml_doc}    xpath=.//field[@name="nr-rrc.a5_Threshold2"]
    BuiltIn.Should Not Be Empty    ${eventA5_Threshold2_element}

    @{lst_eventA5_Threshold2}    create list
    FOR  ${i}  IN   @{eventA5_Threshold2_element}
        ${element1}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.measTriggerQuantity.rsrp"]
        IF  "${element1}[0]"=="PASS"  Append To List   ${lst_eventA5_Threshold2}   ${element1}[1]
    END
    BuiltIn.Should Not Be Empty    ${lst_eventA5_Threshold2}

    # rsrp: -95dBm &lt;= SS-RSRP &lt; -94dBm (62)
    # A5 parameter: a5Threshold2SsbRsrp 62

    @{lst_A5_Threshold2_attributes}       Create List
    FOR  ${i}  IN   @{lst_eventA5_Threshold2}
        ${value}    Get Element Attribute    ${i}    showname
        #Log Element    ${i}    INFO
        Append To List   ${lst_A5_Threshold2_attributes}   ${value}
    END
    BuiltIn.Should Not Be Empty    ${lst_A5_Threshold2_attributes}
    ${j}=  Set Variable    0
    FOR  ${i}  IN   @{lst_A5_Threshold2_attributes}
        ${j}=  Evaluate    ${j} + 1
        Log To Console  \n## A5 Threshold2 attribute ${j}: ${i}
        IF  ${j}==1
            Should Contain  ${i}  rsrp  msg=ERR: No match for a5MeasSsbRsrp
            Should Contain  ${i}  ${threshold2}  msg=ERR: No match for a5Threshold2SsbRsrp
        END
    END

    #  Log to console  \n##-----------------------------------------
    #  FOR  ${j}  IN   @{lst_attributes}
    #      Log to console  Attribute list: ${j}
    #  END
    #  Log to console  \n##-----------------------------------------

    ${event_found}=  Set variable  ${True}
    RETURN    ${event_found}

SA Verify A3 Measurement RSRQ From PDML
    [Arguments]  ${file}=.  ${offset}=.  ${hysteresis}=.  ${trigger}=.

    ${event_found}=  Set Variable    ${False}
    ${pdml_xml_doc}=  Parse Xml    ${file}

    ${eventA3_element}   Get Elements    ${pdml_xml_doc}    xpath=.//field[@name="nr-rrc.eventA3_element"]
    BuiltIn.Should Not Be Empty    ${eventA3_element}

    @{lst_eventA3}    create list
    FOR  ${i}  IN   @{eventA3_element}
        ${element1}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.hysteresis"]
        ${element2}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.timeToTrigger"]
        IF  "${element1}[0]"=="PASS"  Append To List   ${lst_eventA3}   ${element1}[1]
        IF  "${element2}[0]"=="PASS"  Append To List   ${lst_eventA3}   ${element2}[1]
        #IF  "${element2}[0]"=="PASS"  Log Element    ${i}    INFO
    END
    BuiltIn.Should Not Be Empty    ${lst_eventA3}

    @{lst_A3_attributes}       Create List
    FOR  ${i}  IN   @{lst_eventA3}
        ${value}    Get Element Attribute    ${i}    showname
        #Log Element    ${i}    INFO
        Append To List   ${lst_A3_attributes}   ${value}
    END

    ${j}=  Set Variable    0
    FOR  ${i}  IN   @{lst_A3_attributes}
        ${j}=  Evaluate    ${j} + 1
        #Log To Console  \n## A3 attribute ${j}: ${i}
        IF  ${j}==1  Should Contain  ${i}  ${hysteresis}  msg=ERR: No match for a3HysteresisSsbRsrq
        ...  ELSE IF  ${j}==2  Should Contain  ${i}  ${trigger}  msg=ERR: No match for a3TimeToTriggerSsbRsrq
    END

    ${eventA3_offset_element}    Get Elements    ${pdml_xml_doc}    xpath=.//field[@name="nr-rrc.a3_Offset"]
    BuiltIn.Should Not Be Empty    ${eventA3_offset_element}

    @{lst_eventA3_offset}    create list
    FOR  ${i}  IN   @{eventA3_offset_element}
        ${element1}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.measTriggerQuantityOffset.rsrq"]
        IF  "${element1}[0]"=="PASS"  Append To List   ${lst_eventA3_offset}   ${element1}[1]
    END
    BuiltIn.Should Not Be Empty    ${lst_eventA3_offset}

    # rsrp: 5.0dB (10)
    # A3 parameter: a3OffsetSsbRsrp 10

    @{lst_A3_offset_attributes}       Create List
    FOR  ${i}  IN   @{lst_eventA3_offset}
        ${value}    Get Element Attribute    ${i}    showname
        #Log Element    ${i}    INFO
        Append To List   ${lst_A3_offset_attributes}   ${value}
    END
    BuiltIn.Should Not Be Empty    ${lst_A3_offset_attributes}

    ${j}=  Set Variable    0
    FOR  ${i}  IN   @{lst_A3_offset_attributes}
        ${j}=  Evaluate    ${j} + 1
        Log To Console  \n## A3 offset attribute ${j}: ${i}
        IF  ${j}==1
            Should Contain  ${i}  rsrq  msg=ERR: No match for a3MeasSsbRsrq
            Should Contain  ${i}  ${offset}  msg=ERR: No match for a3OffsetSsbRsrq
        END
    END

    ${event_found}=  Set variable  ${True}
    RETURN    ${event_found}

SA Verify A5 Measurement RSRQ From PDML
    [Arguments]  ${file}=.  ${threshold1}=.  ${threshold2}=.  ${hysteresis}=.  ${trigger}=.

    ${event_found}=  Set Variable    ${False}
    ${pdml_xml_doc}=  Parse Xml    ${file}

    ${eventA5_element}   Get Elements    ${pdml_xml_doc}    xpath=.//field[@name="nr-rrc.eventA5_element"]
    BuiltIn.Should Not Be Empty    ${eventA5_element}

    @{lst_eventA5}    create list
    FOR  ${i}  IN   @{eventA5_element}
        ${element1}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.hysteresis"]
        ${element2}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.timeToTrigger"]
        IF  "${element1}[0]"=="PASS"  Append To List   ${lst_eventA5}   ${element1}[1]
        IF  "${element2}[0]"=="PASS"  Append To List   ${lst_eventA5}   ${element2}[1]
        #IF  "${element2}[0]"=="PASS"  Log Element    ${i}    INFO
    END
    BuiltIn.Should Not Be Empty    ${lst_eventA5}

    @{lst_A5_attributes}       Create List
    FOR  ${i}  IN   @{lst_eventA5}
        ${value}    Get Element Attribute    ${i}    showname
        #Log Element    ${i}    INFO
        Append To List   ${lst_A5_attributes}   ${value}
    END

    ${j}=  Set Variable    0
    FOR  ${i}  IN   @{lst_A5_attributes}
        ${j}=  Evaluate    ${j} + 1
        # Log To Console  \n## A5 attribute ${j}: ${i}
        IF  ${j}==1  Should Contain  ${i}  ${hysteresis}  msg=ERR: No match for a5HysteresisSsbRsrq
        ...  ELSE IF  ${j}==2  Should Contain  ${i}  ${trigger}  msg=ERR: No match for a5TimeToTriggerSsbRsrq
    END

    ${eventA5_Threshold1_element}    Get Elements    ${pdml_xml_doc}    xpath=.//field[@name="nr-rrc.a5_Threshold1"]
    BuiltIn.Should Not Be Empty    ${eventA5_Threshold1_element}

    @{lst_eventA5_Threshold1}    create list
    FOR  ${i}  IN   @{eventA5_Threshold1_element}
      ${element1}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.measTriggerQuantity.rsrq"]
      IF  "${element1}[0]"=="PASS"  Append To List   ${lst_eventA5_Threshold1}   ${element1}[1]
    END
    BuiltIn.Should Not Be Empty    ${lst_eventA5_Threshold1}

    # rsrp: -105dBm &lt;= SS-RSRP &lt; -104dBm (52)
    # A5 parameter: a5Threshold1SsbRsrp 52

    @{lst_A5_Threshold1_attributes}       Create List
    FOR  ${i}  IN   @{lst_eventA5_Threshold1}
        ${value}    Get Element Attribute    ${i}    showname
        #Log Element    ${i}    INFO
        Append To List   ${lst_A5_Threshold1_attributes}   ${value}
    END
    BuiltIn.Should Not Be Empty    ${lst_A5_Threshold1_attributes}
    ${j}=  Set Variable    0
    FOR  ${i}  IN   @{lst_A5_Threshold1_attributes}
        ${j}=  Evaluate    ${j} + 1
        Log To Console  \n## A5 Threshold1 attribute ${j}: ${i}
        IF  ${j}==1
            Should Contain  ${i}  rsrq  msg=ERR: No match for a5MeasSsbRsrq
            Should Contain  ${i}  ${threshold1}  msg=ERR: No match for a5Threshold1SsbRsrq
        END
    END

    ${eventA5_Threshold2_element}    Get Elements    ${pdml_xml_doc}    xpath=.//field[@name="nr-rrc.a5_Threshold2"]
    BuiltIn.Should Not Be Empty    ${eventA5_Threshold2_element}

    @{lst_eventA5_Threshold2}    create list
    FOR  ${i}  IN   @{eventA5_Threshold2_element}
        ${element1}    Run Keyword And Ignore Error    Get Element    ${i}    .//field[@name="nr-rrc.measTriggerQuantity.rsrq"]
        IF  "${element1}[0]"=="PASS"  Append To List   ${lst_eventA5_Threshold2}   ${element1}[1]
    END
    BuiltIn.Should Not Be Empty    ${lst_eventA5_Threshold2}

    # rsrp: -95dBm &lt;= SS-RSRP &lt; -94dBm (62)
    # A5 parameter: a5Threshold2SsbRsrp 62

    @{lst_A5_Threshold2_attributes}       Create List
    FOR  ${i}  IN   @{lst_eventA5_Threshold2}
        ${value}    Get Element Attribute    ${i}    showname
        #Log Element    ${i}    INFO
        Append To List   ${lst_A5_Threshold2_attributes}   ${value}
    END
    BuiltIn.Should Not Be Empty    ${lst_A5_Threshold2_attributes}
    ${j}=  Set Variable    0
    FOR  ${i}  IN   @{lst_A5_Threshold2_attributes}
        ${j}=  Evaluate    ${j} + 1
        Log To Console  \n## A5 Threshold2 attribute ${j}: ${i}
        IF  ${j}==1
            Should Contain  ${i}  rsrq  msg=ERR: No match for a5MeasSsbRsrq
            Should Contain  ${i}  ${threshold2}  msg=ERR: No match for a5Threshold2SsbRsrq
        END
    END

    #  Log to console  \n##-----------------------------------------
    #  FOR  ${j}  IN   @{lst_attributes}
    #      Log to console  Attribute list: ${j}
    #  END
    #  Log to console  \n##-----------------------------------------

    ${event_found}=  Set variable  ${True}
    RETURN    ${event_found}

Start Internal Data Transfer
    [Arguments]    ${ue_id}=1  ${pdu_id}=1  ${tp_mbps}=1
    Log to console  Start UL and DL data for UE: ${ue_id}, PDU: ${pdu_id},  tput: ${tp_mbps}

    # Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl trf_id=4 mbps=${tp_mbps}
    # Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul trf_id=5 mbps=${tp_mbps}

Stop Internal Data Transfer
    [Arguments]    ${ue_id}=1
    Run Keyword And Continue On Failure  Stop Data Traffic    ues=${ue_id}

Print Data Throughput
   [Arguments]    ${ue_id}=1    ${pdu_id}=1

    ${dl_throughput}=    Run Keyword And Continue On Failure    SA Get UE Average Traffic Internal  ue_id=${ue_id}  pdu_id=${pdu_id}  dir=dl
    # ${ul_throughput}=    Run Keyword And Continue On Failure    SA Get UE Average Traffic Internal  ue_id=${ue_id}  pdu_id=${pdu_id}  dir=ul
    #Log to console  UE-${ue_id} Through Put DL:${dl_throughput}, UL:${ul_throughput}
    Log to console  UE-${ue_id} Through Put DL:${dl_throughput}

SA Get UE Average Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${qfi}=1
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi} dir\=${dir}
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${tp_delta}    Evaluate    ${avg}*0.000001
    RETURN    ${tp_delta}
