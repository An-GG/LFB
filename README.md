# LFB: Large File Bucket

> **TODO:** this can be like really fast and legit viable + better than LFS. Right now this is slow bc git push is limited to 10 Mb/s network bandwidth.
> *life hack: turns out you can push to like 10 different repos in parallel and this gets you 10x the bandwidth (for github), easily max out your fiber connection.
>
> + disabling delta compression during git push makes this almost uncompromising (.git/ dir will use up 2x disk space so google drive remains relevant for now)



> i'm making this way too complicated, you can just use the --jobs for parallel clone works great (# can probably be even more than nproc since we're waiting on IO)

<img width="774" alt="Screenshot 2023-10-12 at 9 46 46 AM" src="https://github.com/An-GG/LFB/assets/20458990/4dd7c647-99ea-4553-99a2-630f119f89b9">

<br>sustained **1200mbps**  i could stare at this bandwidth meter all day 🤤

(a bit of lie, real val is abt 700mbps)

this is worth keeping as shell code

---

This repo contains scripts that automate splitting up large files into parts, which can be committed and pushed to git hosts, and to reassemble file parts into the original.

basically, solution for 
 
### **"i need to commit large files to a repo ASAP without changing my/my teammates' git workflow"**

----

## 2 super simple scripts 

- `./bin/file2parts` 
- `./bin/parts2file`

## usage

### turning big file into small parts
```bash
$ ./bin/file2parts bigfile.iso
File:   ./bigfile.iso
SHA256: 324db7d51f851df4ee17c8e91683a0173a4f92cfb5bf6a744470fe0c10dd19dd
Part Size: 1 MB
Verifying...    Done.   

Removed:
./bigfile.iso
Created:
./bigfile.iso.324db7d51f851df4ee17c8e91683a0173a4f92cfb5bf6a744470fe0c10dd19dd.parts
$ 
$ ls ./bigfile.iso.324db7d51f851df4ee17c8e91683a0173a4f92cfb5bf6a744470fe0c10dd19dd.parts
aa.part	al.part	aw.part	bh.part	bs.part	cd.part ...
```
> there's filename length issues w/ this strat for naming the file


and now you can commit and push this.

### turning parts into big file

```bash
$ ./bin/parts2file bigfile.iso.324db7d51f851df4ee17c8e91683a0173a4f92cfb5bf6a744470fe0c10dd19dd.parts 
Assembling...     Done.
324db7d51f851df4ee17c8e91683a0173a4f92cfb5bf6a744470fe0c10dd19dd < hash from filename
324db7d51f851df4ee17c8e91683a0173a4f92cfb5bf6a744470fe0c10dd19dd < hash of newly assembled file

Created:
./bigfile.iso
$ 
```

The output directory (ending in .parts) has the hash of the big file in the dirname for double checking after reassembly. 

## ~~submodules & advanced usage~~ 

**this shit kinda cringe ngl i just use it to split and combine**  

You probably don't want to commit even the split up file parts to your primary repo because this will make cloning and manipulating git history slow.

Also, the GitHub has 10GB limit / Project, so ideally each large file gets its own repo. 

`./file2parts` has some options to help with this, 


```bash
$ ./bin/file2parts -h

file2parts FILE_TO_SPLIT [opts]

	-m : also setup submodule repo
	-u : first half of git remote URL to use (ex. git@github.com:An-GG), default to same as parent
	-s : size for part files in MB, default to 1MB
	-c : when -m is used, will also try to create repo with gh (if installed) and push to remote
	-h : help


Available env vars:

	LFB_OPT_SUBMODULE=1
	LFB_GIT_REMOTE='...'
	LFB_PARTSIZE_MB=10
	LFB_CREATE_WITH_GH=1

```

Running `./bin/file2parts bigfile.iso -c -m -u "git@github.com:angg-lf"` will do everything, including setting up and pushing to a remote repository with `gh`. 
Also, here I use a different github organization path, where I store all my LFB .parts repositories.


`./bin/parts2file` will attempt to initialize and clone submodules automatically, so running it on a LFB .parts directory should just work.
