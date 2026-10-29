*** Settings ***
Documentation
...   Resources for regression testing of feature CB013999
...   author: Marek Szłapa
...   contact: marek.szlapa@nokia.com

Library      taf.rfrl.utilities.logger.custom_logger    WITH NAME    logger
Library      testsuite/Krakow/resources/delta/bts_delta_generator.py
Resource     taf/rfrl/bts/robot/gnb.robot
Variables    ./variables.py


*** Keywords ***
Perform SA L3 Call on all cells
    [Arguments]     ${deviation}=40%
    FOR    ${cell_info}    IN    @{cells_info}
        ${current_cell}=    Create List    ${cell_info}[nrcell_id]
        logger.log_info_to_console  Setting cell ${current_cell} to notBarred
        Set Cells To notBarred      ${current_cell}
        logger.log_info_to_console  Ongoing call on cell ${current_cell}
        Run Keyword And Continue On Failure     Verify L3 Call Data Transfer DL&UL
        ...                                     protocol=tcp
        ...                                     duration=120s
        ...                                     deviation=${deviation}
        ...                                     tput_dl=${cell_info}[tput_dl]
        ...                                     tput_ul=${cell_info}[tput_ul]
        ...                                     parallel_streams_ul=${cell_info}[parallel_streams_ul]
        ...                                     parallel_streams_dl=${cell_info}[parallel_streams_dl]
        logger.log_info_to_console  Setting cell ${current_cell} to Barred
        Set Cells To Barred         ${current_cell}
    END

Set Cells To Barred
    [Arguments]     ${cells}
    ${delta}  Generate Delta for barred NRCELLs     cells=${cells}
    gnbscf.Perform Bts Delta Commissioning          delta=${delta}

Set Cells To notBarred
    [Arguments]     ${cells}
    ${delta}  Generate Delta for not barred NRCELLs    cells=${cells}
    gnbscf.Perform Bts Delta Commissioning          delta=${delta}

Common Preconditions With Watching Alarms and cells set to Barred
    Common Preconditions With Watching Alarms
    ${cells}         gnbcell.get_all_cells_id
    @{cells_list}    Evaluate    [cell for cell in ${cells}]
    ${delta}         Generate Delta for barred NRCELLs    cells=${cells_list}
    logger.log_info_to_console    Setting all cells to Barred
    gnbscf.Perform Bts Delta Commissioning    delta=${delta}
    Require Ue for L3 Call

Common Postconditions With Watching Alarms and cells set to notBarred
    Common Postconditions With Watching Alarms
    ${cells}         gnbcell.get_all_cells_id
    @{cells_list}    Evaluate    [cell for cell in ${cells}]
    ${delta}         Generate Delta for not barred NRCELLs    cells=${cells_list}
    logger.log_info_to_console    Setting all cells to notBarred
    gnbscf.Perform Bts Delta Commissioning    delta=${delta}
