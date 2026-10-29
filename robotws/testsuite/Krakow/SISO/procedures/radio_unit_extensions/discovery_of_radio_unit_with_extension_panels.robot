*** Settings ***

Resource    taf/rfrl/bts/robot/gnb.robot

*** Variables ***


*** Keywords ***
Discovery of radio unit with extension panels
    Get and Save DHCP Configuration Dict
    Verify Connection to All Radio Units   ${dhcp_dict}
    Get and Save Numer of Ru and Extension Modules
    Verify Object Exists In Configuration   object_name=RMOD_R    number_of_objects=${number_of_ru}
    Verify Object Exists In Configuration   object_name=LOGLINK_R    number_of_objects=${number_of_ru_ext}

Get and Save DHCP Configuration Dict
    ${dhcp_dict} =      Get DHCP Config For All Radio Units
    Set Test Variable   ${dhcp_dict}

Get and Save Numer of Ru and Extension Modules
    ${number_of_ru_ext} =   Get Count Of Radio Extension Modules
    Set Test Variable   ${number_of_ru_ext}
    ${number_of_ru} =   Get Count Of Radios
    ${number_of_ru} =   Evaluate  ${number_of_ru}+${number_of_ru_ext}
    Set Test Variable   ${number_of_ru}

Preconditions
    Verify All Radio Module Status
    Verify Setup Of All Cells
    Verify gNB is onAir
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}

Postconditions
    Verify Setup Of All Cells
    Verify gNB is onAir
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}
