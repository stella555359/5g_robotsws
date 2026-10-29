from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.log.log import blog


def is_swconfig_modification_needed(swconfig_file, flags_to_check):
    existing_flags = get_flags_from_swconfig(swconfig_file)
    existing_params_and_values = set(split_flags_into_params_and_values(existing_flags))
    params_and_values_to_check = set(split_flags_into_params_and_values(flags_to_check))

    for param_and_value in params_and_values_to_check:
        if param_and_value not in existing_params_and_values:
            return True
    return False


def get_flags_from_swconfig(swconfig_file):
    try:
        with open(swconfig_file, 'r+') as f:
            file_lines = filter(None, (line.rstrip() for line in f))
            existing_flags = remove_commented_lines(file_lines)
            return existing_flags
    except EnvironmentError:
        raise blog('No swconfig found or you don\'t have access to the file.')


def remove_commented_lines(file_lines):
    relevant_lines = []
    for line in file_lines:
        if line[0] != '#':
            relevant_lines.append(line)
    return relevant_lines


def split_flags_into_params_and_values(flags_to_check):
    params_and_values = []
    for flag in flags_to_check:
        params_and_values.append(get_param_and_value_from_flag(flag))
    return params_and_values


def get_param_and_value_from_flag(flag):
    return flag.split('=')[0], flag.split('=')[1]
