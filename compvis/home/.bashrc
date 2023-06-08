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

MODEL_DIR="${STABLE_DIFFUSION_DIR}/models/ldm/stable-diffusion-v1"
MODEL_PATH="${MODEL_DIR}/model.ckpt"

if [ ! -d "${STABLE_DIFFUSION_DIR}" ]; then
  gh-fetch-by-commit "${GH_REPO}" "${COMMIT_HASH}" "${STABLE_DIFFUSION_DIR}"
  git apply "${HOME}/stable-diffusion-cpu.patch"
fi

if [ "$(cat "${MODEL_DIR}/sha256sum")" != "${MODEL_SHA256}" ]; then
  mkdir -p "${MODEL_DIR}"
  rm -f "${MODEL_PATH}"
  curl -L -o "${MODEL_PATH}" "${MODEL_URL}"

  if echo "${MODEL_SHA256} ${MODEL_PATH}" | sha256sum -c; then
    echo "${MODEL_SHA256}" > "${MODEL_DIR}/sha256sum"
  else
    rm -f "${MODEL_PATH}"
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
