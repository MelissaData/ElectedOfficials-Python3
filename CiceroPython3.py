"""
Cicero matches a location to its legislative districts and returns the elected
officials who represent it, along with their contact information.

High-level flow of this sample:
  1. ARGS    - main reads any --flag values off the command line with argparse.
  2. INPUT   - call_api fills in whatever wasn't supplied via interactive prompts.
  3. REQUEST - call_api builds the REST query string (license + input fields).
  4. CALL    - get_contents issues the GET request and pretty-prints the JSON response.

This sample is a thin HTTP client: it builds a query string, sends a GET request to
the Cicero Cloud API (official endpoint), and prints the JSON response.

Reference:
  - Documentation: https://docs.melissa.com/cloud-api/cicero/cicero-index.html
  - Release notes: https://releasenotes.melissa.com/cloud-api/cicero-api/
  - Result codes:  https://docs.melissa.com/melissa/result-codes/result-codes-index.html
"""

import json
from threading import local
import requests
import argparse
import urllib.parse

def main():
  """
  Entry point. Reads the optional command-line arguments, then hands control to
  call_api, which performs the actual request/response cycle.

  Recognized flags (each followed by its value, e.g. --location "22382 Avenida Empresa"):
  --license/-l, --lat, --long, --location, --max.
  Any flag not supplied is None, and call_api prompts for it interactively.
  """
  base_service_url = "https://app.cicerodata.com/"
  service_endpoint = "v3.1/official"

  # Create an ArgumentParser object
  parser = argparse.ArgumentParser(description='Cicero command line arguments parser')

  # Define the command line arguments
  parser.add_argument('--license', '-l', type=str, help='License key')
  parser.add_argument('--lat', type=str, help='Latitude')
  parser.add_argument('--long', type=str, help='Longitude')
  parser.add_argument('--location', type=str, help='Search Location')
  parser.add_argument('--max', type=str, help='Max')

  # Parse the command line arguments
  args = parser.parse_args()

  # Access the values of the command line arguments
  license = args.license
  latitude = args.lat
  longitude = args.long
  location = args.location
  max = args.max

  # Run the lookup with whatever values were passed on the command line.
  call_api(base_service_url, service_endpoint, license, latitude, longitude, location, max)

def get_contents(base_service_url, request_query):
    """
    Issues the GET request against the Cicero endpoint and pretty-prints
    the API call and the JSON response to the console.

    Args:
        base_service_url: The Cicero Cloud API base URL.
        request_query: The endpoint path plus query string built by call_api.
    """
    url = urllib.parse.urljoin(base_service_url, request_query)
    response = requests.get(url)

    # Re-serialize with indentation so the raw response is easier to read.
    obj = json.loads(response.text)
    pretty_response = json.dumps(obj, indent=4)

    print("\n============================================= OUTPUT =============================================\n")

    print("API Call: ")

    for i in range(0, len(url), 70):
        if i + 70 < len(url):
            print(url[i:i+70])
        else:
            print(url[i:len(url)])
    print("\nAPI Response:")
    print(pretty_response)

def call_api(base_service_url, service_endpoint, license, latitude, longitude, location, max):
    """
    Drives the interactive/CLI loop: gathers the input fields, builds and submits the
    REST query, prints the result, and optionally repeats for another record.

    It runs a single pass and exits when all four fields were supplied on the command
    line. Otherwise it loops, asking for a new record each pass until the user answers "N".

    Args:
        base_service_url: The Cicero Cloud API base URL.
        service_endpoint: The specific Cicero endpoint path to call.
        license: The Melissa license string sent with every request.
        latitude: Latitude of the location, or None to prompt for it.
        longitude: Longitude of the location, or None to prompt for it.
        location: An address or place to search, or None to prompt for it.
        max: The maximum number of results to return, or None to prompt for it.
    """
    print("\n=============================== WELCOME TO MELISSA CICERO CLOUD API ==============================\n")

    should_continue_running = True
    while should_continue_running:
        input_latitude = ""
        input_longitude = ""
        input_location = ""
        input_max = ""

        # No latitude, longitude or location was supplied via command line, so prompt
        # for every field.
        if not latitude and not longitude and not location:
            print("\nFill in each value to see results")
            input_latitude = input("Latitude: ")
            input_longitude = input("Longitude: ")
            input_location = input("Search Location: ")
            input_max = input("Max Return: ")
        else:
            # At least one field was supplied via command line; use those values as-is.
            input_latitude = latitude
            input_longitude = longitude
            input_location = location
            input_max = max

        # All four fields are required by this sample, so keep prompting for any
        # that are still missing.
        while not input_latitude or not input_longitude or not input_location or not input_max:
            print("\nFill in each value to see results")
            if not input_latitude:
                input_latitude = input("\nLatitude: ")
            if not input_longitude:
                input_longitude = input("\nLongitude: ")
            if not input_location:
                input_location = input("\nSearch Location: ")
            if not input_max:
                input_max = input("\nMax Return: ")

        # Map input fields to the API's expected query parameter names and
        # request a JSON response.
        inputs = {
            "format": "json",
            "max": input_max,
            "lat": input_latitude,
            "lon": input_longitude,
            "search_loc": input_location
        }

        print("\n============================================= INPUTS =============================================\n")
        print(f"\t   Base Service Url: {base_service_url}")
        print(f"\t  Service End Point: {service_endpoint}")
        print(f"\t           Latitude: {input_latitude}")
        print(f"\t          Longitude: {input_longitude}")
        print(f"\t    Search Location: {input_location}")
        print(f"\t                Max: {input_max}")

       # Create Service Call
        # Set the License String in the Request
        rest_request = f"&key={urllib.parse.quote_plus(license)}"

        # Set the Input Parameters
        for k, v in inputs.items():
            rest_request += f"&{k}={urllib.parse.quote_plus(v)}"

        # Build the final REST String Query
        rest_request = service_endpoint + f"?{rest_request}"

        # Submit to the Web Service.
        success = False
        retry_counter = 0

        while not success and retry_counter < 5:
            try: #retry just in case of network failure
                get_contents(base_service_url, rest_request)
                print()
                success = True
            except Exception as ex:
                retry_counter += 1
                print(ex)
                return

        is_valid = False;

        # If every field came from the command line, treat this as a one-shot run
        # rather than looping for additional records.
        if (latitude is not None) and (longitude is not None) and (location is not None) and (max is not None):
            inputline = latitude + longitude + location
        else:
            inputline = None

        if inputline is not None and inputline != "":
            is_valid = True
            should_continue_running = False

        # Otherwise ask whether to test another record. Keep prompting until we get a
        # valid Y/N. "N" ends the program; "Y" falls through to another pass.
        while not is_valid:
            test_another_response = input("\nTest another record? (Y/N)")
            if test_another_response != '':
                test_another_response = test_another_response.lower()
                if test_another_response == 'y':
                    is_valid = True
                elif test_another_response == 'n':
                    is_valid = True
                    should_continue_running = False
                else:
                    print("Invalid Response, please respond 'Y' or 'N'")

    print("\n============================= THANK YOU FOR USING MELISSA CLOUD API ==============================\n")

main()
