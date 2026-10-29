import re
import os
from datetime import datetime
import pytz
import json
import operator


def to_int(value):
    if isinstance(value, int):
        return value
    if isinstance(value, str):
        try:
            return int(value)
        except ValueError:
            pass  # Handle or log error if needed
    # Optionally handle other types or raise an error
    raise TypeError(f"Cannot convert {type(value)} to int")


def _compare_values(*args, ops):
    """
    Compare two or three numeric values using the specified operation(s).

    Args:
        *args: Two or three numeric values (int or float).
        ops (str or list): A string (e.g., '>', '>=', '==') or a list of two strings
        for double comparison (e.g., ['<', '<']).

    Returns:
        bool: Result of the comparison.

    Examples:
        compare_values(5, 3, ops='>')           # True
        compare_values(2, 2, ops='==')          # True
        compare_values(1, 2, 3, ops=['<', '<']) # True (1 < 2 < 3)
        compare_values(5, 5, 10, ops=['>=', '<']) # True (5 >= 5 < 10)
    """

    op_map = {
        '>': operator.gt,
        '>=': operator.ge,
        '<': operator.lt,
        '<=': operator.le,
        '==': operator.eq,
        '!=': operator.ne
    }

    if isinstance(ops, str):
        if len(args) != 2:
            raise ValueError("Single operation requires exactly 2 values.")
        return op_map[ops](args[0], args[1])
    elif isinstance(ops, (list, tuple)) and len(ops) == 2:
        if len(args) != 3:
            raise ValueError("Double operation requires exactly 3 values.")
        return op_map[ops[0]](args[0], args[1]) and op_map[ops[1]](args[1], args[2])
    else:
        raise ValueError("Invalid ops argument. Use a string for single or a list/tuple of two "
                         "strings for double comparison.")


def eval_comparison(*args) -> list:
    """
    Evaluate multiple comparison sentences with mathematical expressions.

    Args:
        *args: Each argument is a comparison string (e.g., '3 > 2', '3 <= 3*(2+1) <= 10').

    Returns:
        list: List of boolean results for each comparison.
    """
    results = []

    for sentence in args:
        try:
            # Pattern to match comparison operators
            comparison_pattern = r'(<=|>=|==|!=|<|>)'

            # Split by comparison operators while keeping the operators
            parts = re.split(comparison_pattern, sentence)

            # Remove empty strings and strip whitespace
            parts = [part.strip() for part in parts if part.strip()]

            # Separate expressions and operators
            expressions = []
            operators = []

            for i, part in enumerate(parts):
                if re.match(comparison_pattern, part):
                    operators.append(part)
                else:
                    expressions.append(part)

            print(f"Original: {sentence}")
            print(f"Expressions: {expressions}")
            print(f"Operators: {operators}")

            # Evaluate each mathematical expression safely
            evaluated_values = []
            for expr in expressions:
                try:
                    # Use eval with restricted globals for safety
                    safe_dict = {"__builtins__": {}}
                    # Allow only basic math operations and functions
                    safe_dict.update({
                        'abs': abs, 'min': min, 'max': max, 'round': round,
                        'pow': pow, 'sum': sum
                    })
                    value = eval(expr, safe_dict)
                    evaluated_values.append(value)
                except Exception as e:
                    raise ValueError(f"Invalid expression '{expr}': {e}")

            print(f"Evaluated values: {evaluated_values}")

            # Perform comparisons
            if len(evaluated_values) == 2 and len(operators) == 1:
                result = _compare_values(evaluated_values[0], evaluated_values[1], ops=operators[0])
            elif len(evaluated_values) == 3 and len(operators) == 2:
                result = _compare_values(evaluated_values[0], evaluated_values[1],
                                         evaluated_values[2], ops=operators)
            else:
                raise ValueError(f"Unsupported comparison format: {sentence}")

            print(f"Result: {result}")
            results.append(result)

        except Exception as e:
            print(f"Error evaluating '{sentence}': {e}")
            results.append(False)

    return results


def _timestamp_to_int(timestamp):
    dt_obj = datetime.fromisoformat(timestamp)
    return int(dt_obj.timestamp())


def get_current_utc_time():
    formatted = datetime.now(pytz.utc).strftime('%Y-%m-%d %H:%M:%S%z')
    # Insert colon in timezone for '+00:00' format
    if formatted.endswith('+0000'):
        formatted = formatted[:-5] + '+00:00'
    return formatted


def in_range(x, ops):
    numbers = ops.split('-')
    if len(ops) != 2:
        raise ValueError("In range operation requires exactly 2 values.")
    numbers = [float(t) if '.' in t else int(t) for t in numbers if t]
    return operator.ge(x, numbers[0]) and operator.le(x, numbers[1])


def save_in_json_file(data, file_path: str) -> bool:
    """
    Save data to a JSON file with error handling.

    Args:
        data: Data to be saved to JSON file.
        file_path (str): Path where the JSON file will be saved.

    Returns:
        bool: True if successful, False otherwise.

    Raises:
        TypeError: If data is not JSON serializable.
        PermissionError: If there are insufficient permissions to write the file.
        OSError: If there are issues with the file system (disk full, invalid path, etc.).
        Exception: For any other unexpected errors.
    """
    try:
        # Create directory if it doesn't exist
        directory = os.path.dirname(file_path)
        if directory and not os.path.exists(directory):
            os.makedirs(directory)

        with open(file_path, "w", encoding='utf-8') as f:
            json.dump(data, f, indent=4)

        print(f"Data successfully saved to: {file_path}")
        return True

    except TypeError as e:
        print(f"Error: Data is not JSON serializable: {e}")
        raise
    except PermissionError as e:
        print(f"Error: Permission denied to write file '{file_path}': {e}")
        raise
    except OSError as e:
        print(f"Error: File system error while writing to '{file_path}': {e}")
        raise
    except Exception as e:
        print(f"Error: Unexpected error while saving to '{file_path}': {e}")
        raise


def load_json_file(file_path: str) -> dict:
    """
    Open and read a JSON file, returning the parsed data.

    Args:
        file_path (str): Path to the JSON file.

    Returns:
        dict: Parsed JSON data.

    Raises:
        FileNotFoundError: If the file does not exist.
        json.JSONDecodeError: If the file contains invalid JSON.
        PermissionError: If there are insufficient permissions to read the file.
        Exception: For any other unexpected errors.
    """
    try:
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"JSON file not found: {file_path}")

        with open(file_path, 'r', encoding='utf-8') as file:
            data = json.load(file)
            return data

    except FileNotFoundError as e:
        print(f"Error: {e}")
        raise
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON format in file '{file_path}': {e}")
        raise
    except PermissionError as e:
        print(f"Error: Permission denied to read file '{file_path}': {e}")
        raise
    except Exception as e:
        print(f"Error: Unexpected error while reading '{file_path}': {e}")
        raise


def extract_unique_names(input_list: list, pattern=r'.*') -> list:
    """
    Extract unique names matching pattern from a list of strings.

    Args:
        input_list (list): List of strings that may contain names.
        pattern (str): a regex expression pattern
    Returns:
        list: List of unique extracted names.
    """
    name = set()

    for item in input_list:
        matches = re.findall(pattern, str(item))
        name.update(matches)

    return list(name)


def verify_configuration_parameters(actual_conf, expected_conf, obj_list=None, sub_param_name=None):
    """
        This function utility help to check if parameters are well defined
        on the gNB
    :param actual_conf: list of dictionaries or a dictionary
    :param expected_conf: list of expected parameters value.
    :param obj_list:
    :param sub_param_name:
    :return:
    """
    errors = []
    # Expected parameter names
    params_names = list(expected_conf.keys())

    for item in actual_conf:
        # Ensure item is a dictionary
        dist_name = item['distName']
        obj = dist_name.split("/")[-1]
        if obj_list and obj not in obj_list:
            continue
        if sub_param_name:
            params_list = item['parameters'].get(sub_param_name, None)
        else:
            params_list = item['parameters']
        if params_list:
            if isinstance(params_list, list):
                for params in params_list:
                    # elem is a key string, not a dictionary
                    # Check for missing keys and mismatched values
                    err = ''
                    for key in params_names:
                        if key not in params:
                            err = f'Param "{key}" is not defined or found.'
                        else:
                            expected = str(expected_conf[key])
                            actual = str(params[key])
                            print(f"expected: '{expected}' and actual '{actual}'")
                            if actual != expected:
                                err = (
                                    f'Value mismatch for key "{key}": '
                                    f'expected={expected}, actual={actual}'
                                )
                        if err:
                            errors.append(
                                f'Error for {dist_name} : {err}'
                            )
            elif isinstance(params_list, dict):
                err = None
                for key in params_names:
                    if key not in params_list:
                        err = f'Param "{key}" is not defined or found.'
                    else:
                        expected = str(expected_conf[key])
                        actual = str(params_list[key])
                        print(f"expected: '{expected}' and actual '{actual}'")
                        if actual != expected:
                            err = (
                                f'Value mismatch for key "{key}": '
                                f'expected={expected}, actual={actual}'
                            )
                    if err:
                        errors.append(
                            f'Error for {dist_name} : {err}'
                        )
        else:
            errors.append(f'Error for {dist_name} : No Frame Structure is defined')

    return errors
