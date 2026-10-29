import os


def boolean_and_operation(boolean1, boolean2):
    print("Perform AND operation on booleans (boolean1={}, boolean2={})".format(boolean1, boolean2))
    return boolean1 and boolean2


def boolean_or_operation(boolean1, boolean2):
    print("Perform OR operation on booleans (boolean1={}, boolean2={})".format(boolean1, boolean2))
    return boolean1 or boolean2


def addition(value1, value2):
    print("Add values (value1={}, value2={})".format(value1, value2))
    return int(value1) + int(value2)


def add_list_to_list(list1, list2, add_items_just_once=False):
    print("Add list2 ({}) to list1 ({}) if possible.".format(list2, list1))
    if list1 and list2:  # both not None
        return_list = list(list1)  # take copy of list1, so it will not modify original list
        if add_items_just_once:
            print("Check if items of list already {} are in list {} if not add them".format(list2, list1))
            for list_item in list2:
                if list_item not in list1:
                    return_list.append(list_item)
        else:
            print("Extend {} with {}".format(list1, list2))
            return_list.extend(list2)
        return return_list
    elif list1 and not list2:
        print("No list2 ({}) return {}".format(list2, list1))
        return list1
    elif list2 and not list1:
        print("No list1 ({}) return {}".format(list1, list2))
        return list2
    else:
        print("No list1 ({}) nor list2 ({}) return None.".format(list1, list2))
        return None


def if_parameter_not_list_add_it_to_list(parameter):
    print("Check if parameter is list. If not list add it to list, if list return it.")
    if not isinstance(parameter, list):
        print("Add parameter to list and return list")
        return [parameter]
    else:
        print("Parameter is already list type, return it.")
        return parameter


def add_list_to_dict_if_it_exist(dict_to_add, key_list, value_to_add):
    print("If there is list of keys to add, add them. (Parameters: {}, {}, {})".format(dict_to_add, key_list,
                                                                                       value_to_add))
    if dict_to_add:
        if key_list:
            for key in key_list:
                dict_to_add[key] = value_to_add
    else:
        print("Empty dict given, create new one.")
        dict_to_add = {}
        if key_list:
            for key in key_list:
                dict_to_add[key] = value_to_add
    return dict_to_add


def select_text_depending_on_value(boolean_value, text_if_true, text_if_false):
    print("Select text to return based on boolean value (boolean_value={}, text_if_true={}, text_if_false={})".format(
        boolean_value, text_if_true, text_if_false))
    if boolean_value:
        return text_if_true
    else:
        return text_if_false


def merge_two_dicts(first_dict, second_dict):
    print("Merge two dicts (first_dict={}, second_dict={})".format(first_dict, second_dict))
    new_dict = first_dict.copy()
    new_dict.update(second_dict)
    print("Merged dict: {}".format(new_dict))
    return new_dict


def choose_two_values_from_tuple(tuple1, value_no1, tuple2, value_no2, occurrence1=0, occurrence2=0):
    print(f"Returned tuple: ({tuple1[value_no1]}, {tuple2[value_no2]})")
    return (tuple1[int(value_no1)][occurrence1] if occurrence1 else tuple1[int(value_no1)],
            tuple2[int(value_no2)][occurrence2] if occurrence2 else tuple2[int(value_no2)])


def safe_get_from_dictionary(dictionary, key, key_type="str"):
    print(f"Get value from dictionary (dictionary={dictionary}, key={key})")
    if dictionary:
        if key_type == "int":
            key = int(key)
        elif key_type == "str":
            key = str(key)
        return dictionary.get(key)
    else:
        print("No dictionary given, return None")
        return None


def rename_file_in_logs(old_file_path, what_will_be_replaced, with_what_it_is_replaced):
    print(f"rename_file_in_logs: {old_file_path}, {what_will_be_replaced}, {with_what_it_is_replaced}")
    new_file_path = old_file_path.replace(what_will_be_replaced, with_what_it_is_replaced)
    print(f"Rename file {old_file_path} to {new_file_path}")
    os.rename(old_file_path, new_file_path)
    return new_file_path
