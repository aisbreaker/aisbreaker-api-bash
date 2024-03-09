#!/bin/bash

# basic settings
VERSION="0.1.0"

# defaults
INPUT_FORMAT="json"
OUTPUT_FORMAT="json"
DEFAULT_AISBREAKER_SERVER_URL="https://api.demo.aisbreaker.org"
AISBREAKER_SERVER_URL="${DEFAULT_AISBREAKER_SERVER_URL}"

# function to display usage
function usage() {
  echo "aisbreakter.sh - commandline AI accessor"
  echo ""
  echo "Usage: $0 [options]"
  echo "Receives request from stdin and prints the response to stdout."
  echo ""
  echo "aisbreakter.sh is a tool to provide a simple commandline"
  echo "interface to generative AI services of AIsBreaker.org,"
  echo "including OpenAI/ChatGPT, all Hugging Face AIs,"
  echo "Google Gemini AI, and more."
  echo ""
  echo "Options:"
  echo "  -a, --auth=<AUTH-STRING> Specify the authentication string."
  echo "                           Default: no authentication"
  echo "  -h, --help               Display this help message"
  echo "  -i, --input=[text|json]  Specify the input format (text or json),"
  echo "                           text means a user text prompt,"
  echo "                           json means AIsBreaker request (https://aisbreaker.org/docs/request)."
  echo "                           Default: text"
  echo "  -o, --output=[text|json] Specify the output format (text or json): Default: json"
  echo "                           text means a system text response,"
  echo "                           json means AIsBreaker response (https://aisbreaker.org/docs/response)."
  echo "                           Default: json"
  echo "  -p, --props=<PROPS-JSON-STRING>"
  echo "                           Specify the AIsBreaker service properties"
  echo "                           as json string (https://aisbreaker.org/docs/service-properties)."
  echo "                           Example: '--props={\"serviceId\": \"chat:openai.com\"}'"
  echo "                           Required. No default."
  echo "  -s, --session=<SESSION-STATE-FILE>"
  echo "                           Specify the session state file. Default: no session state"
  echo "  -u, --url=<AISBREAKER-SERVER-URL>"
  echo "                           Specify the AIsBreaker server URL."
  echo "                           Default: $AISBREAKER_SERVER_URL"
  echo "  -v, --verbose            Enable verbose mode"
  echo "  -V, --version            Print script version"
  exit 1
}

# function to display version
function version() {
  echo "Version: $0 $VERSION"
  exit 1
}

# Parse options
while (( "$#" )); do
  case "$1" in
    -h|--help)
      usage
      ;;
    -V|--version)
      version
      ;;
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
    --input=*|-i=*)
      INPUT_FORMAT="${1#*=}"
      shift
      ;;
    --input|-i)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        INPUT_FORMAT=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --output=*|-o=*)
      OUTPUT_FORMAT="${1#*=}"
      shift
      ;;
    --output|-o)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        OUTPUT_FORMAT=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --url=*|-u=*)
      AISBREAKER_SERVER_URL="${1#*=}"
      shift
      ;;
    --url|-u)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        AISBREAKER_SERVER_URL=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --session=*|-s=*)
      SESSION_STATE_FILE="${1#*=}"
      shift
      ;;
    --session|-s)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        SESSION_STATE_FILE=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --auth=*|-a=*)
      AUTH_STRING="${1#*=}"
      shift
      ;;
    --auth|-a)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        AUTH_STRING=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --props=*|-p=*)
      PROPS_JSON_STRING="${1#*=}"
      shift
      ;;
    --props|-p)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        PROPS_JSON_STRING=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --)
      shift
      break
      ;;
    -*|--*=)
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *)
      shift
      ;;
  esac
done

# Main script logic goes here
if [[ $VERBOSE == 1 ]]; then
  echo "Verbose mode is enabled" >&2
fi

# check input format: text or json
if [[ $INPUT_FORMAT != "text" ]] && [[ $INPUT_FORMAT != "json" ]]; then
  echo "Error: Input format must be either text or json" >&2
  exit 1
fi
# check output format: text or json
if [[ $OUTPUT_FORMAT != "text" ]] && [[ $OUTPUT_FORMAT != "json" ]]; then
  echo "Error: Output format must be either text or json" >&2
  exit 1
fi

# check AISBreaker server URL
if [[ -z $AISBREAKER_SERVER_URL ]]; then
  echo "Error: AIsBreaker server URL is required" >&2
  exit 1
fi

# output settings
# if verbose
if [[ $VERBOSE == 1 ]]; then
  if [[ -n $INPUT_FORMAT ]]; then
    echo "Input format is set to $INPUT_FORMAT" >&2
  fi
  if [[ -n $OUTPUT_FORMAT ]]; then
    echo "Output format is set to $OUTPUT_FORMAT" >&2
  fi
  if [[ -n $SESSION_STATE_FILE ]]; then
    echo "Session state file is set to $SESSION_STATE_FILE" >&2
  fi
  if [[ -n $AUTH_STRING ]]; then
    echo "Authentication string is set to $AUTH_STRING" >&2
  fi
  if [[ -n $PROPS_JSON_STRING ]]; then
    echo "Properties JSON string is set to $PROPS_JSON_STRING" >&2
  fi
  if [[ -n $AISBREAKER_SERVER_URL ]]; then
    echo "AIsBreaker server URL is set to $AISBREAKER_SERVER_URL" >&2
  fi
fi

# check that tool curl is installed
if ! [ -x "$(command -v curl)" ]; then
  echo 'Error: curl is not installed but required.' >&2
  exit 1
fi
# check that tool jq is installed
if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed but required.' >&2
  exit 1
fi
