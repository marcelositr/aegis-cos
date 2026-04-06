---
layer: foundation
type: templates
priority: high
read_order: 10
version: 1.0.0
tags:
  - templates
  - structure
  - patterns
---

# Templates

## Overview

Reusable code templates following standards.

## Function Template

```typescript
/**
 * Brief description of what this function does.
 * 
 * @param input - Description of input parameter
 * @returns Description of return value
 * 
 * @throws {ErrorType} When this condition occurs
 * 
 * @example
 * const result = myFunction('test');
 */
function functionName(input: InputType): ReturnType {
    // Guard clauses first
    if (!input) {
        throw new Error('Input required');
    }
    
    // Main logic - minimal nesting
    const processed = process(input);
    
    return processed;
}
```

## Class Template

```typescript
/**
 * Brief description of the class.
 */
class ClassName {
    // Properties - grouped by access
    private readonly config: Config;
    private state: State;
    
    // Constructor - dependency injection
    constructor(config: Config) {
        this.config = config;
        this.state = State.INITIAL;
    }
    
    // Public methods
    public execute(): Result {
        this.validate();
        return this.doExecute();
    }
    
    // Private methods
    private validate(): void {
        // Validation logic
    }
    
    private doExecute(): Result {
        // Implementation
        return { success: true };
    }
}
```

## Error Handler Template

```typescript
/**
 * Handles errors with consistent logging and recovery.
 */
class ErrorHandler {
    public handle(error: Error, context: Context): void {
        // Log error
        console.error(`[ERROR] ${context.operation}:`, error.message);
        
        // Determine recovery strategy
        const recovery = this.getRecoveryStrategy(error);
        
        // Attempt recovery
        if (recovery.canRecover) {
            recovery.recover();
        } else {
            // Escalate
            this.escalate(error, context);
        }
    }
    
    private escalate(error: Error, context: Context): void {
        // Notify monitoring
        // Store for analysis
        // Potentially halt execution
    }
}
```

## Test Template

```typescript
describe('FeatureName', () => {
    describe('when condition A', () => {
        it('should do B', () => {
            // Arrange
            const input = createTestInput();
            
            // Act
            const result = execute(input);
            
            // Assert
            expect(result).toEqual(expectedOutput);
        });
    });
});
```

## Validation Template

```typescript
const validationRules = {
    required: (value: any) => value !== null && value !== undefined,
    minLength: (min: number) => (value: string) => value.length >= min,
    maxLength: (max: number) => (value: string) => value.length <= max,
    pattern: (regex: RegExp) => (value: string) => regex.test(value),
};

function validate(value: any, rules: Rule[]): ValidationResult {
    const errors: string[] = [];
    
    for (const rule of rules) {
        if (!rule(value)) {
            errors.push(`Validation failed for rule: ${rule.name}`);
        }
    }
    
    return {
        valid: errors.length === 0,
        errors,
    };
}
```

## Configuration Template

```typescript
interface AppConfig {
    readonly environment: 'development' | 'staging' | 'production';
    readonly apiUrl: string;
    readonly timeout: number;
    readonly retries: number;
}

const config: AppConfig = {
    environment: process.env.NODE_ENV as AppConfig['environment'],
    apiUrl: process.env.API_URL,
    timeout: parseInt(process.env.TIMEOUT || '30000'),
    retries: parseInt(process.env.RETRIES || '3'),
};

export { config, AppConfig };
```

## Portuguese

### Propósito

Templates reutilizáveis seguindo padrões.

### Template de Função

```typescript
/**
 * Descrição breve do que a função faz.
 * 
 * @param entrada - Descrição do parâmetro
 * @returns Descrição do valor de retorno
 */
function nomeFuncao(entrada: TipoEntrada): TipoRetorno {
    // Guard clauses primeiro
    if (!entrada) {
        throw new Error('Entrada requerida');
    }
    
    // Lógica principal - aninhamento mínimo
    const processado = processar(entrada);
    
    return processado;
}
```

### Template de Teste

```typescript
describe('FeatureName', () => {
    describe('quando condição A', () => {
        it('deve fazer B', () => {
            // Arrange
            const entrada = criarEntradaTeste();
            
            // Act
            const resultado = executar(entrada);
            
            // Assert
            expect(resultado).toEqual(resultadoEsperado);
        });
    });
});
```

## Related

- [[knowledge/md/foundation/Naming]]
- [[knowledge/md/foundation/Size]]
- [[knowledge/md/tests/Validation]]
- [[knowledge/md/task/Template]]