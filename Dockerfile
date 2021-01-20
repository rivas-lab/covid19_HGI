FROM python:3-slim
# RUN apt-get -y update \
#  && apt−get install −y pip3 build−essential

COPY web/requirements.txt /opt/requirements.txt
RUN pip3 install -r /opt/requirements.txt
COPY fig /web/static/covid19HGI/fig
COPY web/templates /web/templates
COPY web/app.py /web/app.py

ENTRYPOINT ["python3"]
CMD ["/web/app.py"]
