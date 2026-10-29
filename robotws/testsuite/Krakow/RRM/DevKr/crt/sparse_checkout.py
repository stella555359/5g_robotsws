import os
import sys
import time


def sparse_checkout_if_repo_dont_exist(path='/home/ute/MN/UTE/robotlte'):
    if not os.path.exists(path):
        print('Sparse check started')
        os.system('mkdir {}'.format(path))
        last_dir = os.getcwd()
        os.chdir(path)
        os.system('git init')
        os.system('git remote add origin https://devkr:bL_5FXW7sTK7Kkifp6dx@wrgitlab.int.net.nokia.com/RAN/robotlte')
        print('Remote repository added')
        os.system('git config core.sparseCheckout true')
        os.system('echo "/resources/DevKr/" >> .git/info/sparse-checkout')
        os.system('echo "/resources/DevWro1/" >> .git/info/sparse-checkout')
        os.system('echo "/libraries/" >> .git/info/sparse-checkout')
        pull_start = time.time()
        print('Pull executed')
        os.system('git pull origin master')
        pull_stop = time.time()
        print('Pull finished, took: {}s'.format(int(pull_stop - pull_start)))
        os.chdir(last_dir)
    else:
        print('Repo exists')


if __name__ == '__main__':
    if len(sys.argv) >= 2:
        sparse_checkout_if_repo_dont_exist(sys.argv[1])
    else:
        sparse_checkout_if_repo_dont_exist()
