# DAO (Decentralized Autonomous Organization)

keywords: [advanced, motoko, dao, decentralized organization, decentralized org]

[View this sample's code on GitHub](https://github.com/ASPPIBRA-DAO/ASPPIBRA-DAO)

Este repositório implementa uma DAO [organização autônoma descentralizada](https://en.wikipedia.org/wiki/Decentralized_autonomous_organization) utilizando a linguagem Motoko implantada no [Internet Computer](https://github.com/dfinity/ic) (IC). A DAO permite transferências de tokens, submissão e votação de propostas, além de executar ações automaticamente via heartbeat, O código de amostra DAO básico está disponível em [Motoko](https://k7gat-daaaa-aaaae-qaahq-cai.ic0.app/listing/asppibra-dao-10329).

## Visão geral

Um `basic_dao` pode ser inicializado com um conjunto de contas: mapeamentos de IDs principais para um número de tokens. Os proprietários de contas podem consultar o saldo de suas contas chamando `account_balance` e transferir tokens para outras contas chamando `transfer`. Qualquer um pode chamar `list_accounts` para visualizar todas as contas.

Os proprietários de contas podem enviar propostas chamando `submit_proposal`. Uma proposta especifica um recipiente, método e argumentos para este método. Os proprietários de contas podem votar (`Sim` ou `Não`) em uma proposta chamando `vote`. A quantidade de votos votados é igual à quantidade de tokens que o proprietário da conta tem. Se votos `Sim` suficientes forem votados, `basic_dao` executará a proposta chamando o método fornecido da proposta com os argumentos fornecidos contra o recipiente fornecido. Se votos `Não` suficientes forem votados, a proposta não será executada e, em vez disso, será marcada como `Rejeitada`.

Certos parâmetros do sistema, como o número de votos `Sim` necessários para aprovar uma proposta, podem ser consultados chamando `get_system_params`. Esses parâmetros do sistema podem ser modificados por meio do processo de proposta, ou seja, uma proposta pode ser feita para chamar `update_system_params` com valores atualizados.
Este fluxo de trabalho é demonstrado abaixo.

## Arquitetura e Estrutura

A classe `DAO` é um ator compartilhado (shared actor) que gerencia contas de usuários, propostas e parâmetros do sistema. Utiliza estruturas de dados eficientes, como Tries e Iteradores, para armazenar e manipular informações.

## Estrutura do Main.mo

### Variáveis `stable`

- **`accounts`**: Armazena o estado das contas dos usuários usando uma estrutura Trie.
- **`proposals`**: Armazena as propostas submetidas no sistema.
- **`next_proposal_id`**: Um contador para gerar IDs únicos para novas propostas.
- **`system_params`**: Parâmetros configuráveis do sistema, como taxas e limites de votação.

### Funções

#### 1. `heartbeat()`

- Executa automaticamente propostas aceitas em intervalos regulares. A cada batida de coração do sistema, verifica se há propostas aceitas pendentes de execução e tenta executá-las.

#### 2. `account_get()` e `account_put()`

- **`account_get`**: Obtém o saldo de tokens de uma conta usando o identificador `Principal`. Retorna `null` se a conta não existir.
- **`account_put`**: Atualiza o saldo de uma conta no Trie.

#### 3. `proposal_get()` e `proposal_put()`

- **`proposal_get`**: Obtém uma proposta pelo seu ID. Retorna `null` se a proposta não existir.
- **`proposal_put`**: Atualiza uma proposta no Trie com base no ID da proposta.

#### 4. `transfer()`

- Transfere tokens da conta do chamador para outra conta, verificando se há saldo suficiente para cobrir o valor e a taxa de transferência. Retorna um erro se o saldo for insuficiente.

#### 5. `account_balance()`

- Retorna o saldo de tokens da conta do chamador. Se a conta não existir, retorna um valor de saldo zero.

#### 6. `list_accounts()`

- Retorna uma lista de todas as contas cadastradas no DAO, incluindo o `Principal` do proprietário e a quantidade de tokens.

#### 7. `submit_proposal()`

- Submete uma nova proposta, deduzindo um depósito da conta do chamador. Se o saldo for suficiente, cria uma proposta com o status inicial "open" e a adiciona à lista de propostas.

#### 8. `get_proposal()`

- Retorna os detalhes de uma proposta pelo ID, se ela existir.

#### 9. `list_proposals()`

- Lista todas as propostas registradas no DAO.

#### 10. `vote()`

- Permite que os usuários votem "sim" ou "não" em uma proposta. Se os votos atingirem o limite definido, a proposta será aceita ou rejeitada. Impede que o mesmo usuário vote mais de uma vez.

#### 11. `get_system_params()`

- Retorna os parâmetros atuais do sistema, como taxas de transferência e limites de votação.

#### 12. `update_system_params()`

- Atualiza os parâmetros do sistema. Somente pode ser chamado após a aprovação de uma proposta e pela entidade responsável (a DAO).

#### 13. `deduct_proposal_submission_deposit()`

- Deduz o valor do depósito de submissão de proposta da conta do chamador. Retorna um erro se o saldo for insuficiente.

#### 14. `execute_accepted_proposals()`

- Executa todas as propostas aceitas e altera o estado para `executing` para evitar execuções duplicadas.

#### 15. `execute_proposal()`

- Executa uma proposta chamando um método em um canister remoto, conforme especificado no `ProposalPayload`. Se falhar, retorna um erro com detalhes da falha.

#### 16. `update_proposal_state()`

- Atualiza o estado de uma proposta após a execução ou votação.

### Detalhamento de Funções Críticas

#### `execute_proposal()`

- **Objetivo**: Executa a proposta chamando o método especificado no `canister_id` da proposta.
- **Lógica**: Faz uma chamada assíncrona usando `ICRaw.call` para o canister, passando o método e a mensagem da proposta. Se a execução for bem-sucedida, o estado da proposta é atualizado para `succeeded`. Caso contrário, a proposta é marcada como `failed` e a mensagem de erro é retornada.

#### `vote()`

- **Objetivo**: Gerencia o processo de votação de uma proposta.
- **Lógica**: Cada proposta tem dois contadores de votos (`votes_yes` e `votes_no`). Quando o usuário vota, o sistema verifica se ele já votou e impede votos repetidos. Após o voto, a quantidade de tokens do usuário é contabilizada no respectivo contador. Se os votos a favor ou contra atingirem o limite definido em `system_params.proposal_vote_threshold`, a proposta é aceita ou rejeitada.

### Tratamento de Erros e Exceções

O sistema utiliza o tipo `Result` para capturar e tratar possíveis erros durante as operações. Funções como `transfer()` e `submit_proposal()` retornam erros descritivos em caso de saldo insuficiente ou tentativas inválidas. A função `execute_proposal()` também retorna mensagens de erro detalhadas em caso de falha na execução de uma proposta.

### Exemplo de Uso

Aqui está um exemplo básico de uso do sistema DAO:

1. **Criar uma conta e transferir tokens**:

    ```motoko
    let caller = Principal.fromText("<principal_do_usuario>");
    account_put(caller, { amount_e8s = 100_000_000 });  // Inicializa a conta com 100 tokens
    
    let transferArgs = { to = another_user; amount = { amount_e8s = 10_000_000 } };  // Transfere 10 tokens
    let result = await transfer(transferArgs);
    ```

2. **Submeter uma proposta**:

    ```motoko
    let proposalPayload = { method = "upgrade"; canister_id = myCanister; message = myMessage };
    let proposalResult = await submit_proposal(proposalPayload);
    ```

3. **Votar em uma proposta**:

    ```motoko
    let voteArgs = { vote = #yes; proposal_id = 1 };  // Vota "sim" na proposta com ID 1
    let voteResult = await vote(voteArgs);
    ```

## Lógica de Estruturas

### Contas (`accounts`)

As contas são armazenadas em uma Trie, oferecendo uma maneira eficiente de acessar, atualizar e iterar sobre os saldos de tokens dos usuários. Cada conta é identificada por um `Principal`, e as operações de consulta e inserção utilizam comparações diretas para verificar chaves.

### Propostas (`proposals`)

As propostas também são armazenadas em uma Trie e acessadas pelo seu ID. Quando uma proposta é submetida, ela é criada com status "open" e os usuários podem votar. A proposta será aceita ou rejeitada dependendo da quantidade de votos e o limite configurado em `system_params`.

### Parâmetros do Sistema (`system_params`)

Os parâmetros controlam taxas, limites de votação e depósitos necessários para submeter propostas. Eles são atualizados dinamicamente via propostas aceitas e não podem ser alterados diretamente por usuários.

## Melhorias Futuras

1. **Validação de Dados**:
   - Implementar mais validações de dados para garantir que as entradas sejam corretas ao adicionar ou atualizar informações nas Tries.

2. **Tratamento de Erros**:
   - Expandir o uso de `Result` para capturar e tratar possíveis erros durante a execução de operações, especialmente ao lidar com tokens e propostas.

3. **Documentação**:
   - Adicionar mais comentários explicativos para melhorar a compreensão do código, especialmente em funções mais complexas.

4. **Escalabilidade**:
   - A `Trie` oferece uma estrutura eficiente para busca e inserção, mas será necessário explorar otimizações para suportar um número crescente de usuários e propostas no sistema.

---

Este projeto oferece uma base sólida para uma DAO no Internet Computer, utilizando estruturas de dados eficientes e boas práticas de modularização. Ele está preparado para suportar futuras expansões e melhorias.

Veja a [definição do serviço canister](https://) para mais detalhes.

### Pré-requisitos

Este exemplo requer uma instalação de:

- [x] Instale o [IC SDK](https://internetcomputer.org/docs/current/developer-docs/setup/install/).

```bash
sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)"
```

- [x] Para executar os scripts de teste, você precisa baixar [ic-repl](https://github.com/chenyan2002/ic-repl/releases).

Comece abrindo uma janela de terminal.

### Step 1: Navigate into the folder containing the project's files and start a local instance of the Internet Computer with the command

```bash
cd DAO/motoko
dfx start --background
```

- Canniter Publico:
ixi6n-eiaaa-aaaad-qayoq-cai

```bash
dfx canister status ASPPIBRA-DAO
dfx canister id ASPPIBRA-DAO
```

```bash
dfx canister start ASPPIBRA-DAO
dfx deploy ASPPIBRA-DAO
dfx canister stop bkyz2-fmaaa-aaaaa-qaaaq-cai
```

### Etapa 2: Crie identidades de teste com os comandos

```bash
dfx identity new Alice --storage-mode=plaintext; 
dfx identity use Alice; 
export ALICE=$(dfx identity get-principal);

dfx identity new Bob --storage-mode=plaintext
dfx identity use Bob
export BOB=$(dfx identity get-principal);
```

### Etapa 3: Implantar `ASPPIBRA-DAO` com contas de teste iniciais

```bash

dfx deploy ASPPIBRA-DAO --argument "(record {
    accounts = vec {
        record { owner = principal \"$ALICE\"; tokens = record { amount_e8s = 100_000_000 }; };
        record { owner = principal \"$BOB\"; tokens = record { amount_e8s = 100_000_000 }; };
    };
    proposals = vec {};
    system_params = record {
        transfer_fee = record { amount_e8s = 10_000 };
        proposal_vote_threshold = record { amount_e8s = 10_000_000 };
        proposal_submission_deposit = record { amount_e8s = 10_000 };
    };
})"

```

### Testar Funcionalidades do DAO: Agora que o DAO está rodando, aqui estão algumas funcionalidades importantes que você pode testar

- Verificar o saldo de uma conta (account_balance): Use a interface Candid ou execute um comando diretamente para verificar o saldo de Alice ou Bob:

```bash
dfx canister call ASPPIBRA-DAO account_balance "(principal \"$ALICE\")"
```

- Transferir tokens entre contas (transfer): Teste uma transferência de tokens de Alice para Bob:

```bash
dfx identity use Alice
dfx canister call ASPPIBRA-DAO transfer "(record { to = principal \"$BOB\"; amount = record { amount_e8s = 10_000_000 } })"

```

- Submeter uma proposta (submit_proposal): Alice pode submeter uma proposta, como por exemplo, uma atualização no sistema:

```bash
dfx canister call ASPPIBRA-DAO submit_proposal "(record { method = \"upgrade\"; canister_id = principal \"$BOB\"; message = vec {} })"

```

- Votar em uma proposta (vote): Após a submissão da proposta, tanto Alice quanto Bob podem votar. Para Alice votar:

```bash
dfx canister call ASPPIBRA-DAO vote "(record { proposal_id = 1; vote = #yes })"

```

### Etapa 4: execute os scripts de teste ic-repl

```bash
ic-repl tests/account.test.sh
ic-repl tests/proposal.test.sh
```
