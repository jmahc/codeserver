FROM codercom/code-server:latest

EXPOSE 8443

VOLUME [ "${PWD}:/root/project" ]

# 1. Create a fonts, downloads and assets directory for the container.
# 2. Install `git` for SCM, `make` for `curl`, `curl` for downloading files, `unzip` for ZIP files and `fontconfig` for managing fonts.
# 3. This is a simpler version of `nvm`, called `n`, that installs the LTS version of node.
RUN mkdir /root/.fonts /root/downloads /root/assets /root/n \
  && apt install git make curl unzip fontconfig -y \
  && curl -L https://git.io/n-install | bash -s -- -y lts

# Add `n` to existing `$PATH` ENV variable, so that `node` and `npm` commands are available to the CLI.
ENV PATH $PATH:/root/n/bin

# Globally install some `npm` packages.
RUN npm i -g prettier eslint

# Font name and location on Google Drive.
ARG GDRIVE_FILENAME=OperatorMonoCollection.zip
ARG GDRIVE_FILEID=0B7Nsk2zJ4jK8UG82bHZSRTItYTA

# Download the fonts from Google Drive.
RUN curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${GDRIVE_FILEID}" > /dev/null \
  && curl -Lb ./cookie "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $NF}' ./cookie`&id=${GDRIVE_FILEID}" -o ${GDRIVE_FILENAME} \
  && rm -rf /root/project/cookie

# Move the downloaded zip file to the `/root/downloads` directory.
RUN mv ${GDRIVE_FILENAME} /root/downloads \
  # Unzip the files into the `/root/assets` directory.
  && unzip /root/downloads/${GDRIVE_FILENAME} -d /root/assets \
  # Remove the `__MACOSX` surplus/garbage.
  && rm -rf /root/assets/__MACOSX \
  # Move all of the "Operator Mono" fonts into the shared `/root/.fonts` directory
  && mv /root/assets/Operator\ Mono\ Collection/Operator\ Mono/OperatorMono-* /root/.fonts \
  # Move all of the "Operator Pro" fonts into the shared `/root/.fonts` directory
  && mv /root/assets/Operator\ Mono\ Collection/Operator\ Pro/OperatorPro-* /root/.fonts \
  # Move all of the "Operator ScreenSmart" fonts into the shared `/root/.fonts` directory
  && mv /root/assets/Operator\ Mono\ Collection/Operator\ ScreenSmart/OperatorSSm-* /root/.fonts \
  # Reset the font cache
  && fc-cache -f -v

# Set the `npm init` defaults
RUN npm config set init.author.name "Jordan McArdle" \
  && npm config set init.author.email "jordanmcardle@gmail.com" \
  && npm config set init.author.url "https://mcardle.tech/" \
  && npm config set init.license "NOLICENSE"

ENV NEWTEST myNewTest
COPY test.txt .