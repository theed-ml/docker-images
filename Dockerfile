FROM alpine:3.10.2

LABEL SRC=https://github.com/frol/docker-alpine-glibc
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

ENV NB_USER=root
ENV NB_UID=0
ENV NB_GID=0
ENV JUPYTER_ENABLE_LAB=1

COPY start.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/

RUN apk add linux-headers \
			musl-dev \
			gcc \
			alpine-sdk \
			unixodbc-dev \
			openblas-dev \
			gcompat \
			krb5-dev \
			libffi-dev \
			openssl-dev \
			freetype-dev \
			syslinux-dev \
			subversion \
			# 
			py3-pip \
			python3-dev \
			py3-pytest \
			# 
			bash \
			tini \
			shadow \
			git \
			npm \
 			texlive-xetex \
			graphviz \
 && pip3 install --upgrade pip \
 && pip3 install msgpack \
 		 jupyterlab \
 		 jupyterlab-git \
 		 nbdime \
 		 setuptools_scm \
 		 pytest \
 		 pylint \
 		 flake8 \
 		 black \
		 graphviz \
 && nbdime extensions --enable \
 && jupyter serverextension enable --py jupyterlab_git \
 && jupyter labextension install @jupyterlab/git \
 && jupyter labextension install @jupyterlab/toc \
 && jupyter labextension install @lckr/jupyterlab_variableinspector \
 && jupyter nbextension enable nbdime --py \
 && jupyter lab build \
# 
 && ln -s /usr/bin/pytest-3 /usr/bin/pytest \
 && ln -s /usr/bin/python3 /usr/bin/python \
 && chmod +x /usr/local/bin/start.sh  \
 && mkdir -p /home/jovyan \
 && sed -ri 's/^(c.NotebookApp.ip =)(.*)\*(.*)/\1 \20.0.0.0\3/' /etc/jupyter/jupyter_notebook_config.py


EXPOSE 8888

ENTRYPOINT ["tini", "-g", "--"]

CMD ["/usr/local/bin/start.sh", "jupyter", "lab", "--allow-root"]

WORKDIR /jupyter

HEALTHCHECK CMD curl --fail localhost:8888 || exit 1
