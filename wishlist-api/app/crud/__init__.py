# ==========================================
# CRUD MODULE INITIALIZATION
# ==========================================
# By importing the modules here, we encapsulate the CRUD layer.
# This allows routers to import the entire 'crud' package cleanly,
# rather than importing individual functions from specific files.

from . import user
from . import gift
from . import wishlist
from . import tag
from . import booking
from . import subscription