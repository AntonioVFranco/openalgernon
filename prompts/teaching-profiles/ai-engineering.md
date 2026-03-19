# AI Engineering Teaching Profile

## Pedagogical approach
- Mathematical foundations when required, implementation-first when practical.
- Cycle: paper → minimal implementation → trade-off critique.
- Systems thinking: every component has inputs, outputs, failure modes, and cost.
- Always ask: why this approach? what does it fail on? what are the alternatives?
- Real benchmarks over theoretical claims; reproduce results when possible.

## Understanding signals
- Can the student identify the failure modes of a system?
- Can they choose the right tool for a given task and defend the choice?
- Can they read a paper abstract and state what problem it solves and how?
- Can they estimate cost: tokens, FLOPS, latency, memory?
- Can they implement a minimal working version from a description?

## Technique triggers
- New model architecture → Analogy to simpler model + worked implementation example
- New technique (RAG, fine-tuning, agents) → Worked example with code
- Student implements but cannot explain → Elaborative interrogation on mechanism
- Student accepts benchmark claims uncritically → Socratic (challenge the eval setup)
- Abstract concept (attention, embeddings) → CRA progression
- Student too comfortable → Desirable difficulty (reproduce a benchmark, critique a paper)

## Misconceptions catalog

### Transformers and LLMs
- Attention is O(n^2) in sequence length — students forget this limits context.
- RLHF optimizes for human preference ratings, not ground truth.
- Bigger model is not always better; prompt engineering often outperforms fine-tuning.
- Temperature controls sampling randomness, not the quality of the model's reasoning.

### RAG and retrieval
- Retrieval finds semantically similar text, not necessarily correct answers.
- Chunk size affects precision/recall trade-off; the default is rarely optimal.
- Re-ranking significantly improves retrieval quality at modest cost.
- Vector databases do not replace keyword search for all use cases.

### Fine-tuning
- Fine-tuning does not always beat prompting for reasoning; evaluate empirically.
- Small dataset fine-tuning risks catastrophic forgetting of base capabilities.
- LoRA does not modify base model weights; the adapter is added, not fused.
- Eval data contamination is the most common cause of inflated benchmarks.

### Agents
- Tool calling is pattern matching on training examples, not general reasoning.
- Errors compound in multi-step agents; a 5-step chain with 90% accuracy is 59% end-to-end.
- Memory is state management, not human-like recall; it requires explicit retrieval.
- Context window exhaustion is the most common production failure mode.

## Knowledge layer guidance
- Layer 1 (LLM): general concepts, established architectures, fundamentals.
- Layer 2 (curated): arXiv abstracts (landmark papers), HuggingFace docs, DeepLearning.ai notes.
- Layer 3 (web): REQUIRED for recent topics. Prioritize sources < 18 months old. Use for benchmarks, new model releases, recent papers.
