# LLM-Powered Applications

## Model Optimization for Deployment

**Inference challenges:** High computing and storage demands → Shrink model size, maintain performance.

**Model Distillation**
Scale down model complexity while preserving accuracy. Train a small student model to mimic a large frozen teacher model.
- **Soft labels:** Teacher completions serve as ground truth labels.
- Student and distillation losses update student model weights via backpropagation.
- The student LLM can be used for inference.

**Post Training Quantization (PTQ)**
PTQ reduces model weight precision to 16-bit float or 8-bit integer.
- Can target both weights and activation layers for impact.
- May sacrifice performance, yet beneficial for cost savings and performance gains.

**Model Pruning**
Removes redundant model parameters that contribute little to the model performance.
Some methods require full model training, while others are in the PEFT category (LoRA).

## LLM-Integrated Applications

**Why integrate external data/apps?**
- Knowledge can be out of date.
- LLMs struggle with certain tasks (e.g., math).
- LLMs can confidently provide wrong answers ("hallucination").
→ Leverage **external app** or **data sources**.

**Retrieval Augmented Generation (RAG)**
AI framework that integrates **external data sources** and **apps** (e.g., documents, private databases, etc.). Multiple implementations exist, will depend on the details of the task and the data format.

Process:
- We retrieve **documents most similar to the input query** in the external data.
- We combine the documents with the input query and **send the prompt to the LLM** to receive the answer.

Notes:
- Size of the context window can be a limitation → Use multiple **chunks** (e.g., with LangChain).
- Data must be in format that allows its relevance to be assessed at inference time → Use **embedding vectors** (vector store).

**Vector database** — Stores vectors and associated metadata, enabling efficient nearest-neighbor vector search.

## LLM Reasoning with Chain-of-Thought Prompting

Complex reasoning is challenging for LLMs (e.g., problems with multiple steps, mathematical reasoning).
→ LLM should serve as a **reasoning engine**. The prompt and completion are important!

**Chain-of-Thought (CoT)**
- Prompts the model to **break down problems into sequential steps**.
- Operates by integrating **intermediate reasoning steps** into examples for one-or few-shot inference.
- Improves performance but struggles with precision-demanding tasks like tax computation or discount application.
- Solution: Allow the LLM to communicate with a proficient math program, such as a Python interpreter.

## Program-Aided Language and ReAct

**Program-Aided Language (PAL)**
Generate scripts and pass them to the interpreter.
- Completion is handed off to a Python interpreter.
- Calculations are accurate and reliable.

**ReAct**
Prompting strategy that combines CoT reasoning and action planning, employing **structured examples** to guide an LLM in **problem-solving** and decision-making.

ReAct format: Instructions → Question → Thought → Action → Observation (loop) → Answer

- **Thought:** Analysis of the current situation and the next steps to take.
- **Action:** Actions from a predetermined list defined in the set of instructions in the prompt. The loop ends when the action is "finish []".
- **Observation:** Result of the previous action.

LangChain can be used to connect multiple components through agents, tools, etc.
Agents: Interpret the user input and determine which tool to use (LangChain includes agents for PAL and ReAct).

ReAct reduces the risks of errors.
