*** Settings ***
Documentation   Author:     Jakub Aniszewski
...             Contact:    jakub.aniszewski@nokia.com
...
...             This module helps to get around robotws repository restictions
...             concerning storing binary files (e.g. PCAP or certficate files).
...             `Generate Binary File From HEX String` can be used to create
...             binary file from HEX string at test runtime.
...
...             To prepare HEX String based on original binary file use
...             `binary_file_converter.py` script.
...
...             EXAMPLE:
...                 python testsuite/Wroclaw/TRS/common_resources/binary_files/binary_file_converter.py
...                     -o output/hex_string_file/directory binary_file.bin

Library         ./binary_file_converter.py

*** Keywords ***
Generate Binary File From HEX String
    [Arguments]             ${hex_string_file}     ${binary_file_name}

    Generate Binary File    hex_string_file_name=${hex_string_file}
    ...                     binary_file_name=${binary_file_name}

Generate HEX file from PEM file
    [Arguments]             ${input_file_name}           ${hex_string_file_name}
    #In first argument you should provide the path to file with cert,
    #in the second argument you should provide only path - the file was created automatically.
    Convert To Hex String   file_name=${input_file_name}
    ...                     output_directory=${hex_string_file_name}
