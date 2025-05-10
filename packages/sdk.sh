#!/bin/bash

eval "$(mise activate --shims)"
eval "$(mise activate bash)"

if command -v java &>/dev/null; then
  yellow "[JAVA] java já instalado"
else
  green "[JAVA] instalando o node"
  mise use -g java@zulu-21
fi

if command -v quarkus &>/dev/null; then
  yellow "[JAVA] quarkus já instalado"
else
  green "[JAVA] instalando o quarkus"
  mise use -g quarkus
fi

if command -v mvn &>/dev/null; then
  yellow "[JAVA] maven já instalado"
else
  green "[JAVA] instalando o maven"
  mise use -g maven
fi

if command -v gradle &>/dev/null; then
  yellow "[JAVA] gradle já instalado"
else
  green "[JAVA] instalando o gradle"
  mise use -g gradle
fi

if command -v spring &>/dev/null; then
  yellow "[JAVA] spring-boot já instalado"
else
  green "[JAVA] instalando o spring-boot"
  mise use -g spring-boot
fi

