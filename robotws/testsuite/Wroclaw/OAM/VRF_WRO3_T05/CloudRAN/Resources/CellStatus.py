"""
This module provides utility functions to validate the operational state of cells in a network.

Functions:
- all_cells_should_be_enabled(summary: dict): Verifies that all cells are in the 'enabled' state.
- at_least_one_cell_should_be_disabled(summary: dict): Ensures at least one cell is in the 'disabled' state.
- assert_cell_operational_state(cell_list, cell_id, expected_operational_state): Validates the operational
  state of a specific cell.

History of changes:
    01.06.2025 - Initial creation
Author: lukasz.lechowicz@nokia.com
"""


def all_cells_should_be_enabled(summary: dict):
    """
    Verifies that all cells in the network are in the 'enabled' state.

    Args:
        summary (dict): A dictionary containing the operational state summary of cells.
        For input take a result from taf.gnb.oam.coam.cu.Get Cells Summary or
        taf.gnb.oam.coam.vdu.Get Cells Summary.

    Raises:
        AssertionError: If any cell is in the 'disabled' state or no cells are in the 'enabled' state.
    """
    operational_state = summary.get('basic_cells_summary', {}).get('operational_state', {})

    disabled_count = operational_state.get('disabled', 0)
    enabled_count = operational_state.get('enabled', 0)

    if disabled_count == 0 and enabled_count > 0:
        return

    raise AssertionError(
        f"{disabled_count} NRCELLs are in 'disabled' state, "
        f"{enabled_count} NRCELLs are in 'enabled' state."
    )


def all_cells_should_be_disabled(summary: dict):
    """
    Verifies that all cells in the network are in the 'disabled' state.

    Args:
        summary (dict): A dictionary containing the operational state summary of cells.
        For input take a result from taf.gnb.oam.coam.cu.Get Cells Summary or
        taf.gnb.oam.coam.vdu.Get Cells Summary.

    Raises:
        AssertionError: If any cell is in the 'enabled' state or no cells are in the 'disabled' state.
    """
    operational_state = summary.get('basic_cells_summary', {}).get('operational_state', {})

    enabled_count = operational_state.get('enabled', 0)
    disabled_count = operational_state.get('disabled', 0)

    if enabled_count == 0 and disabled_count > 0:
        return

    raise AssertionError(
        f"{enabled_count} NRCELLs are in 'enabled' state, "
        f"{disabled_count} NRCELLs are in 'disabled' state."
    )


def at_least_one_cell_should_be_disabled(summary: dict):
    """
    Ensures that at least one cell in the network is in the 'disabled' state.

    Args:
        summary (dict): A dictionary containing the operational state summary of cells.
        For input take a result from taf.gnb.oam.coam.cu.Get Cells Summary or
        taf.gnb.oam.coam.vdu.Get Cells Summary.

    Raises:
        AssertionError: If no cells are in the 'disabled' state.
    """
    operational_state = summary.get('basic_cells_summary', {}).get('operational_state', {})
    disabled_count = operational_state.get('disabled', 0)
    enabled_count = operational_state.get('enabled', 'unknown')

    if disabled_count == 0:
        raise AssertionError(
            f"{disabled_count} NRCELLs are in 'disabled' state, "
            f"{enabled_count} NRCELLs are in 'enabled' state."
        )


def at_least_one_cell_should_be_enabled(summary: dict):
    """
    Ensures that at least one cell in the network is in the 'enabled' state.

    Args:
        summary (dict): A dictionary containing the operational state summary of cells.
        For input take a result from taf.gnb.oam.coam.cu.Get Cells Summary or
        taf.gnb.oam.coam.vdu.Get Cells Summary.

    Raises:
        AssertionError: If no cells are in the 'enabled' state.
    """
    operational_state = summary.get('basic_cells_summary', {}).get('operational_state', {})
    enabled_count = operational_state.get('enabled', 0)
    disabled_count = operational_state.get('disabled', 'unknown')

    if enabled_count == 0:
        raise AssertionError(
            f"{enabled_count} NRCELLs are in 'enabled' state, "
            f"{disabled_count} NRCELLs are in 'disabled' state."
        )


def assert_cell_operational_state(cell_list: list, cell_id: str, expected_operational_state: str):
    """
    Validates the operational state of a specific cell.

    Args:
        cell_list (list): A list of dictionaries representing cell information.
            For input take a result from taf.gnb.oam.coam.cu.Get Cells Statuses or
            taf.gnb.oam.coam.vdu.Get Cells Statuses.
        cell_id (str): The ID of the cell to validate.
        expected_operational_state (str): The expected operational state of the cell.
            expected_operational_state can be 'enabled' or 'disabled'.

    Raises:
        AssertionError: If the cell's operational state does not match the expected state.
        ValueError: If the cell with the given ID is not found in the list.
    """
    for cell in cell_list:
        if str(cell.get("id")) == str(cell_id):
            actual_state = cell.get("operational_state")
            if actual_state != expected_operational_state:
                raise AssertionError(
                    f"NRCELL ID: {cell_id} has operational_state = '{actual_state}', "
                    f"expected operational_state: '{expected_operational_state}'"
                )
            break
    else:
        raise ValueError(f"Cell ID: {cell_id} not found")
