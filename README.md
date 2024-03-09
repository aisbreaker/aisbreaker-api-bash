# aisbreaker-api-bash

Usage
-----

```
# minimal usage
echo "What is Nodejs?" | ./aisbreaker.sh '--props={serviceId="chat:openai"}'
```


```
# typical usage    
echo "What is Nodejs?" | ./aisbreaker.sh \
  --input=text \
  --output=json \
  --session=./ais-session-1 \
  '--props={serviceId="chat:openai"}' \
  --url=https://api.demo.aisbreaker.org 
```


Features for Later
------------------
Not implemented yet:
* handling of (binary) input and output files (images, audios, videos)
* ...

