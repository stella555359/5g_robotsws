*** Settings ***

Documentation
...   author: Sebastian Mikos
...   contact: sebastian.mikos@nokia.com
...   Description: Test Cases Emil decode confirmation

Library     Emil_processing_keywords.py

*** Variables ***
${emil_log_path}       C:\\robot_script\\
${end_file}=           ${NONE}

*** Test Cases ***
Emil_decode_output_containing_msg_id_with_message_names_as_NA
    ${output_dir}    Extract Msg Id With Msg Name As NA    ${emil_log_path}    ${end_file}
    ${decoded_msg_id_with_msg_name_as_NA}    Get Emil Msg from CSV    ${emil_log_path}
    Should Not Be Empty    ${decoded_msg_id_with_msg_name_as_NA}
