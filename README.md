# aisbreaker.sh

## Introduction
`aisbreaker.sh` is a tool to provide a simple commandline
interface to generative AI services of [AIsBreaker.org](https://aisbreaker.org/),
including OpenAI/ChatGPT, all Hugging Face AIs,
Google Gemini AI, and more.

For all UNIX-based systems with `bash`.

A nice introduction is: [Getting Started - with Bash Shellscript](https://aisbreaker.org/docs/getting-started-with-bash)


## Installation
First make sure, that the tools `bash`, `curl` and `jq` are installed and in the PATH of your system.

Then download `aisbreaker.sh`:
```
curl -o ./aisbreaker.sh https://raw.githubusercontent.com/aisbreaker/aisbreaker-api-bash/main/aisbreaker.sh
chmod a+x ./aisbreaker.sh
```

Finally check the script:
```
./aisbreaker.sh --version
```


## Usage

Get a tool description:
```
./aisbreaker.sh --help
```

Decide which [service(Id)](https://aisbreaker.org/docs/services) you want to use. The following examples all use `chat:openai.com`. By using a different serviceId you access a different AI service.


### Minimal Usage
Example:
```
echo "What is Nodejs?" | ./aisbreaker.sh --service=chat:openai.com
```
will show output like:
```
Node.js is an open-source, server-side platform built on Chrome's V8 JavaScript engine. It allows developers to build scalable network applications using JavaScript. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, making it ideal for data-intensive real-time applications. It is commonly used for building web servers, APIs, and other networking applications.
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
will show output like:
```
./aisbreaker-state-vFZKys3z

Node.js is an open-source, server-side platform built on Chrome's V8 JavaScript engine. It allows developers to build scalable network applications using JavaScript. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, making it ideal for data-intensive real-time applications. It is commonly used for building web servers, APIs, and other networking applications.

Node.js is a JavaScript runtime environment that allows developers to run server-side applications. It is known for its efficiency and scalability in building network applications.
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

will show output like:
```
./aisbreaker-state-4QrRBoAn
Verbose mode is enabled
Input format is set to 'json'
Output format is set to 'json'
Properties JSON string is set to '{"serviceId": "chat:dummy"}'
Service ID is set to 'chat:openai.com'
Session/conversation state file is set to './aisbreaker-state-4QrRBoAn'
AIsBreaker server URL is set to 'https://api.demo.aisbreaker.org'
Input JSON: {
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
State file exists: ./aisbreaker-state-4QrRBoAn
Request with: '{
  "service": {
    "serviceId": "chat:openai.com"
  },
  "request": {
    "inputs": [
      {
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
      }
    ],
    "stream": false
  }
}'

{
  "outputs": [
    {
      "text": {
        "index": 0,
        "role": "assistant",
        "content": "Yo, Node.js be a runtime environment that lets you run JavaScript on the server side,\nIt's open-source and fast, it's dope for building scalable applications and APIs worldwide.\nYeah, it uses event-driven, non-blocking I/O model,\nSo it's efficient and can handle lots of connections without hitting a bottleneck, yo.\n\nNode.js be versatile, can be used for all kinds of things,\nLike web servers, IoT devices, and even desktop apps, it brings.\nIt's got a huge ecosystem with tons of packages and modules,\nSo you can find what you need and build your project without any troubles.\n\nRespect to Ryan Dahl for creating this game-changing technology,\nNode.js be revolutionizing the way we code and serve our society.\nIf you wanna level up your dev skills, better get familiar with Node.js quick,\n'Cause it's the future of server-side programming, ain't no denying it.",
        "isDelta": false,
        "isProcessing": false
      }
    }
  ],
  "conversationState": "eyJ...",
  "usage": {
    "service": {
      "serviceId": "chat:openai.com",
      "engine": "gpt-3.5-turbo-1106",
      "url": "https://api.openai.com/v1/chat/completions"
    },
    "totalMilliseconds": 3035
  },
  "internResponse": ...
  }
}

Yo, Node.js be a runtime for running JavaScript on servers,
It's fast and scalable, handling connections like champs, no nerves.
From web servers to IoT, it's versatile in its use,
With a huge ecosystem of packages, it's the one to choose.
```


Features for Later
------------------
Not implemented yet:
* nice handling of (binary) input and output files (images, audios, videos)

