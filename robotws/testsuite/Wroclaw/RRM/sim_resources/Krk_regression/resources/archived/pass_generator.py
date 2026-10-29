"""

The pass generator file provide list of functions related to password
generations process.

The functions from this module can be used to create different types of
incorrect password  (According to WebUI password tool restrictions)
"""

import itertools
import random
import string
from random import randrange

non_alpha_numeric = "!#$%&()*+,-.;=?@[]_~/"
non_acceptable_chars = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
                        0x09,
                        0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
                        0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19,
                        0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F,
                        0x20, 0x7F, 0x3C, 0x3E, 0x22, 0x7B, 0x7D, 0x7C, 0x5C, 0x5E,
                        0x60, 0x3A]
non_acceptable_chars_cloud = '<>":{}|^` '


def get_rand_digit():
    """Provide randon digit."""
    return random.choice(string.digits)


def get_rand_upcase():
    """Provide random upper-case letter."""
    return random.choice(string.ascii_uppercase)


def get_rand_lowcase():
    """Provide random low-case letter."""
    return random.choice(string.ascii_lowercase)


def get_rand_not_alpha_digit():
    """Provide random acceptable non alpha-numeric symbol."""
    return random.choice(non_alpha_numeric)


def get_rand_forbidden(is_cloud=False):
    """Provide random non-acceptable symbol."""
    if is_cloud:
        return random.choice(non_acceptable_chars_cloud)
    else:
        return chr(random.choice(non_acceptable_chars))


def generate_password(possible_characters, musthave_characters,
                      min_size=8, max_size=20):
    """Creating generic password according to provided conditions"""
    min_number_of_additional_symbols = min_size - len(musthave_characters)
    max_number_of_additional_symbols = max_size - len(musthave_characters)
    if max_size > len(possible_characters):
        number_of_symbols = random.randint(min_number_of_additional_symbols,
                                           max_number_of_additional_symbols)
        other_characters = [random.choice(possible_characters) for _ in range(number_of_symbols)]
    else:
        other_characters = random.sample(possible_characters, random.randint(min_number_of_additional_symbols,
                                                                             max_number_of_additional_symbols))
    all_together = musthave_characters + other_characters
    random.shuffle(all_together)
    return ''.join(all_together)


def generate_too_short_password():
    """Creating generic password which is too short to be used"""
    possible_characters = string.ascii_letters + string.digits + non_alpha_numeric
    musthave_characters = [get_rand_not_alpha_digit(), get_rand_digit(),
                           get_rand_digit(), get_rand_lowcase(),
                           get_rand_upcase()]
    return generate_password(possible_characters, musthave_characters, 5, 7)


def generate_password_wth_two_same_in_a_row(possible_characters,
                                            musthave_characters, min_size=8, max_size=20):
    """Creating generic password which is contain two same chars in a row"""
    min_number_of_additional_symbols = min_size - len(musthave_characters)
    max_number_of_additional_symbols = max_size - len(musthave_characters)
    other_characters = random.sample(possible_characters, random.randint(min_number_of_additional_symbols,
                                                                         max_number_of_additional_symbols))
    all_together = musthave_characters + other_characters
    random.shuffle(all_together)
    rand_index = randrange(1, len(all_together))
    all_together[rand_index] = all_together[rand_index - 1]
    return ''.join(all_together)


def generate_too_long_password():
    """Creating generic password which is too long to be used"""
    possible_characters = string.ascii_letters + string.digits + non_alpha_numeric
    musthave_characters = [get_rand_not_alpha_digit(), get_rand_digit(),
                           get_rand_digit(), get_rand_lowcase(),
                           get_rand_upcase()]
    return generate_password(possible_characters, musthave_characters, 128, 256)


def generate_only_one_digit_password():
    """Creating generic password which is contain exactly one digit"""
    possible_characters = string.ascii_letters + non_alpha_numeric
    musthave_characters = [get_rand_not_alpha_digit(), get_rand_digit(),
                           get_rand_lowcase(), get_rand_upcase()]
    return generate_password(possible_characters, musthave_characters)


def generate_no_digit_password():
    """Creating generic password without any digits"""
    possible_characters = string.ascii_letters + non_alpha_numeric
    musthave_characters = [get_rand_not_alpha_digit(), get_rand_lowcase(),
                           get_rand_upcase()]
    return generate_password(possible_characters, musthave_characters)


def generate_no_upcase_letter_password():
    """Creating generic password without any upper-case letters"""
    possible_characters = string.ascii_lowercase + string.digits + non_alpha_numeric
    musthave_characters = [get_rand_not_alpha_digit(), get_rand_digit(),
                           get_rand_digit(), get_rand_lowcase()]
    return generate_password(possible_characters, musthave_characters)


def generate_no_lowcase_letter_password():
    """Creating generic password without any low-case letters"""
    possible_characters = string.ascii_uppercase + string.digits + non_alpha_numeric
    musthave_characters = [get_rand_not_alpha_digit(), get_rand_digit(),
                           get_rand_digit(), get_rand_upcase()]
    return generate_password(possible_characters, musthave_characters)


def generate_password_with_forbidden_character(is_cloud=False):
    """Creating generic password that contain non-acceptable character"""
    possible_characters = string.ascii_letters + string.digits + non_alpha_numeric
    musthave_characters = [get_rand_not_alpha_digit(), get_rand_digit(),
                           get_rand_digit(), get_rand_lowcase(),
                           get_rand_upcase(), get_rand_forbidden(is_cloud)]
    return generate_password(possible_characters, musthave_characters)


def generate_two_same_characters_in_row_password():
    """Creating generic password which is contain two same chars in a row"""
    possible_characters = string.ascii_letters + string.digits + non_alpha_numeric
    musthave_characters = [get_rand_not_alpha_digit(), get_rand_digit(),
                           get_rand_digit(), get_rand_lowcase(),
                           get_rand_upcase()]
    return generate_password_wth_two_same_in_a_row(possible_characters, musthave_characters)


def generate_password_containing_username(username):
    """Creating generic password which is contain username"""
    possible_characters = string.ascii_letters + string.digits + non_alpha_numeric
    musthave_characters = [get_rand_not_alpha_digit(), get_rand_digit(),
                           get_rand_digit(), username,
                           get_rand_lowcase(), get_rand_upcase()]
    return generate_password(possible_characters, musthave_characters)


def generate_correct_password():
    """Creating generic password which is correct accroding to WebUI restrictions"""
    possible_characters = string.ascii_letters + string.digits + non_alpha_numeric
    musthave_characters = [get_rand_not_alpha_digit(), get_rand_digit(),
                           get_rand_digit(),
                           get_rand_lowcase(), get_rand_upcase()]
    password = generate_password(possible_characters, musthave_characters)
    password = ''.join(ch for ch, _ in itertools.groupby(password))
    if len(password) < 8:
        password = generate_correct_password()
    return password
