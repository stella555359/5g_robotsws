from sys import argv

"""Listener that stops execution if a test fails."""
if "--dryrun" not in argv:
    ROBOT_LISTENER_API_VERSION = 2


def variables_import(name, attr):
    print('-- Variables: {}'.format(name))


def resource_import(name, attr):
    print('-- Resource: {:25} [{}]'.format(name, attr['importer']))


def library_import(name, attr):
    print(
        '-- Library: {:25} [{}]'.format(attr['originalname'], attr['importer']))
