FROM continuumio/miniconda3:latest

ARG PUID=1000
ARG PGID=1000

ENV USER anaconda
ENV WORKSPACE /home/$USER/workspace

RUN conda update -n base conda \
    && conda config --add channels conda-forge \
    && pip install --upgrade pip \
    && conda install \
                     python-dotenv \
                     scipy \
                     scrapy \
                     seaborn \
                     matplotlib \
                     jupyter \
                      ipython-sql \
                      qgrid \
                      ipypivot

RUN groupadd -r -g $PGID $USER \
    && useradd -r -m -u $PUID -g $USER $USER \
    && mkdir /home/$USER/.jupyter \
    && mkdir -p /home/$USER/.ipython/profile_default
COPY ./conf/jupyter_notebook_config.py /home/$USER/.jupyter/
COPY ./conf/ipython_config.py ./conf/ipython_kernel_config.py /home/$USER/.ipython/profile_default/

RUN mkdir $WORKSPACE
COPY . $WORKSPACE/
WORKDIR $WORKSPACE

RUN chown -R $USER:$USER /home/$USER \
    && chown -R $USER:$USER /opt/conda

USER $USER
ENV PATH "$WORKSPACE/bin:$PATH"
ENV PYTHONPATH "$WORKSPACE/src"

CMD ["/opt/conda/bin/jupyter", "notebook"]
EXPOSE 8888
