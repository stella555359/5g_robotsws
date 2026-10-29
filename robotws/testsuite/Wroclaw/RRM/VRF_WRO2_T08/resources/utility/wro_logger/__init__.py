from .robotbackgroundlogger import BackgroundLogger
from .wro_logger import WroLogger
from ..robot_utils import is_robot_running

if is_robot_running():
    logger = BackgroundLogger()
else:
    logger = WroLogger()

__all__ = ['logger']
