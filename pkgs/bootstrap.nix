{
  writeShellScriptBin,
} :
  writeShellScriptBin "bootstrap" ''
    #!/bin/bash

echo "I'm a bootstrap script"
''
