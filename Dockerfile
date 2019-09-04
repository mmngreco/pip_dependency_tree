FROM jfloff/alpine-python:3.6

RUN apk add tmux vim
RUN mkdir -p /root/git
WORKDIR /root/git
RUN python -m venv venv
# https://pythonspeed.com/articles/activate-virtualenv-dockerfile/
CMD source /root/git/venv/bin/activate && /bin/bash
