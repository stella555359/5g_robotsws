"""
        Keywords Purpose:
            Keyword to check if directory or file

        AUTHOR (I&V-1):
            Philippe Deroche     philippe.deroche@nokia.come
"""

import os
import sys


class disc_dir_file_class(object):

    def disc_dir_file(self, path):
        if os.path.isdir(path):
            return path
        elif os.path.isfile(path):
            basename = os.path.basename(path)
            return basename
        else:
            return '!!None!!'


if __name__ == "__main__":
    obj = disc_dir_file_class()
    try:
        print(obj.disc_dir_file(sys.argv[1]))
    except Exception as e:
        print(str(e))
