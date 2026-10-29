*** Settings ***
Documentation    Commissioning keywords for CB011006 B13



*** Keywords ***

#-----------For swconfig.txt Changes-------------------------------------------------------------------------------------------------[150 characters]
Change RD Parameters in swconfig File for IWK13
    @{rd_params}=  create list
    ...    0x890057=0   # enables intra_gNB NRDC in all cells
    Update SW Config file on System Module  param_list=${rd_params}

Send measurement report for NRDC initialization
    sleep    1
    ${command}   Set Variable   ue_measurement_send_nr id=1 meas_id=1 phycell_id=52 nrsrp_nr=60 event=A4
    Send Egate Command and verify output   cmd=${command}
    sleep    1

Initial commissioning for IWK13
    # create the NRDC parameter list, which is not available in a fresh TL SCF
    # ulDataPathNrDc is the only parameter differing from the default values, so that UL tput is transmitted via (secondary) TDD cell
    ${distName_NRDRB}=    set variable    MRBTS-1/NRBTS-1/NRDRB-11

    Set List      dist_name=${distName_NRDRB}  list_name=nrDcDrbParam
    ${nrDcDrbParam_list}=  create dictionary
    ...    actPrioXxAfterInactNrDc          false
    ...    actXxDuplicateTxNrDc             false
    ...    dlDataSplitBufBldUpThreshNrDc    5
    ...    dlDataSplitGainThresholdNrDc     5
    ...    dlDataSplitModeNrDc              dlOverF1UXxU
    ...    dlNumOfCongOrGainDddsNrDc        2
    ...    dlPreferredPathNrDc              Primary
    ...    dlSplitBufBldUpThresPrioXxNrDc   5
    ...    inactThreshForPrioXxNrDc         300
    ...    inactThreshForRstPrioXxNrDc      100
    ...    initialDLTrafficRoutingNrDc      initDLoverPrimary
    ...    prioritizeXxPeriodNrDc           500
    ...    ulDataPathNrDc                   ulOverSCG
    ...    ulDataSplitThresholdNrDc         infinity
    scf.add_item_to_list    dist_name=${distName_NRDRB}   list_name=nrDcDrbParam   elements=${nrDcDrbParam_list}