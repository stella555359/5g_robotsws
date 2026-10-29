import os


def get_fourth_parent_directory(dir_path):
    parent_dir = os.path.dirname(dir_path)
    for _ in range(3):
        parent_dir = os.path.dirname(parent_dir)
    return parent_dir
