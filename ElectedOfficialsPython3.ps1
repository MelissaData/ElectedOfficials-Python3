<#
.SYNOPSIS
    Runs the Melissa Elected Officials Cloud API Python 3 sample.

.DESCRIPTION
    This script runs ElectedOfficialsPython3.py with python3, passing along the license
    and (if supplied) the latitude, longitude, search location, and max results.

    Overall flow:
      1. Resolve the license (parameter, prompt, or MD_LICENSE environment variable).
      2. Run ElectedOfficialsPython3.py: with the location inputs if any were supplied,
         otherwise with only the license (the Python program prompts for the inputs).

.PARAMETER lat
    Latitude of the location to look up.

.PARAMETER long
    Longitude of the location to look up.

.PARAMETER location
    Free-form search location, such as a street address.

.PARAMETER max
    Maximum number of elected officials to return.

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
    .\ElectedOfficialsPython3.ps1 -license "your-license"

.EXAMPLE
    .\ElectedOfficialsPython3.ps1 -lat "33.637520" -long "-117.606920" -location "22382 Avenida Empresa, Rancho Santa Margarita, CA, 92688" -max "1" -license "your-license"
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
Write-Host "`n===================================== Melissa Elected Officials Cloud API ===================================`n"

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
# No location inputs supplied -> run with only the license (the program prompts);
# otherwise pass all of the inputs through.
if ([string]::IsNullOrEmpty($lat) -and [string]::IsNullOrEmpty($long) -and [string]::IsNullOrEmpty($location) -and [string]::IsNullOrEmpty($max)) {
  python3 ElectedOfficialsPython3.py --license $license 
}
else {
  python3 ElectedOfficialsPython3.py --license $license --lat $lat --long $long --location $location --max $max
}
