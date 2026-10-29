# *-coding=utf-8-*

# Name: Jack Zeng
# Time: 2023/6/15 23:45

from robot.libraries.BuiltIn import BuiltIn


def check_string_exist_in_txt_file(txt_file, string_name):
    """
    as per filter name get all values per col
    :param txt_file: csv file name
    :param string_name: head of filter name
    :return: true or false
    """
    try:
        with open(txt_file, "r", encoding="utf-8") as file:
            file_contents = file.read()
            if string_name in file_contents:
                return "True"
            else:
                return "False"
    except FileNotFoundError:
        print("file not found：{file_path}")
    except Exception as e:
        print("error：{str(e)}")
    return "Error"
