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

Este projeto demonstra uma implementação sólida de uma DAO no Internet Computer, aplicando princípios de governança descentralizada e gerenciamento de propostas.





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

