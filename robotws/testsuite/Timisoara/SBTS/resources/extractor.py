#!/usr/bin/env python3
import zipfile
import os


def extractor(snap_name, path):
    with zipfile.ZipFile(snap_name, 'r') as zip_ref:
        zip_ref.extractall(path)
        zip_ref.close()
    os.chdir(path)
    for item in os.listdir(path):
        if item.endswith(".zip"):
            print(item)
            file_name = os.path.abspath(item)  # get full path of files
            zip_ref = zipfile.ZipFile(file_name)  # create zipfile object
            zip_ref.extractall(path)  # extract file to dir
            zip_ref.close()  # close file
    print("Extractor completed")


if __name__ == '__main__':
    extractor()
