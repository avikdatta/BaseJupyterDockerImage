FROM alpine:3.7
#FROM ubuntu:16.04
MAINTAINER reach4avik@yahoo.com
LABEL maintainer="avikdatta"

ENTRYPOINT []

ENV NB_USER vmuser
ENV NB_GROUP vmuser
ENV NB_UID 1000

USER root
WORKDIR /root/

# ubuntu specific cmd
#RUN apt-get -y update &&   \
#apt-get install --no-install-recommends -y \

## alpine specific commands
RUN apk --update add --no-cache \
        build-essential \
        libbz2-dev \
        libopenblas-dev \
        libreadline6 \
        libreadline6-dev \
        libsqlite3-dev \
        libssl-dev \
        locales \
        texlive-xetex \
        zlib1g-dev
        
RUN apk add --no-cache \
    git                    \
    locales                \
    curl                   \
    wget                   \
    make                   \
    g++                    \
    patch                  \
    build-essential        \
    libssl-dev             \
    zlib1g-dev             \
    libbz2-dev             \
    libsqlite3-dev         \
    libssl-dev             \
    libreadline6-dev       \
    libreadline6           \
    libopenblas-dev        \
    texlive-xetex          \
    openssl                \
    ca-certificates        
    
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER \
     && groupadd $NB_GROUP \
     && usermod -a -G $NB_GROUP $NB_USER
     
#RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
#    && apt-get install --no-install-recommends -y nodejs

# ubuntu specific cmd
#RUN locale-gen en_US.UTF-8
#RUN dpkg-reconfigure locales

# ubuntu specific cmd
#RUN apt-get purge -y --auto-remove \
#    &&  apt-get clean \
#    &&  rm -rf /var/lib/apt/lists/*
    
USER $NB_USER
WORKDIR /home/$NB_USER

RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv

RUN mkdir -p /home/$NB_USER/tmp          
ENV TMPDIR=/home/$NB_USER/tmp
ENV PYENV_ROOT="//home/$NB_USER/.pyenv"   
ENV PATH="$PYENV_ROOT/libexec/:$PATH" 
ENV PATH="$PYENV_ROOT/shims/:$PATH"

RUN eval "$(pyenv init -)" 
RUN pyenv install 3.5.2
RUN pyenv global 3.5.2

RUN pip install --no-cache-dir -q jupyter jupyterlab \
    && rm -rf /home/$NB_USER/.cache \
    && rm -rf /home/$NB_USER/tmp \
    && mkdir -p /home/$NB_USER/tmp 

RUN mkdir -p /home/$NB_USER/.jupyter
RUN echo "c.NotebookApp.password = u'sha1:c991cd11a7cc:f4c7bd274c69271f7333ea24bfe85103566464de'" > /home/$NB_USER/.jupyter/jupyter_notebook_config.py

EXPOSE 8888
CMD ["jupyter","lab","--ip=0.0.0.0","--port=8888","--no-browser"]
