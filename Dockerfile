FROM python:3.10.13

WORKDIR /products/app
COPY dockerenv/pip.conf ~/.pip/pip.conf
RUN pip3 install requests

RUN pip3 install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cu121
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
RUN git config --global --add safe.directory /products/app
RUN git config --global --add safe.directory /products/app/repositories/stable-diffusion-webui-assets
RUN git config --global --add safe.directory /products/app/repositories/stable-diffusion-stability-ai
RUN git config --global --add safe.directory /products/app/repositories/generative-models
RUN git config --global --add safe.directory /products/app/repositories/k-diffusion
RUN git config --global --add safe.directory /products/app/repositories/BLIP

RUN mv /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak
COPY dockerenv/debian.sources /etc/apt/sources.list.d/debian.sources
RUN apt-get update
# python-opencv需要
RUN apt-get install ffmpeg libsm6 libxext6  -y

RUN pip3 install xformers==0.0.23.post1
COPY preset_packages preset_packages
RUN pip3 install --no-index file:///products/app/preset_packages/CLIP_d50d76daa670286dd6cacf3bcd80b5e4823fc8e1.zip

COPY requirements_versions.txt requirements_versions.txt
RUN pip3 install -r requirements_versions.txt

CMD ["python","launch.py","--xformers","--api","--no-half","--disable-nan-check","--port","17860"]
