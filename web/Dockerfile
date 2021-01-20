FROM python:3
# RUN apt-get -y update \
#  && apt−get install −y pip3 build−essential

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY . .
ENTRYPOINT ["python3"]
CMD ["app.py"]
