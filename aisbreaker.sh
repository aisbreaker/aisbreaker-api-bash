#!/bin/bash

# basic settings
VERSION="0.1.1"

# defaults
DEFAULT_INPUT_FORMAT="text"
DEFAULT_OUTPUT_FORMAT="text"
DEFAULT_SERVICE_ID="chat:dummy"
DEFAULT_PROPS_JSON_STRING="{\"serviceId\": \"${DEFAULT_SERVICE_ID}\"}"
DEFAULT_AISBREAKER_SERVER_URL="https://api.demo.aisbreaker.org"
DEFAULT_CURL_OPTS=""

# initialize variables
INPUT_FORMAT="${DEFAULT_INPUT_FORMAT}"
OUTPUT_FORMAT="${DEFAULT_OUTPUT_FORMAT}"
SERVICE_ID="${DEFAULT_SERVICE_ID}"
PROPS_JSON_STRING="${DEFAULT_PROPS_JSON_STRING}"
AISBREAKER_SERVER_URL="${DEFAULT_AISBREAKER_SERVER_URL}"
CURL_OPTS="${DEFAULT_CURL_OPTS}"


# function to check for required tools and exit 1 in the case of an error
function check_tools() {
  ERROR=0

  # check that tool curl is installed
  if ! [ -x "$(command -v curl)" ]; then
    echo 'Error: curl is not installed but required.' >&2
    ERROR=1
  fi
  # check that tool jq is installed
  if ! [ -x "$(command -v jq)" ]; then
    echo 'Error: jq is not installed but required.' >&2
    ERROR=1
  fi

  # exit?
  if [[ $ERROR == 1 ]]; then
    exit 1
  fi
}

# function to display usage/help message
function usage() {
  echo "aisbreakter.sh - commandline AI accessor (version: $VERSION)"
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
  echo "                           Default: ${DEFAULT_INPUT_FORMAT}"
  echo "  -o, --output=[text|json] Specify the output format (text or json): Default: json"
  echo "                           text means a system text response,"
  echo "                           json means AIsBreaker response (https://aisbreaker.org/docs/response)."
  echo "                           Default: ${DEFAULT_OUTPUT_FORMAT}"
  echo "  -p, --props=<PROPS-JSON-STRING>"
  echo "                           Specify the AIsBreaker service properties"
  echo "                           as json string (https://aisbreaker.org/docs/service-properties)."
  echo "                           Example: '--props={\"serviceId\": \"chat:openai.com\"}'"
  echo "                           Default: props with serviceId only as specified with --service."
  echo "  -s, --service=<SERVICE-ID>"
  echo "                           Specify the serviceId. Overwrites serviceId in service properties."
  echo "                           Full list: (https://aisbreaker.org/docs/services)"
  echo "                           Example: chat:openai.com"
  echo "                           Default: chat:dummy"
  echo "  -S, --state=<CONVERSATION-STATE-FILE>"
  echo "                           Specify the session/conversation state file."
  echo "                           Default: no state"
  echo "  -u, --url=<AISBREAKER-SERVER-URL>"
  echo "                           Specify the AIsBreaker server URL."
  echo "                           Default: $AISBREAKER_SERVER_URL"
  echo "  -c, --curlopts=<CURL-OPTIONS>"
  echo "                           Specify additional curl options."
  echo "                           The --silent should always be included."
  echo "                           Default: ${DEFAULT_CURL_OPTS}"
  echo "  -v, --verbose            Enable verbose mode"
  echo "  -V, --version            Print script version"

  # check for required tools
  check_tools

  exit 1
}

# function to display version
function version() {
  # print version
  echo "Version: $0 $VERSION"

  # check for required tools
  check_tools

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
    --curlopts=*|-c=*)
      CURL_OPTS="${1#*=}"
      shift
      ;;
    --curlopts|-c)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        CURL_OPTS=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --service=*|-s=*)
      SERVICE_ID="${1#*=}"
      shift
      ;;
    --service|-s)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        SERVICE_ID=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --state=*|-S=*)
      CONVERSATION_STATE_FILE="${1#*=}"
      shift
      ;;
    --state|-S)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        CONVERSATION_STATE_FILE=$2
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

#
# Argument checks
#
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

# check service properties
if [[ -z $PROPS_JSON_STRING ]]; then
  echo "Error: Service properties (-p, --props) required" >&2
  exit 1
fi
if ! jq -e . >/dev/null 2>&1 <<<"$PROPS_JSON_STRING"; then
  echo "Error: Service properties string is not valid JSON: $PROPS_JSON_STRING" >&2
  exit 1
fi

#
# output settings
# if verbose
#
if [[ $VERBOSE == 1 ]]; then
  if [[ -n $INPUT_FORMAT ]]; then
    echo "Input format is set to '$INPUT_FORMAT'" >&2
  fi
  if [[ -n $OUTPUT_FORMAT ]]; then
    echo "Output format is set to '$OUTPUT_FORMAT'" >&2
  fi
  if [[ -n $PROPS_JSON_STRING ]]; then
    echo "Properties JSON string is set to '$PROPS_JSON_STRING'" >&2
  fi
  if [[ -n $SERVICE_ID ]]; then
    echo "Service ID is set to '$SERVICE_ID'" >&2
  fi
  if [[ -n $CONVERSATION_STATE_FILE ]]; then
    echo "Session/conversation state file is set to '$CONVERSATION_STATE_FILE'" >&2
  fi
  if [[ -n $AUTH_STRING ]]; then
    # echom, but replace every char by a dot
    AUTH_STRING_HIDDEN=$(sed -e 's/./*/g' <<<"$AUTH_STRING")
    echo "Authentication string is set to '$AUTH_STRING_HIDDEN' (masked)" >&2
  fi
  if [[ -n $AISBREAKER_SERVER_URL ]]; then
    echo "AIsBreaker server URL is set to '$AISBREAKER_SERVER_URL'" >&2
  fi
fi

# check for required tools
check_tools

#
# read and check input
#
if [[ $INPUT_FORMAT == "json" ]]; then
  #
  # read and check JSON input from stdin
  #

  # read input from stdin
  INPUT_JSON=$(cat)
  if [[ $VERBOSE == 1 ]]; then
    echo "Input JSON: $INPUT_JSON" >&2
  fi
  # check input JSON
  if [[ -z $INPUT_JSON ]]; then
    echo "Error: Input JSON is empty" >&2
    exit 1
  fi
  # check input JSON
  if ! jq -e . >/dev/null 2>&1 <<<"$INPUT_JSON"; then
    echo "Error: Input JSON is not valid" >&2
    exit 1
  fi
  # check input JSON
  if ! jq -e .inputs[0].text.content >/dev/null 2>&1 <<<"$INPUT_JSON"; then
    echo "Error: Input JSON does not contain a prompt (inputs[0].text.content)" >&2
    exit 1
  fi
  # check input JSON
  if ! jq -e .serviceId >/dev/null 2>&1 <<<"$PROPS_JSON_STRING"; then
    echo "Error: props JSON does not contain serviceId" >&2
    exit 1
  fi
elif [[ $INPUT_FORMAT == "text" ]]; then
  #
  # read input from stdin and convert to JSON
  #

  # read input from stdin
  INPUT_TEXT=$(cat)
  if [[ $VERBOSE == 1 ]]; then
    echo "Input TEXT: $INPUT_TEXT" >&2
  fi

  # create input JSON
  INPUT_JSON='{
    "inputs": [ {
      "text": {
        "role": "user",
        "content": ""
      }
    } ]
  }'
  INPUT_JSON=$(jq --arg content "$INPUT_TEXT" '.inputs[0].text.content = $content' <<<"$INPUT_JSON")
  if [[ $VERBOSE == 1 ]]; then
    echo "Input TEXT as JSON: $INPUT_JSON" >&2
  fi
fi

#
# put all argument together to build a request
#

# set serviceId
if [[ -n $SERVICE_ID ]]; then
  # overwrite serviceId in props
  PROPS_JSON_STRING=$(jq --arg serviceId "$SERVICE_ID" '.serviceId = $serviceId' <<<"$PROPS_JSON_STRING")
fi
# add conversationState if available
if [[ -n $CONVERSATION_STATE_FILE ]] && [[ -f $CONVERSATION_STATE_FILE ]]; then
  # CONVERSATION_STATE_FILE file exists
  if [[ $VERBOSE == 1 ]]; then
    echo "State file exists: $CONVERSATION_STATE_FILE" >&2
  fi
  # read from file
  STATE=$(cat "$CONVERSATION_STATE_FILE")
  if [[ -n $STATE ]]; then
    # STATE is not empty
    if [[ $VERBOSE == 1 ]]; then
      echo "State before request (length): ${#STATE}" >&2
    fi
    # add state to input/request
    INPUT_JSON=$(jq --arg state "$STATE" '.conversationState = $state' <<<"$INPUT_JSON")
  fi
fi
# tune: never use streaming
INPUT_JSON=$(jq '.stream = false' <<<"$INPUT_JSON")

# create request JSON
REQUEST='{
  "service": { },
  "request": { }
}'
REQUEST=$(jq --argjson serviceProps "$PROPS_JSON_STRING" '.service = $serviceProps' <<<"$REQUEST")
REQUEST=$(jq --argjson inputs "$INPUT_JSON" '.request = $inputs' <<<"$REQUEST")
if [[ $VERBOSE == 1 ]]; then
  echo "Request with: '$REQUEST'" >&2
fi

# create authentication header
if [[ -n $AUTH_STRING ]]; then
  AUTH_HEADER_OPT1="--header"
  AUTH_HEADER_OPT2="Authorization: Bearer $AUTH_STRING"
fi

#
# do the HTTP request
#
RESPONSE=$(curl "${AISBREAKER_SERVER_URL}/api/v1/process" \
        --request POST \
        --silent \
        --fail-with-body \
        --header "Content-Type: application/json" \
        --header "user-agent: aisbreakter.sh/$VERSION" \
        ${AUTH_HEADER_OPT1} "${AUTH_HEADER_OPT2}" \
        ${CURL_OPTS} \
        --data "$REQUEST" \
        )
if [[ $VERBOSE == 1 ]]; then
  echo "Response/OUTPUT(s): '$RESPONSE'" >&2
fi

# (optionally) save session/conversation state to file
if [[ -n $CONVERSATION_STATE_FILE ]] ; then
  # extract state from response
  STATE=$(jq -r '.conversationState' <<<"$RESPONSE")
  if [[ -n $STATE ]]; then
    # STATE is not empty
    if [[ $VERBOSE == 1 ]]; then
      echo "State after response (length): ${#STATE}" >&2
    fi
    # save to file
    echo "$STATE" > "$CONVERSATION_STATE_FILE"
  fi
fi

# (optionally) convert response to text
if [[ $OUTPUT_FORMAT == "text" ]]; then
  # convert response to text
  if jq -e '.outputs[0].text.content' >/dev/null 2>&1 <<<"$RESPONSE"; then
    # text exists
    RESPONSE_TEXT=$(jq -r '.outputs[0].text.content' <<<"$RESPONSE")
    if [[ $VERBOSE == 1 ]]; then
      echo "Response as TEXT: $RESPONSE_TEXT" >&2
    fi
    # print response text to stdout
    echo "$RESPONSE_TEXT"
  else
    # text does not exist - probably an error message
    echo "Error: Response doesn't contain .outputs[0].text.content property" >&2
    echo "Full Response: '$RESPONSE'" >&2
    # keep and print response JSON to stdout
    echo "$RESPONSE"
  fi
else
  # keep and print response JSON to stdout
  echo "$RESPONSE"
fi
