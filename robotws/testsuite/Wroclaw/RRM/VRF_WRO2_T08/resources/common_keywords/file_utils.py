"""
File utilities module.

This module provides common file operations used across multiple test features.
"""

from collections.abc import Generator


def file_reader(filename: str) -> Generator[str, None, None]:
    """
    Reads a file line by line and yields each line as a generator.

    :param filename: The path to the file to be read.
    :type filename: str
    :return: A generator yielding lines from the file.
    :rtype: Generator[str, None, None]
    """
    with open(filename, 'r') as file:
        for line in file:
            yield line


def get_empty_list() -> list:
    """
    Returns an empty list.

    This function is used in Robot Framework test cases where an empty list
    is needed as a default value or placeholder.

    :return: An empty list.
    :rtype: list
    """
    return []
