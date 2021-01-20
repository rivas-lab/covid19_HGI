FROM python:3-slim
# RUN apt-get -y update \
#  && apt−get install −y pip3 build−essential

COPY web/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY web .
COPY fig fig
ENTRYPOINT ["python3"]
CMD ["app.py"]
