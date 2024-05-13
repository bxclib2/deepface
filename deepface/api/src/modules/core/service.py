from functools import wraps
from deepface import DeepFace
# pylint: disable=broad-except

import threading

class Mlemaphore:
    """Like a Semaphore, but with atomic acquire(count). This version is thread-safe.

    Has a silly name until someone tells me what these are supposed to be called."""

    def __init__(self, value: int = 1):
        if value < 0:
            raise ValueError("Mlemaphore initial value must be >= 0")
        self._counter = value
        self._condition = threading.Condition()

    def acquire(self, count: int = 1) -> None:
        """Acquire count permits atomically, or wait until they are available."""
        with self._condition:
            while self._counter < count:
                self._condition.wait()
            self._counter -= count

    def locked(self, count: int = 1) -> bool:
        """Return True if acquire(count) would not return immediately."""
        return self._counter < count

    def release(self, count: int = 1) -> None:
        """Release count permits."""
        with self._condition:
            self._counter += count
            self._condition.notify_all()

global_mlemaphore = Mlemaphore(2)

def limit_requests(acquire_count=1):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            global_mlemaphore.acquire(acquire_count)
            try:
                return f(*args, **kwargs)
            finally:
                global_mlemaphore.release(acquire_count)
        return decorated_function
    return decorator

@limit_requests(1)
def represent(img_path, model_name, detector_backend, enforce_detection, align):
    try:
        result = {}
        embedding_objs = DeepFace.represent(
            img_path=img_path,
            model_name=model_name,
            detector_backend=detector_backend,
            enforce_detection=enforce_detection,
            align=align,
        )
        result["results"] = embedding_objs
        return result
    except Exception as err:
        return {"error": f"Exception while representing: {str(err)}"}, 400

@limit_requests(1)
def verify(
    img1_path, img2_path, model_name, detector_backend, distance_metric, enforce_detection, align
):
    try:
        obj = DeepFace.verify(
            img1_path=img1_path,
            img2_path=img2_path,
            model_name=model_name,
            detector_backend=detector_backend,
            distance_metric=distance_metric,
            align=align,
            enforce_detection=enforce_detection,
        )
        return obj
    except Exception as err:
        return {"error": f"Exception while verifying: {str(err)}"}, 400

@limit_requests(2)
def analyze(img_path, actions, detector_backend, enforce_detection, align):
    try:
        result = {}
        demographies = DeepFace.analyze(
            img_path=img_path,
            actions=actions,
            detector_backend=detector_backend,
            enforce_detection=enforce_detection,
            align=align,
            silent=True,
        )
        result["results"] = demographies
        return result
    except Exception as err:
        return {"error": f"Exception while analyzing: {str(err)}"}, 400
