# Preference Fine-Tuning (Part 2)

## Fine-Tuning with RL and Reward Model

The LLM weights are updated to create a human-aligned model via reinforcement learning, leveraging the reward model, and starting with a high-performing base model.

**Goal:** To align the LLM with provided instructions and human behavior.

**Reinforcement learning algorithm:** Proximal Policy Optimization (PPO) is a popular choice.

## PPO Algorithm for LLMs

PPO iteratively updates the policy to **maximize the reward**, adjusting the LLM weights incrementally to **maintain proximity to the previous version** within a defined range for **stable learning**.

The **PPO objective** updates the LLM weights by backpropagation:
L^PPO = L^POLICY + c₁·L^VF + c₂·L^ENT

- **Value Loss (L^VF):** Minimize it to improve return prediction accuracy.
- **Policy Loss (L^POLICY):** Maximize it to get higher rewards while staying within reliable bounds. Uses clipped surrogate objective to keep the policy within a "trust region."
- **Entropy Loss (L^ENT):** Maximize it to promote and sustain model creativity. L^ENT = entropy(π_θ(·|s_t))

The higher the entropy, the more creative the policy.

## Reward Hacking

The agent **learns to cheat the system** by maximizing rewards at the expense of alignment with desired behavior.

To prevent reward hacking, **penalize RL updates** if they significantly deviate from the frozen original LLM, using **KL divergence**.

## Direct Preference Optimization

An RLHF pipeline is **difficult to implement:**
- Need to train a reward model
- New completions needed during training
- Instability of the RL algorithm

**Direct Preference Optimization (DPO)** is a simpler and more stable **alternative to RLHF**. It solves the same problem by minimizing a training loss directly based on the preference data (without reward modeling or RL).

**Identity Preference Optimization (IPO)** is a variant of DPO less prone to overfitting.

## RL from AI Feedback (Constitutional AI)

Obtaining the reward model is labor-intensive; scaling through AI-supervision is more precise and requires fewer human labels.

**Constitutional AI (Bai, Yuntao, et al., 2022)** — Approach that relies on a **set of principles** governing AI behavior, along with a small number of examples for few-shot prompting, collectively forming the "constitution."

Example constitutional principle: "Please choose the response that is the most helpful, honest, and harmless."

**Process:**
1. **Supervised Learning Stage:**
   - Generate harmful prompts and completions using the helpful LLM.
   - Critique and revise completions based on constitutional principles.
   - Fine-tune a pre-trained LLM on the revised completions.
2. **Reinforcement Learning Stage (RLAIF):**
   - Use the fine-tuned LLM with harmful prompts and pairs of completions.
   - Ask which response is best based on constitutional principles (AI-generated comparison data).
   - Train a preference model → Fine-tune the LLM using RL against the preference model.
   - Result: A policy trained by Reinforcement Learning with AI Feedback (RLAIF).
