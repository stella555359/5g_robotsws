import pip


def import_with_auto_install(package):
    try:
        return __import__(package)
    except ImportError:    # ModuleNotFoundError:
        pip.main(['install', package])
    return __import__(package)
