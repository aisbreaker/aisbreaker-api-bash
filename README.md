# aisbreaker-api-bash


Installation
------------

TO BE WRITTEN (download with curl)


Usage
-----

Get a detailled description:
```
./aisbreaker.sh --help
```


Minimal usage:
```
echo "What is Nodejs?" | ./aisbreaker.sh --service=chat:openai.com
```

Typical usage:
```
echo "What is Nodejs?" | ./aisbreaker.sh \
  --verbose \
  --input=text \
  --output=json \
  --service=chat:openai.com \
  --session=/tmp/ais-session-1 \
  --url=https://api.demo.aisbreaker.org 
```

Maximal usage:
TO BE WRITTEN
```
echo "What is Nodejs?" | ./aisbreaker.sh \
  --verbose \
  --input=text \
  --output=json \
  --session=./ais-session-1 \
  '--props={"serviceId":"chat:openai.com"}' \
  --url=https://api.demo.aisbreaker.org 
```


Features for Later
------------------
Not implemented yet:
* handling of (binary) input and output files (images, audios, videos)
* ...

