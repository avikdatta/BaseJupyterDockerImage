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
    ca-certificates        \
    npm nodejs-legacy
    
     
#RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
#    && apt-get install --no-install-recommends -y nodejs

# ubuntu specific cmd
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

# ubuntu specific cmd
RUN apt-get purge -y --auto-remove \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/*
    
USER $NB_USER
WORKDIR /home/$NB_USER

#RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv

RUN mkdir -p /home/$NB_USER/tmp          
ENV TMPDIR=/home/$NB_USER/tmp
#ENV PYENV_ROOT="//home/$NB_USER/.pyenv"   
#ENV PATH="$PYENV_ROOT/libexec/:$PATH" 
#ENV PATH="$PYENV_ROOT/shims/:$PATH"

#RUN eval "$(pyenv init -)" 
#RUN pyenv install 3.6.0
#RUN pyenv global 3.6.0

RUN  wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
     bash Miniconda3-latest-Linux-x86_64.sh -b

ENV PATH $PATH:/home/$NB_USER/miniconda3/bin/

RUN echo ". /home/$NB_USER/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc
    

RUN conda install --quiet --yes\
    python==3.6.0 \
    jupyter \
    jupyterlab && \
    conda clean --all -f -y && \
    rm -rf /home/$NB_USER/tmp && \
    mkdir -p /home/$NB_USER/tmp 

RUN mkdir -p /home/$NB_USER/.jupyter
RUN echo "c.NotebookApp.password = u'sha1:c991cd11a7cc:f4c7bd274c69271f7333ea24bfe85103566464de'" > /home/$NB_USER/.jupyter/jupyter_notebook_config.py

USER root
RUN npm install -g configurable-http-proxy && \
    rm -rf /root/.cache && \
    rm -rf /home/${NB_USER}/tmp


ENV TINI_VERSION v0.18.0
RUN wget --quiet  https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini && \
    mv tini /usr/local/bin/tini && \ 
    chmod +x /usr/local/bin/tini
USER $NB_USER

RUN mkdir -p /home/$NB_USER/tmp 

EXPOSE 8888
ENTRYPOINT ["/usr/local/bin/tini", "--"]
CMD [ "/bin/bash" ]
