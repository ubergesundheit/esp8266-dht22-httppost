FROM node:4

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN npm install -g nodemcu-tool

ENTRYPOINT ["nodemcu-tool", "--port", "/dev/ttyACM0", "--baud", "115200"]

CMD ["terminal"]

