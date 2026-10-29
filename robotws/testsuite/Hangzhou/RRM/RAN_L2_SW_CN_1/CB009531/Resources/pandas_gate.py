from contextlib import contextmanager
from tempfile import gettempdir
import importlib
import os
import pkgutil
import subprocess
pd = None


@contextmanager
def temp_pandas_requirements_file():
    requirements = """pandas
    numpy
    pytz
    python-dateutil
    """
    requirements_file = os.path.join(gettempdir(), 'pandas_requirements.log')
    with open(requirements_file, 'w') as req_file:
        req_file.write(requirements)

    try:
        yield requirements_file
    finally:
        os.remove(requirements_file)


def install_requirements(requirements_file):
    try:
        subprocess.call(['pip', 'install', '--no-deps', '-r', requirements_file])
    except Exception as e:
        raise AssertionError("Error installing requirements " + str(e))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def install_and_import_pandas():
    if not is_pandas_installed():
        with temp_pandas_requirements_file() as requirement_file:
            install_requirements(requirement_file)
    return importlib.import_module('pandas')
