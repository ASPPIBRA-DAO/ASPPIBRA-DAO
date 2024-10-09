import Trie "mo:base/Trie";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Error "mo:base/Error";
import ICRaw "mo:base/ExperimentalInternetComputer";
import List "mo:base/List";
import Time "mo:base/Time";
import Types "./Types";

shared actor class DAO(init : Types.BasicDaoStableStorage) = Self {
    stable var accounts = Types.accounts_fromArray(init.accounts);
    stable var proposals = Types.proposals_fromArray(init.proposals);
    stable var next_proposal_id : Nat = 0;
    stable var system_params : Types.SystemParams = init.system_params;

    system func heartbeat() : async () {
        await execute_accepted_proposals();
    };

    func account_get(id : Principal) : ?Types.Tokens = Trie.get(accounts, Types.account_key(id), Principal.equal);
    func account_put(id : Principal, tokens : Types.Tokens) {
        accounts := Trie.put(accounts, Types.account_key(id), Principal.equal, tokens).0;
    };
    func proposal_get(id : Nat) : ?Types.Proposal = Trie.get(proposals, Types.proposal_key(id), Nat.equal);
    func proposal_put(id : Nat, proposal : Types.Proposal) {
        proposals := Trie.put(proposals, Types.proposal_key(id), Nat.equal, proposal).0;
    };

    /// Função para criar uma nova conta para o `caller` com saldo inicial opcional
    public shared({caller}) func create_account(initial_balance: ?Types.Tokens) : async Types.Result<(), Text> {
        switch (account_get(caller)) {
            case null {
                // Cria a conta com saldo inicial ou saldo zero se não for fornecido
                let balance = Option.get(initial_balance, Types.zeroToken);
                account_put(caller, balance);
                #ok;
            };
            case (?_) { 
                #err("A conta já existe para este usuário.");
            };
        };
    };

    /// Transferir tokens da conta do `caller` para outra conta
    public shared({caller}) func transfer(transfer: Types.TransferArgs) : async Types.Result<(), Text> {
        switch (account_get caller) {
        case null { #err "Caller needs an account to transfer funds" };
        case (?from_tokens) {
                 let fee = system_params.transfer_fee.amount_e8s;
                 let amount = transfer.amount.amount_e8s;
                 if (from_tokens.amount_e8s < amount + fee) {
                     #err ("Caller's account has insufficient funds to transfer " # debug_show(amount));
                 } else {
                     let from_amount : Nat = from_tokens.amount_e8s - amount - fee;
                     account_put(caller, { amount_e8s = from_amount });
                     let to_amount = Option.get(account_get(transfer.to), Types.zeroToken).amount_e8s + amount;
                     account_put(transfer.to, { amount_e8s = to_amount });
                     #ok;
                 };
        };
      };
    };

    /// Retornar o saldo da conta do `caller`
    public query({caller}) func account_balance() : async Types.Tokens {
        Option.get(account_get(caller), Types.zeroToken)
    };

    /// Listar todas as contas
    public query func list_accounts() : async [Types.Account] {
        Iter.toArray(
          Iter.map(Trie.iter(accounts),
                   func ((owner : Principal, tokens : Types.Tokens)) : Types.Account = { owner; tokens }))
    };

    /// Submeter uma proposta
    public shared({caller}) func submit_proposal(payload: Types.ProposalPayload) : async Types.Result<Nat, Text> {
        Result.chain(deduct_proposal_submission_deposit(caller), func (()) : Types.Result<Nat, Text> {
            let proposal_id = next_proposal_id;
            next_proposal_id += 1;

            let proposal : Types.Proposal = {
                id = proposal_id;
                timestamp = Time.now();
                proposer = caller;
                payload;
                state = #open;
                votes_yes = Types.zeroToken;
                votes_no = Types.zeroToken;
                voters = List.nil();
            };
            proposal_put(proposal_id, proposal);
            #ok(proposal_id)
        })
    };

    /// Retornar a proposta com o ID fornecido, se existir
    public query func get_proposal(proposal_id: Nat) : async ?Types.Proposal {
        proposal_get(proposal_id)
    };

    /// Retornar a lista de todas as propostas
    public query func list_proposals() : async [Types.Proposal] {
        Iter.toArray(Iter.map(Trie.iter(proposals), func (kv : (Nat, Types.Proposal)) : Types.Proposal = kv.1))
    };

    // Votar em uma proposta aberta
    public shared({caller}) func vote(args: Types.VoteArgs) : async Types.Result<Types.ProposalState, Text> {
        switch (proposal_get(args.proposal_id)) {
        case null { #err("No proposal with ID " # debug_show(args.proposal_id) # " exists") };
        case (?proposal) {
                 var state = proposal.state;
                 if (state != #open) {
                     return #err("Proposal " # debug_show(args.proposal_id) # " is not open for voting");
                 };
                 switch (account_get(caller)) {
                 case null { return #err("Caller does not have any tokens to vote with") };
                 case (?{ amount_e8s = voting_tokens }) {
                          if (List.some(proposal.voters, func (e : Principal) : Bool = e == caller)) {
                              return #err("Already voted");
                          };
                          
                          var votes_yes = proposal.votes_yes.amount_e8s;
                          var votes_no = proposal.votes_no.amount_e8s;
                          switch (args.vote) {
                          case (#yes) { votes_yes += voting_tokens };
                          case (#no) { votes_no += voting_tokens };
                          };
                          let voters = List.push(caller, proposal.voters);

                          if (votes_yes >= system_params.proposal_vote_threshold.amount_e8s) {
                              // Reembolsa o depósito de proposta quando ela for aceita
                              ignore do ? {
                                  let account = account_get(proposal.proposer)!;
                                  let refunded = account.amount_e8s + system_params.proposal_submission_deposit.amount_e8s;
                                  account_put(proposal.proposer, { amount_e8s = refunded });
                              };
                              state := #accepted;
                          };
                          
                          if (votes_no >= system_params.proposal_vote_threshold.amount_e8s) {
                              state := #rejected;
                          };

                          let updated_proposal = {
                              id = proposal.id;
                              votes_yes = { amount_e8s = votes_yes };                              
                              votes_no = { amount_e8s = votes_no };
                              voters;
                              state;
                              timestamp = proposal.timestamp;
                              proposer = proposal.proposer;
                              payload = proposal.payload;
                          };
                          proposal_put(args.proposal_id, updated_proposal);
                      };
                 };
                 #ok(state)
             };
        };
    };

    /// Retorna os parâmetros atuais do sistema
    public query func get_system_params() : async Types.SystemParams { system_params };

    /// Atualizar parâmetros do sistema
    public shared({caller}) func update_system_params(payload: Types.UpdateSystemParamsPayload) : async () {
        if (caller != Principal.fromActor(Self)) {
            return;
        };
        system_params := {
            transfer_fee = Option.get(payload.transfer_fee, system_params.transfer_fee);
            proposal_vote_threshold = Option.get(payload.proposal_vote_threshold, system_params.proposal_vote_threshold);
            proposal_submission_deposit = Option.get(payload.proposal_submission_deposit, system_params.proposal_submission_deposit);
        };
    };

    /// Deduzir o depósito de submissão de proposta da conta do `caller`
    func deduct_proposal_submission_deposit(caller : Principal) : Types.Result<(), Text> {
        switch (account_get(caller)) {
        case null { #err "Caller needs an account to submit a proposal" };
        case (?from_tokens) {
                 let threshold = system_params.proposal_submission_deposit.amount_e8s;
                 if (from_tokens.amount_e8s < threshold) {
                     #err ("Caller's account must have at least " # debug_show(threshold) # " to submit a proposal")
                 } else {
                     let from_amount : Nat = from_tokens.amount_e8s - threshold;
                     account_put(caller, { amount_e8s = from_amount });
                     #ok
                 };
             };
        };
    };

    /// Executar todas as propostas aceitas
    func execute_accepted_proposals() : async () {
        let accepted_proposals = Trie.filter(proposals, func (_ : Nat, proposal : Types.Proposal) : Bool = proposal.state == #accepted);
        // Atualiza o estado da proposta para que não seja escolhida no próximo heartbeat
        for ((id, proposal) in Trie.iter(accepted_proposals)) {
            update_proposal_state(proposal, #executing);
        };

        for ((id, proposal) in Trie.iter(accepted_proposals)) {
            switch (await execute_proposal(proposal)) {
            case (#ok) { update_proposal_state(proposal, #succeeded); };
            case (#err(err)) { update_proposal_state(proposal, #failed(err)); };
            };
        };
    };

    /// Executa a proposta dada
    func execute_proposal(proposal: Types.Proposal) : async Types.Result<(), Text> {
        try {
            let payload = proposal.payload;
            ignore await ICRaw.call(payload.canister_id, payload.method, payload.message);
            #ok
        }
        catch (e) { #err(Error.message e) };
    };

    func update_proposal_state(proposal: Types.Proposal, state: Types.ProposalState) {
        let updated = {
            state;
            id = proposal.id;
            votes_yes = proposal.votes_yes;
            votes_no = proposal.votes_no;
            voters = proposal.voters;
            timestamp = proposal.timestamp;
            proposer = proposal.proposer;
            payload = proposal.payload;
        };
        proposal_put(proposal.id, updated);
    };
};
