import inspect
from asyncio import CancelledError

import pytest
import asyncio
import os
from unittest.mock import patch, AsyncMock, MagicMock
from core.engine.semaphore import calculate_semaphore_max

from core.RegexWatcher import current_error_counter


class TestSemaphore:

    @pytest.mark.asyncio
    async def test_calculate_semaphore(self):
        """This test is checking correct connection (watcher.connect()):
                - check if used mocked writer and reader after connection done
                - check if logger received info about success connection
                - check if watcher.command_sender has been configured (as mocked object)
                - check if called to create asyncio task process_commands()
                """
        limit = 71
        percentage = {
            "n71": "14%",
            "n25": "22%",
            "n41": "64%"
        }
        output = calculate_semaphore_max(limit, percentage)
        print(output)
