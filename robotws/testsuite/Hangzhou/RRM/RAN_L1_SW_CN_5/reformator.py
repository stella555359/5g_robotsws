# author: yuguo.hou@nokia-sbell.com#

import os
import sys


postfixes = ['.py', '.robot']


def format_covert_tab_to_space(file_path):
    i = j = 0
    for path, dirs, files in os.walk(file_path):
        for name in files:
            tmp = name.split('.')
            tmp_name = tmp[0]+'_tmp.'+tmp[1]
            full_path = os.path.join(path, name)
            tmp_path = os.path.join(path, tmp_name)
            norm_path_orig = os.path.normpath(os.path.abspath(full_path))
            norm_path_tmp = os.path.join(norm_path_orig.split(name)[0], tmp_name)
            modifyFileFlag = any([norm_path_orig.endswith(postfix) for postfix in postfixes])
            if modifyFileFlag:
                os.system("sed -i 's/\r$//g' {}".format(norm_path_orig))
                files_1 = os.system("sed 's/\t/    /g' {} > {}".format(norm_path_orig, norm_path_tmp))
                if files_1 == 0:
                    i += 1
                if norm_path_tmp.endswith('.robot'):
                    os.system("python -m robot.tidy -l unix --inplace {}".format(norm_path_tmp))
                    j += 1
                os.system("mv {} {}".format(norm_path_tmp, norm_path_orig))
                print(norm_path_orig)
    print('{} scripts is reformated!'.format(i))
    print('{} robot files is reformated!'.format(j))


def main(argv):
    file_path = sys.argv[1]
    if not os.path.exists(file_path):
        print('{} is not found.'.format(file_path))
    os.system('cp -rf {} /home/ute/logs/'.format(file_path))
    print("Back up {} files to '/home/ute/logs/'.".format(file_path))
    format_covert_tab_to_space(file_path)


if __name__ == '__main__':
    main(sys.argv)
