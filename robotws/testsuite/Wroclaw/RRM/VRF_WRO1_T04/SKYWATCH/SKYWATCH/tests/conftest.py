import pytest
import importlib
import asyncio
import tempfile
from pathlib import Path
from unittest.mock import AsyncMock, MagicMock, patch


@pytest.fixture(scope="session")
def event_loop():
    """Event loop dla całej sesji testowej"""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest.fixture
def logging_env(tmp_path):
    import core.RegexWatcher
    core.RegexWatcher.set_log_file(tmp_path)


@pytest.fixture
def mock_telnet_connection():
    """Mock połączenia telnet (reader, writer)"""
    mock_reader = AsyncMock()
    mock_writer = AsyncMock()

    # Konfiguracja mock_writer
    mock_writer.write = MagicMock()
    mock_writer.drain = AsyncMock()
    mock_writer.close = MagicMock()
    mock_writer.wait_closed = AsyncMock()

    # Konfiguracja mock_reader
    mock_reader.read = AsyncMock(return_value=b"mock response\n")
    mock_reader.readline = AsyncMock(return_value=b"mock line\n")

    return mock_reader, mock_writer


@pytest.fixture
def mock_stats():
    """Mock obiektu stats"""
    return MagicMock()


@pytest.fixture
def mock_logger():
    import core.RegexWatcher
    core.RegexWatcher._logger = MagicMock()


@pytest.fixture
def mock_file_loger():
    import core.RegexWatcher
    core.RegexWatcher._file_logger = MagicMock()


@pytest.fixture
async def mock_regex_watcher(mock_telnet_connection, mock_stats, logging_env, mock_logger, mock_file_loger):
    """Mock RegexWatcherTelnet z zamockowanym połączeniem"""
    import core.RegexWatcher
    mock_reader, mock_writer = mock_telnet_connection

    with patch('asyncio.open_connection', return_value=(mock_reader, mock_writer)):
        watcher = core.RegexWatcher.RegexWatcherTelnet("test_host", 1234)
        # watcher.logger = mock_logger
        # await watcher.connect()  # Jeśli masz metodę connect
        yield watcher
        # Cleanup jeśli potrzebny
        # if hasattr(watcher, 'disconnect'):
        #     await watcher.disconnect()


@pytest.fixture
def telnet_command_sender(mock_telnet_connection, mock_stats):
    """TelnetCommandSender z mockami"""
    import core.RegexWatcher
    mock_reader, mock_writer = mock_telnet_connection
    return core.RegexWatcher.TelnetCommandSender(mock_writer, mock_stats)


@pytest.fixture
async def command_sender_with_queue(telnet_command_sender):
    """TelnetCommandSender z pustą kolejką"""
    # Upewnij się, że kolejka jest pusta
    while not telnet_command_sender.commands.empty():
        await telnet_command_sender.commands.get()
    return telnet_command_sender


@pytest.fixture
def temp_output_dir():
    """Fixture tworząca tymczasowy katalog dla testów"""
    with tempfile.TemporaryDirectory(prefix="pytest_output_") as temp_dir:
        yield Path(temp_dir)


@pytest.fixture
async def fut():
    loop = asyncio.get_running_loop()
    return loop.create_future()
