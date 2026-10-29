import re
from statistics import mean, median


def parse_aashell_sysinfo_command_output(
    command_output: str,
    alias: str = "default"
) -> dict[str, int | float | str | None]:
    """
    Parse output of SysInfo command executed in Aashell on BTS.

    Parameters
    ----------
    command_output : str
        Output from Aashell `sysinfo -s` command.
        Example format:
        ```
        time stamp;Parameter1 [kB] (Total: 1000);Parameter2 [s];
        2023-01-01T00:00:00Z;500;123;
        ```
    alias : str
        Alias name for identifying measurement. Defaults to 'default'.

    Returns
    -------
    dict
        Parsed system information with parameters and their values.

    Example
    -------
    >>> input_str = '''time stamp;System Memory [kB] (Total: 1000);Uptime [s];
    ... 2023-01-01T00:00:00Z;500;123;'''
    >>> result = parse_aashell_sysinfo_command_output(input_str, "test")
    >>> print(result['System Memory'].current)
    500
    """
    delimeter = ";"
    timestamp_key = "time stamp"
    parsed_params = {}

    if not command_output or not isinstance(command_output, str):
        return {}
    lines = [line for line in command_output.strip().split("\n") if line]
    headers = lines[0].rstrip(delimeter).split(delimeter)
    values = lines[1].rstrip(delimeter).split(delimeter)
    result = {h: v for h, v in zip(headers, values)}
    timestamp = result.pop(timestamp_key)
    for column_name, value in result.items():
        param_name, param_data = _parse_parameter(column_name, value)
        parsed_params.update({param_name: param_data})
    parsed_params.update({"alias": alias, "timestamp": timestamp})

    return parsed_params


def _parse_parameter(
    column_name: str,
    value: str
) -> tuple[str, dict[str, int | float | str | None]]:
    """
    Parse a single system parameter.

    Parameters
    ----------
    column_name : str
        The name of the parameter column.
    value : str
        The value of the parameter.

    Returns
    -------
    Tuple[str, dict]
        A tuple containing the cleaned parameter name and its parsed values.
    """
    total_pattern = r'Total:\s*(\d+)'
    unit_pattern = r'\[(.*?)\]'
    column_name_pattern = r'^(.*?)\['

    total_match = re.search(total_pattern, column_name)
    total_value = int(total_match.group(1)) if total_match else None
    unit_match = re.search(unit_pattern, column_name)
    unit = unit_match.group(1) if unit_match else None
    name_match = re.match(column_name_pattern, column_name)
    clean_name = (name_match.group(1) if name_match else column_name.split('[')[0]).strip()
    current_value = int(value)
    ratio = (round(current_value / total_value, 4) if total_value is not None else None)

    return clean_name, {
        "current": current_value,
        "total": total_value,
        "ratio": ratio,
        "unit": unit,
        }


def analyze_parameter_history(
    parsed_outputs: list[dict],
    parameter_name: str,
    value_type: str = "current",
    alias: str = "default",
    last_n: int | None = None
) -> dict[str, float | int | str | None] | None:
    """
    Analyze historical data for a specific parameter and its value type from multiple executions.

    Parameters
    ----------
    parsed_outputs : list[dict]
        List of parsed outputs from parse_aashell_sysinfo_command_output function
    parameter_name : str
        Name of the parameter to analyze
    value_type : str
        Type of value to analyze. Can be 'current', 'total', or 'ratio'. Defaults to 'current'
    alias : str
        Alias to filter the data by. Defaults to "default"
    last_n : int | None
        Number of last values to analyze. If None, analyzes all values.
        If last_n is greater than available values, all values will be analyzed.

    Returns
    -------
    dict[str, float | int | str | None] | None
        Dictionary containing statistical measures or None if no data found.
        Keys: 'average', 'median', 'min', 'max', 'unit'
        Note: 'average' value is rounded to 4 decimal places

    Example
    -------
    >>> history = [
    ...     {'System Memory': {'current': 500, 'total': 1000, 'ratio': 0.5, 'unit': 'kB'}, 'alias': 'test'},
    ...     {'System Memory': {'current': 600, 'total': 1000, 'ratio': 0.6, 'unit': 'kB'}, 'alias': 'test'}
    ... ]
    >>> # Analyze current values
    >>> stats = analyze_parameter_history(history, "System Memory", "current", "test")
    >>> print(f"Average current: {stats['average']}")
    Average current: 550.0
    >>> # Analyze ratio values
    >>> stats = analyze_parameter_history(history, "System Memory", "ratio", "test")
    >>> print(f"Average ratio: {stats['average']}")
    Average ratio: 0.55
    """
    values = []

    if not parsed_outputs or value_type not in {"current", "total", "ratio"}:
        return None

    for output in parsed_outputs:
        if output.get("alias") == alias and parameter_name in output:
            param_data = output[parameter_name]
            if isinstance(param_data, dict) and value_type in param_data:
                value = param_data[value_type]
                if value is not None:
                    values.append(value)
            unit = param_data.get("unit", None)

    if not values:
        return None

    if last_n is not None:
        values = values[-last_n:]

    return {
        "average": round(mean(values), 4),
        "median": round(median(values), 4),
        "min": min(values),
        "max": max(values),
        "unit": unit
    }
