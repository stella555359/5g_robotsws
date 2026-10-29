import sys
import time
import asyncio
from core.engine.workers import Status
from core.RegexWatcher import max_reached_scen, max_reached, logger
from rich.table import Table
from rich.live import Live
from rich.console import Console, Group
from rich.progress import Progress, BarColumn, TextColumn, ProgressColumn
from rich.text import Text


def format_time(seconds):
    """Konwertuje czas w sekundach na format HH:MM:SS lub MM:SS jeśli krótszy niż godzina."""
    hours, remainder = divmod(int(seconds), 3600)
    minutes, sec = divmod(remainder, 60)
    if hours > 0:
        return f"{hours:02d}:{minutes:02d}:{sec:02d}"
    else:
        return f"{minutes:02d}:{sec:02d}"


class ElapsedTimeoutColumn(ProgressColumn):
    def __init__(self, timeout: int):
        super().__init__()
        self.timeout = timeout

    def render(self, task):
        def fmt(sec):
            sec = int(sec)
            m, s = divmod(sec, 60)
            return f"{m}:{s:02d}"
        return Text(f"{fmt(task.elapsed)} / {fmt(self.timeout)}")


def build_table(status: Status, cells):
    def bold(text: str) -> str:
        return f"\033[1m{text}\033[0m"

    table = Table(title="SKYWATCH", expand=False)
    columns = ['     ', *cells, '∑ Active', 'Done']
    for column in columns:
        table.add_column(column)
    table.add_row("BACKGROUND", None, None, None, str(status.background_active), str(status.background_done))
    table.add_row("SCENARIOS", str(status.scenarios_active[cells[0]]), str(status.scenarios_active[cells[1]]),
                  str(status.scenarios_active[cells[2]]), str(status.summary_active), str(status.scenarios_done))

    return table


async def progress_renderer(timeout: float, status: Status, cells):
    # start = time.monotonic()
    start = None
    console = Console(force_terminal=True, file=open("/dev/tty", "w"))
    progress = Progress(
        TextColumn("[progress.description]{task.description}"),
        BarColumn(bar_width=30,
                  complete_style="white",
                  finished_style="white",
                  pulse_style="grey50"),
        ElapsedTimeoutColumn(int(timeout)),
        expand=False
    )
    task = progress.add_task("Overall Progress", total=timeout, completed=0)
    group = Group(progress, build_table(status, cells))
    try:
        with Live(group, console=console, refresh_per_second=5, auto_refresh=True) as live:
            while True:
                if max_reached.is_set():
                    if start is None:
                        start = time.monotonic()
                    elapsed = time.monotonic() - start
                    logger.warning(f"max reached is set!")
                    progress.update(task, completed=elapsed)

                else:
                    elapsed = 0
                    logger.warning(f"max reached is NOT set!")
                    progress.update(task, completed=0)

                group = Group(progress, build_table(status, cells))
                live.update(group)
                sys.stdout.flush()

                if elapsed >= timeout:
                    break

                await asyncio.sleep(0.2)

    except asyncio.CancelledError:
        sys.__stdout__.write("\n")
        sys.__stdout__.flush()
        raise
