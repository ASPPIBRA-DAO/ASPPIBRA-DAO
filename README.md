# ASPPIBRA-DAO

<div>
Hello, We are ASPPIBRA-DAO the first Decentralized Autonomous Organization in Brazil.
</div> 
<div style="display: inline_block"><br>

<a href="https://bscscan.com/token/0x0697ab2b003fd2cbaea2df1ef9b404e45be59d4c?a=0xDfcE227bf1FfBBbec6410c2C2E22873293e6b56F/" target="_blank">
<img align="center" alt="Bscscan" height="70" width="70" 
src="https://user-images.githubusercontent.com/80177249/189129817-0793f573-cffd-473c-b93a-a56170699920.svg">
</a>
<a class="text-light" href="https://opensea.io/collection/asppibra-collection">
<img align="center" alt="Opeansea" height="30" width="40" src="https://user-images.githubusercontent.com/80177249/189160382-2df611a1-23f4-41e2-ad5a-b896fcc8dbd5.svg">
</a>
<a class="text-light" href="https://coinmarketcap.com/dexscan/bsc/0xe7c00c6dc9c729d3eb830f854fd9a6c5150b11c5/">
<img align="center" alt="Coinmarktcap" height="30" width="40" src="https://user-images.githubusercontent.com/80177249/231921538-4a3299f0-d8d8-45ef-81e3-587692dd86c1.svg">
</a>

</div>


![Mundo Digital](https://user-images.githubusercontent.com/80177249/231606922-94e1b2a0-29cd-4125-af8c-c65ffb002d0a.png)


Today we are developing a platform (Defi) that allows the validation of documents on a large scale for real estate, civil and copyright registration, this platform uses advanced encryption for data security and swap negotiations within the Ecosystem, boosting digital inclusion and economic growth in Brazil.

ASPPIBRA - Associação dos Proprietários e Possuidores de Imóveis no Brasil is a non-profit civil association, founded on 09/04/2016 in the State of Rio de Janeiro-RJ, with the objective of defending and representing property owners and owners in the Brazil. ASPPIBRA was founded with the aim of accelerating digital inclusion in Brazil and facilitating Brazilian citizens' access to resources and services through new technologies and making land tenure regularization in Brazil a reality for everyone, even those who do not have access to information. Knowing well the difficulties faced throughout the national territory, it seeks to provide a support service to all holders with regard to Private Property, real estate registration, licensing, access to information, training and qualification of professionals and exemption in the globalized digital world. ASPPIBRA is an entity that works for the collective well-being, promoting citizenship and digital inclusion, always acting within the limits of the Law.



# DAO (Decentralized Autonomous Organization)

Este repositório implementa uma DAO (Decentralized Autonomous Organization) utilizando a linguagem Motoko no Internet Computer (IC). A DAO permite transferências de tokens, submissão e votação de propostas, além de executar ações automaticamente via heartbeat.

## Arquitetura e Estrutura

A classe `DAO` é um ator compartilhado (shared actor) que gerencia contas de usuários, propostas e parâmetros do sistema. Utiliza estruturas de dados eficientes, como Tries e Iteradores, para armazenar e manipular informações.

## Estrutura do Main.mo

### Variáveis `stable`

- **`accounts`**: Armazena o estado das contas dos usuários usando uma estrutura Trie.
- **`proposals`**: Armazena as propostas submetidas no sistema.
- **`next_proposal_id`**: Um contador para gerar IDs únicos para novas propostas.
- **`system_params`**: Parâmetros configuráveis do sistema, como taxas e limites de votação.

## Funções

### 1. `heartbeat()`
- Executa propostas aceitas automaticamente em intervalos regulares.

### 2. `account_get()` e `account_put()`
- **`account_get`**: Obtém o saldo de tokens de uma conta usando o identificador `Principal`.
- **`account_put`**: Atualiza o saldo de uma conta no Trie.

### 3. `proposal_get()` e `proposal_put()`
- **`proposal_get`**: Obtém uma proposta pelo ID.
- **`proposal_put`**: Atualiza uma proposta no Trie.

### 4. `transfer()`
- Transfere tokens da conta do chamador para outra conta. Verifica se há saldo suficiente, considerando a taxa de transferência.

### 5. `account_balance()`
- Retorna o saldo de tokens da conta do chamador.

### 6. `list_accounts()`
- Retorna uma lista de todas as contas no DAO.

### 7. `submit_proposal()`
- Submete uma nova proposta. Deduz um depósito da conta do chamador e cria uma proposta com status inicial "open".

### 8. `get_proposal()`
- Retorna os detalhes de uma proposta pelo ID.

### 9. `list_proposals()`
- Lista todas as propostas registradas no DAO.

### 10. `vote()`
- Permite que usuários votem em propostas "sim" ou "não". Se os votos atingirem o limite definido, a proposta é aceita ou rejeitada.

### 11. `get_system_params()`
- Retorna os parâmetros atuais do sistema, como taxas de transferência e limites de votação.

### 12. `update_system_params()`
- Atualiza os parâmetros do sistema. Pode ser chamado apenas após a aprovação de uma proposta.

### 13. `deduct_proposal_submission_deposit()`
- Deduz o valor do depósito de submissão de uma proposta da conta do chamador.

### 14. `execute_accepted_proposals()`
- Executa todas as propostas aceitas e altera o estado para `executing` para evitar execuções duplicadas.

### 15. `execute_proposal()`
- Executa uma proposta chamando um método em um canister remoto, conforme especificado na proposta.

### 16. `update_proposal_state()`
- Atualiza o estado de uma proposta após execução ou votação.

## Lógica de Estruturas

### Contas (`accounts`)
As contas são armazenadas em uma Trie, oferecendo uma maneira eficiente de acessar, atualizar e iterar sobre os saldos de tokens dos usuários. Cada conta é identificada por um `Principal`, e as operações de consulta e inserção utilizam comparações diretas para verificar chaves.

### Propostas (`proposals`)
As propostas também são armazenadas em uma Trie e acessadas pelo seu ID. Quando uma proposta é submetida, ela é criada com status "open" e os usuários podem votar. A proposta será aceita ou rejeitada dependendo da quantidade de votos e o limite configurado em `system_params`.

### Parâmetros do Sistema (`system_params`)
Os parâmetros controlam taxas, limites de votação e depósitos necessários para submeter propostas. Eles são atualizados dinamicamente via propostas aceitas e não podem ser alterados diretamente por usuários.

## Melhorias Futuras

- **Validação de Entrada**: Implementar mais validações de entrada para melhorar a robustez do sistema.
- **Tratamento de Erros**: Expandir o tratamento de exceções em operações críticas, como transferências e execuções de propostas.
- **Escalabilidade**: Embora o uso de Trie seja eficiente, pode-se considerar estratégias de otimização para suportar um número crescente de usuários e transações.

---



## Estrutura do Types.mo

A implementação é organizada em torno de definições de tipos e funções que facilitam o gerenciamento de contas, propostas e parâmetros do sistema DAO. Abaixo estão os principais componentes do código:

### Tipos Principais

1. **`Account`**:
   - Representa uma conta no DAO, contendo o proprietário (um `Principal`) e a quantidade de tokens.

2. **`Proposal`**:
   - Define uma proposta no DAO, contendo seu estado, votos a favor e contra, proponente e detalhes da proposta.

3. **`ProposalPayload`**:
   - Contém os detalhes da proposta a ser executada, como o método a ser chamado, o `canister_id` e a mensagem associada.

4. **`ProposalState`**:
   - Enumera os diferentes estados de uma proposta:
     - `#failed`: Proposta falhou na execução.
     - `#open`: Proposta aberta para votação.
     - `#executing`: Proposta em execução.
     - `#rejected`: Proposta rejeitada por votos contrários.
     - `#succeeded`: Proposta executada com sucesso.
     - `#accepted`: Proposta aceita, aguardando execução.

5. **`Tokens`**:
   - Representa a quantidade de tokens em formato `Nat`, armazenado como `amount_e8s`.

6. **`SystemParams`**:
   - Define os parâmetros de governança, incluindo:
     - `transfer_fee`: Taxa de transferência.
     - `proposal_vote_threshold`: Limite de votos para aceitar/rejeitar uma proposta.
     - `proposal_submission_deposit`: Depósito necessário para submissão de uma proposta.

7. **`BasicDaoStableStorage`**:
   - Armazena o estado estável do DAO, incluindo as contas, propostas e os parâmetros do sistema.

### Funções Principais

1. **`proposal_key(t: Nat)`**:
   - Gera uma chave para armazenar uma proposta no Trie com base no ID (`Nat`).

2. **`account_key(t: Principal)`**:
   - Gera uma chave para armazenar uma conta no Trie usando o identificador `Principal`.

3. **`accounts_fromArray(arr: [Account])`**:
   - Converte uma lista de contas em uma Trie de contas, onde a chave é o identificador `Principal` e o valor é o saldo de tokens.

4. **`proposals_fromArray(arr: [Proposal])`**:
   - Converte uma lista de propostas em uma Trie de propostas, onde a chave é o ID da proposta.

5. **`oneToken` e `zeroToken`**:
   - Constantes usadas para definir valores padrão de tokens:
     - `oneToken`: Um token com valor de 10 milhões de unidades.
     - `zeroToken`: Valor zero de tokens.

## Lógica e Estruturas Utilizadas

### Trie (Árvore de Prefixo)

A estrutura `Trie` é usada para armazenar contas e propostas de forma eficiente. Ela permite uma busca rápida por chaves específicas, facilitando a organização e manipulação de grandes conjuntos de dados. Cada conta é associada ao `Principal` de um usuário, e cada proposta é associada ao seu ID (`Nat`).

### Contas (`accounts`)

As contas são armazenadas em uma Trie onde a chave é o `Principal` e o valor é a quantidade de tokens. A função `accounts_fromArray` converte um array de contas em uma Trie para facilitar futuras consultas e atualizações de saldos.

### Propostas (`proposals`)

As propostas também são armazenadas em uma Trie, onde cada proposta tem um ID numérico como chave e o valor contém os detalhes da proposta, como votos, proponente e estado. A função `proposals_fromArray` converte um array de propostas em uma Trie para fácil manipulação.

### Tokens e Parâmetros do Sistema

Os tokens são representados pelo tipo `Tokens`, que armazena a quantidade como um valor `Nat`. Os parâmetros do sistema, como a taxa de transferência e o depósito para submissão de propostas, são armazenados no tipo `SystemParams`, permitindo flexibilidade na governança.

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


## <h2 align="center">🎁 Doe Crypto:</h2>

<div style="display: inline_block"><br>

<a href="https://" target="_blank">
  <img align="center" alt="BTC" height="30" width="40" src="https://user-images.githubusercontent.com/80177249/180482937-475896ac-4853-470f-80da-dae18bcf7748.svg">
</a>
<a href="https://" target="_blank">
  <img align="center" alt="BNB" height="30" width="40" src="https://user-images.githubusercontent.com/80177249/180481724-2560053f-dcd3-4879-a63f-5801eb373e66.svg">
</a>
<a href="https://" target="_blank">
  <img align="center" alt="ETH" height="30" width="40" src="https://user-images.githubusercontent.com/80177249/180481896-cf45cdde-72f9-4986-8181-9ee64fae126d.svg">  
</a>
  
## <img src="https://img.icons8.com/nolan/25/computer.png"/> Connect with me

[![LinkedIn](https://img.shields.io/badge/linkedin-%230077B5.svg?&style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/company/asppibra-dao/) 
[![Instagram](https://img.shields.io/badge/Instagram-%23E4405F.svg?style=for-the-badge&logo=Instagram&logoColor=white)](https://instagram.com/asppibra/) 
[![Twitter](https://img.shields.io/badge/twitter-%231DA1F2.svg?&style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/ASPPIBRA_ORG) 
[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/Mundo_Digital_BR)
[![Discord](https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white)](https://discord)

</div>

