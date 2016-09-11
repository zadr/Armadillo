# Armadillo
## What?
A REPL for (almost) anything

## How?
### Quickstart
% armadillo [-cmd foo] [-path path/to/directory]

- Without specifying a `-path` argument, `armadillo` defaults to the currently opened directory.
- Without specifying a `-cmd` argument, `armadillo will try to guess what you want a REPL for. This is currently limited to `mercurial`, `svn`, and `git` repositories.

### Example session
```
% git clone https://nombytes.com/z/Armadillo.git armadillo-src

% armadillo -path armadillo-src

armadillo-src % # the default prompt of an `armadillo` session

armadillo-src % git status
On branch main
nothing to commit, working directory clean

armadillo-src % checkout -b readme-has-example-session
Switched to a new branch 'readme-has-example-session'

$ # edit the readme in an app that supports Markdown

armadillo-src % commit -am "update readme with sample session"
[readme-has-example-session ea5e1] update readme with sample session
 1 file changed, 26 insertions(+)

armadillo-src % push origin readme-has-example-session
Writing objects: 100% (3/3), 880 bytes | 0 bytes/s, done.
Total 3 (delta 2), reused 0 (delta 0)
To git@nombytes.com:z/Armadillo.git
   1eaf...ea5e1  readme-has-example-session -> readme-has-example-session

armadillo-src % git ^C # control-C closes the current session
```

## Why?
[Automation](https://xkcd.com/1319/) that [probably isn't worth the time](https://xkcd.com/1205/) but is still fun.

## Where?
The project home can be found [here](https://nombytes.com/z/Armadillo), but is also mirrored on [github](https://github.com/zadr/Armadillo).

## License?
[Simplified BSD License](./LICENSE.md).

# Code of Conduct?
Yup. [Read it here](./CONDUCT.md).
