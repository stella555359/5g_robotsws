import sys
import time
import asyncio
from core.engine.workers import Status
from core.RegexWatcher import max_reached_scen, max_reached


def format_time(seconds):
    """Konwertuje czas w sekundach na format HH:MM:SS lub MM:SS jeśli krótszy niż godzina."""
    hours, remainder = divmod(int(seconds), 3600)
    minutes, sec = divmod(remainder, 60)
    if hours > 0:
        return f"{hours:02d}:{minutes:02d}:{sec:02d}"
    else:
        return f"{minutes:02d}:{sec:02d}"


async def progress_renderer(timeout: float, status: Status, cells, debug=False):
    # start = time.monotonic()
    start = None
    width = 10
    GREEN = '\033[32m'
    NC = '\033[0m'  # No Color
    done_sign = f"{GREEN}✔{NC}"
    active_sign = f"{GREEN}●{NC}"

    try:
        while True:
            if max_reached.is_set():
                if start is None:
                    start = time.monotonic()
                elapsed = time.monotonic() - start
            else:
                elapsed = 0
            ratio = min(elapsed / timeout, 1.0)
            filled = int(ratio * width)
            bar = "=" * filled + ">" + " " * (width - filled - 1)
            per_cells_active = ""
            for cell in cells:
                per_cells_active += f"{cell}: {status.scenarios_active[cell]:2d} "
            if debug:
                line = (
                    f"[{bar}] "
                    f"{format_time(elapsed)} / {format_time(timeout)} | "
                    f"bckg: {active_sign}{status.background_active:<3d} {done_sign}{status.background_done:<4d}"
                    f"scn: [{per_cells_active}] ==> {active_sign}{status.summary_active:<4d}"
                    f" {done_sign}{status.scenarios_done:<5d}"
                )
                sys.__stdout__.write("\r" + line.ljust(160))
                sys.__stdout__.flush()
            else:
                line = (
                    f"[{bar}] "
                    f"{format_time(elapsed)} / {format_time(timeout)} "
                    f"bckg:{active_sign}{status.background_active:<3d} {done_sign}{status.background_done:<4d}"
                    f"scn:{active_sign}{status.summary_active:<3d} {done_sign}{status.scenarios_done:<5d}"
                )

                sys.__stdout__.write("\r" + line.ljust(82))
                sys.__stdout__.flush()

            if elapsed >= timeout:
                break

            await asyncio.sleep(0.2)

    except asyncio.CancelledError:
        sys.__stdout__.write("\n")
        sys.__stdout__.flush()
        raise
