#!/bin/bash

# Runs the Melissa Elected Officials Cloud API Python 3 sample.
#
# This script runs ElectedOfficialsPython3.py with python3, passing along the license and
# (if supplied) the latitude, longitude, search location, and max results.
#
# Overall flow:
#   1. Parse the command-line options below.
#   2. Resolve the license (--license, then a prompt, then the MD_LICENSE environment variable).
#   3. Run ElectedOfficialsPython3.py: with the location inputs if a latitude or longitude
#      was supplied, otherwise with only the license (the Python program prompts for the
#      inputs).
#
# Options (each takes a value):
#   --lat       Latitude of the location to look up.
#   --long      Longitude of the location to look up.
#   --location  Free-form search location, such as a street address.
#   --max       Maximum number of elected officials to return.
#   --license   License string. If omitted, the script prompts for it; if the prompt
#               is left blank, it falls back to MD_LICENSE. Running without --license
#               always prompts, even when MD_LICENSE is set.
#
# Examples:
#   ./ElectedOfficialsPython3.sh --license "your-license"
#   ./ElectedOfficialsPython3.sh --lat "33.637520" --long "-117.606920" --location "22382 Avenida Empresa, Rancho Santa Margarita, CA, 92688" --max "1" --license "your-license"

######################### Constants ##########################

RED='\033[0;31m' #RED
NC='\033[0m' # No Color

######################### Parameters ##########################

lat=""
long=""
location=""
license=""
max=""

# Read each --flag and its value. A flag with no value, or whose value looks like another
# flag (e.g. "--max"), is an error. Negative numbers such as "-117.606920" are accepted.
# Unrecognized options are ignored.
while [ $# -gt 0 ] ; do
  case $1 in
    --lat)
        if [ -z "$2" ] || [[ $2 =~ ^--?[a-zA-Z]+$ ]];
        then
            printf "${RED}Error: Missing an argument for parameter 'lat'.${NC}\n"
            exit 1
        fi
        lat="$2"
        shift
        ;;
    --long)
        if [ -z "$2" ] || [[ $2 =~ ^--?[a-zA-Z]+$ ]];
        then
            printf "${RED}Error: Missing an argument for parameter 'long'.${NC}\n"
            exit 1
        fi
        long="$2"
        shift
        ;;
    --location)
        if [ -z "$2" ] || [[ $2 =~ ^--?[a-zA-Z]+$ ]];
        then
            printf "${RED}Error: Missing an argument for parameter 'location'.${NC}\n"
            exit 1
        fi
        location="$2"
        shift
        ;;
    --max)
        if [ -z "$2" ] || [[ $2 =~ ^--?[a-zA-Z]+$ ]];
        then
            printf "${RED}Error: Missing an argument for parameter 'max'.${NC}\n"
            exit 1
        fi
        max="$2"
        shift
        ;;
    --license)
        if [ -z "$2" ] || [[ $2 =~ ^--?[a-zA-Z]+$ ]];
        then
            printf "${RED}Error: Missing an argument for parameter 'license'.${NC}\n"
            exit 1
        fi
        license="$2"
        shift
        ;;
  esac
  shift
done

########################## Main ############################
printf "\n=================================== Melissa Elected Officials Cloud API =====================================\n"

# Get license (either from parameters or user input)
if [ -z "$license" ];
then
  printf "Please enter your license string: "
  read license
fi

# Check for License from Environment Variables 
if [ -z "$license" ];
then
  license=`echo $MD_LICENSE` 
fi

if [ -z "$license" ];
then
  printf "\nLicense String is invalid!\n"
  exit 1
fi

# Run project
# No latitude or longitude supplied -> run with only the license (the program prompts);
# otherwise pass all of the inputs through.
if [ -z "$lat" ] && [ -z "$long" ];
then
    python3 ElectedOfficialsPython3.py --license $license 
else
    python3 ElectedOfficialsPython3.py --license $license --lat "$lat" --long "$long" --location "$location" --max "$max"
fi

