# Set the package version here
__version__ = "0.0.1"

# Import public-facing functions
from .countdown import countdown, countdown_style

# Export public functions
__all__ = ["countdown", "countdown_style"]
