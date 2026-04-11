---
title: AI Engineering MOC
title_pt: Engenharia de IA — Mapa de Conteúdo
layer: ai
type: index
version: 1.0.0
tags:
  - AI
  - MOC
  - Index
description: Navigation hub for AI-assisted development, prompt engineering, and AI validation.
description_pt: Hub de navegação para desenvolvimento assistido por IA, engenharia de prompt e validação de IA.
---

# AI Engineering MOC

## AI-Assisted Development

- [[AIAugmentedDevelopment]] — Using AI to enhance the entire software development lifecycle
- [[AICodeGeneration]] — Using AI to generate code as starting point for human refinement
- [[AICodeReview]] — Leveraging AI for automated code review and quality assessment

## Prompt Engineering

- [[PromptEngineering]] — Designing effective prompts to get reliable AI outputs

## AI Validation & Safety

- [[AIValidation]] — Verifying correctness and quality of AI-generated outputs
- [[HallucinationDetection]] — Identifying when AI generates false or fabricated information
- [[HumanVerification]] — Human-in-the-loop processes for validating AI decisions

## Reasoning Path

1. Set up AI workflow: [[AIAugmentedDevelopment]] → [[PromptEngineering]] → [[AICodeGeneration]]
2. Review code: [[AICodeReview]] → [[AIValidation]]
3. Ensure safety: [[HallucinationDetection]] → [[HumanVerification]]

## Cross-Domain Links

- [[AIAugmentedDevelopment]] → [[CiCd]] → [[Testing]]
- [[AICodeReview]] → [[CodeQuality]] → [[StaticAnalysis]]
- [[PromptEngineering]] → [[APIDesign]] → [[InterfaceDesign]]
- [[AIValidation]] → [[MutationTesting]] → [[PropertyTesting]]
- [[HallucinationDetection]] → [[Testing]] → [[Fuzzing]]
- [[HumanVerification]] → [[AcceptanceTesting]] → [[BDD]]
- [[AIAugmentedDevelopment]] → [[TDD]] → [[Refactoring]]
