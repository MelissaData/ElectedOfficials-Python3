<#
.SYNOPSIS
    Runs the Melissa Cicero Cloud API Python 3 sample.

.DESCRIPTION
    This script runs CiceroPython3.py with python3, passing along the license
    and (if supplied) the location fields.

    Overall flow:
      1. Resolve the license (parameter, prompt, or MD_LICENSE environment variable).
      2. Run CiceroPython3.py: with the location fields if any was supplied, otherwise
         with only the license (the Python program prompts for each field).

.PARAMETER lat
    Latitude of the location.

.PARAMETER long
    Longitude of the location.

.PARAMETER location
    Address or place to search.

.PARAMETER max
    Maximum number of results to return.

.PARAMETER license
    License string. Resolved in this order:
      1. This parameter.
      2. An interactive prompt, if the parameter was not supplied.
      3. The MD_LICENSE environment variable, if the prompt was left blank.
    Note that the environment variable is the last resort, not the first: running
    without -license always prompts, even when MD_LICENSE is set.

.PARAMETER quiet
    Accepted for parity with other sample scripts; not currently used to suppress output.

.EXAMPLE
    .\CiceroPython3.ps1 -license "your-license"

.EXAMPLE
    .\CiceroPython3.ps1 -lat "33.637562" -long "-117.606887" -location "22382 Avenida Empresa, Rancho Santa Margarita, CA" -max "3" -license "your-license"
#>

######################### Parameters ##########################
param(
    $lat = '', 
    $long = '',
    $location = '',
    $max = '',
    $license = '', 
    [switch]$quiet = $false
    )

########################## Main ############################
Write-Host "`n===================================== Melissa Cicero Cloud API ===================================`n"

# Get license (either from parameters or user input)
if ([string]::IsNullOrEmpty($license) ) {
  $license = Read-Host "Please enter your license string"
}

# Check for License from Environment Variables 
if ([string]::IsNullOrEmpty($license) ) {
  $license = $env:MD_LICENSE 
}

if ([string]::IsNullOrEmpty($license)) {
  Write-Host "`nLicense String is invalid!"
  Exit
}

# Run project
# No location fields supplied -> run with only the license (the program prompts);
# otherwise pass every field through.
if ([string]::IsNullOrEmpty($lat) -and [string]::IsNullOrEmpty($long) -and [string]::IsNullOrEmpty($location) -and [string]::IsNullOrEmpty($max)) {
  python3 CiceroPython3.py --license $license 
}
else {
  python3 CiceroPython3.py --license $license --lat $lat --long $long --location $location --max $max
}
