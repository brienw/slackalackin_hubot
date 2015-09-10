FROM node:latest

ADD *.json /lzhubot/
ADD scripts /lzhubot/scripts
ADD bin /lzhubot/bin

WORKDIR /lzhubot

RUN npm install

ENTRYPOINT ["bin/env"]
CMD ["bin/hubot", "-a", "slack", "-n", "Hubot"]
