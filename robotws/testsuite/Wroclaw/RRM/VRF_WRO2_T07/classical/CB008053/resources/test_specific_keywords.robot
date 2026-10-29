*** Settings ***
Documentation
...   Test keywords for 5GC008053

Library        DateTime


*** Keywords ***
Get Logging Start Time
    ${logging_start_date} =  Get Current Date
    Set Global Variable  ${LOGGING_START_DATE}  ${logging_start_date}


Get Logging Stop Time
    ${logging_stop_date} =  Get Current Date
    Set Global Variable  ${LOGGING_STOP_DATE}  ${logging_stop_date}


Get 1st Call Setup Time
    ${call_1_setup_date} =  Get Current Date
    Set Global Variable  ${SETUP_1_DATE}  ${call_1_setup_date}


Get 1st Call Stop Time
    ${call_1_stop_date} =  Get Current Date
    Set Global Variable  ${STOP_1_DATE}  ${call_1_stop_date}


Get 2nd Call Setup Time
    ${call_2_setup_date} =  Get Current Date
    Set Global Variable  ${SETUP_2_DATE}  ${call_2_setup_date}


Get 2nd Call Stop Time
    ${call_2_stop_date} =  Get Current Date
    Set Global Variable  ${STOP_2_DATE}  ${call_2_stop_date}


Get 3rd Call Setup Time
    ${call_3_setup_date} =  Get Current Date
    Set Global Variable  ${SETUP_3_DATE}  ${call_3_setup_date}


Get 3rd Call Stop Time
    ${call_3_stop_date} =  Get Current Date
    Set Global Variable  ${STOP_3_DATE}  ${call_3_stop_date}


Get Omit Before 1st Call
    ${omit_before_1_call} =  Subtract Date From Date  ${SETUP_1_DATE}   ${LOGGING_START_DATE}
    ${omit_before_1_call}  Evaluate  int(__import__('math').ceil( ${omit_before_1_call} ))
    Set Global Variable  ${OMIT_BEFORE_1_CALL}  ${omit_before_1_call}
    log  OMIT_BEFORE_1_CALL: ${OMIT_BEFORE_1_CALL}  console=True


Get End After 1st Call
    ${end_after_1_call} =  Subtract Date From Date  ${STOP_1_DATE}   ${LOGGING_START_DATE}
    ${end_after_1_call}  Evaluate  int(__import__('math').ceil( ${end_after_1_call} ))
    Set Global Variable  ${END_AFTER_1_CALL}  ${end_after_1_call}
    log  END_AFTER_1_CALL: ${END_AFTER_1_CALL}  console=True


Get Omit Before 2nd Call
    ${omit_before_2_call} =  Subtract Date From Date  ${SETUP_2_DATE}   ${LOGGING_START_DATE}
    ${omit_before_2_call}  Evaluate  int(__import__('math').ceil( ${omit_before_2_call} ))
    Set Global Variable  ${OMIT_BEFORE_2_CALL}  ${omit_before_2_call}
    log  OMIT_BEFORE_2_CALL: ${OMIT_BEFORE_2_CALL}  console=True


Get End After 2nd Call
    ${end_after_2_call} =  Subtract Date From Date  ${STOP_2_DATE}   ${LOGGING_START_DATE}
    ${end_after_2_call}  Evaluate  int(__import__('math').ceil( ${end_after_2_call} ))
    Set Global Variable  ${END_AFTER_2_CALL}  ${end_after_2_call}
    log  END_AFTER_2_CALL: ${END_AFTER_2_CALL}  console=True


Get Omit Before 3rd Call
    ${omit_before_3_call} =  Subtract Date From Date  ${SETUP_3_DATE}   ${LOGGING_START_DATE}
    ${omit_before_3_call}  Evaluate  int(__import__('math').ceil( ${omit_before_3_call} ))
    Set Global Variable  ${OMIT_BEFORE_3_CALL}  ${omit_before_3_call}
    log  OMIT_BEFORE_3_CALL: ${OMIT_BEFORE_3_CALL}  console=True


Get End After 3rd Call
    ${end_after_3_call} =  Subtract Date From Date  ${STOP_3_DATE}   ${LOGGING_START_DATE}
    ${end_after_3_call}  Evaluate  int(__import__('math').ceil( ${end_after_3_call} ))
    Set Global Variable  ${END_AFTER_3_CALL}  ${end_after_3_call}
    log  END_AFTER_3_CALL: ${END_AFTER_3_CALL}  console=True


Get 1st Call Duration
    ${call_1_duration} =  Subtract Date From Date  ${STOP_1_DATE}   ${SETUP_1_DATE}
    Set Global Variable  ${CALL_1_DURATION}  ${call_1_duration}
    log  CALL_1_DURATION: ${CALL_1_DURATION}  console=True
    ${CALL_1_DURATION}  Evaluate  int(__import__('math').ceil( ${CALL_1_DURATION} ))
    log  CALL_1_DURATION: ${CALL_1_DURATION}  console=True


Get 2nd Call Duration
    ${call_2_duration} =  Subtract Date From Date  ${STOP_2_DATE}   ${SETUP_2_DATE}
    Set Global Variable  ${CALL_2_DURATION}  ${call_2_duration}
    log  CALL_2_DURATION: ${CALL_2_DURATION}  console=True
    ${CALL_2_DURATION}  Evaluate  int(__import__('math').ceil( ${CALL_2_DURATION} ))
    log  CALL_2_DURATION: ${CALL_2_DURATION}  console=True


Get 3rd Call Duration
    ${call_3_duration} =  Subtract Date From Date  ${STOP_3_DATE}   ${SETUP_3_DATE}
    Set Global Variable  ${CALL_3_DURATION}  ${call_3_duration}
    log  CALL_3_DURATION: ${CALL_3_DURATION}  console=True
    ${CALL_3_DURATION}  Evaluate  int(__import__('math').ceil( ${CALL_3_DURATION} ))
    log  CALL_3_DURATION: ${CALL_3_DURATION}  console=True
