#!/bin/bash

# Standard exit codes following GNU conventions
declare -r EXIT_SUCCESS=0       # Successful execution
declare -r EXIT_ERROR=1         # General errors
declare -r EXIT_INVALID_USAGE=2 # Invalid command usage
declare -r EXIT_TEMP_FAIL=75    # Temporary failure
declare -r EXIT_PERM_FAIL=77    # Permanent failure
declare -r EXIT_CONFIG=78       # Configuration error
