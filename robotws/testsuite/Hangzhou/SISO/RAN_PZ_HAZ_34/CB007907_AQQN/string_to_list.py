def get_list_of_soap(cmd_output):
    """
    finds all ...dlAndUl.csv files from ABIL

    :param cmd_output: directory on ABIL where tti trace logs are stored
    :return: list of filename strings that matched the pattern
    """
    files = []
    lines = cmd_output.splitlines()
    for line in lines:
        files.append(line)
    return files
