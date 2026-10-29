import yaml


def update_CLI_registry(path, registry_link):
    """
    Updates the registry link in the YAML file.
    Args:
        path (str): Path to the YAML file to be updated and converted.
        registry_link (str): The new registry link to be set in the YAML file.
    """
    with open(path, 'r') as file:
        lines = file.readlines()

    updated_lines = []
    for line in lines:
        if 'registry' in line and line.strip().startswith('registry'):
            parts = line.split(':')
            updated_line = f"{parts[0]}: {registry_link}\n"
            updated_lines.append(updated_line)
        else:
            updated_lines.append(line)

    with open(path, 'w') as file:
        file.writelines(updated_lines)

    return ''.join(updated_lines)


def update_rancnf_file(path, updates: dict):
    """
    Updates multiple keys in a YAML file based on dot-separated paths.

    Args:
        path (str): Path to the YAML file to be updated.
        updates (dict): Dictionary of updates where keys are dot-separated paths,
                        and values are the new values to assign.
    """
    with open(path, 'r') as file:
        data = yaml.safe_load(file)

    for key_path, new_value in updates.items():
        keys = key_path.split(".")
        d = data
        try:
            for key in keys[:-1]:
                d = d[key]
            d[keys[-1]] = new_value
        except KeyError:
            raise KeyError(f"Key path '{key_path}' not found in YAML.")

    with open(path, 'w') as file:
        yaml.dump(data, file, sort_keys=False)

    return yaml.dump(data, sort_keys=False)


def load_yaml_as_dict(path):
    with open(path, 'r') as file:
        return yaml.safe_load(file)


def get_value_by_path(data, path):
    """
    Get nested value from dict by dot-separated path string.
    """
    keys = path.split('.')
    val = data
    for key in keys:
        if not isinstance(val, dict):
            raise ValueError(f"Expected dict at key '{key}' in path '{path}', but got {type(val).__name__}")
        if key not in val:
            raise KeyError(f"Key '{key}' not found in path '{path}'")
        val = val[key]
    return val


def add_additional_data_to_nertc_for_wft():
    """
        Function add new line to .netrc file with necessary data for wft api.
    """
    file_path = "/home/ute/.netrc"
    new_line = "machine wft.int.net.nokia.com password gKfr58ELsV5hdaBapwizQxhmBd9UR3Ndda0mbgvC\n"
    try:
        with open(file_path, "r") as file:
            if new_line.strip() in file.read():
                print(f"Credentials already added to {file_path}")
                return
        with open(file_path, "a") as file:
            file.write(new_line + "\n")
    except Exception as e:
        print(f"An error ocurred during adding of credentials: {e}")
