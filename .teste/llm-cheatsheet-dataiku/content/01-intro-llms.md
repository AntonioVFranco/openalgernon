# Introduction to LLMs

## Definitions

**Generative AI** — AI systems that can produce realistic content (text, image, etc.).

**Large Language Models (LLMs)** — Large neural networks trained at internet scale to estimate the probability of sequences of words.
Examples: GPT, FLAN-T5, LLaMA, PaLM, BLOOM (transformers with billions of parameters).
Abilities and computing resources needed tend to rise with the number of parameters.

Use cases: standard NLP tasks (classification, summarization), content generation, reasoning (Q&A, planning, coding).

**Prompt and Completion** — The input to an LLM is a prompt; the output is a completion.
The context window is the space/memory available (~1,000 words).

**In-context learning** — Specifying the task to perform directly in the prompt.
- Zero-Shot: no examples in the prompt
- One-Shot: one example provided
- Few-Shot: multiple examples provided (typically five); consider fine-tuning if many examples are needed.

## Transformers

Transformers can scale efficiently to use multi-core GPUs, can process input data in parallel, and pay attention to all other words when processing a word.

Transformers' strength lies in understanding the **context** and **relevance** of all words in a sentence.

Architecture layers (bottom to top):
1. Input tokenization
2. Embedding
3. Positional encoding
4. Multi-headed attention
5. Feed forward network
→ OUTPUT (Softmax)

**Token** — Word or sub-word. The basic unit processed by transformers.

**Encoder** — Processes input sequence to generate a vector representation (or embedding) for each token.

**Decoder** — Processes input tokens to produce new tokens.

**Embedding layer** — Maps each token to a trainable vector.

**Positional encoding vector** — Added to the token embedding vector to keep track of the token's position.

**Self-Attention** — Computes the importance of each word in the input sequence to all other words in the sequence.

## Types of LLMs

**Encoder only = Autoencoding model**
Examples: BERT, RoBERTa. These are not generative models.
Pre-training objective: predict tokens masked in a sentence (Masked Language Modeling).
Output: encoded representation of the text.
Use cases: sentence classification (e.g., NER).

**Decoder only = Autoregressive model**
Examples: GPT, BLOOM.
Pre-training objective: predict the next token based on the previous sequence of tokens (Causal Language Modeling).
Output: next token.
Use cases: text generation.

**Encoder-Decoder = Seq-to-seq model**
Examples: T5, BART.
Pre-training objective: varies from model to model (e.g., span corruption like T5), using a sentinel token.
Output: sentinel token + predicted tokens.
Use cases: translation, Q&A, summarization.

## Configuration Settings

Parameters to set at **inference time**:

**Max new tokens** — Maximum number of tokens generated during completion.

**Decoding strategy:**
1. **Greedy Decoding** — The word/token with the highest probability is selected from the final probability distribution (prone to repetition).
2. **Random Sampling** — The model chooses an output word at random using the probability distribution to weigh the selection (could be too creative).
   - **Top K** — The next token is drawn from the k tokens with the highest probabilities.
   - **Top P** — The next token is drawn from the tokens with the highest probabilities, whose combined probabilities exceed p.

**Temperature** — Influences the shape of the probability distribution through a scaling factor in the softmax layer.
- T < 1: Peak distribution → less creative.
- T > 1: Broader distribution → more creative.
