# !/bin/sh

# conda installation
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh

source ~/.bashrc

conda --version

conda create -n multitalk python=3.10
conda activate multitalk

# flash attn installation
git clone https://github.com/Dao-AILab/flash-attention.git

# dependencies mentioned in infinitetalk and ninja needed for flash attn
pip install misaki[en]
pip install ninja 
pip install psutil 
pip install packaging
pip install wheel

# check ninja installation
ninja --version

cd flash-attention
cd hopper
# installation took very long time ~ 1 hour
python setup.py install
# test
export PYTHONPATH=$PWD
pytest -q -s test_flash_attn.py

cd ../..

git clone https://github.com/MeiGen-AI/InfiniteTalk.git
cd InfiniteTalk

pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/cu121
pip install -U xformers==0.0.28 --index-url https://download.pytorch.org/whl/cu121

# other deps
pip install -r requirements.txt
conda install -c conda-forge librosa

# ffmpeg installation
conda install -c conda-forge ffmpeg

# models download
hf download Wan-AI/Wan2.1-I2V-14B-480P --local-dir ./weights/Wan2.1-I2V-14B-480P
hf download TencentGameMate/chinese-wav2vec2-base --local-dir ./weights/chinese-wav2vec2-base
hf download TencentGameMate/chinese-wav2vec2-base model.safetensors --revision refs/pr/1 --local-dir ./weights/chinese-wav2vec2-base
hf download MeiGen-AI/InfiniteTalk --local-dir ./weights/InfiniteTalk

cd ..

echo "Installation completed."

# testing
python generate_infinitetalk.py \
    --ckpt_dir weights/Wan2.1-I2V-14B-480P \
    --wav2vec_dir 'weights/chinese-wav2vec2-base' \
    --infinitetalk_dir weights/InfiniteTalk/single/infinitetalk.safetensors \
    --input_json examples/single_example_image.json \
    --size infinitetalk-480 \
    --sample_steps 40 \
    --mode streaming \
    --motion_frame 9 \
    --save_file infinitetalk_res

echo "Testing completed."


# error
# (multitalk) root@54689522270d:/workspace/InfiniteTalk# python -c "import torch, torchvision, torchaudio; print('torch', torch.__version__, 'cuda', torch.cuda.is_available()); print('torchvision', torchvision.__version__); print('torchaudio', torchaudio.__version__)"
# raceback (most recent call last):
#   File "<string>", line 1, in <module>
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/torchvision/__init__.py", line 10, in <module>
#     from torchvision import _meta_registrations, datasets, io, models, ops, transforms, utils  # usort:skip
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/torchvision/_meta_registrations.py", line 164, in <module>
#     def meta_nms(dets, scores, iou_threshold):
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/torch/library.py", line 1063, in register
#     use_lib._register_fake(
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/torch/library.py", line 211, in _register_fake
#     handle = entry.fake_impl.register(
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/torch/_library/fake_impl.py", line 50, in register
#     if torch._C._dispatch_has_kernel_for_dispatch_key(self.qualname, "Meta"):
# RuntimeError: operator torchvision::nms does not exist


# after all installation and building flash attn localy, correctly installing torhc, torchvision, torchaudio
# xformers got this error

# (multitalk) root@54689522270d:/workspace/InfiniteTalk# python generate_infinitetalk.py \
#     --ckpt_dir weights/Wan2.1-I2V-14B-480P \
#     --wav2vec_dir 'weights/chinese-wav2vec2-base' \
#     --infinitetalk_dir weights/InfiniteTalk/single/infinitetalk.safetensors \
#     --input_json examples/single_example_image.json \
#     --size infinitetalk-480 \
#     --sample_steps 40 \
#     --mode streaming \
#     --motion_frame 9 \
#     --save_file infinitetalk_res
# Traceback (most recent call last):
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/utils/import_utils.py", line 1016, in _get_module
#     return importlib.import_module("." + module_name, self.__name__)
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/importlib/__init__.py", line 126, in import_module
#     return _bootstrap._gcd_import(name[level:], package, level)
#   File "<frozen importlib._bootstrap>", line 1050, in _gcd_import
#   File "<frozen importlib._bootstrap>", line 1027, in _find_and_load
#   File "<frozen importlib._bootstrap>", line 992, in _find_and_load_unlocked
#   File "<frozen importlib._bootstrap>", line 241, in _call_with_frames_removed
#   File "<frozen importlib._bootstrap>", line 1050, in _gcd_import
#   File "<frozen importlib._bootstrap>", line 1027, in _find_and_load
#   File "<frozen importlib._bootstrap>", line 1006, in _find_and_load_unlocked
#   File "<frozen importlib._bootstrap>", line 688, in _load_unlocked
#   File "<frozen importlib._bootstrap_external>", line 883, in exec_module
#   File "<frozen importlib._bootstrap>", line 241, in _call_with_frames_removed
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/models/autoencoders/__init__.py", line 1, in <module>
#     from .autoencoder_asym_kl import AsymmetricAutoencoderKL
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/models/autoencoders/autoencoder_asym_kl.py", line 23, in <module>
#     from .vae import AutoencoderMixin, DecoderOutput, DiagonalGaussianDistribution, Encoder, MaskConditionDecoder
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/models/autoencoders/vae.py", line 25, in <module>
#     from ..unets.unet_2d_blocks import (
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/models/unets/__init__.py", line 6, in <module>
#     from .unet_2d import UNet2DModel
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/models/unets/unet_2d.py", line 24, in <module>
#     from .unet_2d_blocks import UNetMidBlock2D, get_down_block, get_up_block
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/models/unets/unet_2d_blocks.py", line 36, in <module>
#     from ..transformers.dual_transformer_2d import DualTransformer2DModel
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/models/transformers/__init__.py", line 20, in <module>
#     from .transformer_bria import BriaTransformer2DModel
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/models/transformers/transformer_bria.py", line 14, in <module>
#     from ..attention_dispatch import dispatch_attention_fn
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/models/attention_dispatch.py", line 80, in <module>
#     from flash_attn_interface import flash_attn_func as flash_attn_3_func
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/flash_attn_interface.py", line 10, in <module>
#     import flash_attn_3._C # Registers operators with PyTorch
# ImportError: /root/miniconda3/envs/multitalk/lib/python3.10/site-packages/flash_attn_3/_C.abi3.so: undefined symbol: aoti_torch_create_device_guard

# The above exception was the direct cause of the following exception:

# Traceback (most recent call last):
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/utils/import_utils.py", line 1016, in _get_module
#     return importlib.import_module("." + module_name, self.__name__)
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/importlib/__init__.py", line 126, in import_module
#     return _bootstrap._gcd_import(name[level:], package, level)
#   File "<frozen importlib._bootstrap>", line 1050, in _gcd_import
#   File "<frozen importlib._bootstrap>", line 1027, in _find_and_load
#   File "<frozen importlib._bootstrap>", line 1006, in _find_and_load_unlocked
#   File "<frozen importlib._bootstrap>", line 688, in _load_unlocked
#   File "<frozen importlib._bootstrap_external>", line 883, in exec_module
#   File "<frozen importlib._bootstrap>", line 241, in _call_with_frames_removed
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/pipelines/pipeline_utils.py", line 47, in <module>
#     from ..models import AutoencoderKL
#   File "<frozen importlib._bootstrap>", line 1075, in _handle_fromlist
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/utils/import_utils.py", line 1006, in __getattr__
#     module = self._get_module(self._class_to_module[name])
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/utils/import_utils.py", line 1018, in _get_module
#     raise RuntimeError(
# RuntimeError: Failed to import diffusers.models.autoencoders.autoencoder_kl because of the following error (look up to see its traceback):
# /root/miniconda3/envs/multitalk/lib/python3.10/site-packages/flash_attn_3/_C.abi3.so: undefined symbol: aoti_torch_create_device_guard

# The above exception was the direct cause of the following exception:

# Traceback (most recent call last):
#   File "/workspace/InfiniteTalk/generate_infinitetalk.py", line 19, in <module>
#     import wan
#   File "/workspace/InfiniteTalk/wan/__init__.py", line 1, in <module>
#     from . import configs, distributed, modules
#   File "/workspace/InfiniteTalk/wan/modules/__init__.py", line 1, in <module>
#     from .attention import flash_attention
#   File "/workspace/InfiniteTalk/wan/modules/attention.py", line 5, in <module>
#     from ..utils.multitalk_utils import RotaryPositionalEmbedding1D, normalize_and_scale, split_token_counts_and_frame_ids
#   File "/workspace/InfiniteTalk/wan/utils/multitalk_utils.py", line 7, in <module>
#     from xfuser.core.distributed import (
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/xfuser/__init__.py", line 1, in <module>
#     from xfuser.model_executor.pipelines import (
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/xfuser/model_executor/pipelines/__init__.py", line 1, in <module>
#     from .base_pipeline import xFuserPipelineBaseWrapper
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/xfuser/model_executor/pipelines/base_pipeline.py", line 10, in <module>
#     from diffusers import DiffusionPipeline
#   File "<frozen importlib._bootstrap>", line 1075, in _handle_fromlist
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/utils/import_utils.py", line 1007, in __getattr__
#     value = getattr(module, name)
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/utils/import_utils.py", line 1006, in __getattr__
#     module = self._get_module(self._class_to_module[name])
#   File "/root/miniconda3/envs/multitalk/lib/python3.10/site-packages/diffusers/utils/import_utils.py", line 1018, in _get_module
#     raise RuntimeError(
# RuntimeError: Failed to import diffusers.pipelines.pipeline_utils because of the following error (look up to see its traceback):
# Failed to import diffusers.models.autoencoders.autoencoder_kl because of the following error (look up to see its traceback):
# /root/miniconda3/envs/multitalk/lib/python3.10/site-packages/flash_attn_3/_C.abi3.so: undefined symbol: aoti_torch_create_device_guard