"""
Delta file generator.

:copyright: Nokia Networks
:author: Rafal Kawa
:contact: rafal.kawa@nokia.com
:maintainer: rafal.kawa@nokia.com
"""


def generate_base_delta(dist_name: str, parameter_name: str, value: str or list, operation: str = 'update'):
    """
    Generates a base delta dictionary for a given parameter.

    Args:
        dist_name (str): The distinguished name of the entity.
        parameter_name (str): The name of the parameter to be updated.
        value (str or list): The value of the parameter. Can be a string or a list.
        operation (str, optional): The operation to be performed. Defaults to 'update'.

    Returns:
        dict: A dictionary representing the base delta.
    """
    return {
        "distName": dist_name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": parameter_name,
                "value": value,
                "operation": operation
            }
        ]
    }


def generate_param_delta_for_multiple_cells(nrbts_dist_name: str, cell_start: int, cell_end: int, param_name: str,
                                            value: str or list, operation: str = 'update'):
    """
    Generates a list of delta dictionaries for multiple cells.

    Args:
        nrbts_dist_name (str): The distinguished name of the NR BTS.
        cell_start (int): The starting cell ID.
        cell_end (int): The ending cell ID.
        param_name (str): The name of the parameter to be updated.
        value (str or list): The value of the parameter. Can be a string or a list.
        operation (str, optional): The operation to be performed. Defaults to 'update'.

    Returns:
        list: A list of dictionaries representing the deltas for the specified cells.
    """
    deltas = []
    for cell_id in range(cell_start, cell_end + 1):
        _cell_dist_name = f'{nrbts_dist_name}/NRCELL-{cell_id}'
        deltas.append(generate_base_delta(_cell_dist_name, param_name, value, operation))
    return deltas
