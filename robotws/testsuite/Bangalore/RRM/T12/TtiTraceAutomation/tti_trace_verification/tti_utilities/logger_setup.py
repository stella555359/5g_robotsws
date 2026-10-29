import os
import logging
from datetime import datetime


def create_log_folder(base_dir='logs', prefix='log'):
    timestamp = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
    folder_name = f"{prefix}_{timestamp}"
    full_path = os.path.join(base_dir, folder_name)
    os.makedirs(full_path, exist_ok=True)
    return full_path


def setup_named_logger(name, log_file, level=logging.INFO):
    logger = logging.getLogger(name)
    logger.setLevel(level)
    logger.handlers.clear()  # Ensure fresh setup

    handler = logging.FileHandler(log_file, encoding='utf-8')
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    logger.propagate = False

    return logger
