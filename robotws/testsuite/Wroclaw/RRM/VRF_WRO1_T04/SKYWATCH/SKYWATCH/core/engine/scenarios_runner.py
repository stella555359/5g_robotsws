import asyncio
from core.engine.semaphore import background_controller, scenarios_controller
from core.engine.workers import background_worker, worker
from core.RegexWatcher import logger, max_reached


async def run_background_scenarios(queue, semaphore, sem_back_limit, status):
    actual_queue = asyncio.Queue()
    try:
        async with asyncio.TaskGroup() as tg:
            tg.create_task(background_controller(actual_queue, queue, semaphore, sem_back_limit))
            for _ in range(sem_back_limit):
                tg.create_task(background_worker(actual_queue, status, semaphore))
    except asyncio.TimeoutError:
        logger.warning("BACKGROUND TASKS REACHED TIMEOUT. Stopping now...")
    except asyncio.CancelledError:
        raise


async def run_scenarios(queue, semaphore, sem_limit, status, cell):
    workers = []
    try:
        workers = [asyncio.create_task(worker(f"W{i}_{cell}", semaphore, queue, status, cell))
                   for i in range(sem_limit)]
        asyncio.create_task(scenarios_controller(semaphore, sem_limit))
        await queue.join()
    except asyncio.CancelledError:
        raise
    finally:
        for w in workers:
            w.cancel()
        await asyncio.gather(*workers, return_exceptions=True)
