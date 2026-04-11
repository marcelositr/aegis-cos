---
title: Fact Checking
layer: ai_engineering
type: concept
priority: high
version: 2.0.0
tags:
  - AIEngineering
  - Validation
  - HallucinationDetection
  - RAG
  - Grounding
  - Truthfulness
description: Verifying factual claims made by AI outputs against reliable external sources to detect hallucinations, fabricated citations, and misinformation before they reach end users.
---

# Fact Checking

## Description

Fact checking in AI engineering is the systematic process of validating factual claims produced by language models against authoritative external sources. Unlike traditional fact checking by human editors, AI fact checking must operate at scale and speed — validating claims in milliseconds during generation or in a post-processing step before output delivery.

The core pipeline consists of:
1. **Claim extraction** — identify declarative statements in the model output that are verifiable (e.g., "Python 3.12 was released in October 2023").
2. **Source retrieval** — for each claim, query authoritative knowledge bases (Wikipedia, official documentation, scientific databases, internal knowledge graphs) for corroborating or contradicting evidence.
3. **Verification** — compare the claim against retrieved evidence using NLI (Natural Language Inference) models, rule-based matching, or a second LLM acting as a verifier.
4. **Resolution** — if the claim is unsupported or contradicted, flag it, suppress it, or regenerate with corrected context.

This is distinct from [[HallucinationDetection]], which focuses on identifying hallucinations through internal signals (confidence scores, perplexity, self-consistency). Fact checking requires external grounding.

## When to Use

- **RAG (Retrieval-Augmented Generation) pipelines** — the model generates answers from retrieved documents, but retrieval may return irrelevant or outdated sources. Fact checking verifies the answer against the source material ("faithfulness" evaluation).
- **Customer-facing AI assistants** — chatbots, search assistants, and copilot products that answer factual questions. Unverified hallucinations directly impact user trust and can cause reputational damage.
- **Legal, medical, or financial AI applications** — domains where incorrect facts carry regulatory liability (SEC compliance, FDA regulations, clinical decision support). Every claim must be traceable to a cited source.
- **Automated content generation** — product descriptions, news summaries, technical documentation generated at scale. Fact checking prevents publishing errors at volume.
- **Research assistance tools** — AI tools that summarize papers or extract findings from scientific literature. Fabricated citations or misattributed findings are common failure modes.
- **Code generation with API references** — verifying that generated code uses real APIs, correct parameter names, and existing library versions. An LLM may invent methods that do not exist in the actual library.

## When NOT to Use

- **Creative writing, brainstorming, or fiction generation** — there are no factual claims to verify. The output is inherently imaginative.
- **Internal developer copilot for code completion** — the code is immediately compiled or tested, providing its own verification layer. Fact checking the docstring comments is low-value compared to running the tests.
- **Conversational chatbots for casual interaction** — the cost-benefit ratio is poor when users do not expect factual accuracy (e.g., a companion chatbot).
- **When authoritative sources do not exist** — for niche internal knowledge or proprietary data with no external reference, fact checking is impossible. You can only check internal consistency.
- **When latency requirements are sub-100ms** — full fact checking (claim extraction → retrieval → verification) typically adds 500ms–5s per response. Real-time applications must use pre-generation grounding instead.
- **When the cost of verification exceeds the cost of error** — for low-stakes outputs (e.g., generating draft email replies), the engineering investment in a fact checking pipeline is not justified.

## Tradeoffs

| Dimension | Pre-Generation Grounding | Post-Generation Fact Checking |
|-----------|------------------------|------------------------------|
| **Latency** | Adds latency during retrieval (before generation) | Adds latency after generation (claim extraction + verification) |
| **Coverage** | Only checks claims that retrieval can answer | Can catch any factual claim, including those outside retrieval scope |
| **Accuracy** | Limited by retrieval quality | Higher accuracy but may produce false positives on nuanced claims |
| **Cost** | One retrieval call per query | N verification calls per claim (often 3–10 claims per response) |
| **User experience** | User sees a single, grounded response | User may see a response, then corrections (jarring) |

| Dimension | LLM-as-Judge Verification | Rule-Based / NLI Verification |
|-----------|--------------------------|------------------------------|
| **Flexibility** | Handles nuanced claims, paraphrasing, implicit references | Requires structured claim-evidence pairs; brittle on paraphrasing |
| **Cost** | $0.01–0.10 per claim (API calls) | Near-zero (local model inference) |
| **Speed** | 500ms–2s per claim | 10–100ms per claim |
| **False positive rate** | 5–15% (LLM can be overconfident) | 15–30% (rigid matching misses nuance) |
| **Maintainability** | Prompt engineering required | Code-based rules, easier to audit |

## Alternatives

- **Retrieval-Augmented Generation (RAG)** — ground the model's output by injecting relevant documents into the prompt before generation. Prevents many hallucinations at the source but does not verify the output.
- **Self-consistency / Self-verification** — ask the model to verify its own answer ("Is this claim supported by the context?"). Low cost but the model can hallucinate during verification too.
- **Constitutional AI** — embed factuality constraints in the model's system prompt and training (e.g., "If you are uncertain, say so"). Reduces hallucination rate but does not eliminate it.
- **Knowledge graph grounding** — map claims to structured knowledge graph entities (Wikidata, internal KG). High precision for well-defined domains (entities, dates, relationships) but poor coverage for free-form text.
- **Human-in-the-loop review** — route low-confidence outputs to human reviewers. Highest accuracy but does not scale and introduces latency.
- **Tool-use / function calling** — have the model call a search API or database query tool to verify claims during generation (e.g., ChatGPT's web browsing). More integrated than post-hoc fact checking.

## Failure Modes

1. **Citation hallucination** → the model invents plausible-looking but non-existent citations (e.g., "Smith et al., Nature 2022, DOI: 10.1038/s41586-022-XXXXX") and the fact checker fails to verify source existence → always validate DOI/URL existence against CrossRef, PubMed, or the target journal's API before accepting a citation.

2. **Temporal mismatch (stale sources)** → the fact checker retrieves evidence from a knowledge base last updated in 2021, contradicting a correct 2024 claim → maintain source freshness metadata. Implement a `last_indexed` timestamp per source and prefer sources updated within the last N days. Use web search as a fallback for recent topics.

3. **Claim extraction misses implicit claims** → the model says "As everyone knows, Python's GIL prevents true parallelism" without explicitly flagging it as a claim. The extractor skips it, and a misleading statement passes through → use a dedicated claim extraction model (e.g., a fine-tuned DeBERTa) trained to identify implicit factual assertions, not just explicit "X is Y" statements.

4. **Evidence retrieval returns irrelevant sources** → the claim "Tesla's market cap exceeded $1T in 2021" retrieves an article about Tesla's market cap in 2024, which does not corroborate the 2021 claim → use temporal filters in search queries. Include date ranges in the retrieval prompt: "Find sources confirming Tesla's market cap specifically in 2021."

5. **NLI verifier produces false positives on negation** → the claim "Vaccines do not cause autism" and evidence "No credible study has found a causal link between vaccines and autism" should be ENTAILMENT, but the NLI model classifies it as NEUTRAL due to negation complexity → use a high-quality NLI model (e.g., DeBERTa-v3 trained on MNLI) and test your verification pipeline on negation-heavy examples. Consider LLM-as-judge for ambiguous cases.

6. **Verification latency degrades user experience** → fact checking 8 claims per response with an LLM verifier takes 12 seconds total. Users abandon the session before the verified response arrives → implement progressive verification: display the response immediately with a "verifying..." indicator, then highlight or redact claims as they are checked. Set a hard timeout (e.g., 3s) and label unchecked claims with low confidence.

7. **Source authority scoring is gamed** → a low-quality blog post ranks highly in search results for a niche query, and the fact checker accepts it as authoritative → implement a source reputation system. Weight sources by domain authority (`.gov` > `.edu` > `.org` > `.com`), citation count, and historical accuracy. Maintain a blocklist of known misinformation domains.

8. **Confidence scores are miscalibrated** → the fact checker reports 95% confidence on a claim that was verified against a single, low-quality source → calibrate confidence as a function of (number of independent sources × source authority × evidence freshness). Never report a single-source verification as > 70% confidence.

9. **Contradictory evidence from equally authoritative sources** → Wikipedia says X, but an official government report says not-X. The fact checker cannot resolve → flag the claim as "disputed" and present both sources to the user. Do not silently pick one. This is common in politics, medicine, and emerging science.

10. **Fact checker is applied to opinions or predictions** → the model says "AI will transform healthcare by 2030." The fact checker tries to verify this as a factual claim and flags it as unsupported → classify claims as factual, opinion, or predictive before verification. Only factual claims enter the verification pipeline. Use a classifier trained to distinguish claim types.

## Code Examples

### Claim Extraction + Verification Pipeline (Python)

```python
from openai import OpenAI
import wikipediaapi
from typing import Literal

client = OpenAI()

ClaimType = Literal["factual", "opinion", "predictive"]
VerificationResult = Literal["supported", "contradicted", "disputed", "unverifiable"]

def extract_claims(text: str) -> list[dict]:
    """Extract verifiable factual claims from model output."""
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{
            "role": "system",
            "content": (
                "Extract all factual claims from the following text. "
                "For each claim, classify it as 'factual', 'opinion', or 'predictive'. "
                "Only return factual claims. Return JSON array: "
                '[{"claim": "...", "type": "factual", "context": "..."}]'
            )
        }, {"role": "user", "content": text}],
        response_format={"type": "json_object"},
    )
    import json
    return json.loads(response.choices[0].message.content).get("claims", [])

def verify_claim_against_wikipedia(claim: str) -> tuple[VerificationResult, str]:
    """Verify a single claim against Wikipedia as a source."""
    wiki = wikipediaapi.Wikipedia("FactChecker/1.0", "en")
    # Extract key entities from the claim for search
    entities = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{
            "role": "system",
            "content": "Extract the main entity (person, place, event, concept) from this claim. Return only the entity name."
        }, {"role": "user", "content": claim}],
    ).choices[0].message.content.strip()

    page = wiki.page(entities)
    if not page.exists():
        return "unverifiable", f"No Wikipedia page for '{entities}'"

    evidence = page.summary[:2000]  # First 2000 chars as evidence

    # Use NLI via LLM for verification
    verdict = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{
            "role": "system",
            "content": (
                "Compare the CLAIM against the EVIDENCE. "
                "Return JSON: {\"verdict\": \"supported|contradicted|disputed|unverifiable\", "
                "\"reasoning\": \"...\"}"
            )
        }, {
            "role": "user",
            "content": f"CLAIM: {claim}\n\nEVIDENCE: {evidence}"
        }],
        response_format={"type": "json_object"},
    )
    import json
    result = json.loads(verdict.choices[0].message.content)
    return result["verdict"], result["reasoning"]

def fact_check_response(model_output: str) -> dict:
    """Full pipeline: extract claims, verify, return report."""
    claims = extract_claims(model_output)
    factual_claims = [c for c in claims if c["type"] == "factual"]

    results = []
    for claim in factual_claims:
        verdict, reasoning = verify_claim_against_wikipedia(claim["claim"])
        results.append({
            "claim": claim["claim"],
            "verdict": verdict,
            "reasoning": reasoning,
            "confidence": _compute_confidence(verdict),
        })

    return {"claims": results, "overall_trustworthiness": _overall_score(results)}

def _compute_confidence(verdict: VerificationResult) -> float:
    return {"supported": 0.85, "contradicted": 0.10, "disputed": 0.40, "unverifiable": 0.20}[verdict]

def _overall_score(results: list[dict]) -> str:
    if not results:
        return "no_factual_claims"
    avg = sum(r["confidence"] for r in results) / len(results)
    if avg >= 0.8: return "high"
    if avg >= 0.5: return "medium"
    return "low"
```

### RAG Faithfulness Check (Post-Generation)

```python
from langchain_core.documents import Document
from langchain_openai import ChatOpenAI

def check_faithfulness(
    answer: str,
    sources: list[Document],
) -> dict:
    """
    Verify that every claim in the answer is supported by the retrieved sources.
    This is the 'faithfulness' metric from RAGAS evaluation.
    """
    source_text = "\n\n".join(f"[{i+1}] {doc.page_content}" for i, doc in enumerate(sources))

    verdict = ChatOpenAI(model="gpt-4o-mini").invoke([
        {"role": "system", "content": (
            "You are evaluating whether an AI-generated answer is faithful to the "
            "provided source documents. An answer is faithful if every factual claim "
            "in it can be traced to one of the source documents.\n"
            "Return JSON: {\"faithful\": bool, \"unsupported_claims\": [\"claim1\", ...]}"
        )},
        {"role": "user", "content": (
            f"SOURCE DOCUMENTS:\n{source_text}\n\n"
            f"ANSWER:\n{answer}"
        )}
    ])

    import json
    return json.loads(verdict.content)
```

## Best Practices

- **Fact check at the pipeline level, not the prompt level.** Do not rely on the model's system prompt alone ("be factual") — this reduces but does not eliminate hallucinations. Use an independent verification step.
- **Use multiple independent sources for verification.** A claim corroborated by Wikipedia, an official government report, and a peer-reviewed paper is far more reliable than one confirmed by a single blog post.
- **Implement claim type classification before verification.** Route factual claims to the verifier, skip opinions and predictions, and flag predictions as "forward-looking, not verifiable."
- **Set hard timeouts on verification.** If fact checking takes longer than the user's patience threshold, return the unverified response with a confidence indicator and continue verification asynchronously.
- **Maintain a source authority registry.** Score each source by domain type, update frequency, historical accuracy, and editorial standards. Use this score to weight verification confidence.
- **Track fact checking metrics over time:** hallucination rate per model version, false positive rate of the verifier, average verification latency, and source coverage gaps. These metrics drive model selection and pipeline improvements.
- **Do not silently suppress unsupported claims.** Instead, present them with a visual indicator ("this claim could not be verified") or regenerate the response with stricter grounding prompts.
- **Test your fact checking pipeline on known hallucination benchmarks.** Use the TruthfulQA benchmark, HaluEval, or a curated set of known model hallucinations in your domain to measure precision and recall.
- **Prefer pre-generation grounding when possible.** It is cheaper and faster to inject correct context into the prompt than to generate, then fact check, then regenerate. Use post-generation fact checking as a safety net.
- **Version your knowledge sources.** When a source is updated, re-run your fact checking pipeline against previously flagged outputs to catch newly contradicted claims.

## Related Topics

- [[HallucinationDetection]]
- [[AICodeReview]]
- [[AIValidation]]
- [[HumanVerification]]
- [[PromptEngineering]]
- [[AIAugmentedDevelopment]]
- [[AI Engineering MOC]]
- [[Quality MOC]]
