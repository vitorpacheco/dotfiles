#!/bin/bash

eval "$(mise activate --shims)"
eval "$(mise activate bash)"

green "[JAVA] instalando o node"
mise use -g java@zulu-21

green "[JAVA] instalando o quarkus"
mise use -g quarkus

green "[JAVA] instalando o maven"
mise use -g maven

green "[JAVA] instalando o gradle"
mise use -g gradle
