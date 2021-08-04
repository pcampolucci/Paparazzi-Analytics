"""
Title: Main Converting Menu
Author: Pietro Campolucci
"""

from converter import Converter
import sys

# run function
message = sys.argv[1]
conversion = Converter(message)
conversion.convert()
