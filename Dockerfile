# MATLAB & NiPreps - fmriprep

# Specify which MATLAB release to install in the container
# The current on-campus license server is set to use R2021a
ARG MATLAB_RELEASE=r2021a

# Use the Ubuntu-based NiPreps/fmriprep image for this build
FROM nipreps/fmriprep:latest

# Declare the global argument to use at the current build stage
ARG MATLAB_RELEASE

# Install dependencies for MATLAB
ENV DEBIAN_FRONTEND="noninteractive" TZ="Etc/UTC"

RUN apt-get update && apt-get install --no-install-recommends -y \
     ca-certificates libasound2 libatk1.0-0 libc6 libcairo-gobject2 libcairo2 libcrypt1 \
     libcups2 libdbus-1-3 libfontconfig1 libgdk-pixbuf2.0-0 libgstreamer-plugins-base1.0-0 \
     libgstreamer1.0-0 libgtk-3-0 libnspr4 libnss3 libodbc1 libpam0g libpango-1.0-0 \
     libpangocairo-1.0-0 libpangoft2-1.0-0 libpython2.7 libpython3.8 libselinux1 libsm6 \
     libsndfile1 libuuid1 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 \
     libxext6 libxfixes3 libxft2 libxi6 libxinerama1 libxrandr2 libxrender1 libxt6 libxtst6 \
     libxxf86vm1 locales locales-all make net-tools procps sudo tzdata unzip wget zlib1g \
    && apt-get clean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/*

RUN [ -d /usr/share/X11/xkb ] || mkdir -p /usr/share/X11/xkb

# Install mpm dependencies
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && \
    apt-get install --no-install-recommends --yes \
        wget \
        unzip \
        ca-certificates && \
    apt-get clean && apt-get autoremove

# Run mpm to install MATLAB in the target location and delete the mpm installation afterwards
RUN wget -q https://urldefense.proofpoint.com/v2/url?u=https-3A__www.mathworks.com_mpm_glnxa64_mpm&d=DwIGAg&c=-35OiAkTchMrZOngvJPOeA&r=Wpdz_JHAO-h9QnP0tZk8OugywBv6yl5B-hTwJGFhjKs&m=xBuO3K3xWk0VlJ5BF3Xao-ofVg7lMKSmwlqmjnvFG1WX23It_h2nEeWSR0Jyv7jS&s=yjLYDtwTidGruTMMah7_zyIQB1sGAea0QdLnWxq_nqo&e=  && \ 
    chmod +x mpm && \
    ./mpm install \
        --release=${MATLAB_RELEASE} \
        --destination=/opt/matlab \
        --products MATLAB && \
    rm -f mpm /tmp/mathworks_root.log && \
    ln -s /opt/matlab/bin/matlab /usr/local/bin/matlab

# Grant sudo permission for the fmriprep user which was
# set up in the base fmriprep image
RUN echo "fmriprep ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/fmriprep && \
    chmod 0440 /etc/sudoers.d/fmriprep
    
# The UCSD campus MATLAB network license file
COPY license.lic /opt/matlab/licenses/    

# Set up user
USER fmriprep
ENV PATH="/opt/conda/bin:/opt/fsl-6.0.5.1/bin:/opt/convert3d-1.0.0/bin:/opt/afni-latest:\
/opt/ants:/opt/ICA-AROMA:/opt/workbench/bin_linux64:/opt/conda/bin:$PATH"
WORKDIR /tmp
ENTRYPOINT [""]
CMD [""]
