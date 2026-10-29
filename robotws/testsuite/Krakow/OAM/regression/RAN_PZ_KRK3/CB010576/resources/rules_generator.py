"""
This script contains functions for rules generation in account management scope.
author: Magda Chroste
email: magda.chrostek@nokia.com
"""
import random
import string

not_allowed_characters = '<>":{}|^`'
not_allowed_characters = not_allowed_characters + '\\'
special_characters = "!#$%&()*+,-.;=/?@[]_~"
allowed_characters_for_CU_username = "._-"
not_allowed_characters_for_CU_username = '!#$%&()*+,;=?@[]~<>":{}|/^`'
not_allowed_characters_for_CU_username = not_allowed_characters_for_CU_username + "'"


def get_digit():
    return random.choice(string.digits)


def get_upcase_letter():
    return random.choice(string.ascii_uppercase)


def get_lowcase_letter():
    return random.choice(string.ascii_lowercase)


def get_special_character():
    return random.choice(special_characters)


def get_not_allowed_character():
    return random.choice(not_allowed_characters)


def generate_too_short_password():
    """This function generate too short password with other valid rules.
       Rule to check: The password should have 8-128 characters"""
    too_short_password = ''.join([get_digit(), get_upcase_letter(), get_lowcase_letter(),
                                  get_digit(), get_special_character()])
    return too_short_password


def generate_too_long_password():
    """This function generate too long password with other valid rules.
       Rule to check:  The password should have 8-128 characters """
    too_long_password = ''.join([get_digit(), get_upcase_letter(), get_lowcase_letter(),
                                 get_digit(), get_special_character()]) \
                        + 5 * string.ascii_lowercase
    return too_long_password


def generate_password_with_two_same_characters_in_row():
    """This function generate this same password twice with other valid rules.
       Rule to check: There should not be two consecutive identical characters """
    get_character = get_digit()
    two_same_in_row_password = ''.join([get_upcase_letter(), get_lowcase_letter(), get_special_character(),
                                        get_digit()]) + 2 * get_character \
                               + string.ascii_lowercase
    return two_same_in_row_password


def generate_password_only_one_digit():
    """This function generate this same password twice with other valid rules.
       Rule to check:  There must be at least 2 numbers (0-9)  """
    only_one_digit = ''.join([get_upcase_letter(), get_lowcase_letter(), get_special_character(),
                              get_digit()]) + string.ascii_lowercase
    return only_one_digit


def generate_password_without_digit():
    """This function generate password without digits with other valid rules.
    Rule to check: There must be at least 2 numbers (0-9) """
    without_digit = ''.join([get_upcase_letter(), get_lowcase_letter(), get_special_character(),
                             get_upcase_letter()]) + string.ascii_lowercase
    return without_digit


def generate_password_without_lowcase():
    """This function generate password without low case with other valid rules.
    Rule to check: There must be at least 1 low case letter (a-z)  """
    without_lowcase = ''.join([get_upcase_letter(), get_digit(), get_special_character(), get_digit(),
                               get_upcase_letter()]) + string.ascii_uppercase
    return without_lowcase


def generate_password_without_uppercase():
    """This function generate password without upper case with other valid rules.
    Rule to check: There must be at least 1 upper case letter (A-Z)  """
    without_uppercase = ''.join([get_lowcase_letter(), get_digit(), get_special_character(),
                                 get_digit()]) + string.ascii_lowercase
    return without_uppercase


def generate_password_with_not_allowed_symbol():
    """This function generate password with not allowed symbols included other valid rules.
    Rule to check: <>":{}|/^` are NOT allowed  """
    password_with_not_allowed_symbol = ''.join([get_digit(), get_upcase_letter(), get_lowcase_letter(),
                                                get_digit(), get_special_character(),
                                                get_not_allowed_character(), get_lowcase_letter(),
                                                get_digit()])
    return password_with_not_allowed_symbol


def generate_correct_password():
    """This function generate correct password."""
    correct_password = ''.join([get_digit(), get_upcase_letter(), get_lowcase_letter(), get_digit(),
                                get_special_character(), get_lowcase_letter(), get_upcase_letter(),
                                get_special_character()])
    return correct_password


def generate_password_with_only_alphanumeric():
    """This function generate password with non-alphanumeric chars, included other valid rules"""
    password_without_alphanumeric = ''.join([get_digit(), get_upcase_letter(), get_lowcase_letter(), get_digit(),
                                             get_upcase_letter(), get_lowcase_letter(), get_upcase_letter(),
                                             get_lowcase_letter()])
    return password_without_alphanumeric


def generate_too_short_username():
    """This function generate too short username with other valid rules.
       Rule to check: The username should have 4-16 characters """
    too_short_username = ''.join([get_digit(), get_upcase_letter(), get_lowcase_letter()])
    return too_short_username


def generate_too_long_username():
    """This function generate too long username with other valid rules.
       Rule to check: The username should have 4-16 characters """
    too_long_username = ''.join([get_digit(), get_upcase_letter()]) + string.ascii_lowercase
    return too_long_username
