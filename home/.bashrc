# ~/.bashrc: executed by bash(1) for non-login shells.

__conda_setup="$('/opt/conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "/opt/conda/etc/profile.d/conda.sh" ]; then
    . "/opt/conda/etc/profile.d/conda.sh"
  else
    export PATH="/opt/conda/bin:$PATH"
  fi
fi

unset __conda_setup

STABLE_DIFFUSION_DIR="${HOME}/stable-diffusion"

STABLE_DIFFUSION_MODEL_DIR="${STABLE_DIFFUSION_DIR}/models/ldm/stable-diffusion-v1"
STABLE_DIFFUSION_MODEL_PATH="${STABLE_DIFFUSION_MODEL_DIR}/model.ckpt"

if [ ! -d "${STABLE_DIFFUSION_DIR}" ]; then
  gh-fetch-by-commit "${STABLE_DIFFUSION_GH_REPO}" "${STABLE_DIFFUSION_COMMIT_HASH}" "${STABLE_DIFFUSION_DIR}"
  git apply "${HOME}/stable-diffusion-cpu.patch"
fi

if [ "$(cat "${STABLE_DIFFUSION_MODEL_DIR}/sha256sum")" != "${STABLE_DIFFUSION_MODEL_SHA256}" ]; then
  mkdir -p "${STABLE_DIFFUSION_MODEL_DIR}"
  rm -f "${STABLE_DIFFUSION_MODEL_PATH}"
  curl -L -o "${STABLE_DIFFUSION_MODEL_PATH}" "${STABLE_DIFFUSION_MODEL_URL}"

  if echo "${STABLE_DIFFUSION_MODEL_SHA256} ${STABLE_DIFFUSION_MODEL_PATH}" | sha256sum -c; then
    echo "${STABLE_DIFFUSION_MODEL_SHA256}" > "${STABLE_DIFFUSION_MODEL_DIR}/sha256sum"
  else
    rm -f "${STABLE_DIFFUSION_MODEL_PATH}"
  fi
fi

cd "${STABLE_DIFFUSION_DIR}"

if [ ! -d "${HOME}/.conda/envs/ldm" ]; then
  conda env create -f environment.yaml
fi

conda activate ldm

pip install \
  diffusers==0.12.1 \
  taming-transformers \
  taming-transformers-rom1504 \
  clip
