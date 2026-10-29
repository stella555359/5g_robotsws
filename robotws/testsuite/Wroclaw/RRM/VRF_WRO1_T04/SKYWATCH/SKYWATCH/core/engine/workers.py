import asyncio
from collections import defaultdict

from core.RegexWatcher import logger


class Status:
    def __init__(self, cells):
        self.scenarios_active = {}
        self.background_done = 0
        self.background_active = 0
        self.scenarios_done = 0
        self.summary_active = 0
        for cell in cells:
            self.scenarios_active[cell] = 0
        self._lock = asyncio.Lock()

    async def increase_active(self, key: str):
        async with self._lock:
            self.scenarios_active[key] += 1
            self.summary_active += 1

    async def increase_active_background(self):
        async with self._lock:
            self.background_active += 1

    async def decrease_active(self, key: str):
        async with self._lock:
            self.scenarios_active[key] -= 1
            self.summary_active -= 1

    async def decrease_active_background(self):
        async with self._lock:
            self.background_active -= 1

    async def increase_scenarios_done(self):
        async with self._lock:
            self.scenarios_done += 1

    async def increase_background_done(self):
        async with self._lock:
            self.background_done += 1


async def worker(name, semaphore, queue, status: Status, cell: str):
    try:
        while True:
            async with semaphore:
                func, *args = await queue.get()
                try:
                    await status.increase_active(cell)
                    await func(*args)
                except asyncio.CancelledError:
                    raise
                except Exception as e:
                    logger.error(f"{name} main task failed in: {e}")
                finally:
                    queue.task_done()
                    await status.decrease_active(cell)
                    await status.increase_scenarios_done()
    except asyncio.CancelledError:
        raise


async def background_worker(queue: asyncio.Queue, status: Status, semaphore):
    try:
        while True:
            async with semaphore:
                try:
                    func, kwargs = await queue.get()
                except asyncio.CancelledError:
                    return
                try:
                    await status.increase_active_background()
                    await func(**kwargs)
                except asyncio.CancelledError:
                    raise
                except Exception as e:
                    logger.error("Background task failed: ", exc_info=e)
                finally:
                    queue.put_nowait((func, kwargs))
                    queue.task_done()
                    await status.decrease_active_background()
                    await status.increase_background_done()
    except asyncio.CancelledError:
        raise
