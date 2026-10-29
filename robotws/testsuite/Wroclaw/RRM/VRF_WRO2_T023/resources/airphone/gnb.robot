*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Palina Krasnova
...              :contact: palina.krasnova@nokia.com
...              This resources contains keywords related to gnb environment configuration

Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/Downloader.py
Library    ta5g_commissioning
Library    ta5g_scfc_analysis


*** Keywords ***
Install Bsr Package
    [Documentation]
    ...    Downloads BSR file from specified artifactory and installs the BSR package
    ...
    ...    | **Author:** palina.krasnova@nokia.com
    ...
    ...    **Input Parameters:**
    ...
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | Parameter              | Man.  | Description                                                          |
    ...    +========================+======+=======================================================================+
    ...    | bsr_file_path          | Yes   | Artifactory path to the BSR file.                                    |
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | target_file_path       | Yes   | Path where the BSR file will be copied.                              |
    ...    +------------------------+------+-----------------------------------------------------------------------+

    [Arguments]    ${bsr_file_path}    ${target_file_path}
    Downloader    url=${bsr_file_path}    download_path=${target_file_path}
    coam.Setup Admin
    ${ret}=    coam.Update Software    sw_package=${target_file_path}
    [Teardown]    Run Keywords    coam.Teardown Admin    AND
    ...                           Remove File    path=${target_file_path}

Save Initial SCF And Apply Delta
    [Documentation]
    ...  KW saves initial full SCF, applies delta SCF and saves full changed SCF.
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Full description:**
    ...
    ...  KW saves initial SCF and sets its path to the test variable.
    ...  Then it searches for delta file under current software branch folder, applies the found delta and saves changed SCF.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | delta                  | Yes  | Delta filename, stored in branch named folder.                        |
    ...  |                        |      | Example path to the delta:                                            |
    ...  |                        |      | ${TEST_SUITE_DIR}/config/SBTS26R2/cb013025_b_iwk1_delta.json          |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Save Initial SCF And Apply Delta  delta=cb013025_b_iwk1_delta.json

    [Arguments]    ${delta}
    ${initial_scfc_path}=    Get Latest Scfc    output_filename=initial_scfc.xml
    Set Test Variable    ${initial_scfc_path}    ${INITIAL_SCFC_PATH}
    Find Scfc And Send Delta Commissioning    scfc_filename=${delta}
    Get Latest Scfc    output_filename=updated_scfc.xml
