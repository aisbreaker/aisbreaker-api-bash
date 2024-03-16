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
Before start using the tool, you need to decide which generative AI service you want to use. On the [Services](https://aisbreaker.org/docs/services) page you find a list of available services and of their serviceIds. The following examples all use the serviceId `chat:openai.com`. By using a different serviceId you access a different AI service.

In all examples below, we'll conveniently use the free `api.demo.aisbreaker.org` server. The server doesn't store any data or credentials. Feel free to install your own [AIsBreaker server](https://aisbreaker.org/docs/aisbreaker-server).

To get a tool description run:
```bash
./aisbreaker.sh --help
```


### Minimal Usage
The following example command just sends a simple text prompt (from stdin) to the AI service
```
echo "What is Nodejs?" | ./aisbreaker.sh --service=chat:openai.com
```
and shows the text response (on stdout):
```
Node.js is an open-source, server-side platform built on Chrome's V8 JavaScript engine. It allows developers to build scalable network applications using JavaScript. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, making it ideal for data-intensive real-time applications. It is commonly used for building web servers, APIs, and other networking applications.
```


### A typical Chat Conversation
In a chat conversation you need to keep the state of the conversation. This can be done by using a state file specified with the `--state` option. The following example shows a conversation with two prompts in the same session:
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


### More Usage Examples
See: [Getting Started - with Bash Shellscript](https://aisbreaker.org/docs/getting-started-with-bash#maximal-usage)


Features for Later
------------------
Not implemented yet:
* nice handling of (binary) input and output files (images, audios, videos)

