from taf.rfrl.bts.helpers.scf_parsers import get_all_params_under_class_name


def get_all_params_under_class_name_from_scf_file(scf_file_content, class_name):
    """
    Get all parameters under a specific class name from an SCF file content.

    Args:
        scf_file_content (str): The content of the SCF file.
        class_name (str): The name of the class to search for.

    Returns:
        list: A list of dictionaries representing the parameters under the specified class name.
    """
    return get_all_params_under_class_name(scf_file_content, class_name)


def get_scf_parameter_value(scf_file, class_param_name, namespace='nrbts'):
    """
    Get the value of a specific parameter from an SCF file.

    Args:
        scf_file (str): Path to the SCF file.
        class_param_name (str): The parameter name in format "Class.Parameter".

    Returns:
        str: The value of the specified parameter or None if not found.
    """
    # Validate input parameters
    if not class_param_name or '.' not in class_param_name:
        return None

    class_name, param_name = class_param_name.split('.')
    if not class_name or not param_name:
        return None

    try:
        # Read the SCF file content
        with open(scf_file, 'r') as f:
            scf_file_content = f.read()

        # Format class name as expected by the helper function
        class_pattern = f'com.nokia.srbts.{namespace}:{class_name}'

        # Get parameters under the specified class
        all_params = get_all_params_under_class_name_from_scf_file(scf_file_content, class_pattern)

        # Find the parameter value
        for item in all_params:
            if param_name in item['params']:
                return item['params'].get(param_name)

        return None

    except FileNotFoundError:
        print(f"Error: SCF file not found at {scf_file}")
        return None
    except Exception as e:
        print(f"Error parsing SCF file: {str(e)}")
        return None
