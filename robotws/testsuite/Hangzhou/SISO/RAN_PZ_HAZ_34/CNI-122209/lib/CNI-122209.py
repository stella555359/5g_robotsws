# -*- coding: utf-8 -*

"""
Author:         Zhang Xuewen
Contact Mail:   xuewen.zhang@nokia-sbell.com
Description:
This script performs the following steps:
Extracts the contents of snapshot.zip.
Searches for the term base-pstore in the extracted files.
Recursively extracts nested zip and tar.gz files.
Checks if the file names contain any of the specified terms (console-ramoops, dmesg, dmesg-ramoops).
"""

"""
import os
import tarfile


def find_upper_level_path(file_list_path, search_term):
    with open(file_list_path, 'r') as file:
        lines = file.readlines()

    for line in lines:
        if search_term in line:
            # Find the upper-level path
            for upper_line in reversed(lines[:lines.index(line)]):
                if upper_line.strip().endswith(':'):
                    return upper_line.strip().rstrip(':')
    return None


def extract_tar_gz(file_path, dest_path):
    with tarfile.open(file_path, 'r:gz') as tar:
        tar.extractall(path=dest_path)


def extract_nested_tar(file_path, dest_path):
    if file_path.endswith('.tar.gz') or file_path.endswith('.tgz'):
        extract_tar_gz(file_path, dest_path)
    elif file_path.endswith('.txz'):
        with tarfile.open(file_path, 'r:xz') as tar:
            tar.extractall(path=dest_path)
    elif file_path.endswith('.gz'):
        with tarfile.open(file_path, 'r:gz') as tar:
            tar.extractall(path=dest_path)


def find_files_with_terms(directory, search_terms):
    matches = {term: [] for term in search_terms}
    for root, _, files in os.walk(directory):
        for file in files:
            for term in search_terms:
                if term in file:
                    matches[term].append(os.path.join(root, file))
    return matches


def main():
    base_pstore_path = 'BTS2457_L1214211778_RMOD_L_1_base-pstore.tar.gz'
    extract_path = 'extracted_files'
    search_terms = ['console-ramoops', 'dmesg', 'dmesg-ramoops']

    # Step 1: Extract the base tar.gz file
    extract_tar_gz(base_pstore_path, extract_path)

    # Step 2: Extract nested tar files
    nested_tar_path = os.path.join(extract_path, 'pstore.txz')
    extract_nested_tar(nested_tar_path, extract_path)

    # Step 3: Recursively search for files containing the search terms
    matches = find_files_with_terms(extract_path, search_terms)

    for term, files in matches.items():
        if files:
            print(f"Files containing '{term}':")
            for file in files:
                print(file)
        else:
            print(f"No files containing '{term}' found.")

if __name__ == '__main__':
    main()
"""


def find_upper_level_path(file_list_path, search_term):
    with open(file_list_path, 'r') as file:
        lines = file.readlines()

    for line in lines:
        if search_term in line:
            # Find the upper-level path
            for upper_line in reversed(lines[:lines.index(line)]):
                if upper_line.strip().endswith(':'):
                    return upper_line.strip().rstrip(':')
    return None


'''
file_list_path = 'file_list.txt'
search_term = 'BTS2463_1M231801860_RMOD_L_3_base-pstore'
upper_level_path = find_upper_level_path(file_list_path, search_term)

if upper_level_path:
    print(f"Upper-level path: {upper_level_path}")
else:
    print("Search term not found.")
'''
