# base image
FROM python:3.8.12
LABEL org.opencontainers.image.source https://github.com/serengil/deepface

# -----------------------------------
# create required folder
RUN mkdir /app
RUN mkdir /app/deepface

# -----------------------------------
# switch to application directory
WORKDIR /app

# -----------------------------------
# update image os
RUN apt-get update
RUN apt-get install ffmpeg libsm6 libxext6 -y

# -----------------------------------
# Copy required files from repo into image
COPY ./deepface /app/deepface
# even though we will use local requirements, this one is required to perform install deepface from source code
COPY ./requirements.txt /app/requirements.txt
COPY ./requirements_local /app/requirements_local.txt
COPY ./package_info.json /app/
COPY ./setup.py /app/
COPY ./README.md /app/

# -----------------------------------
# if you plan to use a GPU, you should install the 'tensorflow-gpu' package
# RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org tensorflow-gpu

# -----------------------------------
# install deepface from pypi release (might be out-of-date)
# RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org deepface
# -----------------------------------
# install dependencies - deepface with these dependency versions is working
RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org -r /app/requirements_local.txt
# install deepface from source code (always up-to-date)
RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org -e .

# -----------------------------------
# some packages are optional in deepface. activate if your task depends on one.
# RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org cmake==3.24.1.1
# RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org dlib==19.20.0
# RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org lightgbm==2.3.1

RUN mkdir -p /root/.deepface/weights && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/age_model_weights.h5 -O /root/.deepface/weights/age_model_weights.h5 && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/arcface_weights.h5 -O /root/.deepface/weights/arcface_weights.h5 && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/deepid_keras_weights.h5 -O /root/.deepface/weights/deepid_keras_weights.h5 && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/facenet512_weights.h5 -O /root/.deepface/weights/facenet512_weights.h5 && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/facenet_weights.h5 -O /root/.deepface/weights/facenet_weights.h5 && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/facial_expression_model_weights.h5 -O /root/.deepface/weights/facial_expression_model_weights.h5 && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/gender_model_weights.h5 -O /root/.deepface/weights/gender_model_weights.h5 && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/openface_weights.h5 -O /root/.deepface/weights/openface_weights.h5 && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/race_model_single_batch.h5 -O /root/.deepface/weights/race_model_single_batch.h5 && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/retinaface.h5 -O /root/.deepface/weights/retinaface.h5 && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/vgg_face_weights.h5 -O /root/.deepface/weights/vgg_face_weights.h5

# -----------------------------------
# environment variables
ENV PYTHONUNBUFFERED=1

# -----------------------------------
# run the app (re-configure port if necessary)
WORKDIR /app/deepface/api/src
CMD gunicorn --workers=1 --timeout=3600 --bind=0.0.0.0:$PORT "app:create_app()"
