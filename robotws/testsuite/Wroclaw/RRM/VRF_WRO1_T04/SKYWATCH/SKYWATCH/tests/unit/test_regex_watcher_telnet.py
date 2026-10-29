import inspect
from asyncio import CancelledError

import pytest
import asyncio
import os
from unittest.mock import patch, AsyncMock, MagicMock

from core.RegexWatcher import current_error_counter


class TestRegexWatcherTelnet:

    @pytest.mark.asyncio
    async def test_connect_successful(self, mock_telnet_connection, logging_env, mock_logger):
        """This test is checking correct connection (watcher.connect()):
                - check if used mocked writer and reader after connection done
                - check if logger received info about success connection
                - check if watcher.command_sender has been configured (as mocked object)
                - check if called to create asyncio task process_commands()
                """
        import core.RegexWatcher
        print("Current working directory:", os.getcwd())
        print("Log path would be created at:", os.path.abspath(core.RegexWatcher.log_path._get_target()))
        mock_reader, mock_writer = mock_telnet_connection
        fake_sender = MagicMock()

        with patch('asyncio.open_connection', return_value=(mock_reader, mock_writer)), \
                patch("asyncio.create_task") as mock_create_task, \
                patch("core.RegexWatcher.TelnetCommandSender", return_value=fake_sender) as mock_sender:
            watcher = core.RegexWatcher.RegexWatcherTelnet("test_host", 1234)
            await watcher.connect()

            assert watcher.writer == mock_writer
            assert watcher.reader == mock_reader
            core.RegexWatcher.logger.info.assert_called_once_with(f"[DEBUG] Connected to test_host:1234")
            assert watcher.command_sender == fake_sender
            watcher.command_sender.process_commands.assert_called_once()
            mock_create_task.assert_called_once_with(fake_sender.process_commands())

    @pytest.mark.asyncio
    async def test_connect_successful_short(self, mock_regex_watcher, mock_telnet_connection):
        """This test is checking correct connection (watcher.connect()):
                - check if used mocked writer and reader after connection done
                - check if logger received info about success connection
                - check if watcher.command_sender has been configured (as mocked object)
                - check if watcher.running flag is set to True
                - check if called to create asyncio task process_commands()
                """
        import core.RegexWatcher
        mock_reader, mock_writer = mock_telnet_connection
        fake_sender = MagicMock()
        with patch("asyncio.create_task") as mock_create_task, \
                patch("core.RegexWatcher.TelnetCommandSender", return_value=fake_sender) as mock_sender:
            watcher = mock_regex_watcher
            await watcher.connect()

            assert watcher.writer == mock_writer
            assert watcher.reader == mock_reader
            core.RegexWatcher.logger.info.assert_called_once_with(f"[DEBUG] Connected to test_host:1234")
            assert watcher.command_sender == fake_sender
            assert watcher.running is True
            watcher.command_sender.process_commands.assert_called_once()
            mock_create_task.assert_called_once_with(fake_sender.process_commands())

    @pytest.mark.asyncio
    async def test_connect_failure(self, mock_telnet_connection, logging_env, mock_logger):
        """This test is checking unsuccessful connection (watcher.connect()):
                - check if logger received info about not possible connection
                - check if watcher.running flag is set to False
                """
        import core.RegexWatcher
        mock_reader, mock_writer = mock_telnet_connection

        with patch('asyncio.open_connection', return_value=(mock_reader, mock_writer)):
            watcher = core.RegexWatcher.RegexWatcherTelnet("test_host", 1234)
            # watcher = mock_regex_watcher
            with patch("asyncio.open_connection", new=AsyncMock(side_effect=Exception("boom"))):

                await watcher.connect()
                assert watcher.running is False
                core.RegexWatcher.logger.warning.assert_called_once_with(f"[ERROR] Couldn't connect: boom")

    @pytest.mark.asyncio
    async def test_initial_values(self, mock_regex_watcher):
        """This test is checking initial values when creating RegexWatcherTelnet() object watcher:"""
        watcher = mock_regex_watcher

        assert watcher.host == "test_host"
        assert watcher.port == 1234
        assert watcher.regex_patterns == []
        assert watcher.waiting_tasks == {}
        assert watcher.running is True
        assert watcher.reader is None
        assert watcher.command_sender is None
        assert watcher.stats == {'regex_data': [], 'command_data': []}

    @pytest.mark.asyncio
    async def test_successful_adding_single_pattern(self, mock_regex_watcher):
        """This test is checking adding of single pattern by watcher.add_pattern
            - create watcher object
            - check if watcher.waiting_tasks empty
            - check if watcher.regex_patterns empty
            - add some various pattern
            - check if pattern added to watcher.waiting_tasks
            - check if task inside waiting_tasks[pattern] is asyncio.Future type (awaitable)
            - check if first element of regex_patterns is pattern
            - check if file_logger triggered with successful output"""
        import core.RegexWatcher
        pattern = fr"UE11: Successful attach"
        watcher = mock_regex_watcher
        assert watcher.waiting_tasks == {}
        assert watcher.regex_patterns == []
        await watcher.add_pattern(pattern)
        assert pattern in watcher.waiting_tasks
        assert inspect.isawaitable(watcher.waiting_tasks[pattern])
        assert watcher.regex_patterns[0] == pattern
        core.RegexWatcher.file_logger.info.assert_called_once_with("[DEBUG] Added regex: UE11: Successful attach")

    @pytest.mark.asyncio
    async def test_adding_single_pattern_already_existing(self, mock_regex_watcher):
        """Test is checking if adding already existing pattern is not adding duplicate
            - successful add pattern
            - check if waiting_tasks and regex_patterns have 1 element
            - add the same pattern
            - check if no new element added
            - check if returned the same task from waiting_tasks"""
        pattern = fr"UE11: Successful attach"
        watcher = mock_regex_watcher
        result_success = await watcher.add_pattern(pattern)
        assert len(watcher.waiting_tasks) == 1
        result_existing = await watcher.add_pattern(pattern)
        assert result_success == result_existing
        assert len(watcher.waiting_tasks) == 1
        assert len(watcher.regex_patterns) == 1

    @pytest.mark.asyncio
    async def test_wait_for_pattern_successful(self, mock_regex_watcher, fut):
        import core.RegexWatcher
        watcher = mock_regex_watcher
        fut.set_result("ok")
        with patch.object(watcher, "add_pattern", return_value=fut):
            result = await watcher.wait_for_pattern(fr"UE5: Successful attach", timeout=1)
            assert result == "ok"
            core.RegexWatcher.file_logger.info.assert_called_once_with(fr"[MATCH][In: 0.000000s]"
                                                                       f" Found pattern: UE5: Successful attach")
            watcher.add_pattern.assert_called_once_with(fr"UE5: Successful attach")

    @pytest.mark.asyncio
    async def test_wait_for_pattern_timeout(self, mock_regex_watcher, fut):
        import core.RegexWatcher
        pattern = "UE5: Successful attach"
        counter = {"errors": 0}
        token = current_error_counter.set(counter)
        watcher = mock_regex_watcher
        with patch.object(watcher, "add_pattern", return_value=fut):
            task = asyncio.create_task(watcher.wait_for_pattern(pattern, timeout=0.1))
            result = await task
            assert result is False
            assert counter["errors"] == 1
            core.RegexWatcher.logger.error.assert_called_once_with(f"[ERROR] Not found pattern '{pattern}' in time"
                                                                   f" 0.1 seconds.")
            current_error_counter.reset(token)

    @pytest.mark.asyncio
    async def test_wait_for_pattern_cancelled(self, mock_regex_watcher, fut):
        import core.RegexWatcher
        watcher = mock_regex_watcher
        pattern = "UE5: Successful attach"
        with patch.object(watcher, "add_pattern", return_value=fut):
            task = asyncio.create_task(watcher.wait_for_pattern(pattern, timeout=2))
            await asyncio.sleep(0.05)
            fut.cancel()
            with pytest.raises(asyncio.CancelledError):
                result = await task
            core.RegexWatcher.logger.warning.assert_called_once_with(f"[BREAK] Task awaiting for {pattern} "
                                                                     f"has been cancelled")

    @pytest.mark.asyncio
    async def test_wait_with_padding_successful(self, mock_regex_watcher):
        import core.RegexWatcher
        watcher = mock_regex_watcher
        pattern = "UE5: Successful attach"
        with patch.object(watcher, "wait_for_pattern", new_callable=AsyncMock, return_value="ok"):
            result = await watcher.wait_with_padding(fr"{pattern}", total_time=0.01, sleep_without_regex=0)
            assert result == "ok"
            core.RegexWatcher.file_logger.info.assert_called_once_with(f"Regex found after 0.00s,"
                                                                       f" waiting next 0.010000s...")

    @pytest.mark.asyncio
    async def test_wait_with_padding_timeout(self, mock_regex_watcher):
        import core.RegexWatcher
        watcher = mock_regex_watcher
        pattern = "UE5: Successful attach"
        with patch.object(watcher, "wait_for_pattern", new_callable=AsyncMock, return_value=False):
            result = await watcher.wait_with_padding(fr"UE5: Successful attach", total_time=0.01,
                                                     sleep_without_regex=0)
            assert result is False
            core.RegexWatcher.logger.error.assert_called_once_with(f"[ERROR] Not found pattern '{pattern}' "
                                                                   f"in time 0.01s")

    @pytest.mark.asyncio
    async def test_wait_with_padding_cancelled(self, mock_regex_watcher):
        import core.RegexWatcher
        watcher = mock_regex_watcher
        pattern = "UE5: Successful attach"
        watcher.wait_for_pattern = AsyncMock(side_effect=asyncio.CancelledError)
        with pytest.raises(asyncio.CancelledError):
            await watcher.wait_with_padding(fr"{pattern}", total_time=2, sleep_without_regex=0)
