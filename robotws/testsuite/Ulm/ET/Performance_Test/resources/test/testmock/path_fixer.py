
import sys
import pathlib
import logging

logger = logging.getLogger(__name__)

ULM_DIRECTORY = pathlib.Path(__file__).resolve().parents[5]


def fix_path():
    assert ULM_DIRECTORY.name == 'Ulm'
    fix_common_keyword_path()
    fix_robotws_path()


def fix_robotws_path():
    robotws_dir = pathlib.Path(ULM_DIRECTORY.parent.parent)
    assert robotws_dir.name == 'robotws'
    _add_path(robotws_dir)


def fix_common_keyword_path():
    _add_path(pathlib.Path(ULM_DIRECTORY.joinpath(
        'resources', 'common', 'python')))


def _add_path(path_to_config):
    assert path_to_config.is_dir()
    print(f"appending path: {path_to_config}")
    sys.path.insert(1, str(path_to_config))
    logger.debug(sys.path)


fix_path()
