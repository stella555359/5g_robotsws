*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB008146-F commissioning

Resource    ../../resources/SQD65/sqd65_commissioning.robot

*** Variables ***

# default profile: 1
# ue mob profile : 2

${CB008146-F_SCF}                scfc_8146-F.xml
${DELTA_CB008146-F_SCF}          delta_scfc_8146-F.json
${NIDD_VERSION}                  NRBTSCL5G21B_2104_100
${EPS_TAC}                       222
${ENB_ID}                        18
${ENB_PHY_CELL_ID}               11
${RFSP_INDEX}                    99
${CELL_TECHNOLOGY}                TDD

&{MEAS_CFG_1}
...    earfcnValue=1000
...    b2MeashoEnabled=rsrq
...    a1MeashoEnabledSA=rsrp
...    a2MeashoEnabledSA=rsrq

&{MEAS_CFG_2}
...    earfcnValue=2000
...    b2MeashoEnabled=rsrpAndRsrq
...    a1MeashoEnabledSA=rsrpAndRsrq
...    a2MeashoEnabledSA=rsrp

&{plmn}                         mcc=311  mnc=489  mncLength=3
&{plmn_2}                       mcc=250  mnc=255  mncLength=3

${maxReportCells}                8       #hardcoded (5GC000707-8852)
${maxNrofIndexesToReport}        8       #hardcoded (5G_RAN_CP_28917)
${includeBeamMeasurements}       true    #hardcoded (5G_RAN_CP_12371925)

#NRCELL-1
${a1HysteresishoSsbRsrpSA}       15	 #0
${a1ThresholdhoSsbRsrpSA}        100	 #60
${a1TimeToTriggerhoSsbRsrpSA}    ms2560	 #ms480
${a1HysteresishoSsbRsrqSA}       15	 #0
${a1ThresholdhoSsbRsrqSA}        127	 #63
${a1TimeToTriggerhoSsbRsrqSA}    ms40	 #ms480

&{A2_MEAS_CFG}
...    a2HysteresishoSsbRsrpSA=0
...    a2ThresholdhoSsbRsrpSA=34
...    a2TimeToTriggerhoSsbRsrpSA=ms480
...    a2HysteresishoSsbRsrqSA=0
...    a2ThresholdhoSsbRsrqSA=49
...    a2TimeToTriggerhoSsbRsrqSA=ms480

${reportAmountSA}                r64     #r4
${reportIntervalSA}              min12   #ms120
${reportOnLeave}                 false   #hardcoded (5G_RAN_CP_33586)

${filterCoeffSsbRsrp}            fc4     #fc4
${filterCoeffSsbRsrq}            spare1  #fc4

${measGapSelectionSA}            favorFastMeasurements   #favourUeThroughput
${gapOffset}                     80        #0
${mgta}                          ms0       #ms0

&{NRHOIR_1}
...  allowedMeasBandwidth=mbw50
...  b2Threshold1hoRsrp=35
...  b2Threshold1hoRsrq=50
...  b2HysteresishoRsrp=0
...  b2Threshold2hoRsrp=18
...  b2TimeToTriggerhoRsrp=ms480
...  b2HysteresishoRsrq=0
...  b2Threshold2hoRsrq=18
...  b2TimeToTriggerhoRsrq=ms480
...  b2reportAmount=r8
...  b2reportInterval=ms240
...  presenceAntennaPort1=false
...  widebandRsrqMeas=false
...  b1MeasRedirectEnabled=none

&{NRHOIR_2}
...  allowedMeasBandwidth=mbw100    #mbw50
...  b2Threshold1hoRsrp=0	    #35
...  b2Threshold1hoRsrq=127	    #50
...  b2HysteresishoRsrp=15	    #0
...  b2Threshold2hoRsrp=0	    #18
...  b2TimeToTriggerhoRsrp=ms0	    #ms480
...  b2HysteresishoRsrq=10	    #0
...  b2Threshold2hoRsrq=0	    #18
...  b2TimeToTriggerhoRsrq=ms5120   #ms480
...  b2reportAmount=infinity        #r8
...  b2reportInterval=min30	    #ms240
...  presenceAntennaPort1=true	    #false
...  widebandRsrqMeas=true	    #false
...  b1MeasRedirectEnabled=none


*** Keywords ***


Commissioning
    [Arguments]    ${actMobilityProfile}=true
    scf.load_scf              ${P_ORIG_SCF}
    Get Values from SCF
    Add NRADJECELL-1 to SCF
    Add NRADJECELL-2 to SCF
    Add NRHOIR-1 to SCF
    Add NRHOIR-2 to SCF
    Add NRMOPR_NSA to SCF
    Add NRRELE-1 to SCF
    Add NRRELE-2 to SCF
    Add NRMEASCFG_IR to SCF
    Add NRMOPRMA_SA to SCF
    Add NRMOPR_SA to SCF
    Add SNSSAI to SCF
    Add SNSSAI to TRACKINGAREA
    Update Params in NRCELL  cell_id=1
    Update Params in NRCELL  cell_id=2
    Update Params in NRCELL  cell_id=3
    Update Params in NRCELL  cell_id=4
    Update Params in NRPMRNL
    Update Params in NRBTS    ${actMobilityProfile}
    Update Params in XNLINK

    scf.modify_scf_element   dist_name=MRBTS-1/MNL-1/AMGR-1/LUAC-1          p_name=webEMSessionLogoutTimer   value=7200
    scf.modify_scf_element   dist_name=MRBTS-1/MNL-1/MNLENT-1/PMCADM-1      p_name=reportingIntervalPm       value=5min

    ${ts_conf_dir}=          Get Test Suite Config Directory
    scf.save_scf             ${ts_conf_dir}/Full_Commissioning_${CB008146-F_SCF}
    Execute full commissioning    gnb_id=0    scf_path=${ts_conf_dir}/Full_Commissioning_${CB008146-F_SCF}

Get Values from SCF
    ${nrarfcn}=  IF           '${CELL_TECHNOLOGY}' == 'TDD'
    ...                     scf.get_value_from_scf         dist_name=NRBTS-1/NRCELL-1                p_name=nrarfcn
    ...          ELSE
    ...                     scf.get_value_from_scf         dist_name=NRBTS-1/NRCELL-1/NRCELL_FDD-1   p_name=nrarfcnDl
    Set Suite Variable       ${nrarfcn}
    ${ssbScs}=               scf.get_value_from_scf        dist_name=NRBTS-1/NRCELL-1                p_name=ssbScs
    Set Suite Variable       ${ssbScs}
    ${freqBandIndicatorNR}=  scf.get_value_from_scf        dist_name=NRBTS-1/NRCELL-1                p_name=freqBandIndicatorNR
    Set Suite Variable       ${freqBandIndicatorNR}
    ${physCellId1}=          scf.get_value_from_scf        dist_name=NRBTS-1/NRCELL-1                p_name=physCellId
    Set Suite Variable       ${physCellId1}
    ${trackingArea}=         scf.get_value_from_scf        p_name=fiveGsTac
    Set Suite Variable       ${trackingArea}


Add NRADJECELL-1 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRADJECELL-1
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRADJECELL     dist_name=${dist_name}             version=${NIDD_VERSION}
    FOR   ${p_name}                         ${value}      IN
    ...   eNodeBId                          ${ENB_ID}
    ...   ePSTrackingAreaCode               ${EPS_TAC}
    ...   iRatDataForwardingMethod          indirectDataFwd
    ...   earfcnValue                       ${MEAS_CFG_1.earfcnValue}
    ...   lcrId                             1
    ...  physCellId                         11
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=eUtraMultibandInfoList
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=eUtraMultibandInfoList   elements=1
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=ecgiPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=ecgiPlmn                 elements=${plmn}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=enbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=enbPlmn                  elements=${plmn}


Add NRADJECELL-2 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRADJECELL-2
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRADJECELL     dist_name=${dist_name}             version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   eNodeBId                      ${ENB_ID}
    ...   ePSTrackingAreaCode           ${EPS_TAC}
    ...   iRatDataForwardingMethod      indirectDataFwd
    ...   earfcnValue                   ${MEAS_CFG_2.earfcnValue}
    ...   lcrId                         2
    ...   physCellId                    11
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=eUtraMultibandInfoList
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=eUtraMultibandInfoList   elements=1
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=ecgiPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=ecgiPlmn                 elements=${plmn}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=enbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=enbPlmn                  elements=${plmn_2}

Add NRHOIR-1 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRHOIR-1
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRHOIR         dist_name=${dist_name}         version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   allowedMeasBandwidth          ${NRHOIR_1.allowedMeasBandwidth}
    ...   b2MeashoEnabled               none
    ...   b2Threshold1hoRsrp            ${NRHOIR_1.b2Threshold1hoRsrp}
    ...   b2Threshold1hoRsrq            ${NRHOIR_1.b2Threshold1hoRsrq}
    ...   earfcnValue                   ${MEAS_CFG_1.earfcnValue}
    ...   presenceAntennaPort1          ${NRHOIR_1.presenceAntennaPort1}
    ...   reportAmount                  ${NRHOIR_1.b2reportAmount}
    ...   reportInterval                ${NRHOIR_1.b2reportInterval}
    ...   widebandRsrqMeas              ${NRHOIR_1.widebandRsrqMeas}
    ...   b1MeasRedirectEnabled         ${NRHOIR_1.b1MeasRedirectEnabled}
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=eutraB2MeashoRsrp
    ${b2MeasRsrp_dict}        Create dictionary         b2HysteresishoRsrp             ${NRHOIR_1.b2HysteresishoRsrp}
    ...                                                 b2Threshold2hoRsrp             ${NRHOIR_1.b2Threshold2hoRsrp}
    ...                                                 b2TimeToTriggerhoRsrp          ${NRHOIR_1.b2TimeToTriggerhoRsrp}
    scf.add_item_to_list      dist_name=${dist_name}    list_name=eutraB2MeashoRsrp    elements=${b2MeasRsrp_dict}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=eutraB2MeashoRsrq
    ${b2MeasRsrq_dict}        Create dictionary         b2HysteresishoRsrq             ${NRHOIR_1.b2HysteresishoRsrq}
    ...                                                 b2Threshold2hoRsrq             ${NRHOIR_1.b2Threshold2hoRsrq}
    ...                                                 b2TimeToTriggerhoRsrq          ${NRHOIR_1.b2TimeToTriggerhoRsrq}
    scf.add_item_to_list      dist_name=${dist_name}    list_name=eutraB2MeashoRsrq    elements=${b2MeasRsrq_dict}

Add NRHOIR-2 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRHOIR-2
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRHOIR         dist_name=${dist_name}         version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   allowedMeasBandwidth          ${NRHOIR_2.allowedMeasBandwidth}
    ...   b2MeashoEnabled               none
    ...   b2Threshold1hoRsrp            ${NRHOIR_2.b2Threshold1hoRsrp}
    ...   b2Threshold1hoRsrq            ${NRHOIR_2.b2Threshold1hoRsrq}
    ...   earfcnValue                   ${MEAS_CFG_2.earfcnValue}
    ...   presenceAntennaPort1          ${NRHOIR_2.presenceAntennaPort1}
    ...   reportAmount                  ${NRHOIR_2.b2reportAmount}
    ...   reportInterval                ${NRHOIR_2.b2reportInterval}
    ...   widebandRsrqMeas              ${NRHOIR_2.widebandRsrqMeas}
    ...   b1MeasRedirectEnabled         ${NRHOIR_2.b1MeasRedirectEnabled}
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=eutraB2MeashoRsrp
    ${b2MeasRsrp_dict}        Create dictionary         b2HysteresishoRsrp             ${NRHOIR_2.b2HysteresishoRsrp}
    ...                                                 b2Threshold2hoRsrp             ${NRHOIR_2.b2Threshold2hoRsrp}
    ...                                                 b2TimeToTriggerhoRsrp          ${NRHOIR_2.b2TimeToTriggerhoRsrp}
    scf.add_item_to_list      dist_name=${dist_name}    list_name=eutraB2MeashoRsrp    elements=${b2MeasRsrp_dict}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=eutraB2MeashoRsrq
    ${b2MeasRsrq_dict}        Create dictionary         b2HysteresishoRsrq             ${NRHOIR_2.b2HysteresishoRsrq}
    ...                                                 b2Threshold2hoRsrq             ${NRHOIR_2.b2Threshold2hoRsrq}
    ...                                                 b2TimeToTriggerhoRsrq          ${NRHOIR_2.b2TimeToTriggerhoRsrq}
    scf.add_item_to_list      dist_name=${dist_name}    list_name=eutraB2MeashoRsrq    elements=${b2MeasRsrq_dict}

Add NRMOPR_NSA to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRMOPR_NSA-1
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRMOPR_NSA     dist_name=${dist_name}         version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   a1MeashoEnabled               none
    ...   a2MeashoEnabled               none
        Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

Update Params in NRCELL
    [Arguments]      ${cell_id}=1
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    not ${mo_exist}   RETURN
    FOR   ${p_name}                     ${value}      IN
    ...   nrDefMoPrNsaDN                MRBTS-1/NRBTS-1/NRMOPR_NSA-1
    ...   nrDefMoPrSaDN                 MRBTS-1/NRBTS-1/NRMOPR_SA-1
    ...   measGapSelectionSA            ${measGapSelectionSA}
    ...   reportAmountSA                ${reportAmountSA}
    ...   reportIntervalSA              ${reportIntervalSA}
    ...   mgta                          ${mgta}
    ...   reportOnLeave                 ${reportOnLeave}
    ...   filterCoeffSsbRsrp            ${filterCoeffSsbRsrp}
    ...   filterCoeffSsbRsrq            ${filterCoeffSsbRsrq}
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
#    ${element_exist}=         scf.is_element_in_object  dist_name=${dist_name}        p_name=mgta
#    IF            not ${element_exist}          scf.add_element_to_scf        dist_name=${dist_name}    p_name=mgta   value=${mgta}
    ${element_exist}=         scf.is_element_in_object  dist_name=${dist_name}        p_name=sMeasConfigSsbRsrp
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf    dist_name=${dist_name}        p_name=sMeasConfigSsbRsrp              value=0
    ${element_exist}=         scf.is_element_in_object  dist_name=${dist_name}        p_name=absThreshSsbRsrpConsolidation
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf    dist_name=${dist_name}        p_name=absThreshSsbRsrpConsolidation   value=1
    ${element_exist}=         scf.is_element_in_object  dist_name=${dist_name}        p_name=sMeasConfigSsbRsrq
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf    dist_name=${dist_name}        p_name=absThreshSsbRsrqConsolidation   value=2

    ${list_name}=             Set Variable              a1MeashoSsbRsrpSA
    ${list_elements}=         Create dictionary         a1HysteresishoSsbRsrpSA       ${a1HysteresishoSsbRsrpSA}
    ...                                                 a1ThresholdhoSsbRsrpSA        ${a1ThresholdhoSsbRsrpSA}
    ...                                                 a1TimeToTriggerhoSsbRsrpSA    ${a1TimeToTriggerhoSsbRsrpSA}
    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}        list_name=${list_name}
    IF            ${list_exist}             scf.remove_list_from_scf      dist_name=${dist_name}        list_name=${list_name}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=${list_name}
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}        elements=${list_elements}

    ${list_name}=             Set Variable              a1MeashoSsbRsrqSA
    ${list_elements}=         Create dictionary         a1HysteresishoSsbRsrqSA       ${a1HysteresishoSsbRsrqSA}
    ...                                                 a1ThresholdhoSsbRsrqSA        ${a1ThresholdhoSsbRsrqSA}
    ...                                                 a1TimeToTriggerhoSsbRsrqSA    ${a1TimeToTriggerhoSsbRsrqSA}
    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}        list_name=${list_name}
    IF            ${list_exist}             scf.remove_list_from_scf      dist_name=${dist_name}        list_name=${list_name}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=${list_name}
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}        elements=${list_elements}

    ${list_name}=             Set Variable              a2MeashoSsbRsrpSA
    ${list_elements}=         Create dictionary         a2HysteresishoSsbRsrpSA       ${A2_MEAS_CFG.a2HysteresishoSsbRsrpSA}
    ...                                                 a2ThresholdhoSsbRsrpSA        ${A2_MEAS_CFG.a2ThresholdhoSsbRsrpSA}
    ...                                                 a2TimeToTriggerhoSsbRsrpSA    ${A2_MEAS_CFG.a2TimeToTriggerhoSsbRsrpSA}
    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}        list_name=${list_name}
    IF            ${list_exist}             scf.remove_list_from_scf      dist_name=${dist_name}        list_name=${list_name}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=${list_name}
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}        elements=${list_elements}

    ${list_name}=             Set Variable              a2MeashoSsbRsrqSA
    ${list_elements}=         Create dictionary         a2HysteresishoSsbRsrqSA       ${A2_MEAS_CFG.a2HysteresishoSsbRsrqSA}
    ...                                                 a2ThresholdhoSsbRsrqSA        ${A2_MEAS_CFG.a2ThresholdhoSsbRsrqSA}
    ...                                                 a2TimeToTriggerhoSsbRsrqSA    ${A2_MEAS_CFG.a2TimeToTriggerhoSsbRsrqSA}
    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}        list_name=${list_name}
    IF            ${list_exist}             scf.remove_list_from_scf      dist_name=${dist_name}        list_name=${list_name}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=${list_name}
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}        elements=${list_elements}

    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}        list_name=a1MeashoSsbRsrp
    IF            not ${list_exist}             Add a1MeashoSsbRsrp to Cell   dist_name=${dist_name}

    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}        list_name=a1MeashoSsbRsrq
    IF            not ${list_exist}             Add a1MeashoSsbRsrq to Cell   dist_name=${dist_name}

    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}        list_name=a2MeashoSsbRsrp
    IF            not ${list_exist}             Add a2MeashoSsbRsrp to Cell   dist_name=${dist_name}

    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}        list_name=a2MeashoSsbRsrq
    IF            not ${list_exist}             Add a2MeashoSsbRsrq to Cell   dist_name=${dist_name}

    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}              list_name=a2MeasRedirectSsbRsrp
    IF            not ${list_exist}             Add a2MeasRedirectSsbRsrp to Cell   dist_name=${dist_name}

    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}              list_name=a2MeasRedirectSsbRsrq
    IF            not ${list_exist}             Add a2MeasRedirectSsbRsrq to Cell   dist_name=${dist_name}

    ${param_list}=            Create List               MRBTS-1/NRBTS-1/NRHOIR-1
    ...                                                 MRBTS-1/NRBTS-1/NRHOIR-2
    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}        list_name=nrhoirDNList
    IF            not ${list_exist}
        scf.add_list_to_scf           dist_name=${dist_name}        list_name=nrhoirDNList
        scf.add_elements_to_list  dist_name=${dist_name}        list_name=nrhoirDNList        elements=${param_list}
    END

    Add NRPLMNSET to SCF      ${cell_id}
    Add A5Meas to Cell        ${cell_id}
    Add A3Meas to Cell        ${cell_id}

Add NRPLMNSET to SCF
    [Arguments]      ${cell_id}=1
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}/NRPLMNSET_NSA-1
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRPLMNSET_NSA      dist_name=${dist_name}        version=${NIDD_VERSION}
    scf.add_element_to_scf    dist_name=${dist_name}        p_name=configuredEpsTac                 value=${EPS_TAC}
    scf.add_element_to_scf    dist_name=${dist_name}        p_name=cellReservedForOperatorUse       value=notReserved
    ${param_list}=            Create List                   MRBTS-1/NRBTS-1/NRPLMN-1
    ${list_exist}=            scf.is_list_in_object         dist_name=${dist_name}        list_name=nrPlmnDNList
    IF            not ${list_exist}
        scf.add_list_to_scf           dist_name=${dist_name}    list_name=nrPlmnDNList
        scf.add_elements_to_list      dist_name=${dist_name}        list_name=nrPlmnDNList    elements=${param_list}
    END

    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}/NRPLMNSET_SA-1
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRPLMNSET_SA      dist_name=${dist_name}         version=${NIDD_VERSION}
    scf.add_element_to_scf    dist_name=${dist_name}       p_name=trackingAreaDN          value=MRBTS-1/NRBTS-1/TRACKINGAREA-${trackingArea}
    scf.add_element_to_scf    dist_name=${dist_name}       p_name=cellReservedForOperatorUse       value=notReserved
    scf.add_element_to_scf    dist_name=${dist_name}       p_name=cellReservedForOperatorUseUacAutoMax       value=notReserved
    ${list_exist}=            scf.is_list_in_object        dist_name=${dist_name}         list_name=nrPlmnDNList
    IF            not ${list_exist}
        scf.add_list_to_scf            dist_name=${dist_name}    list_name=nrPlmnDNList
        scf.add_elements_to_list     dist_name=${dist_name}         list_name=nrPlmnDNList    elements=${param_list}
    END

Add A5Meas to Cell
    [Arguments]      ${cell_id}=1
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}

    ${list_name}=             Set Variable              a5MeasSsbRsrp
    ${a5Meas_rsrp}=           Create dictionary         a5HysteresisSsbRsrp           0
    ...                                                 a5Threshold1SsbRsrp           0
    ...                                                 a5Threshold2SsbRsrp           0
    ...                                                 a5TimeToTriggerSsbRsrp        ms0
    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}        list_name=${list_name}
    IF            not ${list_exist}
        scf.add_list_to_scf           dist_name=${dist_name}   list_name=${list_name}
        scf.add_item_to_list      dist_name=${dist_name}        list_name=${list_name}   elements=${a5Meas_rsrp}
    END

    ${list_name}=             Set Variable              a5MeasSsbRsrq
    ${a5Meas_rsrq}=           Create dictionary         a5HysteresisSsbRsrq           0
    ...                                                 a5Threshold1SsbRsrq           0
    ...                                                 a5Threshold2SsbRsrq           0
    ...                                                 a5TimeToTriggerSsbRsrq        ms0
    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}        list_name=${list_name}
    IF            not ${list_exist}
        scf.add_list_to_scf           dist_name=${dist_name}   list_name=${list_name}
        scf.add_item_to_list      dist_name=${dist_name}        list_name=${list_name}   elements=${a5Meas_rsrq}
    END

Add A3Meas to Cell
    [Arguments]      ${cell_id}=1
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}

    ${list_name}=             Set Variable              a3MeasSsbRsrp
    ${a3Meas_rsrp}=           Create dictionary         a3HysteresisSsbRsrp           0
    ...                                                 a3OffsetSsbRsrp               0
    ...                                                 a3TimeToTriggerSsbRsrp        ms0
    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}        list_name=${list_name}
    IF            not ${list_exist}
        scf.add_list_to_scf           dist_name=${dist_name}   list_name=${list_name}
        scf.add_item_to_list      dist_name=${dist_name}        list_name=${list_name}   elements=${a3Meas_rsrp}
    END

    ${list_name}=             Set Variable              a3MeasSsbRsrq
    ${a3Meas_rsrq}=           Create dictionary         a3HysteresisSsbRsrq           0
    ...                                                 a3OffsetSsbRsrq               0
    ...                                                 a3TimeToTriggerSsbRsrq        ms0
    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}        list_name=${list_name}
    IF            not ${list_exist}
        scf.add_list_to_scf           dist_name=${dist_name}   list_name=${list_name}
        scf.add_item_to_list      dist_name=${dist_name}        list_name=${list_name}   elements=${a3Meas_rsrq}
    END

Add NRRELE-1 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-1/NRRELE-1
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRRELE         dist_name=${dist_name}         version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   cellIndividualOffset          0dB
    ...   eNodeBId                      ${ENB_ID}
    ...   eutranCellExcluded            false
    ...   lcrId                         1
    ...   removeNotAllowed              false
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=ecgiPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=ecgiPlmn             elements=${plmn}

Add NRRELE-2 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-1/NRRELE-2
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRRELE         dist_name=${dist_name}         version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   cellIndividualOffset          0dB
    ...   eNodeBId                      ${ENB_ID}
    ...   eutranCellExcluded            false
    ...   lcrId                         2
    ...   removeNotAllowed              false
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=ecgiPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=ecgiPlmn             elements=${plmn}

Update Params in NRPMRNL
    ${dist_name}=    Set Variable    NRBTS-1/NRPMRNL-1
    scf.modify_scf_element    dist_name=${dist_name}    p_name=miNrNRMOP               value=5min
    scf.modify_scf_element    dist_name=${dist_name}    p_name=miNrRelReportCu         value=5min

Update Params in NRBTS
    [Arguments]    ${actMobilityProfile}=true
    ${dist_name}=    Set Variable    NRBTS-1
    FOR   ${p_name}                     ${value}      IN
    ...   actRanSharing                 true
    ...   actMobilityProfile            ${actMobilityProfile}
    ...   actRedirect                   false
    ...   actNormVCFallback             false
    ...   actEmergencyFallback          true
    ...   actInterRatHoSA               true
    ...   actIntraFreqHoSA              true
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    ${element_exist}=         scf.is_element_in_object  dist_name=${dist_name}         p_name=timerXnDataFwdGuard
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf    dist_name=${dist_name}         p_name=timerXnDataFwdGuard   value=250

Add NRMEASCFG_IR to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRMEASCFG_IR-1
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF  ${mo_exist}
        scf.modify_scf_element    dist_name=${dist_name}    p_name=b2MeashoEnabled          value=${MEAS_CFG_1.b2MeashoEnabled}
        scf.modify_scf_element    dist_name=${dist_name}    p_name=earfcnValue              value=${MEAS_CFG_1.earfcnValue}
        scf.modify_scf_element    dist_name=${dist_name}    p_name=b1MeasRedirectEnabled    value=none
    ELSE
        scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRMEASCFG_IR   dist_name=${dist_name}   version=${NIDD_VERSION}
        scf.add_element_to_scf    dist_name=${dist_name}    p_name=b2MeashoEnabled          value=${MEAS_CFG_1.b2MeashoEnabled}
        scf.add_element_to_scf    dist_name=${dist_name}    p_name=earfcnValue              value=${MEAS_CFG_1.earfcnValue}
        scf.add_element_to_scf    dist_name=${dist_name}    p_name=b1MeasRedirectEnabled    value=none
    END

    ${dist_name}=    Set Variable    NRBTS-1/NRMEASCFG_IR-2
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF  ${mo_exist}
        scf.modify_scf_element    dist_name=${dist_name}    p_name=b2MeashoEnabled          value=${MEAS_CFG_2.b2MeashoEnabled}
        scf.modify_scf_element    dist_name=${dist_name}    p_name=earfcnValue              value=${MEAS_CFG_2.earfcnValue}
        scf.modify_scf_element    dist_name=${dist_name}    p_name=b1MeasRedirectEnabled    value=none
    ELSE
        scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRMEASCFG_IR   dist_name=${dist_name}   version=${NIDD_VERSION}
        scf.add_element_to_scf    dist_name=${dist_name}    p_name=b2MeashoEnabled          value=${MEAS_CFG_2.b2MeashoEnabled}
        scf.add_element_to_scf    dist_name=${dist_name}    p_name=earfcnValue              value=${MEAS_CFG_2.earfcnValue}
        scf.add_element_to_scf    dist_name=${dist_name}    p_name=b1MeasRedirectEnabled    value=none
    END

Add NRMOPRMA_SA to SCF
    [Arguments]    ${nidd_name}=snssaiList
    ${dist_name}=    Set Variable    NRBTS-1/NRMOPRMA_SA-1
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRMOPRMA_SA    dist_name=${dist_name}          version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   mobilityProfilePriority       11
    ...   nrMoPrSaDN                    MRBTS-1/NRBTS-1/NRMOPR_SA-1
        Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=nrPlmnDNList
    ${param_list}=            Create List               MRBTS-1/NRBTS-1/NRPLMN-1
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=nrPlmnDNList          elements=${param_list}

    ${dist_name}=    Set Variable    NRBTS-1/NRMOPRMA_SA-2
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRMOPRMA_SA    dist_name=${dist_name}          version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   mobilityProfilePriority       3
    ...   nrMoPrSaDN                    MRBTS-1/NRBTS-1/NRMOPR_SA-2
        Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    ${snssaiList}             IF  '${nidd_name}'=='snssaiList'
    ...    Create Dictionary         snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
    ...    ELSE    Create List          MRBTS-1/NRBTS-1/SNSSAI-1
    Set New List              dist_name=${dist_name}    list_name=${nidd_name}
    IF  '${nidd_name}'=='snssaiList'
    ...    scf.add_item_to_list      dist_name=${dist_name}    list_name=${nidd_name}    elements=${snssaiList}
    ...    ELSE
    ...    scf.add_elements_to_list  dist_name=${dist_name}    list_name=${nidd_name}    elements=${snssaiList}

    ${dist_name}=    Set Variable    NRBTS-1/NRMOPRMA_SA-3
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRMOPRMA_SA    dist_name=${dist_name}          version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   mobilityProfilePriority       2
    ...   nrMoPrSaDN                    MRBTS-1/NRBTS-1/NRMOPR_SA-3
    ...   rfspIndex                     ${RFSP_INDEX}
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    ${dist_name}=    Set Variable    NRBTS-1/NRMOPRMA_SA-4
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRMOPRMA_SA    dist_name=${dist_name}          version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   mobilityProfilePriority       4
    ...   nrMoPrSaDN                    MRBTS-1/NRBTS-1/NRMOPR_SA-3
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    ${snssaiList}             IF  '${nidd_name}'=='snssaiList'
    ...    Create Dictionary         snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
    ...    ELSE    Create List          MRBTS-1/NRBTS-1/SNSSAI-2
    Set New List              dist_name=${dist_name}    list_name=${nidd_name}
    IF  '${nidd_name}'=='snssaiList'
    ...    scf.add_item_to_list      dist_name=${dist_name}    list_name=${nidd_name}    elements=${snssaiList}
    ...    ELSE
    ...    scf.add_elements_to_list  dist_name=${dist_name}    list_name=${nidd_name}    elements=${snssaiList}

Add NRMOPR_SA to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRMOPR_SA-1
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF   ${mo_exist}  scf.remove_mo_with_descendant_mos  dist_name=${dist_name}
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRMOPR_SA      dist_name=${dist_name}       version=${NIDD_VERSION}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=a1MeashoEnabledSA     value=${MEAS_CFG_1.a1MeashoEnabledSA}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=a2MeashoEnabledSA     value=${MEAS_CFG_1.a2MeashoEnabledSA}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=nrMeasCfgIrDNList
    ${param_list}=            Create List               MRBTS-1/NRBTS-1/NRMEASCFG_IR-1
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=nrMeasCfgIrDNList  elements=${param_list}

    ${dist_name}=    Set Variable    NRBTS-1/NRMOPR_SA-2
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF   ${mo_exist}  scf.remove_mo_with_descendant_mos     dist_name=${dist_name}
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRMOPR_SA      dist_name=${dist_name}       version=${NIDD_VERSION}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=a1MeashoEnabledSA     value=${MEAS_CFG_2.a1MeashoEnabledSA}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=a2MeashoEnabledSA     value=${MEAS_CFG_2.a2MeashoEnabledSA}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=nrMeasCfgIrDNList
    ${param_list}=            Create List               MRBTS-1/NRBTS-1/NRMEASCFG_IR-2
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=nrMeasCfgIrDNList  elements=${param_list}

    ${dist_name}=    Set Variable    NRBTS-1/NRMOPR_SA-3
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF   ${mo_exist}  scf.remove_mo_with_descendant_mos     dist_name=${dist_name}
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRMOPR_SA      dist_name=${dist_name}       version=${NIDD_VERSION}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=a1MeashoEnabledSA     value=rsrp
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=a2MeashoEnabledSA     value=none
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=nrMeasCfgIrDNList
    ${param_list}=            Create List               MRBTS-1/NRBTS-1/NRMEASCFG_IR-2
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=nrMeasCfgIrDNList  elements=${param_list}

Add SNSSAI to SCF
    ${dist_name}=   Set Variable            NRBTS-1/SNSSAI-2
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF  ${mo_exist}  scf.remove_mo_with_descendant_mos     dist_name=${dist_name}
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:SNSSAI         dist_name=${dist_name}       version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   administrativeState           Unlocked
    ...   sd                            13714342
    ...   sst                           1
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=nrPlmnDNList
    ${param_list}=            Create List               MRBTS-1/NRBTS-1/NRPLMN-1
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=nrPlmnDNList       elements=${param_list}

Add SNSSAI to TRACKINGAREA
    [Arguments]    ${nidd_name}=snssaiList
    ${dist_name}=             Set Variable              NRBTS-1/TRACKINGAREA-${trackingArea}
    Set New List              dist_name=${dist_name}    list_name=${nidd_name}
    IF  '${nidd_name}'=='snssaiList'
        ${snssaiList}    Create Dictionary    snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1    snssaiDNLast=MRBTS-1/NRBTS-1/SNSSAI-2
        scf.add_item_to_list      dist_name=${dist_name}    list_name=${nidd_name}    elements=${snssaiList}
    ELSE
        ${snssaiList}    Create List    MRBTS-1/NRBTS-1/SNSSAI-1  MRBTS-1/NRBTS-1/SNSSAI-2
        scf.add_elements_to_list  dist_name=${dist_name}    list_name=${nidd_name}    elements=${snssaiList}
    END

Add NRADJGNB to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRADJGNB-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRADJGNB       dist_name=${dist_name}        version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   administrativeState           Unlocked
    ...   gNbIdLength                   22
    ...   gNodeBId                      38
    ...   xnLinkRef                     1
    ...   gNodeBIdCtrl                  oamControlled
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn             elements=${plmn}

Add NRADJNRCELL to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRADJNRCELL-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRADJNRCELL    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   cellDepType                   SA
    ...   fiveGsTac                     ${trackingArea}
    ...   freqBandIndicatorNR           ${freqBandIndicatorNR}
    ...   gNbId                         38
    ...   gNbIdLength                   22
    ...   lcrId                         1
    ...   nrarfcn                       ${nrarfcn}
    ...   ssbFrequency                  ${NRCELL-1.nrarfcn_gscn}
    ...   physCellId                    48
    ...   cellReservedForOperatorUse    notReserved
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn         elements=${plmn}

Add NRREL to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-1/NRREL-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRREL          dist_name=${dist_name}                version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   cellIndividualSsbRsrpOffset   0dB
    ...   cellIndividualSsbRsrqOffset   0dB
    ...   gNbId                         38
    ...   gNbIdLength                   22
    ...   handoverAllowedSA             allowed
    ...   lcrId                         1
    ...   removeNotAllowed              false
    ...   nrDcAllowed                   false
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn                     elements=${plmn}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=handoverAllowedSARedCap        value=forbidden
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=isRplCellForPSCell             value=false

Add NRREL to Cell
    [Arguments]      ${cell_id}=1
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}/NRREL-3
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    ${nrrel.lcrId}=   Set Variable If    '${cell_id}' == '1'    2    1
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRREL          dist_name=${dist_name}                version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   cellIndividualSsbRsrpOffset   0dB
    ...   cellIndividualSsbRsrqOffset   0dB
    ...   gNbId                         1
    ...   gNbIdLength                   22
    ...   handoverAllowedSA             allowed
    ...   lcrId                         ${nrrel.lcrId}
    ...   removeNotAllowed              false
    ...   nrDcAllowed                   false
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn                     elements=${plmn}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=handoverAllowedSARedCap        value=forbidden
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=isRplCellForPSCell             value=false

Update Params in XNLINK
    ${dist_name}=    Set Variable    NRBTS-1/XNLINK-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF  ${mo_exist}  scf.remove_mo_with_descendant_mos     dist_name=${dist_name}
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:XNLINK             dist_name=${dist_name}  version=${NIDD_VERSION}
    FOR   ${p_name}               ${value}      IN
    ...   cPlaneIpAddr            ${XNIP_simulated_gNB}
    ...   cPlaneIpAddrCtrl        oamControlled
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
