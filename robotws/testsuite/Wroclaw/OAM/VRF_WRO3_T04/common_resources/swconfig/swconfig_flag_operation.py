def add_flag_to_file(file, flag):
    # we need a added_flag variable to be returned from function to know, was there added flag or not
    added_flag = False
    if check_flag_with_another_value_in_file(file, flag):
        remove_flag_from_file(file, flag.split("=")[0])

    if not check_flag_in_file(file, flag):
        file_object = open(file, 'a')
        file_object.write("\n")
        file_object.write(flag + "\n")
        file_object.close()
        added_flag = True
    return added_flag


def add_multiple_flags_to_file(file, list_of_flags):
    list_of_added_flags = []
    list_of_not_added_flags = []
    for flag in list_of_flags:
        list_of_added_flags.append(flag) if add_flag_to_file(file, flag) else list_of_not_added_flags.append(flag)
    return list_of_added_flags, list_of_not_added_flags


def check_flag_in_file(file, flag):
    file_object = open(file, 'r')
    lines = file_object.readlines()
    file_object.close()

    for line in lines:
        if check_flag_in_line(line, flag):
            return True
    return False


def check_flag_in_line(line, flag):
    line_without_white_spaces = "".join(line.split())
    # here we want to get list with indexes of all "#" symbols, to know, is there any of them before our flag
    # '# 0x1A1300=0 : some text # 0x1A1300=1' our flag can look like this so we want to be sure that needed flag is
    # before the last "#" symbol
    list_of_comments = []
    for char_index in range(len(line_without_white_spaces)):
        if line_without_white_spaces[char_index] == "#":
            list_of_comments.append(char_index)

    for comment_index in list_of_comments:
        try:
            if comment_index < line_without_white_spaces.index(flag):
                return False
        except ValueError:
            continue
    # so in this place we know that there are no comment symbols before flag, but we still are not sure that our flag
    # exists, so if flag is in line, we know that its uncommented and want to return True, False in other cases
    return True if flag in line else False


def check_flag_with_another_value_in_file(file, flag):
    file_object = open(file, 'r')
    lines = file_object.readlines()
    file_object.close()

    for line in lines:
        check_full_long_in_line = check_flag_in_line(line, flag)
        check_full_short_in_line = check_flag_in_line(line, flag.split("=")[0])
        if check_full_short_in_line and not check_full_long_in_line:
            return True
    return False


def check_if_file_exists(file):
    try:
        open(file, 'r')
        return True
    except FileNotFoundError:
        return False


def process_remove_output_message(msg, local_path):
    if not msg:
        return "File swconfig.txt was successfully deleted from {path}".format(path=local_path)
    return "There is no such file {path}. Nothing to delete.".format(path=local_path)


def remove_flag_from_file(file, flag):
    # we need a deleted_flag variable to be returned from function to know, was there deleted flag or not
    deleted_flag = False
    if check_flag_in_file(file, flag):
        file_object = open(file, 'r')
        lines = file_object.readlines()
        file_object.close()
        file_object = open(file, 'w')
        for line in lines:
            if not check_flag_in_line(line, flag):
                file_object.write(line)
            else:
                deleted_flag = True
        file_object.close()
    return deleted_flag


def remove_multiple_flags_from_file(file, list_of_flags):
    list_of_removed_flags = []
    list_of_not_removed_flags = []
    for flag in list_of_flags:
        list_of_removed_flags.append(flag) if remove_flag_from_file(file, flag) else list_of_not_removed_flags.append(
            flag)
    return list_of_removed_flags, list_of_not_removed_flags
