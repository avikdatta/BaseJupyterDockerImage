FROM ubuntu:16.04
MAINTAINER reach4avik@yahoo.com
LABEL maintainer="avikdatta"

ENTRYPOINT []

ENV NB_USER vmuser
ENV NB_GROUP vmuser
ENV NB_UID 1000

USER root
WORKDIR /root/

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER \
     && groupadd $NB_GROUP \
     && usermod -a -G $NB_GROUP $NB_USER
     
RUN apt-get -y update &&   \
    apt-get install --no-install-recommends -y \
    git                    \
    locales                \
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
    
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

RUN apt-get purge -y --auto-remove \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/*
    
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
    && rm -rf /home/$NB_USER/tmp

RUN mkdir -p /home/$NB_USER/.jupyter
RUN echo "c.NotebookApp.password = u'sha1:c991cd11a7cc:f4c7bd274c69271f7333ea24bfe85103566464de'" > /home/$NB_USER/.jupyter/jupyter_notebook_config.py

RUN git clone https://github.com/jupyterlab/jupyter-renderers.git \
    && cd jupyter-renderers \
    && jlpm \
    && jlpm build \
    && jupyter labextension link packages/fasta-extension \
    && jupyter labextension link packages/plotly-extension \
    && jlpm build \
    && jupyter lab build

EXPOSE 8888
CMD ["jupyter","notebook","--ip=0.0.0.0","--port=8888","--no-browser"]
