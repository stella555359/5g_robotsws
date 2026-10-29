#!/bin/bash

# "v1.0 created initially"
echo "bootstrap_test_clean v1.0"

# bootstrap clean for bootstrap test script, to prepare bootstrap test
# should run before every bootstrap_test.sh execution runs

# please note this script will delete virtual environments

# this script is located in robotws/testsuite/Ulm/resources/Common/bash/bootstrap
# this script must be run from robotws with command
# testsuite/Ulm/resources/Common/bash/bootstrap/bootstrap_test_clean.sh

bs_bootstrap_test_clean() {

    echo "bootstrap test clean"
    echo "-01-"

    pyenv virtualenv-delete --force reqcfg_3.6.10
    pyenv virtualenv-delete --force robotws_3.6.10
    pyenv virtualenv-delete --force robotws_3.9.14
    rm reqcfg_3.6.10
    rm robotws_3.6.10
    rm robotws_3.9.14
    rm -rf .venv*
    pyenv local 2.7.17
    clear
    pyenv versions
}

echo "---->call bs_bootstrap_test_clean"
bs_bootstrap_test_clean
