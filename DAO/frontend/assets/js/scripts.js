// frontend/assets/js/scripts.js

// Substitua pelo ID do seu canister
const CANISTER_ID = "bkyz2-fmaaa-aaaaa-qaaaq-cai";

async function getBalance(principal) {
    const agent = new dfinity.agent.HttpAgent();
    const actor = dfinity.actor.Actor.createActor({
        // Defina a interface do seu canister aqui
        // Exemplo:
        // 'account_balance': { ... }
    }, {
        agent,
        canisterId: dfinity.principal.Principal.fromText(CANISTER_ID),
    });

    return await actor.account_balance(principal);
}

async function submitProposal(proposalPayload) {
    const agent = new dfinity.agent.HttpAgent();
    const actor = dfinity.actor.Actor.createActor({
        // Defina a interface do seu canister aqui
    }, {
        agent,
        canisterId: dfinity.principal.Principal.fromText(CANISTER_ID),
    });

    return await actor.submit_proposal(proposalPayload);
}

document.getElementById('proposalForm').addEventListener('submit', async (event) => {
    event.preventDefault();
    const proposalData = document.getElementById('proposalInput').value;
    const result = await submitProposal({ message: proposalData });
    console.log(result); // Lidar com o resultado da proposta
});

// Você pode adicionar lógica para obter e exibir o saldo aqui


document.addEventListener('DOMContentLoaded', function () {
    const cards = document.querySelectorAll('.card');

    cards.forEach(card => {
        card.addEventListener('click', () => {
            card.classList.toggle('clicked');
        });
    });
});
