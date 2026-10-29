import asyncio
import sys
import time
import math
from core.RegexWatcher import logger, max_reached, max_reached_scen
from core.engine.progress_bar import format_time
from core.engine.workers import Status


class DynamicSemaphore:
    def __init__(self, initial: int):
        self._sem = asyncio.Semaphore(initial)
        self._limit = initial
        # self._lock = asyncio.Lock()

    async def __aenter__(self):
        await self.acquire()
        return self

    async def __aexit__(self, exc_type, exc, tb):
        self.release()

    async def acquire(self):
        await self._sem.acquire()

    def release(self):
        self._sem.release()

    async def increase_to(self, new_limit: int):
        # async with self._lock:
        delta = new_limit - self._limit
        if delta <= 0:
            self._limit = new_limit
            return
        self._limit = new_limit
        for _ in range(delta):
            self._sem.release()

    def debug_state(self):
        sem = self._sem
        waiters = getattr(sem, "_waiters", None)

        try:
            return {
                "limit": self._limit,
                "available": sem._value,
                "waiters": len(waiters) if waiters else 0,
                "waiters_is_none": waiters is None,
                }
        except Exception as e:
            logger.error(f"FOUND ERROR: {e}")
            return f"DEBUG ERROR {e}"


async def background_controller(actual_queue: asyncio.Queue,
                                queue: asyncio.Queue,
                                sem: DynamicSemaphore,
                                sem_back_limit: int):
    start = time.monotonic()
    step = 5
    limits = []
    remain = sem_back_limit % step
    # for _ in range(step):
    #     actual_queue.put_nowait(queue.get_nowait())
    for i in range(int(sem_back_limit / step)):
        limits.append((i + 1) * step)
    if remain > 0:
        if len(limits) == 0:
            limits.append(remain)
        else:
            limits.append(limits[-1] + remain)
    for limit in limits:
        try:
            for _ in range(limit):
                if not queue.empty():
                    actual_queue.put_nowait(queue.get_nowait())
            await sem.increase_to(limit)
            if limit != limits[-1]:
                await asyncio.sleep(5)
        except asyncio.QueueEmpty:
            logger.error("Reached main Queue empty!")


async def wait_for_stabilization_ues(status: Status, limit, background_sempahore):
    start = time.monotonic()
    while True:
        if status.background_active == background_sempahore:
            elapsed = time.monotonic() - start
            max_reached.set()
            logger.warning(f"\nDone! Total time: {format_time(elapsed)}\n")
            break
        await asyncio.sleep(1)
    start_scen = time.monotonic()
    while True:
        if status.summary_active == limit:
            elapsed_scen = time.monotonic() - start_scen
            max_reached_scen.set()
            logger.warning(f"\nDone! Total time: {format_time(elapsed_scen)}\n")
            break
        await asyncio.sleep(1)


async def scenarios_controller(sem: DynamicSemaphore, sem_limit: int):
    # start = time.monotonic()
    step = 5
    limits = []
    remain = sem_limit % step
    for i in range(int(sem_limit / step)):
        limits.append((i+1) * step)
    if remain > 0:
        limits.append(limits[-1] + remain)
    for limit in limits:
        try:
            await sem.increase_to(limit)
            if limit != limits[-1]:
                await asyncio.sleep(5)
        except asyncio.QueueEmpty:
            logger.error("Reached main Queue empty!")


def calculate_semaphore_max(limit, percentage):
    semaphore_dict = {}
    semaphore_ints = {}
    for key in percentage:
        semaphore_dict[key] = int(percentage[key][:-1]) * limit / 100
        semaphore_ints[key] = math.floor(semaphore_dict[key])
    missing = limit - sum(semaphore_ints.values())
    remainders = sorted(
        semaphore_dict.keys(),
        key=lambda key: semaphore_dict[key] - semaphore_ints[key],
        reverse=True
    )

    for key in remainders[:missing]:
        semaphore_ints[key] += 1
    return semaphore_ints
