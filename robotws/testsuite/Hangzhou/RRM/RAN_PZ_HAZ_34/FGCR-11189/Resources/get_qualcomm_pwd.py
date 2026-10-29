# *-coding=utf-8-*


def read_qualcomm_usr(qualcomm_file='/opt/workspace/SCF/qualcomm_pwd.txt'):
    with open(qualcomm_file, 'r') as qual_file:
        content_list = qual_file.readlines()
        print(content_list)
        usr_na = [uu for uu in content_list if uu.__contains__('USER')]
        pas_wd = [ww for ww in content_list if ww.__contains__('PWD')]
        user_name = usr_na[0].split(":")[1].strip()
        pass_word = pas_wd[0].split(":")[1].strip()
    print(user_name, pass_word)
    return user_name, pass_word
