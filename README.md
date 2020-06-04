# configuration-builder

## What
A script used in building monolitic configuration files by including subsets of configuration.

This script is part of a bundle of script I use to build and deploy haproxy configuration from a git post-receive hook, thus allowing me to have a git repository where said haproxy configuration is split into readable files.

## Exemple
Given the following configuration repository:
```
.
├── back-ends
│   ├── be1.cfg
│   └── be2.cfg
├── front-ends
│   ├── http.cfg
│   ├── https.cfg
│   ├── project-1
│   │   ├── http.cfg
│   │   ├── https.cfg
│   │   └── redirect.cfg
│   └── project-2
│       └── http.cfg
└── main.cfg
```

`main.cfg`:
```
# some configuration file

include("front-ends/http.cfg")

include("front-ends/https.cfg")

include("back-ends/")
```

`front-ends/http.cfg`:
```
frontend http-in
    include("project-1/redirect.cfg")
    # include("project-2/http.cfg")
    include("project-1/http.cfg")
```

`front-ends/https.cfg`:
```
frontend https-in
    include("project-1/https.cfg")
```

The resulting output would be:
```
$ ./build main.cfg
## Source: main.cfg
# some configuration file

## Source: front-ends/http.cfg
frontend http-in
    ## Source: front-ends/project-1/redirect.cfg
    < front-ends/project-1/redirect.cfg content >
    # ## Source: front-ends/project-2/http.cfg
    # < front-ends/project-2/http.cfg content >
    ## Source: front-ends/project-1/http.cfg
    < front-ends/project-1/http.cfg content >

## Source: front-ends/https.cfg
frontend https-in
    ## Source: front-ends/project-1/https.cfg
    < front-ends/project-1/https.cfg content >

## Source: back-ends/be1.cfg
< back-ends/be1.cfg content >
## Source: back-ends/be2.cfg
< back-ends/be2.cfg content >
```
