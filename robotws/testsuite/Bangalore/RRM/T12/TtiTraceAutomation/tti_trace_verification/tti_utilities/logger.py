# utils/logger.py
import logging
import os


def setup_logger(log_file, name="app_logger"):
    os.makedirs(os.path.dirname(f"./logs/{log_file}"), exist_ok=True)

    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)
    logger.handlers.clear()  # Clear any existing handlers

    # File handler only
    file_handler = logging.FileHandler(f"./logs/{log_file}")
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))

    logger.addHandler(file_handler)
    logger.propagate = False  # Prevent bubbling to root logger

    return logger
