#!/usr/bin/env python
import zipfile


def file_ex(a, b):
    print(a, b)
    with zipfile.ZipFile(a, 'r') as archive:
        listOfiles = archive.namelist()
        output_list = [s for s in listOfiles if b in s]
    if len(output_list) != 0:
        print("File Exists")
        print("List of files inside snapshot are:", )
        return True
    else:
        print("File Dnt Exists")
        print(listOfiles)
        return False
