# The idea of how to manage rpm packages with git

## Problem

Now I manage rpm packages like [this repo](https://github.com/paperboy-sqale/sqale-yum).

This repository has source and binary packages.In this way, I have these problems.

 * Files in this repo are so huge.So it takes long time to clone, pull, push and so on.
 * Files in this repo are src.rpm and rpm files only.They are binary files, so git is not usefull very much.

----

## Solution

This repo includes a sample build script(build.rb) and sample package directories(ffmpeg, memcached and ngx_openresty).

In this repo, we don't manage binary rpm packages.We only manage a spec file and other files if they are needed.

Build.rb build source/binary packages and sync to other servers.

This sample repo assume 3 package patterns.

### Pattern 1. ngx_openresty

In this pattern, all we have to manage is spec file only. 

Build.rb gets the source file in spec file and build source and binary rpm.


### Pattern 2. ffmpeg

In this pattern, package directory has a spec file, a patch file and ffmpeg preset files.

Build.rb gets the source file in spec file, copy other files to rpmbuild SOURCES directory and build source and binary rpm.


### Pattern 3. memcached

In this pattern, package directory has a spec file and source rpm file.

This is assume that we'd like change spec file slightly in the existing source rpm package.

We can get memcached source with spectool command, but cannot get memcachesd.sysv file listed in the spec file like this.

```
Source1:        memcached.sysv
```

So source rpm are inlucded in this directory.

----

## TODO

 * Brush up build script
 * Support git url for Source* in spec file
