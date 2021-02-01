FROM jupyter/datascience-notebook:python-3.7.6
LABEL authors="Phil Palmer" \
      description="Docker image containing all requirements for https://github.com/brianhie/viral-mutation"
COPY requirements.txt /
RUN pip install -r /requirements.txt
USER root