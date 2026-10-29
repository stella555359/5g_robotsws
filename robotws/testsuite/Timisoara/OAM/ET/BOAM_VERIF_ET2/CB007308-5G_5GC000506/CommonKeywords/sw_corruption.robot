*** Settings ***
Library   ./sw_info.py
Library   ./sw_editors.py

Resource  ./sw_package_ops.robot

*** Keywords ***
Get previous CIT software and corrupt it
    [Arguments]  ${admin_connection}=${ADMIN_ALIAS}    ${cloud_token}

    ${full_current_build}                   get_current_build           ${admin_connection}
    ${current_stream}   ${current_build}    extract stream and build    ${full_current_build}

    ${cit_names}                            get_cit_build_names         ${current_stream}
    ...                                                                 ${cloud_token}

    ${previous_cit_name}                    get previous build name     ${cit_names}
    ...                                                                 ${current_build}

    ${sw_zip}                               Download software package   ${previous_cit_name}
    ...                                                                 testsuite/OAM/Wroclaw/cOAM/smieci/sw_packages/

    ${sw}    Unzip SW package  ${sw_zip}
    Delete SW package  ${sw_zip}
    corrupt software  ${sw}
    ${corrupted_sw_pack}  Zip SW package  ${sw}
    Delete unzipped SW package  ${sw}

    [Return]  ${corrupted_sw_pack}
