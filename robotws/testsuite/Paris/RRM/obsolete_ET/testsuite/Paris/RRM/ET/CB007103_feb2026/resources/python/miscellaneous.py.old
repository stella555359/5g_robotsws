import os


def read_first_line(file_path):
    with open(file_path, 'r') as file:
        first_line = file.readline().strip()
        first_line = first_line.split(':', 1)[0]  # Split on the first occurrence of ':'
    return first_line
