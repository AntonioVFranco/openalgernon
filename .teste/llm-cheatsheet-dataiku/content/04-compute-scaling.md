# LLM Compute Challenges and Scaling Laws

## Large Language Model Choice

**Generative AI Project Lifecycle:**
Use case definition & scoping → Model Selection → Adapt (prompt engineering, fine-tuning, augment, evaluate) → App integration (model optimization, deployment)

**Two options for model selection:**
- Use a pre-trained LLM.
- Train your own LLM from scratch.

In general, develop your application using a **pre-trained LLM**, except if you work with extremely specific data (medical, legal).
**Hubs:** Where you can browse existing models. **Model Cards** list best use cases, training details, and limitations on models.
The model choice will depend on the details of the task to carry out.

**Model pre-training:**
Model weights are adjusted to minimize the loss of the training objective. It requires significant computational resources (GPUs, due to high computational load).

## Computational Challenges

**Memory Challenge:** `RuntimeError: CUDA out of memory`

LLMs are massive and require plenty of memory for training and inference.

**To load the model into GPU RAM:**
- 1 parameter (32-bit precision) = **4 bytes needed**
- 1B parameters = 4 × 10⁹ bytes = 4GB of GPU

**Pre-training requires storing additional components beyond the model's parameters:**
- Optimizer states (e.g., 2 for Adam)
- Gradients
- Forward activations
- Temporary variables

This could result in an additional **12-20 bytes of memory needed** per model parameter.
This would mean 1B parameter LLM requires **16 GB to 24 GB** of GPU memory — around 4-6x the GPU RAM needed just for storing the weights.

**Hence, the memory needed for LLM training is:**
- Excessive for consumer hardware
- Even demanding for data center hardware (e.g., NVIDIA A100 supports up to 80GB of RAM)

## Quantization

How can you reduce memory for training?

**Quantization** — Decrease memory to store the weights of the model by converting the precision from 32-bit to 16-bit or 8-bit integers.

Quantization maps the FP32 numbers to a lower precision space by employing scaling factors determined from the range of the FP32 numbers.

In most cases, quantization **strongly reduces memory requirements** with a **limited loss** in prediction.

**BFLOAT16 is a popular alternative to FP16:**
- Developed by Google Brain
- Balances memory efficiency and accuracy
- Wider dynamic range
- Optimized for storage and speed in ML tasks
- Example: FLAN T5 pre-trained using BFLOAT16

**Benefits of quantization:**
- Less memory
- Potentially better model performance
- Higher calculation speed

## Scaling Laws

How big do the models need to be? The goal is to maximize model performance.

**Researchers explored trade-offs between the dataset size, the model size, and the compute budget.**

Increasing compute may seem ideal for better performance, but practical constraints like hardware, time, and budget limit its feasibility.

It has been empirically shown that, as the compute budget remains fixed:
- **Fixed model size:** Increasing training dataset size improves model performance.
- **Fixed dataset size:** Larger models demonstrate lower test loss, indicating enhanced performance.

**What is the optimal balance?**
The **Chinchilla approach** — choose the dataset size and the model size to train a **compute-optimal model**, which maximizes performance for a given compute budget. The compute-optimal training dataset size is ~20x the number of parameters.
