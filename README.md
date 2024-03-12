# aisbreaker.sh

## Introduction
`aisbreaker.sh` is a tool to provide a simple commandline
interface to generative AI services of [AIsBreaker.org](https://aisbreaker.org/),
including OpenAI/ChatGPT, all Hugging Face AIs,
Google Gemini AI, and more.

For all UNIX-based systems with `bash`.


## Installation
First make sure, that the tools `bash`, `curl` and `jq` are installed and in the PATH of your system.

Then download `aisbreaker.sh`:
```
curl -s https://raw.githubusercontent.com/aisbreaker/aisbreaker-api-bash/main/aisbreaker.sh > ./aisbreaker.sh
chmod a+x ./aisbreaker.sh
```

Finally check the script:
```
./aisbreaker.sh --version
  # Version: ./aisbreaker.sh 0.1.1
```


## Usage

Get a tool description:
```
./aisbreaker.sh --help
```


### Minimal Usage
Example:
```
echo "What is Nodejs?" | ./aisbreaker.sh --service=chat:openai.com
```

### Typical Usage
Example with a conversation/state:
```
# preparation
STATEFILE=`mktemp ./aisbreaker-state-XXXXXXXX`; echo ${STATEFILE}

# first prompt
echo "What is Nodejs?" | ./aisbreaker.sh \
  --input=text \
  --output=text \
  --service=chat:openai.com \
  --state=${STATEFILE} \
  --url=https://api.demo.aisbreaker.org

# second prompt in the same session
echo "Shorter please" | ./aisbreaker.sh \
  --input=text \
  --output=text \
  --service=chat:openai.com \
  --state=${STATEFILE} \
  --url=https://api.demo.aisbreaker.org

# cleanup
rm ${STATEFILE}
```

### Maximal Usage
Example, with JSON input:
```
# preparation
STATEFILE=`mktemp ./aisbreaker-state-XXXXXXXX`; echo ${STATEFILE}

# system prompt and first user prompt, with JSON output
cat <<EOF | ./aisbreaker.sh \
  --verbose \
  --input=json \
  --output=json \
  --service=chat:openai.com \
  --state=${STATEFILE} \
  --auth="sk-MyOwnOpenaiKey" \
  --url=https://api.demo.aisbreaker.org
{
  "inputs": [{
    "text": {
      "role": "system",
      "content": "Talk like a rapper!"
    }
  },
  {
    "text": {
      "role": "user",
      "content": "What is Nodejs?"
    }
  }]
}
EOF

# second prompt in the same session, with text output
cat <<EOF | ./aisbreaker.sh \
  --input=json \
  --output=text \
  --service=chat:openai.com \
  --state=${STATEFILE} \
  --auth="sk-MyOwnOpenaiKey" \
  --url=https://api.demo.aisbreaker.org
{
  "inputs": [{
     "text": {
      "role": "user",
      "content": "Shorter please"
    }
  }]
}
EOF
```


Features for Later
------------------
Not implemented yet:
* nice handling of (binary) input and output files (images, audios, videos)

