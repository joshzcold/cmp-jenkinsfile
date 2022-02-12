# cmp-jenkinsfile

simple completion utilizing the `IntelliJ IDEA GDSL` file that gets generated for installed jenkins plugins. 

*example gdsl*

```
method(name: 'parallel', type: 'Object', params: ['closures':'java.util.Map'], doc: 'Execute in parallel')
method(name: 'parallel', type: 'Object', namedParams: [parameter(name: 'closures', type: 'java.util.Map'), parameter(name: 'failFast', type: 'boolean'), ], doc: 'Execute in parallel')
```

## demo

![example gif](./docs/example.gif)

## options

**jenkins_url**: full jenkins url to download the gdsl from.
  
example: `http://jenkins.lab/`

`/pipeline-syntax/gdsl` will automatically be append to the end of the url.

**gdsl_file**: full path to either download to or statically read from.

If `jenkins_url` is supplied then this file will be written to. If `jenkins_url` is blank then only read from the supplied path

defaults to: `$HOME/.cache/nvim/cmp-jenkinsfile.gdsl`


**Recommended Config:**

```lua
cmp.setup({
  cmp.setup.filetype("Jenkinsfile", {
    sources = {
      {
        name = "jenkinsfile",
        option = {
          jenkins_url = "https://jenkins.co",
        },
      },
    },
  }),
```
