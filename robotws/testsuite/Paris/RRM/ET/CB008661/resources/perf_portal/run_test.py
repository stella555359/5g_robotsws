#!/bin/env python3

import os
import subprocess

if __name__ == "__main__":
    my_env = os.environ.copy()
    my_env["PERF_PORTAL_DEV_MODE"] = "False"
    os.chdir(os.path.abspath(os.path.dirname(__file__)))
    SCRIPT = os.path.basename(__file__)

    pylint_exclude = [
        "C0111",  # missing-docstring
        "C0302",  # too-many-lines
        "R0902",  # too-many-instance-attributes
        "R0903",  # too-few-public-methods
        "R0904",  # too-many-public-methods
        "R0913",  # too-many-arguments
        "R0914",  # too-many-locals
        "R0915",  # too-many-statements
        "W0603",  # global-statement
        "W0703",  # catching-too-general-exception
    ]

    COMMAND = f"""source ../set_ci-scripts_env.sh \
    && /bin/env coverage run --source . --omit 'gerrit_api_rest.py,{SCRIPT}' -m unittest \
    && /bin/env coverage report --fail-under 98 -m \
    && rm .coverage"""
    STATUS = subprocess.run(
        COMMAND, shell=True, check=True, universal_newlines=True, executable="/bin/bash", env=my_env
    )
    print("OK: " + STATUS.args)
