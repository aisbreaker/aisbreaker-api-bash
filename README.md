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
echo "What is Nodejs?" | ./aisbreaker.sh '--props={"serviceId":"chat:openai.com"}'
```

Typical usage:
```
echo "What is Nodejs?" | ./aisbreaker.sh \
  --input=text \
  --output=json \
  --session=./ais-session-1 \
  '--props={"serviceId":"chat:openai.com"}' \
  --url=https://api.demo.aisbreaker.org 
```

Maximal usage:
TO BE WRITTEN


Features for Later
------------------
Not implemented yet:
* handling of (binary) input and output files (images, audios, videos)
* ...

